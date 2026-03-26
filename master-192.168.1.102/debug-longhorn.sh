#!/bin/bash
# Diagnostic Longhorn
set -e

echo "=== DIAGNOSTIC LONGHORN ==="

echo "1. Status des pods:"
kubectl get pods -n longhorn-system

echo -e "\n2. Logs longhorn-manager:"
kubectl logs -n longhorn-system -l app=longhorn-manager --tail=10 || true

echo -e "\n3. Prérequis workers (à vérifier sur chaque worker):"
echo "Sur chaque worker, vérifiez:"
echo "- apt install -y open-iscsi util-linux"
echo "- systemctl enable --now iscsid"

echo -e "\n4. Alternative: Utiliser le stockage local K3s"
echo "Longhorn peut être lourd pour un lab. Le stockage local suffit souvent."
