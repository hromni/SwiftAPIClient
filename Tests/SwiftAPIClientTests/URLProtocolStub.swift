//
//  URLProtocolStub.swift
//  SwiftAPIClient
//
//  Created by Panayot Panayotov on 28/01/2026.
//

import Foundation

final class URLProtocolStub: URLProtocol {
    struct Stub {
        var data: Data?
        var response: URLResponse?
        var error: Error?
    }

    static var stub: Stub?

    static func register(stub: Stub) {
        self.stub = stub
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = Self.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = Self.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = Self.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

func makeStubbedSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [URLProtocolStub.self]
    return URLSession(configuration: config)
}
