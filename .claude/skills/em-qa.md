---
name: em:qa
description: Systematic QA testing for web applications - EM-Team Command
tags: [qa, testing, quality-assurance, em-team]
always_available: true
---

# EM:QA - Quality Assurance Testing

Systematically QA test web applications.

## Usage

```
Use the em:qa skill to test [url or scope]
```

## Examples

```
Use the em:qa skill to test http://localhost:3000
Use the em:qa skill to test /dashboard critical paths
Use the em:qa skill to run smoke tests on staging
```

## What This Does

Runs QA checks:
- Critical user paths (auth, CRUD, navigation)
- Console errors and network failures
- Performance (page load < 3s, TTI < 5s)
- Responsive design (mobile, tablet, desktop)
- Visual consistency (typography, colors, spacing)
- Accessibility (ARIA labels, keyboard navigation, contrast)
- Generates health score and QA report

## Scopes

- `full` — Complete QA test suite (default)
- `critical` — Critical user paths only
- `smoke` — Basic functionality check
- `visual` — Visual regression only
