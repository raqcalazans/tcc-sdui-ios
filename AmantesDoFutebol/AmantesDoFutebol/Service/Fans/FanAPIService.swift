import Foundation

protocol FanAPIServiceProtocol {
    func fetchScreen(path: String) async throws -> ScreenDefinition
    func fetchFans() async throws -> [Fan]
    func fetchFan(id: Int) async throws -> Fan
    func fetchOptions(path: String, valueField: String, labelField: String) async throws -> [ScreenOption]
    func createFan(payload: [String: String]) async throws -> Fan
    func updateFan(id: Int, payload: [String: String]) async throws -> Fan
    func deleteFan(id: Int) async throws
}

final class FanAPIService: FanAPIServiceProtocol {
    static let shared = FanAPIService()
    private let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(baseURL: URL = URL(string: "http://localhost:8080")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchScreen(path: String) async throws -> ScreenDefinition {
        try await request(path: path, method: "GET")
    }

    func fetchFans() async throws -> [Fan] {
        try await request(path: "/api/v1/fans", method: "GET")
    }

    func fetchFan(id: Int) async throws -> Fan {
        try await request(path: "/api/v1/fans/\(id)", method: "GET")
    }

    func fetchOptions(path: String, valueField: String, labelField: String) async throws -> [ScreenOption] {
        let data = try await requestData(path: path, method: "GET")
        guard let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw URLError(.cannotParseResponse)
        }
        return rows.compactMap { row in
            guard let id = Self.stringValue(row[valueField]),
                  let label = Self.stringValue(row[labelField]) else { return nil }
            return ScreenOption(id: id, label: label)
        }
    }

    func createFan(payload: [String: String]) async throws -> Fan {
        try await request(path: "/api/v1/fans", method: "POST", payload: payload)
    }

    func updateFan(id: Int, payload: [String: String]) async throws -> Fan {
        try await request(path: "/api/v1/fans/\(id)", method: "PUT", payload: payload)
    }

    func deleteFan(id: Int) async throws {
        let url = try makeURL(path: "/api/v1/fans/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (_, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    private func request<Response: Decodable>(path: String, method: String, payload: [String: String]? = nil) async throws -> Response {
        let data = try await requestData(path: path, method: method, payload: payload)
        return try decoder.decode(Response.self, from: data)
    }

    private func requestData(path: String, method: String, payload: [String: String]? = nil) async throws -> Data {
        var request = URLRequest(url: try makeURL(path: path))
        request.httpMethod = method
        if let payload {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        }
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    private static func stringValue(_ value: Any?) -> String? {
        if let value = value as? String { return value }
        if let value = value as? NSNumber { return value.stringValue }
        return nil
    }

    private func makeURL(path: String) throws -> URL {
        guard let url = URL(string: path, relativeTo: baseURL)?.absoluteURL else { throw URLError(.badURL) }
        return url
    }
}
