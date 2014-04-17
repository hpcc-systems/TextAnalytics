package org.hpcc.indexsearch;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.UUID;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringEscapeUtils;
import org.hpcc.indexsearch.SavedSearchHandlerFactory;
import org.hpcc.indexsearch.util.DateUtility;
import org.hpcc.indexsearch.util.Utility;


@WebServlet("/SearchForm")
public class SearchAction extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static final String savedSearchPersistenceModel = "inmemory";
	private static final int SavedSearchesToShow = 10;
	private static  String contenttypequery = null;
	private static String RoxieServerURL="http://10.173.250.3:8002/";
	private static  String defaultStylesheet = "searchresults.xsl";
	private static  String defaultPageSize = "20";
	private static String stylesheetDir="/";
	private static String stylesheet="searchresults.xsl";
	private static String irsearchurl="wsAdHocSearchSimple?";
	private static String phraseirsearchurl="wsAdHocSearch?";
	private static String ctypes = null;
 
	protected boolean showForm=true;
	private String formName="/index.jsp";
	
	public void init(ServletConfig config) throws ServletException {
		
		//values in config/context.xml
	
		
		if (config.getInitParameter("FormName") != null){
			formName=config.getInitParameter("FormName");
		}

		if (config.getInitParameter("ShowForm") != null){
			showForm=Utility.parseBoolean(config.getInitParameter("ShowForm"));
		}
		if (config.getServletContext().getInitParameter("RoxieServerURL") != null){
			RoxieServerURL=config.getServletContext().getInitParameter("RoxieServerURL");
		}
		if (config.getServletContext().getInitParameter("defaultSearchResultsPageSize") != null){
			defaultPageSize=config.getServletContext().getInitParameter("defaultSearchResultsPageSize");
		}
		if (config.getServletContext().getInitParameter("EntityTypeQuery") != null){
			contenttypequery=config.getServletContext().getInitParameter("EntityTypeQuery");
		}
		if (config.getServletContext().getInitParameter("SearchQuery") != null){
			irsearchurl=config.getServletContext().getInitParameter("SearchQuery");
		}
		if (config.getServletContext().getInitParameter("PhraseSearchQuery") != null){
			phraseirsearchurl=config.getServletContext().getInitParameter("PhraseSearchQuery");
		}
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);		
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

	    
		response.setCharacterEncoding("UTF-8");

		request.setAttribute("roxieURL",RoxieServerURL);		
	
		 // Get the searchDTO
		 SearchDTO searchDTO = prepareSearchDTO(request, response);
		 
	//	Object res=searchDTO.getAndItems();
		try {
			if (showForm)
			{					
				RequestDispatcher dispatcher = request.getSession().getServletContext().getRequestDispatcher(formName);
				dispatcher.forward(request, response);
				return;
			} 
		} 	catch (Exception exp) {
				StackTraceElement[] theStackTrace = exp.getStackTrace();
				
				Utility.WriteReqError(request,"Error Navigating to Search Form:" + exp.getMessage());
				
				RequestDispatcher dispatcher = request.getSession().getServletContext().getRequestDispatcher(formName);
				dispatcher.forward(request, response);
				return;
		}
		
		try {			
			searchDTO=doSearch(request,searchDTO);	
						
			//if there's an error or no search results, forward to form
			if (Utility.hasErrors(request) || (formName.contains("ir.") 
					&& searchDTO.getClusterID().equals("0") 
					&& searchDTO.isGetRelationships()==false
			        && searchDTO.getCurrentXMLResult().equals("")))
            {
				
				   if(searchDTO.getOutputFormat().equalsIgnoreCase("ajax"))
				    {
				        String errorString = Utility.getErrorsAsXml(request);
				        response.getWriter().write(errorString);
				    }
				    else
				    {
	        		    RequestDispatcher dispatcher = request.getSession().getServletContext().getRequestDispatcher(formName);
					    dispatcher.forward(request, response);
				    }
				   return;
				}
				   					
			
		} catch (Exception exp)
		{
			StackTraceElement[] theStackTrace = exp.getStackTrace();
			
			Utility.WriteReqError(request,"Error Performing Search:" + exp.getMessage());
			RequestDispatcher dispatcher = request.getSession().getServletContext().getRequestDispatcher(formName);
			dispatcher.forward(request, response);
			return;
		}
		
        doOutput(request, response, searchDTO);
		
	}

	private void doOutput(HttpServletRequest request, HttpServletResponse response, SearchDTO searchDTO) throws IOException, ServletException
	{
        String outputType = searchDTO.getOutputFormat();
        try
        {
            if (outputType.equalsIgnoreCase("html"))
            {
                doHTMLOutput(request, response, searchDTO);
            } else if (outputType.equalsIgnoreCase("ajax"))
            {
                doAjaxOutput(request, response, searchDTO);
            }  else
            {
                response.getWriter().write(searchDTO.getCurrentXMLResult());
            }
        } catch (Exception exp)
        {
            StackTraceElement[] theStackTrace = exp.getStackTrace();
         
            Utility.WriteReqError(request, "Error processing Search Results:" + exp.getMessage());
           
            if (outputType.equals("ajax"))
            {
                response.getWriter().write(exp.getMessage());
            } else
            {
                RequestDispatcher dispatcher = request.getSession().getServletContext().getRequestDispatcher(formName);
                dispatcher.forward(request, response);
            }
           
            return;
        }

        return;
	}
	
	 private void doHTMLOutput(HttpServletRequest request, HttpServletResponse response, SearchDTO searchDTO) throws Exception
	    {
	        long transformstart = System.currentTimeMillis();
	        String transformstylesheetDir=stylesheetDir.replace(request.getSession().getServletContext().getContextPath(),"");
	        if (searchDTO.isDebug())
	        {   
	            request.setAttribute("commandstackxml", StringEscapeUtils.escapeXml(searchDTO.getCmdStackXml()));
	            request.setAttribute("postdata", StringEscapeUtils.escapeXml(searchDTO.getPostData()));
	            request.setAttribute("sourcelistxml", StringEscapeUtils.escapeXml(searchDTO.getSourceXml()));
	            request.setAttribute("searchresultxml", StringEscapeUtils.escapeXml(searchDTO.getCurrentXMLResult()));
	        } 
	        
	       String res=searchDTO.getCurrentXMLResult();
	        res=res.replace("xmlns=\"urn:hpccsystems:ecl:wsadhocsearch:result:matching_records\"", "");
	        res=res.replace("xmlns=\"urn:hpccsystems:ecl:wsadhocsearchsimple:result:matching_records\"", "");
	        String results=Utility.transformXML(res
	                , transformstylesheetDir + stylesheet
	                , request.getSession().getServletContext());  
	        request.setAttribute("searchResults",results);
	     
	        request.setAttribute("showResults","true"); 
	        if (searchDTO.getShowSearchForm())
	        {
	            RequestDispatcher dispatcher = request.getSession().getServletContext().getRequestDispatcher(formName);
	            dispatcher.forward(request, response);
	            return;
	        } 
	        else
	        {
	            RequestDispatcher dispatcher = request.getSession().getServletContext().getRequestDispatcher("/searchResultsOnly.jsp");
	            dispatcher.forward(request, response);
	            return;
	        }
	    }
	    private void doAjaxOutput(HttpServletRequest request, HttpServletResponse response, SearchDTO searchDTO) throws Exception
	    {
	        long transformstart = System.currentTimeMillis();
	        String transformstylesheetDir=stylesheetDir.replace(request.getSession().getServletContext().getContextPath(),"");          
	        String results=Utility.transformXML(searchDTO.getCurrentXMLResult()
	                , transformstylesheetDir + stylesheet
	                , request.getSession().getServletContext());  
	       
	        response.getWriter().write(results);
	        return;
	    }
	protected SearchDTO prepareSearchDTO(
			HttpServletRequest request, HttpServletResponse response
			)
		throws ServletException, IOException
	{
		// Make sure this hasn't already been done
		if (request.getAttribute("searchDTO") != null) {
			return (SearchDTO)request.getAttribute("searchDTO");
		}		
		// Build the search data object
		SearchDTO searchDTO = new SearchDTO();
		request.setAttribute("searchDTO",searchDTO);
		searchDTO.setDebug(Utility.parseBoolean(Utility.getParameter(request,"debug","","false")));
		boolean refreshProfile=Utility.parseBoolean(Utility.getParameter(request,"refreshProfile","","false"));
		
		try {
			searchDTO.setOutputFormat(Utility.getParameter(request, "outputFormat", "", "html"));	
			if (showForm==true || searchDTO.getOutputFormat().equalsIgnoreCase("html"))
			{
				searchDTO=prepForm(request,searchDTO);
			}

		} 	catch (Exception exp) {
			StackTraceElement[] theStackTrace = exp.getStackTrace();
			exp.printStackTrace();
			return searchDTO;
		}
		 
		try {
		    // These need to be set before the search is called
		    // ubarsmx 2012-02-09

            searchDTO.setRemoteIP(request.getRemoteAddr());         
            searchDTO.setRoxieServerURL(RoxieServerURL);   

            if (Utility.getParameter(request, "savedsearch", "").equalsIgnoreCase("true")) {
				searchDTO = getSavedSearch(request, searchDTO);
				// if any errors occurred during the search request, return
				if (Utility.hasErrors(request)) {
					return searchDTO;
				}
			} else {
				searchDTO.setUuid(UUID.randomUUID().toString());
				Double temp=Math.random()*1000;
				
				searchDTO.setId(temp.intValue());
				searchDTO.setDateRange(Utility.getParameter(request, "dateRange", "", ""));
				searchDTO.setBeginDate(Utility.getParameter(request, "begindate", "", ""));
				searchDTO.setEndDate(Utility.getParameter(request, "enddate", "", ""));
				searchDTO.setLastXDays(Utility.getParameter(request, "xdays", "", ""));

				
				searchDTO = getCommandStacks(request, searchDTO);
				

				String eclURL = "";

				

				searchDTO.setBatch(false);
				searchDTO.setAdvanced(false);

				searchDTO.setEclURL(eclURL);
			}
            // set these the same way for saved searches or regular searches
            // get offset
            searchDTO.setPage(Integer.valueOf(Utility.getParameter(request, "page", "", "1")));

            searchDTO.setPageSize(Integer.valueOf(Utility.getParameter(request, "pageSize", "", String.valueOf(defaultPageSize))));
            searchDTO.setOffset((Integer.valueOf(searchDTO.getPage()) - 1) * Integer.valueOf(searchDTO.getPageSize()) + 1);
            String stylesheet = Utility.getParameter(request, "stylesheet", "", defaultStylesheet);
            
		    
		} catch (Exception e) {			
			e.printStackTrace();			
		}

		request.setAttribute("searchDTO",searchDTO);
		return searchDTO;
	}
    

    private SearchDTO prepForm(HttpServletRequest request,SearchDTO searchDTO) throws Exception
    {
    	boolean clearsession= request.getParameterMap().containsKey("clearsession");
    	boolean clearsavedsearches= request.getParameterMap().containsKey("clearsavedsearches");
    	boolean refreshdmt= request.getParameterMap().containsKey("refreshdmt");
    	searchDTO.setRoxieServerURL(RoxieServerURL);
        if (clearsession)
        {
        	for (Object name : Collections.list(request.getSession().getAttributeNames())) {
        		request.getSession().removeAttribute((String)name);
        	}
        }
        
        
        Object contentTypes = request.getSession().getAttribute("ContentTypes");
        
        if (contentTypes == null)
        {
            if (ctypes == null || ctypes == "" || clearsession)
            {
                String cresult = "";
                try
                {
                    String currRoxieUrl = searchDTO.getRoxieServerURL();
                    if(currRoxieUrl == null || currRoxieUrl.length() == 0){
                        currRoxieUrl = RoxieServerURL;
                    }
                    cresult = Utility.processRequest(RoxieServerURL + contenttypequery, "");
                } catch (Exception e){}

                ctypes = Utility.getNodeValue(cresult, "optionTypes");
                ctypes = ctypes.replace("<Item>", "");
                ctypes = ctypes.replace("</Item>", "");
                ctypes = ctypes.replace("<optionTypes>", "");
                ctypes = ctypes.replace("</optionTypes>", "");
                ctypes = ctypes.replace("&lt;", "<");
                ctypes = ctypes.replace("&gt;", ">");
            }
            
            request.getSession().setAttribute("ContentTypeList", ctypes);
        }

        searchDTO.setAllContentTypes("<option value=\"\">All Types</option>" + ctypes);
     /*   
        searchDTO.addItem(new CDCESearchItem("","",false,searchDTO.getAllContentTypes(),""),"and");
		searchDTO.addItem(new CDCESearchItem("","",false,searchDTO.getAllContentTypes(),""),"or");
		searchDTO.addItem(new CDCESearchItem("","",false,searchDTO.getAllContentTypes(),""),"exclude");
		searchDTO.addItem(new CDCESearchItem("","",false,searchDTO.getAllContentTypes(),""),"batch");
		for (int i=0; i < 3; i++)
    	{
            searchDTO.addItem(new CDCESearchItem("","",false,searchDTO.getAllContentTypes(),"display:none"),"and");
    		searchDTO.addItem(new CDCESearchItem("","",false,searchDTO.getAllContentTypes(),"display:none"),"or");
    		searchDTO.addItem(new CDCESearchItem("","",false,searchDTO.getAllContentTypes(),"display:none"),"exclude");    		
    	}    	
    	*/
		searchDTO.setLabel(Utility.getParameter(request,"customlabel","",""));
		searchDTO.setShowSearchForm(Utility.parseBoolean(Utility.getParameter(request,"showsearchform","","true")));
		searchDTO.setOutputFormat("html");
		
		SavedSearchHandler ssh = SavedSearchHandlerFactory.getHandler(savedSearchPersistenceModel, SavedSearchesToShow,request.getSession());
    	try {
		if (clearsavedsearches)
    	{
    		ssh.deleteUserSavedSearches(searchDTO.getUniqueIdentifier());
    		request.getSession().setAttribute("savedsearches",new ArrayList<SearchDTO>());
    	}
    	else {
    		if (request.getSession().getAttribute("savedsearches")==null)
    		{
    			Collection<SavedSearchSummaryDTO> coll=ssh.getSavedSearches(searchDTO.getUniqueIdentifier(),SavedSearchesToShow);
    			request.getSession().setAttribute("savedsearches", coll);
    		}
    	}
    	} catch (Exception e) { //TODO: handle session invalidation
    		
    	}
		return searchDTO;
		//populate data needed by search form(s) (dropdown values, etc)		
	}
	
	public SearchDTO doSearch(HttpServletRequest request,SearchDTO searchDTO) throws ServletException, IOException {
	     	
		request.setAttribute("errors",new ArrayList<String>());
				
		try {	
            searchDTO = ProcessRequest(request, searchDTO);
        } catch (Exception e) {
        	//nothing to do here; request processing errors saved in request object in ProcessRequest()
           
        	return searchDTO;
        } 
		
        //if any errors occurred during the search request, return
        if (Utility.hasErrors(request))
        {
    		return searchDTO;
        }
        try {
        
        SavedSearchHandler ssH = SavedSearchHandlerFactory.getHandler(savedSearchPersistenceModel, SavedSearchesToShow,request.getSession());
        
        searchDTO=ssH.addSavedSearch(searchDTO.getUniqueIdentifier(),searchDTO);
        } catch (Exception e) {
        	Utility.WriteReqError(request, "Error adding saved search:" + e.getMessage());
			return searchDTO;
        }
        
		if (searchDTO.getOutputFormat().equalsIgnoreCase("html"))
		{									
			try {
              
               //reload command stack to get actual search string/regex that was used
				if (!searchDTO.getCmdStackXml().equals("")) {
				
		             BitmapCommandStack cmdStack=new BitmapCommandStack(request.getSession());
		     		 cmdStack.LoadFromXML(searchDTO.getCmdStackXml());
		     		 searchDTO.setSearchstring(cmdStack.toBooleanSearchString());
		     		 searchDTO.setRegexsearchwords(cmdStack.getRegexWords());
		     		searchDTO.setCJKRegexsearchwords(cmdStack.getCJKRegexWords());
		     		Highlight.highlightResults(searchDTO);
				}
			}	catch (Exception e)
			{
				String result="Error processing Search Results:" + e.getMessage();
				e.printStackTrace();
			}
		}
	
		return searchDTO;
	}
	
	private SearchDTO ProcessRequest(HttpServletRequest request, SearchDTO searchDTO) throws Exception
	{

	    String postData="<wsadhocsearchRequest>";
	    postData=postData + searchDTO.getCmdStackXml();
	    postData=postData + "<pagesize>" + String.valueOf(searchDTO.getPageSize()+1) + "</pagesize>";
	    postData=postData + "<offset>" + String.valueOf(searchDTO.getOffset()) + "</offset>";
	    postData=postData + "</wsadhocsearchRequest>";
//      			
//	    postData=postData +   URLEncoder.encode(searchDTO.getCmdStackXml(),"UTF-8");
		//<sourceset><Row><source/></Row></sourceset>
	    //<excludesourceset><Row><source/></Row></excludesourceset>
	   
	    searchDTO.setPostData(postData);
		
        String uiElement = Utility.getParameter(request,"ui","",request.getRemoteHost());
 
		
		 long startTime = Calendar.getInstance().getTimeInMillis();        
		 String result="";		 
	     
	     String initResult="";
	     try {
		
	        boolean dedupresults = true;


        	initResult = Utility.processRequest(RoxieServerURL + irsearchurl 
        			,"_boxFormInput=" + URLEncoder.encode(postData,"UTF-8"));
           
        	searchDTO.setCurrentXMLResult(initResult);
        	if (initResult.contains("<Exception>") || initResult.contains("WS-ECL Error"))
        	{
        		String exp=Utility.getNodeValue(initResult,"//Exception");
        		if (exp.equals("") && initResult.contains("<body>"))
        		{
        			exp=Utility.getNodeValueString(initResult,"body");
        		}
        		Utility.WriteReqError(request,exp);
        		return searchDTO;
        	}        	
	     } 
	     catch (Exception e)
	     {
	    	 result="Error processing url request:" + e.getMessage();
	    	 System.out.println(result);
	    	 e.printStackTrace();
	    	 return searchDTO;
	     }
        
      
        
	   
	     try {
	    	 /* onsite
	    	 FilterUserAccess filterAccess=PassThrough.getFilterAccess(request);
	    	 if (filterAccess != null)
	    	 {
	    		 userAccessList.add(filterAccess);
	    	 }
	    	 */
	       
             boolean wrapWithXML=true;
            
             String ret = Utility.getNodeValue(initResult, "//Dataset[@name='Matching_Records']");
             
    		 //get the number of records; determine if there's more than one page
    		 int numRecs=0;
    		 String numresults=Utility.getNodeValue(initResult,"//NumResults");
    		 try {
    			 numRecs= Integer.valueOf(numresults);
    		 } catch (Exception e) {
    			 
    		 }
    		 		 
 			 if (numRecs > (searchDTO.getPage() * searchDTO.getPageSize()))
 			 {
 				searchDTO.setNumResults(Integer.valueOf(searchDTO.getPageSize()));
 				searchDTO.setMoreResults(true);
 			 }
 			 else {
 				searchDTO.setNumResults(numRecs);
 				searchDTO.setMoreResults(false);
 			 }

             //retrieve the actual command stack used for this search
             String cmdStackXml=Utility.getNodeValue(initResult, "//Dataset[@name='CommandStack']");
             cmdStackXml=cmdStackXml.replace("<Dataset", "<commandstack");
             cmdStackXml=cmdStackXml.replace("</Dataset", "</commandstack");
             searchDTO.setCmdStackXml(cmdStackXml);
             	     
	         searchDTO.setCurrentXMLResult("<result>" + ret + "</result>");	         

	     }
	     catch (Exception e)
	     {
	    	e.printStackTrace();
	     }

         return searchDTO;
	}

	public static SearchDTO getCommandStacks(HttpServletRequest request, SearchDTO searchDTO) throws Exception
	{
		BitmapCommandStack cmdStack=new BitmapCommandStack(request.getSession());
		searchDTO.getItems().clear();
		
			
            String andvalues = getCommandStackParameters(request, searchDTO, "");
            if (andvalues != null && andvalues != "")
            {
                cmdStack.AddWordList(andvalues,
                        BitmapCommandStack.CommandType.AND_OPCODE_NUM);
            }
		    
            String orValues = getCommandStackParameters(request, searchDTO, "or");
            if (orValues != null && orValues != "")
            {                       
                cmdStack.AddWordList(orValues, "",
                        BitmapCommandStack.CommandType.OR_OPCODE_NUM,
                        BitmapCommandStack.CommandType.AND_OPCODE_NUM, false);
            }

            String excludeValues = getCommandStackParameters(request, searchDTO, "exclude");
            if (excludeValues != null && excludeValues != "")
            {
                cmdStack.AddWordList(excludeValues,
                        BitmapCommandStack.CommandType.OR_OPCODE_NUM,
                        BitmapCommandStack.CommandType.AND_NOT_OPCODE_NUM);
            }
            
            if (searchDTO.getDateRange() != null && !searchDTO.getDateRange().trim().equals(""))
            {
            		// Can't alert if there's a date range as part of the search.
            		searchDTO.setAlertable(false);
            		
            		Date begindate=null;
            		Date enddate=null;
            		DateUtility.DateRange rng=null;
            		
            		try {
            			rng=DateUtility.DateRange.valueOf(searchDTO.getDateRange().trim());
            		}
            		catch (Exception e2)
                	{
                
                	}
        			
            		if (rng.equals(DateUtility.DateRange.THIS_MONTH))
            		{
            			begindate=DateUtility.FirstDayOfMonth();
            			enddate=new Date();
            		}
            		else if (rng.equals(DateUtility.DateRange.THIS_WEEK))
            		{
            			begindate=DateUtility.FirstDayOfWeek();
            			enddate=new Date();
            		}
            		else if (rng.equals(DateUtility.DateRange.THIS_YEAR))
            		{
            			begindate=DateUtility.FirstDayOfYear();
            			enddate=new Date();
            		}
            		else if (rng.equals(DateUtility.DateRange.AFTER))
            		{
            			try {
            				begindate=DateUtility.ParseDate(searchDTO.getBeginDate(), null);
            				enddate=new Date();
            			} catch (Exception e2) {
            				e2.printStackTrace();
            			}
            		}
            		else if (rng.equals(DateUtility.DateRange.BETWEEN))
            		{
            			try {
            				begindate=DateUtility.ParseDate(searchDTO.getBeginDate(), null);
            			} catch (Exception e2) {
            				e2.printStackTrace();
            			}
            			try {
            				enddate=DateUtility.ParseDate(searchDTO.getEndDate(), null);            				
            			} catch (Exception e2) {
            				e2.printStackTrace();
            			}
            		}
            		else if (rng.equals(DateUtility.DateRange.IN_THE_LAST_X_DAYS))
            		{
            			try {
            				int daysago=Integer.parseInt(searchDTO.getLastXDays());
            				begindate=DateUtility.DaysAgo(daysago);
            				enddate=new Date();
            			} catch (Exception e2) {
            				e2.printStackTrace();
            			}            		
            		}
            		String edfsOrDates="";
            		ArrayList<String> edfsDates=DateUtility.GetEDFSDateRange(begindate,enddate);
            		for(String dt:edfsDates)
            		{
            			edfsOrDates=edfsOrDates + dt + " ";
            		}
            		
            		cmdStack.AddWordList(edfsOrDates, "UPDATEDATE",
                    BitmapCommandStack.CommandType.OR_OPCODE_NUM,
                    BitmapCommandStack.CommandType.AND_OPCODE_NUM, false);
            }
        	if (cmdStack._commands!=null && cmdStack._commands.size() > 0)
    		{
    			searchDTO.setCmdStackXml(cmdStack.ToEDFSXml());
    			searchDTO.setSearchstring(cmdStack.toBooleanSearchString());

    		}
//    		if (searchDTO.isBatch())
//    		{
//    		    searchDTO.setRoxieQueryUrl(asyncIRSearchURL);
//    		}
        	if (cmdStack.containsPhrases())
    		{
    			searchDTO.setRoxieQueryUrl(phraseirsearchurl);
    		}
    		else {
    			searchDTO.setRoxieQueryUrl(irsearchurl);
    		}
    		
    		return searchDTO;
            
		}
            

            public static String getCommandStackParameters(HttpServletRequest request, SearchDTO searchDTO, String valueClass) throws Exception
        	{
        	    String valueParameter = valueClass + "value";
        	    String typeParameter = valueClass + "type";
        	    String synonymParameter = valueClass + "synonym";
                String[] values = request.getParameterValues(valueParameter);
                if (values != null && values.length > 0)
                {
                    String[] types = new String[] { "", "", "", "" };
                    if (request.getParameterMap().containsKey(typeParameter))
                    {
                        types=request.getParameterValues(typeParameter);
                    };
                    if (values.length > types.length)
                    {
                        throw new Exception("search form values and types array must be the same length");
                    }
                    String[] synonyms = {
                            Utility.getParameter(request, synonymParameter + "0", ""),
                            Utility.getParameter(request, synonymParameter + "1", ""),
                            Utility.getParameter(request, synonymParameter + "2", ""),
                            Utility.getParameter(request, synonymParameter + "3", ""), };
                    //add form data to dto
                    for (int i = 0; i < values.length; i++)
                    {
                        values[i] = prepSearchString(values[i]);
                        SearchDTOItem item = new SearchDTOItem(values[i], types[i],
                                Utility.parseBoolean(synonyms[i]), searchDTO.getAllContentTypes(), "");
                        if (item.getValue().equals("") && i > 0)
                        {
                            item.setDisplay("display:none");
                        }
                        if (valueClass.equals(""))
                        {
                        searchDTO.addItem(item, "and");
                        } else {
                            searchDTO.addItem(item, valueClass);                        	
                        }
                    }
                    
                    String returnValues = CreateBitmapValueString(values,types,synonyms);
                    return returnValues;
                }
        	    return null;
        	}
        	
        	public static String prepSearchString(String input)
        	{
        		String value=input;
        		try {
        			value=new String(input.toString().getBytes("ISO-8859-1"), "UTF-8");
        		} catch (Exception e) {}
                value = value.replace(")", " ").trim();
                value = value.replace("(", " ").trim();
                value = value.replace("\r\n", " ").trim();
                value = value.replace("\n", " ").trim();
                value = value.replace("\t", " ").trim();
                value = value.replaceAll("[+,;()\\[\\]\\{}!\\&<>\\^]", " ").trim(); // see ConceptRetrieval.utils.fixCharacters
                value = value.replaceAll("[$#%]", "").trim(); // see ConceptRetrieval.utils.fixCharacters
        //        value = Utility.ProcessCJK(value); // add spaces between chinese chars
                return value;
        	}
        	public static String CreateBitmapValueString(String[] values, String[] types, String[]synonyms)
        	{		
        		String finalValue = "";
        		for (int i=0;i < values.length; i++)
        		{			
        			 String value=values[i].trim();
        		     if (value.equals(""))
        		     {
        		    	 continue;
        		     }
        		     
        		     //if this is one word surrounded by quotes, strip them off
        		     if (value.length() > 1 && value.startsWith("\"") && value.endsWith("\"") 
        		    		 && !value.substring(1,value.length()-1).trim().contains(" "))		    	
        		     {
        		    	 value=value.substring(1,value.length()-1).trim();		    	 
        		     }
        		     //if there's only one quote at the beginning of a string, strip it off
        		     else if (value.length() > 1 && value.startsWith("\"") && value.indexOf("\"",1)==-1)
        		     {		    	 
        		    	 value=value.substring(1,value.length()).trim();		    	 
        		     }
        		     if (value.length() > 3 && value.substring(0,2).equals("\" "))
        	    	 {
        	    		 value="\"" + value.substring(2,value.length());
        	    	 }
        	    	 if (value.length() > 3 && value.substring(value.length()-2,value.length()).equals(" \""))
        	    	 {
        	    		 value= value.substring(0,value.length()-2) + "\"";
        	    	 }

        		     String type=types.length > i-1?types[i]:"";
        		     boolean synonym=synonyms[i].equals("1")?true:false;		     
        		     String[] splitvals=value.split(" ");
        		     for (int j=0; j < splitvals.length; j++)
        		     {
        		    	 if (splitvals[j].trim().equals("")) {continue;}
        		    	 
            			 boolean beginPhrase=false;
            			 boolean endPhrase=false;
            			 boolean connector=false;
            			 String thisVal=splitvals[j].trim();
            			 // TODO: Show Drea and Eric 2012-02-03
            			 // values are xmlencoded, need to decode quotes
            			 thisVal = thisVal.replace("&quot;", "\"");
                         thisVal = thisVal.replace("&QUOT;", "\"");
            			 if (thisVal.startsWith("\""))
            			 {
            				 beginPhrase=true;
            			 }
            			 if (thisVal.endsWith("\""))
            			 {
            				 endPhrase=true;
            			 }
        				 thisVal=thisVal.replace("\"","");
            			 if (thisVal.equalsIgnoreCase("OR") || thisVal.equalsIgnoreCase("AND") || thisVal.equalsIgnoreCase("NOT"))
            			 {
            				 connector=true;
            			 }
            			 
            			 thisVal=thisVal.trim();
        	    		 if (!thisVal.equals("")) {
        	    			 if (!connector)
        	    			 {
        	    				thisVal=BitmapCommandStack.CreateCompositeValue(type,thisVal,synonym);
        	    				
        	    			 }
        	    			 if (synonym)
        	    			 {
        	    				 thisVal="(" + thisVal + ")";
        	    			 }
        	    			 if (beginPhrase)
        	    			 {
        	    				 thisVal="\"" + thisVal;
        	    			 }
        	    			 if (endPhrase)
        	    			 {
        	    				 thisVal=thisVal + "\"";
        	    			 }    			 
        	    			 finalValue=finalValue + " " + thisVal;
            			 }
        		    }				  		     
        		}
        		return finalValue.trim();
        	}
            
            public SearchDTO getSavedSearch(HttpServletRequest request,SearchDTO searchDTO)
            {
        			String uuid=Utility.getParameter(request,"searchuuid","");
        			if (uuid.equals(""))
        			{
        				Utility.WriteReqError(request, "No ID given for saved search");
        				return searchDTO;
        			}
        			try {
        				int idnum=Integer.valueOf(uuid);
        				SearchDTO ss=SavedSearchHandlerFactory.getHandler(savedSearchPersistenceModel, SavedSearchesToShow, request.getSession()).getSavedSearch(searchDTO.getUniqueIdentifier(),idnum);
        				if (ss==null)
        				{
        					Utility.WriteReqError(request, "search with Saved Search ID " + uuid + " does not exist for user " + String.valueOf(searchDTO.getDistinguishedName()));
        					return searchDTO;
        				} 
        				else {
        					searchDTO.setCmdStackXml(ss.getCmdStackXml());
        					searchDTO.setEclURL(ss.getEclURL());
        					searchDTO.setSourceXml(ss.getSourceXml());
        					searchDTO.setBatch(ss.isBatch());
        					searchDTO.setAdvanced(ss.isAdvanced());
        					searchDTO.setAlert(ss.isAlert());
        					searchDTO.setPage(ss.getPage());
                            searchDTO.setPageSize(ss.getPageSize());
        					searchDTO.setOffset(ss.getOffset());
        					// When getting saved search we should be able to change the output format
        					//searchDTO.setOutputFormat(ss.getOutputFormat());
        					searchDTO.setGroupByElement(ss.getGroupByElement());
        					searchDTO.setItems(ss.getItems());
        					searchDTO.setDateRange(ss.getDateRange());
        					searchDTO.setBeginDate(ss.getBeginDate());
        					searchDTO.setEndDate(ss.getEndDate());
        					searchDTO.setLastXDays(ss.getLastXDays());
        					//searchDTO.setRegexsearchwords(ss.getRegexsearchwords());
        					//searchDTO.setCJKRegexsearchwords(ss.getCJKRegexsearchwords());
        					searchDTO.setSearchstring(ss.getSearchstring());
        					searchDTO.setSourcegroups(ss.getSourcegroups());
        					searchDTO.setCountries(ss.getCountries());
        					searchDTO.setSources(ss.getSources());
        					searchDTO.setSelectedSourceOptions(ss.getSelectedSourceOptions());
        					searchDTO.setId(ss.getId());
        					searchDTO.setUuid(ss.getUuid());
        					String isclustered = ss.isClustered()?"1":"0";
        					searchDTO.setClustered(Utility.parseBoolean( Utility.getParameter(request, "clustered", "", isclustered) ));
        					searchDTO.setTotalResults(ss.getTotalResults());
        					searchDTO.setCurrentXMLResult(ss.getCurrentXMLResult());
        					searchDTO.setCreateDate(ss.getCreateDate());
        					searchDTO.setUpdateDate(ss.getUpdateDate());
        					/*if (searchDTO.isCountOnly()) {
        	        			searchDTO.setRoxieQueryUrl(countIRSearchUrl);
        	        			searchDTO.setEclURL(searchDTO.getRoxieServerURL() + searchDTO.getRoxieQueryUrl()
                                 + "?format_=xml&noschemas_=true");
        	        		}*/
        				}
        			} catch(Exception e)
        			 {
        				 String result= "Error retrieving saved search:" + e.getMessage();
        				 Utility.WriteReqError(request,result);
        				 e.printStackTrace();
        			     return searchDTO;
        			 }
        			//load saved search data into current search DTO
        			
        			return searchDTO;
            }

}
