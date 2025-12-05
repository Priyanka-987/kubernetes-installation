# Kubernetes Installation (Bare-Metal | kubeadm | containerd)

This repository provides a complete, copy-paste ready Kubernetes installation setup for **kubeadm** on Ubuntu (20.04/22.04) or Debian systems.
It includes scripts for preparing hosts, installing containerd, installing Kubernetes components (kubeadm/kubelet/kubectl), example kubeadm config, Calico CNI, MetalLB, Metrics Server and Dashboard manifests.

**Structure**
- `docs/` — guides and hardware recommendations
- `scripts/` — bash scripts for each installation step
- `manifests/` — YAML manifests for CNI, MetalLB, metrics-server, dashboard
- `cluster-config/` — kubeadm config and containerd config examples

## Quick start (one control-plane node)
1. Extract this repo on each node.
2. On every node run (as root): `bash scripts/00-precheck.sh`
3. On every node run: `bash scripts/01-install-container-runtime.sh`
4. On every node run: `bash scripts/02-install-kubernetes.sh`
5. On the control-plane node run: `bash scripts/03-init-master.sh`
6. On worker nodes run: `bash scripts/04-join-worker.sh` (use the token printed from init)
7. Apply networking: `kubectl apply -f manifests/calico.yaml`
8. Apply MetalLB, metrics, dashboard: see `manifests/`

## Notes
- Tested on Ubuntu 20.04 / 22.04 and Debian 12.
- The scripts assume `apt` package manager and systemd.
- Adjust IP ranges in `manifests/metallb/ipaddresspool.yaml` to your LAN.

