# Kubernetes Production Lab

Infrastructure Kubernetes automatisée avec K3s, Traefik et Longhorn.

## 🚀 Déploiement Rapide

```bash
# 1. Master
cd master-192.168.1.102/
./deploy-k3s.sh

# 2. Récupérer le token et modifier les scripts workers

# 3. Workers
cd worker1-192.168.1.101/ && ./deploy-k3s.sh
cd worker2-192.168.1.100/ && ./deploy-k3s.sh  
cd worker3-192.168.1.99/ && ./deploy-k3s.sh
```

## 📋 Documentation

- **[Architecture Technique](docs/ARCHITECTURE.md)** - Protocoles, flux de données, sécurité
- **[Guide de déploiement](docs/DEPLOYMENT.md)** - Instructions détaillées
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Diagnostic et maintenance
- **[README complet](docs/README.md)** - Fonctionnalités et structure

## 🌐 Services

- **Portainer** : http://portainer.192.168.1.102.nip.io
- **Longhorn UI** : http://longhorn.192.168.1.102.nip.io
- **Traefik Dashboard** : http://192.168.1.102:8080

## ⚡ Caractéristiques

- ✅ Cluster K3s haute disponibilité
- ✅ Stockage distribué Longhorn
- ✅ Load balancer Traefik
- ✅ Interface Portainer
- ✅ Déploiement automatisé (~15 min)
