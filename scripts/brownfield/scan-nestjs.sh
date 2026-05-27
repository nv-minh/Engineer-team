#!/usr/bin/env bash
# Scan NestJS modules: find @Controller, @Module, route mappings.
# Usage: scan-nestjs.sh [src_root]
# Output: JSON array of {module, controllers, routes, providers}

set -euo pipefail
SRC="${1:-apps/api/src}"

[[ ! -d "$SRC" ]] && { echo "[]"; exit 0; }

modules=()
while IFS= read -r module_file; do
  [[ -z "$module_file" ]] && continue
  module_dir=$(dirname "$module_file")
  module_name=$(basename "$module_dir")

  # Find controllers
  controllers=()
  while IFS= read -r ctrl_file; do
    [[ -z "$ctrl_file" ]] && continue
    ctrl_name=$(grep -oE '@Controller\([^)]*\)' "$ctrl_file" | head -1 || true)
    base_path=$(echo "$ctrl_name" | grep -oE "'[^']+'|\"[^\"]+\"" | tr -d "'\"" | head -1 || true)
    class_name=$(grep -oE 'export class \w+' "$ctrl_file" | sed 's/export class //' | head -1 || true)

    # Find route handlers
    routes=()
    while IFS= read -r route_line; do
      [[ -z "$route_line" ]] && continue
      method=$(echo "$route_line" | grep -oE '@(Get|Post|Put|Delete|Patch)' | head -1 | tr -d '@' || true)
      path=$(echo "$route_line" | grep -oE "@${method}\(['\"][^'\"]*['\"]\)" | grep -oE "'[^']+'|\"[^\"]+\"" | tr -d "'\"" | head -1 || true)
      [[ -n "$method" ]] && routes+=("\"${method} ${base_path}/${path}\"")
    done < <(grep -nE '@(Get|Post|Put|Delete|Patch)\(' "$ctrl_file" 2>/dev/null || true)

    if [[ ${#routes[@]} -gt 0 ]]; then
      routes_json=$(IFS=,; echo "${routes[*]}")
    else
      routes_json=""
    fi
    [[ -n "$class_name" ]] && controllers+=("{\"class\": \"$class_name\", \"file\": \"$ctrl_file\", \"routes\": [$routes_json]}")
  done < <(find "$module_dir" -maxdepth 2 -name "*.controller.ts" 2>/dev/null || true)

  if [[ ${#controllers[@]} -gt 0 ]]; then
    ctrls_json=$(IFS=,; echo "${controllers[*]}")
  else
    ctrls_json=""
  fi

  # Find providers (services)
  providers=()
  while IFS= read -r svc_file; do
    [[ -z "$svc_file" ]] && continue
    svc_class=$(grep -oE 'export class \w+Service' "$svc_file" | sed 's/export class //' | head -1 || true)
    [[ -n "$svc_class" ]] && providers+=("\"$svc_class\"")
  done < <(find "$module_dir" -maxdepth 2 -name "*.service.ts" 2>/dev/null || true)

  if [[ ${#providers[@]} -gt 0 ]]; then
    providers_json=$(IFS=,; echo "${providers[*]}")
  else
    providers_json=""
  fi

  modules+=("{\"module\": \"$module_name\", \"module_file\": \"$module_file\", \"controllers\": [$ctrls_json], \"providers\": [$providers_json]}")
done < <(find "$SRC" -name "*.module.ts" -not -name "app.module.ts" 2>/dev/null || true)

if [[ ${#modules[@]} -gt 0 ]]; then
  modules_json=$(IFS=,; echo "${modules[*]}")
else
  modules_json=""
fi
echo "[$modules_json]"
