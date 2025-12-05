# Kubernetes Installation Guide

## Setup
1. **4 VMs Ubuntu 22.04** — 1 control plane, 3 worker nodes.
2. **Static IPs** assigned to each VM.
3. **/etc/hosts** updated with hostname → IP mappings for all nodes.
4. **Swap disabled** on all nodes.

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
## 1. Install Required Packages (Both Control plane and Worker) 
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
## 5. Creating the Kubernetes Cluster
Log into the control plane:
```bash
ssh priyanka@my-ubuntu-1
```

Download Calico manifest:
```bash
wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
```

Edit Pod CIDR if needed:
```bash
vi calico.yaml
```

Initialize the cluster:
```bash
sudo kubeadm init --kubernetes-version v1.31.14
```

Set up kubeconfig:
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---
## 6. Deploy Pod Network (Calico)
Apply Calico:
```bash
kubectl apply -f calico.yaml
```

Watch pods:
```bash
kubectl get pods --all-namespaces --watch
```

Check when all system pods are Running:
```bash
kubectl get pods --all-namespaces
```

Check nodes:
```bash
kubectl get nodes
```

---
## 7. Join Worker Nodes to the Cluster
Log out of the worker node and return to the control plane:
```bash
exit
```

Generate the cluster join command:
```bash
kubeadm token create --print-join-command
```
*Copy the output — you'll need it for each worker node.*

SSH into the first worker node:
```bash
ssh priyanka@my-ubuntu-2
```

Run the join command (example — your token will differ):
```bash
sudo kubeadm join 172.16.94.10:6443 \
  --token th8kxn.wprtltponkh1d6s0 \
  --discovery-token-ca-cert-hash sha256:41e98ba1e95281e53dfd65935dee7073ee3ef227f3250f4257f97663a19473bd
```

Return to control plane:
```bash
exit
```

Check node status (will be **NotReady** until network pod is deployed):
```bash
kubectl get nodes
```

Watch pods across all namespaces:
```bash
kubectl get pods --all-namespaces
```
![Screenshot Name](images/pod.jpg)

Verify worker node becomes **Ready**:
```bash
kubectl get nodes
```