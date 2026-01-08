if ! command -v fzf > /dev/null 2>&1;then
    return
fi

if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
fi
# ---------
if command -v fdfind >/dev/null 2>&1;then
    # fd is installed, use it instead of find in fzf
    # see https://github.com/sharkdp/fd
    export FZF_DEFAULT_COMMAND='fdfind --color=always --strip-cwd-prefix --follow --hidden --exclude .git'
    export FZF_DEFAULT_OPTS="--ansi"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fdfind --type=d --border --hidden --strip-cwd-prefix --exclude .git "
fi
