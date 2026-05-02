---
name: react-native
description: >
  React Native cross-platform mobile development — components, React Navigation,
  platform-specific code, native modules, Expo vs bare workflow, and performance
  optimization. Use when building mobile apps with React/TypeScript.
version: "1.0.0"
category: "expert-mobile"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "react native"
  - "react-native"
  - "mobile react"
  - "expo"
  - "native modules"
  - "react navigation"
intent: >
  Guide React Native development from project creation through production. Covers
  core components, navigation patterns, platform-specific code, native module
  bridging, and list performance optimization.
scenarios:
  - "Building cross-platform mobile apps with React and TypeScript"
  - "Setting up React Navigation for stack, tab, and drawer navigation"
  - "Writing platform-specific code for iOS and Android differences"
  - "Creating native modules for platform APIs not in React Native core"
  - "Choosing between Expo managed and bare workflow"
  - "Optimizing FlatList performance for large data sets"
best_for: "Cross-platform mobile apps with React ecosystem, TypeScript mobile development, Expo rapid prototyping"
estimated_time: "10-60 min"
anti_patterns:
  - "Using ScrollView for long lists — use FlatList instead"
  - "Heavy computation on JS thread — offload to native modules"
  - "Ignoring Platform.select for platform differences"
  - "Mismatched native dependency versions with React Native version"
  - "Not testing on both iOS and Android early"
related_skills: ["flutter", "react", "android-kotlin", "ios-swift"]
---

# React Native

## Overview

React Native development for cross-platform mobile apps using React and TypeScript. Compiles to native components with a bridge architecture. Supports Expo (managed) and bare workflows.

## When to Use

- Building cross-platform mobile apps with React/TypeScript
- Leveraging React ecosystem knowledge for mobile development
- Rapid prototyping with Expo managed workflow
- Apps that share logic between web (React) and mobile

## When NOT to Use

- Apps requiring pixel-perfect native UI that differs significantly per platform
- Performance-critical apps needing 60fps animations (consider Flutter or native)
- When the team has no React/web experience (consider Flutter)

## Process

### 1. Project Setup

```bash
# Expo managed (recommended for most projects)
npx create-expo-app MyApp --template expo-template-blank-typescript

# Bare React Native
npx react-native init MyApp --template react-native-template-typescript
```

**Expo vs Bare decision:**

| Factor | Expo Managed | Bare Workflow |
|--------|-------------|---------------|
| Setup speed | Minutes | Longer |
| Native modules | Limited to Expo SDK | Full access |
| OTA updates | Supported | Supported |
| Custom native code | Requires config plugin | Direct access |
| Build | EAS Build | Local or CI |

### 2. Core Components

```tsx
import { View, Text, FlatList, StyleSheet, TouchableOpacity } from 'react-native';

interface User { id: string; name: string; }

export function UserList({ users }: { users: User[] }) {
  return (
    <FlatList
      data={users}
      keyExtractor={item => item.id}
      renderItem={({ item }) => (
        <TouchableOpacity style={styles.item} onPress={() => handlePress(item)}>
          <Text style={styles.name}>{item.name}</Text>
        </TouchableOpacity>
      )}
    />
  );
}

const styles = StyleSheet.create({
  item: { padding: 16, borderBottomWidth: 1, borderBottomColor: '#eee' },
  name: { fontSize: 16, fontWeight: '600' },
});
```

### 3. Navigation (React Navigation)

```tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Details" component={DetailsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

// Navigate
navigation.navigate('Details', { id: '123' });
```

### 4. Platform-Specific Code

**Inline selection:**

```tsx
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 44 : 0,
    ...Platform.select({
      ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 } },
      android: { elevation: 4 },
    }),
  },
});
```

**Platform-specific files:**
- `Component.ios.tsx` and `Component.android.tsx` — bundler auto-selects

### 5. Native Modules

```tsx
// TypeScript bridge
import { NativeModules } from 'react-native';
const { BatteryModule } = NativeModules;
const level = await BatteryModule.getLevel();
```

### 6. FlatList Performance

```tsx
<FlatList
  data={items}
  keyExtractor={item => item.id}
  getItemLayout={(data, index) => ({
    length: ITEM_HEIGHT,
    offset: ITEM_HEIGHT * index,
    index,
  })}
  removeClippedSubviews={true}
  maxToRenderPerBatch={10}
  windowSize={5}
  renderItem={renderItem}
/>
```

## Best Practices

- Always use `FlatList` over `ScrollView` for dynamic lists
- Use `StyleSheet.create` for memoized, optimized style objects
- Test on both platforms from day one — platform quirks surface early
- Use TypeScript for type-safe props, state, and API responses
- Keep native dependency versions aligned with React Native version

## Coaching Notes

- **Bridge bottleneck**: The JS-to-native bridge is async and serial. Batch bridge calls when possible. For heavy computation, write native modules
- **Reanimated over Animated**: `react-native-reanimated` runs animations on the UI thread, avoiding bridge overhead
- **Flipper for debugging**: Use Flipper for network inspection, layout debugging, and performance profiling
- **Hermes engine**: Enable Hermes for faster startup, smaller APK size, and better memory usage

## Verification

- [ ] FlatList used for all dynamic lists with `keyExtractor`
- [ ] Platform-specific differences handled with `Platform.select` or file extensions
- [ ] Navigation types are defined (nested screen params)
- [ ] No inline style objects — all styles in `StyleSheet.create`
- [ ] App tested on both iOS and Android simulators/devices

## Related Skills

- **flutter** — Alternative cross-platform framework (Dart-based)
- **android-kotlin** — Native Android for native module implementation
- **ios-swift** — Native iOS for native module implementation
