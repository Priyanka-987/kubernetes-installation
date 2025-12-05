# Kubernetes Installation Guide

## Setup

1. **4 VMs Ubuntu 22.04** — 1 control plane, 3 worker nodes.
2. **Static IPs** assigned to each VM.
3. **/etc/hosts** updated with hostname → IP mappings for all nodes.
4. **Swap disabled** on all nodes.
5. **Take VM snapshots** before installing Kubernetes (recommended).

SSH into control plane:

```bash
ssh priyanka@my-ubuntu-1
```

---

## 0. Disable Swap

```bash
sudo swapoff -a
sudo vi /etc/fstab
```

*Remove any swap entries.*

---

## 1. Install Required Packages

Load kernel modules:

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

System settings:

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
```

---

## 2. Install containerd

```bash
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
```

Edit containerd config to use systemd cgroups:

```bash
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
```

Verify:

```bash
grep 'SystemdCgroup = true' /etc/containerd/config.toml
```

Restart:

```bash
sudo systemctl restart containerd
```

---

## 3. Install Kubernetes Components

Add repository:

```bash
sudo apt update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg conntrack
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Update and check versions:

```bash
sudo apt-get update
apt-cache policy kubelet | head -n 20
```

Install Kubernetes:

```bash
VERSION=1.31.14-1.1
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt-mark hold kubelet kubeadm kubectl containerd
sudo systemctl enable --now kubelet
```

---

## 4. Check Services

```bash
sudo systemctl status kubelet.service
sudo systemctl status containerd.service
```

kubelet will show **inactive (dead)** until cluster is initialized with `kubeadm init` or joined with `kubeadm join`.

---

### IMPORTANT

The installation commands may change based on Kubernetes releases. Always check official documentation for the most updated instructions.
