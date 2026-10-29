<?php
// Router para el servidor embebido de PHP: php -S 0.0.0.0:8000 -t php-app php-app/router.php
declare(strict_types=1);
require __DIR__ . '/lib.php';

$ruta = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$archivo = basename($ruta);

if (in_array($archivo, ['lib.php', 'router.php'], true)) {
    error_http(403, 'Acceso prohibido.');
}
if ($ruta === '/' || is_file(__DIR__ . $ruta)) {
    return false; // lo sirve el servidor embebido
}
error_http(404, 'Recurso no encontrado.');
