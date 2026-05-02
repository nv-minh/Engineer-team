# EM-Team Installation Guide

One-command installation. Works on macOS and Linux.

---

## Quick Install

```bash
cd /path/to/EM-Team
bash install.sh
```

The script handles everything:

- Updates `~/.claude/config.json` — points skills/agents/workflows paths to EM-Team
- Creates symlinks in `~/.claude/skills/em:*/SKILL.md` — skills auto-discovered by Claude Code
- Cleans up orphaned entries from previous installs
- Preserves existing settings (model, max_tokens, etc.)
- Verifies installation

---

## Using EM-Team Skills

Once installed, open **any project** in Claude Code. All EM-Team skills are available via `/` autocomplete or by name:

```
/em:quick fix typo in README          — Quick task execution
/em:debug investigate login timeout   — Systematic debugging
/em:code-review review auth module    — 5-axis code review
/em:ship ship the payment feature     — Ship workflow
/em:health check project health       — Project health check
/em:team-lead review new feature      — Full team review orchestration
```

### Skill Categories

| Category | Skills |
|----------|--------|
| **Core** | `em:quick`, `em:debug`, `em:code-review`, `em:planner`, `em:new-feature` |
| **Specialized** | `em:architect`, `em:frontend`, `em:backend`, `em:database`, `em:security` |
| **Quality** | `em:test`, `em:performance`, `em:refactor`, `em:bug-fix` |
| **Team Reviews** | `em:team-lead`, `em:code-review-deep`, `em:product-review` |
| **Workflow** | `em:ship`, `em:verify`, `em:qa`, `em:health`, `em:checkpoint` |

---

## What Gets Installed

| Component | Source | Global Location |
|-----------|--------|-----------------|
| Agent/Workflow wrappers (33) | `EM-Team/.claude/skills/em:*.md` | `~/.claude/skills/em:*/SKILL.md` (symlinks) |
| Skill wrappers (36) | `EM-Team/.claude/skills/em:skill-*.md` | `~/.claude/skills/em:skill:*/SKILL.md` (symlinks) |
| Agents (31) | `EM-Team/agents/*.md` | Referenced via `~/.claude/config.json` |
| Workflows (23) | `EM-Team/workflows/*.md` | Referenced via `~/.claude/config.json` |

EM-Team repo is the **single source of truth**. Symlinks point back to it — update the repo, changes apply everywhere.

---

## Verify

```bash
# Check symlinks (should be 69 total: 33 em:* + 36 em:skill:*)
ls ~/.claude/skills/em:*/SKILL.md ~/.claude/skills/em:skill:*/SKILL.md 2>/dev/null | wc -l

# Check no orphaned entries (should be empty)
ls ~/.claude/skills/em:* 2>/dev/null

# Verify paths in config
cat ~/.claude/config.json | grep "paths" -A2

# Open any project in Claude Code and try:
/em:quick hello world
```

---

## Uninstall

```bash
cd /path/to/EM-Team
bash uninstall.sh
```

Removes symlinks, orphaned entries, optional CLI wrapper, and cleans config.json. Preserves non-EM settings and other skills.

---

## Manual Install (if script fails)

```bash
REPO="/path/to/EM-Team"

# 1. Update ~/.claude/config.json paths
# Set skills.paths   → ["$REPO/.claude/skills"]
# Set agents.paths   → ["$REPO/agents"]
# Set workflows.paths → ["$REPO/workflows"]

# 2. Create symlinks for each skill wrapper
for src in $REPO/.claude/skills/em:*.md; do
  name=$(basename "$src" .md | sed 's/^em-//')
  dir="$HOME/.claude/skills/em:$name"
  mkdir -p "$dir"
  ln -sf "$src" "$dir/SKILL.md"
done

# Also symlink em-skill-* wrappers
for src in $REPO/.claude/skills/em:skill-*.md; do
  name=$(basename "$src" .md | sed 's/^em-skill-//')
  dir="$HOME/.claude/skills/em:skill:$name"
  mkdir -p "$dir"
  ln -sf "$src" "$dir/SKILL.md"
done

# 3. Verify
ls ~/.claude/skills/em:*/SKILL.md ~/.claude/skills/em:skill:*/SKILL.md 2>/dev/null | wc -l
```

---

## Troubleshooting

### "Skills not appearing in Claude Code"
```bash
# Restart Claude Code after install
# Check symlinks resolve correctly
ls -la ~/.claude/skills/em:*/SKILL.md

# Verify paths in config
cat ~/.claude/config.json | grep "paths" -A2
```

### "Broken symlinks"
```bash
# Reinstall fixes broken symlinks and cleans orphans automatically
bash install.sh
```

### "Orphaned em-* entries in ~/.claude/skills/"
```bash
# These are flat files/symlinks from an older install — reinstall cleans them
bash install.sh
```

### "config.json not valid JSON"
```bash
jq . ~/.claude/config.json

# If broken, delete and reinstall
rm ~/.claude/config.json
bash install.sh
```

---

**Last Updated:** 2026-05-02
**Version:** 3.0.0
