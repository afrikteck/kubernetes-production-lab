#!/bin/bash
# Configuration du master en mode ingress-only
set -e

echo "=== CONFIGURATION MASTER INGRESS-ONLY ==="

# Ajouter un taint pour empêcher les pods sur le master
kubectl taint nodes ingress node-role.kubernetes.io/control-plane:NoSchedule --overwrite

# Vérifier les taints
kubectl describe node ingress | grep Taints

echo "=== REDÉPLOIEMENT DES PODS EXISTANTS ==="

# Forcer le redéploiement de Portainer sur les workers uniquement
kubectl delete pod -n portainer -l app=portainer

# Attendre le redéploiement
sleep 10
kubectl get pods -n portainer -o wide

echo "=== MASTER CONFIGURÉ ==="
echo "Le master 'ingress' ne fera plus tourner de pods applicatifs"
echo "Seuls les workers kubctl0/1/2 hébergeront les applications"
