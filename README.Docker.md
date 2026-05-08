# Production Docker Setup for PinjamMobil

## Quick Start

### 1. First-time Setup

```bash
# Copy environment file
cp .env.docker .env

# Build and start containers
docker-compose up -d --build

# Install dependencies and setup application
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan migrate --force
docker-compose exec app npm install
docker-compose exec app npm run build
```

### 2. Access the Application

- **Application:** http://localhost
- **phpMyAdmin:** http://localhost:8080

### 3. Default Admin Credentials

After running the seeder:
```bash
docker-compose exec app php artisan db:seed
```

- **Email:** admin@pinjammobil.com
- **Password:** password

## Production Deployment

### 1. Update Environment Variables

Edit `.env.docker` with your production settings:
- Database passwords
- Application URL
- Mail configuration
- Redis configuration

### 2. Build Production Images

```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

### 3. Run Migrations

```bash
docker-compose -f docker-compose.prod.yml exec app php artisan migrate --force
```

### 4. Build Assets

```bash
docker-compose -f docker-compose.prod.yml exec app npm run build
```

## Docker Services

| Service | Description | Port |
|---------|-------------|------|
| app | Laravel application (PHP-FPM) | 9000 |
| web | Nginx web server | 80, 443 |
| db | MySQL 8.0 database | 3306 |
| redis | Redis cache/session | 6379 |
| queue | Laravel queue worker | - |
| scheduler | Laravel task scheduler | - |
| phpmyadmin | Database management | 8080 |

## Common Commands

```bash
# Start all containers
docker-compose up -d

# Stop all containers
docker-compose down

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f app
docker-compose logs -f web
docker-compose logs -f queue

# SSH into app container
docker-compose exec app bash

# Run artisan commands
docker-compose exec app php artisan <command>

# Run npm commands
docker-compose exec app npm <command>

# Clear caches
docker-compose exec app php artisan optimize:clear

# Restart specific service
docker-compose restart app

# Rebuild containers
docker-compose up -d --build

# Remove all containers and volumes (WARNING: deletes data)
docker-compose down -v
```

## Volumes

- `mysql_data` - Persistent MySQL data
- `redis_data` - Persistent Redis data
- `./storage` - Laravel storage (mounted for logs/uploads)
- `./public` - Public assets (mounted for builds)

## Security Notes

1. **Never commit `.env` files** - They contain sensitive credentials
2. **Change default passwords** in production
3. **Use HTTPS** in production with SSL certificates
4. **Backup MySQL regularly** - Use `docker-compose exec db mysqldump`
5. **Keep images updated** - Run `docker-compose pull` periodically

## Backup & Restore

### Backup MySQL
```bash
docker-compose exec db mysqldump -u pinjammobil -p<password> pinjammobil > backup.sql
```

### Restore MySQL
```bash
docker-compose exec -T db mysql -u pinjammobil -p<password> pinjammobil < backup.sql
```

### Backup Storage
```bash
tar -czf storage-backup.tar.gz storage/
```

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs <service>

# Rebuild without cache
docker-compose build --no-cache
```

### Database connection issues
```bash
# Check if MySQL is running
docker-compose ps

# Wait for MySQL to be ready (can take 30-60 seconds on first start)
docker-compose logs -f db
```

### Permission issues
```bash
# Fix storage permissions
docker-compose exec app chmod -R 775 storage bootstrap/cache
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
```

## Performance Optimization

### Enable OPcache
Already configured in `php.ini` for production.

### Use Redis for cache/sessions
Set in `.env.docker`:
```env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

### Optimize Laravel
```bash
docker-compose exec app php artisan optimize
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache
```

## Environment Variables

See `.env.docker` for all available configuration options.

### Required Variables
- `APP_NAME` - Application name
- `APP_URL` - Application URL
- `DB_PASSWORD` - MySQL password
- `REDIS_PASSWORD` - Redis password

### Mail Configuration (Optional)
- `MAIL_MAILER` - smtp, mailgun, ses, etc.
- `MAIL_HOST` - SMTP host
- `MAIL_PORT` - SMTP port
- `MAIL_USERNAME` - SMTP username
- `MAIL_PASSWORD` - SMTP password

## Updating

1. Pull latest code
2. Update containers: `docker-compose up -d --build`
3. Run migrations: `docker-compose exec app php artisan migrate --force`
4. Build assets: `docker-compose exec app npm run build`
5. Optimize: `docker-compose exec app php artisan optimize`

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Review this documentation
3. Check Laravel logs: `storage/logs/laravel.log`
4. Check Nginx error logs: `docker-compose logs -f web`
