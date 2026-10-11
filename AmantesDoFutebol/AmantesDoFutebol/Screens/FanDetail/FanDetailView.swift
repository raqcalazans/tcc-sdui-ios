import SwiftUI

struct FanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FanDetailViewModel
    private let service: FanAPIServiceProtocol
    private let onChange: () -> Void
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false

    init(fanId: Int, service: FanAPIServiceProtocol = FanAPIService.shared, onChange: @escaping () -> Void) {
        self.service = service
        self.onChange = onChange
        _viewModel = StateObject(wrappedValue: FanDetailViewModel(fanId: fanId, service: service))
    }

    var body: some View {
        Group {
            if let screen = viewModel.screen, viewModel.fan != nil {
                List {
                    ForEach(screen.sections) { section in
                        Section(section.title ?? "") {
                            ForEach(section.components) { component in
                                LabeledContent(component.label ?? "", value: viewModel.value(for: component))
                                    .accessibilityElement(children: .combine)
                                    .accessibilityIdentifier("detailRow_\(component.label ?? component.id)")
                            }
                        }
                    }
                    Section {
                        ForEach(screen.actions) { action in
                            if action.id == "editFan" {
                                Button(action.title, systemImage: "pencil") { showingEdit = true }
                                    .accessibilityIdentifier("editFanButton")
                            } else if action.id == "deleteFan" {
                                Button(role: .destructive) { showingDeleteConfirmation = true } label: {
                                    Label(action.title, systemImage: "trash")
                                        .foregroundStyle(.red)
                                }
                                .tint(.red)
                                .accessibilityIdentifier("deleteFanButton")
                            }
                        }
                    }
                }
            } else if viewModel.isLoading {
                ProgressView("Carregando detalhes...")
            } else {
                ContentUnavailableView("Detalhes indisponíveis", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(viewModel.screen?.screenTitle ?? "Detalhes do fã")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .sheet(isPresented: $showingEdit, onDismiss: { Task { await viewModel.load(); onChange() } }) {
            NavigationStack {
                FanRegistrationView(fanId: viewModel.fanId, service: service)
                    .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancelar") { showingEdit = false } } }
            }
        }
        .confirmationDialog("Excluir este fã?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Excluir fã", role: .destructive) {
                Task {
                    do { try await viewModel.delete(); onChange(); dismiss() }
                    catch { viewModel.errorMessage = "Não foi possível excluir este fã. Tente novamente." }
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: { Text("Esta ação não pode ser desfeita.") }
        .alert("Não foi possível concluir", isPresented: errorPresented) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "Ocorreu um erro.") }
    }

    private var errorPresented: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })
    }
}
