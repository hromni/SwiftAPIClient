//
//  RequestBody.swift
//  
//
//  Created by Panayot Panayotov on 06/03/2023.
//

/**
 MIT License

 Copyright (c) 2023 HR Omni Solutions

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

public enum RequestBody {
    case jsonEncodable(Encodable)
    case jsonDictionary(Any)
    case formData([String: CustomStringConvertible?])

    func getData() throws -> Data? {
        switch self {
        case .jsonEncodable(let obj):
            return try makeJson(obj)
        case .formData(let formData):
            return makeFormData(formData)
        case .jsonDictionary(let dictionary):
            return try makeJson(dictionary)
        }
    }

    private func makeJson(_ encodable: Encodable) throws -> Data? {
        do {
            return try JSONEncoder().encode(encodable)
        }catch let encodingError as EncodingError {
            throw SwiftApiClientError.encodingError(encodingError)
        } catch {
            // this should never be called but is here as fallback
            throw SwiftApiClientError.unexpectedError(error)
        }
    }

    private func makeJson(_ json: Any) throws -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json)
        }catch let encodingError as EncodingError {
            throw SwiftApiClientError.encodingError(encodingError)
        } catch {
            // this should never be called but is here as fallback
            throw SwiftApiClientError.unexpectedError(error)
        }
    }

    private func makeFormData(_ formData: [String: CustomStringConvertible?]) -> Data? {
        var components = URLComponents()
        components.queryItems = formData.map{ .init(name: $0.key, value: $0.value?.description) }
        return components.query?.data(using: .utf8)
    }
}
