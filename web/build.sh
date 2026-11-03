#!/usr/bin/env bash
# Build the PokeSurvivor web release for arcade.azhang.me/pokesurvivor/.
#   web/build.sh           export + package into web/dist
#   web/build.sh deploy    ...then deploy the fin-fur-pokesurvivor Worker
set -euo pipefail
cd "$(dirname "$0")/.."
ARCADE=/run/media/adam-zhang/SERVE/Projects/ChatGPT/Arcade

mkdir -p build/web
godot --headless --path . --export-release "Web" build/web/index.html
node web/package.mjs build/web web/dist

if [[ "${1:-}" == "deploy" ]]; then
  # Reuse the Arcade checkout's Wrangler and OAuth login (kept in its ignored .local-config/).
  XDG_CONFIG_HOME="$ARCADE/.local-config" node "$ARCADE/node_modules/wrangler/bin/wrangler.js" \
    deploy --config web/wrangler.json
fi
