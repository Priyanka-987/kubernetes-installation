# Installation Guide (summary)

1. Run `scripts/00-precheck.sh` on all nodes as root to disable swap and set sysctl.
2. Run `scripts/01-install-container-runtime.sh` on all nodes to install and configure containerd.
3. Run `scripts/02-install-kubernetes.sh` on all nodes to install kubeadm/kubelet/kubectl.
4. On the control-plane node run `scripts/03-init-master.sh` to initialize the cluster.
5. Copy the kubeadm join command and run `scripts/04-join-worker.sh` on worker nodes.
6. Apply networking: `kubectl apply -f manifests/calico.yaml`
7. Apply MetalLB: `kubectl apply -f manifests/metallb/metallb-native.yaml` and `kubectl apply -f manifests/metallb/ipaddresspool.yaml` (edit IPs first)
8. Install optional addons: metrics-server and dashboard.
