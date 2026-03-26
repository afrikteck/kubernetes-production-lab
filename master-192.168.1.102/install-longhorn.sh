#!/bin/bash
# Installation Longhorn pour stockage distribué
set -e

echo "=== INSTALLATION LONGHORN ==="

# Installer Longhorn
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/longhorn.yaml

echo "Attente de Longhorn..."
kubectl wait --for=condition=ready pod -l app=longhorn-manager -n longhorn-system --timeout=300s

# Définir Longhorn comme StorageClass par défaut
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Redéployer Portainer avec Longhorn
kubectl delete pvc portainer-pvc -n portainer --ignore-not-found
kubectl delete deployment portainer -n portainer --ignore-not-found

cat > /tmp/portainer-ha.yaml << EOF
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
    - ReadWriteMany
  storageClassName: longhorn
  resources:
    requests:
      storage: 10Gi
EOF

kubectl apply -f /tmp/portainer-ha.yaml

echo "=== LONGHORN INSTALLÉ ==="
echo "Stockage distribué et répliqué sur tous les workers"
echo "Longhorn UI: http://longhorn.192.168.1.102.nip.io (à configurer)"
