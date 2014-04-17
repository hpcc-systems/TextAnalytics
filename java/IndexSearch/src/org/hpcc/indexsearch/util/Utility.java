package org.hpcc.indexsearch.util;
//TODO: make sweep on this class to ensure we are not carrying anything extra.

	import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.lang.Character.UnicodeBlock;
import java.net.PasswordAuthentication;
import java.net.Authenticator;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.net.ssl.HttpsURLConnection;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;



	/**
	 * @author uleeddx
	 * Utility class used by multiple classes in com.lnssi
	 *
	 */

	public class Utility {
		public static String BEGIN_DYNAMIC = "~D~";
		public static String END_DYNAMIC = "~D~";
		private static Logger _logger = Logger.getLogger(Utility.class);
		private static ServletContext servletContext = null;

		public static ServletContext getServletContext() {
			return servletContext;
		}
		
		public static NodeList getNodes(String eclInput, String nodeName) throws Exception
		{
			if (eclInput == null || eclInput.trim() == "") {
				return null;
			}
			if (nodeName.startsWith("/")==false)
			{
				nodeName="//" + nodeName;
			}
			
			DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
//			String eclStr=new String(eclInput.getBytes("ISO-8859-1"),"UTF-8");
			
			ByteArrayInputStream bis = new ByteArrayInputStream(eclInput.getBytes("UTF-8")); 
			Document doc = db.parse(bis);
		   	XPathFactory xpf = XPathFactory.newInstance(); 
	        XPath xp = xpf.newXPath(); 
	        NodeList result = (NodeList)xp.evaluate(nodeName, doc.getDocumentElement(), XPathConstants.NODESET); 	       
	        return result;	
		}
		
		/**
		 * Takes and XML string and the name of the nodes to return.
		 * Uses SAX to parse the XML document and extract the nodes.
		 * <br/>
		 * Uses SimpleNode so Utility.ElementToString(node); returns an empty
		 * String.
		 * @param eclInput
		 * @param nodeName
		 * @return
		 * @throws Exception
		 */
	 
	    
		/**
		 * GetNodeValueString
		 * @param eclInput - the xml text containing the node value to extract
		 * @param nodeName - the name of the node whose value to return. Case-sensitive.
		 * @return string of the node's content.
		 */
		public static String getNodeValueString(String eclInput,String nodeName)
		{
			if (eclInput == null || eclInput.trim() == "") {
				return "";
			}
			int start = eclInput.indexOf("<" + nodeName + ">");
			int end = eclInput.indexOf("</" + nodeName + ">");
			if (start == -1 || end == -1
					|| end < start + ("<" + nodeName + ">").length()) {
				return "";
			}
			String result = eclInput.substring(start
					+ ("<" + nodeName + ">").length(), end);
			if (result.indexOf("<") > 0) {
				result = result.substring(result.indexOf("<"), result.length()
						- result.indexOf("<"));
			}
			return "<" + nodeName + ">" + result + "</" + nodeName + ">";
		}
		/**
		 * GetNodeValue
		 * @param eclInput - the xml text containing the node value to extract
		 * @param nodeName - the name of the node whose value to return. Case-sensitive.
		 * @return string of the node's content.
		 */
		public static String getNodeValue(String eclInput, String nodeName) {
			if (eclInput == null || eclInput.trim() == "") {
				return "";
			}
			if (nodeName.startsWith("/")==false)
			{
				nodeName="//" + nodeName;
			}
			
			try {
				DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
//				String eclStr=new String(eclInput.getBytes("ISO-8859-1"),"UTF-8");
				
				ByteArrayInputStream bis = new ByteArrayInputStream(eclInput.getBytes("UTF-8")); 
				Document doc = db.parse(bis);
			   	XPathFactory xpf = XPathFactory.newInstance(); 
		        XPath xp = xpf.newXPath(); 
		        NodeList result = (NodeList)xp.evaluate(nodeName, doc.getDocumentElement(), XPathConstants.NODESET); 
		        StringBuilder sb=new StringBuilder();
		        if (result.getLength()==1 && ( result.item(0).hasChildNodes()==false
		        		|| (result.item(0).hasChildNodes()==true && result.item(0).getChildNodes().getLength()==1
		        		&& result.item(0).getChildNodes().item(0).getNodeType()==3)))
		        {
		       		sb.append(result.item(0).getTextContent());
		        }
		        else {
			        for (int i=0; i < result.getLength();i++)
			        {
			        	StringWriter sw = new StringWriter();
			        	Node nd =result.item(i);
			        	Transformer serializer = TransformerFactory.newInstance().newTransformer();
			        	serializer.transform(new DOMSource(nd), new StreamResult(sw));
			        	sb.append(sw.toString());		        	
			        }
		        }
		        String xmlstr=sb.toString();
		        xmlstr=xmlstr.replace("<?xml version=\"1.0\" encoding=\"UTF-8\"?>","");
		        return xmlstr;
			
			} catch (Exception e){
				_logger.warn(e.getMessage(), e);
				return "";
			}
		}

		/**
		 * @param theURL - the URL to submit
		 * @param theData - any additional data to post to the URL
		 * @param auth - the base-64 encoded username:password string for URL authorization
		 * @return the URL response content
		 * @throws Exception 
		 */
		public static String processRequest(String theURL, String data) throws Exception {
			return processRequest(theURL,data,null,null,new HashMap<String,String>(),true);
		}
		public static String processRequest(String theURL, String data,
				String username, String password,Boolean allowInvalidCerts) throws Exception {
			return processRequest(theURL,data,username,password,new HashMap<String,String>(),true);
		}
		public static String processRequest(String theURL, String data,
				String user,String password,HashMap<String,String> headerParams,Boolean allowInvalidCerts) throws Exception {
		
			StringBuilder mydata = new StringBuilder();
    	   	//System.out.println("ECLSoap doSoap -- User:"+user+ " " + "Pass:" + pass);
			String auth=null;
			
			if (user != null && password != null && !user.isEmpty()) {
				ECLAuthenticator eclauth = new ECLAuthenticator(user,password);    	       	   
    	   		Authenticator.setDefault(eclauth);
    	   		auth= user + ":" + password;
    	   		auth = new String(Base64.encodeBase64(auth.getBytes()));
			}

            	
			try {
				if (allowInvalidCerts)
				{
						SSLUtilities.trustAllHttpsCertificates();
						SSLUtilities.trustAllHostnames();
				} 
			
				URL myurl = new URL(theURL);
				URLConnection myconn = myurl.openConnection();
				HttpURLConnection connection=(HttpURLConnection) myconn;
				if (theURL.contains("https://"))
				{
					connection=(HttpsURLConnection) connection;
				}
				//	HttpURLConnection connection = (HttpURLConnection) myconn;
				connection.setDoInput(true);
				connection.setDoOutput(true);
				connection.setRequestMethod("POST");
				if (auth != null) {
					connection.setRequestProperty("Authorization", "Basic " + auth);
				}
				connection.setUseCaches(true);
				if (headerParams != null && headerParams.size()>0)
				{
					for (Map.Entry<String, String> entry : headerParams.entrySet())
			    	{		
						connection.setRequestProperty(entry.getKey(),entry.getValue());					
					}
				}
				
		        if(data != null && data.length() > 0)
		        {
		        	 connection.setRequestProperty("Content-Length", "" + 
		        			 Integer.toString(data.getBytes().length));
		            DataOutputStream dos = new DataOutputStream(connection.getOutputStream());
		            dos.writeBytes(data.toString());
		            dos.flush();
		            dos.close();
		        }
				
				//connection.connect();

				
				BufferedReader urlin = new BufferedReader(new InputStreamReader(
						connection.getInputStream(), "UTF-8"));
				String inline = null;

				while ((inline = urlin.readLine()) != null) {
					mydata.append(inline);
				}
				urlin.close();
			} catch (FileNotFoundException exp) {
				_logger.error("URL " + theURL + " does not exist");
				throw new Exception("URL " + theURL + " does not exist");
			} catch (Exception exp)
			{
				_logger.error("error in Utility.ProcessRequest:" + exp.toString());
				StackTraceElement[] theStackTrace = exp.getStackTrace();
				for (int i = 0; i < theStackTrace.length; i++) {
					_logger.error(theStackTrace[i]);
				}
				throw exp;
			}
			String result=mydata.toString();
			try {
				//result= new String(mydata.toString().getBytes("ISO-8859-1"), "UTF-8");
			} catch (Exception e) {}
			return result;
		}

		/**
		 * @param xml the xml string containing the date to convert to a standard date
		 * @return the Date representation of the xml date
		 */
		public static Date xmlToDate(String xml) {
			try {
				XMLGregorianCalendar xcal = DatatypeFactory.newInstance()
						.newXMLGregorianCalendar(xml);
				GregorianCalendar cal = xcal.toGregorianCalendar();
				return cal.getTime();
			} catch (Exception e) {
				return null;
			}
		}

	    
	    static public boolean hasParameter(HttpServletRequest request, String paramName)
	    {
	        String[] paramValues = request.getParameterValues(paramName);
	        if (paramValues != null && paramValues.length>=1)
	        {
	        	return true;
	        }
	        else {
	        	return false;
	        }
	    }
	    
	    
	    static public String parametersToString(Map<String,String[]> parameters, boolean joinMultipleFieldValues, String joinchar) throws UnsupportedEncodingException
	    {
	    	StringBuilder val = new StringBuilder();
	    	int i=1;
	    	int numParams=parameters.size();
	    	for(Map.Entry<String, String[]>entry : parameters.entrySet())
	    	{
	    		val.append(entry.getKey()).append("=");
	    		String value="";
	    		if (joinMultipleFieldValues)
	    		{
	    			value=StringUtils.join(entry.getValue(),joinchar);
	    			
	    		} else {
	    			value=entry.getValue()[0];
	    		}
	    		
	    		value= new String(value.getBytes("ISO-8859-1"), "UTF-8");
	    		value=URLEncoder.encode(value,"UTF-8");
	    		val.append(value);
	    		if (i < numParams)
	    		{
	    			val.append("&");
	    		}
	    		i++;
	    		
	    	}
	    	return val.toString();
	    }

	    static public Map<String,String[]> stripParameters(Map<String,String[]> parameters, ArrayList<String> fieldsToStrip)
	    {
	    	HashMap<String,String[]> newmap = new HashMap<String,String[]>();
	    	for (Map.Entry<String, String[]> entry : parameters.entrySet())
	    	{
	    		if (!fieldsToStrip.contains(entry.getKey()))
	    		{
	    			newmap.put(entry.getKey(), entry.getValue());
	    		}
	    	}
	    	
	    	return newmap;
	    	
	    }
	    
	    static public String  getUrlData(HttpServletRequest request)
	    {
	    	StringBuffer mydata=new StringBuffer();
	    	BufferedReader urlin = null;
	    	try {
			urlin = new BufferedReader( new InputStreamReader(request.getInputStream(), "UTF-8"));
			String inline;
			while( (inline = urlin.readLine()) != null )
			    {
			        mydata.append(inline);
			    }
			urlin.close();
	    	}
			catch (Exception e){
				if (urlin != null)
				{
					try {urlin.close();} catch (IOException e1) {}
				}
			}
		    return mydata.toString();
	    }
	    

	    static public String getParameter(HttpServletRequest request, String paramName, String joinChar)
	    {
	        String[] paramValues = request.getParameterValues(paramName);
	        if (paramValues != null && paramValues.length>=1)
	        {
	        	return StringUtils.join(paramValues,joinChar);
	        }
	        else {
	        	return "";
	        }
	    }
	    
	    static public String getParameter(HttpServletRequest request, String paramName, String joinChar, String defaultval)
	    {    	
	        String[] paramValues = request.getParameterValues(paramName);
	        if (paramValues != null && paramValues.length>=1)
	        {
	        	return StringUtils.join(paramValues,joinChar);
	        }
	        else {
	        	return defaultval;
	        }
	    }
	    

	    static public boolean hasErrors(HttpServletRequest request)
	    {
	    	boolean haserrors=false;
	    	if (request.getAttribute("errors") != null)
	    	{
	    		@SuppressWarnings("unchecked")
				ArrayList<String> errs=(ArrayList<String>) request.getAttribute("errors");
	    		if (errs.size() > 0)
	    		{
	    			haserrors=true;
	    		}
	    	}
	    	return haserrors;
	    }
	    static public String getErrorsAsXml(HttpServletRequest request)
	    {
	        StringBuffer errorBuf = new StringBuffer();
	        errorBuf.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
	        errorBuf.append("<errors>");
	        if (request.getAttribute("errors") != null)
	        {
	            @SuppressWarnings("unchecked")
				ArrayList<String> errs=(ArrayList<String>) request.getAttribute("errors");
	            Iterator<String> eiter = errs.iterator();
	            while(eiter.hasNext())
	            {
	                errorBuf.append("<error>");
	                errorBuf.append(StringEscapeUtils.escapeXml(eiter.next()));
	                errorBuf.append("</error>");
	            }
	        }
	        errorBuf.append("</errors>");
	        return errorBuf.toString();
	    }
	    
	    
	    static public boolean parseBoolean(String value)
	    {
	    	if (value==null) {return false;}
	    	
	    	else if (value.equalsIgnoreCase("true") || 
	   	          value.equalsIgnoreCase("yes") || 
	  	          value.equalsIgnoreCase("on") || 
	    	      isPositive(value)) {
	    	      return true;
	    	    }    	    
	   	    return false;
	    }

		private static boolean isPositive(String value) {
		    int intValue = 0;
		    try {
		      intValue = Integer.parseInt(value);
		    } catch (NumberFormatException e) {
		      //Ignore for now
		    }
		    return intValue > 0;
		  }
	    static public String transformXml(String xml, String xslfile, String instanceId) throws Exception
	    {
	    	  try {
	    	        // Create transformer factory
	    	        TransformerFactory factory = TransformerFactory.newInstance();

	    	        // Use the factory to create a template containing the xsl file
	    	        //path should begin with dir under the context root, and start with "/"
	    	        
	    	        InputStream is = null;
	    	        if (servletContext == null) {
	    	        	is = ClassLoader.getSystemClassLoader().getResourceAsStream(xslfile);	    	        	
	    	        } else {
    	        		is= servletContext.getClassLoader().getResourceAsStream(xslfile);
	    	        }
	        		StreamSource ss=new StreamSource(is);
	        		Templates template = factory.newTemplates(ss);
	    	        				
	    	        // Use the template to create a transformer
	    	        Transformer xformer = template.newTransformer();
	    	        if (instanceId != null) {
	    	        	xformer.setParameter("instance", instanceId);
	    	        }

	    	        // Prepare the input file
	    	    	StreamSource source= new StreamSource(new ByteArrayInputStream(xml.getBytes("UTF-8")));
	    	    	
	    	    	ByteArrayOutputStream out=new ByteArrayOutputStream();
	    	    	//init destination stream
	    	        StreamResult result = new StreamResult(out);
	    	        
	    	        //perform transform
	    	        xformer.transform(source, result);
	    	        
	    	        //convert output to string
	    	        StringBuilder r = new StringBuilder();
	    	        r.append("<!-- stylesheet being used: ").append(xslfile).append(" -->\n");
	    	        r//.append("<div style=\"overflow:auto;overflow-y:hidden;-ms-overflow-y:hidden;border:1px solid gray;\">")
	    	        	.append(out.toString("UTF-8"));
	    	        	//.append("</div>");
	    	        return r.toString();
	    	        
	    	  	} catch (TransformerException sax) {
	    	  		throw sax;
	    	    } catch (Exception e) {
	    	    	_logger.error("error in Utility.TransformXML:" + e.toString(), e);
	    			StackTraceElement[] theStackTrace = e.getStackTrace();
	    			for (int i = 0; i < theStackTrace.length; i++) {
	    				_logger.error(theStackTrace[i]);
	    			}
	    			return xml;
	    	    }
	    }
	    static public String transformXML(String xml, String xslfile,ServletContext ctx) throws Exception
	    {
	    	  try {
	    	        // Create transformer factory
	    	        TransformerFactory factory = TransformerFactory.newInstance();

	    	        // Use the factory to create a template containing the xsl file
	    	        //path should begin with dir under the context root, and start with "/"
	    	        Templates template = factory.newTemplates(new StreamSource(
	    	            ctx.getResourceAsStream(xslfile)));

	    	        // Use the template to create a transformer
	    	        Transformer xformer = template.newTransformer();

	    	        // Prepare the input file
	    	    	StreamSource source= new StreamSource(new ByteArrayInputStream(xml.getBytes("UTF-8")));
	    	    	
	    	    	ByteArrayOutputStream out=new ByteArrayOutputStream();
	    	    	//init destination stream
	    	        StreamResult result = new StreamResult(out);
	    	        
	    	        //perform transform
	    	        xformer.transform(source, result);
	    	        
	    	        //convert output to string
	    	        return out.toString("UTF-8");
	    	        
	    	    } catch (Exception e) {
	    	    	
	    			StackTraceElement[] theStackTrace = e.getStackTrace();
	    			for (int i = 0; i < theStackTrace.length; i++) {
	    			
	    			}
	    			throw e; // An error occurred while creating an empty DOM document
	    	    }
	    }

	    static public void transformXml(String xml, String xslfile, Writer writer, String instanceId) throws Exception
	    {
	    	  try {
	    	        // Create transformer factory
	    	        TransformerFactory factory = TransformerFactory.newInstance();

	    	        // Use the factory to create a template containing the xsl file
	    	        //path should begin with dir under the context root, and start with "/"
	    	        
	    	        InputStream is = null;
	    	        if (servletContext == null) {
	    	        	is = ClassLoader.getSystemClassLoader().getResourceAsStream(xslfile);	    	        	
	    	        } else {
    	        		is= servletContext.getClassLoader().getResourceAsStream(xslfile);
	    	        }
	        		StreamSource ss=new StreamSource(is);
	        		Templates template = factory.newTemplates(ss);
	    	        				
	    	        // Use the template to create a transformer
	    	        Transformer xformer = template.newTransformer();
	    	        if (instanceId != null) {
	    	        	xformer.setParameter("instance", instanceId);
	    	        }

	    	        // Prepare the input file
	    	    	StreamSource source= new StreamSource(new ByteArrayInputStream(xml.getBytes("UTF-8")));
	    	    	
	    	    	//init destination stream
	    	        writer.append("<!-- stylesheet being used: ").append(xslfile).append(" -->\n");
	    	    	StreamResult result = new StreamResult(writer);
	    	        
	    	        
	    	        //perform transform
	    	        xformer.transform(source, result);
	    	        return;
	    	        
	    	        
	    	  	} catch (TransformerException sax) {
	    	  		throw sax;
	    	    } catch (Exception e) {
	    	    	_logger.error("error in Utility.TransformXML:" + e.toString(), e);
	    			StackTraceElement[] theStackTrace = e.getStackTrace();
	    			for (int i = 0; i < theStackTrace.length; i++) {
	    				_logger.error(theStackTrace[i]);
	    			}
	    			return;
	    	    }
	    }

	    
	    
	    public static String getEspError(String edfsResult)
	    {
	    	String error="";
	    	if (edfsResult.contains("<Exception") || edfsResult.contains("WS-ECL Error")
					|| edfsResult.contains("ESP Error"))
			{
				error=Utility.getNodeValue(edfsResult,"//Exception");
				if (error.equals("") && edfsResult.contains("<body"))
				{
					error=Utility.getNodeValueString(edfsResult,"body");
				}
				if (error.equals(""))
				{
					error=edfsResult;
				}
			}
			return error;
	    }
	    

	    /**
	     * Read a file that's on the classpath and return it as a single string.
	     * This version preserves newlines.
	     * @param filepath Path to file (with slashes for folders)
	     * @return String
	     * @throws IOException if the file can't be found or read
	     */
	    public static String getResourceAsString(String filepath)
	    	throws IOException
	    {
	    	return getResourceAsString(filepath, true);
	    }
	    
	    /**
	     * Read a file that's on the classpath and return it as a single string.
	     * @param filepath Path to file (with slashes for folders)
	     * @param preserveNewlines
	     * @return String
	     * @throws IOException if the file can't be found or read
	     */
	    public static String getResourceAsString(String filepath, boolean preserveNewlines)
	    	throws IOException
	    {
    		StringBuilder s = new StringBuilder();

    		BufferedReader reader = getResourceReader(filepath);
    		try {
	    		while(reader.ready()) {
	    			if (s.length() > 0) {
	    				if (preserveNewlines) {
	    					s.append('\n');
	    				} else {
	    					s.append(' ');
	    				}
	    			}
	    			s.append(reader.readLine());
	    		}
	    		return s.toString();
    		} finally {
    			reader.close();
    		}
	    }

	    public static BufferedReader getResourceReader(String filepath) throws IOException {
    		try {
	    		if (servletContext == null) {
		    		return new BufferedReader(
						new InputStreamReader(
							ClassLoader.getSystemClassLoader().getResourceAsStream(
								filepath)));
	    		} else {
		    		return new BufferedReader(
						new InputStreamReader(
							servletContext.getClassLoader().getResourceAsStream(filepath), "utf-8"));
	    		}
    		} catch (NullPointerException npe) {
    			throw new IOException("File not found: "+filepath, npe);
    		}
	    }
	    
	    public static void setServletContext(ServletContext servletContext) {
	    	Utility.servletContext = servletContext;
	    }
	    
	    
		/*
	     * ECLAuthenticator
	     * 
	     * Hnadles the http authentication for the soap request
	     */
	    static class ECLAuthenticator extends Authenticator {
	        public String user;
	        public String pass;
	        String hostname = getRequestingHost();
	        
	        public ECLAuthenticator(String kuser,String kpass){
	            //System.out.println("_________Hostname_______"+hostname);
	            user=kuser;
	            pass=kpass;
	        }
	        public PasswordAuthentication getPasswordAuthentication() {
	            // I haven't checked getRequestingScheme() here, since for NTLM
	            // and Negotiate, the usrname and password are all the same.
	           // System.err.println("Feeding username and password for " + getRequestingScheme() + " " + user + ":" + pass +"@"+hostname);
	            PasswordAuthentication p = new PasswordAuthentication(user, pass.toCharArray());
	           // System.out.println("_________Hostname_______"+hostname);
	            return p;
	        }
	    }

		public static boolean connectivityCheck(String url,String username, String password, Boolean allowInvalidCerts) throws Exception{
			boolean connect=false;
			 int responseCode=0;
				try {
					if (allowInvalidCerts)
					{
							SSLUtilities.trustAllHttpsCertificates();
							SSLUtilities.trustAllHostnames();
					} 
						
				//try pinging the URL
				  HttpURLConnection connection=(HttpURLConnection) new URL(url).openConnection();
				  if (url.contains("https://"))
				  {
					  connection= (HttpsURLConnection) new URL(url).openConnection();					  
				  }
				  connection.setConnectTimeout(15000);
			      connection.setReadTimeout(15000);
			      connection.setRequestMethod("HEAD");
			      responseCode = connection.getResponseCode();
				}
			     //can't connect to internet
			      catch (Exception e) {
				  if (e.getMessage().contains("Network is unreachable"))
					{
						throw new Exception("Could not connect to the internet");
					}
					//handle possible invalid cert check
					else if (e.getMessage().toLowerCase().contains("SSLHandshakeException")) {
						if (allowInvalidCerts) {
							throw new Exception("Error connecting to " + url + ": SSHHandshakeException");
						} else {
							SSLUtilities.trustAllHttpsCertificates();
							SSLUtilities.trustAllHostnames();
							try {
							HttpsURLConnection connection = (HttpsURLConnection) new URL(url).openConnection();
							  connection.setConnectTimeout(15000);
						        connection.setReadTimeout(15000);
						        connection.setRequestMethod("HEAD");
						       responseCode = connection.getResponseCode();
							} catch (Exception e2) {
								throw new Exception("Error connecting to " + url + ": SSHHandshakeException");
							}
							throw new Exception(url +"'s Certificate is invalid.");
						}
					}
					//todo: handle authentication errors for non https connection
					else {
						throw new Exception("Could not connect to " + url);
					}
				}
				//able to connect, but invalid response code
				if (responseCode==401) {
					throw new Exception("user " + username + " is not authorized to access " + url);
				}
				else if ( ! (200 <= responseCode && responseCode <= 399)) {
					throw new Exception(url + " returned HTTP Response Code " + responseCode);
				}
				
				return true;
		}

	    static public boolean IsCJK(String input)
	    {
	    	Set<UnicodeBlock> cjkBlocks = new HashSet<UnicodeBlock>();     	
		    cjkBlocks.add(UnicodeBlock.CJK_COMPATIBILITY); 
		    cjkBlocks.add(UnicodeBlock.CJK_COMPATIBILITY_FORMS); 
		    cjkBlocks.add(UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS); 
		    cjkBlocks.add(UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS_SUPPLEMENT); 
		    cjkBlocks.add(UnicodeBlock.CJK_RADICALS_SUPPLEMENT); 
		    cjkBlocks.add(UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION); 
		    cjkBlocks.add(UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS); 
		    cjkBlocks.add(UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A); 
		    cjkBlocks.add(UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B); 
		    cjkBlocks.add(UnicodeBlock.KANGXI_RADICALS); 
		    cjkBlocks.add(UnicodeBlock.IDEOGRAPHIC_DESCRIPTION_CHARACTERS);    	    
		    
			StringBuffer sb=new StringBuffer(); 
			boolean lastcharspace=false;
			int i=0;
			for (char c : input.toCharArray()) 
			{    		    	
			    if (cjkBlocks.contains(UnicodeBlock.of(c))) { 
			    	return true;
			    }
			    	    	    
			} 
			return false;    	
	    }
	    //add spaces around any chinese characters in the input string 
	    static public String ProcessCJK(String input)
	    {
	    	Set<UnicodeBlock> cjkBlocks = new HashSet<UnicodeBlock>();     	
	    	    cjkBlocks.add(UnicodeBlock.CJK_COMPATIBILITY); 
	    	    cjkBlocks.add(UnicodeBlock.CJK_COMPATIBILITY_FORMS); 
	    	    cjkBlocks.add(UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS); 
	    	    cjkBlocks.add(UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS_SUPPLEMENT); 
	    	    cjkBlocks.add(UnicodeBlock.CJK_RADICALS_SUPPLEMENT); 
	    	    cjkBlocks.add(UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION); 
	    	    cjkBlocks.add(UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS); 
	    	    cjkBlocks.add(UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A); 
	    	    cjkBlocks.add(UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B); 
	    	    cjkBlocks.add(UnicodeBlock.KANGXI_RADICALS); 
	    	    cjkBlocks.add(UnicodeBlock.IDEOGRAPHIC_DESCRIPTION_CHARACTERS);    	    
	    	    
	    	StringBuffer sb=new StringBuffer(); 
	    	boolean lastcharspace=false;
	    	int i=0;
	    	for (char c : input.toCharArray()) {    		    	
	    	    if (cjkBlocks.contains(UnicodeBlock.of(c))) { 
	    	    	if (!lastcharspace && i > 0) {sb.append(" ");}
	    	    	sb.append(c).append(" ");    	    	
	    	    	lastcharspace=true;
	    	    } else {
	    	    	lastcharspace= c==' '?true:false;
	    	    	sb.append(c);
	    	    }
	    	    i++;    	    
	    	} 
	    	return sb.toString();
	    }
	    
	    static public void WriteReqError(HttpServletRequest request, String errorString)
	    {
	    	ArrayList<String> errors=new ArrayList<String>();
	    	if (request.getAttribute("errors") != null)
	    	{
	    		errors=(ArrayList<String>) request.getAttribute("errors");
	    	}
	    	errors.add(errorString);
	    	request.setAttribute("errors",errors);    	
	    }

	}
