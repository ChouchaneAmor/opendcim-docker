#!/bin/bash
set -e

VERSION="23.04"

if [ -d "opendcim" ] && [ "$(ls -A opendcim 2>/dev/null)" ]; then
    echo "Le dossier ./opendcim/ existe déjà et n'est pas vide — rien à télécharger."
    echo "Pour forcer un nouveau téléchargement, supprime d'abord le dossier ./opendcim/"
    exit 0
fi

echo "Téléchargement d'OpenDCIM ${VERSION}..."
mkdir -p opendcim
wget -O /tmp/opendcim.tar.gz "https://github.com/opendcim/openDCIM/archive/refs/tags/${VERSION}.tar.gz"
tar -zxpf /tmp/opendcim.tar.gz --strip-components=1 -C opendcim
rm /tmp/opendcim.tar.gz

mkdir -p opendcim/assets/pictures opendcim/assets/drawings
cp opendcim/db.inc.php-dist opendcim/db.inc.php

echo "OpenDCIM ${VERSION} est maintenant dans ./opendcim/"
echo "Tu peux lancer : docker compose up -d --build"
