<%@ page import="org.apache.commons.lang3.StringUtils" %>
<%!  
 
 public static class Utils
 {

 public static String SetOptionListSelections(String allOptions, String[] selectedVals)
 {
 	if (selectedVals==null) {return allOptions;} 	
 	for (int i=0; i < selectedVals.length; i++)
 	{ 	
 	 allOptions=allOptions.replace("value=\"" + selectedVals[i] + "\">", "value=\"" + selectedVals[i] + "\" selected=\"selected\">");
 	}

 	
	 return allOptions;
 
 }
 public static String getVal(String valname,HttpServletRequest request, String defaultValue)
 {
 	String result=getVal(valname,request);
 	if (result=="") {
 		result=defaultValue;
 	}
 	return result;
 }
 
 public static String getVal(String valname,HttpServletRequest request)
 {
 if (request.getParameter(valname) != null && request.getParameter(valname) != "")
 {
 return request.getParameter(valname);
 }
 else if (request.getAttribute(valname) != null && (String) request.getAttribute(valname) != "")
 {
 return (String) request.getAttribute(valname);
 }
 else if (request.getSession().getAttribute(valname) != null)
 {
 return (String) request.getSession().getAttribute(valname);
 }
 else {
 return "";
 }
 }
 
 
  public static String[] getVals(String valname,HttpServletRequest request)
 {
 if (request.getParameterValues(valname) != null)
 {
     return request.getParameterValues(valname);
 }
 else if (request.getAttribute(valname) != null && (String) request.getAttribute(valname) != "")
 {
 return ((String) request.getAttribute(valname)).split("|");
 }
 else if (request.getSession().getAttribute(valname) != null)
 {
 return ((String) request.getSession().getAttribute(valname)).split("|");
 }
 else {
 return new String[] {""};
 }
 }
}
%>
