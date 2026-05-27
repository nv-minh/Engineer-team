# Naming Convention Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename all 158 `.claude/skills/` entry points to `em-skill:`, `em-agent:`, `em-wf:` prefixes, consolidate 4 overlapping code-review and 4 overlapping security entry points, update `install.sh`, and update all documentation.

**Architecture:** Migration script handles bulk renames + frontmatter updates; install.sh is updated to detect new file prefixes (`em-agent-*`, `em-wf-*`, `em-skill-*`); CLAUDE.md and docs are updated with sed + manual edits.

**Tech Stack:** Bash (migration script, install.sh), sed (in-place replacements), macOS `sed -i ''` syntax.

---

## Consolidation Decisions

### Code Review: 4 → 2 entry points

| Old | Action | New |
|-----|--------|-----|
| `em:code-reviewer` | Rename | `em-agent:code-reviewer` (5/9-axis, standard/deep mode) |
| `em:code-review` | Rename (alias) | `em-agent:code-review` (shortcut for code-reviewer) |
| `em:code-review-9axis` | Rename + consolidate | `em-wf:code-review` (9-axis + OWASP security workflow) |
| `em:code-review-deep` | **DELETE** (duplicate of 9axis) | — |
| `em:senior-code-reviewer` | **DELETE** (deprecated v3.1.0) | — |

### Security: 4 → 3 entry points

| Old | Action | New |
|-----|--------|-----|
| `em:security-reviewer` | Rename | `em-agent:security-reviewer` (OWASP + STRIDE, blocking) |
| `em:security-audit` | Rename | `em-wf:security-audit` (5-stage audit workflow) |
| `em:security-review-advanced` | Rename | `em-wf:security-review-advanced` (STRIDE threat modeling) |
| `em:security` | **DELETE** (alias, no value) | — |
| `em:security-auditor` | **DELETE** (deprecated duplicate) | — |

---

## File Structure Map

```
.claude/skills/
├── em-agent-{name}.md    ← was em-{name}.md  (agents)
├── em-wf-{name}.md       ← was em-{name}.md  (workflows)
└── em-skill-{name}.md    ← unchanged filename, updated name: field
```

### Categorization of all 158 entry points

**36 canonical agents** → `em-agent-{name}.md` / `em-agent:{name}`:
architect, autoplan, backend-expert, brownfield-test-engineer, code-review, code-reviewer, codebase-mapper, database-expert, debugger, design-reviewer, devex-reviewer, devops-expert, executor, frontend-expert, integration-checker, iron-law-enforcer, learn, market-intelligence, mobile-expert, nestjs-expert, performance-auditor, planner, playwright-setup, product-manager, react-expert, researcher, rust-expert, security-reviewer, spring-expert, staff-engineer, team-lead, techlead-orchestrator, test-engineer, test-verifier, ui-auditor, verifier, vue-expert

**10 agent aliases** → `em-agent-{alias}.md` / `em-agent:{alias}`:
backend→backend-expert, database→database-expert, debug→debugger, frontend→frontend-expert, performance→performance-auditor, research→researcher, team→team-lead, test→test-engineer, verify→verifier, checkpoint/health/quick (standalone)

**24 canonical workflows** → `em-wf-{name}.md` / `em-wf:{name}`:
architecture-review, bug-fix, canary-monitoring, code-review (consolidated from 9axis), database-review, deployment, design-review, discovery-process, distributed-development, distributed-investigation, documentation, incident-response, market-driven-feature, new-feature, product-review, project-setup, qa-bug-hunter, refactoring, retro, security-audit, security-review-advanced, ship-workflow, six-phase-lifecycle, team-review

**4 workflow aliases** → `em-wf-{alias}.md` / `em-wf:{alias}`:
distributed→distributed-investigation, incident→incident-response, refactor→refactoring, ship→ship-workflow

**4 standalone** → treated as agents: checkpoint, health, qa, quick

**76 skills** → keep `em-skill-{name}.md` filename, update `name:` from `em:skill:` → `em-skill:`

**DELETE (5 files):** em-code-review-deep, em-senior-code-reviewer, em-security, em-security-auditor, em-code-review-9axis (content merged into em-wf-code-review)

---

## Task 1: Pre-migration — Delete redundant entry points

**Files:**
- Delete: `.claude/skills/em-code-review-deep.md`
- Delete: `.claude/skills/em-senior-code-reviewer.md`
- Delete: `.claude/skills/em-security.md`
- Delete: `.claude/skills/em-security-auditor.md`

- [ ] **Step 1: Delete the 4 redundant/deprecated files**

```bash
cd /path/to/Engineer-team
rm .claude/skills/em-code-review-deep.md
rm .claude/skills/em-senior-code-reviewer.md
rm .claude/skills/em-security.md
rm .claude/skills/em-security-auditor.md
```

Expected: No output. `ls .claude/skills/em-code-review-deep.md` returns "No such file".

- [ ] **Step 2: Consolidate code-review-9axis → em-wf-code-review.md**

```bash
# Update the name: field inside the file first
sed -i '' 's/^name: em:code-review-9axis/name: em-wf:code-review/' .claude/skills/em-code-review-9axis.md
# Update description to reflect it's the canonical code review workflow
sed -i '' 's/description: Deep 9-axis code review - EM-Team Workflow/description: 9-axis code review + OWASP security assessment - EM-Team Workflow/' .claude/skills/em-code-review-9axis.md
# Rename the file
mv .claude/skills/em-code-review-9axis.md .claude/skills/em-wf-code-review.md
```

Expected: `ls .claude/skills/em-wf-code-review.md` shows the file. `head -3 .claude/skills/em-wf-code-review.md` shows `name: em-wf:code-review`.

- [ ] **Step 3: Commit pre-migration cleanup**

```bash
git add -A .claude/skills/
git commit -m "refactor: consolidate redundant code-review and security entry points

- Delete em-code-review-deep (duplicate of 9axis workflow)
- Delete em-senior-code-reviewer (deprecated since v3.1.0)
- Delete em-security (redundant alias for security-auditor)
- Delete em-security-auditor (deprecated duplicate of security-reviewer)
- Rename em-code-review-9axis → em-wf-code-review (canonical code review workflow)"
```

---

## Task 2: Create migration script

**Files:**
- Create: `scripts/migration/migrate-names.sh`

- [ ] **Step 1: Create the migration directory**

```bash
mkdir -p scripts/migration
```

- [ ] **Step 2: Write the migration script**

Create `scripts/migration/migrate-names.sh`:

```bash
#!/bin/bash
# scripts/migration/migrate-names.sh
# Migrates .claude/skills/ entry points to new naming convention:
#   Agents:    em-{name}.md  → em-agent-{name}.md  (name: em-agent:{name})
#   Workflows: em-{name}.md  → em-wf-{name}.md     (name: em-wf:{name})
#   Skills:    em-skill-{name}.md unchanged         (name: em:skill: → em-skill:)
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SKILLS_DIR="$REPO/.claude/skills"
AGENTS_DIR="$REPO/agents"
WORKFLOWS_DIR="$REPO/workflows"

echo "=== EM-Team Naming Convention Migration ==="
echo "Repo: $REPO"
echo ""

RENAMED=0
UPDATED=0
SKIPPED=0

# ─── Step 1: Update em-skill-* name: fields (em:skill: → em-skill:) ───
echo "--- Processing skill wrappers ---"
for file in "$SKILLS_DIR"/em-skill-*.md; do
  [[ ! -f "$file" ]] && continue
  basename=$(basename "$file")
  name="${basename#em-skill-}"
  name="${name%.md}"

  # Check if already migrated
  if grep -q "^name: em-skill:" "$file"; then
    echo "  SKIP (already migrated): $basename"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  sed -i '' "s|^name: em:skill:${name}|name: em-skill:${name}|" "$file"
  echo "  UPDATED: $basename → name: em-skill:$name"
  UPDATED=$((UPDATED + 1))
done

# ─── Step 2: Process em-agent-* and em-wf-* (already renamed, just update name:) ───
echo ""
echo "--- Processing already-renamed agent/workflow wrappers ---"
for file in "$SKILLS_DIR"/em-agent-*.md "$SKILLS_DIR"/em-wf-*.md; do
  [[ ! -f "$file" ]] && continue
  basename=$(basename "$file")

  if [[ "$basename" == em-agent-* ]]; then
    name="${basename#em-agent-}"
    name="${name%.md}"
    expected_name="em-agent:$name"
    prefix="em-agent"
  else
    name="${basename#em-wf-}"
    name="${name%.md}"
    expected_name="em-wf:$name"
    prefix="em-wf"
  fi

  if grep -q "^name: $expected_name$" "$file"; then
    echo "  SKIP (already correct): $basename"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Replace any em:* name with correct prefix
  sed -i '' "s|^name: em:[a-z:/-]*$|name: $expected_name|" "$file"
  echo "  UPDATED: $basename → name: $expected_name"
  UPDATED=$((UPDATED + 1))
done

# ─── Step 3: Process remaining em-*.md files (agents and workflows) ───
echo ""
echo "--- Processing legacy em-*.md entry points ---"

# Alias map: short-name → canonical-name:type
declare -A ALIAS_MAP=(
  ["backend"]="backend-expert:agent"
  ["code-review"]="code-reviewer:agent"
  ["database"]="database-expert:agent"
  ["debug"]="debugger:agent"
  ["frontend"]="frontend-expert:agent"
  ["performance"]="performance-auditor:agent"
  ["research"]="researcher:agent"
  ["team"]="team-lead:agent"
  ["test"]="test-engineer:agent"
  ["verify"]="verifier:agent"
  ["checkpoint"]="checkpoint:agent"
  ["health"]="health:agent"
  ["quick"]="quick:agent"
  ["qa"]="qa:agent"
  ["distributed"]="distributed-investigation:workflow"
  ["incident"]="incident-response:workflow"
  ["refactor"]="refactoring:workflow"
  ["ship"]="ship-workflow:workflow"
)

for file in "$SKILLS_DIR"/em-*.md; do
  [[ ! -f "$file" ]] && continue
  basename=$(basename "$file")

  # Skip already-processed prefixes
  [[ "$basename" == em-skill-* ]] && continue
  [[ "$basename" == em-agent-* ]] && continue
  [[ "$basename" == em-wf-* ]] && continue

  name="${basename#em-}"
  name="${name%.md}"

  # Determine entity type
  entity_type=""
  canonical_name=""

  if [[ -n "${ALIAS_MAP[$name]+_}" ]]; then
    mapval="${ALIAS_MAP[$name]}"
    canonical_name="${mapval%%:*}"
    entity_type="${mapval##*:}"
  elif [[ -f "$AGENTS_DIR/$name.md" ]]; then
    entity_type="agent"
    canonical_name="$name"
  elif [[ -f "$WORKFLOWS_DIR/$name.md" ]]; then
    entity_type="workflow"
    canonical_name="$name"
  else
    echo "  UNKNOWN (no match in agents/ or workflows/): $basename — SKIPPED"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  if [[ "$entity_type" == "agent" ]]; then
    new_file="$SKILLS_DIR/em-agent-$name.md"
    new_name="em-agent:$name"
  else
    new_file="$SKILLS_DIR/em-wf-$name.md"
    new_name="em-wf:$name"
  fi

  # Update name: field (replace any em:* with new name)
  sed -i '' "s|^name: em:.*|name: $new_name|" "$file"
  # Rename file
  mv "$file" "$new_file"
  echo "  RENAMED: $basename → $(basename "$new_file")  (name: $new_name)"
  RENAMED=$((RENAMED + 1))
done

echo ""
echo "=== Migration Summary ==="
echo "  Renamed:  $RENAMED files"
echo "  Updated:  $UPDATED name: fields"
echo "  Skipped:  $SKIPPED (already correct)"
echo ""
echo "Total entry points in .claude/skills/:"
ls "$SKILLS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' '
```

- [ ] **Step 3: Make script executable**

```bash
chmod +x scripts/migration/migrate-names.sh
```

- [ ] **Step 4: Commit the migration script**

```bash
git add scripts/migration/migrate-names.sh
git commit -m "feat: add migration script for naming convention refactor"
```

---

## Task 3: Run the migration

**Files:**
- Modify: all `em-*.md` in `.claude/skills/` (~154 files)

- [ ] **Step 1: Run the migration script**

```bash
bash scripts/migration/migrate-names.sh
```

Expected output:
```
=== EM-Team Naming Convention Migration ===
  UPDATED: em-skill-brainstorming.md → name: em-skill:brainstorming
  UPDATED: em-skill-react.md → name: em-skill:react
  ... (76 skill updates)
  RENAMED: em-planner.md → em-agent-planner.md  (name: em-agent:planner)
  RENAMED: em-new-feature.md → em-wf-new-feature.md  (name: em-wf:new-feature)
  ... (~110 more renames)
=== Migration Summary ===
  Renamed:  ~110 files
  Updated:  ~76 name: fields
```

- [ ] **Step 2: Verify file counts**

```bash
# Should see em-agent-*.md, em-wf-*.md, em-skill-*.md only (no plain em-*.md except em-wf-code-review.md etc.)
ls .claude/skills/ | grep -v "^em-agent-" | grep -v "^em-wf-" | grep -v "^em-skill-" | grep "^em-"
```

Expected: empty output (all files now have correct prefixes).

- [ ] **Step 3: Spot-check a few files**

```bash
head -3 .claude/skills/em-agent-planner.md
# Expected: name: em-agent:planner

head -3 .claude/skills/em-wf-new-feature.md
# Expected: name: em-wf:new-feature

head -3 .claude/skills/em-skill-brainstorming.md
# Expected: name: em-skill:brainstorming
```

- [ ] **Step 4: Commit migration results**

```bash
git add -A .claude/skills/
git commit -m "refactor: rename all .claude/skills/ entry points to new naming convention

- Agents: em-{name}.md → em-agent-{name}.md (em-agent:{name})
- Workflows: em-{name}.md → em-wf-{name}.md (em-wf:{name})
- Skills: updated name: from em:skill: → em-skill: (filenames unchanged)
- 110+ files renamed, 76 name: fields updated"
```

---

## Task 4: Update install.sh

**Files:**
- Modify: `install.sh`

The current `install.sh` has one loop for `em-*.md` (agents+workflows) and one for `em-skill-*.md`. It must be split into three explicit loops: agents, workflows, skills.

- [ ] **Step 1: Replace the command-generation section (lines 147–229)**

Replace the "Agent commands" and "Skill commands" sections with three loops:

```bash
# --- Agent commands (em-agent-*.md) ---
for wrapper in "$REPO/.claude/skills/"em-agent-*.md; do
  [[ ! -f "$wrapper" ]] && continue
  basename=$(basename "$wrapper" .md)    # e.g., em-agent-planner
  name="${basename#em-agent-}"           # e.g., planner

  # Determine source: check agents/ first, then try alias resolution
  source_file=""
  if [[ -f "$CONTENT_DIR/agents/$name.md" ]]; then
    source_file="agents/$name.md"
  else
    # Alias map: short names that route to longer agent names
    case "$name" in
      backend)     source_file="agents/backend-expert.md" ;;
      code-review) source_file="agents/code-reviewer.md" ;;
      database)    source_file="agents/database-expert.md" ;;
      debug)       source_file="agents/debugger.md" ;;
      frontend)    source_file="agents/frontend-expert.md" ;;
      performance) source_file="agents/performance-auditor.md" ;;
      research)    source_file="agents/researcher.md" ;;
      team)        source_file="agents/team-lead.md" ;;
      test)        source_file="agents/test-engineer.md" ;;
      verify)      source_file="agents/verifier.md" ;;
    esac
  fi

  if [[ -n "$source_file" ]]; then
    desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
    [[ -z "$desc" ]] && desc="$name"
    cat > "$COMMANDS_DIR/$name.md" <<CMD
---
name: em-agent:$name
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
    CMD_COUNT=$((CMD_COUNT + 1))
  else
    # Standalone: copy wrapper content directly (checkpoint, health, quick, qa)
    desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
    [[ -z "$desc" ]] && desc="$name"
    cat > "$COMMANDS_DIR/$name.md" <<CMD
---
name: em-agent:$name
description: $desc
---
CMD
    sed '1,/^---$/d' "$wrapper" | sed '1,/^---$/d' >> "$COMMANDS_DIR/$name.md"
    CMD_COUNT=$((CMD_COUNT + 1))
  fi
done

# --- Workflow commands (em-wf-*.md) ---
for wrapper in "$REPO/.claude/skills/"em-wf-*.md; do
  [[ ! -f "$wrapper" ]] && continue
  basename=$(basename "$wrapper" .md)    # e.g., em-wf-new-feature
  name="${basename#em-wf-}"              # e.g., new-feature

  # Determine source: check workflows/ first, then try alias resolution
  source_file=""
  if [[ -f "$CONTENT_DIR/workflows/$name.md" ]]; then
    source_file="workflows/$name.md"
  else
    case "$name" in
      code-review)  source_file="workflows/code-review-9axis.md" ;;
      distributed)  source_file="workflows/distributed-investigation.md" ;;
      incident)     source_file="workflows/incident-response.md" ;;
      refactor)     source_file="workflows/refactoring.md" ;;
      ship)         source_file="workflows/ship-workflow.md" ;;
    esac
  fi

  if [[ -n "$source_file" ]]; then
    desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
    [[ -z "$desc" ]] && desc="$name"
    cat > "$COMMANDS_DIR/$name.md" <<CMD
---
name: em-wf:$name
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
    CMD_COUNT=$((CMD_COUNT + 1))
  fi
done

# --- Skill commands (em-skill-*.md) ---
for wrapper in "$REPO/.claude/skills/"em-skill-*.md; do
  [[ ! -f "$wrapper" ]] && continue
  basename=$(basename "$wrapper" .md)    # e.g., em-skill-brainstorming
  name="${basename#em-skill-}"           # e.g., brainstorming

  rel_source=$(resolve_source_path "$wrapper")

  if [[ -n "$rel_source" ]] && [[ -f "$CONTENT_DIR/$rel_source" ]]; then
    source_file="$rel_source"
  else
    found=$(find "$CONTENT_DIR/skills" -name "$name.md" | head -1)
    if [[ -n "$found" ]]; then
      source_file="${found#$CONTENT_DIR/}"
    else
      continue
    fi
  fi

  desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
  [[ -z "$desc" ]] && desc="$name"
  cat > "$COMMANDS_DIR/$name.md" <<CMD
---
name: em-skill:$name
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
  CMD_COUNT=$((CMD_COUNT + 1))
done
```

- [ ] **Step 2: Remove the old "Alias shortcuts" section (lines 231–267) from install.sh**

The new agent and workflow loops handle aliases via their `case` statements, so the hardcoded alias section is replaced.

- [ ] **Step 3: Remove the old "Standalone command shortcuts" section (lines 269–289)**

Standalone commands (checkpoint, health, qa, quick) are now handled by the agent loop's fallback branch.

- [ ] **Step 4: Update the verification section (lines 317–324)**

Replace the sample check for `planner.md`:

```bash
# Check a sample command has valid @file reference
SAMPLE="$COMMANDS_DIR/planner.md"
if [[ -f "$SAMPLE" ]]; then
  if grep -q '@.*/em-team/' "$SAMPLE"; then
    ok "  @file references valid (em-agent:planner)"
  else
    warn "  @file reference missing in planner.md"
    ERRORS=$((ERRORS + 1))
  fi
fi
```

- [ ] **Step 5: Update the "Next steps" message (lines 343–350)**

```bash
echo "  Next steps:"
echo "    1. Restart Claude Code"
echo "    2. Type /em-agent: to see all EM-Team agent commands"
echo "    3. Type /em-wf: to see all EM-Team workflow commands"
echo "    4. Type /em-skill: to see all EM-Team skill commands"
echo "    5. Try: /em-agent:planner Create implementation plan"
echo "    6. Try: /em-skill:brainstorming Explore feature ideas"
echo "    7. Try: /em-wf:new-feature Implement a feature"
```

- [ ] **Step 6: Commit install.sh changes**

```bash
git add install.sh
git commit -m "refactor(install): update command generation for em-agent/em-wf/em-skill naming

Split single em-*.md loop into three explicit loops:
- em-agent-*.md → name: em-agent:{name}
- em-wf-*.md    → name: em-wf:{name}
- em-skill-*.md → name: em-skill:{name}
Remove hardcoded alias section (handled by case statements in each loop)"
```

---

## Task 5: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md` (~850 `em:` references)

- [ ] **Step 1: Replace skill prefix throughout CLAUDE.md**

```bash
# em:skill: → em-skill:
sed -i '' 's/`em:skill:\([^`]*\)`/`em-skill:\1`/g' CLAUDE.md
sed -i '' "s/em:skill:/em-skill:/g" CLAUDE.md
```

- [ ] **Step 2: Replace workflow names (em:{wf-name} → em-wf:{wf-name})**

Workflows: architecture-review, bug-fix, brownfield-investigation, canary-monitoring, code-review (9axis), database-review, deployment, design-review, discovery-process, distributed-development, distributed-investigation, documentation, greenfield-app, incident-response, japanese-outsourcing, market-driven-feature, new-feature, product-review, project-setup, qa-bug-hunter, refactoring, retro, security-audit, security-review-advanced, ship-workflow, six-phase-lifecycle, team-review

```bash
for wf in architecture-review bug-fix brownfield-investigation canary-monitoring \
           code-review database-review deployment design-review discovery-process \
           distributed-development distributed-investigation documentation greenfield-app \
           incident-response japanese-outsourcing market-driven-feature new-feature \
           product-review project-setup qa-bug-hunter refactoring retro security-audit \
           security-review-advanced ship-workflow six-phase-lifecycle team-review; do
  sed -i '' "s/\`em:${wf}\`/\`em-wf:${wf}\`/g" CLAUDE.md
  sed -i '' "s/ em:${wf} / em-wf:${wf} /g" CLAUDE.md
done
```

- [ ] **Step 3: Replace agent names (em:{agent-name} → em-agent:{agent-name})**

```bash
for agent in architect autoplan backend-expert backend brownfield-test-engineer \
             code-review code-reviewer codebase-mapper database-expert database \
             debug debugger design-reviewer devex-reviewer devops-expert executor \
             frontend-expert frontend integration-checker iron-law-enforcer learn \
             market-intelligence mobile-expert nestjs-expert performance-auditor \
             performance planner playwright-setup product-manager react-expert \
             researcher rust-expert security-reviewer spring-expert staff-engineer \
             team-lead team techlead-orchestrator test-engineer test-verifier \
             test ui-auditor verifier verify vue-expert; do
  sed -i '' "s/\`em:${agent}\`/\`em-agent:${agent}\`/g" CLAUDE.md
  sed -i '' "s/trigger: \`em-agent:${agent}\`/trigger: \`em-agent:${agent}\`/g" CLAUDE.md
done
```

- [ ] **Step 4: Update the "Usage" section examples**

Find and manually update:
```markdown
# Old
Use the brainstorming skill to explore this feature idea  →  name: em-skill:brainstorming
Agent: em:planner - Create implementation plan            →  Agent: em-agent:planner
Workflow: em:new-feature - Take this feature...           →  Workflow: em-wf:new-feature
```

Specific replacements in CLAUDE.md:
```bash
sed -i '' 's/Agent: em:/Agent: em-agent:/g' CLAUDE.md
sed -i '' 's/Workflow: em:new-feature/Workflow: em-wf:new-feature/g' CLAUDE.md
sed -i '' 's/Workflow: em:bug-fix/Workflow: em-wf:bug-fix/g' CLAUDE.md
sed -i '' 's/Workflow: em:security-audit/Workflow: em-wf:security-audit/g' CLAUDE.md
```

- [ ] **Step 5: Update Agent Categories trigger format**

In CLAUDE.md, triggers are already `em-agent:` format. Verify they're correct:
```bash
grep 'trigger:' CLAUDE.md | head -20
# Expected: trigger: `em-agent:planner`, `em-agent:code-reviewer`, etc.
```

- [ ] **Step 6: Update version header**

```bash
sed -i '' 's/Current version: 5.4.0/Current version: 5.5.0/' CLAUDE.md
```

- [ ] **Step 7: Update Brownfield Intelligence integration table**

Find the "Integration Points" table and update any `em:` references to new format. Search:
```bash
grep -n "em:" CLAUDE.md | grep -v "em-agent\|em-wf\|em-skill" | head -30
```
Fix any remaining `em:` occurrences manually.

- [ ] **Step 8: Commit CLAUDE.md**

```bash
git add CLAUDE.md
git commit -m "docs(CLAUDE.md): update all em: references to new naming convention

- em:skill:{name} → em-skill:{name}
- em:{agent} → em-agent:{agent}
- em:{workflow} → em-wf:{workflow}
- Bump version to 5.5.0"
```

---

## Task 6: Update README.md and docs/

**Files:**
- Modify: `README.md`
- Modify: `docs/guides/*.md`
- Modify: `docs/skill-systems-guide.md`
- Modify: `docs/ARCHITECTURE-GUIDE.md`
- Modify: `skills/README.md`

- [ ] **Step 1: Apply naming replacements to all documentation files**

```bash
# Process all .md files in docs/ and root README
for file in README.md skills/README.md docs/guides/*.md \
            docs/skill-systems-guide.md docs/ARCHITECTURE-GUIDE.md \
            docs/GUIDE-HERMES-PROTOCOL.md docs/GUIDE-TEST-AUTOMATION-AND-WORKSPACE.md; do
  [[ ! -f "$file" ]] && continue

  # Skill prefix
  sed -i '' 's/em:skill:/em-skill:/g' "$file"

  # Workflow names
  for wf in architecture-review bug-fix canary-monitoring code-review \
             database-review deployment design-review discovery-process \
             distributed-development distributed-investigation documentation \
             greenfield-app incident-response market-driven-feature new-feature \
             product-review project-setup qa-bug-hunter refactoring retro \
             security-audit security-review-advanced ship-workflow \
             six-phase-lifecycle team-review; do
    sed -i '' "s/\`em:${wf}\`/\`em-wf:${wf}\`/g" "$file"
    sed -i '' "s|/em:${wf}|/em-wf:${wf}|g" "$file"
  done

  # Agent examples
  sed -i '' 's|/em:planner|/em-agent:planner|g' "$file"
  sed -i '' 's|/em:code-review |/em-agent:code-review |g' "$file"
  sed -i '' 's|em:planner|em-agent:planner|g' "$file"
  sed -i '' 's|em:executor|em-agent:executor|g' "$file"
  sed -i '' 's|em:code-reviewer|em-agent:code-reviewer|g' "$file"
  sed -i '' 's|em:debugger|em-agent:debugger|g' "$file"
  sed -i '' 's|em:test-engineer|em-agent:test-engineer|g' "$file"
  sed -i '' 's|em:verifier|em-agent:verifier|g' "$file"
  echo "Updated: $file"
done
```

- [ ] **Step 2: Update Quick Start section in README.md**

Find the "Quick Start" section and update:
```markdown
# Old:
Type /em-planner to create a plan
Use /em-skill-brainstorming to explore ideas

# New:
Type /em-agent:planner to create a plan
Use /em-skill:brainstorming to explore ideas
Use /em-wf:new-feature to implement a feature
```

- [ ] **Step 3: Update install.sh "Next steps" hint in README.md**

```bash
sed -i '' 's|em-planner Create|em-agent:planner Create|g' README.md
sed -i '' 's|em-skill-brainstorming|em-skill:brainstorming|g' README.md
```

- [ ] **Step 4: Check for any remaining em: references**

```bash
grep -rn "em:" README.md docs/ skills/README.md | grep -v "em-agent:\|em-wf:\|em-skill:\|em-team\|#.*em" | head -30
```

Fix any remaining occurrences manually.

- [ ] **Step 5: Commit documentation updates**

```bash
git add README.md skills/README.md docs/
git commit -m "docs: update all documentation to new em-agent/em-wf/em-skill naming convention"
```

---

## Task 7: Update protocols/naming-convention.md

**Files:**
- Modify: `protocols/naming-convention.md`

- [ ] **Step 1: Rewrite the naming convention table**

Replace the full content with the new convention:

```markdown
# Naming Convention Protocol

**Canonical naming rules for `.claude/skills/` entry points.**

---

## File Naming Rules

| Entity Type | Filename Pattern | `name:` Format | Routes To | Example |
|---|---|---|---|---|
| Agent (canonical) | `em-agent-{name}.md` | `em-agent:{name}` | `agents/{name}.md` | `em-agent-planner.md` → `em-agent:planner` |
| Agent alias | `em-agent-{short}.md` | `em-agent:{short}` | Same agent as canonical | `em-agent-backend.md` → `em-agent:backend` (routes to backend-expert) |
| Workflow (canonical) | `em-wf-{name}.md` | `em-wf:{name}` | `workflows/{name}.md` | `em-wf-new-feature.md` → `em-wf:new-feature` |
| Workflow alias | `em-wf-{short}.md` | `em-wf:{short}` | Same workflow as canonical | `em-wf-refactor.md` → `em-wf:refactor` (routes to refactoring) |
| Skill wrapper | `em-skill-{name}.md` | `em-skill:{name}` | `skills/{category}/{name}/{name}.md` | `em-skill-react.md` → `em-skill:react` |
| Standalone command | `em-agent-{name}.md` | `em-agent:{name}` | Self-contained (no external file) | `em-agent-checkpoint.md` → `em-agent:checkpoint` |

---

## Rules

1. **Type prefix is mandatory.** Every entry point must use `em-agent:`, `em-wf:`, or `em-skill:` — never bare `em:`.
2. **Filename uses hyphens.** `em-agent-backend-expert.md`, not `em_agent_backend_expert.md`.
3. **`name:` uses colon after type.** `name: em-agent:backend-expert` (correct), `name: em:backend-expert` (wrong).
4. **One canonical + max one alias per entity.** No more than 2 entry points for the same underlying file.
5. **Deprecated files must state it.** `description: "DEPRECATED — Use em-agent:code-reviewer instead"`.

---

## Invocation Examples

```bash
# Agent
Use the em-agent:planner skill to create a plan
/em-agent:planner Create implementation plan for JWT auth

# Workflow
Use the em-wf:new-feature workflow to implement user auth
/em-wf:new-feature Implement shopping cart

# Skill
Use the em-skill:brainstorming skill to explore ideas
/em-skill:brainstorming Feature ideas for notification system
```

---

## Adding New Entry Points

1. Create source file in `agents/`, `workflows/`, or `skills/`
2. Create ONE canonical entry point following the pattern above
3. Optionally create ONE alias (short name) if canonical is long
4. Never create more than 2 entry points per entity
```

- [ ] **Step 2: Commit naming convention update**

```bash
git add protocols/naming-convention.md
git commit -m "docs(protocols): update naming-convention.md for em-agent/em-wf/em-skill prefixes"
```

---

## Task 8: Verify install.sh works

- [ ] **Step 1: Run install.sh**

```bash
bash install.sh
```

Expected output:
```
╔══════════════════════════════════════╗
║       EM-Team v3.2.0 Installer       ║
╚══════════════════════════════════════╝

[install] Cleaning old installs ...
[OK] Removed old ~/.claude/em-team/
[OK] Removed old ~/.claude/commands/em/
[install] Copying content to ~/.claude/em-team/ ...
[OK] Content copied:
[OK]   36 agents
[OK]   24 workflows
[OK]   76 skills
[install] Creating slash commands in ~/.claude/commands/em/ ...
[OK] Created 150+ slash commands

[install] Verifying installation ...
[OK]   Content directory: ~/.claude/em-team
[OK]   150+ slash commands in ~/.claude/commands/em
[OK]   @file references valid (em-agent:planner)
[OK]   3 lib files (session-audit, artifact-store, trace-store)

  Installation complete!
```

- [ ] **Step 2: Verify command files have correct name: fields**

```bash
# Check agents
head -3 ~/.claude/commands/em/planner.md
# Expected: name: em-agent:planner

head -3 ~/.claude/commands/em/new-feature.md
# Expected: name: em-wf:new-feature

head -3 ~/.claude/commands/em/brainstorming.md
# Expected: name: em-skill:brainstorming
```

- [ ] **Step 3: Verify consolidations**

```bash
# code-review entries: should be 2 (code-reviewer + code-review alias + code-review workflow)
ls ~/.claude/commands/em/ | grep "code-review"
# Expected: code-review.md, code-reviewer.md

# security entries: should be 3
ls ~/.claude/commands/em/ | grep "security"
# Expected: security-reviewer.md, security-audit.md, security-review-advanced.md
# NOT expected: security.md, security-auditor.md

# Deleted files should not produce commands
ls ~/.claude/commands/em/ | grep "senior-code-reviewer"
# Expected: empty
```

- [ ] **Step 4: Check total command count**

```bash
ls ~/.claude/commands/em/ | wc -l
```

Expected: ~153 commands (original 158 minus 5 deleted/merged).

- [ ] **Step 5: Run validate-hermes.sh**

```bash
bash scripts/validate-hermes.sh
```

Expected: All checks pass (frontmatter, block structure, schema presence).

- [ ] **Step 6: Commit final verification**

```bash
git add -A
git status
# If any stray changes, review and commit
git commit -m "verify: confirm install.sh works with new em-agent/em-wf/em-skill naming" --allow-empty
```

---

## Task 9: Smoke test key commands (manual)

After restarting Claude Code:

- [ ] **Step 1: Test agent invocation**

```
/em-agent:planner Create a plan for adding JWT authentication
```
Expected: Planner agent loads and creates a structured implementation plan.

- [ ] **Step 2: Test skill invocation**

```
/em-skill:brainstorming Ideas for improving API performance
```
Expected: Brainstorming skill loads and presents structured exploration.

- [ ] **Step 3: Test workflow invocation**

```
/em-wf:bug-fix There's a race condition in the login flow
```
Expected: Bug-fix workflow starts the systematic debugging process.

- [ ] **Step 4: Test consolidated code-review workflow**

```
/em-wf:code-review Review the recent changes to the auth module
```
Expected: 9-axis + OWASP security review runs (was em:code-review-9axis).

- [ ] **Step 5: Test consolidated security agent**

```
/em-agent:security-reviewer Audit the payment API for vulnerabilities
```
Expected: Security reviewer agent runs (was em:security-reviewer, em:security-auditor both consolidated here).

- [ ] **Step 6: Final commit if any fixes were needed**

```bash
git log --oneline -10
# Review the commit history looks clean
```

---

## Verification Summary

| Check | Command | Expected |
|-------|---------|----------|
| File naming | `ls .claude/skills/ \| grep "^em-" \| grep -v "^em-agent-\|^em-wf-\|^em-skill-"` | empty |
| Install runs | `bash install.sh` | no errors |
| Agent commands | `head -3 ~/.claude/commands/em/planner.md` | `name: em-agent:planner` |
| Workflow commands | `head -3 ~/.claude/commands/em/new-feature.md` | `name: em-wf:new-feature` |
| Skill commands | `head -3 ~/.claude/commands/em/brainstorming.md` | `name: em-skill:brainstorming` |
| Consolidation | `ls ~/.claude/commands/em/ \| grep "senior-code"` | empty |
| Hermes valid | `bash scripts/validate-hermes.sh` | all pass |
| CLAUDE.md clean | `grep -c "em:skill:\|em:planner\|em:new-feature" CLAUDE.md` | 0 |
