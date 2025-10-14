#/bin/env bash
docker build . -t jfo/chezmoi/arch
docker run -it --rm -v $HOME/.local/share/chezmoi:/root/.local/share/chezmoi jfo/chezmoi/arch:latest
