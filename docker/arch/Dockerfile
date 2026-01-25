# File: Dockerfile.arch
FROM archlinux:latest

# Install chezmoi + common dependencies
RUN pacman -Syu --noconfirm --needed \
    ca-certificates git curl sudo \
    && curl -fsLS get.chezmoi.io | sh -s -- -b /usr/local/bin \
    && pacman -Scc --noconfirm

# Set workdir
WORKDIR /root

# Entry point: open a shell with chezmoi available
CMD ["/bin/bash"]
