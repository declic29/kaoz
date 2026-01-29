# === Étape 1 : Base PHP officielle avec extensions nécessaires ===
FROM php:8.3-fpm

# Variables d'environnement pour éviter les prompts
ENV DEBIAN_FRONTEND=noninteractive

# Mise à jour et installation des paquets système
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libicu-dev \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libvips-dev \
    pkg-config \
    libffi-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Extensions PHP requises
RUN docker-php-ext-install bcmath intl pcntl ffi opcache zip gd

# === Étape 2 : Composer ===
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# === Étape 3 : Copier le projet ===
WORKDIR /var/www/html
COPY . .

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader

# Générer la clé de l'application si elle n’existe pas
RUN php artisan key:generate --ansi

# Permissions (optionnel mais conseillé)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Exposer le port pour le serveur PHP-FPM
EXPOSE 9000

# Commande par défaut
CMD ["php-fpm"]
