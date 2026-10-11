import Combine
import Foundation

@MainActor
final class FanListViewModel: ObservableObject {
    @Published private(set) var screen: ScreenDefinition?
    @Published private(set) var fans: [Fan] = []
    @Published private(set) var teamNames: [String: String] = [:]
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let service: FanAPIServiceProtocol

    init(service: FanAPIServiceProtocol = FanAPIService.shared) { self.service = service }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let fansRequest = service.fetchFans()
            let loadedScreen = try await service.fetchScreen(path: "/api/v1/ui/fans/list-screen")
            screen = loadedScreen
            let fetchedFans = try await fansRequest
            fans = fetchedFans.sorted { $0.id < $1.id }
            for component in loadedScreen.sections.flatMap(\.components) {
                guard let source = component.subtitleOptionsSource,
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
            errorMessage = "Não foi possível carregar os fãs. Verifique sua conexão e tente novamente."
        }
    }
}
