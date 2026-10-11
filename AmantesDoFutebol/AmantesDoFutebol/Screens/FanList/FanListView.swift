import SwiftUI

struct FanListView: View {
    @StateObject private var viewModel: FanListViewModel
    private let service: FanAPIServiceProtocol
    @State private var showingRegistration = false
    @State private var path: [Int] = []

    init(service: FanAPIServiceProtocol = FanAPIService.shared) {
        self.service = service
        _viewModel = StateObject(wrappedValue: FanListViewModel(service: service))
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if viewModel.isLoading && viewModel.screen == nil {
                    ProgressView("Carregando...")
                } else if let screen = viewModel.screen {
                    listContent(screen)
                } else {
                    ContentUnavailableView("Não foi possível carregar", systemImage: "wifi.exclamationmark")
                }
            }
            .navigationTitle(viewModel.screen?.screenTitle ?? "Amantes do Futebol")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Int.self) { fanId in
                FanDetailView(fanId: fanId, service: service) { Task { await viewModel.load() } }
            }
            .overlay(alignment: .bottomTrailing) {
                Button { showingRegistration = true } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 58)
                        .background(Color.accentColor, in: Circle())
                        .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                }
                .accessibilityLabel(createActionTitle)
                .accessibilityIdentifier("addFanButton")
                .padding(22)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { Task { await viewModel.load() } } label: { Image(systemName: "arrow.clockwise") }
                        .accessibilityLabel("Atualizar lista")
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .sheet(isPresented: $showingRegistration, onDismiss: { Task { await viewModel.load() } }) {
                NavigationStack {
                    FanRegistrationView(service: service)
                        .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancelar") { showingRegistration = false } } }
                }
            }
            .alert("Não foi possível carregar", isPresented: errorPresented) {
                Button("Tentar novamente") { Task { await viewModel.load() } }
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: { Text(viewModel.errorMessage ?? "Ocorreu um erro.") }
        }
    }

    @ViewBuilder
    private func listContent(_ screen: ScreenDefinition) -> some View {
        let listComponents = screen.sections.flatMap(\.components).filter { $0.type == "FAN_LIST" }
        if viewModel.fans.isEmpty {
            ContentUnavailableView("Nenhum fã cadastrado", systemImage: "person.2", description: Text("Toque em + para cadastrar a primeira pessoa."))
        } else {
            List {
                ForEach(listComponents) { component in
                    Section {
                        ForEach(viewModel.fans) { fan in
                            NavigationLink(value: fan.id) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(value(component.titleField, from: fan)).font(.headline)
                                    Label(value(component.subtitleField, from: fan), systemImage: "shield")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 5)
                            }
                            .accessibilityIdentifier("fanRow_\(fan.id)")
                        }
                    } header: {
                        EmptyView()
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private var createActionTitle: String {
        viewModel.screen?.actions.first(where: { $0.id == "createFan" })?.title ?? "Cadastrar fã"
    }

    private var errorPresented: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })
    }

    private func value(_ field: String?, from fan: Fan) -> String {
        guard let field else { return "" }
        if field == "name" { return fan.name }
        if field == "favoriteTeamId" {
            return viewModel.teamNames[fan.favoriteTeamId] ?? fan.favoriteTeamId
        }
        return fan.name
    }
}
