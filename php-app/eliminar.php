<?php
declare(strict_types=1);
require_once __DIR__ . '/lib.php';

try {
    solo_post();
    if (!csrf_valido()) {
        error_http(403, 'Token CSRF inválido o ausente. Recarga la página.');
    }
    iniciar_sesion();

    $todos = filter_input(INPUT_POST, 'todos', FILTER_UNSAFE_RAW) === '1';
    $id = filter_input(INPUT_POST, 'id', FILTER_UNSAFE_RAW);

    if ($todos) {
        $_SESSION['registros'] = [];
        flash_set('Registros eliminados.');
    } elseif (is_string($id) && $id !== '') {
        $_SESSION['registros'] = array_values(array_filter(
            $_SESSION['registros'] ?? [],
            static fn(array $r): bool => $r['id'] !== $id
        ));
        flash_set('Registro eliminado.');
    } else {
        error_http(422, 'Falta el identificador del registro.');
    }
    redirigir('/registros.php');
} catch (Throwable $ex) {
    error_log('[eliminar.php] ' . $ex->getMessage());
    error_http(500, 'Error interno del servidor.');
}
