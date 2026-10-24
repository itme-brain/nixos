FROM node:24.22.1-bookworm-slim@sha256:55fb5f5a527ea2c5c4a95f963e48ef90aa38c7b346054fdc8ee9957a2b55d205 AS assets
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --ignore-scripts
COPY app/ ./
COPY dark-mode.patch /tmp/dark-mode.patch
RUN apt-get update && apt-get install -y --no-install-recommends patch \
    && patch -p1 < /tmp/dark-mode.patch \
    && rm -rf /var/lib/apt/lists/*
ENV ASSET_URL=https://ai.ramos.codes/systemone
RUN npm run build

FROM php:8.4.27-apache-trixie@sha256:a0b75cee7023ba2c127138dcad2ecc6ec7e09435534645e70450f29f24ea2a5a
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip patch libzip-dev libicu-dev libonig-dev libsqlite3-dev libbrotli1=1.1.0-2+deb13u1 \
    && docker-php-ext-install pdo_sqlite mbstring intl zip pcntl bcmath \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2@sha256:af98f42dfff7c68ba8d53c2164fd9fde1087b7d449514baa38c418b1f6bc4bac /usr/bin/composer /usr/local/bin/composer
WORKDIR /app
COPY app/ ./
COPY web-hosting.patch /tmp/web-hosting.patch
COPY dark-mode.patch /tmp/dark-mode.patch
RUN patch -p1 < /tmp/web-hosting.patch && patch -p1 < /tmp/dark-mode.patch
COPY systemone.php config/systemone.php
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader \
    && chown -R www-data:www-data storage bootstrap/cache
COPY --from=assets /app/public/build public/build
RUN printf '%s\n' '<VirtualHost *:80>' 'DocumentRoot /app/public' \
    '<Directory /app/public>' 'AllowOverride All' 'Require all granted' \
    '</Directory>' '</VirtualHost>' > /etc/apache2/sites-available/000-default.conf \
    && printf '%s\n' 'upload_max_filesize=24M' 'post_max_size=32M' \
    > /usr/local/etc/php/conf.d/uploads.ini
RUN sed -i 's/Listen 80/Listen 127.0.0.1:3090/' /etc/apache2/ports.conf \
    && sed -i 's/\*:80/127.0.0.1:3090/' /etc/apache2/sites-available/000-default.conf
