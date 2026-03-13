if ! command -v zoxide > /dev/null 2>&1; then
    return
fi

# Only initialize in interactive shells — avoids __zoxide_doctor warnings
# in non-interactive contexts (e.g. Claude Code bash sessions)
[[ $- == *i* ]] || return

eval "$(zoxide init zsh --cmd cd)"
