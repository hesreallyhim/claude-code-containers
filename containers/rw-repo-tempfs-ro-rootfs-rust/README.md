# Claude Code + Rust Devcontainer (Hardened Sandbox)

This provisions a **self-contained workspace** for testing Claude Code inside a repo with:

- Claude Code running inside a container
- Rust toolchain (rustup/cargo) inside the same container
- A hardened runtime posture: non-root, `no-new-privileges`, dropped caps, read-only root FS, writable temp via `tmpfs`. More secure - not bulletproof.

The container has **write access to the mounted repo** and **temporary writable locations** (`/tmp`, `/run`), while keeping the container filesystem read-only.

## Layout

```bash
./
.devcontainer/
devcontainer.json
docker-compose.yml
Dockerfile
repo/ # your target repo (bind-mounted into the container)
Makefile
```

## Quick start

1. Use the `./scripts/launch-container.sh` script - pass in a repository url, and it will create a new directory, clone the repo, into that directory, and then create a Docker container inside that workspace.

```bash
# chmod +x ./scripts/launch-container.sh
./scripts/launch-container.sh https:github.com/repo-owner/repo-name

Result:
|
|-sandbox-repo-name/
|---.devcontainer/ # Copied from the current directory.
|---Makefile
|---README.md
|---repo-name/
```

The script then launches into VS Code (if `code` is in your path) from inside `repo-name`.

2. In VS Code, choose “Reopen in Container”.
3.	Inside the container, authenticate Claude Code:

```bash
claude login
claude --version
```

4.	Build/test the library (example for Rust projects):

```bash
cd /workspaces/repo
cargo test
```

### Teardown (remove everything container-related)

From the host, in this folder:

```bash
make down
```

This runs docker compose down -v --remove-orphans, which deletes the named volumes too
(including Claude auth/config and Rust caches).

If you also want the repo gone, delete the workspace folder.

Common commands
- Start container (headless): make up
- Shell into container: make shell
- Run Claude Code: make claude
- Run Rust tests in repo: make test
- Full cleanup: make clean

Notes
- `repo-name/` is bind-mounted read/write. Edits are real and persist on your host.
- Claude auth/config is stored in a named Docker volume and removed by `make down` / `make clean`.
- If you see permission issues on Linux, ensure your host user is UID/GID 1000 or adjust user: in `.devcontainer/docker-compose.yml`.


### Syncing changes from container back to machine:

- Start with a dry-run
```bash
rsync -avnc --delete .devcontainer/ "$(TEMPLATE_DIR)/.devcontainer/"
```

- Perofrm the backport
```bash
rsync -a --delete --delay-updates .devcontainer/ "$(TEMPLATE_DIR)/.devcontainer/"
```

- If success, should see a clean working tree
```bash
git -C "$(TEMPLATE_DIR)" status
```
