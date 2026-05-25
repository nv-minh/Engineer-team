---
name: flutter
description: >
  Flutter cross-platform development — widgets, state management, navigation,
  platform channels, performance optimization, and hot reload workflow.
version: "3.0.0"
category: "expert-mobile"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["flutter", "dart", "cross-platform mobile", "flutter widget", "flutter state management", "flutter navigation", "flutter hot reload"]
intent: >
  Guide Flutter development from project setup through production. Covers widget
  composition, state management strategies, navigation patterns, platform interop,
  and performance tuning.
scenarios:
  - "Building cross-platform mobile apps with shared Dart codebase"
  - "Choosing and applying state management (Provider, Riverpod, Bloc)"
  - "Calling native platform APIs via platform channels"
best_for: "Cross-platform mobile/web/desktop apps, Material and Cupertino UI, reactive widget trees"
estimated_time: "10-60 min"
anti_patterns:
  - "Giant build() methods — extract into smaller widgets"
  - "setState for app-wide state — use Provider/Riverpod/Bloc instead"
  - "Ignoring const constructors — always use const where possible"
  - "Not testing on both iOS and Android — platform differences matter"
  - "Synchronous platform channel calls — use async MethodChannel"
related_skills: ["react-native", "android-kotlin", "ios-swift"]

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

# Flutter

[ROLE]
Act as a Flutter expert. Deliver composable widget trees with `const` constructors, consistent state management, and platform-aware navigation.

[OBJECTIVE]
Build Flutter applications where widgets are small and focused, state management is consistent (one approach per project), and platform channels handle native integration asynchronously.

[RULES]
1. <thought>Before writing any widget, determine: Is this Stateless or Stateful? Can it use const? What state management approach does this project use?</thought>
2. Split large widgets into small, focused, reusable components.
3. Use `const` constructors everywhere possible — they are free performance.
4. Choose ONE state management approach per project (Provider, Riverpod, or Bloc).
5. Test on both iOS and Android — handle platform differences with `Platform.isIOS`.
6. DO NOT write giant build() methods — extract sub-widgets.
7. DO NOT use setState for app-wide state — use Provider/Riverpod/Bloc.
8. DO NOT ignore const constructors.
9. Use Keys on list items for correct reconciliation — `ValueKey` for data-driven lists.
10. Avoid expensive operations in `build()` — move to `initState` or compute providers.
11. Use `RepaintBoundary` for frequently updating sub-trees.
12. ABC: Widget vs Element vs RenderObject — Widgets are blueprints, Elements are instances, RenderObjects paint. Understanding this makes debugging layout issues faster.

[PROCESS]

### Widget Composition

```dart
class UserCard extends StatelessWidget {
  final String name;
  const UserCard({super.key, required this.name});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(title: Text(name)));
}
```

### State Management

| Scale | Solution | Use Case |
|-------|----------|----------|
| Local | `setState` | Single-widget state |
| Simple | `Provider` | Small-to-medium apps |
| Medium | `Riverpod` | Type-safe, testable state |
| Complex | `Bloc/Cubit` | Event-driven, enterprise apps |

### Navigation (GoRouter)

```dart
final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const HomePage()),
  GoRoute(path: '/details/:id', builder: (_, state) => DetailsPage(id: state.pathParameters['id']!)),
]);
```

### Platform Channels

```dart
const platform = MethodChannel('com.example/channel');
final result = await platform.invokeMethod('getBatteryLevel');
```

### Verification

- [ ] All widgets use `const` constructors where possible
- [ ] State management is consistent across the project
- [ ] Navigation handles back button on both platforms
- [ ] No expensive operations in `build()` methods
- [ ] App runs on both iOS and Android

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
