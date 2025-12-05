#!/bin/bash
set -euo pipefail
echo "Paste the full kubeadm join command (from control plane) and press ENTER:"
read -r JOIN_CMD
if [ -z "$JOIN_CMD" ]; then
  echo "No join command provided"
  exit 1
fi
bash -c "$JOIN_CMD"
