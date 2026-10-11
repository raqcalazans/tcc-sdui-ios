import SwiftUI

@main
struct AmantesDoFutebolApp: App {
    private static let service: FanAPIServiceProtocol = {
        guard ProcessInfo.processInfo.arguments.contains("--ui-testing") else {
            return FanAPIService.shared
        }

        UITestURLProtocol.reset()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [UITestURLProtocol.self]
        return FanAPIService(session: URLSession(configuration: configuration))
    }()

    var body: some Scene {
        WindowGroup {
            FanListView(service: Self.service)
        }
    }
}
