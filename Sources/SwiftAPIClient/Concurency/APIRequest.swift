//  APIRequest.swift
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

/// A concurrency-safe request description.
///
/// The intent is that this type is safe to pass across tasks. Actual network execution is performed by `APIClient`.
public struct APIRequest: Sendable {
    public var baseURL: String
    public var path: String
    public var method: HTTPMethod
    public var headers: [String: String]
    public var query: [String: String?]
    public var body: RequestBody?
    public var timeoutInterval: TimeInterval
    public var cachePolicy: URLRequest.CachePolicy

    public init(
        baseURL: String,
        path: String,
        method: HTTPMethod = .get,
        headers: [String : String] = [:],
        query: [String : String?] = [:],
        body: RequestBody? = nil,
        timeoutInterval: TimeInterval = 30,
        cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.query = query
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
    }
    
    /// Builds a `URLRequest` from this request definition.
    public func buildURLRequest() throws(SwiftApiClientError) -> URLRequest {
        let components = URLComponents(string: baseURL)
        guard var urlComponents = components else {
            throw .invalidURL
        }

        let queryItems = query
            .sorted(by: { $0.key < $1.key })
            .map { URLQueryItem(name: $0.key, value: $0.value) }

        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems

        // Preserve existing base path and append provided path in a predictable way.
        let basePath = urlComponents.path
        if path.isEmpty {
            urlComponents.path = basePath
        } else if path.hasPrefix("/") {
            urlComponents.path = basePath.appending(path)
        } else {
            urlComponents.path = basePath.appending("/").appending(path)
        }

        guard let url = urlComponents.url else {
            throw .invalidURL
        }

        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue

        // Headers
        for (k, v) in headers {
            request.setValue(v, forHTTPHeaderField: k)
        }

        // Body + Content-Type
        if let body {
            request.httpBody = try body.getData()
        }

        return request
    }
}
