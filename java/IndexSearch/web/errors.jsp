<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<head></head>
<body>

<c:forEach var="error" items="${errors}">
 <font color="red"><strong>Error:</strong><c:out value="${error}" />
 </font> 
<br/>
</c:forEach>

<p/>
<c:forEach var="warning" items="${warnings}">
 <strong>Warning:</strong><c:out value="${warning}" ></c:out>
 </font> 
<br/>
</c:forEach>

</body>
