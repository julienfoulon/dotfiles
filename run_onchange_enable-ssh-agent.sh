#!/bin/sh
command -v ssh-agent > /dev/null 2>&1 || exit 0
systemctl --user enable ssh-agent.service
