//
//  EndpointTests.swift
//  
//
//  Created by Panayot Panayotov on 06/03/2023.
//

import XCTest
@testable import SwiftAPIClient

final class EndpointTests: XCTestCase {

    struct TestEndpoint: Endpoint {
        let baseUrlString: String = "https://example.com/"
        let path: String = "/some-path/another-level"
        let query: [String : CustomStringConvertible?]?
    }

    func testEndpointDefaults() throws {
        let endpoint = TestEndpoint(query: nil)
        let urlRequest = try endpoint.buildURLRequest()
        XCTAssertEqual(HTTPMethod.get, endpoint.httpMethod)
        XCTAssertEqual("GET", urlRequest.httpMethod)
        XCTAssertEqual([:], endpoint.heаders)
        XCTAssertEqual([:], urlRequest.allHTTPHeaderFields)
        XCTAssertEqual("https://example.com/some-path/another-level", urlRequest.url?.absoluteString)
        XCTAssertEqual(nil, urlRequest.httpBody)
    }

    func testEndpoint_query() throws {
        let endpoint = TestEndpoint(query: ["search": "some text"])
        let urlRequest = try endpoint.buildURLRequest()
        XCTAssertEqual(HTTPMethod.get, endpoint.httpMethod)
        XCTAssertEqual("GET", urlRequest.httpMethod)
        XCTAssertEqual([:], endpoint.heаders)
        XCTAssertEqual([:], urlRequest.allHTTPHeaderFields)
        XCTAssertEqual("https://example.com/some-path/another-level?search=some%20text", urlRequest.url?.absoluteString)
        XCTAssertEqual(nil, urlRequest.httpBody)
    }
}
