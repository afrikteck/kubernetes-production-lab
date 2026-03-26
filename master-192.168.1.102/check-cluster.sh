#!/bin/bash
# Script de vérification du cluster
set -e

echo "=== CLUSTER STATUS ==="
kubectl get nodes -o wide

echo -e "\n=== PODS SYSTÈME ==="
kubectl get pods -n kube-system

echo -e "\n=== SERVICES ==="
kubectl get svc -A

echo -e "\n=== TRAEFIK STATUS ==="
kubectl get pods -n kube-system | grep traefik
