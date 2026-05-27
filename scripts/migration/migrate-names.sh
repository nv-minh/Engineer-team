#!/bin/bash
# scripts/migration/migrate-names.sh
# Migrates .claude/skills/ entry points to new naming convention:
#   Agents:    em-{name}.md  → em-agent-{name}.md  (name: em-agent:{name})
#   Workflows: em-{name}.md  → em-wf-{name}.md     (name: em-wf:{name})
#   Skills:    em-skill-{name}.md unchanged         (name: em:skill:{name} → em-skill:{name})
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
  basename_f=$(basename "$file")
  name="${basename_f#em-skill-}"
  name="${name%.md}"

  if grep -q "^name: em-skill:" "$file"; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  sed -i '' "s|^name: em:skill:${name}|name: em-skill:${name}|" "$file"
  echo "  UPDATED: $basename_f → name: em-skill:$name"
  UPDATED=$((UPDATED + 1))
done

# ─── Step 2: Process already-renamed em-agent-* and em-wf-* files ───
echo ""
echo "--- Processing already-renamed wrappers ---"
for file in "$SKILLS_DIR"/em-agent-*.md "$SKILLS_DIR"/em-wf-*.md; do
  [[ ! -f "$file" ]] && continue
  basename_f=$(basename "$file")

  if [[ "$basename_f" == em-agent-* ]]; then
    name="${basename_f#em-agent-}"
    name="${name%.md}"
    expected_name="em-agent:$name"
  else
    name="${basename_f#em-wf-}"
    name="${name%.md}"
    expected_name="em-wf:$name"
  fi

  if grep -q "^name: $expected_name$" "$file"; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  sed -i '' "s|^name: .*|name: $expected_name|" "$file"
  echo "  UPDATED: $basename_f → name: $expected_name"
  UPDATED=$((UPDATED + 1))
done

# ─── Step 3: Process legacy em-*.md files (classify as agent or workflow) ───
echo ""
echo "--- Processing legacy em-*.md entry points ---"

for file in "$SKILLS_DIR"/em-*.md; do
  [[ ! -f "$file" ]] && continue
  basename_f=$(basename "$file")

  # Skip already-processed prefixes
  [[ "$basename_f" == em-skill-* ]] && continue
  [[ "$basename_f" == em-agent-* ]] && continue
  [[ "$basename_f" == em-wf-* ]] && continue

  name="${basename_f#em-}"
  name="${name%.md}"

  entity_type=""
  canonical_name=""

  # Check alias map using case (compatible with macOS bash 3.2)
  case "$name" in
    backend)     canonical_name="backend-expert";           entity_type="agent" ;;
    code-review) canonical_name="code-reviewer";           entity_type="agent" ;;
    database)    canonical_name="database-expert";         entity_type="agent" ;;
    debug)       canonical_name="debugger";                entity_type="agent" ;;
    frontend)    canonical_name="frontend-expert";         entity_type="agent" ;;
    performance) canonical_name="performance-auditor";     entity_type="agent" ;;
    research)    canonical_name="researcher";              entity_type="agent" ;;
    team)        canonical_name="team-lead";               entity_type="agent" ;;
    test)        canonical_name="test-engineer";           entity_type="agent" ;;
    verify)      canonical_name="verifier";                entity_type="agent" ;;
    checkpoint)  canonical_name="checkpoint";              entity_type="agent" ;;
    health)      canonical_name="health";                  entity_type="agent" ;;
    quick)       canonical_name="quick";                   entity_type="agent" ;;
    qa)          canonical_name="qa";                      entity_type="agent" ;;
    distributed) canonical_name="distributed-investigation"; entity_type="workflow" ;;
    incident)    canonical_name="incident-response";       entity_type="workflow" ;;
    refactor)    canonical_name="refactoring";             entity_type="workflow" ;;
    ship)        canonical_name="ship-workflow";           entity_type="workflow" ;;
  esac

  # Fall back to filesystem check if case didn't match
  if [[ -z "$entity_type" ]]; then
    if [[ -f "$AGENTS_DIR/$name.md" ]]; then
      entity_type="agent"
      canonical_name="$name"
    elif [[ -f "$WORKFLOWS_DIR/$name.md" ]]; then
      entity_type="workflow"
      canonical_name="$name"
    else
      echo "  UNKNOWN (no match): $basename_f — SKIPPED"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi
  fi

  if [[ "$entity_type" == "agent" ]]; then
    new_file="$SKILLS_DIR/em-agent-$name.md"
    new_name="em-agent:$name"
  else
    new_file="$SKILLS_DIR/em-wf-$name.md"
    new_name="em-wf:$name"
  fi

  # Update name: field
  sed -i '' "s|^name: em:.*|name: $new_name|" "$file"
  # Rename file
  mv "$file" "$new_file"
  echo "  RENAMED: $basename_f → $(basename "$new_file")  (name: $new_name)"
  RENAMED=$((RENAMED + 1))
done

echo ""
echo "=== Migration Summary ==="
echo "  Renamed:  $RENAMED files"
echo "  Updated:  $UPDATED name: fields"
echo "  Skipped:  $SKIPPED (already correct or unknown)"
echo ""
echo "Total entry points in .claude/skills/:"
ls "$SKILLS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' '
