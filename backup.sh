#!/bin/bash
set -e

# Charge les identifiants depuis .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

DB_ROOT_PASS="${DB_ROOT_PASS:-rootpass}"
DB_NAME="${DB_NAME:-dcim}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="dcim_${TIMESTAMP}.sql"

echo "Sauvegarde de la base '${DB_NAME}' en cours..."
docker compose exec -T mariadb mariadb-dump -u root -p"${DB_ROOT_PASS}" "${DB_NAME}" > "${BACKUP_FILE}"

echo "Sauvegarde terminée : ${BACKUP_FILE}"
echo "Taille : $(du -h "${BACKUP_FILE}" | cut -f1)"
