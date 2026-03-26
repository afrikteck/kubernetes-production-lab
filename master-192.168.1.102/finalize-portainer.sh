#!/bin/bash
# Finalisation Portainer avec Longhorn
set -e

echo "=== DÉPLOIEMENT PORTAINER AVEC LONGHORN ==="

# Créer le deployment Portainer
cat > /tmp/portainer-deploy.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portainer
  namespace: portainer
spec:
  replicas: 1
  selector:
    matchLabels:
      app: portainer
  template:
    metadata:
      labels:
        app: portainer
    spec:
      serviceAccountName: portainer-sa-clusteradmin
      containers:
      - name: portainer
        image: portainer/portainer-ce:latest
        ports:
        - containerPort: 9000
        volumeMounts:
        - name: data
          mountPath: /data
        env:
        - name: PORTAINER_K8S_MODE
          value: "true"
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: portainer-pvc-longhorn
EOF

kubectl apply -f /tmp/portainer-deploy.yaml

# Créer l'ingress Longhorn UI
cat > /tmp/longhorn-ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: longhorn-ui
  namespace: longhorn-system
spec:
  rules:
  - host: longhorn.192.168.1.102.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: longhorn-frontend
            port:
              number: 80
EOF

kubectl apply -f /tmp/longhorn-ingress.yaml

echo "=== VÉRIFICATION ==="
kubectl get pods -n portainer
kubectl get pvc -n portainer

echo "=== LABORATOIRE PRODUCTION-READY ==="
echo "- Portainer: http://portainer.192.168.1.102.nip.io"
echo "- Longhorn UI: http://longhorn.192.168.1.102.nip.io"
echo "- Traefik Dashboard: http://192.168.1.102:8080"
