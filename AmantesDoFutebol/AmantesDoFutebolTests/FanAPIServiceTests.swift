import XCTest
@testable import AmantesDoFutebol

final class FanAPIServiceTests: XCTestCase {
    func testFetchFansUsesVersionedEndpointAndDecodesResponse() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.setHandler { request in
            capturedRequest = request
            return (self.response(status: 200), Data("[\(self.fanJSON)]".utf8))
        }

        let fans = try await makeService().fetchFans()

        XCTAssertEqual(capturedRequest?.httpMethod, "GET")
        XCTAssertEqual(capturedRequest?.url?.path, "/api/v1/fans")
        XCTAssertEqual(fans.first?.id, 1)
        XCTAssertEqual(fans.first?.favoriteTeamId, "FLA")
    }

    func testFetchScreenAndOptionsUseServerPaths() async throws {
        var capturedPaths: [String] = []
        MockURLProtocol.setHandler { request in
            capturedPaths.append(request.url!.path)
            if request.url?.path == "/api/v1/teams" {
                return (self.response(status: 200), Data("[{\"id\":123,\"name\":\"Time\"}]".utf8))
            }
            return (self.response(status: 200), Data("\(self.screenJSON)".utf8))
        }
        let service = makeService()

        let screen = try await service.fetchScreen(path: "/api/v1/ui/fans/list-screen")
        let options = try await service.fetchOptions(path: "/api/v1/teams", valueField: "id", labelField: "name")

        XCTAssertEqual(screen.screenType, "LIST")
        XCTAssertEqual(options, [ScreenOption(id: "123", label: "Time")])
        XCTAssertEqual(capturedPaths, ["/api/v1/ui/fans/list-screen", "/api/v1/teams"])
    }

    func testCreateAndUpdateEncodePayloadAndDecodeResponse() async throws {
        var requests: [URLRequest] = []
        var requestBodies: [Data?] = []
        MockURLProtocol.setHandler { request in
            requests.append(request)
            requestBodies.append(self.bodyData(from: request))
            return (self.response(status: 200), Data(self.fanJSON.utf8))
        }
        let service = makeService()
        let payload = ["name": "Ana", "birthDate": "1995-08-14"]

        _ = try await service.createFan(payload: payload)
        _ = try await service.updateFan(id: 8, payload: payload)

        XCTAssertEqual(requests.map(\.httpMethod), ["POST", "PUT"])
        XCTAssertEqual(requests.map { $0.url?.path }, ["/api/v1/fans", "/api/v1/fans/8"])
        XCTAssertEqual(requests[0].value(forHTTPHeaderField: "Content-Type"), "application/json")
        let body = try XCTUnwrap(requestBodies[0])
        let bodyObject = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])
        XCTAssertEqual(bodyObject, payload)
    }

    func testDeleteAcceptsNoContentResponse() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.setHandler { request in
            capturedRequest = request
            return (self.response(status: 204), Data())
        }

        try await makeService().deleteFan(id: 6)

        XCTAssertEqual(capturedRequest?.httpMethod, "DELETE")
        XCTAssertEqual(capturedRequest?.url?.path, "/api/v1/fans/6")
    }

    func testNonSuccessfulHTTPStatusIsRejected() async {
        MockURLProtocol.setHandler { _ in (self.response(status: 500), Data()) }

        do {
            _ = try await makeService().fetchFans()
            XCTFail("Expected an HTTP error")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
        }
    }

    private var fanJSON: String {
        #"{"id":1,"name":"Ana","email":"ana@example.com","birthDate":"1995-08-14","gender":"Feminino","favoriteTeamId":"FLA","city":"Rio","state":"RJ","country":"Brasil","stadiumFrequency":"SEMPRE"}"#
    }

    private var screenJSON: String {
        #"{"screenId":"list","screenTitle":"Fãs","screenType":"LIST","sections":[],"actions":[]}"#
    }

    private func makeService() -> FanAPIService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return FanAPIService(baseURL: URL(string: "http://unit.test")!, session: URLSession(configuration: configuration))
    }

    private func response(status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "http://unit.test")!, statusCode: status, httpVersion: nil, headerFields: nil)!
    }

    private func bodyData(from request: URLRequest) -> Data? {
        if let body = request.httpBody { return body }
        guard let stream = request.httpBodyStream else { return nil }
        stream.open()
        defer { stream.close() }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        defer { buffer.deallocate() }
        var data = Data()
        while stream.hasBytesAvailable {
            let count = stream.read(buffer, maxLength: 1024)
            if count < 0 { return nil }
            if count == 0 { break }
            data.append(buffer, count: count)
        }
        return data
    }
}
