<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/jspf/comun.jspf" %>
<%
  pageContext.setAttribute("csrf", tokenCsrf(session));
  pageContext.setAttribute("flash", session.getAttribute("flash"));
  session.removeAttribute("flash");
%>
<c:set var="titulo" value="Registros almacenados"/>
<%@ include file="/WEB-INF/jspf/encabezado.jspf" %>
<c:if test="${not empty flash}"><p class="ok"><c:out value="${flash}"/></p></c:if>
<c:choose>
  <c:when test="${empty sessionScope.registros}">
    <p class="muted">Aún no hay registros.</p>
  </c:when>
  <c:otherwise>
    <div class="tabla">
      <table border="1">
        <tr><th>#</th><th>Nombre</th><th>Correo</th><th>Acción</th></tr>
        <c:forEach var="r" items="${sessionScope.registros}" varStatus="st">
          <tr>
            <td>${st.count}</td>
            <td><c:out value="${r.nombre}"/></td>
            <td><c:out value="${r.correo}"/></td>
            <td>
              <form class="inline" action="eliminar.jsp" method="POST">
                <input type="hidden" name="csrf" value="${csrf}">
                <input type="hidden" name="id" value="<c:out value="${r.id}"/>">
                <button class="peligro" type="submit">Eliminar</button>
              </form>
            </td>
          </tr>
        </c:forEach>
      </table>
    </div>
    <form action="eliminar.jsp" method="POST">
      <input type="hidden" name="csrf" value="${csrf}">
      <input type="hidden" name="todos" value="1">
      <button class="peligro" type="submit">Eliminar todos</button>
    </form>
  </c:otherwise>
</c:choose>
<p><a href="index.jsp">Registrar otro contacto</a></p>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
