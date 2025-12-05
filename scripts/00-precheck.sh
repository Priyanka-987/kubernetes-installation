#!/bin/bash
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root: sudo bash $0"
  exit 1
fi

echo "[precheck] Disabling swap (temporary and persistent)"
swapoff -a || true
sed -i.bak '/\bswap\b/ s/^/#/' /etc/fstab || true

echo "[precheck] Enabling kernel modules and sysctl settings"
cat > /etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF

modprobe overlay || true
modprobe br_netfilter || true

cat > /etc/sysctl.d/k8s.conf <<'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system >/dev/null 2>&1 || true

echo "[precheck] Done"
