#!/bin/bash
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "[containerd] Installing prerequisites"
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

echo "[containerd] Installing containerd from packages"
apt-get install -y containerd

echo "[containerd] Create default config and restart"
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml || true

sed -i '/^\s*SystemdCgroup/c\            SystemdCgroup = true' /etc/containerd/config.toml || true

systemctl restart containerd
systemctl enable containerd

echo "[containerd] Done"
