# ============================================================
# PinjamMobil - Docker Makefile
# ============================================================
# Usage: make <command>
# Example: make start, make stop, make logs
# ============================================================

.PHONY: help start stop restart logs build clean migrate seed backup restore shell artisan npm

# Default command
help:
	@echo "🚀 PinjamMobil Docker Commands"
	@echo "================================"
	@echo ""
	@echo "make start        - Start all containers"
	@echo "make stop         - Stop all containers"
	@echo "make restart      - Restart all containers"
	@echo "make build        - Build containers from scratch"
	@echo "make logs         - View logs (Ctrl+C to exit)"
	@echo "make logs-app     - View app logs"
	@echo "make logs-web     - View web server logs"
	@echo "make logs-queue   - View queue worker logs"
	@echo "make logs-db      - View database logs"
	@echo "make migrate      - Run database migrations"
	@echo "make seed         - Run database seeders"
	@echo "make setup        - Complete first-time setup"
	@echo "make shell        - SSH into app container"
	@echo "make db-shell     - SSH into database container"
	@echo "make artisan      - Run artisan command (make artisan CMD='key:generate')"
	@echo "make npm          - Run npm command (make npm CMD='run build')"
	@echo "make backup       - Create backup"
	@echo "make restore      - Restore from backup"
	@echo "make clean        - Remove all containers and volumes"
	@echo "make optimize     - Optimize Laravel for production"
	@echo "make test         - Run tests"
	@echo "make status       - Show container status"
	@echo ""

# Start containers
start:
	@echo "🚀 Starting PinjamMobil..."
	docker-compose up -d
	@echo "✅ Containers started!"
	@echo ""
	@echo "🌐 Application: http://localhost"
	@echo "📊 phpMyAdmin: http://localhost:8080"

# Stop containers
stop:
	@echo "🛑 Stopping PinjamMobil..."
	docker-compose down
	@echo "✅ Containers stopped!"

# Restart containers
restart: stop start

# Build containers
build:
	@echo "🔨 Building PinjamMobil containers..."
	docker-compose up -d --build
	@echo "✅ Build complete!"

# View logs
logs:
	docker-compose logs -f

logs-app:
	docker-compose logs -f app

logs-web:
	docker-compose logs -f web

logs-queue:
	docker-compose logs -f queue

logs-db:
	docker-compose logs -f db

logs-redis:
	docker-compose logs -f redis

# Complete first-time setup
setup:
	@echo "🔧 Setting up PinjamMobil..."
	@if [ ! -f .env ]; then \
		cp .env.docker .env; \
		echo "📝 Created .env from .env.docker"; \
	fi
	docker-compose up -d --build
	@echo "⏳ Waiting for services..."
	@sleep 15
	docker-compose exec -T app php artisan key:generate --force
	docker-compose exec -T app php artisan migrate --force
	docker-compose exec -T app npm install
	docker-compose exec -T app npm run build
	@echo "✅ Setup complete!"
	@echo ""
	@echo "🌐 Application: http://localhost"
	@echo "📝 Next: make seed (to add sample data)"

# Run migrations
migrate:
	@echo "🗄️  Running migrations..."
	docker-compose exec -T app php artisan migrate --force
	@echo "✅ Migrations complete!"

# Run seeders
seed:
	@echo "🌱 Running seeders..."
	docker-compose exec -T app php artisan db:seed
	@echo "✅ Database seeded!"

# SSH into app
shell:
	docker-compose exec app bash

# SSH into database
db-shell:
	docker-compose exec db bash

# Run artisan commands
artisan:
	docker-compose exec -T app php artisan $(CMD)

# Run npm commands
npm:
	docker-compose exec -T app npm $(CMD)

# Create backup
backup:
	@echo "📦 Creating backup..."
	@bash docker-backup.sh

# Restore from backup
restore:
	@echo "⚠️  Manual restore required"
	@echo "   1. List backups: ls backups/"
	@echo "   2. Restore DB: docker-compose exec -T db mysql -u user -p db < backups/backup.sql"
	@echo "   3. Restore storage: tar -xzf backups/backup_storage.tar.gz"

# Clean everything
clean:
	@echo "⚠️  This will remove ALL containers and volumes!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker-compose down -v
	@echo "✅ Cleaned!"

# Optimize for production
optimize:
	@echo "⚡ Optimizing for production..."
	docker-compose exec -T app php artisan optimize
	docker-compose exec -T app php artisan config:cache
	docker-compose exec -T app php artisan route:cache
	docker-compose exec -T app php artisan view:cache
	docker-compose exec -T app php artisan event:cache
	@echo "✅ Optimized!"

# Run tests
test:
	@echo "🧪 Running tests..."
	docker-compose exec -T app php artisan test

# Show status
status:
	@echo "📊 Container Status:"
	docker-compose ps
	@echo ""
	@echo "💾 Resource Usage:"
	docker stats --no-stream | grep pinjammobil || echo "   No containers running"
