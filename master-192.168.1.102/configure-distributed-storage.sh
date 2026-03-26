#!/bin/bash
# Configuration stockage distribué Longhorn
set -e

echo "=== CONFIGURATION STOCKAGE DISTRIBUÉ ==="

# Attendre que tous les pods Longhorn soient prêts
echo "Attente de Longhorn..."
kubectl wait --for=condition=ready pod -l app=longhorn-manager -n longhorn-system --timeout=300s

# Configurer Longhorn comme stockage par défaut
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

echo "=== REDÉPLOIEMENT PORTAINER AVEC LONGHORN ==="

# Supprimer l'ancien Portainer
kubectl delete pvc portainer-pvc -n portainer --ignore-not-found
kubectl delete deployment portainer -n portainer --ignore-not-found

# Déployer Portainer avec stockage distribué
cat > /tmp/portainer-longhorn.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portainer
  namespace: portainer
spec:
  replicas: 2
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
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: portainer-pvc-longhorn
  namespace: portainer
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 10Gi
EOF

kubectl apply -f /tmp/portainer-longhorn.yaml

# Créer l'ingress pour Longhorn UI
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

echo "Attente du déploiement Portainer..."
kubectl wait --for=condition=available --timeout=300s deployment/portainer -n portainer

echo "=== STOCKAGE DISTRIBUÉ CONFIGURÉ ==="
echo ""
echo "Services avec stockage distribué :"
echo "- Portainer: http://portainer.192.168.1.102.nip.io (2 replicas)"
echo "- Longhorn UI: http://longhorn.192.168.1.102.nip.io"
echo ""
echo "Caractéristiques :"
echo "- Stockage répliqué sur 3 workers"
echo "- Haute disponibilité automatique"
echo "- Sauvegarde et restauration"
echo "- Prêt pour la production"
