XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}"
# Prefer forwarded agent when present; fall back to local systemd agent.
if [ -z "$SSH_CONNECTION" ] && [ -S "${XDG_RUNTIME_DIR}/ssh-agent.socket" ]; then
  SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
  export SSH_AUTH_SOCK
fi
