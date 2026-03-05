# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Dotfiles managed by [chezmoi](https://www.chezmoi.io/). Files prefixed with `dot_` or `private_dot_` map to the home directory. Templates use Go templating syntax.

## Key Commands

- `chezmoi diff` — preview changes between repo and target files
- `chezmoi apply` — apply templates to the home directory
- `./docker/arch/test.sh` — build and run the Arch test container for clean-environment validation

## Hosts & Environments

Configured via `.chezmoi.toml.tmpl` using hostname detection:

- **magneto**: work laptop, Arch Linux (`work=true`, `laptop=true`), hosts `jammy`/`noble` nspawn containers and an `ubuntu` VM, two external Dell screens, lab network `192.168.80.0/24`
- **moriarty**: personal laptop, Arch Linux (`home=true`, `laptop=true`), Waydroid, optional 4K screen with 2x scaling
- **nspawn/Ubuntu dev envs** (e.g. `jammy`, `noble`): non-laptop Ubuntu hosts, get the base Ubuntu package set only (no GUI, no laptop packages)

Template data variables: `work`, `home`, `laptop`, `osid`.

## Package Management

Package lists live in `.chezmoidata/*.yaml` (`packages.yaml`, `laptop-packages.yaml`, `home-laptop-packages.yaml`, `gui-packages.yaml`). `run_onchange_install-package.sh.tmpl` installs them via `pacman`/`yay` on Arch and `apt`/`cargo` on Ubuntu. Laptop-only and home-only packages are gated by the corresponding data flags. Only laptops install GUI packages.

## Code Style

- Lua (`dot_config/jvim/`): 2-space indentation, inline tables
- Shell/zsh: concise, POSIX-friendly, no tabs
- File naming follows chezmoi conventions (`dot_`, `private_dot_`, `run_onchange_`, etc.)

## Commits

- Short, imperative messages focused on one logical change
- Always confirm the commit message before committing
- For UI-affecting changes, describe or screenshot the visual change
