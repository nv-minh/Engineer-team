# EM-Team Knowledge Base

This directory contains project-specific knowledge that all agents use to maintain consistency.

## Knowledge Files

- **project-conventions.md** - All project naming, organization, and coding conventions
- **coding-style.md** - Code formatting, patterns, and style guidelines
- **architecture-patterns.md** - Detected architectural patterns and design decisions
- **dependencies.md** - Dependency mapping and integration points

## Examples Directory

Contains representative code samples that demonstrate project patterns:
- `component-example.tsx` - Typical React component structure
- `service-example.ts` - Service layer pattern
- `test-example.test.ts` - Test structure and conventions

## How Agents Use This Knowledge

When an agent starts a task, it automatically:
1. Loads relevant knowledge files
2. Studies code examples
3. Applies conventions to its work
4. Validates output against patterns

## Updating Knowledge

Run the Codebase-Mapper agent to update knowledge:
```bash
Agent: codebase-mapper - Update knowledge base
```

## When to Update

- After major refactoring
- When coding conventions change
- Before starting large features
- When style drift is detected

---

**Knowledge Base Version:** 1.0.0
**Last Updated:** 2026-04-19
