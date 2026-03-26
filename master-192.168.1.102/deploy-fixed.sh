#!/bin/bash
set -e

apt update && apt upgrade -y
apt install -y curl containerd iptables conntrack ebtables ethtool socat

swapoff -a
sed -i '/swap/ s/^/#/' /etc/fstab

modprobe br_netfilter
echo 'net.bridge.bridge-nf-call-iptables=1' > /etc/sysctl.d/k8s.conf
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.d/k8s.conf
sysctl --system

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

curl -L "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
curl -L "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubeadm" -o /usr/local/bin/kubeadm
curl -L "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubelet" -o /usr/local/bin/kubelet
chmod +x /usr/local/bin/kubectl /usr/local/bin/kubeadm /usr/local/bin/kubelet

cat > /etc/systemd/system/kubelet.service << EOF
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable kubelet

# Nettoyage préventif
kubeadm reset -f 2>/dev/null || true
systemctl stop kubelet containerd 2>/dev/null || true
systemctl start containerd
systemctl start kubelet

kubeadm init --control-plane-endpoint "192.168.1.102:6443" --pod-network-cidr "10.244.0.0/16"

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

kubeadm token create --print-join-command
