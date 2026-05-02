# Context Management Guidelines

## Overview

Guidelines for using the context window efficiently and maintaining session quality.

**Important**: These are guidelines, not hard rules. Quality always takes priority over context efficiency.

---

## MCP Server Management

### Recommended Settings

| Setting | Value | Reason |
|---------|-------|--------|
| Registered MCP servers | 10-20 | Enough options without bloat |
| Active MCP servers | 5-8 | Prevent context shrinkage |
| Active tools | 40-60 | Too many tools reduce effective context |

### Per-Project Configuration

Only enable needed MCP servers, disable the rest:

```json
// .claude/settings.json
{
  "disabledMcpServers": [
    "server-not-needed-for-this-project"
  ]
}
```

---

## Tool Usage Efficiency

### Efficient Search Pattern

```
1. Glob to narrow scope (find candidate files)
2. Grep for patterns (identify relevant lines)
3. Read only needed files (with offset/limit for large files)
```

### Task Type Guidelines

| Task | Glob | Read | Grep |
|------|------|------|------|
| Code review | Few | Many | Few |
| Bug investigation | Few | Medium | Many |
| Refactoring | Medium | Many | Few |
| Search tasks | Many | Few | Many |

**Quality is priority. Exceed these when needed.**

---

## Context Low Prevention

### Warning Signs

- `/compact` suggestion appears
- Responses get truncated
- Repetition of same content

### Remedies

1. **Run `/compact` immediately**
2. Start a new session
3. Use offset/limit for large files

### Prevention Tips

- Use Grep instead of reading entire large log files
- Suppress unnecessary output: `npm install > /dev/null 2>&1`
- Use background execution for long-running tasks

---

## Large File Handling

| File Size | Approach |
|-----------|----------|
| < 500 lines | Full read OK |
| 500-1000 lines | Read only needed sections |
| > 1000 lines | Always use offset/limit |

---

> Quality always takes priority over context efficiency.
