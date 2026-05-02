---
name: tauri
description: >
  Tauri v2 framework for building desktop and mobile applications — Rust backend,
  frontend integration, plugin ecosystem, system integration, mobile builds, and
  security. Use when building lightweight cross-platform apps with Rust and web
  frontends.
version: "1.0.0"
category: "tauri"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "tauri"
  - "tauri v2"
  - "rust desktop app"
  - "tauri mobile"
  - "tauri plugin"
  - "desktop app rust"
intent: >
  Guide Tauri v2 development for desktop and mobile applications. Covers Rust
  backend commands, frontend integration (invoke/IPC), plugin ecosystem, system
  integration (file system, notifications, clipboard), mobile builds, and
  security model (capabilities and ACL).
scenarios:
  - "Building lightweight desktop apps with Rust backend and web frontend"
  - "Implementing IPC between Rust backend and frontend via invoke"
  - "Using Tauri plugins for system integration (clipboard, notifications, dialogs)"
  - "Building mobile apps (Android/iOS) with Tauri v2"
  - "Configuring security capabilities and permissions"
  - "Setting up Tauri project with custom frontend framework"
best_for: "Cross-platform desktop/mobile apps, lightweight native apps, Rust + web frontend hybrid"
estimated_time: "15-60 min"
anti_patterns:
  - "Bundling Electron when Tauri provides smaller binaries and better security"
  - "Ignoring capabilities/permissions model — Tauri security is opt-in"
  - "Blocking the UI thread with heavy Rust computation — use async commands"
  - "Not scoping file system access — use scoped FS permissions"
  - "Skipping mobile testing — mobile builds have different constraints than desktop"
related_skills: ["rust-patterns", "frontend-patterns"]
---

# Tauri

## Overview

Tauri v2 framework for building desktop and mobile applications with a Rust backend and web frontend. Key advantages over Electron: smaller binary size (MBs vs 100s of MBs), better security model (capability-based ACL), and native performance via Rust. Supports Android and iOS builds alongside desktop (Windows, macOS, Linux).

## When to Use

- Building lightweight desktop apps with native performance
- Cross-platform apps needing Rust backend power with web frontend flexibility
- Mobile apps combining Rust logic with familiar web UI frameworks
- Apps requiring strong security isolation (capability-based permissions)

## When NOT to Use

- Pure web applications (no desktop/mobile packaging needed)
- Apps requiring deep native UI (use platform-native frameworks)
- Teams without Rust expertise (consider Electron as alternative)

## Process

### 1. Project Setup

```bash
# Create new Tauri project
npm create tauri-app@latest my-app -- --template react-ts

# Or with other frontends
npm create tauri-app@latest my-app -- --template vue-ts
npm create tauri-app@latest my-app -- --template svelte-ts

# Development
cd my-app
npm run tauri dev
```

### 2. Rust Backend Commands

```rust
// src-tauri/src/main.rs
#[tauri::command]
async fn greet(name: String) -> Result<String, String> {
    Ok(format!("Hello, {}!", name))
}

#[tauri::command]
async fn fetch_data(url: String) -> Result<String, String> {
    // HTTP client in Rust — no CORS restrictions
    let response = reqwest::get(&url).await
        .map_err(|e| e.to_string())?;
    let body = response.text().await
        .map_err(|e| e.to_string())?;
    Ok(body)
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet, fetch_data])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### 3. Frontend Integration (IPC)

```typescript
// Frontend calls Rust backend
import { invoke } from '@tauri-apps/api/core';

async function greet() {
  const result = await invoke<string>('greet', { name: 'World' });
  console.log(result); // "Hello, World!"
}

// Type-safe with shared types
interface FetchResult {
  data: string;
  status: number;
}
```

### 4. Configuration (tauri.conf.json)

```json
{
  "productName": "My App",
  "version": "1.0.0",
  "identifier": "com.example.myapp",
  "build": {
    "frontendDist": "../dist"
  },
  "app": {
    "windows": [
      { "title": "My App", "width": 800, "height": 600 }
    ],
    "security": {
      "csp": "default-src 'self'; script-src 'self'"
    }
  }
}
```

### 5. Plugin Ecosystem

| Plugin | Purpose |
|--------|---------|
| `tauri-plugin-shell` | Execute system commands |
| `tauri-plugin-dialog` | Native file pickers and dialogs |
| `tauri-plugin-clipboard` | Copy/paste operations |
| `tauri-plugin-notification` | System notifications |
| `tauri-plugin-fs` | Scoped file system access |
| `tauri-plugin-http` | CORS-free HTTP client |
| `tauri-plugin-sql` | SQLite/MySQL/PostgreSQL |
| `tauri-plugin-store` | Key-value persistence |
| `tauri-plugin-stronghold` | Encrypted secret storage |
| `tauri-plugin-biometric` | TouchID/FaceID auth |

```bash
# Add a plugin
npm install @tauri-apps/plugin-fs
cargo add tauri-plugin-fs
```

### 6. Mobile Builds

```bash
# Initialize mobile targets
npm run tauri android init
npm run tauri ios init

# Build for mobile
npm run tauri android build
npm run tauri ios build
```

### 7. Security Model

Tauri uses a capability-based security model:

```json
// capabilities/default.json
{
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:allow-execute",
    "dialog:allow-open",
    "fs:allow-read",
    "fs:allow-write"
  ]
}
```

- **Capabilities** define what windows can access
- **Permissions** are granted per-plugin, per-action
- **Scope** restricts file paths, URLs, and commands

## Best Practices

- Use async Tauri commands to avoid blocking the UI thread
- Scope all file system and shell permissions explicitly
- Use `tauri-plugin-http` for API calls (bypasses CORS)
- Keep Rust business logic in the backend; frontend handles UI only
- Test on all target platforms — desktop and mobile have different constraints

## Coaching Notes

- **IPC is async**: All `invoke` calls return Promises. Use async/await on both sides
- **Security is opt-in**: Unlike Electron (full Node.js access), Tauri grants zero permissions by default. You must explicitly allow each capability
- **Mobile is maturing**: Tauri v2 mobile support is production-ready but some plugins may have platform-specific limitations
- **Bundle size**: Tauri apps are typically 2-10MB vs 100-200MB for Electron. This matters for distribution and mobile

## Verification

- [ ] All Rust commands use async (not blocking the UI)
- [ ] Capabilities and permissions are explicitly configured
- [ ] File system access is scoped (not full disk access)
- [ ] CSP headers set in tauri.conf.json
- [ ] App tested on all target platforms (desktop + mobile if applicable)

## Related Skills

- **rust-patterns** — Idiomatic Rust for backend command implementation
- **frontend-patterns** — Web frontend patterns for Tauri's webview layer
