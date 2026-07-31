#!/bin/sh
# Copy the read-only mounted source into place so run scripts (update's git
# operations, chezmoi externals) can never touch the host checkout.
# .venv is excluded: it's untracked local tooling whose symlinks point at
# host paths that don't exist in the container and break chezmoi.
set -e
if [ -d /src ] && [ ! -d "$HOME/.local/share/chezmoi" ]; then
    mkdir -p "$HOME/.local/share/chezmoi"
    (cd /src && tar --exclude=./.venv -cf - .) \
        | tar -C "$HOME/.local/share/chezmoi" -xf -
fi

echo "chezmoi test container — hostname: $(uname -n), user: $(id -un)"

# Default mode ("auto" CMD, no explicit command): deploy if not yet done,
# then land in the deployed zsh. Two steps, not `init --apply`: config data
# (work/home/laptop flags) isn't loaded during init's apply phase.
if [ "$1" = "auto" ]; then
    if [ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]; then
        echo "No chezmoi config yet — running: chezmoi init && chezmoi apply"
        if ! (chezmoi init && chezmoi apply); then
            echo "deploy failed — dropping to bash for debugging" >&2
            exec /bin/bash
        fi
    else
        echo "chezmoi already initialized — going straight to zsh"
    fi
    if command -v zsh >/dev/null 2>&1; then
        exec zsh -l
    fi
    echo "zsh not found — dropping to bash" >&2
    exec /bin/bash
fi

# Explicit command given (debugging, CI-style validation): run it as-is.
exec "$@"
