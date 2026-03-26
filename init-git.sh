#!/bin/bash
# Initialisation du repository Git
set -e

echo "=== INITIALISATION REPOSITORY GIT ==="

cd /home/kubernetes

# Initialiser le repo
git init

# Créer .gitignore
cat > .gitignore << EOF
# Fichiers temporaires
/tmp/
*.tmp
*.log

# Fichiers de configuration sensibles
*.env
**/tokens.txt

# Fichiers Kubernetes générés
**/admin.conf
**/k3s.yaml
EOF

# Créer README.md
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
- ✅ Stockage distribué Longhorn
- ✅ Load balancer Traefik
- ✅ Interface Portainer
- ✅ Scripts de déploiement automatisés

## Déploiement

### Master Node
\`\`\`bash
cd master-192.168.1.102/
./deploy-k3s.sh
\`\`\`

### Workers
\`\`\`bash
# Sur chaque worker
cd worker{X}-192.168.1.{IP}/
./deploy-k3s.sh
\`\`\`

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
EOF

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit: Kubernetes lab with K3s, Traefik, Longhorn"

echo "=== REPOSITORY INITIALISÉ ==="
echo "Prêt pour GitHub !"
echo ""
echo "Prochaines étapes :"
echo "1. Créer un repo sur GitHub"
echo "2. git remote add origin https://github.com/USERNAME/k8s-lab.git"
echo "3. git push -u origin main"
