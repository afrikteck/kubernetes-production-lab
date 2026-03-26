#!/bin/bash
# K3s Master - Installation complète avec Traefik Dashboard et Portainer
set -e

# Arrêt complet des services
systemctl stop kubelet containerd 2>/dev/null || true
pkill -f kubelet 2>/dev/null || true
pkill -f containerd 2>/dev/null || true
sleep 5

# Nettoyage complet automatique
kubeadm reset -f 2>/dev/null || true
rm -rf /usr/local/bin/kube* /etc/kubernetes /var/lib/kubelet /var/lib/etcd 2>/dev/null || true

# Installation K3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--bind-address=192.168.1.102 --advertise-address=192.168.1.102 --node-external-ip=192.168.1.102" sh -

# Attendre que K3s soit prêt
sleep 30

# Configuration kubectl
mkdir -p $HOME/.kube
cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sed -i 's/127.0.0.1/192.168.1.102/g' $HOME/.kube/config

# Configuration master ingress-only (pas de pods applicatifs)
kubectl taint nodes ingress node-role.kubernetes.io/control-plane:NoSchedule --overwrite

# Activation dashboard Traefik
kubectl patch deployment traefik -n kube-system --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--api.dashboard=true"},
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--api.insecure=true"}
]'

kubectl patch service traefik -n kube-system --type='json' -p='[
  {"op": "add", "path": "/spec/ports/-", "value": {"name": "dashboard", "port": 8080, "targetPort": 8080, "protocol": "TCP"}}
]'

kubectl rollout restart deployment traefik -n kube-system
kubectl rollout status deployment traefik -n kube-system

# Déploiement Portainer
kubectl create namespace portainer --dry-run=client -o yaml | kubectl apply -f -

cat > /tmp/portainer.yaml << EOF
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
  - port: 9000
    targetPort: 9000
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

kubectl apply -f /tmp/portainer.yaml

# App de test whoami
cat > /tmp/whoami.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
spec:
  replicas: 3
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
      - name: whoami
        image: traefik/whoami
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  selector:
    app: whoami
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: whoami
spec:
  rules:
  - host: whoami.192.168.1.102.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: whoami
            port:
              number: 80
EOF

kubectl apply -f /tmp/whoami.yaml

echo "=== TOKEN POUR LES WORKERS ==="
cat /var/lib/rancher/k3s/server/node-token

echo "=== CLUSTER PRÊT ==="
kubectl get nodes
echo ""
echo "Services disponibles:"
echo "- Dashboard Traefik: http://192.168.1.102:8080"
echo "- Portainer: http://portainer.192.168.1.102.nip.io"
echo "- App test: http://whoami.192.168.1.102.nip.io"
