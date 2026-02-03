//
//  EndpointBridgeTests.swift
//  SwiftAPIClient
//
//  Created by Panayot Panayotov on 28/01/2026.
//

import XCTest
@testable import SwiftAPIClient

final class EndpointBridgeTests: XCTestCase {

    struct MyEndpoint: Endpoint {
        let baseUrlString: String = "https://example.com"
        let path = "/ping"
        let method: HTTPMethod = .get
        let timeoutInterval: TimeInterval = 5
        let cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
        let query: [String : CustomStringConvertible?]? = ["a": "1"]
        let body: RequestBody? = nil
        var heаders: [String: String] { ["X-Ping": "1"] }

        // If your protocol requires heаders, your shim should bridge it.
    }

    struct PingResponse: JsonResponse, Sendable {
        typealias Body = [String: Bool]
    }

    func test_EndpointAsRequestCopiesBasics() throws {
        let endpoint = MyEndpoint()
        let request: APIRequest<PingResponse> = try endpoint.asRequest(PingResponse.self)

        XCTAssertEqual(request.path, "/ping")
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.headers["X-Ping"], "1")
    }
}
