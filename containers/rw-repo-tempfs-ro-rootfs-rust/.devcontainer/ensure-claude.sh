#!/usr/bin/env bash
set -euo pipefail

export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-/home/vscode/.npm-global}"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

if command -v claude >/dev/null 2>&1; then
  echo "claude already present: $(command -v claude)"
  exit 0
fi

mkdir -p "$NPM_CONFIG_PREFIX"
npm config set prefix "$NPM_CONFIG_PREFIX"
npm install -g --prefix "$NPM_CONFIG_PREFIX" @anthropic-ai/claude-code
claude --version
