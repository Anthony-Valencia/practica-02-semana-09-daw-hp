<?php
declare(strict_types=1);
require_once __DIR__ . '/lib.php';

$token = csrf_token();
$registros = $_SESSION['registros'] ?? [];
$msg = flash_get();
$aviso = $msg !== null ? '<p class="ok">' . e($msg) . '</p>' : '';

if (!$registros) {
    $cuerpo = '<p class="muted">Aún no hay registros.</p>';
} else {
    $filas = '';
    foreach ($registros as $i => $r) {
        $filas .= '<tr><td>' . ($i + 1) . '</td><td>' . e($r['nombre']) . '</td><td>' . e($r['correo']) . '</td><td>'
            . '<form class="inline" action="/eliminar.php" method="POST">'
            . '<input type="hidden" name="csrf" value="' . e($token) . '">'
            . '<input type="hidden" name="id" value="' . e($r['id']) . '">'
            . '<button class="peligro" type="submit">Eliminar</button></form></td></tr>';
    }
    $cuerpo = "<div class='tabla'><table border='1'><tr><th>#</th><th>Nombre</th><th>Correo</th><th>Acción</th></tr>$filas</table></div>"
        . '<form action="/eliminar.php" method="POST">'
        . '<input type="hidden" name="csrf" value="' . e($token) . '">'
        . '<input type="hidden" name="todos" value="1">'
        . '<button class="peligro" type="submit">Eliminar todos</button></form>';
}

pagina(200, 'Registros almacenados', $aviso . $cuerpo . '<p><a href="/index.php">Registrar otro contacto</a></p>');
