import Foundation

/// Serves deterministic SDUI JSON over the real URLSession/FanAPIService stack in UI tests.
final class UITestURLProtocol: URLProtocol {
    private static let lock = NSLock()
    private static var fans: [[String: Any]] = []
    private static var nextFanID = 2

    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        fans = [jsonObject(FanScreenJSONFixtures.sampleFan)]
        nextFanID = 2
    }

    override class func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "localhost" && request.url?.path.hasPrefix("/api/") == true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        do {
            let (status, data) = try Self.response(for: request)
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: status,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ) else {
                throw URLError(.badServerResponse)
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if !data.isEmpty { client?.urlProtocol(self, didLoad: data) }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }

    private static func response(for request: URLRequest) throws -> (Int, Data) {
        let method = request.httpMethod ?? "GET"
        let path = request.url?.path ?? ""

        if method == "GET", path == "/api/v1/ui/fans/list-screen" { return (200, Data(FanScreenJSONFixtures.list.utf8)) }
        if method == "GET", path == "/api/v1/ui/fans/registration-screen" { return (200, Data(FanScreenJSONFixtures.registration.utf8)) }
        if method == "GET", path.hasSuffix("/edit-screen") { return (200, Data(FanScreenJSONFixtures.edit.utf8)) }
        if method == "GET", path.hasSuffix("/detail-screen") { return (200, Data(FanScreenJSONFixtures.detail.utf8)) }
        if method == "GET", path == "/api/v1/teams" { return (200, Data(FanScreenJSONFixtures.teams.utf8)) }

        if method == "GET", path == "/api/v1/fans" {
            lock.lock()
            defer { lock.unlock() }
            return (200, try data(fans))
        }

        let pathParts = path.split(separator: "/")
        if pathParts.count == 4, pathParts[0...2].joined(separator: "/") == "api/v1/fans",
           let fanID = Int(pathParts[3]) {
            return try fanResponse(method: method, fanID: fanID, request: request)
        }

        if method == "POST", path == "/api/v1/fans" {
            lock.lock()
            defer { lock.unlock() }
            let payload = try requestPayload(request)
            let fan = fanRecord(id: nextFanID, payload: payload)
            nextFanID += 1
            fans.append(fan)
            return (201, try data(fan))
        }

        return (404, try data(["error": "UI test fixture route not found"]))
    }

    private static func fanResponse(method: String, fanID: Int, request: URLRequest) throws -> (Int, Data) {
        lock.lock()
        defer { lock.unlock() }
        guard let index = fans.firstIndex(where: { ($0["id"] as? Int) == fanID }) else {
            return (404, try data(["error": "Fan not found"]))
        }

        switch method {
        case "GET": return (200, try data(fans[index]))
        case "PUT":
            fans[index] = fanRecord(id: fanID, payload: try requestPayload(request))
            return (200, try data(fans[index]))
        case "DELETE":
            fans.remove(at: index)
            return (204, Data())
        default: return (405, try data(["error": "Method not allowed"]))
        }
    }

    private static func requestPayload(_ request: URLRequest) throws -> [String: String] {
        guard let body = request.httpBody ?? readBodyStream(request.httpBodyStream),
              let payload = try JSONSerialization.jsonObject(with: body) as? [String: String] else {
            throw URLError(.cannotParseResponse)
        }
        return payload
    }

    private static func readBodyStream(_ stream: InputStream?) -> Data? {
        guard let stream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count <= 0 { break }
            data.append(buffer, count: count)
        }
        return data.isEmpty ? nil : data
    }

    private static func fanRecord(id: Int, payload: [String: String]) -> [String: Any] {
        [
            "id": id,
            "name": payload["name", default: ""],
            "email": payload["email", default: ""],
            "birthDate": payload["birthDate", default: "2000-01-01"],
            "gender": payload["gender", default: "Feminino"],
            "favoriteTeamId": payload["favoriteTeamId", default: "FLA"],
            "city": payload["city", default: ""],
            "state": payload["state", default: ""],
            "country": payload["country", default: "Brasil"],
            "stadiumFrequency": payload["stadiumFrequency", default: "NUNCA"]
        ]
    }

    private static func data(_ value: Any) throws -> Data {
        try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed, .sortedKeys])
    }

    private static func jsonObject(_ json: String) -> [String: Any] {
        (try? JSONSerialization.jsonObject(with: Data(json.utf8))) as? [String: Any] ?? [:]
    }
}
