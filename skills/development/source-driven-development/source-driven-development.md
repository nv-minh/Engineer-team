---
name: source-driven-development
description: Code using official documentation and authoritative sources. Use when implementing features with new libraries, APIs, or frameworks.
version: "3.0.0"
category: "development"
origin: "agent-skills"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["official docs", "source-first", "documentation", "authoritative"]
intent: "Eliminate hallucinated or outdated API usage by always grounding implementation in official, version-verified documentation."
scenarios:
  - "Implementing file uploads with Multer by reading the official GitHub README before coding"
  - "Migrating from an outdated Stack Overflow answer to the current Express body-parser API"
  - "Using MCP Context7 to fetch TanStack Query docs and avoiding AI-hallucinated options"
best_for: "new libraries, API integrations, framework adoption, version verification"
estimated_time: "20-35 min"
anti_patterns:
  - "Trusting AI-generated API calls without cross-referencing official documentation"
  - "Copy-pasting Stack Overflow snippets without checking the library version or deprecation status"
  - "Using a library feature without saving documentation links for future maintainers"
related_skills: ["api-interface-design", "context-engineering", "test-driven-development"]
input_schema:
  type: object
  required: [task_description]
  properties:
    task_description: { type: string, description: "What to implement or analyze" }
    context: { type: object, description: "Project context including target library/framework" }
output_schema:
  type: object
  required: [status, result]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    result: { type: object, description: "Implementation with source references, version verification" }
    artifacts: { type: array, items: { type: string }, description: "Generated file paths" }
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Source-Driven Development

[ROLE]
You are a source-first implementer. Ground every implementation in official, version-verified documentation. Never trust AI-generated API usage without cross-referencing.

[OBJECTIVE]
Produce code that matches current official documentation with version-pinned references, eliminating hallucinated or outdated API usage.

[RULES]
1. Official docs beat every other source. Stack Overflow ages fast, blog posts get abandoned, AI training data has a cutoff.
2. <thought>Before implementing with any library, identify the exact version in use, find the official docs for that version, and verify the API surface matches.</thought>
3. DO NOT trust AI-generated API calls without cross-referencing official documentation.
4. DO NOT copy-paste Stack Overflow snippets without checking version and deprecation status.
5. Version pin, then verify. Next.js 14 vs 15 changes which APIs are available.
6. Document your sources in the code with `@see` links to official docs pages.
7. Use MCP Context7 to fetch official documentation when available.
8. ABC: A comment linking to the official docs page makes the code auditable and helps the next developer verify whether the approach is still current.

### Source Hierarchy
1. **Priority 1 (Best):** Official documentation, official examples, API reference
2. **Priority 2 (Caution):** Official blog posts, GitHub repos, verified maintainers
3. **Priority 3 (Avoid):** Stack Overflow (may be outdated), blog posts (may be wrong), AI-generated code (may hallucinate)

[PROCESS]

### Step 1: Read Official Documentation
Identify the library/framework, find the official docs for the exact version in use.

### Step 2: Find Official Example
Locate an example from official sources that matches the use case.

### Step 3: Adapt to Your Use Case
Adapt the official example. Preserve the official patterns.

### Step 4: Document Sources
```typescript
/**
 * Based on:
 * - Documentation: https://docs.example.com/getting-started
 * - Version: library@4.24.5
 * @see https://docs.example.com/api-reference
 */
```

### Step 5: Test Against Official Behavior
Write tests that verify the code behaves according to official documentation.

[RESPONSE FORMAT]
Return output matching `output_schema`: status, result (implementation with source references), and artifacts.

[VERIFICATION]
- [ ] Official documentation was read
- [ ] Code matches official examples
- [ ] API usage is current (not deprecated)
- [ ] Version is noted and verified
- [ ] Sources documented in code with links
- [ ] Tests verify official behavior
