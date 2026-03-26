#!/bin/bash
# Script de diagnostic et correction

echo "=== DIAGNOSTIC KUBERNETES ==="

echo "1. Status kubelet:"
systemctl status kubelet --no-pager

echo -e "\n2. Logs kubelet (dernières 20 lignes):"
journalctl -xeu kubelet --no-pager -n 20

echo -e "\n3. Conteneurs Kubernetes:"
crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a | grep kube

echo -e "\n4. Logs containerd:"
journalctl -u containerd --no-pager -n 10

echo -e "\n5. Configuration réseau:"
cat /proc/sys/net/ipv4/ip_forward
cat /proc/sys/net/bridge/bridge-nf-call-iptables

echo -e "\n=== NETTOYAGE ET RESTART ==="
kubeadm reset -f
systemctl stop kubelet containerd
systemctl start containerd
systemctl start kubelet

echo -e "\n=== REINITIALISATION ==="
kubeadm init --control-plane-endpoint "192.168.1.102:6443" --pod-network-cidr "10.244.0.0/16" --v=5
