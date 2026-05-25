---
name: tauri
description: >
  Tauri v2 framework for building desktop and mobile applications — Rust backend,
  frontend integration, plugin ecosystem, system integration, mobile builds, and
  security. Use when building lightweight cross-platform apps with Rust and web frontends.
version: "3.0.0"
category: "tauri"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["tauri", "tauri v2", "rust desktop app", "tauri mobile", "tauri plugin", "desktop app rust"]
intent: >
  Guide Tauri v2 development for desktop and mobile applications. Covers Rust
  backend commands, frontend integration (invoke/IPC), plugin ecosystem, system
  integration, mobile builds, and security model (capabilities and ACL).
scenarios:
  - "Building lightweight desktop apps with Rust backend and web frontend"
  - "Implementing IPC between Rust backend and frontend via invoke"
  - "Using Tauri plugins for system integration (clipboard, notifications, dialogs)"
  - "Building mobile apps (Android/iOS) with Tauri v2"
  - "Configuring security capabilities and permissions"
best_for: "Cross-platform desktop/mobile apps, lightweight native apps, Rust + web frontend hybrid"
estimated_time: "15-60 min"
anti_patterns:
  - "Bundling Electron when Tauri provides smaller binaries and better security"
  - "Ignoring capabilities/permissions model — Tauri security is opt-in"
  - "Blocking the UI thread with heavy Rust computation — use async commands"
  - "Not scoping file system access — use scoped FS permissions"
  - "Skipping mobile testing — mobile builds have different constraints than desktop"
related_skills: ["rust-patterns", "frontend-patterns"]

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

# Tauri

[ROLE]
Act as a Tauri v2 expert. Deliver cross-platform desktop/mobile applications with async Rust commands, capability-based security, and plugin integration.

[OBJECTIVE]
Build Tauri applications where Rust commands are async, security permissions are explicitly scoped, frontend invokes backend via typed IPC, and plugins handle system integration.

[RULES]
1. <thought>Before writing any Tauri code, determine: What Rust commands are needed? What capabilities/permissions must be granted? What plugins handle the required system integration?</thought>
2. Use async Tauri commands to avoid blocking the UI thread.
3. Scope all file system and shell permissions explicitly.
4. Use `tauri-plugin-http` for API calls (bypasses CORS).
5. Keep Rust business logic in the backend — frontend handles UI only.
6. Test on all target platforms — desktop and mobile have different constraints.
7. DO NOT ignore the capabilities/permissions model — Tauri grants zero permissions by default.
8. DO NOT block the UI thread with heavy Rust computation — use async commands.
9. DO NOT grant unscoped file system access — use scoped FS permissions.
10. Set CSP headers in tauri.conf.json.
11. ABC: Unlike Electron (full Node.js access), Tauri grants zero permissions by default. You must explicitly allow each capability. This is a security feature, not a limitation.

[PROCESS]

### Project Setup

```bash
npm create tauri-app@latest my-app -- --template react-ts
cd my-app && npm run tauri dev
```

### Rust Backend Commands

```rust
#[tauri::command]
async fn greet(name: String) -> Result<String, String> {
    Ok(format!("Hello, {}!", name))
}

#[tauri::command]
async fn fetch_data(url: String) -> Result<String, String> {
    let response = reqwest::get(&url).await.map_err(|e| e.to_string())?;
    response.text().await.map_err(|e| e.to_string())
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet, fetch_data])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

### Frontend Integration (IPC)

```typescript
import { invoke } from '@tauri-apps/api/core';

async function greet() {
  const result = await invoke<string>('greet', { name: 'World' });
  console.log(result); // "Hello, World!"
}
```

### Configuration

```json
{
  "productName": "My App",
  "version": "1.0.0",
  "identifier": "com.example.myapp",
  "app": {
    "windows": [{ "title": "My App", "width": 800, "height": 600 }],
    "security": { "csp": "default-src 'self'; script-src 'self'" }
  }
}
```

### Plugin Ecosystem

| Plugin | Purpose |
|--------|---------|
| `tauri-plugin-dialog` | Native file pickers and dialogs |
| `tauri-plugin-fs` | Scoped file system access |
| `tauri-plugin-http` | CORS-free HTTP client |
| `tauri-plugin-sql` | SQLite/MySQL/PostgreSQL |
| `tauri-plugin-store` | Key-value persistence |
| `tauri-plugin-stronghold` | Encrypted secret storage |

### Security Model

```json
{
  "identifier": "default",
  "windows": ["main"],
  "permissions": ["core:default", "dialog:allow-open", "fs:allow-read", "fs:allow-write"]
}
```

### Mobile Builds

```bash
npm run tauri android init && npm run tauri android build
npm run tauri ios init && npm run tauri ios build
```

### Verification

- [ ] All Rust commands use async (not blocking the UI)
- [ ] Capabilities and permissions are explicitly configured
- [ ] File system access is scoped
- [ ] CSP headers set in tauri.conf.json
- [ ] App tested on all target platforms

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
