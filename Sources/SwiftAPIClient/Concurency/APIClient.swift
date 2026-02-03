//
//  APIClient.swift
//
//
//  Created by Panayot Panayotov on 28/01/2026.
//

/**
 MIT License

 Copyright (c) 2026 HR Omni Solutions

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

public protocol URLRequestInterceptor: Sendable {
    func preflight(_ request: inout URLRequest) async throws
    func postflight(_ response: URLResponse, data: Data) async
}

/// Actor-isolated HTTP client.
public actor APIClient {
    private let session: URLSession
    private let interceptor: URLRequestInterceptor?
    
    public init(session: URLSession = .shared, interceptor: URLRequestInterceptor? = nil) {
        self.session = session
        self.interceptor = interceptor
    }

    /// Sends a request and parses its response.
    public final func send<T: Response, V: ResponseValidator>(
        _ request: APIRequest,
        responseValidation: V = BasicResponseValidator()
    ) async throws(SwiftApiClientError) -> T {
        var urlRequest = try request.buildURLRequest()
        do {
            try await interceptor?.preflight(&urlRequest)
            let (data, response) = try await session.data(for: urlRequest)
            try await interceptor?.postflight(response, data: data)
            try responseValidation.validate((data: data, response: response))
            return try T.parse(data: data)
        } catch let error as SwiftApiClientError {
            throw error
        } catch {
            throw .unexpectedError(error)
        }
    }

    /// Sends a request where you don't need a parsed model (e.g. endpoints returning empty bodies).
    public final func sendVoid<V: ResponseValidator>(
        _ request: APIRequest,
        responseValidation: V = BasicResponseValidator()
    ) async throws(SwiftApiClientError) {
        var urlRequest = try request.buildURLRequest()
        do {
            try await interceptor?.preflight(&urlRequest)
            let (data, response) = try await session.data(for: urlRequest)
            try await interceptor?.postflight(response, data: data)
            try responseValidation.validate((data: data, response: response))
        } catch let error as SwiftApiClientError {
            throw error
        } catch {
            throw .unexpectedError(error)
        }
    }
}
