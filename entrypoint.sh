#!/bin/bash
set -e

DCIM_USER="${DCIM_HTTP_USER:-dcim}"
DCIM_PASS="${DCIM_HTTP_PASS:-dcim}"
DB_HOST="${DB_HOST:-mariadb}"
DB_NAME="${DB_NAME:-dcim}"
DB_USER="${DB_USER:-dcim}"
DB_PASS="${DB_PASS:-dcim}"

# 0. Vérifie que le code source a bien été monté (via setup.sh + docker-compose)
if [ ! -f /opt/openDCIM/opendcim/index.php ]; then
    echo "ERREUR : le code source d'OpenDCIM est introuvable dans /opt/openDCIM/opendcim"
    echo "As-tu lancé ./setup.sh sur ta machine hôte avant de démarrer le conteneur ?"
    exit 1
fi

# 1. htpasswd pour l'authentification Apache, comme dans le guide
if [ ! -f /opt/openDCIM/opendcim/.htpasswd ]; then
    echo "Création de l'utilisateur Apache '$DCIM_USER'..."
    htpasswd -cb /opt/openDCIM/opendcim/.htpasswd "$DCIM_USER" "$DCIM_PASS"
fi

# 2. Attente que MariaDB soit prête
echo "Attente de la base de données ($DB_HOST)..."
until mysqladmin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" --silent; do
    sleep 2
done

# 3. Configuration de db.inc.php avec les identifiants du conteneur (une seule fois)
if ! grep -q "$DB_HOST" /opt/openDCIM/opendcim/db.inc.php 2>/dev/null; then
    sed -i "s/localhost/${DB_HOST}/" /opt/openDCIM/opendcim/db.inc.php
    sed -i "s/'dcim'/'${DB_USER}'/1" /opt/openDCIM/opendcim/db.inc.php
    sed -i "0,/dcimpassword/s//${DB_PASS}/" /opt/openDCIM/opendcim/db.inc.php
fi

# 4. Permissions (équivalent du chown www-data:www-data du guide)
mkdir -p /opt/openDCIM/opendcim/assets/pictures /opt/openDCIM/opendcim/assets/drawings
chown -R www-data:www-data /opt/openDCIM/opendcim

# 5. Démarrage d'Apache au premier plan (nécessaire pour Docker)
echo "Démarrage d'Apache..."
exec apache2ctl -D FOREGROUND
