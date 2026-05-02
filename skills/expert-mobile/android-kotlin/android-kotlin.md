---
name: android-kotlin
description: >
  Native Android development with Kotlin — Activities, Fragments, Jetpack Compose,
  ViewModels, Navigation component, MVVM architecture, and Gradle configuration.
  Use when building native Android applications.
version: "1.0.0"
category: "expert-mobile"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "android"
  - "kotlin"
  - "jetpack compose"
  - "android viewmodel"
  - "gradle android"
  - "android MVVM"
intent: >
  Guide native Android development with Kotlin and Jetpack. Covers MVVM architecture,
  Jetpack Compose UI, ViewModels with StateFlow, Navigation component, and Gradle
  build configuration.
scenarios:
  - "Building native Android apps with Kotlin and Jetpack Compose"
  - "Implementing MVVM architecture with ViewModel and StateFlow"
  - "Configuring Gradle build variants, dependencies, and signing"
  - "Setting up Navigation component for multi-screen apps"
  - "Managing Android lifecycle with Fragments and ViewModels"
  - "Preparing APK/AAB for Play Store release with ProGuard/R8"
best_for: "Native Android apps, Jetpack Compose UI, MVVM architecture, Gradle builds"
estimated_time: "15-60 min"
anti_patterns:
  - "Using findViewById — use ViewBinding or Compose"
  - "Leaking activities through coroutine scopes — use viewModelScope"
  - "Ignoring process death — save state with SavedStateHandle"
  - "Not applying ProGuard/R8 for release builds"
  - "Business logic in Activity/Fragment — move to ViewModel"
related_skills: ["flutter", "ios-swift"]
---

# Android Kotlin

## Overview

Native Android development with Kotlin, Jetpack libraries, and Material Design. Modern Android uses MVVM architecture with Jetpack Compose for declarative UI, ViewModels for state management, and Kotlin coroutines for async work.

## When to Use

- Building native Android applications requiring full platform access
- Implementing Material Design 3 UI with Jetpack Compose
- Creating apps with complex lifecycle requirements (Fragments, Navigation)
- Integrating Android-specific APIs (sensors, camera, notifications)

## When NOT to Use

- Cross-platform apps where Flutter or React Native suffice
- Server-side Kotlin (use Spring Boot skill instead)
- Simple utility apps that could be PWAs

## Process

### 1. Project Setup

```kotlin
// build.gradle.kts (app module)
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0")
    implementation("androidx.navigation:navigation-fragment-ktx:2.7.6")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.compose.ui:ui:1.6.0")
    implementation("androidx.compose.material3:material3:1.2.0")
}
```

### 2. MVVM Architecture

**ViewModel with StateFlow:**

```kotlin
class MainViewModel : ViewModel() {
    private val _items = MutableStateFlow<List<Item>>(emptyList())
    val items: StateFlow<List<Item>> = _items.asStateFlow()

    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean> = _loading.asStateFlow()

    fun loadItems() {
        viewModelScope.launch {
            _loading.value = true
            _items.value = repository.getItems()
            _loading.value = false
        }
    }
}
```

**Repository pattern:**

```kotlin
class ItemRepository @Inject constructor(
    private val api: ItemApi,
    private val dao: ItemDao
) {
    suspend fun getItems(): List<Item> {
        return try {
            val remote = api.getItems()
            dao.insertAll(remote)
            remote
        } catch (e: Exception) {
            dao.getAll()
        }
    }
}
```

### 3. Jetpack Compose UI

```kotlin
@Composable
fun ItemList(viewModel: MainViewModel = viewModel()) {
    val items by viewModel.items.collectAsState()
    val loading by viewModel.loading.collectAsState()

    if (loading) {
        CircularProgressIndicator()
    } else {
        LazyColumn {
            items(items, key = { it.id }) { item ->
                ItemRow(item = item, onClick = { /* navigate */ })
            }
        }
    }
}

@Composable
fun ItemRow(item: Item, onClick: () -> Unit) {
    Card(modifier = Modifier.fillMaxWidth().padding(8.dp)) {
        Row(modifier = Modifier.padding(16.dp)) {
            Text(item.name, style = MaterialTheme.typography.titleMedium)
        }
    }
}
```

### 4. Navigation

```kotlin
// Compose Navigation
NavHost(navController, startDestination = "home") {
    composable("home") { HomeScreen(onItemClick = { id ->
        navController.navigate("details/$id")
    })}
    composable("details/{id}", arguments = listOf(navArgument("id") { type = NavType.StringType })) {
        val id = it.arguments?.getString("id") ?: return@composable
        DetailScreen(id)
    }
}
```

### 5. Gradle Configuration

```kotlin
// Signing config for release
android {
    signingConfigs {
        create("release") {
            storeFile = file("keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = "release"
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }
}
```

## Best Practices

- Use `viewModelScope` for coroutines tied to ViewModel lifecycle
- Save UI state with `SavedStateHandle` for process death recovery
- Prefer Jetpack Compose over XML layouts for new projects
- Apply ProGuard/R8 for release builds; keep signing keys secure
- Write tests with `@RunWith(AndroidJUnit4::class)` and Espresso

## Coaching Notes

- **Compose vs XML**: New projects should use Compose. Existing XML projects can mix Compose with `ComposeView` interop
- **StateFlow vs LiveData**: StateFlow is the modern replacement — it integrates naturally with coroutines and Compose
- **Hilt for DI**: Use Hilt (built on Dagger) for dependency injection; it generates less boilerplate than manual Dagger
- **Gradle Version Catalogs**: Use `libs.versions.toml` for centralized dependency management

## Verification

- [ ] ViewModel used for all business logic (none in Activity/Fragment)
- [ ] StateFlow or SharedFlow for reactive state (not LiveData for new code)
- [ ] Navigation component handles back stack correctly
- [ ] ProGuard/R8 enabled for release builds
- [ ] Coroutines use viewModelScope (not GlobalScope)

## Related Skills

- **flutter** — Cross-platform alternative with Dart
- **ios-swift** — Native iOS counterpart for cross-platform teams
