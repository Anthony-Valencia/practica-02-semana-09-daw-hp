<?php
declare(strict_types=1);

/** Escapa salida HTML (prevención XSS). */
function e(string $texto): string
{
    return htmlspecialchars($texto, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/** Inicia la sesión con cookie endurecida. */
function iniciar_sesion(): void
{
    if (session_status() === PHP_SESSION_NONE) {
        session_set_cookie_params(['httponly' => true, 'samesite' => 'Lax']);
        session_start();
    }
}

/** Imprime una página HTML completa con el código HTTP indicado. $contenido es HTML ya escapado. */
function pagina(int $codigo, string $titulo, string $contenido): void
{
    http_response_code($codigo);
    header('Content-Type: text/html; charset=UTF-8');
    echo '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">'
        . '<meta name="viewport" content="width=device-width, initial-scale=1">'
        . '<title>' . e($titulo) . '</title><link rel="stylesheet" href="/style.css"></head>'
        . '<body><main class="card"><h2>' . e($titulo) . '</h2>' . $contenido . '</main></body></html>';
}

/** Respuesta de error 4xx/5xx y termina la ejecución. */
function error_http(int $codigo, string $mensaje): void
{
    pagina(
        $codigo,
        "Error $codigo",
        '<p class="error">' . e($mensaje) . '</p><p><a href="/index.html">Volver al formulario</a></p>'
    );
    exit;
}
