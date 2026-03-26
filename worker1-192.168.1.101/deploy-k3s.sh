#!/bin/bash
# K3s Worker avec prérequis Longhorn
set -e

# Installation curl et prérequis Longhorn
apt update && apt install -y curl open-iscsi util-linux nfs-common

# Activer iSCSI
systemctl enable --now iscsid

# Token du master
K3S_TOKEN="K101c8803f15fae2f3bcedbf6c35033dcbbdd7084091019d55fa5a608d8ac3e2889::server:080499302888061736493e39cf3d728e"

curl -sfL https://get.k3s.io | K3S_URL=https://192.168.1.102:6443 K3S_TOKEN=${K3S_TOKEN} sh -
