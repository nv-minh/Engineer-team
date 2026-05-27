#!/usr/bin/env bash
# Detect tech stack of a brownfield project. Output JSON.
# Usage: detect-stack.sh [path]

set -euo pipefail
ROOT="${1:-.}"

detected=()
monorepo=false
package_managers=()

# Monorepo detection
[[ -f "${ROOT}/pnpm-workspace.yaml" ]] && monorepo=true && package_managers+=("pnpm")
[[ -f "${ROOT}/lerna.json" ]] && monorepo=true && package_managers+=("lerna")
[[ -f "${ROOT}/nx.json" ]] && monorepo=true && package_managers+=("nx")
[[ -f "${ROOT}/turbo.json" ]] && monorepo=true && package_managers+=("turbo")
[[ -d "${ROOT}/apps" ]] || [[ -d "${ROOT}/packages" ]] && monorepo=true

# Frontend frameworks
if [[ -f "${ROOT}/package.json" ]] || ls "${ROOT}"/apps/*/package.json &>/dev/null; then
  pkgs=$(cat "${ROOT}/package.json" 2>/dev/null; cat "${ROOT}"/apps/*/package.json 2>/dev/null || true)
  echo "$pkgs" | grep -q '"next"' && detected+=("nextjs")
  echo "$pkgs" | grep -q '"vite"' && detected+=("vite")
  echo "$pkgs" | grep -q '"react"' && detected+=("react")
  echo "$pkgs" | grep -q '"vue"' && detected+=("vue")
  echo "$pkgs" | grep -q '"@angular/core"' && detected+=("angular")
  echo "$pkgs" | grep -q '"svelte"' && detected+=("svelte")

  # Backend frameworks (TS/JS)
  echo "$pkgs" | grep -q '"@nestjs/core"' && detected+=("nestjs")
  echo "$pkgs" | grep -q '"express"' && detected+=("express")
  echo "$pkgs" | grep -q '"fastify"' && detected+=("fastify")
  echo "$pkgs" | grep -qE '"@apollo/server|"graphql"' && detected+=("graphql")
fi

# Python
[[ -f "${ROOT}/requirements.txt" ]] || [[ -f "${ROOT}/pyproject.toml" ]] && {
  reqs=$(cat "${ROOT}/requirements.txt" "${ROOT}/pyproject.toml" 2>/dev/null || true)
  echo "$reqs" | grep -qi 'fastapi' && detected+=("fastapi")
  echo "$reqs" | grep -qi 'django' && detected+=("django")
  echo "$reqs" | grep -qi 'flask' && detected+=("flask")
}

# Go
[[ -f "${ROOT}/go.mod" ]] && {
  detected+=("go")
  grep -q 'gin-gonic' "${ROOT}/go.mod" 2>/dev/null && detected+=("gin")
  grep -q 'echo' "${ROOT}/go.mod" 2>/dev/null && detected+=("echo")
}

# Java/Kotlin/Spring
[[ -f "${ROOT}/pom.xml" ]] || [[ -f "${ROOT}/build.gradle" ]] || [[ -f "${ROOT}/build.gradle.kts" ]] && {
  detected+=("jvm")
  grep -qE 'spring-boot|spring-framework' "${ROOT}/pom.xml" "${ROOT}/build.gradle"* 2>/dev/null && detected+=("spring-boot")
}

# Rust
[[ -f "${ROOT}/Cargo.toml" ]] && {
  detected+=("rust")
  grep -q 'actix-web\|axum\|rocket' "${ROOT}/Cargo.toml" && detected+=("rust-web")
}

# Databases
[[ -f "${ROOT}/prisma/schema.prisma" ]] || ls "${ROOT}"/apps/*/prisma/schema.prisma &>/dev/null && detected+=("prisma")
grep -rq "mongoose" "${ROOT}/package.json" 2>/dev/null && detected+=("mongoose")
grep -rq "typeorm" "${ROOT}/package.json" 2>/dev/null && detected+=("typeorm")

# Test frameworks
grep -rq '"playwright"\|"@playwright/test"' "${ROOT}/package.json" 2>/dev/null && detected+=("playwright")
grep -rq '"jest"' "${ROOT}/package.json" 2>/dev/null && detected+=("jest")
grep -rq '"vitest"' "${ROOT}/package.json" 2>/dev/null && detected+=("vitest")

# Format output (guard against empty arrays in older bash with nounset)
join_json_array() {
  local arr_name="$1"
  eval "local n=\${#$arr_name[@]}"
  if [[ "$n" -eq 0 ]]; then
    printf ''
    return
  fi
  eval "printf '\"%s\",' \"\${$arr_name[@]}\"" | sed 's/,$//'
}

detected_json=$(join_json_array detected)
pm_json=$(join_json_array package_managers)

# Build apps + packages lists with proper JSON via shell logic (avoid jq dependency)
apps_list=$( (ls -d "${ROOT}"/apps/*/ 2>/dev/null || true) | xargs -n1 basename 2>/dev/null | awk 'BEGIN{first=1} {if(first){first=0;printf "\""$0"\""}else{printf ",\""$0"\""}}')
pkgs_list=$( (ls -d "${ROOT}"/packages/*/ 2>/dev/null || true) | xargs -n1 basename 2>/dev/null | awk 'BEGIN{first=1} {if(first){first=0;printf "\""$0"\""}else{printf ",\""$0"\""}}')

cat <<EOF
{
  "monorepo": $monorepo,
  "package_managers": [$pm_json],
  "stack": [$detected_json],
  "apps": [$apps_list],
  "packages": [$pkgs_list]
}
EOF
