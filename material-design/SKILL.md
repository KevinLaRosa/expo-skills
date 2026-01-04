---
name: material-design
description: Design Android apps following Material Design 3 (Material You) guidelines with dynamic color, adaptive layouts, and accessible components for native Android experiences
license: MIT
compatibility: "Requires: Basic understanding of Android design patterns, Jetpack Compose (optional)"
---

# Material Design

## Overview

Follow Material Design 3 (Material You) guidelines to create Android apps with dynamic theming, expressive components, and adaptive layouts that feel native to the Android ecosystem.

## When to Use This Skill

- Designing new Android app interfaces with Jetpack Compose or React Native
- Implementing Material Design 3 (Material You) theming
- Choosing colors, typography, or components for Android apps
- Ensuring accessibility compliance (TalkBack, large text, touch targets)
- When app doesn't feel "Android-native" compared to Google apps
- Implementing dynamic color (user wallpaper theming)
- Making design decisions for navigation patterns (bottom nav, nav drawer, nav rail)
- Reviewing designs for Google Play Store submission

## Workflow

### Step 1: Understand Material Design 3 Principles

**Core Concepts:**

1. **Expressive** - Dynamic color derived from user's wallpaper
2. **Adaptive** - Layouts adjust to screen size and device type
3. **Accessible** - Touch targets, contrast, and assistive technology support

**Material You (M3) vs Material 2:**
- **Dynamic color** - System generates color scheme from wallpaper
- **Larger touch targets** - 48dp minimum (up from 40dp)
- **Updated components** - Rounded corners, larger surfaces
- **New tokens** - Color roles (primary, secondary, tertiary)

### Step 2: Implement Color System

**Material 3 Color Roles:**

```kotlin
// Jetpack Compose
import androidx.compose.material3.*

MaterialTheme.colorScheme.primary          // Primary brand color
MaterialTheme.colorScheme.onPrimary        // Text/icons on primary
MaterialTheme.colorScheme.primaryContainer // Tinted container
MaterialTheme.colorScheme.secondary        // Accent color
MaterialTheme.colorScheme.tertiary         // Contrasting accent
MaterialTheme.colorScheme.surface          // Background surfaces
MaterialTheme.colorScheme.surfaceVariant   // Subtle variation
MaterialTheme.colorScheme.error            // Error states
```

**Dynamic Color (Android 12+):**
```kotlin
val dynamicColorScheme = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    if (darkTheme) dynamicDarkColorScheme(context)
    else dynamicLightColorScheme(context)
} else {
    // Fallback to static color scheme
    if (darkTheme) darkColorScheme() else lightColorScheme()
}

MaterialTheme(
    colorScheme = dynamicColorScheme,
    content = content
)
```

**Generate Color Scheme:**
- Use [Material Theme Builder](https://m3.material.io/theme-builder)
- Export to Jetpack Compose or XML
- Automatically generates light/dark variants and all color roles

### Step 3: Apply Typography Scale

**Material 3 Type Scale:**

```kotlin
// Jetpack Compose
MaterialTheme.typography.displayLarge      // 57sp (96sp M2)
MaterialTheme.typography.displayMedium     // 45sp (60sp M2)
MaterialTheme.typography.displaySmall      // 36sp (48sp M2)
MaterialTheme.typography.headlineLarge     // 32sp
MaterialTheme.typography.headlineMedium    // 28sp
MaterialTheme.typography.headlineSmall     // 24sp
MaterialTheme.typography.titleLarge        // 22sp
MaterialTheme.typography.titleMedium       // 16sp
MaterialTheme.typography.titleSmall        // 14sp
MaterialTheme.typography.bodyLarge         // 16sp
MaterialTheme.typography.bodyMedium        // 14sp
MaterialTheme.typography.bodySmall         // 12sp
MaterialTheme.typography.labelLarge        // 14sp (buttons)
MaterialTheme.typography.labelMedium       // 12sp
MaterialTheme.typography.labelSmall        // 11sp
```

**Default Fonts:**
- **Roboto** - Standard Android font
- **Roboto Flex** - Variable font with customizable weight/width
- Use Google Fonts API for custom fonts

### Step 4: Choose Navigation Pattern

**Bottom Navigation Bar:**
- 3-5 top-level destinations
- Icons + labels (or icons only)
- Use for: Phone portrait mode, main app sections

```kotlin
NavigationBar {
    items.forEach { item ->
        NavigationBarItem(
            icon = { Icon(item.icon, contentDescription = null) },
            label = { Text(item.label) },
            selected = selectedItem == item,
            onClick = { selectedItem = item }
        )
    }
}
```

**Navigation Drawer:**
- 5+ top-level destinations
- Appears from left edge (or right for RTL)
- Use for: Apps with many sections

```kotlin
ModalNavigationDrawer(
    drawerContent = {
        ModalDrawerSheet {
            items.forEach { item ->
                NavigationDrawerItem(
                    label = { Text(item.label) },
                    selected = selectedItem == item,
                    onClick = { selectedItem = item }
                )
            }
        }
    }
) {
    Content()
}
```

**Navigation Rail (Tablet/Desktop):**
- Persistent vertical navigation
- Icons + optional labels
- Use for: Tablet landscape, large screens

```kotlin
Row {
    NavigationRail {
        items.forEach { item ->
            NavigationRailItem(
                icon = { Icon(item.icon, contentDescription = item.label) },
                label = { Text(item.label) },
                selected = selectedItem == item,
                onClick = { selectedItem = item }
            )
        }
    }
    Content()
}
```

**Top App Bar:**
```kotlin
TopAppBar(
    title = { Text("Title") },
    navigationIcon = {
        IconButton(onClick = { /* Back */ }) {
            Icon(Icons.Default.ArrowBack, contentDescription = "Back")
        }
    },
    actions = {
        IconButton(onClick = { /* Action */ }) {
            Icon(Icons.Default.Search, contentDescription = "Search")
        }
    }
)
```

### Step 5: Use Material Components

**Buttons:**

```kotlin
// Filled button (primary action)
Button(onClick = { }) {
    Text("Continue")
}

// Filled tonal button (secondary action)
FilledTonalButton(onClick = { }) {
    Text("Save")
}

// Outlined button
OutlinedButton(onClick = { }) {
    Text("Cancel")
}

// Text button (tertiary action)
TextButton(onClick = { }) {
    Text("Skip")
}

// Floating Action Button
FloatingActionButton(onClick = { }) {
    Icon(Icons.Default.Add, contentDescription = "Add")
}

// Extended FAB
ExtendedFloatingActionButton(
    onClick = { },
    icon = { Icon(Icons.Default.Add, contentDescription = null) },
    text = { Text("New Message") }
)
```

**Cards:**

```kotlin
Card(
    onClick = { },
    modifier = Modifier.fillMaxWidth()
) {
    Column(Modifier.padding(16.dp)) {
        Text("Title", style = MaterialTheme.typography.headlineSmall)
        Text("Subtitle", style = MaterialTheme.typography.bodyMedium)
    }
}

// Elevated Card
ElevatedCard { }

// Outlined Card
OutlinedCard { }
```

**Dialogs:**

```kotlin
AlertDialog(
    onDismissRequest = { },
    title = { Text("Delete item?") },
    text = { Text("This action cannot be undone") },
    confirmButton = {
        TextButton(onClick = { }) {
            Text("Delete")
        }
    },
    dismissButton = {
        TextButton(onClick = { }) {
            Text("Cancel")
        }
    }
)
```

**Snackbars:**

```kotlin
val snackbarHostState = remember { SnackbarHostState() }
val scope = rememberCoroutineScope()

Scaffold(
    snackbarHost = { SnackbarHost(snackbarHostState) }
) { padding ->
    Button(onClick = {
        scope.launch {
            snackbarHostState.showSnackbar(
                message = "Item deleted",
                actionLabel = "Undo",
                duration = SnackbarDuration.Short
            )
        }
    }) {
        Text("Show Snackbar")
    }
}
```

### Step 6: Implement Elevation and Surfaces

**Material 3 Elevation:**
- Uses **tonal elevation** (surface tint) instead of shadows
- Higher elevation = more surface tint color

```kotlin
Surface(
    tonalElevation = 2.dp,  // Subtle tint
    modifier = Modifier.fillMaxWidth()
) {
    Text("Content", Modifier.padding(16.dp))
}

// Standard elevation levels
0.dp   // Level 0 - Default surface
1.dp   // Level 1 - Cards at rest
3.dp   // Level 2 - Cards raised
6.dp   // Level 3 - Dialogs
8.dp   // Level 4 - Navigation drawer
12.dp  // Level 5 - FAB
```

### Step 7: Support Accessibility

**Touch Targets:**
- Minimum 48dp × 48dp (Material 3)
- Add padding to increase touch area:

```kotlin
IconButton(
    onClick = { },
    modifier = Modifier.size(48.dp)  // Ensures minimum touch target
) {
    Icon(Icons.Default.Favorite, contentDescription = "Favorite")
}
```

**Content Descriptions:**
```kotlin
// Always provide for icon-only buttons
Icon(
    Icons.Default.Search,
    contentDescription = "Search"
)

// Hide decorative icons
Icon(
    Icons.Default.Star,
    contentDescription = null  // Decorative only
)
```

**Color Contrast:**
- 4.5:1 for body text (WCAG AA)
- 3:1 for large text (18sp+)
- Material Theme Builder generates accessible color pairings

**TalkBack Support:**
```kotlin
// Merge elements for better TalkBack experience
Row(Modifier.semantics(mergeDescendants = true) {}) {
    Icon(Icons.Default.Star, contentDescription = null)
    Text("Favorite")
}

// Custom actions
Modifier.semantics {
    customActions = listOf(
        CustomAccessibilityAction("Delete") {
            deleteItem()
            true
        }
    )
}
```

### Step 8: Create Adaptive Layouts

**Window Size Classes:**

```kotlin
@OptIn(ExperimentalMaterial3WindowSizeClassApi::class)
@Composable
fun AdaptiveLayout() {
    val windowSizeClass = calculateWindowSizeClass(this)

    when (windowSizeClass.widthSizeClass) {
        WindowWidthSizeClass.Compact -> {
            // Phone portrait
            BottomNavigationLayout()
        }
        WindowWidthSizeClass.Medium -> {
            // Phone landscape, small tablet
            NavigationRailLayout()
        }
        WindowWidthSizeClass.Expanded -> {
            // Large tablet, foldable unfolded
            NavigationDrawerLayout()
        }
    }
}
```

**Responsive Grid:**
```kotlin
LazyVerticalGrid(
    columns = GridCells.Adaptive(minSize = 150.dp)
) {
    items(photos) { photo ->
        PhotoCard(photo)
    }
}
```

## Guidelines

**Do:**
- Use Material 3 components from `androidx.compose.material3`
- Implement dynamic color (Android 12+)
- Support light and dark themes
- Ensure 48dp minimum touch targets
- Use Material Theme Builder to generate color schemes
- Provide content descriptions for all interactive elements
- Test with TalkBack enabled
- Use standard navigation patterns (bottom nav, drawer, rail)
- Implement adaptive layouts for tablets/foldables
- Use tonal elevation (M3) instead of shadows (M2)
- Follow 8dp grid for spacing

**Don't:**
- Don't use iOS design patterns (tab bars at bottom with 5 items, swipe back gesture)
- Don't use `androidx.compose.material` (Material 2) - use `material3` instead
- Don't hardcode colors - use `MaterialTheme.colorScheme`
- Don't use small touch targets (<48dp)
- Don't ignore dark theme support
- Don't forget content descriptions for icon-only buttons
- Don't use more than 5 bottom navigation items
- Don't ignore window size classes on tablets/foldables
- Don't use deprecated Material 2 components (Scaffold from material, not material3)
- Don't mix Material 2 and Material 3 components

## Examples

### Example 1: Material 3 Theme Setup

```kotlin
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import android.os.Build

@Composable
fun MyAppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val context = LocalContext.current

    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            if (darkTheme) dynamicDarkColorScheme(context)
            else dynamicLightColorScheme(context)
        }
        darkTheme -> darkColorScheme(
            primary = Color(0xFFBB86FC),
            secondary = Color(0xFF03DAC6),
            tertiary = Color(0xFF3700B3)
        )
        else -> lightColorScheme(
            primary = Color(0xFF6200EE),
            secondary = Color(0xFF03DAC6),
            tertiary = Color(0xFF3700B3)
        )
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
```

### Example 2: Scaffold with Navigation

```kotlin
import androidx.compose.material3.*
import androidx.compose.runtime.*

@Composable
fun MainScreen() {
    var selectedItem by remember { mutableStateOf(0) }
    val items = listOf("Home", "Search", "Profile")

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("App Title") }
            )
        },
        bottomBar = {
            NavigationBar {
                items.forEachIndexed { index, item ->
                    NavigationBarItem(
                        icon = { Icon(Icons.Default.Home, contentDescription = item) },
                        label = { Text(item) },
                        selected = selectedItem == index,
                        onClick = { selectedItem = index }
                    )
                }
            }
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { }) {
                Icon(Icons.Default.Add, contentDescription = "Add")
            }
        }
    ) { paddingValues ->
        // Content
        Box(Modifier.padding(paddingValues)) {
            when (selectedItem) {
                0 -> HomeScreen()
                1 -> SearchScreen()
                2 -> ProfileScreen()
            }
        }
    }
}
```

### Example 3: Adaptive Layout with Window Size Classes

```kotlin
import androidx.compose.material3.adaptive.currentWindowAdaptiveInfo
import androidx.window.core.layout.WindowWidthSizeClass

@Composable
fun AdaptiveNavigation() {
    val adaptiveInfo = currentWindowAdaptiveInfo()

    when (adaptiveInfo.windowSizeClass.windowWidthSizeClass) {
        WindowWidthSizeClass.COMPACT -> {
            // Phone - Bottom Navigation
            Scaffold(
                bottomBar = { BottomNavigationBar() }
            ) { Content() }
        }

        WindowWidthSizeClass.MEDIUM -> {
            // Tablet portrait - Navigation Rail
            Row {
                NavigationRail { NavigationRailContent() }
                Content()
            }
        }

        WindowWidthSizeClass.EXPANDED -> {
            // Tablet landscape - Permanent Drawer
            PermanentNavigationDrawer(
                drawerContent = { DrawerContent() }
            ) {
                Content()
            }
        }
    }
}
```

### Example 4: Card with Tonal Elevation

```kotlin
import androidx.compose.material3.*
import androidx.compose.foundation.layout.*

@Composable
fun ProductCard(product: Product) {
    ElevatedCard(
        onClick = { },
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Column(Modifier.padding(16.dp)) {
            Text(
                text = product.name,
                style = MaterialTheme.typography.headlineSmall,
                color = MaterialTheme.colorScheme.onSurface
            )

            Spacer(Modifier.height(8.dp))

            Text(
                text = product.description,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(Modifier.height(16.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "$${product.price}",
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.primary
                )

                Button(onClick = { }) {
                    Text("Add to Cart")
                }
            }
        }
    }
}
```

### Example 5: Dialog with Material 3

```kotlin
import androidx.compose.material3.*

@Composable
fun ConfirmDeleteDialog(
    onDismiss: () -> Unit,
    onConfirm: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        icon = {
            Icon(Icons.Default.Delete, contentDescription = null)
        },
        title = {
            Text("Delete item?")
        },
        text = {
            Text("This action cannot be undone. The item will be permanently deleted.")
        },
        confirmButton = {
            TextButton(
                onClick = onConfirm,
                colors = ButtonDefaults.textButtonColors(
                    contentColor = MaterialTheme.colorScheme.error
                )
            ) {
                Text("Delete")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
```

## Resources

- [Material Design 3](https://m3.material.io/)
- [Material Theme Builder](https://m3.material.io/theme-builder) - Generate color schemes
- [Material 3 Components](https://m3.material.io/components)
- [Jetpack Compose Material 3](https://developer.android.com/jetpack/compose/designsystems/material3)
- [Material Icons](https://fonts.google.com/icons)
- [Adaptive Layouts](https://developer.android.com/jetpack/compose/layouts/adaptive)
- [Accessibility in Compose](https://developer.android.com/jetpack/compose/accessibility)

## Tools & Commands

- **Material Theme Builder** - Generate dynamic color schemes
- **Figma Material 3 Kit** - Design with official components
- **TalkBack** - Android screen reader (Settings → Accessibility)
- **Layout Inspector** - Android Studio → View → Tool Windows → Layout Inspector
- **Color Contrast Checker** - [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

## Troubleshooting

### Dynamic color not working

**Problem**: App doesn't use wallpaper colors on Android 12+

**Solution**:
```kotlin
// Ensure Android 12+ check
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    dynamicLightColorScheme(context)
}

// Provide fallback for older Android versions
else {
    lightColorScheme(...)
}
```

### Components look like Material 2

**Problem**: Using old Material Design 2 components

**Solution**:
```kotlin
// ❌ Material 2
import androidx.compose.material.Button
import androidx.compose.material.Scaffold

// ✅ Material 3
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
```

### Touch targets too small

**Problem**: Buttons/icons don't meet 48dp minimum

**Solution**:
```kotlin
// Ensure minimum touch target
IconButton(
    onClick = { },
    modifier = Modifier.size(48.dp)  // or larger
) {
    Icon(icon, contentDescription = "...")
}
```

### Layout doesn't adapt to tablet

**Problem**: Phone layout on tablet/foldable

**Solution**:
```kotlin
// Use window size classes
val windowSizeClass = calculateWindowSizeClass(this)

when (windowSizeClass.widthSizeClass) {
    WindowWidthSizeClass.Compact -> PhoneLayout()
    WindowWidthSizeClass.Medium -> TabletPortraitLayout()
    WindowWidthSizeClass.Expanded -> TabletLandscapeLayout()
}
```

### Dark theme colors incorrect

**Problem**: Poor contrast in dark mode

**Solution**:
1. Use Material Theme Builder to generate accessible dark scheme
2. Never hardcode colors - use `MaterialTheme.colorScheme`
3. Test with Settings → Developer Options → Dark Mode
