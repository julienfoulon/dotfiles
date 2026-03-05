if command -v bat >/dev/null 2>&1; then
    _bat='bat'
elif command -v batcat >/dev/null 2>&1; then
    _bat='batcat'
fi

if [[ -n "$_bat" ]]; then
    alias cat="$_bat"
    export MANPAGER="sh -c 'col -bx | $_bat -l man -p'"
    export MANROFFOPT="-c"
    alias -g -- -h="-h 2>&1 | $_bat --language=help --style=plain"
    alias -g -- --help="--help 2>&1 | $_bat --language=help --style=plain"
    unset _bat
fi
