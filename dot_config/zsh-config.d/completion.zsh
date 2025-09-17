autoload -Uz compinit && compinit

# case insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


if command -v fzf > /dev/null 2>&1;then
    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    # Remove default completion menu
    zstyle ':completion:*' menu no
    # cd preview (could use eza if installed)
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color --color=always $realpath'
fi
