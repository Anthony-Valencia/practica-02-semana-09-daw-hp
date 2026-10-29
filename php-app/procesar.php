<?php
declare(strict_types=1);
require_once __DIR__ . '/lib.php';

try {
    // 1) Solo POST + token CSRF
    solo_post();
    if (!csrf_valido()) {
        error_http(403, 'Token CSRF inválido o ausente. Recarga el formulario.');
    }

    // 2) Obtener y sanitizar entradas
    $rawNombre = filter_input(INPUT_POST, 'nombre', FILTER_UNSAFE_RAW);
    $rawCorreo = filter_input(INPUT_POST, 'correo', FILTER_UNSAFE_RAW);
    $nombre = is_string($rawNombre) ? trim(preg_replace('/[\x00-\x1F\x7F]/u', '', $rawNombre) ?? '') : '';
    $correo = is_string($rawCorreo) ? trim($rawCorreo) : '';

    // 3) Validar
    $errores = [];
    if (mb_strlen($nombre) < 2 || mb_strlen($nombre) > 60
        || !preg_match("/^[\p{L}\p{M} .'-]+$/u", $nombre)) {
        $errores[] = 'Nombre inválido (2-60 caracteres: letras, espacios, punto, apóstrofe o guion).';
    }
    if (strlen($correo) > 100 || filter_var($correo, FILTER_VALIDATE_EMAIL) === false) {
        $errores[] = 'Correo electrónico inválido.';
    }
    if ($errores) {
        error_http(422, implode(' ', $errores));
    }

    // 4) Evitar correos duplicados (409 Conflict)
    iniciar_sesion();
    foreach ($_SESSION['registros'] ?? [] as $r) {
        if (strcasecmp($r['correo'], $correo) === 0) {
            error_http(409, 'Ese correo ya está registrado.');
        }
    }

    // 5) Guardar en $_SESSION (se escapa al imprimir)
    $_SESSION['registros'][] = [
        'id' => bin2hex(random_bytes(4)),
        'nombre' => $nombre,
        'correo' => $correo,
    ];
    if (count($_SESSION['registros']) > MAX_REGISTROS) {
        array_shift($_SESSION['registros']);
    }

    // 6) Post/Redirect/Get: evita reenvío al refrescar
    flash_set('Registro guardado correctamente.');
    redirigir('/registros.php');
} catch (Throwable $ex) {
    error_log('[procesar.php] ' . $ex->getMessage());
    error_http(500, 'Error interno del servidor.');
}
