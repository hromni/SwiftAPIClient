//
//  APIRequestBuildTests.swift
//  SwiftAPIClient
//
//  Created by Panayot Panayotov on 28/01/2026.
//

import XCTest
@testable import SwiftAPIClient

final class APIRequestBuildTests: XCTestCase {

    func testBuildURLRequestIncludesHeadersQueryAndBody() throws {
        let base = URL(string: "https://example.com")!
        let req = APIRequest<VoidResponse>(
            baseURL: base,
            path: "/search",
            method: .post,
            headers: ["X-Test": "1"],
            query: ["q": "swift", "page": "2"],
            body: .json(.object(["hello": .string("world")])),
            timeoutInterval: 10
        )

        let urlRequest = try req.buildURLRequest()

        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-Test"), "1")
        XCTAssertEqual(urlRequest.timeoutInterval, 10)
        XCTAssertTrue(urlRequest.url?.absoluteString.contains("q=swift") == true)

        let bodyData = try XCTUnwrap(urlRequest.httpBody)
        XCTAssertFalse(bodyData.isEmpty)
    }
}
