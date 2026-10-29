<?php
declare(strict_types=1);

const MAX_REGISTROS = 50;

/** Escapa salida HTML (prevención XSS). */
function e(string $texto): string
{
    return htmlspecialchars($texto, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/** Cabeceras de seguridad HTTP. */
function cabeceras_seguridad(): void
{
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: no-referrer');
    header("Content-Security-Policy: default-src 'self'; style-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'none'");
}

/** Inicia la sesión con cookie endurecida. */
function iniciar_sesion(): void
{
    cabeceras_seguridad();
    if (session_status() === PHP_SESSION_NONE) {
        session_set_cookie_params(['httponly' => true, 'samesite' => 'Lax']);
        session_start();
    }
}

/** Token CSRF de la sesión (se crea si no existe). */
function csrf_token(): string
{
    iniciar_sesion();
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

/** Valida el token CSRF recibido por POST. */
function csrf_valido(): bool
{
    iniciar_sesion();
    $enviado = filter_input(INPUT_POST, 'csrf', FILTER_UNSAFE_RAW);
    $real = $_SESSION['csrf'] ?? '';
    return is_string($enviado) && $real !== '' && hash_equals($real, $enviado);
}

function flash_set(string $mensaje): void
{
    iniciar_sesion();
    $_SESSION['flash'] = $mensaje;
}

function flash_get(): ?string
{
    iniciar_sesion();
    $m = $_SESSION['flash'] ?? null;
    unset($_SESSION['flash']);
    return is_string($m) ? $m : null;
}

/** Exige método POST (si no, 405). */
function solo_post(): void
{
    if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
        header('Allow: POST');
        error_http(405, 'Método no permitido. Usa el formulario (POST).');
    }
}

/** Patrón Post/Redirect/Get: 303 See Other. */
function redirigir(string $ruta): void
{
    header('Location: ' . $ruta, true, 303);
    exit;
}

/** Imprime una página HTML completa. $contenido es HTML ya escapado. */
function pagina(int $codigo, string $titulo, string $contenido): void
{
    cabeceras_seguridad();
    http_response_code($codigo);
    header('Content-Type: text/html; charset=UTF-8');
    echo '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">'
        . '<meta name="viewport" content="width=device-width, initial-scale=1">'
        . '<title>' . e($titulo) . ' | Lab 09 PHP</title><link rel="stylesheet" href="/style.css"></head>'
        . '<body><nav class="nav"><a href="/index.php">Inicio</a><a href="/registros.php">Registros</a></nav>'
        . '<main class="card"><h2>' . e($titulo) . '</h2>' . $contenido . '</main></body></html>';
}

/** Respuesta de error 4xx/5xx y termina la ejecución. */
function error_http(int $codigo, string $mensaje): void
{
    pagina(
        $codigo,
        "Error $codigo",
        '<p class="error">' . e($mensaje) . '</p><p><a href="/index.php">Volver al formulario</a></p>'
    );
    exit;
}
