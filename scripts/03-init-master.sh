#!/bin/bash
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

CONF=/root/cluster-config/kubeadm-config.yaml
if [ ! -f "$CONF" ]; then
  echo "kubeadm config not found at $CONF, creating a minimal one"
  mkdir -p /root/cluster-config
  cat > $CONF <<'EOF'
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: stable
networking:
  podSubnet: 192.168.0.0/16
EOF
fi

echo "[init] Initializing control plane (kubeadm init)"
kubeadm init --config "$CONF" --upload-certs

echo "[init] Setup kubeconfig for current user"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[init] You can now run: kubectl get nodes"
echo "[init] To join workers, run the kubeadm join command printed above or 'kubeadm token create --print-join-command'"
