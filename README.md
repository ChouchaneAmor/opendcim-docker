# OpenDCIM sur Docker

Conteneurisation d'OpenDCIM 23.04 respectant le guide d'installation manuel
(Apache + PHP + MariaDB + authentification htpasswd).

**Le code source complet d'OpenDCIM vit directement dans ce dossier**
(`./opendcim/`), monté en volume dans le conteneur — pas besoin d'entrer
dans le conteneur pour éditer les fichiers PHP.

## Structure

```
opendcim-docker/
├── Dockerfile              # Image Apache/PHP (sans le code source)
├── docker-compose.yml      # Orchestration app + base de données
├── entrypoint.sh           # htpasswd, config DB, permissions
├── setup.sh                # Télécharge OpenDCIM dans ./opendcim/
├── apache/
│   └── opendcim.conf       # Virtual host
├── .env.example            # Modèle des variables d'environnement
└── opendcim/                # ⭐ Code source OpenDCIM (créé par setup.sh)
    ├── index.php
    ├── db.inc.php
    ├── DeviceTemplate.class.php
    ├── assets/
    └── ...
```

## Déploiement

```bash
git clone <votre-repo> opendcim-docker
cd opendcim-docker

# 1. Télécharger le code source d'OpenDCIM à la racine du projet
chmod +x setup.sh
./setup.sh

# 2. Configurer les identifiants
cp .env.example .env
vim .env

# 3. Construire et démarrer
docker compose up -d --build
```

## Accès

```
http://localhost:8080
```

Identifiants HTTP (Basic Auth) : ceux définis dans `.env`
(`DCIM_HTTP_USER` / `DCIM_HTTP_PASS`). Termine ensuite l'installation
via l'interface web comme dans le guide original.

## Modifier le code source

Comme `./opendcim/` est monté en volume, toute modification d'un fichier
PHP sur ta machine hôte est immédiatement visible dans le conteneur —
pas besoin de rebuild. Un simple rafraîchissement de la page suffit.

```bash
vim opendcim/DeviceTemplate.class.php
# → rafraîchis simplement la page web, le changement est actif
```

## Persistance des données

- `dcim_db_data` (volume Docker) : les données MariaDB.
- `./opendcim/assets/` (dossier sur ta machine) : images/plans uploadés.
- `./opendcim/db.inc.php` : identifiants de connexion générés au premier démarrage.

## Sauvegarde avec Git/GitHub

Le code source d'OpenDCIM (`./opendcim/`) peut être versionné avec le
reste du projet, mais certains fichiers ne doivent PAS être commités
(secrets et données utilisateur générées). `.gitignore` recommandé :

```
.env
opendcim/db.inc.php
opendcim/.htpasswd
opendcim/assets/pictures/*
opendcim/assets/drawings/*
!opendcim/assets/pictures/.gitkeep
!opendcim/assets/drawings/.gitkeep
```

## Commandes utiles

```bash
docker compose logs -f opendcim     # voir les logs Apache
docker compose exec opendcim bash   # entrer dans le conteneur
docker compose down                 # arrêter (les volumes sont conservés)
docker compose down -v              # arrêter et supprimer aussi la base de données
```
