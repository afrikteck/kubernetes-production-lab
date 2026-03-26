# Laboratoire Kubernetes Production-Ready

Infrastructure Kubernetes automatisée avec K3s, Traefik et Longhorn.

## Architecture

- **Master Node** (192.168.1.102) : Control-plane + Traefik Ingress
- **Worker Nodes** : 
  - kubctl0 (192.168.1.101)
  - kubctl1 (192.168.1.100) 
  - kubctl2 (192.168.1.99)

## Structure du Repository

### 📁 master-192.168.1.102/
- **`deploy-k3s.sh`** ⭐ : Script principal d'installation du master (K3s + Traefik + Longhorn + Portainer)
- **`check-cluster.sh`** : Vérification de l'état du cluster (nodes, pods, services)
- **`test-apps.sh`** : Déploiement et test de l'application whoami
- **`ingress-routes.yaml`** : Configuration des routes Traefik (dashboard, longhorn)
- **`whoami-k3s.yaml`** : Manifeste de l'application de test whoami
- **`whoami-test.yaml`** : Version alternative du manifeste whoami

### 📁 worker1-192.168.1.101/
- **`deploy-k3s.sh`** ⭐ : Script d'installation du worker 1 (avec prérequis Longhorn)

### 📁 worker2-192.168.1.100/
- **`deploy-k3s.sh`** ⭐ : Script d'installation du worker 2 (avec prérequis Longhorn)

### 📁 worker3-192.168.1.99/
- **`deploy-k3s.sh`** ⭐ : Script d'installation du worker 3 (avec prérequis Longhorn)

### 📁 Racine
- **`README.md`** : Cette documentation
- **`DEPLOYMENT.md`** : Guide de déploiement détaillé
- **`.gitignore`** : Exclusions Git (fichiers sensibles)
- **`init-git.sh`** : Script d'initialisation du repository Git
- **`clean-repo.sh`** : Script de nettoyage du repository

## Fonctionnalités

- ✅ Cluster K3s haute disponibilité
- ✅ Stockage distribué Longhorn avec réplication
- ✅ Load balancer Traefik avec dashboard
- ✅ Interface Portainer pour la gestion
- ✅ Scripts de déploiement automatisés

## Déploiement - ORDRE OBLIGATOIRE

### 1. Master Node (192.168.1.102)
```bash
cd master-192.168.1.102/
./deploy-k3s.sh
```
**Récupérez le token affiché à la fin !**

### 2. Modifier les scripts workers
Éditez les fichiers workers et remplacez le token :
- `worker1-192.168.1.101/deploy-k3s.sh`
- `worker2-192.168.1.100/deploy-k3s.sh`
- `worker3-192.168.1.99/deploy-k3s.sh`

### 3. Déployer les workers (dans l'ordre)
```bash
# Sur 192.168.1.101
cd worker1-192.168.1.101/
./deploy-k3s.sh

# Sur 192.168.1.100
cd worker2-192.168.1.100/
./deploy-k3s.sh

# Sur 192.168.1.99
cd worker3-192.168.1.99/
./deploy-k3s.sh
```

### 4. Vérification (sur le master)
```bash
./check-cluster.sh    # Vérifier l'état du cluster
./test-apps.sh        # Déployer et tester l'application whoami
```

## Services disponibles

- **Portainer** : http://portainer.192.168.1.102.nip.io
- **Longhorn UI** : http://longhorn.192.168.1.102.nip.io
- **Traefik Dashboard** : http://192.168.1.102:8080
- **App test** : http://whoami.192.168.1.102.nip.io

## Caractéristiques Production

- **Haute disponibilité** : Failover automatique
- **Stockage distribué** : Réplication sur 3 nœuds
- **Load balancing** : Traefik avec ingress
- **Monitoring** : Interfaces web complètes
- **Sécurité** : Master dédié (pas de pods applicatifs)

## Prérequis

- 4 VMs Debian/Ubuntu
- Accès root avec mot de passe
- Réseau 192.168.1.x/24
- Connexion Internet

## Architecture pour Production

Cette configuration est prête pour :
- Serveurs distants
- Connexions VPN
- Scaling horizontal
- Sauvegardes automatiques
