#!/bin/bash
# ============================================================
# PinjamMobil - Quick Start Script for Docker
# ============================================================
# This script provides a quick way to start the Docker environment
# Run: ./docker-start.sh
# ============================================================

set -e

echo "🚀 PinjamMobil Docker Quick Start"
echo "=================================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env from .env.docker..."
    cp .env.docker .env
    echo "⚠️  Using default passwords. Change them in .env for production!"
fi

# Check if containers are already running
if docker-compose ps | grep -q "Up"; then
    echo "⚠️  Containers are already running."
    read -p "Do you want to restart them? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Restarting containers..."
        docker-compose restart
    else
        echo "👋 Exiting..."
        exit 0
    fi
else
    echo "🔨 Starting Docker containers..."
    docker-compose up -d
fi

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 15

# Check if services are ready
echo "🔍 Checking services..."
docker-compose ps

echo ""
echo "=================================="
echo "✅ PinjamMobil is ready!"
echo "=================================="
echo ""
echo "🌐 Application: http://localhost"
echo "📊 phpMyAdmin: http://localhost:8080"
echo ""
echo "📝 Useful commands:"
echo "   View logs:         docker-compose logs -f"
echo "   SSH into app:      docker-compose exec app bash"
echo "   Run artisan:       docker-compose exec app php artisan <command>"
echo "   Stop containers:   docker-compose down"
echo "   Rebuild:           docker-compose up -d --build"
echo ""
echo "📖 Full documentation: README.Docker.md"
echo ""
