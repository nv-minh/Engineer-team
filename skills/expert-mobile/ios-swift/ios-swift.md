---
name: ios-swift
description: >
  Native iOS development with Swift — SwiftUI views, UIKit controllers, navigation,
  async/await networking, Core Data persistence, Xcode configuration, and App Store
  submission. Use when building native iOS/iPadOS/watchOS apps.
version: "1.0.0"
category: "expert-mobile"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "ios"
  - "swift"
  - "swiftui"
  - "uikit"
  - "xcode"
  - "app store"
  - "testflight"
intent: >
  Guide native iOS development with Swift and SwiftUI/UIKit. Covers declarative UI,
  async networking, data persistence, Xcode project management, and App Store
  submission workflow.
scenarios:
  - "Building native iOS apps with SwiftUI declarative UI"
  - "Implementing async/await networking with URLSession"
  - "Persisting data with Core Data or SwiftData"
  - "Configuring Xcode signing, capabilities, and entitlements"
  - "Preparing builds for TestFlight and App Store review"
  - "Integrating UIKit components in SwiftUI with representable"
best_for: "Native iOS apps, SwiftUI declarative UI, App Store submission, Apple platform integration"
estimated_time: "15-60 min"
anti_patterns:
  - "UI updates off main thread — use @MainActor"
  - "Strong self references in closures — use [weak self]"
  - "Missing Info.plist privacy descriptions before permission requests"
  - "Skipping real device testing before App Store submission"
  - "Ignoring Apple Human Interface Guidelines"
related_skills: ["flutter", "android-kotlin"]
---

# iOS Swift

## Overview

Native iOS development with Swift, SwiftUI, and UIKit. Modern iOS uses SwiftUI for declarative UI, async/await for concurrency, and SwiftData/Core Data for persistence. Covers the full workflow from Xcode project setup to App Store submission.

## When to Use

- Building native iOS, iPadOS, or watchOS applications
- Implementing Apple-specific features (WidgetKit, CloudKit, HealthKit)
- Creating apps that follow Apple Human Interface Guidelines closely
- Apps requiring deep iOS framework integration

## When NOT to Use

- Cross-platform apps where Flutter or React Native suffice
- Server-side Swift (use backend-patterns skill instead)
- Android development (use android-kotlin skill)

## Process

### 1. SwiftUI View

```swift
struct ContentView: View {
    @StateObject private var viewModel = ItemViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.items) { item in
                NavigationLink(item.name) {
                    DetailView(item: item)
                }
            }
            .navigationTitle("Items")
            .task { await viewModel.loadItems() }
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
        }
    }
}
```

### 2. ViewModel with async/await

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
        } catch {
            // Handle error
        }
    }
}
```

### 3. Navigation

**SwiftUI (declarative):**

```swift
NavigationStack {
    List(items) { item in
        NavigationLink(item.name, value: item)
    }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)
    }
}
```

**UIKit (imperative):**

```swift
let detailVC = DetailViewController()
detailVC.item = selectedItem
navigationController?.pushViewController(detailVC, animated: true)
```

### 4. Data Persistence

**Core Data:**

```swift
@main struct MyApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
```

**SwiftData (iOS 17+):**

```swift
@Model class Item {
    var name: String
    var createdAt: Date
}

struct ContentView: View {
    @Query(sort: \Item.createdAt) var items: [Item]
    @Environment(\.modelContext) var context

    func addItem() {
        context.insert(Item(name: "New", createdAt: .now))
    }
}
```

### 5. Xcode Configuration

- **Signing**: Set Team and Bundle ID in Signing & Capabilities
- **Capabilities**: Add Push Notifications, Background Modes as needed
- **Archive**: Product > Archive > Distribute App for submission
- **TestFlight**: Upload archive, add testers, distribute builds
- **Info.plist**: Add privacy keys (`NSCameraUsageDescription`, etc.) before requesting permissions

### 6. App Store Submission

1. Archive the release build in Xcode
2. Upload via Xcode Organizer or Transporter
3. Configure App Store Connect metadata (screenshots, description, keywords)
4. Submit for review — typical review time 24-48 hours

## Best Practices

- Always use `@MainActor` for view models that publish to SwiftUI
- Use `[weak self]` in closures to prevent retain cycles
- Add all required privacy keys to Info.plist before calling any permission API
- Test on real devices and via TestFlight before submission
- Follow Apple Human Interface Guidelines for layout, typography, and navigation

## Coaching Notes

- **SwiftUI vs UIKit**: Start with SwiftUI for new projects. Use `UIViewRepresentable`/`UIViewControllerRepresentable` for UIKit interop
- **async/await over delegates**: Modern Swift concurrency replaces completion handlers and delegate patterns. Use `async let` for parallel tasks
- **SwiftData over Core Data**: For iOS 17+ targets, SwiftData is significantly less boilerplate. Use Core Data for backward compatibility
- **Preview canvas**: Use `#Preview` macros for rapid UI iteration without running the full app

## Verification

- [ ] All UI updates execute on `@MainActor`
- [ ] Closures use `[weak self]` where needed
- [ ] Info.plist has all required privacy usage descriptions
- [ ] App tested on real device, not just simulator
- [ ] Navigation handles edge cases (deep links, back gestures)

## Related Skills

- **flutter** — Cross-platform alternative with Dart
- **android-kotlin** — Native Android counterpart for cross-platform teams
