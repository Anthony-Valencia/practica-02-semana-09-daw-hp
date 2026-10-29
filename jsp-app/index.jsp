<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Lab 09 | Registro JSP</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <main class="card">
    <h2>Formulario de Contacto (JSP)</h2>
    <form action="procesar.jsp" method="POST">
      <label for="nombre">Nombre</label>
      <input id="nombre" type="text" name="nombre" required minlength="2" maxlength="60" autocomplete="name">
      <label for="correo">Correo</label>
      <input id="correo" type="email" name="correo" required maxlength="100" autocomplete="email">
      <button type="submit">Enviar</button>
    </form>
  </main>
</body>
</html>
