#!/bin/bash

sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install -y zsh fd-find eza ripgrep bat

# ZDOTDIR
zdotdir_path='export ZDOTDIR="$HOME/dotfiles/zsh"'
echo "Setting ZDOTDIR..."
if ! grep -qxF "$zdotdir_path" /etc/zsh/zshenv; then
    echo "$zdotdir_path" | sudo tee -a /etc/zsh/zshenv > /dev/null
    echo "Successfully added '$zdotdir_path' to /etc/zsh/zshenv."
else
    echo "The line '$zdotdir_path' already exists in /etc/zsh/zshenv."
fi

# Proxy
echo "Do you want to set up proxy settings? (y/n): "
read confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Enter your HTTP proxy (e.g., http://proxy.example.com:80): "
    read http_proxy

    output_file="$HOME/dotfiles/zsh/sheldon/defer.zsh"

    {
        echo "# Proxy settings"
        echo "export HTTP_PROXY=\"$http_proxy\""
        echo "export HTTPS_PROXY=\"$http_proxy\""
    } > "$output_file"

    echo "Proxy settings have been written to $output_file."

    OVERRIDE_DIR="/etc/systemd/system/docker.service.d"
    OVERRIDE_FILE="$OVERRIDE_DIR/override.conf"

    if [ ! -d "$OVERRIDE_DIR" ]; then
        sudo mkdir -p "$OVERRIDE_DIR"
    fi

    {
        echo "[Service]"
        echo "Environment=\"HTTP_PROXY=$http_proxy\""
        echo "Environment=\"HTTPS_PROXY=$http_proxy\""
    } | sudo tee "$OVERRIDE_FILE" > /dev/null

    echo "Proxy settings have been added to $OVERRIDE_FILE."

    APT_CONF_FILE="/etc/apt/apt.conf"

    if [ ! -f "$APT_CONF_FILE" ]; then
        echo "Creating APT configuration file at $APT_CONF_FILE."
        echo "Acquire::http::Proxy \"$http_proxy\";" | sudo tee "$APT_CONF_FILE" > /dev/null
        echo "Acquire::https::Proxy \"$http_proxy\";" | sudo tee -a "$APT_CONF_FILE" > /dev/null
        echo "Proxy settings added to APT configuration."
    else
        if ! grep -q "Acquire::http::Proxy" "$APT_CONF_FILE" 2>/dev/null; then
            echo "Acquire::http::Proxy \"$http_proxy\";" | sudo tee -a "$APT_CONF_FILE" > /dev/null
            echo "Acquire::https::Proxy \"$http_proxy\";" | sudo tee -a "$APT_CONF_FILE" > /dev/null
            echo "Proxy settings added to APT configuration."
        else
            echo "APT proxy settings already exist."
        fi
    fi
else
    echo "Proxy settings were not changed."
fi

# sheldon
echo "installing sheldon..."
if ! command -v sheldon &>/dev/null; then
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin -f
    mkdir -p "$HOME/.config/sheldon"
    ln -sf "$HOME/dotfiles/zsh/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
else
    echo "sheldon is already installed."
fi

# zsh
echo "Changing the default shell to Zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    echo "Default shell changed to Zsh. Please log out and log back in for the changes to take effect."
else
    echo "Zsh is already the default shell."
    echo "Setup is completed."
fi
