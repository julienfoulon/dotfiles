#!/usr/bin/env bash
# Deploy the current checkout without running its host package/service scripts,
# then start the real Hyprland config through a container-only Lua wrapper.
set -euo pipefail

mode="${1:-window}"
case "$mode" in
    window|browser) ;;
    *)
        echo "usage: entrypoint.sh [window|browser]" >&2
        exit 2
        ;;
esac

if [[ ! -d /src ]]; then
    echo "the chezmoi repository must be mounted at /src" >&2
    exit 1
fi

source_dir="$HOME/.local/share/chezmoi"
mkdir -p "$source_dir"
(cd /src && tar --exclude=./.venv -cf - .) | tar -C "$source_dir" -xf -

# init creates the hostname-derived data first; apply then deploys the user's
# actual Hyprland, Waybar, Kitty and Clipse files. System mutation scripts are
# deliberately excluded because this purpose-built image already has packages.
chezmoi init
chezmoi apply --exclude scripts

install -m 644 /usr/local/share/hyprland-test/hyprland-test.lua \
    "$HOME/.config/hypr/hyprland-test.lua"

export HYPRLAND_TEST_MODE="$mode"

if [[ "$mode" == browser ]]; then
    python -m http.server 6080 --bind 0.0.0.0 --directory /opt/novnc &
    novnc_pid=$!
    trap 'kill "$novnc_pid" 2>/dev/null || true' EXIT INT TERM
fi

exec dbus-run-session -- Hyprland --config "$HOME/.config/hypr/hyprland-test.lua"
