FROM golang:1.24-alpine AS clipse-builder

RUN apk add --no-cache git make \
    && git clone --branch v1.2.1 --depth 1 https://github.com/savedra1/clipse.git /src/clipse \
    && make -C /src/clipse wayland

FROM archlinux:latest

# Keep this image focused on exercising the real Hyprland desktop config.
# Package installation scripts are skipped by the entrypoint, so the runtime
# dependencies used by autostart.lua are installed explicitly here.
RUN pacman -Sy --noconfirm archlinux-keyring \
    && pacman -Su --noconfirm --needed \
        awww \
        base-devel \
        brightnessctl \
        ca-certificates \
        chezmoi \
        dbus \
        dunst \
        git \
        hypridle \
        hyprland \
        hyprpolkitagent \
        imagemagick \
        kitty \
        libnotify \
        network-manager-applet \
        noto-fonts \
        noto-fonts-emoji \
        pavucontrol-qt \
        playerctl \
        power-profiles-daemon \
        python \
        sudo \
        ttf-firacode-nerd \
        waybar \
        wayvnc \
        wl-clipboard \
        wofi \
        zsh \
    && pacman -Scc --noconfirm

# UID 1000 matches the usual desktop user and permits access to the host's
# Wayland socket. The numeric render group is added by run.sh at runtime.
RUN useradd -m -s /bin/zsh -u 1000 julien \
    && echo 'julien ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/julien \
    && chmod 440 /etc/sudoers.d/julien \
    && install -d -o julien -g julien -m 700 /run/user/1000

# noVNC is only static web content. wayvnc 0.10+ speaks WebSocket directly,
# so a separate websockify process is unnecessary.
RUN git clone --branch v1.7.0 --depth 1 https://github.com/novnc/noVNC.git /opt/novnc \
    && rm -rf /opt/novnc/.git

COPY --from=clipse-builder /src/clipse/clipse /usr/local/bin/clipse
COPY entrypoint.sh /usr/local/bin/hyprland-test-entrypoint
COPY hyprland-test.lua /usr/local/share/hyprland-test/hyprland-test.lua
RUN chmod 755 /usr/local/bin/hyprland-test-entrypoint

USER julien
WORKDIR /home/julien
ENV HOME=/home/julien \
    PATH=/home/julien/.local/bin:/usr/local/bin:/usr/bin \
    XDG_RUNTIME_DIR=/run/user/1000 \
    HYPRLAND_NO_RT=1 \
    HYPRLAND_NO_SD_NOTIFY=1 \
    HYPRLAND_NO_SD_VARS=1

ENTRYPOINT ["/usr/local/bin/hyprland-test-entrypoint"]
CMD ["window"]
