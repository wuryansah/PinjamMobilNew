#!/bin/bash
# ============================================================
# PinjamMobil - Backup Script
# ============================================================
# Creates a complete backup of the application
# Run: ./docker-backup.sh
# ============================================================

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="pinjammobil_backup_${TIMESTAMP}"

echo "📦 PinjamMobil Backup Script"
echo "============================"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Containers are not running. Please start them first."
    exit 1
fi

echo "🗄️  Backing up MySQL database..."
docker-compose exec -T db mysqldump -u root -p"${DB_ROOT_PASSWORD:-root}" \
    pinjammobil > "${BACKUP_DIR}/${BACKUP_NAME}_database.sql" 2>/dev/null || {
    echo "⚠️  Trying with environment variables..."
    docker-compose exec -T db mysqldump -u "${DB_USERNAME:-pinjammobil}" \
        -p"${DB_PASSWORD:-secret}" pinjammobil > "${BACKUP_DIR}/${BACKUP_NAME}_database.sql"
}

echo "📁 Backing up storage files..."
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}_storage.tar.gz" storage/ 2>/dev/null || {
    echo "⚠️  Storage backup skipped or incomplete"
}

echo "📄 Backing up .env file..."
cp .env "${BACKUP_DIR}/${BACKUP_NAME}_env.txt" 2>/dev/null || {
    echo "⚠️  .env file not found"
}

# Create backup manifest
cat > "${BACKUP_DIR}/${BACKUP_NAME}_manifest.txt" << EOF
PinjamMobil Backup
==================
Date: $(date)
Timestamp: ${TIMESTAMP}
Database: ${BACKUP_NAME}_database.sql
Storage: ${BACKUP_NAME}_storage.tar.gz
Env: ${BACKUP_NAME}_env.txt

To restore:
1. docker-compose exec -T db mysql -u user -p database < ${BACKUP_NAME}_database.sql
2. tar -xzf ${BACKUP_NAME}_storage.tar.gz
3. cp ${BACKUP_NAME}_env.txt .env
EOF

echo ""
echo "============================"
echo "✅ Backup complete!"
echo "============================"
echo ""
echo "📦 Backup files:"
ls -lh "${BACKUP_DIR}/${BACKUP_NAME}"* 2>/dev/null || echo "   (Check ${BACKUP_DIR} folder)"
echo ""
echo "💾 Total size:"
du -sh "${BACKUP_DIR}/${BACKUP_NAME}"* 2>/dev/null | tail -1 || echo "   N/A"
echo ""
