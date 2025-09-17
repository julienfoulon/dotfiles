if command -v eza >/dev/null 2>&1;then
    alias ls='eza --icons'
    alias ll='ls -l --time-style "+%Y-%m-%d %H:%M"'
fi
