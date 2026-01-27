#!/usr/bin/env bash
set -euo pipefail

export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-/home/vscode/.npm-global}"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

# Version is pinned in docker-compose
# Fall back to latest here as a convenience
PINNED="${CLAUDE_CODE_VERSION:latest}"

have_version() {
  npm -g --prefix "$NPM_CONFIG_PREFIX" list --depth=0 --json @anthropic-ai/claude-code 2>/dev/null \
    | node -e 'let s="";process.stdin.on("data",d=>s+=d);process.stdin.on("end",()=>{try{let j=JSON.parse(s);let v=j.dependencies?.["@anthropic-ai/claude-code"]?.version||"";process.stdout.write(v)}catch{}})'
}

if ! command -v claude >/dev/null 2>&1; then
  mkdir -p "$NPM_CONFIG_PREFIX"
  npm config set prefix "$NPM_CONFIG_PREFIX"
  npm install -g --prefix "$NPM_CONFIG_PREFIX" "@anthropic-ai/claude-code@${PINNED}"
fi

INSTALLED="$(have_version || true)"
echo "Claude Code installed: ${INSTALLED:-unknown} (pinned: $PINNED)"

# Notify if newer exists (best-effort; don’t fail container if network is blocked)
LATEST="$(npm view @anthropic-ai/claude-code version 2>/dev/null || true)"
if [[ -n "$LATEST" && -n "$INSTALLED" && "$LATEST" != "$INSTALLED" ]]; then
  echo
  echo "Update available: @anthropic-ai/claude-code $INSTALLED -> $LATEST"
  echo "To upgrade (this sandbox):"
  echo "  npm install -g --prefix \"$NPM_CONFIG_PREFIX\" \"@anthropic-ai/claude-code@$LATEST\""
  echo "To update the pin (template): set CLAUDE_CODE_VERSION=$LATEST in docker-compose.yml"
  echo
fi
