#!/usr/bin/env bash
# Build and launch the disposable Hyprland desktop.
#
#   ./docker/hyprland/run.sh           # nested Wayland window
#   ./docker/hyprland/run.sh browser   # http://127.0.0.1:6080
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/../.." && pwd)"
mode="${1:-window}"

case "$mode" in
    window|browser) ;;
    -h|--help)
        echo "usage: $0 [window|browser]"
        exit 0
        ;;
    *)
        echo "usage: $0 [window|browser]" >&2
        exit 2
        ;;
esac

if ! command -v docker >/dev/null 2>&1; then
    echo "docker is required" >&2
    exit 1
fi

shopt -s nullglob
render_nodes=(/dev/dri/renderD*)
shopt -u nullglob
render_node="${HYPRLAND_TEST_DRM_DEVICE:-${render_nodes[0]:-}}"

if [[ -z "$render_node" || ! -c "$render_node" ]]; then
    echo "no DRM render node found; set HYPRLAND_TEST_DRM_DEVICE=/dev/dri/renderD…" >&2
    exit 1
fi

if [[ "$mode" == window ]]; then
    if [[ -z "${XDG_RUNTIME_DIR:-}" || -z "${WAYLAND_DISPLAY:-}" ]]; then
        echo "window mode must be launched from a Wayland session" >&2
        exit 1
    fi

    wayland_socket="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    if [[ ! -S "$wayland_socket" ]]; then
        echo "Wayland socket not found: $wayland_socket" >&2
        exit 1
    fi
fi

# Reuse the host compositor's configured XKB values when Hyprland exposes
# them. XKB_DEFAULT_* also covers other Wayland compositors. If neither is
# available, use the requested US international fallback.
keyboard_layout="${XKB_DEFAULT_LAYOUT:-}"
keyboard_variant="${XKB_DEFAULT_VARIANT:-}"
keyboard_options="${XKB_DEFAULT_OPTIONS:-}"

if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    host_layout="$(hyprctl -j getoption input:kb_layout 2>/dev/null | jq -er '.str // empty' 2>/dev/null || true)"
    if [[ -n "$host_layout" ]]; then
        keyboard_layout="$host_layout"
        keyboard_variant="$(hyprctl -j getoption input:kb_variant 2>/dev/null | jq -er '.str // empty' 2>/dev/null || true)"
        keyboard_options="$(hyprctl -j getoption input:kb_options 2>/dev/null | jq -er '.str // empty' 2>/dev/null || true)"
    fi
fi

if [[ -z "$keyboard_layout" ]]; then
    keyboard_layout="us"
    keyboard_variant="intl"
    keyboard_options=""
fi

test_scale="${HYPRLAND_TEST_SCALE:-1}"
if ! [[ "$test_scale" =~ ^[0-9]+([.][0-9]+)?$ ]] \
    || ! awk -v scale="$test_scale" 'BEGIN { exit !(scale > 0) }'; then
    echo "HYPRLAND_TEST_SCALE must be a positive number" >&2
    exit 2
fi

image="jfo/chezmoi-test-hyprland"
docker build --pull -t "$image" "$script_dir"

docker_args=(
    run --rm -it --init
    --hostname hyprland-test
    --shm-size 1g
    --device "$render_node:$render_node"
    --group-add "$(stat -c '%g' "$render_node")"
    --mount "type=bind,src=$repo_dir,dst=/src,readonly"
    --env "HYPRLAND_TEST_KB_LAYOUT=$keyboard_layout"
    --env "HYPRLAND_TEST_KB_VARIANT=$keyboard_variant"
    --env "HYPRLAND_TEST_KB_OPTIONS=$keyboard_options"
    --env "HYPRLAND_TEST_SCALE=$test_scale"
)

# Clipse only needs uinput for its optional auto-paste feature. Clipboard
# history still works when the host does not expose this device.
if [[ -c /dev/uinput ]]; then
    docker_args+=(
        --device /dev/uinput:/dev/uinput
        --group-add "$(stat -c '%g' /dev/uinput)"
    )
fi

if [[ "$mode" == window ]]; then
    docker_args+=(
        --env "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
        --mount "type=bind,src=$wayland_socket,dst=/run/user/1000/$WAYLAND_DISPLAY"
    )
else
    docker_args+=(
        --env AQ_NO_KMS_REQUIREMENT=1
        --publish 127.0.0.1:5900:5900
        --publish 127.0.0.1:6080:6080
    )
    echo "noVNC: http://127.0.0.1:6080/vnc.html?host=127.0.0.1&port=5900&encrypt=0&autoconnect=1&resize=remote"
fi

exec docker "${docker_args[@]}" "$image" "$mode"
