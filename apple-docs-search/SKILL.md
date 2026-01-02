---
name: apple-docs-search
description: Search and fetch Apple Developer documentation in AI-readable Markdown format using sosumi.ai for Swift, SwiftUI, WidgetKit, and iOS SDK references
license: MIT
compatibility: "Requires: Internet access, sosumi.ai service availability"
---

# Apple Docs Search

## Overview

Search and fetch Apple Developer documentation in AI-readable Markdown format using sosumi.ai, solving the problem that Apple's docs require JavaScript rendering which makes them inaccessible to language models.

## When to Use This Skill

- Need Swift API documentation
- Looking for SwiftUI view references
- Need WidgetKit documentation
- Want UIKit/AppKit API details
- Searching for iOS SDK documentation
- Need code examples from Apple docs

**When you see:**
- "Check Apple documentation for X"
- "What's the API for Y in Swift?"
- "How to use Z in SwiftUI?"
- Need official Apple references

**The Problem**: Apple Developer docs use JavaScript rendering, showing "This page requires JavaScript" to LLMs, making them invisible.

**The Solution**: sosumi.ai converts Apple docs to Markdown format accessible to AI agents.

## Workflow

### Step 1: Search Apple Documentation

**Use sosumi.ai to search:**

Replace `developer.apple.com` with `sosumi.ai` in any URL:

```
# Original Apple URL:
https://developer.apple.com/documentation/widgetkit

# sosumi.ai URL (AI-readable Markdown):
https://sosumi.ai/documentation/widgetkit
```

**Common documentation paths:**

```
# WidgetKit
https://sosumi.ai/documentation/widgetkit

# SwiftUI
https://sosumi.ai/documentation/swiftui

# UIKit
https://sosumi.ai/documentation/uikit

# Foundation
https://sosumi.ai/documentation/foundation

# Combine
https://sosumi.ai/documentation/combine

# Swift Language
https://sosumi.ai/documentation/swift

# Expo Modules specifics
https://sosumi.ai/documentation/swift/documentation/swift_standard_library
```

### Step 2: Navigate to Specific APIs

**Find specific classes/functions:**

```
# TimelineProvider (WidgetKit)
https://sosumi.ai/documentation/widgetkit/timelineprovider

# View (SwiftUI)
https://sosumi.ai/documentation/swiftui/view

# UIViewController
https://sosumi.ai/documentation/uikit/uiviewcontroller

# UserDefaults
https://sosumi.ai/documentation/foundation/userdefaults

# Async/await
https://sosumi.ai/documentation/swift/swift_standard_library/concurrency
```

### Step 3: Use with WebFetch Tool

**Fetch documentation programmatically:**

```typescript
// Example: Fetch WidgetKit TimelineProvider docs
const docs = await webFetch({
  url: 'https://sosumi.ai/documentation/widgetkit/timelineprovider',
  prompt: 'Explain how to implement TimelineProvider for widgets'
});
```

**Common queries:**

```typescript
// SwiftUI View documentation
webFetch({
  url: 'https://sosumi.ai/documentation/swiftui/view',
  prompt: 'Show me all View modifiers for layout'
});

// Widget timeline policies
webFetch({
  url: 'https://sosumi.ai/documentation/widgetkit/timelinereloadpolicy',
  prompt: 'Explain timeline reload policies'
});

// App Groups
webFetch({
  url: 'https://sosumi.ai/documentation/foundation/userdefaults',
  prompt: 'How to use UserDefaults with app groups'
});
```

### Step 4: Search Documentation

**sosumi.ai provides search:**

```
# Search for "widget timeline"
https://sosumi.ai/search?q=widget+timeline

# Search for "SwiftUI animation"
https://sosumi.ai/search?q=SwiftUI+animation

# Search for "async await"
https://sosumi.ai/search?q=async+await
```

### Step 5: Use in Skills Workflow

**Integrate with Swift skills:**

When building widgets (see `swift-widgets` skill):

```swift
// Need TimelineProvider reference?
// Fetch: https://sosumi.ai/documentation/widgetkit/timelineprovider

struct Provider: TimelineProvider {
    // Implementation based on sosumi.ai docs
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // ...
    }
}
```

When debugging (see `swift-debugging` skill):

```swift
// Need LLDB command reference?
// Fetch: https://sosumi.ai/documentation/xcode/debugging

// Or Swift error handling
// Fetch: https://sosumi.ai/documentation/swift/error-handling
```

### Step 6: Cache Documentation Locally

**For frequently used docs:**

```bash
# Create references directory in skill
mkdir -p swift-widgets/references/apple-docs

# Fetch and save commonly used docs
curl https://sosumi.ai/documentation/widgetkit > references/apple-docs/widgetkit.md
curl https://sosumi.ai/documentation/swiftui/view > references/apple-docs/view.md
```

### Step 7: Model Context Protocol (MCP) Integration

**If using Claude Desktop/Cursor/VS Code:**

sosumi.ai provides MCP server with tools:
- `searchAppleDocumentation` - Search with structured results
- `fetchAppleDocumentation` - Retrieve specific content by path

**Example MCP usage (if supported):**

```json
{
  "mcpServers": {
    "sosumi": {
      "command": "npx",
      "args": ["@sosumi/mcp-server"]
    }
  }
}
```

## Guidelines

**Do:**
- Use sosumi.ai instead of trying to fetch developer.apple.com
- Cache frequently used documentation locally
- Reference specific API paths for accuracy
- Combine with `swift-widgets` and `swift-debugging` skills
- Respect sosumi.ai rate limits
- Comply with Apple's Terms of Use

**Don't:**
- Don't try to scrape developer.apple.com directly (won't work)
- Don't bulk-download entire documentation
- Don't cache excessively (use on-demand)
- Don't redistribute cached documentation
- Don't skip reading actual documentation (sosumi.ai helps fetch it)

## Examples

### Find WidgetKit Timeline API

```
# Search for timeline documentation
URL: https://sosumi.ai/search?q=widgetkit+timeline

# Get TimelineProvider reference
URL: https://sosumi.ai/documentation/widgetkit/timelineprovider

# Get TimelineReloadPolicy
URL: https://sosumi.ai/documentation/widgetkit/timelinereloadpolicy
```

### SwiftUI View Modifiers

```
# SwiftUI View protocol
URL: https://sosumi.ai/documentation/swiftui/view

# Common modifiers
URL: https://sosumi.ai/documentation/swiftui/view/padding
URL: https://sosumi.ai/documentation/swiftui/view/frame
URL: https://sosumi.ai/documentation/swiftui/view/background
```

### Async/Await in Swift

```
# Swift concurrency
URL: https://sosumi.ai/documentation/swift/swift_standard_library/concurrency

# async keyword
URL: https://sosumi.ai/search?q=async+function

# Task
URL: https://sosumi.ai/documentation/swift/task
```

### UserDefaults and App Groups

```
# UserDefaults
URL: https://sosumi.ai/documentation/foundation/userdefaults

# Search for App Groups
URL: https://sosumi.ai/search?q=app+groups
```

## Resources

- [sosumi.ai](https://sosumi.ai/) - AI-readable Apple documentation
- [swift-widgets Skill](../swift-widgets/SKILL.md) - Widget development
- [swift-debugging Skill](../swift-debugging/SKILL.md) - Xcode debugging
- [Apple Developer](https://developer.apple.com/) - Original documentation
- [Apple Documentation Archive](https://developer.apple.com/documentation/)

## Tools & Commands

- `https://sosumi.ai/documentation/[framework]` - Fetch framework docs
- `https://sosumi.ai/search?q=[query]` - Search documentation
- `curl https://sosumi.ai/[path]` - Fetch docs via CLI
- MCP tools (if available): `searchAppleDocumentation`, `fetchAppleDocumentation`

## Troubleshooting

### sosumi.ai returns 404

**Problem**: URL not found on sosumi.ai

**Solution**:
```
# 1. Check URL path matches Apple's structure
# Original: https://developer.apple.com/documentation/widgetkit/timelineprovider
# sosumi.ai: https://sosumi.ai/documentation/widgetkit/timelineprovider

# 2. Try searching instead
https://sosumi.ai/search?q=TimelineProvider

# 3. Use lowercase paths
https://sosumi.ai/documentation/widgetkit (✅)
https://sosumi.ai/documentation/WidgetKit (❌)
```

### Rate limited

**Problem**: Too many requests to sosumi.ai

**Solution**:
```bash
# 1. Cache documentation locally
curl https://sosumi.ai/documentation/widgetkit > widgetkit-docs.md

# 2. Slow down requests
# Don't bulk-download - use on-demand

# 3. Use MCP server (handles rate limiting)
```

### Documentation outdated

**Problem**: sosumi.ai docs seem old

**Solution**:
```
# sosumi.ai renders on-demand, should be current
# Check Apple's original docs to compare versions:
https://developer.apple.com/documentation/widgetkit

# If mismatch, report to sosumi.ai
```

### Can't find specific API

**Problem**: Looking for specific class/method

**Solution**:
```
# 1. Use search
https://sosumi.ai/search?q=your+query

# 2. Navigate from framework root
https://sosumi.ai/documentation/widgetkit → find links

# 3. Check Apple docs for exact path
developer.apple.com/documentation/[framework]/[class]
↓
sosumi.ai/documentation/[framework]/[class]
```

---

## Notes

- sosumi.ai solves "This page requires JavaScript" problem
- Converts Apple docs to AI-readable Markdown
- Not affiliated with Apple (independent service)
- Rate limiting in place - don't abuse
- MCP integration available for supported editors
- On-demand rendering (not bulk-scraped)
- Respect Apple's Terms of Use
- Combine with swift-widgets, swift-debugging skills
- Essential for Swift development with AI agents
- Alternative: Use offline documentation (Dash app)
