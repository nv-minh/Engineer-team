#!/bin/bash
# artifact-register.sh — Manage EM-Team skill artifacts
# Usage:
#   bash scripts/artifact-register.sh list [category]    — List exported artifacts
#   bash scripts/artifact-register.sh stats              — Show artifact statistics
#   bash scripts/artifact-register.sh recent [days]      — Show recent artifacts
#   bash scripts/artifact-register.sh by-skill <name>    — Find artifacts by skill
#   bash scripts/artifact-register.sh clean [days]       — Remove artifacts older than N days (default 90)
#   bash scripts/artifact-register.sh workspace          — List all feature workspaces
#   bash scripts/artifact-register.sh workspace <slug>   — Show workspace details
#   bash scripts/artifact-register.sh context            — Show active feature context
#   bash scripts/artifact-register.sh switch <slug>      — Switch active workspace to an existing feature
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[artifacts]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

CATEGORIES="brainstorm specs plans reviews architecture security performance tests test-reports ux artifacts"

scan_artifacts() {
  local category="${1:-}"
  local workflow="${2:-}"
  for cat in ${CATEGORIES}; do
    [[ -n "$category" && "$cat" != "$category" ]] && continue
    local dir="$PROJECT_ROOT/$cat"
    [[ ! -d "$dir" ]] && continue
    # If workflow context filter is specified, only scan that sub-folder
    if [[ -n "$workflow" ]]; then
      dir="$dir/$workflow"
      [[ ! -d "$dir" ]] && continue
    fi
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      echo "$f"
    done < <(find "$dir" -maxdepth 2 -name '*.md')
  done
}

cmd_list() {
  local category="${1:-}"
  local workflow="${2:-}"
  echo ""
  info "Exported artifacts${category:+ in category: $category}${workflow:+ / workflow: $workflow}"
  echo ""

  local found=0
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    local basename
    basename=$(basename "$filepath")
    local dir
    dir=$(dirname "$filepath")
    local cat
    cat=$(basename "$dir")
    local parent
    parent=$(basename "$(dirname "$dir")")
    # Detect workflow context sub-folder (parent is a known category)
    local display_cat="$cat"
    for known_cat in ${CATEGORIES}; do
      if [[ "$parent" == "$known_cat" ]]; then
        display_cat="$parent/$cat"
        break
      fi
    done
    # Extract title from frontmatter
    local title=""
    if head -5 "$filepath" | grep -q "^title:"; then
      title=$(head -10 "$filepath" | grep "^title:" | head -1 | sed 's/^title: *//')
    fi
    echo "  [$display_cat] ${basename}${title:+ — $title}"
    found=$((found + 1))
  done < <(scan_artifacts "$category" "$workflow")

  [[ $found -eq 0 ]] && warn "No artifacts found" || true
  echo ""
}

cmd_stats() {
  echo ""
  info "Artifact statistics"
  echo ""

  local total=0
  for cat in ${CATEGORIES}; do
    local dir="$PROJECT_ROOT/$cat"
    [[ ! -d "$dir" ]] && continue
    local count
    count=$(find "$dir" -maxdepth 2 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt 0 ]]; then
      echo "  $cat: $count files"
      # Show sub-folder breakdown
      for subdir in "$dir"/*/; do
        [[ ! -d "$subdir" ]] && continue
        local subcount
        subcount=$(find "$subdir" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$subcount" -gt 0 ]]; then
          echo "    └─ $(basename "$subdir"): $subcount files"
        fi
      done
    fi
    total=$((total + count))
  done

  echo ""
  echo "  Total: $total artifacts"
  echo ""
}

cmd_recent() {
  local days="${1:-7}"
  echo ""
  info "Recent artifacts (last $days days)"
  echo ""

  local cutoff
  cutoff=$(date -v-${days}d +%Y%m%d 2>/dev/null || date -d "$days days ago" +%Y%m%d)

  local found=0
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    local basename
    basename=$(basename "$filepath")
    # Extract date prefix from filename (YYYY-MM-DD-HHMM)
    local file_date
    file_date=$(echo "$basename" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | tr -d '-' || true)
    [[ -z "$file_date" ]] && continue
    if [[ "$file_date" -ge "$cutoff" ]]; then
      local cat
      cat=$(basename "$(dirname "$filepath")")
      echo "  [$cat] $basename"
      found=$((found + 1))
    fi
  done < <(scan_artifacts)

  [[ $found -eq 0 ]] && warn "No recent artifacts" || true
  echo ""
}

cmd_by_skill() {
  local skill="$1"
  echo ""
  info "Artifacts from skill: $skill"
  echo ""

  local found=0
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    if head -10 "$filepath" | grep -q "skill: $skill"; then
      local basename
      basename=$(basename "$filepath")
      local cat
      cat=$(basename "$(dirname "$filepath")")
      echo "  [$cat] $basename"
      found=$((found + 1))
    fi
  done < <(scan_artifacts)

  [[ $found -eq 0 ]] && warn "No artifacts found for skill: $skill" || true
  echo ""
}

cmd_clean() {
  local days="${1:-90}"
  echo ""
  info "Cleaning artifacts older than $days days..."

  local cutoff
  cutoff=$(date -v-${days}d +%Y%m%d 2>/dev/null || date -d "$days days ago" +%Y%m%d)
  local removed=0

  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    local basename
    basename=$(basename "$filepath")
    local file_date
    file_date=$(echo "$basename" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | tr -d '-' || true)
    [[ -z "$file_date" ]] && continue
    if [[ "$file_date" -lt "$cutoff" ]]; then
      rm "$filepath"
      removed=$((removed + 1))
    fi
  done < <(scan_artifacts)

  ok "Removed $removed old artifacts"
  echo ""
}

WORKSPACE_ROOT="$PROJECT_ROOT/.em-artifacts"
FEATURE_CONTEXT="$PROJECT_ROOT/.em-feature-context"

cmd_workspace() {
  local slug="${1:-}"
  echo ""

  if [[ ! -d "$WORKSPACE_ROOT" ]]; then
    warn "No feature workspaces found (.em-artifacts/ does not exist)"
    echo ""
    return
  fi

  if [[ -z "$slug" ]]; then
    # List all workspaces
    info "Feature workspaces"
    echo ""
    local found=0
    for wt_dir in "$WORKSPACE_ROOT"/*/; do
      [[ ! -d "$wt_dir" ]] && continue
      local wt
      wt=$(basename "$wt_dir")
      for feat_dir in "$wt_dir"*/; do
        [[ ! -d "$feat_dir" ]] && continue
        local feat
        feat=$(basename "$feat_dir")
        local file_count
        file_count=$(find "$feat_dir" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
        local iter_count="?"
        if [[ -f "$FEATURE_CONTEXT" ]]; then
          local ctx_slug
          ctx_slug=$(grep '"featureSlug"' "$FEATURE_CONTEXT" 2>/dev/null | sed 's/.*: *"\(.*\)".*/\1/' || true)
          if [[ "$ctx_slug" == "$feat" ]]; then
            iter_count=$(grep '"iterations"' "$FEATURE_CONTEXT" 2>/dev/null | sed 's/.*: *\([0-9]*\).*/\1/' || echo "?")
          fi
        fi
        echo "  [$wt] $feat — $file_count files, $iter_count iterations"
        found=$((found + 1))
      done
    done
    [[ $found -eq 0 ]] && warn "No workspaces found" || true
  else
    # Show specific workspace
    local ws_path=""
    for wt_dir in "$WORKSPACE_ROOT"/*/; do
      [[ ! -d "$wt_dir" ]] && continue
      if [[ -d "$wt_dir$slug" ]]; then
        ws_path="$wt_dir$slug"
        break
      fi
    done

    if [[ -z "$ws_path" ]]; then
      warn "Workspace '$slug' not found"
      echo ""
      return
    fi

    info "Workspace: $slug"
    echo "  Path: $ws_path"
    echo ""

    # List all files
    echo "  Files:"
    while IFS= read -r f; do
      local rel
      rel="${f#$ws_path/}"
      echo "    $rel"
    done < <(find "$ws_path" -name '*.md' -o -name '*.json' -o -name '*.png' -o -name '*.webm' | sort)

    echo ""

    # Show iteration log tail if exists
    if [[ -f "$ws_path/ITERATION-LOG.md" ]]; then
      echo "  Recent iterations:"
      tail -20 "$ws_path/ITERATION-LOG.md" | sed 's/^/    /'
    fi
  fi
  echo ""
}

cmd_context() {
  echo ""
  if [[ -f "$FEATURE_CONTEXT" ]]; then
    info "Active feature context"
    echo ""
    cat "$FEATURE_CONTEXT" | sed 's/^/  /'
  else
    warn "No active feature context (.em-feature-context not found)"
  fi
  echo ""
}

cmd_switch() {
  local slug="${1:-}"
  echo ""

  if [[ -z "$slug" ]]; then
    # No slug provided — list available workspaces to help user pick
    warn "Usage: bash scripts/artifact-register.sh switch <feature-slug>"
    echo ""
    echo "  Available workspaces:"
    if [[ ! -d "$WORKSPACE_ROOT" ]]; then
      warn "  No workspaces found (.em-artifacts/ does not exist)"
      echo ""
      return 1
    fi
    for wt_dir in "$WORKSPACE_ROOT"/*/; do
      [[ ! -d "$wt_dir" ]] && continue
      local wt
      wt=$(basename "$wt_dir")
      for feat_dir in "$wt_dir"*/; do
        [[ ! -d "$feat_dir" ]] && continue
        local feat
        feat=$(basename "$feat_dir")
        local file_count
        file_count=$(find "$feat_dir" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
        # Check if this is the active one
        local active=""
        if [[ -f "$FEATURE_CONTEXT" ]]; then
          local ctx_slug
          ctx_slug=$(grep '"featureSlug"' "$FEATURE_CONTEXT" 2>/dev/null | sed 's/.*: *"\(.*\)".*/\1/' || true)
          [[ "$ctx_slug" == "$feat" ]] && active=" (active)"
        fi
        echo "    [$wt] $feat — $file_count files${active}"
      done
    done
    echo ""
    echo "  Example: bash scripts/artifact-register.sh switch user-dashboard"
    echo ""
    return 1
  fi

  # Find workspace matching slug
  if [[ ! -d "$WORKSPACE_ROOT" ]]; then
    warn "No workspaces found (.em-artifacts/ does not exist)"
    echo ""
    return 1
  fi

  local ws_path=""
  local ws_workflow_type=""
  for wt_dir in "$WORKSPACE_ROOT"/*/; do
    [[ ! -d "$wt_dir" ]] && continue
    if [[ -d "$wt_dir$slug" ]]; then
      ws_path="$wt_dir$slug"
      ws_workflow_type=$(basename "$wt_dir")
      break
    fi
  done

  if [[ -z "$ws_path" ]]; then
    warn "Workspace '$slug' not found in .em-artifacts/"
    echo ""
    echo "  Available slugs:"
    for wt_dir in "$WORKSPACE_ROOT"/*/; do
      [[ ! -d "$wt_dir" ]] && continue
      for feat_dir in "$wt_dir"*/; do
        [[ ! -d "$feat_dir" ]] && continue
        echo "    $(basename "$feat_dir")"
      done
    done
    echo ""
    return 1
  fi

  # Read existing iteration count from ITERATION-LOG.md if available
  local iterations=0
  if [[ -f "$ws_path/ITERATION-LOG.md" ]]; then
    iterations=$(grep -c "^## Iteration" "$ws_path/ITERATION-LOG.md" 2>/dev/null || echo "0")
  fi

  # Derive feature name from slug (replace hyphens with spaces, title case)
  local feature_name
  feature_name=$(echo "$slug" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')

  # Generate .em-feature-context
  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  cat > "$FEATURE_CONTEXT" << CTXEOF
{
  "workflowType": "$ws_workflow_type",
  "featureSlug": "$slug",
  "featureName": "$feature_name",
  "workspacePath": ".em-artifacts/$ws_workflow_type/$slug",
  "createdAt": "$now",
  "iterations": $iterations,
  "lastUpdated": "$now"
}
CTXEOF

  ok "Switched to workspace: $slug"
  echo ""
  echo "  Workflow:   $ws_workflow_type"
  echo "  Path:       .em-artifacts/$ws_workflow_type/$slug"
  echo "  Iterations: $iterations"
  echo ""
  echo "  .em-feature-context updated. Next prompt will use this workspace."
  echo ""
}

# ─── Main ───
case "${1:-list}" in
  list)      cmd_list "${2:-}" "${3:-}" ;;
  stats)     cmd_stats ;;
  recent)    cmd_recent "${2:-7}" ;;
  by-skill)  cmd_by_skill "${2:-brainstorming}" ;;
  clean)     cmd_clean "${2:-90}" ;;
  workspace) cmd_workspace "${2:-}" ;;
  context)   cmd_context ;;
  switch)    cmd_switch "${2:-}" ;;
  *)
    echo "Usage: bash scripts/artifact-register.sh {list|stats|recent|by-skill|clean|workspace|context|switch}"
    echo "  list [category] [workflow]  — List artifacts (e.g., list specs new-feature)"
    echo "  stats                       — Show statistics with workflow breakdown"
    echo "  recent [days]               — Show recent artifacts"
    echo "  by-skill <name>             — Find by skill name"
    echo "  clean [days]                — Remove old artifacts (default 90 days)"
    echo "  workspace [slug]            — List workspaces or show workspace details"
    echo "  context                     — Show active feature context"
    echo "  switch <slug>               — Switch active workspace to an existing feature"
    exit 1
    ;;
esac
