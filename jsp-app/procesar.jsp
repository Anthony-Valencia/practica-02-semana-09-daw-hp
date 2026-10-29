<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.*, java.util.regex.Pattern" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%!
  private static final Pattern NOMBRE = Pattern.compile("^[\\p{L}\\p{M} .'-]{2,60}$");
  private static final Pattern CORREO = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
  private static final int MAX_REGISTROS = 50;
%>
<%
  // 1) Solo POST
  if (!"POST".equals(request.getMethod())) {
    response.setHeader("Allow", "POST");
    response.sendError(405, "Método no permitido. Usa el formulario (POST).");
    return;
  }

  // 2) Obtener y sanitizar parámetros
  request.setCharacterEncoding("UTF-8");
  String nombre = request.getParameter("nombre");
  String correo = request.getParameter("correo");
  nombre = (nombre == null) ? "" : nombre.replaceAll("\\p{Cntrl}", "").trim();
  correo = (correo == null) ? "" : correo.trim();

  // 3) Validar
  List<String> errores = new ArrayList<>();
  if (!NOMBRE.matcher(nombre).matches()) {
    errores.add("Nombre inválido (2-60 caracteres: letras, espacios, punto, apóstrofe o guion).");
  }
  if (correo.length() > 100 || !CORREO.matcher(correo).matches()) {
    errores.add("Correo electrónico inválido.");
  }
  if (!errores.isEmpty()) {
    response.sendError(422, String.join(" ", errores));
    return;
  }

  // 4) Guardar en sesión
  HttpSession sesion = request.getSession();
  synchronized (sesion) {
    @SuppressWarnings("unchecked")
    List<Map<String, String>> registros = (List<Map<String, String>>) sesion.getAttribute("registros");
    if (registros == null) registros = new ArrayList<>();
    registros.add(Map.of("nombre", nombre, "correo", correo));
    if (registros.size() > MAX_REGISTROS) registros.remove(0);
    sesion.setAttribute("registros", registros);
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Resultado</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <main class="card">
    <h2>Registros almacenados</h2>
    <p class="ok">Registro guardado correctamente.</p>
    <table border="1">
      <tr><th>#</th><th>Nombre</th><th>Correo</th></tr>
      <c:forEach var="r" items="${sessionScope.registros}" varStatus="st">
        <tr>
          <td>${st.count}</td>
          <td><c:out value="${r.nombre}"/></td>
          <td><c:out value="${r.correo}"/></td>
        </tr>
      </c:forEach>
    </table>
    <p><a href="index.jsp">Registrar otro contacto</a></p>
  </main>
</body>
</html>
