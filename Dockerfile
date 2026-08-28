FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Mêmes paquets que le guide original
RUN apt update && apt install -y \
    vim wget curl ca-certificates apache2 \
    php php-mbstring php-snmp php-gd php-ldap php-curl php-xml php-mysql php-zip php-intl \
    tzdata locales-all graphviz locales \
    openssl apache2-utils mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Modules Apache nécessaires (rewrite, headers)
RUN a2enmod rewrite headers

# Le code source d'OpenDCIM N'EST PLUS téléchargé ici : il vit dans
# ./opendcim/ à la racine du projet, monté en volume dans docker-compose.yml
RUN mkdir -p /opt/openDCIM

# Config Apache pour le virtual host OpenDCIM
COPY apache/opendcim.conf /etc/apache2/sites-available/opendcim.conf
RUN a2dissite 000-default.conf && a2ensite opendcim.conf

# Script de démarrage : htpasswd, config DB, permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
