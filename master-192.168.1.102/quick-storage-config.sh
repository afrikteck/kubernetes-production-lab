#!/bin/bash
# Configuration stockage distribué - Version rapide
set -e

echo "=== CONFIGURATION STOCKAGE DISTRIBUÉ ==="

# Configurer Longhorn comme défaut
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Nettoyage forcé
kubectl delete deployment portainer -n portainer --force --grace-period=0 2>/dev/null || true
kubectl delete pvc portainer-pvc-longhorn -n portainer --force --grace-period=0 2>/dev/null || true

sleep 5

# Créer le PVC d'abord
cat > /tmp/portainer-pvc.yaml << EOF
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

kubectl apply -f /tmp/portainer-pvc.yaml

echo "Attente du PVC..."
kubectl wait --for=condition=Bound pvc/portainer-pvc-longhorn -n portainer --timeout=120s

# Puis le deployment
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

echo "=== STOCKAGE DISTRIBUÉ CONFIGURÉ ==="
kubectl get pods -n portainer
kubectl get pvc -n portainer
