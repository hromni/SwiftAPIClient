## SwiftAPIClient

![Group 3032 (3)](https://user-images.githubusercontent.com/11628358/223416855-71d0c02f-ee39-48f5-a5d4-4442e2a5089e.png)

Light weight and simplistic API Client written in Swift using protocol oriented programming. You can send requests using `async await` or `Combine` publishers without having to change anything.  **SwiftAPIClient** can help you implement your server API calls with just a couple lines of code.

| Table of contents |
| --- |
| [Install with SPM](#spm) |
| [Define your endpoints using enum](#enum-endpoints) |
| [Define endpoint using struct](#struct-endpoint) |
| [Decode JSON responses](#decode-json) |
| [Send request using Combine](#send-combine) |
| [Send request using async](#send-async) |
| [Response validation](#response-validation) |
| [Contribution](#contribution) |

<a name="spm"/>

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding SwiftAPIClient as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(url: "https://github.com/hromni/SwiftAPIClient.git", .upToNextMajor(from: "0.1"))
]
```

<a name="enum-endpoints"/>

### Define your endpoints using enum

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

<a name="struct-endpoint"/>

### Endpoint example using `struct`

```swift
struct GetDataEndpoint: Endpoint {
    var baseUrlString: String {  "https://example.com/" }
    // URL path should always start with forward slash
    var path: String { "/getData" }
}
```

<a name="decode-json"/>

### Decode JSON responses

If you're expecting a JSON response you can use `JsonResponse` protocol which is a wrapper of `Decodable` with some extra build-in functionality. You can also create your own response type by conforming to `Response` protocol.

 ```swift
import Foundation
import SwiftAPIClient

struct ExampleDataResponse: JsonResponse {
    let name: String
}
 ```

<a name="send-combine"/>

### Send request using Combine

Create client wrapper with `Combine` using the endpoints

```swift

struct ApiClient {
    static func getData() -> AnyPublisher<ExampleDataResponse, SwiftApiClientError> {
        Endpoints.getData.send() 
        // GetDataEndpoint().send()
    }
}

```

<a name="send-async"/>

### Send request using async

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

<a name="response-validation"/>

### Validating responses

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

<a name="contribution"/>

### Contribution

Contributors are welcome.
Simply open an issue or a pull request if there is any issues or suggestions.
