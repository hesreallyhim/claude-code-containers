#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  launchbox.sh <REPO_URL> [SANDBOX_DIR]

Examples:
  ./scripts/launchbox.sh https://github.com/org/project.git
  ./scripts/launchbox.sh git@github.com:org/project.git ./sandboxes/project

What it does:
  - Creates SANDBOX_DIR (default: ./sandbox-<repo-name>)
  - Copies this template's .devcontainer/ into SANDBOX_DIR/.devcontainer/
  - Clones REPO_URL into SANDBOX_DIR/repo/
  - Copies README.md + Makefile into SANDBOX_DIR/ (if present next to this script)
  - Optionally opens VS Code if `code` is available

Notes:
  - You must run this script from the template repo (the one that contains .devcontainer/).
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${#}" -lt 1 ]]; then
  usage
  exit 0
fi

REPO_URL="$1"
SANDBOX_DIR="${2:-}"

# Derive a default sandbox name from the repo url.
repo_name="$(basename "${REPO_URL%.git}")"
if [[ -z "${SANDBOX_DIR}" ]]; then
  SANDBOX_DIR="./sandbox-${repo_name}"
fi

TEMPLATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVCONTAINER_SRC="${TEMPLATE_ROOT}/.devcontainer"

if [[ ! -d "${DEVCONTAINER_SRC}" ]]; then
  echo "ERROR: .devcontainer/ not found at: ${DEVCONTAINER_SRC}" >&2
  exit 1
fi

if [[ -e "${SANDBOX_DIR}" ]]; then
  echo "ERROR: Sandbox dir already exists: ${SANDBOX_DIR}" >&2
  exit 1
fi

echo "Creating sandbox: ${SANDBOX_DIR}"
mkdir -p "${SANDBOX_DIR}"

echo "Copying .devcontainer/"
cp -R "${DEVCONTAINER_SRC}" "${SANDBOX_DIR}/.devcontainer"

# Optional conveniences if they exist in the template root
for f in README.md Makefile; do
  if [[ -f "${TEMPLATE_ROOT}/${f}" ]]; then
    echo "Copying ${f}"
    cp "${TEMPLATE_ROOT}/${f}" "${SANDBOX_DIR}/${f}"
  fi
done

echo "Cloning repo into ${SANDBOX_DIR}/repo"
git clone --depth 1 "${REPO_URL}" "${SANDBOX_DIR}/repo"

cat <<EOF

✅ Sandbox ready.

Next:
  cd "${SANDBOX_DIR}"
  # Option A: open in VS Code (then "Reopen in Container")
  code .

  # Option B: build/start container headless
  make up
  make shell

Teardown:
  make down

EOF

if command -v code >/dev/null 2>&1; then
  echo "Opening VS Code..."
  (cd "${SANDBOX_DIR}" && code .) >/dev/null 2>&1 || true
else
  echo "VS Code 'code' CLI not found; skipping auto-open."
fi

# chmod +x scripts/launchbox.sh
# ./scripts/launchbox.sh https://github.com/org/project.git
# # or
# make new REPO=https://github.com/org/project.git DIR=./sandboxes/project
