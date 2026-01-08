if ! command -v rg >/dev/null 2>&1 && command -v ripgrep >/dev/null 2>&1; then
  alias rg='ripgrep'
fi
