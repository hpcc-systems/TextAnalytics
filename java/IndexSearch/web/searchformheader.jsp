<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %> 
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<link href="css/cdce.css" rel="stylesheet" type="text/css">
<link href="css/tabs2.css" rel="stylesheet" type="text/css">
<link href="css/print.css" rel="stylesheet" type="text/css" media="print">

<script type="text/javascript" src="js/helper.js"></script>


<c:choose>
<c:when test="${(searchDTO.secondsSinceLastRun > 60 || searchDTO.secondsSinceLastRun == 0 || searchDTO.totalResults==0)
==true}"> 

<body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" onLoad="javascript:loadTasks('${searchDTO.id}');"> 
</c:when>
<c:otherwise>
<body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0">
</c:otherwise>
</c:choose>

<a class="hideskiplink" href="#skiptosearch">Skip To Search</a>
<a class="hideskiplink" href="#skiptoresults">Skip To Results</a>

<c:set var="thispage" value="/circuits/SearchForm"/>
<c:url value="UpdateProfileRedirect" var="redirurl">
<c:param name="name" value="RoxieURL" />
<c:param name="returnto" value="${thispage}" />
</c:url>


<c:url value="UpdateProfileRedirect" var="debugurl">
<c:param name="name" value="Debug" />
<c:param name="returnto" value="${thispage}" />
</c:url>



<c:url value="../${thispage}" var="refreshurl">
<c:param name="refreshdmt" value="true" />
</c:url>

<a name="top"></a>

<!-- BEGIN wrapper DIV -->
<div id="wrapper">
<c:if test="${IRTabClass==null || searchDTO.showSearchForm==true}">
<table id="outerTable">
    <tr><td style="padding-left:20px;padding-bottom:10px;"><h3>Simple Search</h3>
    <font size="-1" color="blue"><c:out value="${applicationScope.adminmessage}"/></font></td></tr>
    <tr><td>
        <table id="containerTable">
            <tbody>
                <tr>
                    <td id="containerLeft" valign="top" align="left">

	<!-- begin search body -->

<!-- begin search_input.tpl -->


<div id="tabs">
   <ul id="tablist" >

	<li class="<c:out value='${IRTabClass}'/>" ><a href="IR">Info Retrieval</a></li>

   </ul>
</div>

<div id="tabBkg">
  <div id="tabBkgRight">
  </c:if>