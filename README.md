# claude-code-containers

This repo is for sharing various Docker setups designed to provide some useful out-of-the-box easy-install environments for experimenting with Claude Code and living _dangerously_ (but inside a cozy container). Hoping to make it easier for people newer to software development and who don't care to learn about Docker to still practice their vibes and not get pwned. 🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀

## Containers

- `node-python-basic` - more or less a minor extension of the Claude Code [reference container](https://docs.anthropic.com/en/docs/claude-code/devcontainer), but with better support for Pythonistas (the reference container firewall blocks PyPI), and automatically copies over your project's `CLAUDE.md`/`.claude/` as well

## Repo Structure

- `./containers` - contains appropriately-named directories which have a README and a `.devcontainers` folder tailored for more specific use cases.

## Roadmap

- [ ] More containers.

- [ ] Add a CLI that allows users to set up and configure their containers without having to touch the `.devcontainer` files.

## Context

Vibe coding tools are bringing a lot of new folks into the fun world of staring at your computer all day. Docker can be a little intimidating and may have a learning curve that, for many people, makes it such that they'd rather "yolo" until their data gets "yeeted". So, just trying to provide some things to make the ecosystem a little safer. (awww)

## Contributing

This is kind of a hobby project at the moment, but if you have a devcontainer setup that's perfect for doing X and want to share it here, feel free to open up a PR.
