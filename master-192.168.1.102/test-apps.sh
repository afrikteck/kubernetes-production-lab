#!/bin/bash
# Script de test des applications
set -e

echo "=== DÉPLOIEMENT APP DE TEST ==="

# Déployer whoami
kubectl apply -f whoami-k3s.yaml

echo "Attente du déploiement..."
sleep 10

# Vérifier le déploiement
echo "=== STATUS ==="
kubectl get pods
kubectl get ingress
kubectl get svc

echo -e "\n=== TEST CURL ==="
curl -H 'Host: whoami.192.168.1.102.nip.io' http://192.168.1.102

echo -e "\n=== ACCÈS NAVIGATEUR ==="
echo "http://whoami.192.168.1.102.nip.io"
