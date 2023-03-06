//
//  Endpoint.swift
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
import Combine

public protocol Endpoint {
    var httpBody: RequestBody? { get }
    var httpMethod: HTTPMethod { get }
    var heаders: [String: String] { get }
    var baseUrlString: String { get }
    /// URL path. *Important* should always start with formward slash
    var path: String { get }
    var query: [String: CustomStringConvertible?]? { get }
    var responseValidation: ResponseValidator { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

extension Endpoint {
    func buildURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseUrlString) else {
            throw SwiftApiClientError.invalidURL
        }
        urlComponents.queryItems = query?.map { key, value in
            URLQueryItem(name: key, value: value?.description)
        }
        urlComponents.path = path
        guard let url = urlComponents.url else {
            throw SwiftApiClientError.invalidURL
        }
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        heаders.forEach { (header: String, value: String) in
            request.setValue(value, forHTTPHeaderField: header)
        }

        request.httpMethod = httpMethod.rawValue
        request.httpBody = try httpBody?.getData()

        return request
    }
}

public extension Endpoint {
    var httpMethod: HTTPMethod { .get }
    var httpBody: RequestBody? { nil }
    var heаders: [String: String] { [:] }
    var query: [String: CustomStringConvertible?]? { nil }
    var timeoutInterval: TimeInterval { 30 }
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalAndRemoteCacheData }
    var responseValidation: ResponseValidator { BasicResponseValidator() }

    func send<T: Response>() -> AnyPublisher<T, SwiftApiClientError> {
        do {
            let request = try buildURLRequest()
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMapResponse(T.self, responseValidator: responseValidation)
                .mapErrorsToApiClientError()
                .eraseToAnyPublisher()
        } catch let error as SwiftApiClientError {
            return Fail<T, SwiftApiClientError>(error: error).eraseToAnyPublisher()
        } catch {
            return Fail<T, SwiftApiClientError>(error: SwiftApiClientError.unexpectedError(error)).eraseToAnyPublisher()
        }
    }

    func send() -> AnyPublisher<Void, SwiftApiClientError> {
        do {
            let request = try buildURLRequest()
            return URLSession.shared.dataTaskPublisher(for: request)
                .validateResponse(responseValidation)
                .mapErrorsToApiClientError()
                .eraseToAnyPublisher()
        } catch let error as SwiftApiClientError {
            return Fail<Void, SwiftApiClientError>(error: error).eraseToAnyPublisher()
        } catch {
            return Fail<Void, SwiftApiClientError>(error: SwiftApiClientError.unexpectedError(error)).eraseToAnyPublisher()
        }
    }
}

@available(macOS 12, *)
public extension Endpoint {
    func send<T: Response>() async throws -> T {
        let request = try buildURLRequest()
        let serverResponse = try await URLSession.shared.data(for: request)
        try responseValidation.validate(serverResponse)
        return try T.parse(data: serverResponse.0)
    }
}

private extension URLSession.DataTaskPublisher {
    func tryMapResponse<T: Response>(_ decodable: T.Type, responseValidator: ResponseValidator) -> Publishers.TryMap<Self, T> {
        self.tryMap {
            try responseValidator.validate($0)
            return try T.parse(data: $0.data)
        }
    }

    func validateResponse(_ responseValidator: ResponseValidator) -> Publishers.TryMap<Self, Void> {
        self.tryMap {
            try responseValidator.validate($0)
            return ()
        }
    }
}

private extension Publishers.TryMap where Self.Failure: Error {
    func mapErrorsToApiClientError() -> Publishers.MapError<Self, SwiftApiClientError> {
        self.mapError { error in
            if let apiError = error as? SwiftApiClientError {
                return apiError
            }
            return SwiftApiClientError.unexpectedError(error)
        }
    }
}
