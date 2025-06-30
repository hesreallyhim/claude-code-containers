#!/bin/bash
set -e

echo "🚀 Starting Claude Code environment..."

# Initialize firewall
echo "Setting up network security..."
sudo /usr/local/bin/init-firewall.sh

# Set up Claude Code files and directories
echo "Setting up Claude Code workspace..."

# The workspace is already mounted at /workspace with project files (including any ./CLAUDE.md and ./.claude/)
# We need to handle the global user files separately

# In Docker, $HOME for the node user is /home/node
# We need to check if the host user has global Claude files and copy them

echo "Note: Project-level Claude files:"
if [ -f /workspace/CLAUDE.md ]; then
    echo "  ✓ Found ./CLAUDE.md in project workspace"
else
    echo "  - No ./CLAUDE.md in project workspace"
fi

if [ -d /workspace/.claude ]; then
    echo "  ✓ Found ./.claude/ directory in project workspace"
else
    echo "  - No ./.claude/ directory in project workspace"
fi

echo ""
echo "Note: For global Claude files (~/CLAUDE.md, ~/.claude/):"
echo "  These would need to be manually copied into the container if needed."
echo "  The container's \$HOME is /home/node"
echo "  Project-level and global Claude files are kept separate as intended."

# Ensure proper ownership of home directory
chown -R node:node /home/node

# Set up shell environment
export HISTFILE=/commandhistory/.bash_history
export PATH=$PATH:/usr/local/share/npm-global/bin

# Verify Claude Code installation
if command -v claude >/dev/null 2>&1; then
    echo "✓ Claude Code is ready"
    echo ""
    echo "📋 Quick Commands:"
    echo "  claude          - Start Claude Code"
    echo "  claude --help   - Show Claude Code help"
    echo "  git --version   - Check git installation"
    echo "  python3 --version - Check Python installation"
    echo "  pip install package - Install Python packages"
    echo ""
    echo "📁 Claude Code Files:"
    echo "  Project level:"
    echo "    ./CLAUDE.md     - Project-specific context (if exists)"
    echo "    ./.claude/      - Project-specific configuration (if exists)"
    echo "  Global level:"
    echo "    ~/CLAUDE.md     - User global context (copy manually if needed)"
    echo "    ~/.claude/      - User global configuration (/home/node/.claude/)"
    echo ""
else
    echo "⚠ Claude Code not found in PATH"
    echo "Attempting to reinstall..."
    npm install -g @anthropic-ai/claude-code
fi

echo "🎉 Environment ready! Run 'claude' to get started."
echo ""

# Start zsh shell
exec /bin/zsh