//
//  APIClientSuccessTests.swift
//  SwiftAPIClient
//
//  Created by Panayot Panayotov on 28/01/2026.
//

import XCTest
@testable import SwiftAPIClient

final class APIClientSuccessTests: XCTestCase {

    struct UserResponse: JsonResponse, Equatable {
        let id: Int
        let name: String
    }

    func testSendDecodesJsonResponse() async throws {
        let session = makeStubbedSession()
        let client = APIClient(session: session)

        let json = #"{"id": 7, "name": "Ana"}"#
        let data = Data(json.utf8)
        let url = URL(string: "https://example.com/users/7")!

        let http = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!

        URLProtocolStub.register(stub: .init(data: data, response: http, error: nil))

        let request = APIRequest<UserResponse>(
            baseURL: url.deletingLastPathComponent(),
            path: "/users/7",
            method: .get
        )

        let result = try await client.send(request)
        XCTAssertEqual(result, UserResponse(id: 7, name: "Ana"))
    }
}
