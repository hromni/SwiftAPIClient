//
//  JsonResponseTests.swift
//  
//
//  Created by Panayot Panayotov on 06/03/2023.
//

import XCTest
@testable import SwiftAPIClient

struct TestJsonResponse: JsonResponse {
    let name: String
    let age: Int

    static let testResponseData = """
{
 "name": "John Doe",
 "age": 2
}
""".data(using: .utf8)
}

final class JsonResponseTests: XCTestCase {

    func testParse_success() throws {
        let responseObject = try TestJsonResponse.parse(data: TestJsonResponse.testResponseData)
        XCTAssertEqual("John Doe", responseObject.name)
        XCTAssertEqual(2, responseObject.age)
    }

    func testParse_nilData() {
        do {
            _ = try TestJsonResponse.parse(data: nil)
            XCTFail("TestJsonResponse.parse(data: nil) should throw error")
        } catch SwiftApiClientError.nilResponseData {
            // do nothing for expected error
        } catch {
            XCTFail("TestJsonResponse.parse(data: nil) should throw SwiftApiClientError.nilResponseData found: \(error)")
        }
    }

    func testParse_decodingError() {
        do {
            _ = try TestJsonResponse.parse(data: "".data(using: .utf8)!)
            XCTFail("TestJsonResponse.parse(data: '') should throw decoding error")
        } catch SwiftApiClientError.decodingError(_) {
            // do nothing for expected error
        } catch {
            XCTFail("TestJsonResponse.parse(data: nil) should throw SwiftApiClientError.decodingError found: \(error)")
        }
    }
}
