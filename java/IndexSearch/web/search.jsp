<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %> 
<%@ page language="java" contentType="text/html;UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%@ page import="org.hpcc.indexsearch.SearchDTO" %>
<%@ page import="org.hpcc.indexsearch.util.Utility" %>

<%@include file="common.jsp"%>

<%    
SearchDTO searchDTO=(SearchDTO) request.getAttribute("searchDTO");

//advanced form display
String basicTabClass="";
String advancedTabClass="";
String batchTabClass="";
String basicDisplay="";
String advancedDisplay="visibility:visible";
String batchDisplay="";

String excelPageSize="100";
basicTabClass="active";
//advancedDisplay="display:none";
//batchDisplay="display:none";



int offset=((int)searchDTO.getOffset());
int endoffset=offset +  searchDTO.getPageSize()-1;
if (searchDTO.getNumResults() < (searchDTO.getPage() * searchDTO.getPageSize()))
{
	if (searchDTO.getNumResults()!=searchDTO.getPageSize())
	{
		endoffset= searchDTO.getNumResults();
	}
}
//offset=offset+1;

String searchResults=Utils.getVal("searchResults",request);

int firstRec=1 * Integer.valueOf(searchDTO.getPage());
int lastRec=firstRec + searchDTO.getNumResults() -1;

String searchParameterString="savedsearch=true&searchuuid=" + String.valueOf(searchDTO.getId());
if (searchDTO.isDebug()){
	searchParameterString=searchParameterString + "&debug";
}
 
 %>
<html>
<head>

		<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>Simple Search</title>

</head>
<!-- handles main cdc -->

<jsp:include page="searchformheader.jsp" />

	<form accept-charset="UTF-8" name="search" id="searchform" method="POST" action="Search">	
<!-- Include the Search Input form for the search -->
  <table id="searchTable" cellpadding="1" cellspacing="0" border="0">
<tbody>
	<tr>
     <td style="padding-left: 10px; padding-top: 5px;" valign="top">

	 <!-- begin left side of search form -->
	   <table cellspacing="0" border="0">
	   <tbody>
    <!-- row for basic search-->    
      <tr>
        <td valign="top" align="left">
        <table id="fieldsrow" <% if (searchDTO.isBatch()) {%>
style="display:none"
<% } %>
        "border="0" cellpadding="2" cellspacing="0">
        <tr><td colspan=2><h4>Find Records Containing</h4></td></tr>
          <tr>
            <td>&nbsp;<b><label>All of these words</label></b></td>
            
            <td>&nbsp;<b><label>of type</label></b></td>
            <td></td>
            <td></td>
          </tr>
          <c:forEach var='item' items='${searchDTO.andItems}' varStatus='cnt'>
          
          <c:set var="rownum" value="${cnt.count-1}"/>          
          <c:set var="valwidth" value="${cnt.first==false?42:45}"/>
          <tr id="fieldsrow${rownum}" style="${item.display}">                    
            <td class="nsinputs"><nobr>
            <c:if test="${cnt.first==false}"><img src="images/minus.gif" alt="remove row" title="remove row" onclick="removeFieldsRow('','${rownum}');"/>
          </c:if><input type="text" name="value" id="value${rownum}" value="${item.displayValue}" tabindex="1" size="${valwidth}" maxlength="255">
          </nobr></td>
      
            <td class="nsinputs">
            <select name="type" id="type${rownum}">${item.selectedOptionList}</select></td>			
						
          </tr>
          </c:forEach>          
          <tr></tr>        
        </table>
        <a id="fieldsrowadd"  style="visibility:visible" href="javascript:addFieldsRow('')">Add...</a>
        </td>
      </tr>

      
    <!-- end row for basic search--> 

    <tr><td>
    <!-- table for advanced search criteria -->
    <div id="advanced" style="visibility:visible">
    <table border="0" cellpadding="0" cellspacing="0"><tr><td><table>
    <!-- row for "or" search-->
      <tr>
        <td valign="top" align="left">
        <table border="0" id="orfieldsrow" cellpadding="2" cellspacing="0">
          <tr>
            <td>&nbsp;<b><label>Any of these words</label></b></td>
           
            <td>&nbsp;<b><label>of type</label></b></td>
            <td></td>
            <td></td>
          </tr>
         <c:forEach var='item' items='${searchDTO.orItems}' varStatus='cnt'>          
          <c:set var="rownum" value="${cnt.count-1}"/>
            <c:set var="valwidth" value="${cnt.first==false?42:45}"/>                  
          <tr id="orfieldsrow${rownum}" style="${item.display}">                    
            <td class="nsinputs">
            <nobr><c:if test="${cnt.first==false}"><img src="images/minus.gif" alt="remove row" title="remove row" onclick="removeFieldsRow('or','${rownum}');"/></c:if>
            <input type="text" name="orvalue" id="orvalue${rownum}" value="${item.displayValue}" tabindex="1" size="${valwidth}" maxlength="255"></nobr></td>           
            <td class="nsinputs"><select name="ortype" id="ortype${rownum}">${item.selectedOptionList}</select></td>
			
          </tr>
          </c:forEach>  		 
        </table>
         <a id="orfieldsrowadd"  style="<%=advancedDisplay %>" href="javascript:addFieldsRow('or')">Add...</a>
        </td>
      </tr>
    <!-- end row for "or" search--> 
    
    <!-- row for "not" search-->
      <tr>
        <td valign="top" align="left">
        <table border="0" id="excludefieldsrow" cellpadding="2" cellspacing="0">
        
          <tr>
            <td>&nbsp;<b><label for="excludevalue">None of these words</label></b></td>        
            <td>&nbsp;<b><label for="excludetype">of type</label></b></td>
            <td></td>
            <td></td>
          </tr>
          <c:forEach var='item' items='${searchDTO.excludeItems}' varStatus='cnt'>          
          <c:set var="rownum" value="${cnt.count-1}"/>     
          <c:set var="valwidth" value="${cnt.first==false?42:45}"/>               
          <tr id="excludefieldsrow${rownum}" style="${item.display}">          
          <td class="nsinputs">
          <c:if test="${cnt.first==false}">
          	<img src="images/minus.gif" alt="remove row" title="remove row" onclick="removeFieldsRow('exclude','${rownum}');"/>
          </c:if>          
          <input type="text" name="excludevalue" id="excludevalue${rownum}" value="${item.displayValue}" tabindex="1" size="${valwidth}" maxlength="255"></td>
          <td class="nsinputs"><select name="excludetype" id="excludetype${rownum}"">${item.selectedOptionList}</select></td>
			
          </tr>
          </c:forEach>    
        </table>
        <a id="excludefieldsrowadd"  style="<%=advancedDisplay %>" href="javascript:addFieldsRow('exclude')">Add...</a>
        </td>
      </tr>
    <!-- end row for "not" search--> 
    
   
    
    </table></td></tr></table>
    </div><!-- end advanced div -->
    <!-- recent div -->
      <!-- recent div -->

					<div id="advancedsearchtips"  style="<%=advancedDisplay %>">
						<p style="margin-top:10px;"><strong>Search Tips:</strong>&nbsp; Use wildcards (*) to search for partial words. To search for phrases, enclose the phrase in quotes.</p>
					</div>
    
    <!-- end table for advanced search -->
    </td></tr>

<!-- 
            <tr><td><div id="drangediv"  style="visibility:visible"><b>Only Show Records added:</b>
        <script>
function toggledatefields()
{
var range=document.getElementById("dateRange").value;
if (range=="BETWEEN")
{
document.getElementById("xdays").value="";
document.getElementById("begindatelabel").style.display="";
document.getElementById("begindate").style.display="";
document.getElementById("enddatelabel").style.display="";
document.getElementById("enddate").style.display="";
document.getElementById("xdays").style.display="none";
document.getElementById("xdayslabel").style.display="none";
document.getElementById("xdaysendlabel").style.display="none";

}
else if (range=="AFTER") {
document.getElementById("enddate").value="";
document.getElementById("xdays").value="";
document.getElementById("begindatelabel").style.display="";
document.getElementById("begindate").style.display="";
document.getElementById("enddatelabel").style.display="none";
document.getElementById("enddate").style.display="none";
document.getElementById("xdays").style.display="none";
document.getElementById("xdayslabel").style.display="none";
document.getElementById("xdaysendlabel").style.display="none";
}
else if (range=="IN_THE_LAST_X_DAYS") {
document.getElementById("enddate").value="";
document.getElementById("begindate").value="";
document.getElementById("begindatelabel").style.display="none";
document.getElementById("begindate").style.display="none";
document.getElementById("enddatelabel").style.display="none";
document.getElementById("enddate").style.display="none";
document.getElementById("xdays").style.display="";
document.getElementById("xdayslabel").style.display="";
document.getElementById("xdaysendlabel").style.display="";
}
else {
document.getElementById("begindatelabel").style.display="none";
document.getElementById("begindate").style.display="none";
document.getElementById("enddatelabel").style.display="none";
document.getElementById("enddate").style.display="none";
document.getElementById("xdays").style.display="none";
document.getElementById("xdayslabel").style.display="none";
document.getElementById("xdaysendlabel").style.display="none";
}
}
</script>
<% 

//String dateRange=Utils.getVal("dateRange",request);
//String begindate=Utils.getVal("begindate",request);
//String enddate=Utils.getVal("enddate",request);
//String xdays=Utils.getVal("xdays",request);

String dateRange=searchDTO.getDateRange();
String begindate=searchDTO.getBeginDate();
String enddate=searchDTO.getEndDate();
String xdays=searchDTO.getLastXDays();

String displaybegin="display:none;";
String displayend="display:none;";
String displayxdays="display:none;";
String yearselected="";
String weekselected="";
String monthselected="";
String xdaysselected="";
String betweenselected="";
String afterselected="";
if (dateRange.equals("IN_THE_LAST_X_DAYS"))
{
	xdaysselected="selected";
	displayxdays="";
	begindate="";
	enddate="";
}
else if (dateRange.equals("AFTER"))
{
	afterselected="selected";
	displaybegin="";
	enddate="";
	xdays="";

}
else if (dateRange.equals("BETWEEN"))
{
	betweenselected="selected";
	displaybegin="";
	displayend="";
	xdays="";
} else if (dateRange.equals("THIS_WEEK"))
{
	weekselected="selected";
	xdays="";
	begindate="";
	enddate="";
}
else if (dateRange.equals("THIS_MONTH"))
{
	monthselected="selected";
	xdays="";
	begindate="";
	enddate="";
}
else if (dateRange.equals("THIS_YEAR"))
{
	yearselected="selected";
	xdays="";
	begindate="";
	enddate="";
}

%>

<table><tr><td>
<select name="dateRange" id="dateRange" onchange="javascript:toggledatefields();">
<option value=""></option>
<option value="THIS_WEEK" <%=weekselected%>>This Week</option>
<option value="THIS_MONTH" <%=monthselected%>>This Month</option>
<option value="THIS_YEAR" <%=yearselected%>>This Year</option>
<option value="IN_THE_LAST_X_DAYS" <%=xdaysselected%>>In the Last X Days</option>
<option value="BETWEEN" <%=betweenselected%>>Between Dates</option>
<option value="AFTER" <%=afterselected%>>After</option>
</select>
</td>
<td>
<label id="begindatelabel" style="<%=displaybegin%>">Begin Date (mm/dd/yyyy)</label> 
<input name="begindate" id="begindate" value="<%=begindate%>" style="<%=displaybegin%>"/>
</td>
<td>
<label id="enddatelabel" style="<%=displayend%>"> and End Date (mm/dd/yyyy)</label> 
<input name="enddate" id="enddate" value="<%=enddate%>" style="<%=displayend%>"/>
</td>
<td>
<label id="xdayslabel" style="<%=displayxdays%>">In the last</label> 
<input name="xdays" id="xdays" value="<%=xdays%>" style="<%=displayxdays%>" size=4/>
<label id="xdaysendlabel" style="<%=displayxdays%>">days</label>
</td>
</td></tr></table>


            </div></td></tr>
	  -->
	   </tbody>
	   </table>	   
	<!-- end left side of search-->   
	  </td>
	  
  <!-- begin right side of search form -->  
  	<td style="padding-left: 10px; padding-right: 5px; padding-top: 5px;" valign="top" width="25%">
  	
	   <table cellspacing="0" border="0">
	   		<!-- search buttons -->
	   		<tr>
      			<td style="padding-right: 10px; padding-top: 18px;" valign="top" width="33%">
			        <table border="0" cellpadding="0" cellspacing="0">
  						<tr>
    						<td class="no-print" align="center">
    						<input name="BUTTON" tabindex="101" id="searchBtn" type="submit" value="Search"> 	
							<input name="BUTTON" tabindex="102" id="clearSrch" type="button" value="Clear Form" onClick="ClearAll();">
    						</td>
  						</tr>
					</table>
		      </td>
    		</tr>
		   <!-- spacer row -->
		   <tr>
			   <td height="10"></td>
	  	   </tr>
	  	   
	  	   <!-- help link row -->
	     	<tr>
	         	<td valign="top" align="left">
        		</td>
        	</tr>
        	<!-- search tips row -->
        	<tr>
        		<td>
    <div id="recentsearches" ><!-- style="display:none;"> -->
 <h2>Recent Searches</h2>
    	<c:forEach var="ss" items="${sessionScope.savedsearches}" varStatus="status">
    	   <table border=0>
    	<tr><td>

    	<c:out value="${status.count}"/>. 
			<a href="Search?savedsearch=true&searchuuid=${ss.id}&page=1&outputFormat=html">  ${ss.searchstring} &nbsp;</a>     

   			</td>
   			<!-- <td valign="top"><nobr>(<c:out value="${ss.totalResults}"/> Records)</nobr></td>-->
   			</tr>
		</table>
		</c:forEach>
		
		(<a href="Search?clearsavedsearches">Clear Saved Searches</a>)				
    </div><!-- end recent div -->
      			</td>
     		</tr>
   		</table><!-- end right side of search form -->
   		
	 </td>
	</tr>  
</tbody>
</table><!-- end search form -->
<input type="hidden" name="ui" value="cdce.ir.v01"/>
<input type="hidden" name="outputFormat" value="html"/>
<input type="hidden" name="passthroughURL" value="wsIR/wsIR.Raw_bitmap"/>
<input type="hidden" name="debug" value="${searchDTO.debug}"/>
<input type="hidden" name="isadvanced" id="isadvanced" value="${searchDTO.advanced}"/>
<input type="hidden" name="isBatch" id="isBatch" value="${searchDTO.batch}"/>
</form>


<jsp:include page="searchformfooter.jsp"/>
	
	

    <!-- Start Right Column Content -->
   
  </td> <td valign="top" width="240" id="tdr">


<!--end of right side of page-->
   </td>
  </tr>
  </tbody>
</table>
<c:if test="${searchDTO.debug}">
<div>
<c:if test="${not empty postdata}">
<b>Post Data:</b><pre>${postdata}</pre>
</c:if>
<p/>
<c:if test="${not empty sourcelistxml}">
<b>Source Stack:</b><pre>${sourcelistxml}</pre>
</c:if>
<p/>
<c:if test="${not empty searchresultxml}">
<b>Search Result XML:</b><pre>${searchresultxml}</pre>
</c:if>
</div>
</c:if>
<a name="skiptoresults"></a>
	
<table width="98%" border="0">
  <tbody>
  <tr>
  <td colspan="1">
  
<!--errors-->
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
	     <!-- begin search results-->

	    <% if (!searchResults.trim().equals("")) { %> 

<script>
window.location="#searchResults";
</script>
<a name="searchResults"></a>
<div id="searchResults">

<% if ( searchDTO.getNumResults() > 0) { %>
<span class="grey" id="resultcount">
<c:if test="${(searchDTO.secondsSinceLastRun < 60 && searchDTO.secondsSinceLastRun > 0 && searchDTO.totalResults > 0)==true}">
<c:out value="${searchDTO.totalResults}"/>
</c:if>
</span><span class="grey">Records: <%=offset%> to <%=endoffset %> </span>   
<%}%>
  
	<h2>${searchDTO.label}</h2>
	<c:if test="${searchDTO.searchResults}">
	<span id="search_terms"><p><strong>Search Terms Used: </strong>		
	<% if (searchDTO.getSearchstring(500) != searchDTO.getSearchstring()) { %>
<a class=info href="#searchResults"><%=searchDTO.getSearchstring(500) %><span><%=searchDTO.getSearchstring() %></span></a>
<%} else {%>
<a class=searchstring><%=searchDTO.getSearchstring() %></a>

<%}%> 
</p></span>
<c:if test="${not empty message}">
<br/><span id="search_terms" style="color:#FF0000"><c:out value="${message}"/></span>
</c:if>
</c:if>
<!-- begin search messages -->

<% if (searchDTO.getNumResults() > 0) { %>
	<span class="grey">
			
      <% if (searchDTO.getPage() > 1) {%>
     		<a href="Search?<%=searchParameterString%>&page=<%=searchDTO.getPage()-1%>&outputFormat=html"><img border="0" width="6" height="8" src="images/ico_left_arrow.gif" alt="Previous"> Previous</a> | 
      <% } %> 
      Page <%=searchDTO.getPage() %> 
      <% if (searchDTO.getMoreResults()) {%>
  | <a href="Search?<%=searchParameterString%>&page=<%=searchDTO.getPage()+1%>&outputFormat=html">Next <img border="0" width="6" height="8" src="images/ico_right_arrow.gif" alt="Next"></a> 
<% } %>
    <br/>
    </span>

<!-- end search messages -->

<br/>

<table width="100%"><tr><td width="50%"><!-- todo: actual total count<p>Records Retrieved: <%= endoffset %></p> --></td><td><table id="searchResultsIcons" cellpadding="0" cellspacing="0"><tbody><tr>
<td></td>
<td></td>

</tr></tbody></table></td></tr></table>

<%} else { %>
<P style="padding-top:20px"><strong>No Results Found</strong></P>

<%} %>
<%=searchResults %>

<% if (searchDTO.getNumResults() > 0) { %>
	<span class="grey">
			
      <% if (searchDTO.getPage() > 1) {%>
    		<a href="Search?<%=searchParameterString%>&page=<%=searchDTO.getPage()-1%>&outputFormat=html"><img border="0" width="6" height="8" src="images/ico_left_arrow.gif" alt="Previous"> Previous</a> |
      <% } %> 
      Page <%=searchDTO.getPage() %> 
      <% if (searchDTO.getMoreResults()) {%>
| <a href="Search?<%=searchParameterString%>&page=<%=searchDTO.getPage()+1%>&outputFormat=html">Next <img border="0" width="6" height="8" src="images/ico_right_arrow.gif" alt="Next"></a>
<% } %>
    <br/>
    </span>



	   
	   
	   <div id="clear"></div>
	   
	<div id="clear"></div>

<%} %>



</div>

<% }%>

<!-- end if show results -->
  
  <br/>



<!-- end search footer -->


  </td>
  </tr>
  </tbody>
</table>

</td></tr></table>

</div><!-- END wrapper DIV -->
<div id="systemWorking" style="position:absolute;top:350px;left:450px;z-index:100;display:none;">
<img id="sWimg" src="images/bg_searching.gif" alt="Running Search.." />
</div>



<div id="footer">
     
</div>


<div id="info_rem"></div>
<div id="wrapperoverlay" onClick="close_tip('info_rem','wrapperoverlay');"></div>

<div name="phonelist" id="phonelist"></div>
<div name="checksources" id="checksources"></div>
</body>
</html>
