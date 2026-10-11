import Combine
import Foundation

@MainActor
final class FanDetailViewModel: ObservableObject {
    @Published private(set) var screen: ScreenDefinition?
    @Published private(set) var fan: Fan?
    @Published private(set) var teamNames: [String: String] = [:]
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    let fanId: Int
    private let service: FanAPIServiceProtocol

    init(fanId: Int, service: FanAPIServiceProtocol) {
        self.fanId = fanId
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let fanRequest = service.fetchFan(id: fanId)
            let loadedScreen = try await service.fetchScreen(path: "/api/v1/ui/fans/\(fanId)/detail-screen")
            screen = loadedScreen
            fan = try await fanRequest
            for component in loadedScreen.sections.flatMap(\.components) {
                guard let source = component.optionsSource,
                      source.method == nil || source.method == "GET" else { continue }
                if let options = try? await service.fetchOptions(
                    path: source.path,
                    valueField: source.valueField,
                    labelField: source.labelField
                ) {
                    teamNames = Dictionary(uniqueKeysWithValues: options.map { ($0.id, $0.label) })
                }
            }
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar os dados deste fã."
        }
    }

    func value(for component: ScreenComponent) -> String {
        guard let fan else { return "" }
        if let fields = component.fields, component.format == "LOCATION" {
            return fields.compactMap { fieldValue($0, fan: fan) }.joined(separator: ", ")
        }
        guard let field = component.field else { return "" }
        switch component.format {
        case "dd/MM/yyyy": return FanDateFormatter.display(fan.birthDate)
        case "AGE":
            guard let age = FanDateFormatter.age(from: fan.birthDate) else { return "—" }
            return age == 1 ? "1 ano" : "\(age) anos"
        default: break
        }
        if field == "favoriteTeamId" { return teamNames[fan.favoriteTeamId] ?? fan.favoriteTeamId }
        if field == "stadiumFrequency" { return frequencyLabel(fan.stadiumFrequency) }
        return fieldValue(field, fan: fan) ?? ""
    }

    func delete() async throws {
        try await service.deleteFan(id: fanId)
    }

    private func fieldValue(_ field: String, fan: Fan) -> String? {
        switch field {
        case "name": fan.name
        case "email": fan.email
        case "birthDate": fan.birthDate
        case "gender": fan.gender
        case "favoriteTeamId": fan.favoriteTeamId
        case "city": fan.city
        case "state": fan.state
        case "country": fan.country
        case "stadiumFrequency": fan.stadiumFrequency
        default: nil
        }
    }

    private func frequencyLabel(_ value: String) -> String {
        switch value {
        case "SEMPRE": "Sempre"
        case "AS_VEZES": "Às vezes"
        case "RARAMENTE": "Raramente"
        case "NUNCA": "Nunca"
        default: value
        }
    }
}
