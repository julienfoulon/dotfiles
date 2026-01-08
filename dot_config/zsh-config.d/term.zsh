if command -v infocmp >/dev/null 2>&1 && infocmp -x kitty >/dev/null 2>&1; then
    export TERM=kitty
else
    export TERM=xterm-256color
fi
