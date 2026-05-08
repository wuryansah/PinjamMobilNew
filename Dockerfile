# ============================================================
# Stage 1: Build assets with Node.js
# ============================================================
FROM node:20-alpine AS node-builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY vite.config.js ./

# Install Node.js dependencies
RUN npm ci

# Copy frontend source code
COPY resources/ ./resources/

# Build frontend assets
RUN npm run build

# ============================================================
# Stage 2: PHP production environment
# ============================================================
FROM php:8.2-fpm-alpine AS production

# Add persistent dependencies
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    libzip-dev \
    zlib-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    curl-dev \
    git \
    unzip \
    zip \
    libpq-dev \
    bash \
    supervisor \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        zip \
        intl \
        mbstring \
        exif \
        pcntl \
        bcmath \
        opcache \
    && apk del --purge \
        libpng-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        freetype-dev \
        libzip-dev \
        zlib-dev \
        icu-dev \
        oniguruma-dev \
        libxml2-dev \
        curl-dev

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application code
COPY . .

# Remove development files
RUN rm -rf \
    node_modules \
    .git \
    .github \
    .vscode \
    tests \
    phpunit.xml \
    .editorconfig \
    postcss.config.js \
    tailwind.config.js

# Copy built assets from node-builder
COPY --from=node-builder /app/public/build/ ./public/build/

# Install PHP dependencies (production only)
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    && composer clear-cache

# Create necessary directories
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Configure PHP for production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && { \
        echo 'upload_max_filesize=10M'; \
        echo 'post_max_size=10M'; \
        echo 'memory_limit=256M'; \
        echo 'max_execution_time=300'; \
        echo 'max_input_vars=3000'; \
        echo 'realpath_cache_size=4096K'; \
        echo 'realpath_cache_ttl=600'; \
        echo 'opcache.enable=1'; \
        echo 'opcache.memory_consumption=256'; \
        echo 'opcache.interned_strings_buffer=16'; \
        echo 'opcache.max_accelerated_files=20000'; \
        echo 'opcache.validate_timestamps=0'; \
        echo 'opcache.fast_shutdown=1'; \
    } >> "$PHP_INI_DIR/conf.d/docker-php-prod.ini"

# Copy supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/laravel-worker.conf

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose PHP-FPM port
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost:9000/ || exit 1

# Use entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start PHP-FPM
CMD ["php-fpm"]
