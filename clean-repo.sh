#!/bin/bash
# Nettoyage et réorganisation du repository
set -e

cd /home/kubernetes

echo "=== NETTOYAGE DU REPOSITORY ==="

# Supprimer les scripts de debug/correction temporaires
rm -f master-192.168.1.102/debug-*.sh
rm -f master-192.168.1.102/fix-*.sh
rm -f master-192.168.1.102/quick-*.sh
rm -f master-192.168.1.102/remove-*.sh
rm -f master-192.168.1.102/configure-*.sh
rm -f master-192.168.1.102/deploy-fixed.sh
rm -f master-192.168.1.102/deploy-portainer.sh
rm -f master-192.168.1.102/deploy-traefik.sh
rm -f master-192.168.1.102/install-longhorn.sh
rm -f master-192.168.1.102/enable-*.sh
rm -f master-192.168.1.102/finalize-*.sh
rm -f master-192.168.1.102/deploy.sh
rm -f worker*/deploy.sh

# Garder seulement les scripts finaux
# master-192.168.1.102/deploy-k3s.sh (script principal)
# worker*/deploy-k3s.sh (scripts workers)
# check-cluster.sh et test-apps.sh (utilitaires)

# Créer un nouveau README avec l'ordre correct
cat > README.md << EOF
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
- ✅ Stockage distribué Longhorn avec réplication
- ✅ Load balancer Traefik avec dashboard
- ✅ Interface Portainer pour la gestion
- ✅ Scripts de déploiement automatisés

## Déploiement - ORDRE OBLIGATOIRE

### 1. Master Node (192.168.1.102)
\`\`\`bash
cd master-192.168.1.102/
./deploy-k3s.sh
\`\`\`
**Récupérez le token affiché à la fin !**

### 2. Modifier les scripts workers
Éditez les fichiers workers et remplacez le token :
- \`worker1-192.168.1.101/deploy-k3s.sh\`
- \`worker2-192.168.1.100/deploy-k3s.sh\`
- \`worker3-192.168.1.99/deploy-k3s.sh\`

### 3. Déployer les workers (dans l'ordre)
\`\`\`bash
# Sur 192.168.1.101
cd worker1-192.168.1.101/
./deploy-k3s.sh

# Sur 192.168.1.100
cd worker2-192.168.1.100/
./deploy-k3s.sh

# Sur 192.168.1.99
cd worker3-192.168.1.99/
./deploy-k3s.sh
\`\`\`

### 4. Vérification (sur le master)
\`\`\`bash
./check-cluster.sh
./test-apps.sh
\`\`\`

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
EOF

# Créer un guide de déploiement
cat > DEPLOYMENT.md << EOF
# Guide de Déploiement Étape par Étape

## Prérequis
- 4 serveurs avec accès root
- IPs : 192.168.1.102 (master), 192.168.1.101/100/99 (workers)

## Étapes de Déploiement

### 1. Copier les scripts
\`\`\`bash
# Sur chaque serveur, copier le dossier correspondant
scp -r master-192.168.1.102/ root@192.168.1.102:/root/
scp -r worker1-192.168.1.101/ root@192.168.1.101:/root/
scp -r worker2-192.168.1.100/ root@192.168.1.100:/root/
scp -r worker3-192.168.1.99/ root@192.168.1.99:/root/
\`\`\`

### 2. Déployer le master
\`\`\`bash
ssh root@192.168.1.102
cd master-192.168.1.102/
chmod +x *.sh
./deploy-k3s.sh
\`\`\`

### 3. Récupérer le token
À la fin du script master, copiez la ligne qui ressemble à :
\`K10xxxxx::server:xxxxxx\`

### 4. Modifier les workers
Éditez chaque script worker et remplacez la ligne :
\`K3S_TOKEN=""\` par \`K3S_TOKEN="VOTRE_TOKEN"\`

### 5. Déployer les workers
\`\`\`bash
# Worker 1
ssh root@192.168.1.101
cd worker1-192.168.1.101/
chmod +x *.sh
./deploy-k3s.sh

# Worker 2
ssh root@192.168.1.100
cd worker2-192.168.1.100/
chmod +x *.sh
./deploy-k3s.sh

# Worker 3
ssh root@192.168.1.99
cd worker3-192.168.1.99/
chmod +x *.sh
./deploy-k3s.sh
\`\`\`

### 6. Vérification finale
\`\`\`bash
# Sur le master
kubectl get nodes
kubectl get pods -A
\`\`\`

## Temps de déploiement
- Master : ~5 minutes
- Chaque worker : ~3 minutes
- **Total : ~15 minutes**

## Dépannage
Si un worker ne se connecte pas :
1. Vérifier le token
2. Vérifier la connectivité réseau
3. Relancer le script worker
EOF

git add .
git commit -m "Clean repository: keep only essential scripts with proper deployment order"
git push

echo "=== REPOSITORY NETTOYÉ ==="
echo "Scripts organisés avec ordre de déploiement clair"
