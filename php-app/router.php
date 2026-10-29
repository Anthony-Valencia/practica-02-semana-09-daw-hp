<?php
// Router del servidor embebido: php -S 0.0.0.0:8000 -t php-app php-app/router.php
declare(strict_types=1);
require_once __DIR__ . '/lib.php';

$ruta = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';

if (in_array(basename($ruta), ['lib.php', 'router.php'], true)) {
    error_http(403, 'Acceso prohibido.');
}
if ($ruta === '/' || is_file(__DIR__ . $ruta)) {
    return false; // lo sirve el servidor embebido
}
error_http(404, 'Recurso no encontrado.');
