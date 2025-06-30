# Setup Instructions - Minimal Claude Code DevContainer

## Quick Setup

1. **Create the directory structure:**

   ```bash
   mkdir -p .devcontainer/scripts
   ```

2. **Save the configuration files:**

   Save each of the provided artifacts to these locations:

   - `devcontainer.json` → `.devcontainer/devcontainer.json`
   - `Dockerfile` → `.devcontainer/Dockerfile`
   - `init-firewall.sh` → `.devcontainer/scripts/init-firewall.sh`
   - `startup.sh` → `.devcontainer/scripts/startup.sh`

3. **Set script permissions:**

   ```bash
   chmod +x .devcontainer/scripts/*.sh
   ```

4. **Open in VS Code:**

   ```bash
   code .
   ```

5. **Reopen in Container:**
   When VS Code prompts, click "Reopen in Container"

6. **Wait for build:**
   First time will take 2-3 minutes to build the container

7. **Start using Claude Code:**
   ```bash
   claude
   ```

## What You Get

### ✅ Included Features

- **Claude Code**: Latest version installed globally
- **Claude Code Files**: Automatic setup of `~/CLAUDE.md` and `~/.claude/` directories
- **Development Tools**: git, zsh, fzf, vim, Python 3, pip, and essential CLI tools
- **Network Security**: Firewall with whitelist-only access to:
  - GitHub (API and git operations)
  - npm registry
  - Anthropic APIs
  - **PyPI and Python package repositories**
  - **PyPI CDN networks (Fastly)**
- **Persistent Storage**:
  - Workspace files
  - Command history
  - Claude configuration
  - **Claude Code reserved files (`CLAUDE.md`, `.claude/`)**
- **VS Code Integration**: Extensions and settings for development

## Claude Code Files

The container properly handles Claude Code's dual file system:

### Project-Level Files (automatically included)

- **`./CLAUDE.md`** - Project-specific context and instructions
- **`./.claude/`** - Project-specific configuration and commands
- **Included automatically** when you mount your workspace
- **Separate from global files** - no linking or copying

### Global User Files (manual setup if needed)

- **`~/CLAUDE.md`** - User's global context (container path: `/home/node/CLAUDE.md`)
- **`~/.claude/`** - User's global configuration (container path: `/home/node/.claude/`)
- **Not automatically copied** - these are user-specific, not project-specific
- **To include**: Copy manually into container or create as needed

### File Separation

- ✅ Project files stay in `/workspace/` (your project directory)
- ✅ Global files go in `/home/node/` (container's $HOME)
- ✅ No symlinks or automatic copying between them
- ✅ Claude Code can access both levels independently

### If You Have Global Claude Files

If you have `~/CLAUDE.md` or `~/.claude/` on your host machine that you want in the container:

```bash
# Option 1: Copy during container startup
docker cp ~/CLAUDE.md container-name:/home/node/CLAUDE.md
docker cp ~/.claude/ container-name:/home/node/.claude/

# Option 2: Add to your project and copy manually
# (This is usually not recommended as global files are user-specific)
```

### Typical Workspace Structure

```
/workspace/                    # Your project (mounted from host)
├── CLAUDE.md                 # Project-specific instructions
├── .claude/                  # Project-specific config
│   ├── commands/
│   └── config/
├── src/
└── ...

/home/node/                   # Container user home
├── CLAUDE.md                 # Global user instructions (if copied)
└── .claude/                  # Global user config (if copied)
    ├── commands/
    └── config/
```

```bash
# Check Claude Code installation
claude --version

# Check what Claude files exist
echo "Project-level files:"
ls -la ./CLAUDE.md ./.claude/ 2>/dev/null || echo "  None found"

echo "Global-level files:"
ls -la ~/CLAUDE.md ~/.claude/ 2>/dev/null || echo "  None found"

# Test network access (should work)
curl -s https://api.github.com/zen
curl -s https://pypi.org/simple/

# Test Python package installation
pip install requests

# Test blocked access (should fail)
curl -s --connect-timeout 5 https://example.com

# Check firewall rules
sudo iptables -L -n
```

## Troubleshooting

## Verification

After the container starts, verify everything is working:

### Container won't build

```bash
# Clear Docker cache
docker system prune -f
docker builder prune -f

# Try building again
```

### Claude Code not found

```bash
# Reinstall inside container
npm install -g @anthropic-ai/claude-code
```

### Network issues

```bash
# Re-run firewall setup
sudo /usr/local/bin/init-firewall.sh
```

### VS Code extensions not loading

```bash
# Rebuild container
Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

## Customization

### Add allowed domains

Edit `.devcontainer/scripts/init-firewall.sh` and add domains to the resolution loop:

```bash
for domain in "registry.npmjs.org" "api.anthropic.com" "pypi.org" "files.pythonhosted.org" "your-domain.com"; do
```

### Add VS Code extensions

Edit `.devcontainer/devcontainer.json` and add to the extensions array:

```json
"extensions": [
  "existing.extension",
  "your.new-extension"
]
```

### Change shell configuration

The container uses zsh by default. Customize by editing `~/.zshrc` inside the container.

## File Structure

```
.devcontainer/
├── devcontainer.json       # VS Code configuration
├── Dockerfile             # Container definition
└── scripts/
    ├── init-firewall.sh   # Network security setup
    └── startup.sh         # Container initialization
```

This minimal setup provides everything needed for Claude Code development with security, while keeping the configuration simple and build times fast.
