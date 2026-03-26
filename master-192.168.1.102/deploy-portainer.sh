#!/bin/bash
# Déploiement Portainer sur Kubernetes
set -e

echo "=== DÉPLOIEMENT PORTAINER ==="

# Créer le namespace
kubectl create namespace portainer --dry-run=client -o yaml | kubectl apply -f -

# Déployer Portainer
cat > portainer.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: portainer-sa-clusteradmin
  namespace: portainer
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: portainer-crb-clusteradmin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: portainer-sa-clusteradmin
  namespace: portainer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: portainer-pvc
  namespace: portainer
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
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
        - containerPort: 8000
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
kind: Service
metadata:
  name: portainer
  namespace: portainer
spec:
  selector:
    app: portainer
  ports:
  - name: http
    port: 9000
    targetPort: 9000
  - name: edge
    port: 8000
    targetPort: 8000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: portainer
  namespace: portainer
spec:
  rules:
  - host: portainer.192.168.1.102.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: portainer
            port:
              number: 9000
EOF

kubectl apply -f portainer.yaml

echo "Attente du déploiement..."
kubectl wait --for=condition=available --timeout=300s deployment/portainer -n portainer

echo "=== PORTAINER DÉPLOYÉ ==="
echo "Accès: http://portainer.192.168.1.102.nip.io"
echo "Premier accès: créez un compte admin"
