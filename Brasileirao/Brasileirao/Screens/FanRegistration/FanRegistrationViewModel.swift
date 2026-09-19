import Foundation
import Combine

@MainActor
class FanRegistrationViewModel: ObservableObject {
    @Published var screen: FormScreen?
    @Published var formData: [String: String] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSubmitted = false

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchScreenData() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                self.screen = try await networkService.fetchSduiScreen(endpoint: "/fans/registration-screen")
            } catch {
                self.errorMessage = "Erro ao carregar o ecrã: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    func submitForm() {
        guard let screen = screen else { return }
        
        Task {
            isLoading = true
            errorMessage = nil
            do {
                try await networkService.submitFanRegistration(endpoint: screen.submitButton.url, data: formData)
                // Ativa o gatilho de sucesso
                self.isSubmitted = true
            } catch {
                self.errorMessage = "Erro ao submeter: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}
