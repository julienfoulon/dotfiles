FROM archlinux:latest

# Refresh the keyring first: the base image's keys can be too stale to verify
# current package signatures. chezmoi is in extra; git/curl/sudo are needed by
# the run scripts.
RUN pacman -Sy --noconfirm archlinux-keyring \
    && pacman -Su --noconfirm --needed \
    ca-certificates git curl sudo chezmoi \
    && pacman -Scc --noconfirm

# Non-root user: makepkg/yay refuse to run as root, and the run scripts
# use sudo. uid 1000 matches the host user so the ro-mounted /src is readable.
RUN useradd -m -s /bin/bash -u 1000 julien \
    && echo 'julien ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/julien \
    && chmod 440 /etc/sudoers.d/julien

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER julien
WORKDIR /home/julien
# run_update.sh invokes the freshly deployed ~/.local/bin/update by name
ENV PATH="/home/julien/.local/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["auto"]
