#!/bin/bash
set -e

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add traefik https://traefik.github.io/charts
helm repo update

kubectl create namespace traefik
helm install traefik traefik/traefik --namespace traefik --set service.type=LoadBalancer --set service.spec.externalIPs[0]=192.168.1.102

kubectl apply -f ingress-routes.yaml
