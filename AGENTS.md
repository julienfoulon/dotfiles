# Repository Guidelines

## Project Structure & Module Organization
- `dot_*` and `private_dot_*` are chezmoi templates for home directory files.
- `dot_config/` contains app configs (e.g., `dot_config/zsh-config.d/`, `dot_config/kitty/`, `dot_config/jvim/`).
- Hyprland and Waybar configs live under `dot_config/hypr/` and `dot_config/waybar/`.
- `private_dot_local/bin/` holds local scripts and wrappers (e.g., `symlink_jvim`).
- `docker/arch/` provides a containerized Arch setup for validation (`Dockerfile`, `test.sh`).

## Build, Test, and Development Commands
- `chezmoi diff` previews changes between repo state and target files.
- `chezmoi apply` applies templates into the home directory.
- `./docker/arch/test.sh` builds and runs the Arch test container.
  - Equivalent: `docker build -t jfo/chezmoi/arch .` then `docker run -it --rm -v $HOME/.local/share/chezmoi:/root/.local/share/chezmoi jfo/chezmoi/arch:latest`.

## Package Installation
- Package lists live in `.chezmoidata/*.yaml` (`packages.yaml`, `laptop-packages.yaml`, `home-laptop-packages.yaml`, `gui-packages.yaml`).
- `run_onchange_install-package.sh.tmpl` installs them via `pacman`/`yay` on Arch and `apt`/`cargo` on Ubuntu.
- Laptop and home/laptop package sets are gated by `.chezmoi.config.data.laptop` and `.chezmoi.config.data.home`.
- Laptop installs GUI packages; VMs do not.
- Home can add specific packages.

## Hosts & Environments
- Magneto: work laptop, Arch Linux, two external Dell screens.
  - Hosts systemd-nspawn environments: `jammy` and `noble` (Ubuntu Jammy/Noble).
  - Also has an `ubuntu` VM used for builds.
  - All on lab network `192.168.80.0/24`.
- Moriarty: personal laptop, Arch Linux, Waydroid.
  - May be connected to a 4K screen with 2x scaling.
- Chezmoi configs target these machines and the above environments.

## Coding Style & Naming Conventions
- Follow existing patterns in each file type; keep edits minimal and focused.
- Lua config in `dot_config/jvim/` uses 2-space indentation and inline tables.
- Shell scripts and zsh snippets prefer concise, POSIX-friendly syntax; avoid tabs.
- File naming follows chezmoi conventions (`dot_`, `private_`) for mapping to target paths.

## Testing Guidelines
- No formal test suite is configured.
- For configuration changes that impact system setup, validate with `chezmoi diff` and `chezmoi apply`, then sanity-check the affected tool (e.g., launch `kitty` or `jvim`).
- Use `docker/arch/test.sh` when changes should be verified on a clean Arch environment.

## Commit & Pull Request Guidelines
- Commit history uses short, imperative messages (e.g., "Add config for home laptop", "Update nvim configuration").
- Keep commits focused on one logical change.
- Propose a commit message based first on the diff and/or staged file changes before asking for confirmation.
- PRs should include a short description, the affected app(s) or OS, and any manual validation performed.
- For UI-affecting changes (kitty themes, zsh prompts), include a screenshot or describe the visual change.
- Before committing, always ask for confirmation of the commit message.

## Security & Configuration Tips
- Avoid committing secrets or machine-specific credentials.
- Prefer templates or conditional logic for host-specific settings (see `dot_config/` examples).
