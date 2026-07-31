FROM ubuntu:24.04

# Noninteractive apt for the whole test container: debconf prompts (tzdata's
# "Geographic area:" etc.) would otherwise block the deploy. tzdata is
# preseeded to UTC here so nothing asks later.
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates git curl sudo tzdata \
    && curl -fsLS get.chezmoi.io | sh -s -- -b /usr/local/bin \
    && rm -rf /var/lib/apt/lists/*

# ubuntu:24.04 ships a default "ubuntu" user on uid 1000; replace it so the
# container user matches the other test images (and the host uid for /src).
RUN userdel -r ubuntu 2>/dev/null || true \
    && useradd -m -s /bin/bash -u 1000 julien \
    && echo 'julien ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/julien \
    && echo 'Defaults env_keep += "DEBIAN_FRONTEND TZ"' >> /etc/sudoers.d/julien \
    && chmod 440 /etc/sudoers.d/julien

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER julien
WORKDIR /home/julien
# run_update.sh invokes the freshly deployed ~/.local/bin/update by name;
# cargo-installed tools land in ~/.cargo/bin
ENV PATH="/home/julien/.local/bin:/home/julien/.cargo/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["auto"]
