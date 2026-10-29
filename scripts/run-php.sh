#!/usr/bin/env bash
# Servidor PHP en http://localhost:8000  (logs en logs/php-server.log)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/logs"
echo "PHP en http://localhost:8000  (Ctrl+C para detener)"
php -S 0.0.0.0:8000 -t "$ROOT/php-app" "$ROOT/php-app/router.php" 2>&1 | tee -a "$ROOT/logs/php-server.log"
