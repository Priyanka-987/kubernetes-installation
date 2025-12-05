#!/bin/bash
set -euo pipefail
echo "[calico] Applying calico manifest (manifests/calico.yaml)"
kubectl apply -f manifests/calico.yaml
