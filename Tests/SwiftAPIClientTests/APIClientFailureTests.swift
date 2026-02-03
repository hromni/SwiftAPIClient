//
//  APIClientFailureTests.swift
//  SwiftAPIClient
//
//  Created by Panayot Panayotov on 28/01/2026.
//

import XCTest
@testable import SwiftAPIClient

final class APIClientFailureTests: XCTestCase {

    struct Empty: JsonResponse, Sendable {
        typealias Body = [String: String]
    }

    func testSendThrowsOnNon2xx() async {
        let session = makeStubbedSession()
        let client = APIClient(session: session)

        let url = URL(string: "https://example.com/fail")!
        let http = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!

        URLProtocolStub.register(stub: .init(data: Data(), response: http, error: nil))

        let request = APIRequest<Empty>(
            baseURL: url.deletingLastPathComponent(),
            path: "/fail",
            method: .get
        )

        do {
            _ = try await client.send(request)
            XCTFail("Expected error")
        } catch {
            // If your client throws SwiftApiClientError, check it here.
            // Example:
            // XCTAssertEqual(error as? SwiftApiClientError, .serverError(statusCode: 500))
            XCTAssertTrue(true)
        }
    }
}
