#!/bin/bash
# Activation du dashboard Traefik
set -e

echo "=== ACTIVATION DASHBOARD TRAEFIK ==="

# Modifier la configuration Traefik pour activer le dashboard
kubectl patch deployment traefik -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--api.dashboard=true"
  },
  {
    "op": "add", 
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--api.insecure=true"
  }
]'

# Exposer le port 8080 pour le dashboard
kubectl patch service traefik -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/ports/-",
    "value": {
      "name": "dashboard",
      "port": 8080,
      "targetPort": 8080,
      "protocol": "TCP"
    }
  }
]'

echo "Redémarrage de Traefik..."
kubectl rollout restart deployment traefik -n kube-system
kubectl rollout status deployment traefik -n kube-system

echo "=== DASHBOARD ACTIVÉ ==="
echo "Accès: http://192.168.1.102:8080"
