# Mistakes Ledger

Records past mistakes and prevention measures. Append when failures occur, reference when starting related tasks.

---

## CRITICAL PATTERNS TO AVOID

### Pattern 1: Ignoring Skill Instructions
```
User: "Use the X skill to create Y"
WRONG: Manually write the code
RIGHT: Invoke the Skill tool to call /X
```

### Pattern 2: Ignoring Existing Files
```
User: "Create a similar workflow for feature B"
WRONG: Create a new file from scratch
RIGHT: Read the existing file for feature A first, then adapt it
```

### Pattern 3: Unverified Agent Reports
```
Context: Agent review reports 15 issues (4 Critical, 11 High)
WRONG: Report numbers without verifying — agents tend to overstate severity
RIGHT: Open each file and verify the issue yourself before reporting
Why: Agent severity ratings are often inflated. Actual Critical may be 1, not 4.
```

### Pattern 4: Session Continuation Without State Check
```
Context: Starting a new session
WRONG: Begin working without checking previous state
RIGHT: Check SESSION_HANDOFF.md and git log before starting work
```

### Pattern 5: Fix Introduces New Bugs
```
Context: Adding a security guard to update.sh
WRONG: Guard blocks the fallback path too, breaking the original flow
RIGHT: Draw a flow diagram for all paths before modifying branching logic
Why: Security fixes often focus on one path and break others
```

### Pattern 6: Claiming "All Verified" Without Actually Checking
```
Context: Reporting audit results
WRONG: "All numbers match" without opening the actual files
RIGHT: Open each file, count items yourself, report honestly
Why: Desire to finish quickly leads to false "verified" claims
```

### Pattern 7: Local Commits Left Behind Before Branch Switch
```
Context: Switching to a new branch
WRONG: Create new branch from origin/main while local main has unpushed commits
RIGHT: Run `git log origin/main..HEAD` first. Push or PR local commits before branching.
Why: Local-only commits disappear from worktree when switching branches
```

### Pattern 8: Assuming Skill Sub-files Auto-Load
```
Context: Placing reference.md in a skill directory
WRONG: Assume Claude will automatically read it
RIGHT: Add an explicit `[reference.md](reference.md)` link inside the main skill file
Why: Claude only reads files it's explicitly told to read
```

### Pattern 9: Session Handoff Left as Template
```
Context: Session ending
WRONG: Auto-generated SESSION_HANDOFF.md with only generic template content
RIGHT: Read SESSION_HANDOFF.md after generation, add session-specific context (current HEAD, open PRs, next priorities)
Why: Auto-generated templates are skeletons — session-specific info must be added manually
```

---

## Resolved Mistakes History

*No entries yet. Mistakes will be moved here after resolution.*

---

*This file is updated when violations are detected.*
