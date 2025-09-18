# Get the command name, bat or batcat
if command -v bat > /dev/null 2>&1;then
  BAT=bat
else
  BAT=batcat # debian / ubuntu
fi

# if the command is there, configure
if command -v $BAT >/dev/null 2>&1; then
  alias cat=$BAT
  # use bat as the man pager
  export MANPAGER="sh -c 'col -bx | $BAT -l man -p'"
  export MANROFFOPT="-c"
  # use bat for -h and --help
  alias -g -- -h="-h 2>&1 | $BAT --language=help --style=plain"
  alias -g -- --help="--help 2>&1 | $BAT --language=help --style=plain"
fi
