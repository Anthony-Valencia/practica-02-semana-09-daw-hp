<?php
declare(strict_types=1);
require_once __DIR__ . '/lib.php';

$token = csrf_token();
$msg = flash_get();
$aviso = $msg !== null ? '<p class="ok">' . e($msg) . '</p>' : '';
$total = count($_SESSION['registros'] ?? []);

$form = <<<HTML
<form action="/procesar.php" method="POST">
  <input type="hidden" name="csrf" value="{$token}">
  <label for="nombre">Nombre</label>
  <input id="nombre" type="text" name="nombre" required minlength="2" maxlength="60" autocomplete="name">
  <label for="correo">Correo</label>
  <input id="correo" type="email" name="correo" required maxlength="100" autocomplete="email">
  <button type="submit">Enviar</button>
</form>
<p class="muted">Registros en esta sesión: {$total}. <a href="/registros.php">Ver registros</a></p>
HTML;

pagina(200, 'Formulario de Contacto (PHP)', $aviso . $form);
