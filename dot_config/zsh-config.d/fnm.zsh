# Node version manager (fnm, replaces zsh-nvm). --use-on-cd switches the
# node version automatically on .nvmrc / .node-version.
if command -v fnm > /dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
