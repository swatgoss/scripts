#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "=== Mise a jour systeme ==="

apt update
apt -y upgrade

echo "=== Installation dependances ==="

apt install -y \
    python3.12 \
    python3.12-venv \
    python3-pip \
    build-essential \
    git \
    curl \
    wget \
    ffmpeg \
    libsm6 \
    libxext6 \
    nginx

echo "=== Verification Python ==="

python3.12 --version

echo "=== Creation utilisateur systeme ==="

if ! id openwebui >/dev/null 2>&1; then
    useradd -r -m -d /opt/openwebui -s /usr/sbin/nologin openwebui
fi

echo "=== Creation environnement virtuel ==="

python3.12 -m venv /opt/openwebui/venv

echo "=== Mise a jour pip ==="

/opt/openwebui/venv/bin/pip install --upgrade \
    pip \
    setuptools \
    wheel

echo "=== Installation Open WebUI ==="

#
# Pas de versions figees:
# pip resout automatiquement les dependances compatibles.
#

/opt/openwebui/venv/bin/pip install open-webui

echo "=== Preparation dossiers ==="

mkdir -p /opt/openwebui/data

chown -R openwebui:openwebui /opt/openwebui

echo "=== Creation service systemd ==="

cat > /etc/systemd/system/open-webui.service <<EOF
[Unit]
Description=Open WebUI
After=network.target

[Service]
Type=simple

User=openwebui
Group=openwebui

WorkingDirectory=/opt/openwebui

Environment=HOME=/opt/openwebui
Environment=DATA_DIR=/opt/openwebui/data
Environment=HOST=0.0.0.0
Environment=PORT=8080

ExecStart=/opt/openwebui/venv/bin/open-webui serve

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "=== Activation service ==="

systemctl daemon-reload

systemctl enable --now open-webui

echo
echo "=== Verification ==="

systemctl --no-pager --full status open-webui || true

echo
echo "=== Installation terminee ==="
echo
echo "Interface web :"
echo
echo "http://IP_DU_SERVEUR:8080"
echo
echo "Logs :"
echo
echo "journalctl -u open-webui -f"
