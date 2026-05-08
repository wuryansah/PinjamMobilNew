#!/bin/bash
# ============================================================
# PinjamMobil - Production Deployment Script
# ============================================================
# This script automates the production deployment process
# Run: ./docker-deploy.sh
# ============================================================

set -e

echo "🚀 PinjamMobil Production Deployment"
echo "====================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    exit 1
fi

echo "✅ Docker found: $(docker --version)"
echo "✅ Docker Compose found: $(docker-compose --version)"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.docker..."
    cp .env.docker .env
    echo "📝 Please edit .env file with your production settings:"
    echo "   - Database passwords"
    echo "   - Redis password"
    echo "   - Mail configuration"
    echo "   - APP_URL"
    echo ""
    read -p "Press Enter after you've configured .env..."
fi

# Build and start containers
echo "🔨 Building Docker images..."
docker-compose up -d --build

echo ""
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are healthy
echo "🔍 Checking service health..."
docker-compose ps

echo ""
echo "🔑 Generating application key..."
docker-compose exec -T app php artisan key:generate --force

echo ""
echo "🗄️  Running database migrations..."
docker-compose exec -T app php artisan migrate --force

echo ""
echo "📦 Installing Node.js dependencies..."
docker-compose exec -T app npm install

echo ""
echo "🎨 Building frontend assets..."
docker-compose exec -T app npm run build

echo ""
echo "⚡ Optimizing Laravel for production..."
docker-compose exec -T app php artisan config:cache
docker-compose exec -T app php artisan route:cache
docker-compose exec -T app php artisan view:cache
docker-compose exec -T app php artisan optimize

echo ""
echo "🔒 Setting permissions..."
docker-compose exec -T app chmod -R 775 storage bootstrap/cache
docker-compose exec -T app chown -R www-data:www-data storage bootstrap/cache

echo ""
echo "====================================="
echo "✅ Deployment Complete!"
echo "====================================="
echo ""
echo "🌐 Application URL: http://localhost"
echo "📊 phpMyAdmin: http://localhost:8080"
echo ""
echo "📝 Next steps:"
echo "   1. Run database seeder: docker-compose exec app php artisan db:seed"
echo "   2. Create admin user manually or via seeder"
echo "   3. Configure mail settings in .env"
echo "   4. Set up SSL certificates for HTTPS"
echo ""
echo "📖 See README.Docker.md for more information"
echo ""
