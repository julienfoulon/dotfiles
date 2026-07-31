#!/usr/bin/env bash
# Test a clean chezmoi deploy in a container.
#
# Host detection is hostname-based (.chezmoi.toml.tmpl), so the variant is
# selected simply by the container hostname:
#   arch    — plain Arch host, base packages only            [default]
#   laptop  — Arch with hostname "magneto" → work laptop: laptop + GUI/Wayland
#             packages (multi-GB download, AUR builds)
#   noble   — Ubuntu 24.04, like the noble nspawn dev env (apt + cargo builds)
#
# The container deploys automatically (chezmoi init && chezmoi apply — two
# steps: config data isn't loaded during init's apply) and lands in zsh.
# If already deployed (e.g. re-entering a kept container), it goes straight
# to zsh. Pass a command to docker run to bypass the auto-deploy.
set -euo pipefail
cd "$(dirname "$0")"

variant="${1:-arch}"
case "$variant" in
    arch)   dockerfile=arch/Dockerfile;   image=jfo/chezmoi-test-arch;   host=arch-test ;;
    laptop) dockerfile=arch/Dockerfile;   image=jfo/chezmoi-test-arch;   host=magneto ;;
    noble)  dockerfile=ubuntu/Dockerfile; image=jfo/chezmoi-test-ubuntu; host=noble ;;
    *) echo "usage: $0 [arch|laptop|noble]" >&2; exit 1 ;;
esac

# --pull: a stale cached base image (e.g. months-old archlinux:latest) fails
# on pacman keyring signature checks
docker build --pull -f "$dockerfile" -t "$image" .

# Cap the container at half the host cores (hard CFS quota) and 8g RAM so
# cargo/rustc/makepkg builds can't starve the host.
cpus=$(( $(nproc) / 2 ))
[ "$cpus" -ge 1 ] || cpus=1

# Source is mounted read-only; the entrypoint copies it into the container so
# run scripts (update, externals) cannot modify the host checkout.
exec docker run -it --rm \
    --hostname "$host" \
    --cpus "$cpus" \
    --memory 8g \
    -v "$(cd .. && pwd)":/src:ro \
    "$image"
