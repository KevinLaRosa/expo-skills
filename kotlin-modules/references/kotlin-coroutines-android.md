# Kotlin Coroutines on Android

> Source: [Android Developers - Kotlin Coroutines](https://developer.android.com/kotlin/coroutines)

## Overview

Coroutines are Kotlin's recommended solution for asynchronous programming on Android. They simplify code that executes asynchronously and help manage long-running tasks that would otherwise block the main thread.

## Key Features

- **Lightweight**: Support for suspension without blocking threads, saving memory
- **Fewer memory leaks**: Use structured concurrency to run operations within a scope
- **Built-in cancellation support**: Automatic propagation through coroutine hierarchy
- **Jetpack integration**: Many Jetpack libraries provide coroutine extensions and scopes

## Core Concepts

### 1. CoroutineScope and viewModelScope

`viewModelScope` is a predefined `CoroutineScope` from the ViewModel KTX extensions that automatically manages coroutine lifecycle:

```kotlin
class LoginViewModel(
    private val loginRepository: LoginRepository
) : ViewModel() {

    fun login(username: String, token: String) {
        viewModelScope.launch {
            val jsonBody = "{ username: \"$username\", token: \"$token\"}"
            val result = loginRepository.makeLoginRequest(jsonBody)
        }
    }
}
```

**Benefits**:
- Automatically cancelled when ViewModel is destroyed
- Tied to Android lifecycle
- No memory leaks from abandoned coroutines

### 2. Dispatchers

Control which thread executes the coroutine:

```kotlin
// Main thread (UI updates)
viewModelScope.launch { }

// I/O thread (network/database)
viewModelScope.launch(Dispatchers.IO) { }
```

## Main-Safety Pattern

Use `withContext()` to make repository functions main-safe (non-blocking):

```kotlin
class LoginRepository(private val responseParser: LoginResponseParser) {
    private const val loginUrl = "https://example.com/login"

    suspend fun makeLoginRequest(jsonBody: String): Result<LoginResponse> {
        // Move execution to I/O thread
        return withContext(Dispatchers.IO) {
            val url = URL(loginUrl)
            (url.openConnection() as? HttpURLConnection)?.run {
                requestMethod = "POST"
                setRequestProperty("Content-Type", "application/json; utf-8")
                setRequestProperty("Accept", "application/json")
                doOutput = true
                outputStream.write(jsonBody.toByteArray())
                return@withContext Result.Success(responseParser.parse(inputStream))
            }
            Result.Error(Exception("Cannot open HttpURLConnection"))
        }
    }
}
```

**Key points**:
- `suspend` keyword enforces calling from within a coroutine
- `withContext()` switches dispatcher without creating a new coroutine
- Makes the function safe to call from the main thread

## Structured Concurrency

The recommended pattern integrating with ViewModel:

```kotlin
class LoginViewModel(
    private val loginRepository: LoginRepository
) : ViewModel() {

    fun login(username: String, token: String) {
        // Create coroutine in main scope
        viewModelScope.launch {
            val jsonBody = "{ username: \"$username\", token: \"$token\"}"

            // Call suspend function (thread switch happens internally)
            val result = try {
                loginRepository.makeLoginRequest(jsonBody)
            } catch(e: Exception) {
                Result.Error(Exception("Network request failed"))
            }

            // Update UI with result (back on main thread)
            when (result) {
                is Result.Success<LoginResponse> -> {
                    // Update LiveData for UI
                }
                is Result.Error -> {
                    // Show error in UI
                }
            }
        }
    }
}
```

## Exception Handling

Use Kotlin's standard try-catch blocks:

```kotlin
viewModelScope.launch {
    val result = try {
        loginRepository.makeLoginRequest(jsonBody)
    } catch(e: Exception) {
        Result.Error(Exception("Network request failed"))
    }

    when (result) {
        is Result.Success -> { /* handle success */ }
        is Result.Error -> { /* handle error */ }
    }
}
```

## Execution Flow

1. App calls `login()` from View layer on main thread
2. `launch` creates a coroutine on main thread
3. Coroutine calls `makeLoginRequest()` which suspends
4. `withContext()` switches to I/O thread for network operation
5. Network completes and coroutine resumes on main thread
6. Result is displayed via UI updates

## Result Sealed Class

Model network responses:

```kotlin
sealed class Result<out R> {
    data class Success<out T>(val data: T) : Result<T>()
    data class Error(val exception: Exception) : Result<Nothing>()
}
```

## Dependencies

Add to `build.gradle`:

```kotlin
dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.3.9")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.x.x")
}
```

## Best Practices

1. **Use viewModelScope** for automatic lifecycle management
2. **Make repository functions main-safe** with `suspend` and `withContext()`
3. **Inject Dispatchers** into repositories for easier testing
4. **Use LiveData** to communicate between ViewModel and View layers
5. **Handle exceptions** with try-catch blocks within coroutines
6. **Never block** the main thread

## Related Resources

- [Kotlin Coroutines Guide](https://kotlinlang.org/docs/coroutines-guide.html)
- [Advanced coroutines concepts](https://developer.android.com/kotlin/coroutines/coroutines-adv)
- [Testing coroutines](https://developer.android.com/kotlin/coroutines/test)
- [Kotlin Flows](https://developer.android.com/kotlin/flow)
