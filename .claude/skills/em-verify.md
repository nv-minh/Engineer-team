---
name: em:verify
description: Verify implementation against spec - EM-Team Command
tags: [verify, validation, em-team]
always_available: true
---

# EM:Verify - Implementation Verification

Verify implementation against spec or requirements.

## Usage

```
Use the em:verify skill to verify [spec or implementation]
```

## Examples

```
Use the em:verify skill to verify the implementation against SPEC.md
Use the em:verify skill to verify the auth module implementation
```

## What This Does

Verifies implementation against spec:
1. **Objectives** — All spec objectives met
2. **Commands/API** — Endpoints implemented correctly
3. **Structure** — Project structure follows conventions
4. **Code Style** — TypeScript strict, linting, formatting
5. **Testing** — Unit, integration, E2E coverage (>80%)
6. **Boundaries** — No scope creep, out-of-scope items excluded

## Output

Final decision:
- **APPROVED** — Meets all requirements, ready to ship
- **CONDITIONAL** — Minor issues, can be addressed post-ship
- **REJECTED** — Critical issues, must be fixed
