# Laboratoire Kubernetes Production-Ready

Infrastructure Kubernetes automatisée avec K3s, Traefik et Longhorn.

## Architecture

- **Master Node** (192.168.1.102) : Control-plane + Traefik Ingress
- **Worker Nodes** : 
  - kubctl0 (192.168.1.101)
  - kubctl1 (192.168.1.100) 
  - kubctl2 (192.168.1.99)

## Fonctionnalités

- ✅ Cluster K3s haute disponibilité
- ✅ Stockage distribué Longhorn
- ✅ Load balancer Traefik
- ✅ Interface Portainer
- ✅ Scripts de déploiement automatisés

## Déploiement

### Master Node
```bash
cd master-192.168.1.102/
./deploy-k3s.sh
```

### Workers
```bash
# Sur chaque worker
cd worker{X}-192.168.1.{IP}/
./deploy-k3s.sh
```

## Services

- **Portainer** : http://portainer.192.168.1.102.nip.io
- **Longhorn UI** : http://longhorn.192.168.1.102.nip.io
- **Traefik Dashboard** : http://192.168.1.102:8080
- **App test** : http://whoami.192.168.1.102.nip.io

## Production

Architecture prête pour :
- Serveurs distants
- Connexions VPN
- Haute disponibilité
- Stockage distribué et répliqué
