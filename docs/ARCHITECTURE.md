# Architecture Technique Interne

## Protocoles et Communications

### Cluster Kubernetes (K3s)
- **API Server** : HTTPS/6443 (REST API, authentification mTLS)
- **etcd** : Intégré dans K3s (SQLite par défaut, pas de cluster etcd séparé)
- **Kubelet** : HTTP/10250 (communication master ↔ workers)
- **Container Runtime** : containerd via CRI (Container Runtime Interface)

### Réseau Pod (Flannel CNI)
- **CIDR Pods** : `10.42.0.0/16` (réseau overlay VXLAN)
- **CIDR Services** : `10.43.0.0/16` (ClusterIP virtuel)
- **Flannel Backend** : VXLAN sur UDP/8472
- **Cross-node** : Encapsulation VXLAN entre workers

### Stockage Distribué (Longhorn)
- **iSCSI** : TCP/3260 (accès aux volumes entre nœuds)
- **Longhorn Manager** : HTTP/9500 (API interne)
- **Engine Process** : TCP/10000-10999 (réplication des données)
- **Replica Sync** : TCP direct entre instance-managers

## Architecture des Composants

### Master Node (Control Plane)
```
┌─────────────────────────────────────┐
│ Master (192.168.1.102)              │
├─────────────────────────────────────┤
│ kube-apiserver     :6443            │
│ kube-scheduler                      │
│ kube-controller-manager             │
│ etcd (SQLite)                       │
│ traefik            :80,:443,:8080   │
│ coredns            :53              │
└─────────────────────────────────────┘
```

### Worker Nodes
```
┌─────────────────────────────────────┐
│ Workers (kubctl0/1/2)               │
├─────────────────────────────────────┤
│ kubelet            :10250           │
│ kube-proxy         (iptables)       │
│ containerd         :2376            │
│ longhorn-manager   :9500            │
│ longhorn-csi       (volumes)        │
│ flannel            :8472 (VXLAN)    │
└─────────────────────────────────────┘
```

## Flux de Données

### Déploiement d'un Pod
1. **kubectl** → API Server (HTTPS/6443)
2. **API Server** → etcd (stockage état)
3. **Scheduler** → sélection nœud optimal
4. **API Server** → kubelet worker (HTTP/10250)
5. **kubelet** → containerd (CRI)
6. **containerd** → pull image + start container

### Accès Application via Traefik
1. **Client** → Traefik (HTTP/80)
2. **Traefik** → Service Discovery (API Server)
3. **Traefik** → Pod backend (réseau Flannel)
4. **Load Balancing** : Round-robin entre replicas

### Réplication Longhorn
1. **Volume Write** → Engine Process (leader)
2. **Engine** → Replica 1,2,3 (TCP sync)
3. **Quorum** : 2/3 replicas OK = write success
4. **Failure** : Auto-rebuild replica sur nœud sain

## Sécurité et Authentification

### Certificats TLS
- **CA Cluster** : Auto-générée par kubeadm
- **API Server** : Cert pour 192.168.1.102 + DNS
- **kubelet** : Client cert pour auth master
- **etcd** : Peer + client certs

### RBAC (Role-Based Access Control)
- **ServiceAccounts** : Identité pods
- **ClusterRoles** : Permissions cluster-wide
- **RoleBindings** : Association user ↔ permissions

### Network Policies
- **Default** : All traffic allowed (lab config)
- **Production** : Micro-segmentation possible

## Haute Disponibilité

### Failover Automatique
- **Node Failure** : 30s detection → pod eviction
- **Pod Restart** : Automatic via ReplicaSet
- **Storage** : Longhorn auto-rebuild replicas
- **Load Balancer** : Traefik health checks

### Split-Brain Prevention
- **Single Master** : Pas de split-brain possible
- **Longhorn Quorum** : 2/3 replicas minimum
- **etcd** : SQLite local (pas de consensus distribué)

## Monitoring et Observabilité

### Métriques Natives
- **kubelet** : cAdvisor metrics (CPU/RAM/IO)
- **API Server** : Request latency, errors
- **Traefik** : HTTP metrics, response times
- **Longhorn** : Volume IOPS, latency, health

### Logs Centralisés
- **Container logs** : `/var/log/pods/`
- **System logs** : journald
- **Audit logs** : API Server (optionnel)

## Optimisations Production

### Performance
- **CPU Pinning** : Possible via CPU Manager
- **NUMA Awareness** : Topology Manager
- **Storage Classes** : SSD vs HDD tiers
- **Network QoS** : Bandwidth limits

### Scalabilité
- **Horizontal** : Ajout workers (kubectl join)
- **Vertical** : Resource limits/requests
- **Storage** : Longhorn expansion automatique
- **Ingress** : Traefik multi-replica

Cette architecture garantit une infrastructure robuste, scalable et production-ready.
