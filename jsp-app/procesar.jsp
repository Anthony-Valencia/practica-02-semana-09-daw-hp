<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"
         import="java.util.regex.Pattern" %>
<%@ include file="/WEB-INF/jspf/comun.jspf" %>
<%!
  private static final Pattern NOMBRE = Pattern.compile("^[\\p{L}\\p{M} .'-]{2,60}$");
  private static final Pattern CORREO = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
%>
<%
  // 1) Solo POST + token CSRF
  if (!"POST".equals(request.getMethod())) {
    response.setHeader("Allow", "POST");
    response.sendError(405, "Método no permitido. Usa el formulario (POST).");
    return;
  }
  request.setCharacterEncoding("UTF-8");
  if (!csrfValido(request, session)) {
    response.sendError(403, "Token CSRF inválido o ausente. Recarga el formulario.");
    return;
  }

  // 2) Obtener y sanitizar parámetros
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

  // 4) Guardar en sesión (evitando duplicados -> 409)
  boolean duplicado = false;
  synchronized (session) {
    @SuppressWarnings("unchecked")
    List<Map<String, String>> registros = (List<Map<String, String>>) session.getAttribute("registros");
    if (registros == null) registros = new ArrayList<>();
    for (Map<String, String> r : registros) {
      if (r.get("correo").equalsIgnoreCase(correo)) { duplicado = true; break; }
    }
    if (!duplicado) {
      registros.add(Map.of("id", UUID.randomUUID().toString().substring(0, 8), "nombre", nombre, "correo", correo));
      if (registros.size() > MAX_REGISTROS) registros.remove(0);
      session.setAttribute("registros", registros);
      session.setAttribute("flash", "Registro guardado correctamente.");
    }
  }
  if (duplicado) {
    response.sendError(409, "Ese correo ya está registrado.");
    return;
  }

  // 5) Post/Redirect/Get (303 See Other)
  response.setStatus(303);
  response.setHeader("Location", request.getContextPath() + "/registros.jsp");
%>
