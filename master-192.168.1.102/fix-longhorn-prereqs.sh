#!/bin/bash
# Installation prérequis Longhorn sur workers existants
set -e

echo "=== INSTALLATION PRÉREQUIS LONGHORN SUR WORKERS ==="

# Sur chaque worker via SSH
for worker in 192.168.1.101 192.168.1.100 192.168.1.99; do
    echo "Configuration worker $worker..."
    ssh -o StrictHostKeyChecking=no root@$worker "
        apt update && apt install -y open-iscsi util-linux nfs-common
        systemctl enable --now iscsid
        echo 'Worker $worker configuré'
    "
done

echo "=== REDÉMARRAGE LONGHORN ==="

# Redémarrer les pods Longhorn
kubectl delete pods -n longhorn-system -l app=longhorn-manager

echo "Attente du redémarrage..."
sleep 30

kubectl get pods -n longhorn-system

echo "=== PRÉREQUIS INSTALLÉS ==="
echo "Longhorn devrait maintenant fonctionner correctement"
