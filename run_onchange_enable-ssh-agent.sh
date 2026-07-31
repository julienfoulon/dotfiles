#!/bin/sh
command -v ssh-agent > /dev/null 2>&1 || exit 0
# No systemd (e.g. docker test container): nothing to enable
[ -d /run/systemd/system ] || exit 0
systemctl --user enable ssh-agent.service
