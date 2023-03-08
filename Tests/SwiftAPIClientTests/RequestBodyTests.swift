//
//  RequestBodyTests.swift
//  
//
//  Created by Panayot Panayotov on 08/03/2023.
//

import XCTest
@testable import SwiftAPIClient

final class RequestBodyTests: XCTestCase {

    func testFormData() throws {
        let body = RequestBody.formData([
            "int": 1,
            "string": "stringValue",
            "double": 1.2
        ])
        let data = try body.getData()
        XCTAssertNotNil(data)
        XCTAssertEqual(35, String(data: data!, encoding: .utf8)?.count)
    }

    func testJsonEncodable() throws {
        struct TestObject: Encodable {
            let name: String = "John Doe"
            let age: Int = 21
            let nullable: String? = nil
        }

        let body = RequestBody.jsonEncodable(TestObject())
        let data = try body.getData()
        XCTAssertNotNil(data)
        XCTAssertEqual("""
{"name":"John Doe","age":21}
""", String(data: data!, encoding: .utf8))
    }

    func testJsonDictionary_dictionary() throws {
        let body = RequestBody.jsonDictionary(["user": ["name": "John Doe", "age": 21]])
        let data = try body.getData()
        XCTAssertNotNil(data)
        let jsonString = String(data: data!, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("user"))
        XCTAssertTrue(jsonString!.contains("age"))
        XCTAssertTrue(jsonString!.contains("21"))
        XCTAssertTrue(jsonString!.contains("name"))
        XCTAssertTrue(jsonString!.contains("John Doe"))
    }
}
