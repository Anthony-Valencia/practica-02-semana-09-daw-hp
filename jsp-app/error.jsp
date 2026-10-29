<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  Integer codigo = (Integer) request.getAttribute("javax.servlet.error.status_code");
  if (codigo == null) codigo = 500;
  response.setStatus(codigo);
  pageContext.setAttribute("codigo", codigo);
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Error ${codigo}</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
</head>
<body>
  <main class="card">
    <h2>Error ${codigo}</h2>
    <c:choose>
      <c:when test="${codigo >= 500}">
        <p class="error">Error interno del servidor.</p>
      </c:when>
      <c:when test="${codigo == 404}">
        <p class="error">Recurso no encontrado.</p>
      </c:when>
      <c:otherwise>
        <p class="error"><c:out value="${requestScope['javax.servlet.error.message']}" default="Solicitud no válida."/></p>
      </c:otherwise>
    </c:choose>
    <p><a href="${pageContext.request.contextPath}/index.jsp">Volver al formulario</a></p>
  </main>
</body>
</html>
