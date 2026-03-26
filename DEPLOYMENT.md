# Guide de Déploiement Étape par Étape

## Prérequis
- 4 serveurs avec accès root
- IPs : 192.168.1.102 (master), 192.168.1.101/100/99 (workers)

## Étapes de Déploiement

### 1. Copier les scripts
```bash
# Sur chaque serveur, copier le dossier correspondant
scp -r master-192.168.1.102/ root@192.168.1.102:/root/
scp -r worker1-192.168.1.101/ root@192.168.1.101:/root/
scp -r worker2-192.168.1.100/ root@192.168.1.100:/root/
scp -r worker3-192.168.1.99/ root@192.168.1.99:/root/
```

### 2. Déployer le master
```bash
ssh root@192.168.1.102
cd master-192.168.1.102/
chmod +x *.sh
./deploy-k3s.sh
```

### 3. Récupérer le token
À la fin du script master, copiez la ligne qui ressemble à :
`K10xxxxx::server:xxxxxx`

### 4. Modifier les workers
Éditez chaque script worker et remplacez la ligne :
`K3S_TOKEN=""` par `K3S_TOKEN="VOTRE_TOKEN"`

### 5. Déployer les workers
```bash
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
```

### 6. Vérification finale
```bash
# Sur le master
kubectl get nodes
kubectl get pods -A
```

## Temps de déploiement
- Master : ~5 minutes
- Chaque worker : ~3 minutes
- **Total : ~15 minutes**

## Dépannage
Si un worker ne se connecte pas :
1. Vérifier le token
2. Vérifier la connectivité réseau
3. Relancer le script worker
