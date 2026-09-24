#!/bin/bash

set -e

echo "=== CITA WordPress runtime ==="
echo "PHP:"
php -v | head -1

echo "Apache:"
httpd -v | head -1

mkdir -p \
    /run/php-fpm \
    /var/lib/php/session \
    /var/lib/php/wsdlcache

chown apache:apache \
    /var/lib/php/session \
    /var/lib/php/wsdlcache

echo "Starting PHP-FPM..."
php-fpm --nodaemonize &

PHP_PID=$!

echo "Starting Apache..."
httpd -DFOREGROUND &

HTTPD_PID=$!

term_handler()
{
    echo "Stopping Apache and PHP-FPM..."

    kill -TERM "$HTTPD_PID" 2>/dev/null || true
    kill -TERM "$PHP_PID" 2>/dev/null || true

    wait "$HTTPD_PID" 2>/dev/null || true
    wait "$PHP_PID" 2>/dev/null || true

    exit 0
}

trap term_handler TERM INT

while kill -0 "$HTTPD_PID" 2>/dev/null &&
      kill -0 "$PHP_PID" 2>/dev/null
do
    sleep 2
done

echo "Apache or PHP-FPM exited unexpectedly."

kill -TERM "$HTTPD_PID" 2>/dev/null || true
kill -TERM "$PHP_PID" 2>/dev/null || true

wait || true

exit 1
