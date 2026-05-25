---
name: react-native
description: >
  React Native cross-platform mobile development — components, React Navigation,
  platform-specific code, native modules, Expo vs bare workflow, and performance optimization.
version: "3.0.0"
category: "expert-mobile"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["react native", "react-native", "mobile react", "expo", "native modules", "react navigation"]
intent: >
  Guide React Native development from project creation through production. Covers
  core components, navigation patterns, platform-specific code, and list performance.
scenarios:
  - "Building cross-platform mobile apps with React and TypeScript"
  - "Setting up React Navigation for stack, tab, and drawer navigation"
  - "Optimizing FlatList performance for large data sets"
best_for: "Cross-platform mobile apps with React ecosystem, TypeScript mobile development"
estimated_time: "10-60 min"
anti_patterns:
  - "Using ScrollView for long lists — use FlatList instead"
  - "Heavy computation on JS thread — offload to native modules"
  - "Ignoring Platform.select for platform differences"
  - "Not testing on both iOS and Android early"
related_skills: ["flutter", "react", "android-kotlin", "ios-swift"]

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

# React Native

[ROLE]
Act as a React Native expert. Deliver cross-platform mobile code with FlatList optimization, React Navigation typing, platform-specific handling, and Expo/bare workflow guidance.

[OBJECTIVE]
Build React Native applications where FlatList handles all dynamic lists, navigation params are typed, platform differences use Platform.select, and performance is monitored on both platforms.

[RULES]
1. <thought>Before starting a React Native project, determine: Expo managed or bare workflow? What navigation patterns are needed? What platform-specific differences exist?</thought>
2. Always use `FlatList` over `ScrollView` for dynamic lists with `keyExtractor`.
3. Use `StyleSheet.create` for memoized, optimized style objects.
4. Test on both platforms from day one — platform quirks surface early.
5. Use TypeScript for type-safe props, state, and navigation params.
6. DO NOT use ScrollView for long lists — use FlatList.
7. DO NOT ignore `Platform.select` for platform differences.
8. DO NOT put heavy computation on the JS thread — use native modules.
9. Enable Hermes engine for faster startup and smaller APK.
10. Use `react-native-reanimated` for UI-thread animations.
11. Keep native dependency versions aligned with React Native version.
12. ABC: The JS-to-native bridge is async and serial. Batch bridge calls when possible. For heavy computation, write native modules.

[PROCESS]

### Core Components

```tsx
<FlatList
  data={users}
  keyExtractor={item => item.id}
  renderItem={({ item }) => <Text>{item.name}</Text>}
  getItemLayout={(data, index) => ({ length: ITEM_HEIGHT, offset: ITEM_HEIGHT * index, index })}
  removeClippedSubviews={true}
  maxToRenderPerBatch={10}
/>
```

### Navigation

```tsx
<NavigationContainer>
  <Stack.Navigator>
    <Stack.Screen name="Home" component={HomeScreen} />
    <Stack.Screen name="Details" component={DetailsScreen} />
  </Stack.Navigator>
</NavigationContainer>
```

### Platform-Specific Code

```tsx
const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 44 : 0,
    ...Platform.select({
      ios: { shadowColor: '#000' },
      android: { elevation: 4 },
    }),
  },
});
```

### Verification

- [ ] FlatList used for all dynamic lists with `keyExtractor`
- [ ] Platform differences handled with `Platform.select`
- [ ] All styles in `StyleSheet.create`
- [ ] App tested on both iOS and Android

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
