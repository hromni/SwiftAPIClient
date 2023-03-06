# SwiftAPIClient
This is a light weight API Client written in Swift. It works with both `async await` and `Combine` publishers depending on your needs

## Endpoint example using enum

```swift
import Foundation
import SwiftAPIClient

enum Endpoints: Endpoint {

    case getData, addData(_ name: String)

    var baseUrlString: String {  "https://example.com/" }

    var httpBody: RequestBody? {
        switch self {
        case .addData(let name):
            return .jsonDictionary(["name" : name])
        default: return nil
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getData: return .get
        case .addData: return .post
        }
    }

    var path: String {
    // URL path should always start with forward slash
        switch self {
        case .getData:
            return "/getData"
        case .addData(let data):
            return "/addData"
        }
    }
    
}
```

## Endpoint example using `struct`

```swift
struct GetDataEndpoint: Endpoint {
    var baseUrlString: String {  "https://example.com/" }
    // URL path should always start with forward slash
    var path: String { "/getData" }
}
```


## Define JSON responses

If you're expecting a JSON response you can use `JsonResponse` protocol which is a wrapper of `Decodable` with some extra build-in functionality. You can also create your own response type by conforming to `Response` protocol.

 ```swift
import Foundation
import SwiftAPIClient

struct ExampleDataResponse: JsonResponse {
    let name: String
}
 ```

## Send request using Combine

Create client wrapper with `Combine` using the endpoints

```swift

struct ApiClient {
    static func getData() -> AnyPublisher<ExampleDataResponse, SwiftApiClientError> {
        Endpoints.getData.send() 
        // GetDataEndpoint().send()
    }
}

```

## Send request using async

As mentioned the endpoint automatically handles both `Combine` and `async`, so you can use either approach.
For example if you want to use `async` you can do so with the example below using the same `Endponts` definition above

```swift

struct ApiClient {
    static func getData() async throws -> ExampleDataResponse {
        try await Endpoints.getData.send() 
        // try await GetDataEndpoint().send()
    }
}

```

## Validating responses

The default validator code is below.

```swift
struct BasicResponseValidator: ResponseValidator {
    public func validate(_ response: (data: Data, response: URLResponse)) throws {
        if let statusCode = (response.response as? HTTPURLResponse)?.statusCode,
           statusCode >= 300 {
            throw SwiftApiClientError.serverError(statusCode: statusCode, payload: response.data)
        }
    }
}
```

You can also create your own validator by conforming to 
```
public protocol ResponseValidator {
    func validate(_ response: (data: Data, response: URLResponse)) throws
}
```
and then pass it as a validator to your endpoints to replace the default response validation
