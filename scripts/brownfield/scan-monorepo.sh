#!/usr/bin/env bash
# Top-level scan for monorepo: detect each app's stack and dispatch.
# Usage: scan-monorepo.sh [root]
# Output: JSON {apps: [{name, stack, scan_result}], packages: [...]}

set -euo pipefail
ROOT="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

apps=()
packages=()

if [[ -d "${ROOT}/apps" ]]; then
  for app_dir in "${ROOT}"/apps/*/; do
    [[ ! -d "$app_dir" ]] && continue
    app_name=$(basename "$app_dir")

    # Detect app stack via its own package.json
    stack_json=$(bash "${SCRIPT_DIR}/detect-stack.sh" "$app_dir" 2>/dev/null || echo '{}')
    has_nestjs=false
    has_react=false
    echo "$stack_json" | grep -q '"nestjs"' && has_nestjs=true
    echo "$stack_json" | grep -qE '"react"|"nextjs"|"vite"' && has_react=true

    scan_result="{}"
    if [[ "$has_nestjs" == "true" ]] && [[ -d "${app_dir}/src" ]]; then
      scan_result=$(bash "${SCRIPT_DIR}/scan-nestjs.sh" "${app_dir}/src" 2>/dev/null || echo "[]")
    elif [[ "$has_react" == "true" ]] && [[ -d "${app_dir}/src" ]]; then
      scan_result=$(bash "${SCRIPT_DIR}/scan-react.sh" "${app_dir}/src" 2>/dev/null || echo '{"routes":[],"components":[]}')
    fi

    apps+=("{\"name\": \"$app_name\", \"path\": \"apps/$app_name\", \"stack\": $stack_json, \"scan\": $scan_result}")
  done
fi

if [[ -d "${ROOT}/packages" ]]; then
  for pkg_dir in "${ROOT}"/packages/*/; do
    [[ ! -d "$pkg_dir" ]] && continue
    pkg_name=$(basename "$pkg_dir")
    packages+=("{\"name\": \"$pkg_name\", \"path\": \"packages/$pkg_name\"}")
  done
fi

if [[ ${#apps[@]} -gt 0 ]]; then
  apps_json=$(IFS=,; echo "${apps[*]}")
else
  apps_json=""
fi
if [[ ${#packages[@]} -gt 0 ]]; then
  packages_json=$(IFS=,; echo "${packages[*]}")
else
  packages_json=""
fi

echo "{\"apps\": [$apps_json], \"packages\": [$packages_json]}"
