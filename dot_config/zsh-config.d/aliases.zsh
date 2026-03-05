if ! command -v eza >/dev/null 2>&1; then
    alias ls='ls --color'
    alias ll='ls -l'
fi

if command -v jvim >/dev/null 2>&1 && command -v nvim >/dev/null 2>&1; then
    alias vim='jvim'
fi
