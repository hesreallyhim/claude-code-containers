# Claude Code + Rust Devcontainer (Hardened Sandbox)

This folder is a **self-contained workspace** for testing a target repo with:

- Claude Code running inside a container
- Rust toolchain (rustup/cargo) inside the same container
- A hardened runtime posture: non-root, `no-new-privileges`, dropped caps, read-only root FS, writable temp via `tmpfs`

The container has **write access to the mounted repo** and **temporary writable locations** (`/tmp`, `/run`), while keeping the container filesystem read-only.

## Layout

./
.devcontainer/
devcontainer.json
docker-compose.yml
Dockerfile
repo/ # your target repo (bind-mounted into the container)
Makefile

## Quick start

1. Create a clean workspace and clone the repo you want to test:

```bash
mkdir sandbox && cd sandbox
# copy in the .devcontainer/ directory (and this README/Makefile)
git clone <REPO_URL> repo
```

2.	Open this folder in VS Code and choose “Reopen in Container”.
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

Teardown (remove everything container-related)

From the host, in this folder:

```bash
make down
```

This runs docker compose down -v --remove-orphans, which deletes the named volumes too
(including Claude auth/config and Rust caches).

If you also want the repo gone, delete the workspace folder.

Common commands
	•	Start container (headless): make up
	•	Shell into container: make shell
	•	Run Claude Code: make claude
	•	Run Rust tests in repo: make test
	•	Full cleanup: make clean

Notes
	•	repo/ is bind-mounted read/write. Edits are real and persist on your host.
	•	Claude auth/config is stored in a named Docker volume and removed by make down / make clean.
	•	If you see permission issues on Linux, ensure your host user is UID/GID 1000 or adjust user: in .devcontainer/docker-compose.yml.
