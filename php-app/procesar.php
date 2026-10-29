<?php
declare(strict_types=1);
require __DIR__ . '/lib.php';

const MAX_REGISTROS = 50;

try {
    // 1) Solo se acepta POST
    if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
        header('Allow: POST');
        error_http(405, 'Método no permitido. Usa el formulario (POST).');
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

    // 4) Guardar en $_SESSION (se escapa al imprimir)
    iniciar_sesion();
    $_SESSION['registros'][] = ['nombre' => $nombre, 'correo' => $correo];
    if (count($_SESSION['registros']) > MAX_REGISTROS) {
        array_shift($_SESSION['registros']);
    }

    // 5) Respuesta: tabla de registros
    $filas = '';
    foreach ($_SESSION['registros'] as $i => $r) {
        $filas .= '<tr><td>' . ($i + 1) . '</td><td>' . e($r['nombre']) . '</td><td>' . e($r['correo']) . '</td></tr>';
    }
    pagina(
        200,
        'Registros almacenados',
        '<p class="ok">Registro guardado correctamente.</p>'
        . "<table border='1'><tr><th>#</th><th>Nombre</th><th>Correo</th></tr>$filas</table>"
        . '<p><a href="/index.html">Registrar otro contacto</a></p>'
    );
} catch (Throwable $ex) {
    error_log('[procesar.php] ' . $ex->getMessage());
    error_http(500, 'Error interno del servidor.');
}
