if [[ -o login ]]; then
    os_id="unknown"
    os_version="unknown"
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        os_id="${ID:-unknown}"
        os_version="${VERSION_ID:-unknown}"
    fi

    host_name="$(command hostname)"
    kernel_version="$(command uname -r)"
    container_tag=""
    if [[ -r /run/systemd/container ]]; then
        container_type="$(command cat /run/systemd/container)"
        container_tag=" %F{blue}(container:${container_type})%f"
    fi

    os_icon=""
    os_label="$os_id"
    case "$os_id" in
        ubuntu) os_icon=""; os_label="Ubuntu" ;;
        arch) os_icon=""; os_label="Arch" ;;
        debian) os_icon=""; os_label="Debian" ;;
        fedora) os_icon=""; os_label="Fedora" ;;
    esac

    print -P "%F{cyan}%f %BWelcome%f %B${USER}%b - %F{yellow}󰒋%f ${host_name}${container_tag}, %F{green}${os_icon}%f ${os_label} ${os_version}, %F{magenta}%f ${kernel_version}"
fi
