# Kotlin Best Practices for Expo Modules

## Kotlin Coding Style for Expo Modules

### Module Definition

```kotlin
package expo.modules.mymodule

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class MyModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("MyModule")

    // Module configuration goes here
  }
}
```

### Naming Conventions

- **Classes**: Use PascalCase for module classes
- **Functions**: Use camelCase for function names
- **Constants**: Use camelCase for const vals, UPPER_SNAKE_CASE for companion object constants
- **Properties**: Use camelCase for properties

```kotlin
// Good
class VideoPlayerModule : Module() {
  private val maxRetryCount = 3

  companion object {
    private const val DEFAULT_TIMEOUT = 30000L
    private const val TAG = "VideoPlayerModule"
  }

  override fun definition() = ModuleDefinition {
    Name("VideoPlayer")

    Function("playVideo") { url: String ->
      // Implementation
    }
  }
}
```

### Type Safety

Always use explicit types when exposing APIs to JavaScript:

```kotlin
// Good - Explicit types
Function("calculateDistance") { x: Double, y: Double ->
  sqrt(x * x + y * y)
}

// Avoid - Implicit types can cause issues
Function("calculateDistance") { x, y ->
  sqrt(x * x + y * y)
}
```

### Property Delegates

Use Kotlin property delegates effectively:

```kotlin
class PreferencesModule : Module() {
  private val preferences by lazy {
    appContext.reactContext?.getSharedPreferences(
      "expo_prefs",
      Context.MODE_PRIVATE
    )
  }

  override fun definition() = ModuleDefinition {
    Name("Preferences")

    Function("getString") { key: String ->
      preferences?.getString(key, null)
    }
  }
}
```

## Coroutines Best Practices

### Using Coroutines with AsyncFunction

Expo modules provide seamless integration with Kotlin coroutines:

```kotlin
class NetworkModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Network")

    // Coroutine-based async function
    AsyncFunction("fetchData") { url: String ->
      withContext(Dispatchers.IO) {
        val client = OkHttpClient()
        val request = Request.Builder()
          .url(url)
          .build()

        client.newCall(request).execute().use { response ->
          if (!response.isSuccessful) {
            throw Exception("HTTP ${response.code}: ${response.message}")
          }
          response.body?.string() ?: ""
        }
      }
    }
  }
}
```

### Structured Concurrency

Use structured concurrency patterns:

```kotlin
class DataSyncModule : Module() {
  private val moduleScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

  override fun definition() = ModuleDefinition {
    Name("DataSync")

    AsyncFunction("syncAll") {
      coroutineScope {
        val user = async { fetchUserData() }
        val posts = async { fetchPosts() }
        val comments = async { fetchComments() }

        mapOf(
          "user" to user.await(),
          "posts" to posts.await(),
          "comments" to comments.await()
        )
      }
    }

    OnDestroy {
      moduleScope.cancel()
    }
  }

  private suspend fun fetchUserData(): Map<String, Any> {
    delay(100)
    return mapOf("id" to "123", "name" to "User")
  }

  private suspend fun fetchPosts(): List<Map<String, Any>> {
    delay(200)
    return listOf(mapOf("id" to "1", "title" to "Post"))
  }

  private suspend fun fetchComments(): List<Map<String, Any>> {
    delay(150)
    return listOf(mapOf("id" to "1", "text" to "Comment"))
  }
}
```

### Flow for Streaming Data

Use Kotlin Flow for reactive data streams:

```kotlin
class LocationModule : Module() {
  private val locationFlow = MutableSharedFlow<Location>(replay = 1)

  override fun definition() = ModuleDefinition {
    Name("Location")

    Events("onLocationUpdate")

    OnStartObserving("onLocationUpdate") {
      // Start collecting location updates
      moduleScope.launch {
        locationFlow.collect { location ->
          sendEvent("onLocationUpdate", mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude
          ))
        }
      }
    }

    AsyncFunction("getCurrentLocation") {
      locationFlow.first()
    }
  }
}
```

### Cancellation and Timeouts

Handle coroutine cancellation properly:

```kotlin
class DownloadModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Download")

    AsyncFunction("downloadFile") { url: String ->
      withTimeout(30000L) { // 30 second timeout
        withContext(Dispatchers.IO) {
          try {
            downloadFileWithProgress(url)
          } catch (e: CancellationException) {
            // Clean up resources
            cleanup()
            throw e // Re-throw to propagate cancellation
          }
        }
      }
    }
  }

  private suspend fun downloadFileWithProgress(url: String): String {
    // Download implementation
    // Check for cancellation periodically
    ensureActive() // Throws if cancelled
    return "downloaded"
  }

  private fun cleanup() {
    // Clean up resources
  }
}
```

### Dispatcher Selection

Choose the right dispatcher for the task:

```kotlin
class ProcessingModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Processing")

    AsyncFunction("processImage") { path: String ->
      // CPU-intensive work
      withContext(Dispatchers.Default) {
        processImageData(path)
      }
    }

    AsyncFunction("saveToDatabase") { data: Map<String, Any> ->
      // IO operations
      withContext(Dispatchers.IO) {
        database.insert(data)
      }
    }

    Function("updateUI") { text: String ->
      // UI updates (if needed)
      withContext(Dispatchers.Main) {
        updateView(text)
      }
    }
  }
}
```

## Null Safety Patterns

### Safe Calls and Elvis Operator

Use Kotlin's null safety features:

```kotlin
class StorageModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Storage")

    Function("getItem") { key: String ->
      // Safe call with Elvis operator
      preferences?.getString(key, null) ?: throw Exception("Preferences not initialized")
    }

    Function("getItemOrDefault") { key: String, defaultValue: String ->
      // Elvis operator for default value
      preferences?.getString(key, null) ?: defaultValue
    }

    Function("hasItem") { key: String ->
      // Safe call with let
      preferences?.contains(key) ?: false
    }
  }
}
```

### Nullable Type Handling

Handle nullable types explicitly:

```kotlin
class UserModule : Module() {
  private var currentUser: User? = null

  override fun definition() = ModuleDefinition {
    Name("User")

    Function("getUserName") {
      // Throw if null
      currentUser?.name ?: throw Exception("No user logged in")
    }

    Function("getUserAge") {
      // Return nullable value to JS
      currentUser?.age
    }

    Function("isLoggedIn") {
      // Convert to boolean
      currentUser != null
    }

    Function("getUser") {
      // Use let for safe transformation
      currentUser?.let { user ->
        mapOf(
          "id" to user.id,
          "name" to user.name,
          "email" to user.email
        )
      }
    }
  }
}

data class User(
  val id: String,
  val name: String,
  val email: String,
  val age: Int?
)
```

### Require and Check

Use require and check for validation:

```kotlin
class ValidationModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Validation")

    Function("processAge") { age: Int ->
      require(age >= 0) { "Age must be non-negative" }
      require(age < 150) { "Invalid age value" }
      // Process age
      age
    }

    Function("divide") { a: Double, b: Double ->
      check(b != 0.0) { "Division by zero" }
      a / b
    }
  }
}
```

### Safe Casts

Use safe casting operators:

```kotlin
class DataModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Data")

    Function("processValue") { value: Any ->
      when (val typed = value) {
        is String -> processString(typed)
        is Int -> processInt(typed)
        is Map<*, *> -> processMap(typed as? Map<String, Any> ?: emptyMap())
        else -> throw IllegalArgumentException("Unsupported type")
      }
    }
  }

  private fun processString(s: String): String = s.uppercase()
  private fun processInt(i: Int): Int = i * 2
  private fun processMap(m: Map<String, Any>): Map<String, Any> = m
}
```

## Data Classes and Sealed Classes

### Data Classes for DTOs

Use data classes for data transfer objects:

```kotlin
data class UserProfile(
  val id: String,
  val name: String,
  val email: String,
  val avatarUrl: String? = null,
  val createdAt: Long
) {
  fun toMap(): Map<String, Any?> = mapOf(
    "id" to id,
    "name" to name,
    "email" to email,
    "avatarUrl" to avatarUrl,
    "createdAt" to createdAt
  )
}

class ProfileModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Profile")

    AsyncFunction("getProfile") { userId: String ->
      val profile = fetchProfile(userId)
      profile.toMap()
    }
  }

  private suspend fun fetchProfile(userId: String): UserProfile {
    // Fetch from API
    return UserProfile(
      id = userId,
      name = "John Doe",
      email = "john@example.com",
      createdAt = System.currentTimeMillis()
    )
  }
}
```

### Sealed Classes for State Management

Use sealed classes for representing state:

```kotlin
sealed class NetworkResult<out T> {
  data class Success<T>(val data: T) : NetworkResult<T>()
  data class Error(val code: Int, val message: String) : NetworkResult<Nothing>()
  object Loading : NetworkResult<Nothing>()
}

sealed class DownloadState {
  object Idle : DownloadState()
  data class Downloading(val progress: Int) : DownloadState()
  data class Completed(val path: String) : DownloadState()
  data class Failed(val error: String) : DownloadState()
}

class DownloadManager : Module() {
  private val downloadState = MutableStateFlow<DownloadState>(DownloadState.Idle)

  override fun definition() = ModuleDefinition {
    Name("DownloadManager")

    Events("onDownloadStateChange")

    AsyncFunction("download") { url: String ->
      when (val result = performDownload(url)) {
        is NetworkResult.Success -> result.data
        is NetworkResult.Error -> throw Exception("${result.code}: ${result.message}")
        NetworkResult.Loading -> throw Exception("Unexpected state")
      }
    }

    OnStartObserving("onDownloadStateChange") {
      moduleScope.launch {
        downloadState.collect { state ->
          val stateMap = when (state) {
            is DownloadState.Idle -> mapOf("status" to "idle")
            is DownloadState.Downloading -> mapOf(
              "status" to "downloading",
              "progress" to state.progress
            )
            is DownloadState.Completed -> mapOf(
              "status" to "completed",
              "path" to state.path
            )
            is DownloadState.Failed -> mapOf(
              "status" to "failed",
              "error" to state.error
            )
          }
          sendEvent("onDownloadStateChange", stateMap)
        }
      }
    }
  }

  private suspend fun performDownload(url: String): NetworkResult<String> {
    return try {
      downloadState.value = DownloadState.Downloading(0)
      // Download logic with progress updates
      val path = "/path/to/file"
      downloadState.value = DownloadState.Completed(path)
      NetworkResult.Success(path)
    } catch (e: Exception) {
      downloadState.value = DownloadState.Failed(e.message ?: "Unknown error")
      NetworkResult.Error(500, e.message ?: "Download failed")
    }
  }
}
```

### Enum Classes

Use enum classes for fixed sets of values:

```kotlin
enum class LogLevel(val priority: Int) {
  DEBUG(0),
  INFO(1),
  WARNING(2),
  ERROR(3);

  companion object {
    fun fromString(level: String): LogLevel {
      return values().find { it.name.equals(level, ignoreCase = true) } ?: INFO
    }
  }
}

class LoggerModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Logger")

    Function("log") { level: String, message: String ->
      val logLevel = LogLevel.fromString(level)
      when (logLevel) {
        LogLevel.DEBUG -> Log.d(TAG, message)
        LogLevel.INFO -> Log.i(TAG, message)
        LogLevel.WARNING -> Log.w(TAG, message)
        LogLevel.ERROR -> Log.e(TAG, message)
      }
    }
  }

  companion object {
    private const val TAG = "LoggerModule"
  }
}
```

## Testing Kotlin Modules

### Unit Testing

Create unit tests for module logic:

```kotlin
import org.junit.Test
import org.junit.Assert.*
import org.junit.Before
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.MockitoAnnotations

class CalculatorModuleTest {
  @Mock
  private lateinit var mockContext: Context

  private lateinit var module: CalculatorModule

  @Before
  fun setup() {
    MockitoAnnotations.openMocks(this)
    module = CalculatorModule()
  }

  @Test
  fun `test addition`() {
    val result = module.add(5.0, 3.0)
    assertEquals(8.0, result, 0.001)
  }

  @Test
  fun `test division`() {
    val result = module.divide(10.0, 2.0)
    assertEquals(5.0, result, 0.001)
  }

  @Test(expected = IllegalArgumentException::class)
  fun `test division by zero throws exception`() {
    module.divide(10.0, 0.0)
  }
}
```

### Coroutine Testing

Use kotlinx-coroutines-test for testing suspending functions:

```kotlin
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import org.junit.Test
import org.junit.Assert.*

@ExperimentalCoroutinesApi
class NetworkModuleTest {
  private val testDispatcher = StandardTestDispatcher()

  @Before
  fun setup() {
    Dispatchers.setMain(testDispatcher)
  }

  @After
  fun tearDown() {
    Dispatchers.resetMain()
  }

  @Test
  fun `test async data fetch`() = runTest {
    val module = NetworkModule()
    val result = module.fetchData("test-id")

    assertNotNull(result)
    assertTrue(result.containsKey("id"))
  }

  @Test
  fun `test timeout handling`() = runTest {
    val module = NetworkModule()

    assertThrows(TimeoutCancellationException::class.java) {
      runBlocking {
        module.fetchDataWithTimeout("slow-endpoint")
      }
    }
  }
}
```

### Mocking Dependencies

Use interfaces and dependency injection for testability:

```kotlin
interface ApiClient {
  suspend fun get(url: String): String
  suspend fun post(url: String, body: String): String
}

class RealApiClient : ApiClient {
  override suspend fun get(url: String): String {
    // Real implementation
    return ""
  }

  override suspend fun post(url: String, body: String): String {
    // Real implementation
    return ""
  }
}

class MockApiClient : ApiClient {
  var mockResponse: String = "{}"
  var shouldThrowError: Boolean = false

  override suspend fun get(url: String): String {
    if (shouldThrowError) {
      throw IOException("Network error")
    }
    return mockResponse
  }

  override suspend fun post(url: String, body: String): String {
    if (shouldThrowError) {
      throw IOException("Network error")
    }
    return mockResponse
  }
}

class ApiModule(
  private val client: ApiClient = RealApiClient()
) : Module() {
  override fun definition() = ModuleDefinition {
    Name("Api")

    AsyncFunction("fetchUser") { userId: String ->
      client.get("https://api.example.com/users/$userId")
    }
  }
}

// In tests
@Test
fun `test fetchUser success`() = runTest {
  val mockClient = MockApiClient()
  mockClient.mockResponse = """{"id":"123","name":"John"}"""

  val module = ApiModule(client = mockClient)
  val result = module.fetchUser("123")

  assertTrue(result.contains("John"))
}

@Test
fun `test fetchUser error`() = runTest {
  val mockClient = MockApiClient()
  mockClient.shouldThrowError = true

  val module = ApiModule(client = mockClient)

  assertThrows(IOException::class.java) {
    runBlocking {
      module.fetchUser("123")
    }
  }
}
```

### Testing Events

Test event emission:

```kotlin
@ExperimentalCoroutinesApi
class EventModuleTest {
  @Test
  fun `test event emission`() = runTest {
    val module = EventModule()
    val events = mutableListOf<Map<String, Any>>()

    // Mock event listener
    module.setEventListener { name, data ->
      if (name == "testEvent") {
        events.add(data)
      }
    }

    module.emitTestEvent(mapOf("value" to 42))

    assertEquals(1, events.size)
    assertEquals(42, events[0]["value"])
  }
}
```

## Performance Optimization

### Lazy Initialization

Use lazy delegates for expensive initialization:

```kotlin
class ImageProcessorModule : Module() {
  private val processor by lazy {
    ImageProcessor(context).apply {
      setQuality(100)
      setCompression(true)
    }
  }

  override fun definition() = ModuleDefinition {
    Name("ImageProcessor")

    Function("processImage") { path: String ->
      // Processor is initialized only when first used
      processor.process(path)
    }
  }
}
```

### Caching

Implement caching strategies:

```kotlin
class CacheModule : Module() {
  private val cache = ConcurrentHashMap<String, Any>()
  private val cacheExpiry = ConcurrentHashMap<String, Long>()
  private val ttl = 60_000L // 1 minute

  override fun definition() = ModuleDefinition {
    Name("Cache")

    Function("get") { key: String ->
      if (isExpired(key)) {
        cache.remove(key)
        cacheExpiry.remove(key)
        null
      } else {
        cache[key]
      }
    }

    Function("set") { key: String, value: Any ->
      cache[key] = value
      cacheExpiry[key] = System.currentTimeMillis() + ttl
    }

    Function("clear") {
      cache.clear()
      cacheExpiry.clear()
    }
  }

  private fun isExpired(key: String): Boolean {
    val expiry = cacheExpiry[key] ?: return true
    return System.currentTimeMillis() > expiry
  }
}
```

### Object Pooling

Reuse expensive objects:

```kotlin
class ConnectionPoolModule : Module() {
  private val connectionPool = object {
    private val pool = LinkedList<Connection>()
    private val maxSize = 10

    @Synchronized
    fun acquire(): Connection {
      return if (pool.isNotEmpty()) {
        pool.removeFirst()
      } else {
        createConnection()
      }
    }

    @Synchronized
    fun release(connection: Connection) {
      if (pool.size < maxSize) {
        pool.add(connection)
      } else {
        connection.close()
      }
    }

    private fun createConnection(): Connection {
      return Connection()
    }
  }

  override fun definition() = ModuleDefinition {
    Name("ConnectionPool")

    AsyncFunction("executeQuery") { query: String ->
      val connection = connectionPool.acquire()
      try {
        connection.execute(query)
      } finally {
        connectionPool.release(connection)
      }
    }

    OnDestroy {
      // Clean up all connections
    }
  }
}

class Connection {
  fun execute(query: String): String = "result"
  fun close() {}
}
```

### Memory-Efficient Collections

Use appropriate collection types:

```kotlin
class CollectionModule : Module() {
  // Use Array for fixed-size collections
  private val fixedData = arrayOf(1, 2, 3, 4, 5)

  // Use List for read-only collections
  private val readOnlyList = listOf("a", "b", "c")

  // Use Sequence for large or infinite collections
  private fun processLargeData(data: List<Int>): List<Int> {
    return data.asSequence()
      .filter { it % 2 == 0 }
      .map { it * 2 }
      .take(100)
      .toList()
  }

  override fun definition() = ModuleDefinition {
    Name("Collection")

    Function("processData") { count: Int ->
      val largeList = (1..count).toList()
      processLargeData(largeList)
    }
  }
}
```

### Background Processing

Use coroutines with appropriate dispatchers:

```kotlin
class BackgroundModule : Module() {
  private val backgroundScope = CoroutineScope(
    SupervisorJob() + Dispatchers.Default
  )

  override fun definition() = ModuleDefinition {
    Name("Background")

    AsyncFunction("heavyComputation") { data: List<Int> ->
      withContext(Dispatchers.Default) {
        data.map { item ->
          // CPU-intensive work
          complexCalculation(item)
        }
      }
    }

    Function("startBackgroundTask") {
      backgroundScope.launch {
        while (isActive) {
          performPeriodicTask()
          delay(5000)
        }
      }
    }

    OnDestroy {
      backgroundScope.cancel()
    }
  }

  private fun complexCalculation(value: Int): Int {
    // Simulated heavy computation
    return value * value
  }

  private suspend fun performPeriodicTask() {
    // Background task logic
  }
}
```

### Avoid Memory Leaks

Properly manage lifecycle and clean up resources:

```kotlin
class ResourceModule : Module() {
  private var callback: ((String) -> Unit)? = null
  private var listener: SomeListener? = null
  private val jobs = mutableListOf<Job>()

  override fun definition() = ModuleDefinition {
    Name("Resource")

    Function("registerCallback") { fn: (String) -> Unit ->
      callback = fn
    }

    Function("startListening") {
      listener = createListener()
      registerListener(listener!!)
    }

    AsyncFunction("startJob") {
      val job = moduleScope.launch {
        // Long-running task
      }
      jobs.add(job)
    }

    OnDestroy {
      // Clean up all resources
      callback = null
      listener?.let { unregisterListener(it) }
      listener = null
      jobs.forEach { it.cancel() }
      jobs.clear()
    }
  }

  private fun createListener(): SomeListener = object : SomeListener {
    override fun onEvent(data: String) {
      // Handle event
    }
  }

  private fun registerListener(listener: SomeListener) {}
  private fun unregisterListener(listener: SomeListener) {}
}

interface SomeListener {
  fun onEvent(data: String)
}
```

## Additional Best Practices

### Extension Functions

Use extension functions for cleaner code:

```kotlin
fun Map<String, Any>.toBundle(): Bundle {
  return Bundle().apply {
    this@toBundle.forEach { (key, value) ->
      when (value) {
        is String -> putString(key, value)
        is Int -> putInt(key, value)
        is Boolean -> putBoolean(key, value)
        is Double -> putDouble(key, value)
        // Add more types as needed
      }
    }
  }
}

class BundleModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Bundle")

    Function("createBundle") { data: Map<String, Any> ->
      val bundle = data.toBundle()
      // Use bundle
      true
    }
  }
}
```

### Scope Functions

Use scope functions effectively:

```kotlin
class BuilderModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("Builder")

    Function("createUser") { data: Map<String, Any> ->
      User().apply {
        id = data["id"] as? String ?: ""
        name = data["name"] as? String ?: ""
        email = data["email"] as? String ?: ""
      }.let { user ->
        validateUser(user)
        user.toMap()
      }
    }

    Function("processConfig") { config: Map<String, Any> ->
      config.takeIf { it.containsKey("enabled") }
        ?.let { processEnabled(it) }
        ?: throw IllegalArgumentException("Config must have 'enabled' key")
    }
  }

  private fun validateUser(user: User) {
    require(user.email.isNotEmpty()) { "Email is required" }
  }

  private fun processEnabled(config: Map<String, Any>): Boolean {
    return config["enabled"] as? Boolean ?: false
  }
}
```

### Constants

Define constants properly:

```kotlin
class ConfigModule : Module() {
  companion object {
    private const val TAG = "ConfigModule"
    private const val MAX_RETRIES = 3
    private const val TIMEOUT_MS = 30000L
    private const val API_VERSION = "v1"
  }

  override fun definition() = ModuleDefinition {
    Name("Config")

    Constants {
      "MAX_RETRIES" to MAX_RETRIES
      "TIMEOUT_MS" to TIMEOUT_MS
      "API_VERSION" to API_VERSION
    }
  }
}
```

### Documentation

Use KDoc for documentation:

```kotlin
/**
 * A module for handling user authentication and authorization.
 *
 * This module provides functions for logging in, logging out,
 * and checking authentication status.
 */
class AuthModule : Module() {

  /**
   * Authenticates a user with email and password.
   *
   * @param email The user's email address
   * @param password The user's password
   * @return A map containing user data and authentication token
   * @throws IllegalArgumentException if email or password is empty
   * @throws Exception if authentication fails
   */
  override fun definition() = ModuleDefinition {
    Name("Auth")

    AsyncFunction("login") { email: String, password: String ->
      require(email.isNotEmpty()) { "Email cannot be empty" }
      require(password.isNotEmpty()) { "Password cannot be empty" }

      performLogin(email, password)
    }
  }

  private suspend fun performLogin(email: String, password: String): Map<String, Any> {
    // Implementation
    return mapOf("token" to "abc123")
  }
}
```

### Type Aliases

Use type aliases for complex types:

```kotlin
typealias UserData = Map<String, Any>
typealias Callback = (String) -> Unit
typealias AsyncCallback = suspend (String) -> Unit

class TypeAliasModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("TypeAlias")

    Function("processUser") { userData: UserData ->
      val id = userData["id"] as? String ?: ""
      val name = userData["name"] as? String ?: ""
      // Process user
      true
    }

    AsyncFunction("fetchUser") { userId: String ->
      fetchUserData(userId)
    }
  }

  private suspend fun fetchUserData(userId: String): UserData {
    return mapOf(
      "id" to userId,
      "name" to "John Doe"
    )
  }
}
```
