#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage : ./restore.sh nom_du_fichier.sql"
    echo ""
    echo "Sauvegardes disponibles :"
    ls -1 *.sql 2>/dev/null || echo "  (aucune trouvée)"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Erreur : fichier introuvable : $1"
    exit 1
fi

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

DB_ROOT_PASS="${DB_ROOT_PASS:-rootpass}"
DB_NAME="${DB_NAME:-dcim}"

echo "Restauration de ${DB_NAME} depuis $1..."
docker compose exec -T mariadb mariadb -u root -p"${DB_ROOT_PASS}" "${DB_NAME}" < "$1"

echo "Restauration terminée."
