#!/bin/bash
# Nettoyage Longhorn et retour au stockage local
set -e

echo "=== SUPPRESSION LONGHORN ==="

# Supprimer Longhorn
kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/longhorn.yaml --ignore-not-found

# Attendre la suppression
sleep 30

# Remettre local-path comme défaut
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Redéployer Portainer avec stockage local
kubectl delete pvc portainer-pvc-longhorn -n portainer --ignore-not-found
kubectl delete deployment portainer -n portainer --ignore-not-found

cat > /tmp/portainer-simple.yaml << EOF
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
          claimName: portainer-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: portainer-pvc
  namespace: portainer
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 10Gi
EOF

kubectl apply -f /tmp/portainer-simple.yaml

echo "=== STOCKAGE LOCAL RESTAURÉ ==="
echo "Portainer utilise maintenant le stockage local K3s"
echo "Plus simple et fiable pour un laboratoire"
