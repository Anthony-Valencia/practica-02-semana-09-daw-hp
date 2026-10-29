<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ include file="/WEB-INF/jspf/comun.jspf" %>
<%
  if (!"POST".equals(request.getMethod())) {
    response.setHeader("Allow", "POST");
    response.sendError(405, "Método no permitido. Usa el formulario (POST).");
    return;
  }
  request.setCharacterEncoding("UTF-8");
  if (!csrfValido(request, session)) {
    response.sendError(403, "Token CSRF inválido o ausente. Recarga la página.");
    return;
  }

  final String id = request.getParameter("id");
  boolean todos = "1".equals(request.getParameter("todos"));
  if (!todos && (id == null || id.isEmpty())) {
    response.sendError(422, "Falta el identificador del registro.");
    return;
  }

  synchronized (session) {
    @SuppressWarnings("unchecked")
    List<Map<String, String>> registros = (List<Map<String, String>>) session.getAttribute("registros");
    if (registros != null) {
      if (todos) registros.clear();
      else registros.removeIf(m -> id.equals(m.get("id")));
    }
  }
  session.setAttribute("flash", todos ? "Registros eliminados." : "Registro eliminado.");

  response.setStatus(303);
  response.setHeader("Location", request.getContextPath() + "/registros.jsp");
%>
