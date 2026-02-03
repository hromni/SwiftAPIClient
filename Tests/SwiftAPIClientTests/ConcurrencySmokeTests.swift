//
//  ConcurrencySmokeTests.swift
//  SwiftAPIClient
//
//  Created by Panayot Panayotov on 28/01/2026.
//

import XCTest
@testable import SwiftAPIClient

final class ConcurrencySmokeTests: XCTestCase {

    struct Ok: JsonResponse, Sendable {
        let value: Int
    }

    func testClientCanSendConcurrently() async throws {
        let session = makeStubbedSession()
        let client = APIClient(session: session)

        let url = URL(string: "https://example.com/ok")!
        let http = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

        // This stub returns the same response for all requests.
        URLProtocolStub.register(stub: .init(data: Data(#"{"value":1}"#.utf8), response: http, error: nil))

        let request = APIRequest<Ok>(
            baseURL: url.deletingLastPathComponent(),
            path: "/ok",
            method: .get
        )

        let results = try await withThrowingTaskGroup(of: Ok.self) { group in
            for _ in 0..<50 {
                group.addTask { try await client.send(request) }
            }
            var out: [Ok] = []
            for try await r in group { out.append(r) }
            return out
        }

        XCTAssertEqual(results.count, 50)
        XCTAssertTrue(results.allSatisfy { $0.value == 1 })
    }
}
