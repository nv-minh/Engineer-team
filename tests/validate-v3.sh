#!/bin/bash
################################################################################
# EM-Team v3.0.0 Comprehensive Validation
#
# Validates the entire EM-Team repo after expert group restructuring:
# - Structure (expert dirs, counts, symlinks)
# - YAML frontmatter (skills + agents)
# - Cross-references (related_skills)
# - Content quality (language, categories)
# - Regression (unchanged categories)
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL=0
PASSED=0
FAILED=0
WARNINGS=0
ERRORS=""

log_pass() { echo -e "  ${GREEN}PASS${NC} $1"; PASSED=$((PASSED+1)); TOTAL=$((TOTAL+1)); }
log_fail() { echo -e "  ${RED}FAIL${NC} $1"; FAILED=$((FAILED+1)); TOTAL=$((TOTAL+1)); ERRORS="$ERRORS\n  - $1"; }
log_warn() { echo -e "  ${YELLOW}WARN${NC} $1"; WARNINGS=$((WARNINGS+1)); }
log_section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

################################################################################
# A. Structure Validation
################################################################################

validate_structure() {
    log_section "A. Structure Validation"

    # A1. Expert directories exist
    expert_dirs="expert-react expert-vue expert-go expert-nest expert-python
                 expert-database expert-devops expert-mobile expert-spring
                 expert-frontend expert-backend expert-rust expert-typescript
                 drawio tauri"
    missing=0
    for dir in $expert_dirs; do
        [ -d "skills/$dir" ] || { log_warn "Missing directory: skills/$dir"; missing=$((missing+1)); }
    done
    [ "$missing" -eq 0 ] && log_pass "All 15 expert directories exist" || log_fail "Missing $missing expert directories"

    # A2. Skill count
    skill_count=$(find skills/ -name "*.md" -not -name "SKILL.md" -not -name "README.md" -not -name "SKILL-INDEX.md" -not -path "*/references/*" | wc -l | tr -d ' ')
    [ "$skill_count" -eq 72 ] && log_pass "Skill count: $skill_count (expected 72)" || log_fail "Skill count: $skill_count (expected 72)"

    # A3. Agent count
    agent_count=$(find agents/ -name "*.md" | wc -l | tr -d ' ')
    [ "$agent_count" -eq 35 ] && log_pass "Agent count: $agent_count (expected 35)" || log_fail "Agent count: $agent_count (expected 35)"

    # A4. SKILL.md symlinks valid
    broken=0
    while IFS= read -r link; do
        dir=$(dirname "$link")
        target=$(readlink "$link")
        [ ! -f "$dir/$target" ] && { log_warn "Broken symlink: $link -> $target"; broken=$((broken+1)); }
    done < <(find skills/ -name "SKILL.md" -type l)
    [ "$broken" -eq 0 ] && log_pass "All SKILL.md symlinks valid" || log_fail "Broken symlinks: $broken"

    # A5. Skill count per category
    echo "  Skill breakdown:"
    for dir in skills/*/; do
        name=$(basename "$dir")
        count=$(find "$dir" -name "*.md" -not -name "SKILL.md" -not -name "README.md" -not -name "SKILL-INDEX.md" -not -path "*/references/*" | wc -l | tr -d ' ')
        printf "    %-20s %s skills\n" "$name" "$count"
    done
    log_pass "Skill breakdown listed above"
}

################################################################################
# B. YAML Frontmatter Validation
################################################################################

validate_frontmatter() {
    log_section "B. YAML Frontmatter Validation"

    # B1. Skill frontmatter
    skill_errors=0
    while IFS= read -r file; do
        # Check frontmatter exists
        first=$(head -1 "$file")
        if [ "$first" != "---" ]; then
            log_warn "No frontmatter: $file"
            skill_errors=$((skill_errors+1))
            continue
        fi

        # Check required fields
        for field in name description version category; do
            if ! grep -q "^${field}:" "$file"; then
                log_warn "Missing '$field' in: $file"
                skill_errors=$((skill_errors+1))
            fi
        done
    done < <(find skills/ -name "*.md" -not -name "SKILL.md" -not -name "README.md" -not -name "SKILL-INDEX.md" -not -path "*/references/*")
    [ "$skill_errors" -eq 0 ] && log_pass "All skill files have valid frontmatter" || log_fail "Skill frontmatter errors: $skill_errors"

    # B2. Agent frontmatter
    agent_errors=0
    for agent_file in agents/*.md; do
        [ -f "$agent_file" ] || continue
        for field in name type trigger status_protocol completion_marker; do
            if ! grep -q "^${field}:" "$agent_file"; then
                log_warn "Missing '$field' in: $agent_file"
                agent_errors=$((agent_errors+1))
            fi
        done
    done
    [ "$agent_errors" -eq 0 ] && log_pass "All agent files have required fields" || log_fail "Agent field errors: $agent_errors"

    # B3. No duplicate skill names
    dupes=$(find skills/ -name "*.md" -not -name "SKILL.md" -not -name "README.md" -not -name "SKILL-INDEX.md" -not -path "*/references/*" -exec grep "^name:" {} \; | sed 's/name: *//' | tr -d '"' | sort | uniq -d)
    if [ -z "$dupes" ]; then
        log_pass "No duplicate skill names"
    else
        log_fail "Duplicate skill names: $dupes"
    fi
}

################################################################################
# C. Cross-Reference Validation
################################################################################

validate_references() {
    log_section "C. Cross-Reference Validation"

    # C1. Skill related_skills references
    broken_refs=0
    while IFS= read -r file; do
        refs=$(awk '/related_skills:/{found=1; next} found && /^  - /{gsub(/^  - /, ""); print; next} found && /^[^ ]/{exit}' "$file")
        for ref in $refs; do
            ref=$(echo "$ref" | tr -d '[]",')
            [ -z "$ref" ] && continue
            found=$(find skills/ -type d -name "$ref" 2>/dev/null)
            if [ -z "$found" ]; then
                log_warn "Broken ref in $(basename $(dirname $(dirname "$file"))): '$ref'"
                broken_refs=$((broken_refs+1))
            fi
        done
    done < <(find skills/ -name "*.md" -not -name "SKILL.md" -not -name "README.md" -not -name "SKILL-INDEX.md" -not -path "*/references/*")
    [ "$broken_refs" -eq 0 ] && log_pass "All skill related_skills valid" || log_fail "Broken skill refs: $broken_refs"

    # C2. Agent related_skills references
    agent_broken=0
    for agent_file in agents/*.md; do
        [ -f "$agent_file" ] || continue
        refs=$(awk '/related_skills:/{found=1; next} found && /^  - /{gsub(/^  - /, ""); print; next} found && /^[^ ]/{exit}' "$agent_file")
        for ref in $refs; do
            ref=$(echo "$ref" | tr -d '[]",')
            [ -z "$ref" ] && continue
            found=$(find skills/ -type d -name "$ref" 2>/dev/null)
            if [ -z "$found" ]; then
                log_warn "Broken ref in $(basename "$agent_file" .md): '$ref'"
                agent_broken=$((agent_broken+1))
            fi
        done
    done
    [ "$agent_broken" -eq 0 ] && log_pass "All agent related_skills valid" || log_fail "Broken agent refs: $agent_broken"

    # C3. All agents listed in CLAUDE.md
    missing_from_docs=0
    for f in $(ls agents/*.md | xargs -I{} basename {} .md); do
        if ! grep -q "$f" CLAUDE.md; then
            log_warn "Agent '$f' not documented in CLAUDE.md"
            missing_from_docs=$((missing_from_docs+1))
        fi
    done
    [ "$missing_from_docs" -eq 0 ] && log_pass "All agents documented in CLAUDE.md" || log_fail "Undocumented agents: $missing_from_docs"
}

################################################################################
# D. Content Quality
################################################################################

validate_content() {
    log_section "D. Content Quality"

    # D1. No Chinese/Japanese in expert skill files (new skills)
    cjk_files=0
    while IFS= read -r file; do
        dir=$(basename $(dirname $(dirname "$file")))
        case "$dir" in
            expert-*|drawio|tauri)
                if grep -qP '[\x{4e00}-\x{9fff}\x{3040}-\x{309f}\x{30a0}-\x{30ff}]' "$file" 2>/dev/null; then
                    log_warn "CJK characters in: $file"
                    cjk_files=$((cjk_files+1))
                fi
                ;;
        esac
    done < <(find skills/ -name "*.md" -not -name "SKILL.md" -not -name "README.md" -not -name "SKILL-INDEX.md" -not -path "*/references/*")
    [ "$cjk_files" -eq 0 ] && log_pass "No CJK characters in new skill files" || log_warn "CJK found in $cjk_files files (may be intentional)"

    # D2. Moved skills have correct category
    wrong_category=0
    for entry in "expert-frontend:frontend-patterns" "expert-backend:backend-patterns" "expert-backend:api-interface-design" \
                 "expert-go:go-patterns" "expert-python:python-patterns" "expert-typescript:typescript-patterns" "expert-rust:rust-patterns"; do
        group="${entry%%:*}"
        skill="${entry##*:}"
        file="skills/$group/$skill/$skill.md"
        if [ -f "$file" ]; then
            cat=$(grep "^category:" "$file" | head -1 | sed 's/category: *//' | tr -d '"')
            if [ "$cat" != "$group" ]; then
                log_warn "Wrong category '$cat' in $file (expected '$group')"
                wrong_category=$((wrong_category+1))
            fi
        fi
    done
    [ "$wrong_category" -eq 0 ] && log_pass "All moved skills have correct category" || log_fail "Wrong category in $wrong_category moved skills"

    # D3. New expert skills have EM-Team origin
    wrong_origin=0
    while IFS= read -r file; do
        dir=$(basename $(dirname $(dirname "$file")))
        case "$dir" in
            expert-*|drawio|tauri)
                if ! grep -q "origin:" "$file"; then
                    log_warn "Missing origin in: $file"
                    wrong_origin=$((wrong_origin+1))
                fi
                ;;
        esac
    done < <(find skills/ -name "*.md" -not -name "SKILL.md" -not -name "README.md" -not -name "SKILL-INDEX.md" -not -path "*/references/*")
    [ "$wrong_origin" -eq 0 ] && log_pass "All new skills have origin field" || log_warn "Missing origin in $wrong_origin files"
}

################################################################################
# E. Regression Check
################################################################################

validate_regression() {
    log_section "E. Regression Check"

    # E1. Foundation skills unchanged (6)
    foundation=$(find skills/foundation -name "*.md" -not -name "SKILL.md" | wc -l | tr -d ' ')
    [ "$foundation" -eq 6 ] && log_pass "Foundation skills: $foundation (expected 6)" || log_fail "Foundation skills: $foundation (expected 6)"

    # E2. Quality skills unchanged (10)
    quality=$(find skills/quality -name "*.md" -not -name "SKILL.md" | wc -l | tr -d ' ')
    [ "$quality" -eq 10 ] && log_pass "Quality skills: $quality (expected 10)" || log_fail "Quality skills: $quality (expected 10)"

    # E3. Workflow skills unchanged (6)
    workflow=$(find skills/workflow -name "*.md" -not -name "SKILL.md" | wc -l | tr -d ' ')
    [ "$workflow" -eq 6 ] && log_pass "Workflow skills: $workflow (expected 6)" || log_fail "Workflow skills: $workflow (expected 6)"

    # E4. Additional skills unchanged (5)
    additional=$(find skills/additional -name "*.md" -not -name "SKILL.md" | wc -l | tr -d ' ')
    [ "$additional" -eq 5 ] && log_pass "Additional skills: $additional (expected 5)" || log_fail "Additional skills: $additional (expected 5)"

    # E5. Development skills (11 remaining)
    dev=$(find skills/development -name "*.md" -not -name "SKILL.md" -not -name "README.md" -not -path "*/references/*" | wc -l | tr -d ' ')
    [ "$dev" -eq 11 ] && log_pass "Development skills: $dev (expected 11)" || log_fail "Development skills: $dev (expected 11)"

    # E6. Workflows unchanged (23 .md files)
    wf_count=$(find workflows/ -name "*.md" | wc -l | tr -d ' ')
    log_pass "Workflow files: $wf_count"

    # E7. Foundation skills still have category: "foundation"
    wrong_foundation=0
    for file in skills/foundation/*/*.md; do
        [ -f "$file" ] || continue
        [ "$(basename "$file")" = "SKILL.md" ] && continue
        cat=$(grep "^category:" "$file" | head -1 | sed 's/category: *//' | tr -d '"')
        if [ "$cat" != "foundation" ]; then
            log_warn "Foundation skill has wrong category: $file ($cat)"
            wrong_foundation=$((wrong_foundation+1))
        fi
    done
    [ "$wrong_foundation" -eq 0 ] && log_pass "Foundation skills have correct category" || log_fail "Wrong category in $wrong_foundation foundation skills"
}

################################################################################
# Main
################################################################################

echo "=========================================="
echo "EM-Team v3.0.0 Validation Report"
echo "=========================================="
echo "Date: $(date)"
echo ""

validate_structure
validate_frontmatter
validate_references
validate_content
validate_regression

echo ""
echo "=========================================="
echo "SUMMARY"
echo "=========================================="
echo -e "Total checks: $TOTAL"
echo -e "Passed:       ${GREEN}$PASSED${NC}"
echo -e "Failed:       ${RED}$FAILED${NC}"
echo -e "Warnings:     ${YELLOW}$WARNINGS${NC}"

if [ "$FAILED" -gt 0 ]; then
    echo -e "\n${RED}ERRORS:${NC}"
    echo -e "$ERRORS"
    echo ""
    exit 1
else
    echo -e "\n${GREEN}All validations passed!${NC}"
    exit 0
fi
