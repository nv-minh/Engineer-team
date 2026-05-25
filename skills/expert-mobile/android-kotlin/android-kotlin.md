---
name: android-kotlin
description: >
  Native Android development with Kotlin — Jetpack Compose, ViewModels, Navigation component,
  MVVM architecture, and Gradle configuration.
version: "3.0.0"
category: "expert-mobile"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["android", "kotlin", "jetpack compose", "android viewmodel", "gradle android", "android MVVM"]
intent: >
  Guide native Android development with Kotlin and Jetpack. Covers MVVM architecture,
  Jetpack Compose UI, ViewModels with StateFlow, and Navigation component.
scenarios:
  - "Building native Android apps with Kotlin and Jetpack Compose"
  - "Implementing MVVM architecture with ViewModel and StateFlow"
  - "Configuring Gradle build variants and signing"
best_for: "Native Android apps, Jetpack Compose UI, MVVM architecture, Gradle builds"
estimated_time: "15-60 min"
anti_patterns:
  - "Using findViewById — use ViewBinding or Compose"
  - "Leaking activities through coroutine scopes — use viewModelScope"
  - "Ignoring process death — save state with SavedStateHandle"
  - "Business logic in Activity/Fragment — move to ViewModel"
related_skills: ["flutter", "ios-swift"]

input_schema:
  type: object
  required: [task_description]
  properties:
    task_description:
      type: string
      description: "What to implement, review, or investigate"
    context:
      type: object
      description: "Project context — existing code, tech stack, constraints"
    mode:
      type: string
      enum: [implement, review, investigate, advise]
      default: implement
      description: "Execution mode"

output_schema:
  type: object
  required: [status, implementation]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    implementation:
      type: object
      description: "Implementation details, code, or analysis results"
    patterns_applied:
      type: array
      items: { type: string }
      description: "Patterns and best practices used"
    recommendations:
      type: array
      items:
        type: object
        properties:
          priority: { type: string, enum: [high, medium, low] }
          action: { type: string }
          reasoning: { type: string }

error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Android Kotlin

[ROLE]
Act as an Android expert. Deliver MVVM architecture with Jetpack Compose, ViewModels with StateFlow, and proper coroutine scoping.

[OBJECTIVE]
Build Android applications with MVVM architecture where business logic lives in ViewModels, UI uses Jetpack Compose with StateFlow, and coroutines use viewModelScope.

[RULES]
1. <thought>Before writing any Android code, determine: Is this UI (Composable), logic (ViewModel), or data (Repository)? Should state survive process death (SavedStateHandle)?</thought>
2. Use `viewModelScope` for all coroutines tied to ViewModel lifecycle.
3. Use StateFlow (not LiveData) for reactive state in new code.
4. Prefer Jetpack Compose over XML layouts for new projects.
5. Apply ProGuard/R8 for release builds — keep signing keys secure.
6. DO NOT use findViewById — use ViewBinding or Compose.
7. DO NOT leak activities through coroutine scopes — use viewModelScope.
8. DO NOT put business logic in Activity/Fragment — use ViewModel.
9. DO NOT use GlobalScope for coroutines.
10. Use Hilt for dependency injection.
11. Use `libs.versions.toml` for centralized dependency management.
12. ABC: StateFlow is the modern replacement for LiveData — it integrates naturally with coroutines and Compose.

[PROCESS]

### ViewModel with StateFlow

```kotlin
class MainViewModel : ViewModel() {
    private val _items = MutableStateFlow<List<Item>>(emptyList())
    val items: StateFlow<List<Item>> = _items.asStateFlow()

    fun loadItems() {
        viewModelScope.launch {
            _items.value = repository.getItems()
        }
    }
}
```

### Jetpack Compose UI

```kotlin
@Composable
fun ItemList(viewModel: MainViewModel = viewModel()) {
    val items by viewModel.items.collectAsState()
    LazyColumn {
        items(items, key = { it.id }) { item ->
            ItemRow(item = item)
        }
    }
}
```

### Navigation

```kotlin
NavHost(navController, startDestination = "home") {
    composable("home") { HomeScreen(onItemClick = { id -> navController.navigate("details/$id") }) }
    composable("details/{id}") { DetailScreen(it.arguments?.getString("id")!!) }
}
```

### Verification

- [ ] ViewModel used for all business logic
- [ ] StateFlow for reactive state
- [ ] Navigation handles back stack correctly
- [ ] ProGuard/R8 enabled for release builds
- [ ] Coroutines use viewModelScope

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
