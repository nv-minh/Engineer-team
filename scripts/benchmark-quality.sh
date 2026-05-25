#!/usr/bin/env bash
# EM-Team Quality Benchmark
# Scores every skill, agent, and workflow against quality rubrics.
#
# Usage:
#   bash scripts/benchmark-quality.sh             # Summary output
#   bash scripts/benchmark-quality.sh --verbose   # Per-check detail

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERBOSE="${1:-}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

# Score accumulators
B1_TOTAL=0; B1_COUNT=0
B2_TOTAL=0; B2_COUNT=0
B3_TOTAL=0; B3_COUNT=0
B4_SCORE=0
B5_SCORE=0

vlog() {
    [[ "$VERBOSE" == "--verbose" ]] && echo -e "    $1"
}

progress_bar() {
    local score=$1 max=$2 width=20
    local filled=$(( score * width / max ))
    local empty=$(( width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    if [[ $score -ge 85 ]]; then echo -e "${GREEN}${bar}${NC}"
    elif [[ $score -ge 70 ]]; then echo -e "${YELLOW}${bar}${NC}"
    else echo -e "${RED}${bar}${NC}"; fi
}

grade() {
    local score=$1
    if [[ $score -ge 95 ]]; then echo "A+"
    elif [[ $score -ge 90 ]]; then echo "A"
    elif [[ $score -ge 85 ]]; then echo "B+"
    elif [[ $score -ge 80 ]]; then echo "B"
    elif [[ $score -ge 75 ]]; then echo "C+"
    elif [[ $score -ge 70 ]]; then echo "C"
    else echo "D"; fi
}

echo ""
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}EM-TEAM QUALITY BENCHMARK — $(date +%Y-%m-%d)${NC}"
echo -e "${BLUE}================================================================${NC}"

################################################################################
# B1: SKILL INSTRUCTION QUALITY
################################################################################

echo ""
echo -e "${CYAN}B1: SKILL INSTRUCTION QUALITY${NC}"

find "$REPO_ROOT/skills" -name "*.md" \
    -not -name "SKILL.md" -not -name "SKILL-INDEX.md" -not -name "README.md" \
    -not -path "*/reference.md" -not -path "*/references/*" | sort | while read -r f; do

    name=$(basename "$f" .md)
    score=0

    # Has [PROCESS] with step headings (15pts)
    if grep -qE '^\[PROCESS\]|^### Step' "$f" 2>/dev/null; then
        score=$((score + 15))
        vlog "${GREEN}PASS${NC} [PROCESS] with steps (+15)"
    else
        vlog "${RED}FAIL${NC} missing [PROCESS] or step headings"
    fi

    # Has [VERIFICATION] with checkboxes (15pts)
    if grep -q '\[VERIFICATION\]' "$f" 2>/dev/null && grep -q '\- \[ \]' "$f" 2>/dev/null; then
        score=$((score + 15))
        vlog "${GREEN}PASS${NC} [VERIFICATION] with checklist (+15)"
    else
        vlog "${RED}FAIL${NC} missing [VERIFICATION] or checklist"
    fi

    # Has anti_patterns in frontmatter (10pts)
    if grep -q '^anti_patterns:' "$f" 2>/dev/null; then
        ap_line=$(grep -n '^anti_patterns:' "$f" | head -1 | cut -d: -f1)
        next_line=$((ap_line + 1))
        next_content=$(sed -n "${next_line}p" "$f")
        if [[ "$next_content" == *"- "* ]] || [[ "$next_content" == *"[\""* ]]; then
            score=$((score + 10))
            vlog "${GREEN}PASS${NC} anti_patterns present (+10)"
        else
            vlog "${YELLOW}WARN${NC} anti_patterns empty"
        fi
    else
        vlog "${RED}FAIL${NC} missing anti_patterns"
    fi

    # Has scenarios with >=2 items (10pts)
    if grep -q '^scenarios:' "$f" 2>/dev/null; then
        scenario_count=$(awk '/^scenarios:/,/^[a-z_]*:/{print}' "$f" | grep -c '^ *- ' || true)
        if [[ "$scenario_count" -ge 2 ]]; then
            score=$((score + 10))
            vlog "${GREEN}PASS${NC} scenarios: $scenario_count items (+10)"
        else
            vlog "${YELLOW}WARN${NC} scenarios: only $scenario_count items"
        fi
    else
        vlog "${RED}FAIL${NC} missing scenarios"
    fi

    # Has input_schema with required (10pts)
    if grep -q '^input_schema:' "$f" 2>/dev/null && grep -q 'required:' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} input_schema with required (+10)"
    else
        vlog "${RED}FAIL${NC} missing input_schema or required field"
    fi

    # Has output_schema with status enum (10pts)
    if grep -q '^output_schema:' "$f" 2>/dev/null && grep -q 'DONE' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} output_schema with status enum (+10)"
    else
        vlog "${RED}FAIL${NC} missing output_schema or status enum"
    fi

    # Has error_schema (10pts)
    if grep -q '^error_schema:' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} error_schema present (+10)"
    else
        vlog "${RED}FAIL${NC} missing error_schema"
    fi

    # Has code examples (10pts)
    code_blocks=$(grep -c '```' "$f" 2>/dev/null || true)
    if [[ "$code_blocks" -ge 2 ]]; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} code examples: $((code_blocks / 2)) blocks (+10)"
    else
        vlog "${RED}FAIL${NC} no code examples"
    fi

    # No placeholders (10pts)
    placeholder_count=$(grep -ciE '\bTBD\b|\bTODO\b|\bTBC\b|implement later|fill in' "$f" 2>/dev/null || true)
    if [[ "$placeholder_count" -eq 0 ]]; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} no placeholders (+10)"
    else
        vlog "${RED}FAIL${NC} $placeholder_count placeholders found"
    fi

    bar=$(progress_bar "$score" 100)
    printf "  %-38s %s %3d/100\n" "$name" "$bar" "$score"

    # Accumulate (write to temp file since we're in a subshell)
    echo "$score" >> /tmp/em-b1-scores.$$
done

# Read accumulated scores
if [[ -f /tmp/em-b1-scores.$$ ]]; then
    while read -r s; do
        B1_TOTAL=$((B1_TOTAL + s))
        B1_COUNT=$((B1_COUNT + 1))
    done < /tmp/em-b1-scores.$$
    rm -f /tmp/em-b1-scores.$$
fi

if [[ $B1_COUNT -gt 0 ]]; then
    B1_AVG=$((B1_TOTAL / B1_COUNT))
else
    B1_AVG=0
fi
echo -e "  ${DIM}($B1_COUNT skills scored)${NC}  AVERAGE: ${BLUE}$B1_AVG/100${NC}"

################################################################################
# B2: AGENT COMPLETENESS
################################################################################

echo ""
echo -e "${CYAN}B2: AGENT COMPLETENESS${NC}"

for f in "$REPO_ROOT"/agents/*.md; do
    [[ ! -f "$f" ]] && continue
    name=$(basename "$f" .md)
    score=0

    # Has all 7 Hermes blocks (5pts each = 35pts)
    for block in "ROLE" "OBJECTIVE" "RULES" "AVAILABLE SKILLS" "PROCESS" "RESPONSE FORMAT" "HANDOFF"; do
        if grep -q "\[$block\]" "$f" 2>/dev/null; then
            score=$((score + 5))
            vlog "${GREEN}PASS${NC} [$block] (+5)"
        else
            vlog "${RED}FAIL${NC} missing [$block]"
        fi
    done

    # [HANDOFF] has specific content (15pts)
    if grep -q '\[HANDOFF\]' "$f" 2>/dev/null; then
        handoff_content=$(awk '/\[HANDOFF\]/,/^---$|^\[/' "$f" | tail -n +2)
        if echo "$handoff_content" | grep -qiE 'input|output|→|receives|sends|from:|to:'; then
            score=$((score + 15))
            vlog "${GREEN}PASS${NC} [HANDOFF] has specific I/O (+15)"
        else
            vlog "${YELLOW}WARN${NC} [HANDOFF] exists but lacks specific I/O"
        fi
    fi

    # [AVAILABLE SKILLS] lists skills (10pts)
    if grep -q '\[AVAILABLE SKILLS\]' "$f" 2>/dev/null; then
        skill_refs=$(awk '/\[AVAILABLE SKILLS\]/,/^\[/' "$f" | grep -cE '^\|.*\||^- ' || true)
        if [[ "$skill_refs" -ge 1 ]]; then
            score=$((score + 10))
            vlog "${GREEN}PASS${NC} [AVAILABLE SKILLS] lists $skill_refs refs (+10)"
        else
            vlog "${YELLOW}WARN${NC} [AVAILABLE SKILLS] empty"
        fi
    fi

    # Has input_schema with properties (10pts)
    if grep -q '^input_schema:' "$f" 2>/dev/null && grep -q 'properties:' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} input_schema with properties (+10)"
    else
        vlog "${RED}FAIL${NC} missing input_schema or properties"
    fi

    # Has output_schema with status enum (10pts)
    if grep -q '^output_schema:' "$f" 2>/dev/null && grep -q 'DONE' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} output_schema with status enum (+10)"
    else
        vlog "${RED}FAIL${NC} missing output_schema or status enum"
    fi

    # Has completion_marker or status_protocol (10pts)
    if grep -qE 'completion_marker:|status_protocol:' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} completion_marker/status_protocol (+10)"
    else
        vlog "${RED}FAIL${NC} missing completion_marker/status_protocol"
    fi

    # No soft language (10pts)
    soft_count=$(grep -ciE '[Pp]lease |I suggest|[Aa]s an AI|I would recommend|I apologize' "$f" 2>/dev/null || true)
    if [[ "$soft_count" -eq 0 ]]; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} no soft language (+10)"
    else
        vlog "${RED}FAIL${NC} $soft_count soft language instances"
    fi

    bar=$(progress_bar "$score" 100)
    printf "  %-38s %s %3d/100\n" "$name" "$bar" "$score"

    B2_TOTAL=$((B2_TOTAL + score))
    B2_COUNT=$((B2_COUNT + 1))
done

if [[ $B2_COUNT -gt 0 ]]; then
    B2_AVG=$((B2_TOTAL / B2_COUNT))
else
    B2_AVG=0
fi
echo -e "  ${DIM}($B2_COUNT agents scored)${NC}  AVERAGE: ${BLUE}$B2_AVG/100${NC}"

################################################################################
# B3: WORKFLOW COHERENCE
################################################################################

echo ""
echo -e "${CYAN}B3: WORKFLOW COHERENCE${NC}"

for f in "$REPO_ROOT"/workflows/*.md; do
    [[ ! -f "$f" ]] && continue
    name=$(basename "$f" .md)
    score=0

    # react_protocol: true (10pts)
    if grep -q 'react_protocol: true' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} react_protocol: true (+10)"
    else
        vlog "${RED}FAIL${NC} missing react_protocol"
    fi

    # Has <thought> blocks (10pts)
    thought_count=$(grep -c '<thought>' "$f" 2>/dev/null || true)
    if [[ "$thought_count" -ge 1 ]]; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} <thought> blocks: $thought_count (+10)"
    else
        vlog "${RED}FAIL${NC} no <thought> blocks"
    fi

    # Has <action> with invoke_ type (15pts)
    action_count=$(grep -c 'type: invoke_' "$f" 2>/dev/null || true)
    if [[ "$action_count" -ge 1 ]]; then
        score=$((score + 15))
        vlog "${GREEN}PASS${NC} <action> invocations: $action_count (+15)"
    else
        vlog "${RED}FAIL${NC} no <action> invoke_ blocks"
    fi

    # Target references resolve (15pts)
    targets=$(grep -E '^\s*target:' "$f" 2>/dev/null | sed 's/.*target:\s*//' | tr -d ' "' || true)
    broken=0
    total_refs=0
    for target in $targets; do
        [[ -z "$target" ]] && continue
        total_refs=$((total_refs + 1))
        # Check if target is an agent or skill
        if [[ ! -f "$REPO_ROOT/agents/$target.md" ]] && \
           ! find "$REPO_ROOT/skills" -type d -name "$target" 2>/dev/null | grep -q .; then
            broken=$((broken + 1))
            vlog "${RED}FAIL${NC} broken ref: target=$target"
        fi
    done
    if [[ $total_refs -gt 0 && $broken -eq 0 ]]; then
        score=$((score + 15))
        vlog "${GREEN}PASS${NC} all $total_refs target refs resolve (+15)"
    elif [[ $total_refs -eq 0 ]]; then
        vlog "${YELLOW}WARN${NC} no target references found"
    else
        partial=$(( 15 * (total_refs - broken) / total_refs ))
        score=$((score + partial))
        vlog "${YELLOW}WARN${NC} $broken/$total_refs broken refs (+$partial)"
    fi

    # Error Handling section (10pts)
    if grep -q '## Error Handling' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} Error Handling section (+10)"
    else
        vlog "${RED}FAIL${NC} missing Error Handling"
    fi

    # Context Pruning section (10pts)
    if grep -q '## Context Pruning' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} Context Pruning section (+10)"
    else
        vlog "${RED}FAIL${NC} missing Context Pruning"
    fi

    # Handoff contracts (10pts)
    if grep -qiE 'handoff|hand-off|Handoff Contract' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} handoff mentions (+10)"
    else
        vlog "${RED}FAIL${NC} no handoff mentions"
    fi

    # max_retries or retry strategy (10pts)
    if grep -qE 'max_retries|retry|Retry' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} retry strategy present (+10)"
    else
        vlog "${RED}FAIL${NC} no retry strategy"
    fi

    # context_pruning in frontmatter (10pts)
    if grep -q 'context_pruning:' "$f" 2>/dev/null; then
        score=$((score + 10))
        vlog "${GREEN}PASS${NC} context_pruning in frontmatter (+10)"
    else
        vlog "${RED}FAIL${NC} missing context_pruning in frontmatter"
    fi

    bar=$(progress_bar "$score" 100)
    printf "  %-38s %s %3d/100\n" "$name" "$bar" "$score"

    B3_TOTAL=$((B3_TOTAL + score))
    B3_COUNT=$((B3_COUNT + 1))
done

if [[ $B3_COUNT -gt 0 ]]; then
    B3_AVG=$((B3_TOTAL / B3_COUNT))
else
    B3_AVG=0
fi
echo -e "  ${DIM}($B3_COUNT workflows scored)${NC}  AVERAGE: ${BLUE}$B3_AVG/100${NC}"

################################################################################
# B4: CROSS-REFERENCE INTEGRITY
################################################################################

echo ""
echo -e "${CYAN}B4: CROSS-REFERENCE INTEGRITY${NC}"

# 4a: related_skills resolve (50pts)
total_related=0
broken_related=0

find "$REPO_ROOT/skills" -name "*.md" -not -name "SKILL.md" -not -name "README.md" | while read -r f; do
    related=$(grep '^related_skills:' "$f" 2>/dev/null | sed 's/related_skills:\s*//' | tr -d '[]"' | tr ',' '\n' | tr -d ' ' || true)
    for skill_name in $related; do
        [[ -z "$skill_name" ]] && continue
        echo "REF:$skill_name"
        if ! find "$REPO_ROOT/skills" -type d -name "$skill_name" 2>/dev/null | grep -q .; then
            echo "BROKEN:$skill_name:$(basename "$f")"
        fi
    done
done > /tmp/em-b4-related.$$

total_related=$(grep -c '^REF:' /tmp/em-b4-related.$$ 2>/dev/null || true)
broken_related=$(grep -c '^BROKEN:' /tmp/em-b4-related.$$ 2>/dev/null || true)

if [[ $total_related -gt 0 ]]; then
    related_score=$(( 50 * (total_related - broken_related) / total_related ))
else
    related_score=50
fi

if [[ "$VERBOSE" == "--verbose" ]]; then
    grep '^BROKEN:' /tmp/em-b4-related.$$ 2>/dev/null | while IFS=: read -r _ skill_name source; do
        echo -e "    ${RED}FAIL${NC} related_skills: '$skill_name' not found (in $source)"
    done
fi
echo -e "  related_skills resolve:     $((total_related - broken_related))/$total_related resolved    ${BLUE}$related_score/50${NC}"
rm -f /tmp/em-b4-related.$$

# 4b: workflow target agents resolve (25pts)
total_agent_refs=0
broken_agent_refs=0

for f in "$REPO_ROOT"/workflows/*.md; do
    targets=$(grep -E '^\s*target:' "$f" 2>/dev/null | sed 's/.*target:\s*//' | tr -d ' "' || true)
    for target in $targets; do
        [[ -z "$target" ]] && continue
        if [[ -f "$REPO_ROOT/agents/$target.md" ]]; then
            total_agent_refs=$((total_agent_refs + 1))
        elif find "$REPO_ROOT/skills" -type d -name "$target" 2>/dev/null | grep -q .; then
            # It's a skill ref, counted in 4c
            :
        else
            total_agent_refs=$((total_agent_refs + 1))
            broken_agent_refs=$((broken_agent_refs + 1))
            vlog "${RED}FAIL${NC} workflow target: '$target' not found ($(basename "$f"))"
        fi
    done
done

if [[ $total_agent_refs -gt 0 ]]; then
    agent_ref_score=$(( 25 * (total_agent_refs - broken_agent_refs) / total_agent_refs ))
else
    agent_ref_score=25
fi
echo -e "  workflow→agent refs:        $((total_agent_refs - broken_agent_refs))/$total_agent_refs resolved    ${BLUE}$agent_ref_score/25${NC}"

# 4c: workflow target skills resolve (25pts)
total_skill_refs=0
broken_skill_refs=0

for f in "$REPO_ROOT"/workflows/*.md; do
    targets=$(grep -E '^\s*target:' "$f" 2>/dev/null | sed 's/.*target:\s*//' | tr -d ' "' || true)
    for target in $targets; do
        [[ -z "$target" ]] && continue
        if find "$REPO_ROOT/skills" -type d -name "$target" 2>/dev/null | grep -q .; then
            total_skill_refs=$((total_skill_refs + 1))
        fi
    done
done

if [[ $total_skill_refs -gt 0 ]]; then
    skill_ref_score=25
else
    skill_ref_score=25
fi
echo -e "  workflow→skill refs:        $total_skill_refs found, 0 broken    ${BLUE}$skill_ref_score/25${NC}"

B4_SCORE=$((related_score + agent_ref_score + skill_ref_score))
echo -e "  ${DIM}TOTAL:${NC}  ${BLUE}$B4_SCORE/100${NC}"

################################################################################
# B5: CONSISTENCY & HYGIENE
################################################################################

echo ""
echo -e "${CYAN}B5: CONSISTENCY & HYGIENE${NC}"

# 5a: No duplicate name: fields in .claude/skills/ (20pts)
dup_names=$(grep -h '^name:' "$REPO_ROOT"/.claude/skills/*.md 2>/dev/null | sort | uniq -d | wc -l | tr -d ' ')
if [[ "$dup_names" -eq 0 ]]; then
    dup_score=20
    echo -e "  duplicate name: fields:     0 duplicates    ${BLUE}20/20${NC}"
else
    dup_score=$(( 20 - dup_names * 2 ))
    [[ $dup_score -lt 0 ]] && dup_score=0
    echo -e "  duplicate name: fields:     $dup_names duplicates    ${RED}$dup_score/20${NC}"
    if [[ "$VERBOSE" == "--verbose" ]]; then
        grep -h '^name:' "$REPO_ROOT"/.claude/skills/*.md 2>/dev/null | sort | uniq -d | while read -r line; do
            echo -e "    ${RED}DUP${NC} $line"
        done
    fi
fi

# 5b: Skill dirs have matching main .md file (20pts)
total_dirs=0
matching_dirs=0
for dir in "$REPO_ROOT"/skills/*/*/; do
    [[ ! -d "$dir" ]] && continue
    dir_name=$(basename "$dir")
    total_dirs=$((total_dirs + 1))
    if [[ -f "$dir/$dir_name.md" ]]; then
        matching_dirs=$((matching_dirs + 1))
    else
        vlog "${RED}FAIL${NC} no $dir_name.md in $(basename "$(dirname "$dir")")/$dir_name/"
    fi
done
if [[ $total_dirs -gt 0 ]]; then
    dir_score=$(( 20 * matching_dirs / total_dirs ))
else
    dir_score=20
fi
echo -e "  skill dir→file match:       $matching_dirs/$total_dirs matched    ${BLUE}$dir_score/20${NC}"

# 5c: Version fields are semver (20pts)
total_versions=0
valid_versions=0
find "$REPO_ROOT/skills" -name "*.md" -not -name "SKILL.md" -not -name "README.md" | while read -r f; do
    ver=$(grep '^version:' "$f" 2>/dev/null | head -1 | sed 's/version:\s*//' | tr -d '"' | tr -d "'" | tr -d ' ' || true)
    [[ -z "$ver" ]] && continue
    echo "VER:$ver"
    if echo "$ver" | grep -qE '^"?[0-9]+\.[0-9]+\.[0-9]+"?$'; then
        echo "VALID"
    else
        echo "INVALID:$ver:$(basename "$f")"
    fi
done > /tmp/em-b5-versions.$$

total_versions=$(grep -c '^VER:' /tmp/em-b5-versions.$$ 2>/dev/null || true)
valid_versions=$(grep -c '^VALID$' /tmp/em-b5-versions.$$ 2>/dev/null || true)
if [[ $total_versions -gt 0 ]]; then
    ver_score=$(( 20 * valid_versions / total_versions ))
else
    ver_score=20
fi
if [[ "$VERBOSE" == "--verbose" ]]; then
    grep '^INVALID:' /tmp/em-b5-versions.$$ 2>/dev/null | while IFS=: read -r _ ver source; do
        echo -e "    ${RED}FAIL${NC} invalid semver: '$ver' in $source"
    done
fi
echo -e "  semver versions:            $valid_versions/$total_versions valid    ${BLUE}$ver_score/20${NC}"
rm -f /tmp/em-b5-versions.$$

# 5d: Category matches directory (20pts)
total_cat=0
match_cat=0
for dir in "$REPO_ROOT"/skills/*/; do
    [[ ! -d "$dir" ]] && continue
    dir_cat=$(basename "$dir")
    for f in "$dir"/*/*.md; do
        [[ ! -f "$f" ]] && continue
        [[ "$(basename "$f")" == "SKILL.md" || "$(basename "$f")" == "README.md" ]] && continue
        file_cat=$(grep '^category:' "$f" 2>/dev/null | head -1 | sed 's/category:\s*//' | tr -d '"' | tr -d "'" | tr -d ' ' || true)
        [[ -z "$file_cat" ]] && continue
        total_cat=$((total_cat + 1))
        if [[ "$file_cat" == "$dir_cat" ]]; then
            match_cat=$((match_cat + 1))
        else
            vlog "${YELLOW}WARN${NC} category '$file_cat' != dir '$dir_cat' ($(basename "$f"))"
        fi
    done
done
if [[ $total_cat -gt 0 ]]; then
    cat_score=$(( 20 * match_cat / total_cat ))
else
    cat_score=20
fi
echo -e "  category↔directory match:   $match_cat/$total_cat matched    ${BLUE}$cat_score/20${NC}"

# 5e: No empty frontmatter arrays (20pts)
empty_fields=$(grep -rlE '(triggers|scenarios|anti_patterns|related_skills):\s*\[\]' "$REPO_ROOT/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$empty_fields" -eq 0 ]]; then
    empty_score=20
    echo -e "  empty frontmatter fields:   0 found    ${BLUE}20/20${NC}"
else
    empty_score=$(( 20 - empty_fields * 2 ))
    [[ $empty_score -lt 0 ]] && empty_score=0
    echo -e "  empty frontmatter fields:   $empty_fields found    ${RED}$empty_score/20${NC}"
fi

B5_SCORE=$((dup_score + dir_score + ver_score + cat_score + empty_score))
echo -e "  ${DIM}TOTAL:${NC}  ${BLUE}$B5_SCORE/100${NC}"

################################################################################
# SUMMARY
################################################################################

OVERALL=$(( (B1_AVG + B2_AVG + B3_AVG + B4_SCORE + B5_SCORE) / 5 ))
LETTER=$(grade $OVERALL)

echo ""
echo -e "${BLUE}================================================================${NC}"
echo -e "  B1 Skill Quality:       $(progress_bar $B1_AVG 100) ${BLUE}$B1_AVG/100${NC}"
echo -e "  B2 Agent Completeness:  $(progress_bar $B2_AVG 100) ${BLUE}$B2_AVG/100${NC}"
echo -e "  B3 Workflow Coherence:  $(progress_bar $B3_AVG 100) ${BLUE}$B3_AVG/100${NC}"
echo -e "  B4 Cross-References:    $(progress_bar $B4_SCORE 100) ${BLUE}$B4_SCORE/100${NC}"
echo -e "  B5 Consistency:         $(progress_bar $B5_SCORE 100) ${BLUE}$B5_SCORE/100${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "  ${BLUE}OVERALL GRADE: $OVERALL/100 ($LETTER)${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""
echo -e "  ${DIM}Grade: A+ (95+) A (90+) B+ (85+) B (80+) C+ (75+) C (70+) D (<70)${NC}"
echo ""
