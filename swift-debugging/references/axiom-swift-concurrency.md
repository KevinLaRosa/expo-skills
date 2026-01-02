# Swift 6 Concurrency Guide

> Source: [Axiom - Swift Concurrency](https://charleswiltgen.github.io/Axiom/skills/concurrency/swift-concurrency)

## Core Purpose
The skill guides developers through "a progressive journey from single-threaded to concurrent Swift code," addressing Swift 6 strict concurrency, actor isolation, data race prevention, and the `@concurrent` attribute (Swift 6.2+).

## When to Apply This Skill
Use it when:
- Starting new projects and determining concurrency strategy
- Debugging Swift 6 concurrency errors (actor isolation, Sendable compliance, data races)
- Deciding between async/await versus full concurrency implementation
- Working with `@MainActor` classes or async functions
- Converting delegate callbacks to async-safe patterns
- Resolving "Sending 'self' risks causing data races" errors
- Moving CPU-intensive operations off the main thread

## Key Progression Model
The skill teaches four escalating stages:
1. **Single-Threaded** (starting point)
2. **Asynchronous** (hiding I/O latency)
3. **Concurrent** (background CPU work)
4. **Actors** (isolating mutable state)

## Core Concepts Covered
- `@MainActor` for main thread isolation
- `nonisolated` for opting out of actor isolation
- `@concurrent` for forcing background execution
- `Sendable` protocol for thread-safe type passing
- Actor-based state isolation patterns

## Common Patterns Included
- Async/await for network operations
- Task groups for parallel work
- Actor-isolated data managers
- MainActor application to SwiftUI state
- Continuations for callback bridging

## Error Resolution Guidance
The skill addresses common compiler errors including:
- Actor isolation violations
- Non-sendable type crossing
- Mutable property restrictions
- Synchronous calls to main actor functions

## Related Resources
- [Swift.org - Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- WWDC Sessions on Swift Concurrency
- [Axiom - Swift Concurrency Skill](https://charleswiltgen.github.io/Axiom/skills/concurrency/swift-concurrency)
