if ! command -v zoxide > /dev/null 2>&1; then
    return
fi

eval "$(zoxide init zsh --cmd cd)"
