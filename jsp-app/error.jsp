<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/jspf/comun.jspf" %>
<%
  Integer codigo = (Integer) request.getAttribute("javax.servlet.error.status_code");
  if (codigo == null) codigo = 500;
  response.setStatus(codigo);
  pageContext.setAttribute("codigo", codigo);
%>
<c:set var="titulo" value="Error ${codigo}"/>
<%@ include file="/WEB-INF/jspf/encabezado.jspf" %>
<c:choose>
  <c:when test="${codigo >= 500}"><p class="error">Error interno del servidor.</p></c:when>
  <c:when test="${codigo == 404}"><p class="error">Recurso no encontrado.</p></c:when>
  <c:otherwise>
    <p class="error"><c:out value="${requestScope['javax.servlet.error.message']}" default="Solicitud no válida."/></p>
  </c:otherwise>
</c:choose>
<p><a href="${pageContext.request.contextPath}/index.jsp">Volver al formulario</a></p>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
