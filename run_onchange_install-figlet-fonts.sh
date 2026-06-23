#!/bin/sh
# Install xero's "3d" figlet font for the login banner (dot_config/zsh-config.d/
# login.zsh.tmpl). The font has no redistribution license, so instead of
# vendoring it we fetch it from upstream at apply time, pinned to a commit and
# verified by checksum. chezmoi re-runs this script whenever its contents (the
# pin/checksum below) change.
set -eu

PIN="417429ef36ab039cbf192a4424c60aa23fc32de8"
SHA256="e784641299186d8484c22e69656cbe31f31192dd0b7ca4b1de3174fdb5a63ab3"
URL="https://raw.githubusercontent.com/xero/figlet-fonts/${PIN}/3d.flf"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/figlet"
FONT="$DEST/3d.flf"

# Already present and matching the pinned checksum? nothing to do.
if [ -f "$FONT" ] && echo "$SHA256  $FONT" | sha256sum -c - >/dev/null 2>&1; then
    exit 0
fi

mkdir -p "$DEST"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL" -o "$tmp"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$tmp" "$URL"
else
    echo "install-figlet-fonts: need curl or wget" >&2
    exit 1
fi

if ! echo "$SHA256  $tmp" | sha256sum -c - >/dev/null 2>&1; then
    echo "install-figlet-fonts: 3d.flf checksum mismatch (upstream changed?)" >&2
    exit 1
fi

mv "$tmp" "$FONT"
trap - EXIT
echo "install-figlet-fonts: installed 3d.flf (pinned $PIN)"
