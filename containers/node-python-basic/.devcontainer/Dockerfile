FROM node:20-slim

# Install essential system packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    sudo \
    zsh \
    fzf \
    vim \
    less \
    procps \
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    jq \
    gh \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create node user directories
RUN mkdir -p /usr/local/share/npm-global && \
    chown -R node:node /usr/local/share

# Set up command history persistence
RUN mkdir /commandhistory && \
    touch /commandhistory/.bash_history && \
    chown -R node:node /commandhistory

# Create workspace and config directories
RUN mkdir -p /workspace /home/node/.claude && \
    chown -R node:node /workspace /home/node/.claude

# Create Claude Code reserved directories
RUN mkdir -p /home/node/.claude/commands /home/node/.claude/config && \
    chown -R node:node /home/node/.claude

WORKDIR /workspace

# Switch to node user
USER node

# Configure npm global directory
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set zsh as default shell
ENV SHELL=/bin/zsh

# Install and configure zsh with minimal setup
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    echo 'export HISTFILE=/commandhistory/.bash_history' >> ~/.zshrc && \
    echo 'export PATH=$PATH:/usr/local/share/npm-global/bin' >> ~/.zshrc

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create Claude Code reserved files if they exist on the host
# Copy host Claude files to container if they exist
COPY --chown=node:node CLAUDE.md /home/node/
COPY --chown=node:node .claude/ /home/node/

# Create default CLAUDE.md if it doesn't exist
RUN if [ ! -f /home/node/CLAUDE.md ]; then \
    echo "# Claude Code Workspace" > /home/node/CLAUDE.md && \
    echo "" >> /home/node/CLAUDE.md && \
    echo "This is your Claude Code workspace. Claude will read and update this file." >> /home/node/CLAUDE.md && \
    echo "" >> /home/node/CLAUDE.md && \
    echo "## Instructions" >> /home/node/CLAUDE.md && \
    echo "- Add project context and instructions here" >> /home/node/CLAUDE.md && \
    echo "- Claude will reference this file for project understanding" >> /home/node/CLAUDE.md && \
    chown node:node /home/node/CLAUDE.md; \
    fi

# Copy scripts
COPY .devcontainer/scripts/ /tmp/scripts/

# Switch back to root to set up sudo permissions
USER root

# Copy scripts and set permissions
RUN cp /tmp/scripts/init-firewall.sh /usr/local/bin/ && \
    cp /tmp/scripts/startup.sh /usr/local/bin/ && \
    chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/startup.sh && \
    echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
    chmod 0440 /etc/sudoers.d/node-firewall && \
    rm -rf /tmp/scripts

# Set environment variable
ENV DEVCONTAINER=true

# Switch back to node user
USER node

# Set startup script as entrypoint
ENTRYPOINT ["/usr/local/bin/startup.sh"]
