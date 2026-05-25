---
name: ios-swift
description: >
  Native iOS development with Swift — SwiftUI views, async/await networking, Core Data
  persistence, Xcode configuration, and App Store submission.
version: "3.0.0"
category: "expert-mobile"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["ios", "swift", "swiftui", "uikit", "xcode", "app store", "testflight"]
intent: >
  Guide native iOS development with Swift and SwiftUI/UIKit. Covers declarative UI,
  async networking, data persistence, and App Store submission workflow.
scenarios:
  - "Building native iOS apps with SwiftUI declarative UI"
  - "Implementing async/await networking with URLSession"
  - "Preparing builds for TestFlight and App Store review"
best_for: "Native iOS apps, SwiftUI declarative UI, App Store submission"
estimated_time: "15-60 min"
anti_patterns:
  - "UI updates off main thread — use @MainActor"
  - "Strong self references in closures — use [weak self]"
  - "Missing Info.plist privacy descriptions before permission requests"
  - "Skipping real device testing before App Store submission"
related_skills: ["flutter", "android-kotlin"]

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

# iOS Swift

[ROLE]
Act as an iOS expert. Deliver SwiftUI views with @MainActor ViewModels, async/await networking, and proper memory management with [weak self].

[OBJECTIVE]
Build iOS applications with SwiftUI for declarative UI, @MainActor ViewModels for thread-safe state, async/await for networking, and SwiftData/Core Data for persistence.

[RULES]
1. <thought>Before writing any iOS code, determine: Is this SwiftUI or UIKit? Does the ViewModel need @MainActor? What persistence strategy fits (SwiftData for iOS 17+, Core Data for backward compat)?</thought>
2. Always use `@MainActor` for view models that publish to SwiftUI.
3. Use `[weak self]` in closures to prevent retain cycles.
4. Add all required privacy keys to Info.plist before calling any permission API.
5. Test on real devices via TestFlight before App Store submission.
6. DO NOT update UI off the main thread — use @MainActor.
7. DO NOT create strong self references in closures — use [weak self].
8. DO NOT skip Info.plist privacy descriptions.
9. DO NOT skip real device testing before submission.
10. Use async/await over completion handlers and delegates.
11. Use SwiftData for iOS 17+ targets, Core Data for backward compatibility.
12. ABC: async/await replaces completion handlers and delegate patterns. Use `async let` for parallel tasks.

[PROCESS]

### SwiftUI View

```swift
struct ContentView: View {
    @StateObject private var viewModel = ItemViewModel()
    var body: some View {
        NavigationStack {
            List(viewModel.items) { item in
                NavigationLink(item.name) { DetailView(item: item) }
            }
            .navigationTitle("Items")
            .task { await viewModel.loadItems() }
        }
    }
}
```

### ViewModel with async/await

```swift
@MainActor
class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false

    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            items = try JSONDecoder().decode([Item].self, from: data)
        } catch { /* Handle error */ }
    }
}
```

### SwiftData (iOS 17+)

```swift
@Model class Item { var name: String; var createdAt: Date }

struct ContentView: View {
    @Query(sort: \Item.createdAt) var items: [Item]
    @Environment(\.modelContext) var context
    func addItem() { context.insert(Item(name: "New", createdAt: .now)) }
}
```

### App Store Submission

1. Archive release build in Xcode
2. Upload via Xcode Organizer or Transporter
3. Configure App Store Connect metadata
4. Submit for review (24-48 hours typical)

### Verification

- [ ] All UI updates on `@MainActor`
- [ ] Closures use `[weak self]` where needed
- [ ] Info.plist has all required privacy descriptions
- [ ] App tested on real device
- [ ] Navigation handles deep links and back gestures

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
