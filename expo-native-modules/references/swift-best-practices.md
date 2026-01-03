# Swift Best Practices for Expo Modules

## Swift Coding Style for Expo Modules

### Module Definition

```swift
import ExpoModulesCore

public class MyModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MyModule")

    // Module configuration goes here
  }
}
```

### Naming Conventions

- **Classes**: Use PascalCase for module classes
- **Functions**: Use camelCase for function names
- **Constants**: Use camelCase for constants, UPPER_SNAKE_CASE for static constants
- **Properties**: Use camelCase for properties

```swift
// Good
public class VideoPlayerModule: Module {
  private let maxRetryCount = 3
  private static let DEFAULT_TIMEOUT = 30.0

  public func definition() -> ModuleDefinition {
    Name("VideoPlayer")

    Function("playVideo") { (url: String) in
      // Implementation
    }
  }
}
```

### Type Safety

Always use explicit types when exposing APIs to JavaScript:

```swift
// Good - Explicit types
Function("calculateDistance") { (x: Double, y: Double) -> Double in
  return sqrt(x * x + y * y)
}

// Avoid - Implicit types can cause issues
Function("calculateDistance") { x, y in
  return sqrt(x * x + y * y)
}
```

## Memory Management

### Weak Self Pattern

Always use `[weak self]` in closures to avoid retain cycles:

```swift
public class CameraModule: Module {
  private var session: AVCaptureSession?

  public func definition() -> ModuleDefinition {
    Name("Camera")

    AsyncFunction("startRecording") { [weak self] (promise: Promise) in
      guard let self = self else {
        promise.reject("MODULE_DEALLOCATED", "Module was deallocated")
        return
      }

      self.session?.startRunning()
      promise.resolve(true)
    }
  }
}
```

### Retain Cycles with Events

Be careful with event emitters to avoid retain cycles:

```swift
public class LocationModule: Module {
  private var locationManager: CLLocationManager?

  public func definition() -> ModuleDefinition {
    Name("Location")

    Events("onLocationUpdate")

    OnStartObserving {
      // Use weak self when setting up callbacks
      self.locationManager?.onUpdate = { [weak self] location in
        self?.sendEvent("onLocationUpdate", [
          "latitude": location.coordinate.latitude,
          "longitude": location.coordinate.longitude
        ])
      }
    }

    OnStopObserving {
      self.locationManager?.onUpdate = nil
    }
  }
}
```

### Resource Cleanup

Always clean up resources in lifecycle methods:

```swift
public class DatabaseModule: Module {
  private var connection: DatabaseConnection?

  public func definition() -> ModuleDefinition {
    Name("Database")

    OnDestroy {
      self.connection?.close()
      self.connection = nil
    }
  }
}
```

## Error Handling Patterns

### Using Exceptions

Expo modules can throw exceptions that are bridged to JavaScript:

```swift
Function("divide") { (a: Double, b: Double) throws -> Double in
  guard b != 0 else {
    throw Exception(name: "DivisionByZero", description: "Cannot divide by zero")
  }
  return a / b
}
```

### Custom Error Types

Define custom error types for better error handling:

```swift
enum NetworkError: Error {
  case invalidURL
  case timeout
  case unauthorized
  case serverError(Int)
}

extension NetworkError: CustomStringConvertible {
  var description: String {
    switch self {
    case .invalidURL:
      return "Invalid URL provided"
    case .timeout:
      return "Request timed out"
    case .unauthorized:
      return "Unauthorized access"
    case .serverError(let code):
      return "Server error with code: \(code)"
    }
  }
}

public class APIModule: Module {
  public func definition() -> ModuleDefinition {
    Name("API")

    AsyncFunction("fetch") { (url: String, promise: Promise) in
      guard URL(string: url) != nil else {
        promise.reject(
          "INVALID_URL",
          "Invalid URL provided",
          NetworkError.invalidURL
        )
        return
      }

      // Perform fetch
    }
  }
}
```

### Promise-based Error Handling

Use promises for asynchronous operations with proper error handling:

```swift
AsyncFunction("loadData") { (id: String, promise: Promise) in
  Task {
    do {
      let data = try await self.fetchData(id: id)
      promise.resolve(data)
    } catch let error as NetworkError {
      promise.reject("NETWORK_ERROR", error.description, error)
    } catch {
      promise.reject("UNKNOWN_ERROR", error.localizedDescription, error)
    }
  }
}
```

## Async/Await vs Callbacks

### Modern Async/Await (Recommended)

Use Swift's modern async/await with Expo's AsyncFunction:

```swift
public class StorageModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Storage")

    // Async/await style
    AsyncFunction("saveFile") { (path: String, data: String) async throws -> Bool in
      let url = URL(fileURLWithPath: path)
      try data.write(to: url, atomically: true, encoding: .utf8)
      return true
    }

    AsyncFunction("readFile") { (path: String) async throws -> String in
      let url = URL(fileURLWithPath: path)
      return try String(contentsOf: url, encoding: .utf8)
    }
  }
}
```

### Promise-based Callbacks (Legacy Support)

For compatibility or when working with callback-based APIs:

```swift
AsyncFunction("uploadFile") { (path: String, promise: Promise) in
  let uploadTask = self.performUpload(path: path)

  uploadTask.onComplete = { result in
    switch result {
    case .success(let response):
      promise.resolve(response)
    case .failure(let error):
      promise.reject("UPLOAD_FAILED", error.localizedDescription, error)
    }
  }
}
```

### Converting Callback APIs to Async/Await

Use continuations to bridge callback-based APIs:

```swift
private func fetchUserData(userId: String) async throws -> [String: Any] {
  return try await withCheckedThrowingContinuation { continuation in
    legacyAPI.getUserData(userId: userId) { result, error in
      if let error = error {
        continuation.resume(throwing: error)
      } else if let result = result {
        continuation.resume(returning: result)
      } else {
        continuation.resume(throwing: NSError(
          domain: "APIError",
          code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
        ))
      }
    }
  }
}

AsyncFunction("getUser") { (userId: String) async throws -> [String: Any] in
  return try await self.fetchUserData(userId: userId)
}
```

## SwiftUI Integration

### Using Views in Expo Modules

Define SwiftUI views as native components:

```swift
import SwiftUI

struct CustomButton: View {
  @ObservedObject var props: CustomButtonProps

  var body: some View {
    Button(action: {
      props.onPress?()
    }) {
      Text(props.title)
        .foregroundColor(Color(props.textColor))
        .padding()
        .background(Color(props.backgroundColor))
        .cornerRadius(props.cornerRadius)
    }
  }
}

class CustomButtonProps: ExpoSwiftUI.ViewProps {
  @Field var title: String = "Button"
  @Field var textColor: UIColor = .white
  @Field var backgroundColor: UIColor = .blue
  @Field var cornerRadius: CGFloat = 8.0
  @Field var onPress: (() -> Void)?
}

public class UIComponentsModule: Module {
  public func definition() -> ModuleDefinition {
    Name("UIComponents")

    View(CustomButton.self) {
      Props {
        Prop("title") { (props: CustomButtonProps, title: String) in
          props.title = title
        }

        Prop("textColor") { (props: CustomButtonProps, color: UIColor) in
          props.textColor = color
        }

        Prop("backgroundColor") { (props: CustomButtonProps, color: UIColor) in
          props.backgroundColor = color
        }

        Prop("cornerRadius") { (props: CustomButtonProps, radius: CGFloat) in
          props.cornerRadius = radius
        }

        Events("onPress") { (props: CustomButtonProps, eventDispatcher: EventDispatcher) in
          props.onPress = {
            eventDispatcher([:])
          }
        }
      }
    }
  }
}
```

### UIKit to SwiftUI Bridge

When you need to use UIKit components:

```swift
import SwiftUI
import ExpoModulesCore

struct UIKitVideoPlayer: UIViewRepresentable {
  let url: URL
  let onReady: () -> Void

  func makeUIView(context: Context) -> UIView {
    let playerView = AVPlayerView()
    playerView.player = AVPlayer(url: url)
    return playerView
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    // Update view if needed
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(onReady: onReady)
  }

  class Coordinator: NSObject {
    let onReady: () -> Void

    init(onReady: @escaping () -> Void) {
      self.onReady = onReady
    }
  }
}
```

## Testing Swift Modules

### Unit Testing

Create unit tests for your module logic:

```swift
import XCTest
@testable import MyExpoModule

class MyModuleTests: XCTestCase {
  var module: MyModule!

  override func setUp() {
    super.setUp()
    module = MyModule()
  }

  override func tearDown() {
    module = nil
    super.tearDown()
  }

  func testCalculation() {
    let result = module.calculate(a: 5, b: 3)
    XCTAssertEqual(result, 8)
  }

  func testAsyncOperation() async throws {
    let result = try await module.fetchData(id: "123")
    XCTAssertNotNil(result)
  }

  func testErrorHandling() {
    XCTAssertThrowsError(try module.riskyOperation()) { error in
      XCTAssertTrue(error is NetworkError)
    }
  }
}
```

### Mocking Dependencies

Use protocols for dependency injection and testing:

```swift
protocol DataService {
  func fetchData(id: String) async throws -> [String: Any]
}

class RealDataService: DataService {
  func fetchData(id: String) async throws -> [String: Any] {
    // Real implementation
    return [:]
  }
}

class MockDataService: DataService {
  var mockData: [String: Any] = [:]
  var shouldThrowError = false

  func fetchData(id: String) async throws -> [String: Any] {
    if shouldThrowError {
      throw NetworkError.serverError(500)
    }
    return mockData
  }
}

public class DataModule: Module {
  private let dataService: DataService

  init(dataService: DataService = RealDataService()) {
    self.dataService = dataService
  }

  public func definition() -> ModuleDefinition {
    Name("Data")

    AsyncFunction("getData") { (id: String) async throws -> [String: Any] in
      return try await self.dataService.fetchData(id: id)
    }
  }
}

// In tests
class DataModuleTests: XCTestCase {
  func testGetData() async throws {
    let mockService = MockDataService()
    mockService.mockData = ["key": "value"]

    let module = DataModule(dataService: mockService)
    let result = try await module.getData(id: "123")

    XCTAssertEqual(result["key"] as? String, "value")
  }
}
```

### Integration Testing

Test the module in an Expo app context:

```swift
import XCTest
import ExpoModulesCore
@testable import MyExpoModule

class ModuleIntegrationTests: XCTestCase {
  var appContext: AppContext!
  var module: MyModule!

  override func setUp() {
    super.setUp()
    appContext = AppContext()
    module = MyModule(appContext: appContext)
  }

  func testModuleInitialization() {
    XCTAssertNotNil(module)
    XCTAssertEqual(module.definition().name, "MyModule")
  }

  func testEventEmission() {
    let expectation = XCTestExpectation(description: "Event emitted")

    module.sendEvent("testEvent", ["data": "value"])

    // Verify event was sent
    expectation.fulfill()
    wait(for: [expectation], timeout: 1.0)
  }
}
```

## Performance Optimization

### Lazy Initialization

Initialize expensive resources only when needed:

```swift
public class ImageProcessorModule: Module {
  private lazy var processor: ImageProcessor = {
    return ImageProcessor(configuration: .highQuality)
  }()

  public func definition() -> ModuleDefinition {
    Name("ImageProcessor")

    Function("processImage") { (path: String) -> String in
      // Processor is only initialized when first used
      return self.processor.process(imagePath: path)
    }
  }
}
```

### Caching

Implement caching for expensive operations:

```swift
public class APIModule: Module {
  private var cache: [String: Any] = [:]
  private let cacheQueue = DispatchQueue(label: "com.myapp.cache")

  public func definition() -> ModuleDefinition {
    Name("API")

    AsyncFunction("fetchData") { (key: String) async throws -> Any in
      // Check cache first
      if let cached = await self.getCached(key: key) {
        return cached
      }

      // Fetch and cache
      let data = try await self.performFetch(key: key)
      await self.setCache(key: key, value: data)
      return data
    }
  }

  private func getCached(key: String) async -> Any? {
    return await cacheQueue.sync {
      return cache[key]
    }
  }

  private func setCache(key: String, value: Any) async {
    await cacheQueue.sync {
      cache[key] = value
    }
  }
}
```

### Background Processing

Use background queues for heavy operations:

```swift
public class DataProcessorModule: Module {
  private let processingQueue = DispatchQueue(
    label: "com.myapp.processing",
    qos: .userInitiated,
    attributes: .concurrent
  )

  public func definition() -> ModuleDefinition {
    Name("DataProcessor")

    AsyncFunction("processLargeDataset") { (data: [Any], promise: Promise) in
      self.processingQueue.async {
        do {
          let result = try self.process(data: data)
          DispatchQueue.main.async {
            promise.resolve(result)
          }
        } catch {
          DispatchQueue.main.async {
            promise.reject("PROCESSING_ERROR", error.localizedDescription, error)
          }
        }
      }
    }
  }

  private func process(data: [Any]) throws -> [Any] {
    // Heavy processing logic
    return data
  }
}
```

### Memory Management for Large Data

Handle large data efficiently:

```swift
public class FileModule: Module {
  public func definition() -> ModuleDefinition {
    Name("File")

    AsyncFunction("processLargeFile") { (path: String) async throws -> Bool in
      let fileURL = URL(fileURLWithPath: path)

      // Use streaming instead of loading entire file
      guard let inputStream = InputStream(url: fileURL) else {
        throw Exception(name: "FILE_ERROR", description: "Cannot open file")
      }

      inputStream.open()
      defer { inputStream.close() }

      let bufferSize = 4096
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
      defer { buffer.deallocate() }

      while inputStream.hasBytesAvailable {
        let bytesRead = inputStream.read(buffer, maxLength: bufferSize)
        if bytesRead > 0 {
          // Process chunk
          autoreleasepool {
            self.processChunk(buffer, length: bytesRead)
          }
        }
      }

      return true
    }
  }

  private func processChunk(_ buffer: UnsafeMutablePointer<UInt8>, length: Int) {
    // Process data chunk
  }
}
```

### Avoid Retain Cycles in Closures

Always use capture lists appropriately:

```swift
public class NotificationModule: Module {
  private var observers: [String: NSObjectProtocol] = [:]

  public func definition() -> ModuleDefinition {
    Name("Notification")

    Function("addListener") { (eventName: String) in
      let observer = NotificationCenter.default.addObserver(
        forName: NSNotification.Name(eventName),
        object: nil,
        queue: .main
      ) { [weak self] notification in
        // weak self prevents retain cycle
        guard let self = self else { return }
        self.sendEvent("notification", [
          "name": eventName,
          "data": notification.userInfo ?? [:]
        ])
      }

      self.observers[eventName] = observer
    }

    OnDestroy {
      for (_, observer) in self.observers {
        NotificationCenter.default.removeObserver(observer)
      }
      self.observers.removeAll()
    }
  }
}
```

## Additional Best Practices

### Constants and Configuration

Define module constants clearly:

```swift
public class ConfigModule: Module {
  private enum Constants {
    static let maxRetries = 3
    static let timeout: TimeInterval = 30.0
    static let apiVersion = "v1"
  }

  public func definition() -> ModuleDefinition {
    Name("Config")

    Constants {
      ("MAX_RETRIES", Constants.maxRetries)
      ("TIMEOUT", Constants.timeout)
      ("API_VERSION", Constants.apiVersion)
    }
  }
}
```

### Documentation

Use Swift documentation comments:

```swift
/// A module for handling user authentication
public class AuthModule: Module {

  /// Authenticates a user with email and password
  /// - Parameters:
  ///   - email: The user's email address
  ///   - password: The user's password
  /// - Returns: A dictionary containing user data and auth token
  /// - Throws: AuthError if authentication fails
  AsyncFunction("login") { (email: String, password: String) async throws -> [String: Any] in
    // Implementation
    return [:]
  }
}
```

### Type Conversions

Handle type conversions safely:

```swift
Function("updateSettings") { (settings: [String: Any]) in
  if let timeout = settings["timeout"] as? Double {
    self.timeout = timeout
  }

  if let retries = settings["retries"] as? Int {
    self.maxRetries = retries
  }

  // Use nil coalescing for defaults
  let debugMode = settings["debug"] as? Bool ?? false
}
```
