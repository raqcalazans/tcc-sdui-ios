import Combine
import Foundation

@MainActor
final class FanRegistrationViewModel: ObservableObject {
    @Published private(set) var screen: ScreenDefinition?
    @Published private(set) var optionsByComponent: [String: [ScreenOption]] = [:]
    @Published var values: [String: String] = [:]
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    let fanId: Int?
    private let service: FanAPIServiceProtocol

    var isEditing: Bool { fanId != nil }

    init(fanId: Int? = nil, service: FanAPIServiceProtocol = FanAPIService.shared) {
        self.fanId = fanId
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let path = fanId.map { "/api/v1/ui/fans/\($0)/edit-screen" } ?? "/api/v1/ui/fans/registration-screen"
            screen = try await service.fetchScreen(path: path)
            if let fanId {
                let fan = try await service.fetchFan(id: fanId)
                values = [
                    "name": fan.name,
                    "email": fan.email,
                    "birthDate": FanDateFormatter.display(fan.birthDate),
                    "gender": fan.gender,
                    "favoriteTeamId": fan.favoriteTeamId,
                    "city": fan.city,
                    "state": fan.state,
                    "country": fan.country,
                    "stadiumFrequency": fan.stadiumFrequency
                ]
            }
            await loadOptions(for: screen)
        } catch {
            errorMessage = "Não foi possível carregar a tela. Verifique sua conexão e tente novamente."
        }
    }

    func options(for component: ScreenComponent) -> [ScreenOption] {
        optionsByComponent[component.id] ?? component.options ?? []
    }

    var requiredOptionsAvailable: Bool {
        guard let screen else { return false }
        return screen.sections.flatMap(\.components)
            .filter { $0.type == "SELECT" && $0.required == true }
            .allSatisfy { !options(for: $0).isEmpty }
    }

    func save() async throws {
        guard let screen else { throw URLError(.badServerResponse) }
        isLoading = true
        defer { isLoading = false }
        let components = screen.sections.flatMap(\.components)
        let requiredFields = components.filter { $0.required == true }.map { $0.field ?? $0.id }
        guard requiredFields.allSatisfy({ !(values[$0] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw FanFormError.missingRequiredField
        }
        for component in components where component.type == "SELECT" && component.required == true {
            let field = component.field ?? component.id
            guard options(for: component).contains(where: { $0.id == values[field] }) else {
                throw FanFormError.invalidSelection(component.label ?? field)
            }
        }
        let displayedBirthDate = values["birthDate", default: ""]
        let date = FanDateFormatter.storage(displayedBirthDate)
        guard displayedBirthDate.count == 10, date != displayedBirthDate else {
            throw FanFormError.invalidBirthDate
        }

        var payload = values
        payload["birthDate"] = date
        if isEditing, let fanId {
            _ = try await service.updateFan(id: fanId, payload: payload)
        } else {
            _ = try await service.createFan(payload: payload)
        }
    }

    private func loadOptions(for screen: ScreenDefinition?) async {
        guard let screen else { return }
        let components = screen.sections.flatMap(\.components)
        for component in components {
            guard let source = component.optionsSource, source.method == nil || source.method == "GET" else { continue }
            let field = component.field ?? component.id
            do {
                let options = try await service.fetchOptions(
                    path: source.path,
                    valueField: source.valueField,
                    labelField: source.labelField
                )
                optionsByComponent[component.id] = options
                if field == "favoriteTeamId", (values[field] ?? "").isEmpty, let first = options.first {
                    values[field] = first.id
                }
                if options.isEmpty && component.required == true {
                    errorMessage = "Não há opções disponíveis para \(component.label ?? field)."
                }
            } catch {
                optionsByComponent[component.id] = []
                errorMessage = "Não foi possível carregar as opções de \(component.label ?? field)."
            }
        }
        if (values["stadiumFrequency"] ?? "").isEmpty,
           let frequency = components.first(where: { ($0.field ?? $0.id) == "stadiumFrequency" }),
           options(for: frequency).contains(where: { $0.id == "NUNCA" }) {
            values["stadiumFrequency"] = "NUNCA"
        }
    }
}

enum FanFormError: LocalizedError {
    case missingRequiredField
    case invalidBirthDate
    case invalidSelection(String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredField: "Preencha todos os campos obrigatórios."
        case .invalidBirthDate: "Informe uma data válida no formato DD/MM/AAAA."
        case .invalidSelection(let field): "Selecione uma opção válida para \(field)."
        }
    }
}
