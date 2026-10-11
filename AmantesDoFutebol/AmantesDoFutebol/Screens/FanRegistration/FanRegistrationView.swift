import SwiftUI

struct FanRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FanRegistrationViewModel
    private let service: FanAPIServiceProtocol

    init(fanId: Int? = nil, service: FanAPIServiceProtocol = FanAPIService.shared) {
        self.service = service
        _viewModel = StateObject(wrappedValue: FanRegistrationViewModel(fanId: fanId, service: service))
    }

    var body: some View {
        Group {
            if let screen = viewModel.screen {
                Form {
                    ForEach(screen.sections) { section in
                        Section(section.title ?? "") {
                            ForEach(section.components) { component in
                                render(component)
                            }
                        }
                    }
                    Section {
                        Button(actionTitle) {
                            Task {
                                do { try await viewModel.save(); dismiss() }
                                catch { viewModel.errorMessage = error.localizedDescription }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .disabled(viewModel.isLoading || !viewModel.requiredOptionsAvailable)
                    }
                }
            } else if viewModel.isLoading {
                ProgressView("Carregando formulário...")
            } else {
                ContentUnavailableView("Formulário indisponível", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(viewModel.screen?.screenTitle ?? (viewModel.isEditing ? "Editar fã" : "Cadastro de fã"))
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .alert("Não foi possível concluir", isPresented: errorPresented) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "Ocorreu um erro.") }
    }

    @ViewBuilder
    private func render(_ component: ScreenComponent) -> some View {
        let field = component.field ?? component.id
        switch component.type {
        case "TEXT_FIELD":
            TextField(component.label ?? "", text: binding(for: field))
                .keyboardType(component.keyboard == "EMAIL" ? .emailAddress : .default)
                .textInputAutocapitalization(component.keyboard == "EMAIL" ? .never : .sentences)
                .autocorrectionDisabled(component.keyboard == "EMAIL")
                .accessibilityIdentifier(component.id)
        case "DATE_FIELD":
            TextField(component.label ?? "Data de nascimento (DD/MM/AAAA)", text: Binding(
                get: { viewModel.values[field, default: ""] },
                set: { viewModel.values[field] = FanDateFormatter.mask($0) }
            ))
            .keyboardType(.numbersAndPunctuation)
            .accessibilityIdentifier("birthDateField")
        case "SELECT":
            Picker(component.label ?? "", selection: binding(for: field)) {
                Text("Selecione").tag("")
                ForEach(viewModel.options(for: component)) { option in
                    Text(option.label).tag(option.id)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier(component.id == "gender" ? "genderPicker" : component.id)
        default:
            Text("Componente não suportado: \(component.type)").foregroundStyle(.red)
        }
    }

    private var actionTitle: String {
        viewModel.screen?.actions.first(where: { $0.role == "SUBMIT" })?.title ?? (viewModel.isEditing ? "Salvar alterações" : "Cadastrar fã")
    }

    private var errorPresented: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })
    }

    private func binding(for field: String) -> Binding<String> {
        Binding(get: { viewModel.values[field, default: ""] }, set: { viewModel.values[field] = $0 })
    }
}
