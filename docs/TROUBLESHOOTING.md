# Troubleshooting et Maintenance

## Diagnostic Réseau

### Vérification Connectivité Inter-Nœuds
```bash
# Test ping entre nœuds
for node in 192.168.1.101 192.168.1.100 192.168.1.99; do
  ping -c 2 $node
done

# Test ports Kubernetes
nmap -p 6443,10250,2379,2380 192.168.1.102

# Test VXLAN Flannel
tcpdump -i any port 8472
```

### Debug CNI Flannel
```bash
# Vérifier les routes
ip route show | grep flannel
cat /run/flannel/subnet.env

# Logs Flannel
kubectl logs -n kube-system -l app=flannel
```

## Diagnostic Stockage Longhorn

### Vérification Santé Volumes
```bash
# État des volumes
kubectl get volumes -n longhorn-system
kubectl get replicas -n longhorn-system

# Diagnostic iSCSI
iscsiadm -m session -P 3
systemctl status iscsid
```

### Réparation Volume Corrompu
```bash
# Forcer rebuild replica
kubectl patch replica REPLICA_NAME -n longhorn-system --type='json' \
  -p='[{"op": "replace", "path": "/spec/failedAt", "value": ""}]'

# Backup/Restore
kubectl apply -f backup-job.yaml
```

## Performance Monitoring

### Métriques Système
```bash
# CPU/RAM par nœud
kubectl top nodes
kubectl top pods --all-namespaces

# I/O disque
iostat -x 1
iotop -o

# Réseau
iftop -i eth0
ss -tuln | grep :6443
```

### Métriques Applicatives
```bash
# Latence API Server
curl -k https://192.168.1.102:6443/metrics | grep apiserver_request_duration

# Métriques Traefik
curl http://192.168.1.102:8080/metrics

# Longhorn metrics
kubectl port-forward -n longhorn-system svc/longhorn-frontend 9090:80
curl http://localhost:9090/metrics
```

## Maintenance Préventive

### Mise à Jour Cluster
```bash
# Upgrade K3s
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.35.0+k3s1" sh -

# Drain nœud pour maintenance
kubectl drain kubctl0 --ignore-daemonsets --delete-emptydir-data
# Maintenance...
kubectl uncordon kubctl0
```

### Sauvegarde
```bash
# Backup etcd (K3s utilise SQLite)
cp /var/lib/rancher/k3s/server/db/state.db /backup/

# Backup Longhorn
kubectl create -f longhorn-backup-job.yaml

# Backup configurations
kubectl get all --all-namespaces -o yaml > cluster-backup.yaml
```

### Nettoyage
```bash
# Images inutilisées
crictl rmi --prune

# Logs anciens
journalctl --vacuum-time=7d

# Volumes Longhorn orphelins
kubectl delete volumes -n longhorn-system --field-selector=status.state=detached
```

## Sécurité

### Audit et Compliance
```bash
# Vérifier RBAC
kubectl auth can-i --list --as=system:serviceaccount:default:default

# Scanner vulnérabilités
trivy image traefik:v3.6
kube-bench run --targets master,node

# Rotation certificats
kubeadm certs check-expiration
kubeadm certs renew all
```

### Hardening
```bash
# Network policies restrictives
kubectl apply -f network-policies/

# Pod Security Standards
kubectl label namespace default pod-security.kubernetes.io/enforce=restricted

# Secrets encryption at rest
kubectl create secret generic test --from-literal=key=value
etcdctl get /registry/secrets/default/test
```

## Scenarios de Panne

### Panne Master
```bash
# Backup automatique
systemctl enable k3s-backup.timer

# Restauration
systemctl stop k3s
rm -rf /var/lib/rancher/k3s/server/db/
cp /backup/state.db /var/lib/rancher/k3s/server/db/
systemctl start k3s
```

### Panne Worker
```bash
# Le cluster continue à fonctionner
# Pods redéployés automatiquement sur nœuds sains
kubectl get pods -o wide

# Réintégration nœud
./worker-deploy.sh  # Rejoint automatiquement
```

### Split Storage
```bash
# Longhorn gère automatiquement
# Quorum 2/3 replicas maintient la cohérence
kubectl get volumes -n longhorn-system -o wide
```

Cette documentation couvre tous les aspects opérationnels pour maintenir le cluster en production.
