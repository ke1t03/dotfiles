#!/bin/bash

# /etc/apt/keyrings ディレクトリを作成
echo "Creating directory /etc/apt/keyrings..."
sudo install -m 0755 -d /etc/apt/keyrings

# Docker GPGキーをダウンロード
echo "Downloading Docker GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "Setting permissions for the GPG key..."
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Dockerのリポジトリを追加
echo "Adding Docker repository to sources list..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# パッケージを更新してインストール
echo "Updating package list and installing Docker..."
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ユーザーをdockerグループに追加
echo "Adding user $USER to docker group..."
sudo usermod -aG docker $USER

# Docker設定ディレクトリとファイルの作成
DOCKER_CONFIG_DIR="$HOME/.docker"
DOCKER_CONFIG_FILE="$DOCKER_CONFIG_DIR/config.json"

if [ ! -d "$DOCKER_CONFIG_DIR" ]; then
    echo "Creating Docker config directory at $DOCKER_CONFIG_DIR..."
    mkdir -p "$DOCKER_CONFIG_DIR"
fi

echo "Creating Docker config file at $DOCKER_CONFIG_FILE..."
cat <<EOL > "$DOCKER_CONFIG_FILE"
{
  "proxies": {
    "default": {
      "httpProxy": "$HTTP_PROXY",
      "httpsProxy": "$HTTPS_PROXY"
    }
  }
}
EOL

# Dockerサービスを再起動
echo "Reloading Docker daemon and restarting Docker service..."
sudo systemctl daemon-reload
sudo systemctl restart docker

# Shellを再起動
echo "You need to restart the shell for the settings to take effect."
