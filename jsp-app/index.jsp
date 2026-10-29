<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/jspf/comun.jspf" %>
<%
  pageContext.setAttribute("csrf", tokenCsrf(session));
  pageContext.setAttribute("flash", session.getAttribute("flash"));
  session.removeAttribute("flash");
  Object lista = session.getAttribute("registros");
  pageContext.setAttribute("total", lista == null ? 0 : ((List<?>) lista).size());
%>
<c:set var="titulo" value="Formulario de Contacto (JSP)"/>
<%@ include file="/WEB-INF/jspf/encabezado.jspf" %>
<c:if test="${not empty flash}"><p class="ok"><c:out value="${flash}"/></p></c:if>
<form action="procesar.jsp" method="POST">
  <input type="hidden" name="csrf" value="${csrf}">
  <label for="nombre">Nombre</label>
  <input id="nombre" type="text" name="nombre" required minlength="2" maxlength="60" autocomplete="name">
  <label for="correo">Correo</label>
  <input id="correo" type="email" name="correo" required maxlength="100" autocomplete="email">
  <button type="submit">Enviar</button>
</form>
<p class="muted">Registros en esta sesión: ${total}. <a href="registros.jsp">Ver registros</a></p>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
