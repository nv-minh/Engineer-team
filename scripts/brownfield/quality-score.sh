#!/usr/bin/env bash
# Score a .em-brownfield/ directory for onboarding quality.
# Output JSON with per-dimension scores 0-100 + overall grade A/B/C/D.

set -euo pipefail
BF="${1:-.em-brownfield}"
if [[ ! -d "$BF" ]]; then
  echo '{"error": "not found"}'
  exit 1
fi

# Determine script directory to find sibling scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scores=()
issues=()

# D1: Domain profile completeness (0-100)
d1=0
if [[ -f "$BF/DOMAIN-PROFILE.yaml" ]]; then
  d1=20
  if grep -q "primary:" "$BF/DOMAIN-PROFILE.yaml" 2>/dev/null; then
    line=$(grep "primary:" "$BF/DOMAIN-PROFILE.yaml" 2>/dev/null | head -1)
    # Check primary has actual value (not empty quotes)
    if [[ "$line" != *'""'* ]] && [[ -n "$(echo "$line" | sed 's/.*primary:[[:space:]]*//' | tr -d '"' | tr -d ' ')" ]]; then
      d1=$((d1 + 20))
    fi
  fi
  grep -q "critical_business_operations:" "$BF/DOMAIN-PROFILE.yaml" 2>/dev/null && d1=$((d1 + 20))
  grep -q "p0_criteria:" "$BF/DOMAIN-PROFILE.yaml" 2>/dev/null && d1=$((d1 + 20))
  grep -q "domain_invariants:" "$BF/DOMAIN-PROFILE.yaml" 2>/dev/null && d1=$((d1 + 20))
else
  issues+=("\"missing DOMAIN-PROFILE.yaml\"")
fi
scores+=("\"domain_profile\": $d1")

# D2: Module structure completeness
total_mods=0
complete_mods=0
for mod in "$BF"/modules/*/; do
  [[ ! -d "$mod" ]] && continue
  total_mods=$((total_mods + 1))
  has_all=true
  for required in FLOWS.md DOMAIN.md INTEGRATIONS.md CODE-MAP.md; do
    [[ ! -f "${mod}${required}" ]] && has_all=false
  done
  $has_all && complete_mods=$((complete_mods + 1))
done
if [[ $total_mods -gt 0 ]]; then
  d2=$((complete_mods * 100 / total_mods))
else
  d2=0
fi
scores+=("\"module_completeness\": $d2")

# D3: Cross-reference integrity (run validator)
d3=0
if [[ -x "${SCRIPT_DIR}/validate-refs.sh" ]] && bash "${SCRIPT_DIR}/validate-refs.sh" "$BF" >/dev/null 2>&1; then
  d3=100
else
  d3=50  # has refs but some broken (or validator unavailable)
fi
scores+=("\"cross_references\": $d3")

# D4: Flow ID stability (all flows have FLOW-X-NNN IDs)
total_flows=0
ided_flows=0
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  flows_in_file=$(grep -c "^## Flow:" "$f" 2>/dev/null || echo 0)
  ids_in_file=$(grep -cE "^## Flow:.*FLOW-[A-Z_-]+-[0-9]+" "$f" 2>/dev/null || echo 0)
  total_flows=$((total_flows + flows_in_file))
  ided_flows=$((ided_flows + ids_in_file))
done < <(find "$BF" -name "FLOWS.md" 2>/dev/null || true)
if [[ $total_flows -gt 0 ]]; then
  d4=$((ided_flows * 100 / total_flows))
else
  d4=100
fi
scores+=("\"flow_ids\": $d4")

# D5: JSON sidecars present (rough estimate)
total_md=$(find "$BF" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
total_json=$(find "$BF" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
# Expect roughly half MD files to have JSON sidecars (INDEX + per-module FLOWS + CODE-MAP)
expected_json=$((total_md / 2))
if [[ $expected_json -gt 0 ]]; then
  d5=$((total_json * 100 / expected_json))
else
  d5=0
fi
[[ $d5 -gt 100 ]] && d5=100
scores+=("\"sidecars\": $d5")

# Overall
sum=$((d1 + d2 + d3 + d4 + d5))
overall=$((sum / 5))
grade="D"
if [[ $overall -ge 90 ]]; then
  grade="A"
elif [[ $overall -ge 75 ]]; then
  grade="B"
elif [[ $overall -ge 60 ]]; then
  grade="C"
fi

scores_json=$(IFS=,; echo "${scores[*]}")
if [[ ${#issues[@]} -gt 0 ]]; then
  issues_json=$(IFS=,; echo "${issues[*]}")
else
  issues_json=""
fi

cat <<EOF
{
  "schema_version": "5.4.0",
  "overall_score": $overall,
  "grade": "$grade",
  "scores": { $scores_json },
  "issues": [$issues_json],
  "total_modules": $total_mods,
  "complete_modules": $complete_mods,
  "total_flows": $total_flows,
  "flows_with_ids": $ided_flows
}
EOF
