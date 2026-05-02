---
name: flutter
description: >
  Flutter cross-platform development — widgets, state management, navigation,
  platform channels, performance optimization, and hot reload workflow.
  Use when building mobile, web, or desktop apps with Flutter/Dart.
version: "1.0.0"
category: "expert-mobile"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "flutter"
  - "dart"
  - "cross-platform mobile"
  - "flutter widget"
  - "flutter state management"
  - "flutter navigation"
  - "flutter hot reload"
intent: >
  Guide Flutter development from project setup through production. Covers widget
  composition, state management strategies, navigation patterns, platform interop,
  and performance tuning.
scenarios:
  - "Building cross-platform mobile apps with shared Dart codebase"
  - "Implementing reactive UI with StatelessWidget and StatefulWidget"
  - "Choosing and applying state management (Provider, Riverpod, Bloc)"
  - "Setting up declarative routing with GoRouter or Navigator 2.0"
  - "Calling native platform APIs via platform channels"
  - "Optimizing widget rebuilds and profiling performance"
best_for: "Cross-platform mobile/web/desktop apps, Material and Cupertino UI, reactive widget trees"
estimated_time: "10-60 min"
anti_patterns:
  - "Giant build() methods — extract into smaller widgets"
  - "setState for app-wide state — use Provider/Riverpod/Bloc instead"
  - "Ignoring const constructors — always use const where possible"
  - "Not testing on both iOS and Android — platform differences matter"
  - "Synchronous platform channel calls — use async MethodChannel"
related_skills: ["react-native", "android-kotlin", "ios-swift"]
---

# Flutter

## Overview

Flutter development for cross-platform mobile, web, and desktop applications using Dart. Widget-based UI framework with hot reload for rapid iteration. Supports Material Design and Cupertino (iOS-style) widgets.

## When to Use

- Building cross-platform apps from a single Dart codebase
- Creating reactive UIs with composable widgets
- Implementing complex state management flows
- Calling native platform APIs (camera, sensors, storage)
- Prototyping UI rapidly with hot reload

## When NOT to Use

- Pure native performance-critical apps (use android-kotlin or ios-swift)
- Apps requiring heavy native UI components not available in Flutter
- When team has no Dart expertise and React Native is a better fit

## Process

### 1. Project Setup

```bash
flutter create my_app --org com.example --platforms android,ios
cd my_app
flutter run  # Hot reload enabled
```

### 2. Widget Composition

**StatelessWidget** — immutable, rebuilds when parent changes:

```dart
class UserCard extends StatelessWidget {
  final String name;
  final String email;
  const UserCard({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(name),
        subtitle: Text(email),
      ),
    );
  }
}
```

**StatefulWidget** — mutable, manages own state:

```dart
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(child: Text('Count: $_count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 3. State Management Strategy

| Scale | Solution | Use Case |
|-------|----------|----------|
| Local | `setState` | Single-widget state |
| Simple | `Provider` | Small-to-medium apps |
| Medium | `Riverpod` | Type-safe, testable state |
| Complex | `Bloc/Cubit` | Event-driven, enterprise apps |

**Provider example:**

```dart
// Define
final counterProvider = StateProvider<int>((ref) => 0);

// Consume (Riverpod)
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

### 4. Navigation

**Named routes (simple):**

```dart
MaterialApp(
  routes: {
    '/': (context) => const HomePage(),
    '/details': (context) => const DetailsPage(),
  },
);
Navigator.pushNamed(context, '/details');
```

**GoRouter (recommended for complex apps):**

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/details/:id', builder: (_, state) =>
      DetailsPage(id: state.pathParameters['id']!)),
  ],
);
```

### 5. Platform Channels

```dart
// Dart side
const platform = MethodChannel('com.example/channel');
final result = await platform.invokeMethod('getBatteryLevel');

// Android (Kotlin)
override fun onMethodCall(call: MethodCall, result: Result) {
  if (call.method == "getBatteryLevel") {
    result.success(batteryLevel)
  }
}
```

### 6. Performance

- Use `const` constructors to enable widget caching
- Use `Keys` on list items for correct reconciliation
- Avoid expensive operations in `build()` — move to `initState` or compute providers
- Use `RepaintBoundary` for frequently updating sub-trees
- Profile with `flutter run --profile` and DevTools

## Best Practices

- Split large widgets into small, focused, reusable components
- Choose ONE state management approach per project and stick with it
- Test on both iOS and Android; handle platform differences with `Platform.isIOS`
- Use `ThemeData` for consistent styling across the app
- Keep widget trees shallow — extract sub-trees into separate widgets

## Coaching Notes

- **const is free performance**: Every `const` constructor call is cached at compile time
- **Widget vs Element vs RenderObject**: Widgets are blueprints, Elements are instances, RenderObjects paint. Understanding this triage makes debugging layout issues faster
- **Hot reload vs Hot restart**: Hot reload preserves state; hot restart resets it. Use hot reload for UI tweaks, hot restart for state changes
- **Key discipline**: Always use `Key` in `ListView.builder` items; `ValueKey` for data-driven lists, `ObjectKey` for objects

## Verification

- [ ] All widgets use `const` constructors where possible
- [ ] State management is consistent (not mixing setState with Provider without reason)
- [ ] Navigation handles back button correctly on both platforms
- [ ] No expensive operations in `build()` methods
- [ ] App runs on both iOS and Android without platform errors

## Related Skills

- **react-native** — Alternative cross-platform framework (React-based)
- **android-kotlin** — Native Android for platform channel implementation
- **ios-swift** — Native iOS for platform channel implementation
