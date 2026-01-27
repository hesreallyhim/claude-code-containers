FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git bash openssh-client \
  && rm -rf /var/lib/apt/lists/*

# Node LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

# Non-root user
RUN useradd -m -u 1000 -s /bin/bash vscode \
  && mkdir -p /workspaces /home/vscode/.claude \
  && chown -R vscode:vscode /workspaces /home/vscode

USER vscode
WORKDIR /workspaces/repo

# Claude Code
RUN npm install -g @anthropic-ai/claude-code
