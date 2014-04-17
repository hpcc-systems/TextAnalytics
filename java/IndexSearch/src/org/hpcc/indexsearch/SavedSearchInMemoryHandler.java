package org.hpcc.indexsearch;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.hpcc.indexsearch.SavedSearchSummaryDTO;
import org.hpcc.indexsearch.SearchAction;
import org.hpcc.indexsearch.SearchDTO;




/**
 * Saved search handler that persists the saved searches to the database.
 */
public class SavedSearchInMemoryHandler implements SavedSearchHandler {

	private int size;
	private HttpSession session = null;
	private boolean isAlertInstance = false;


	SavedSearchInMemoryHandler(int size, HttpSession session) throws Exception{
		this.size=size;
		this.session=session;
	}

	public void setSession(HttpSession inSession) {
		this.session=inSession;
	}
	@Override
	public Collection<SavedSearchSummaryDTO> getSavedSearches(String distinguishedName) throws Exception {
	
		
		try {
			
			List<SavedSearchSummaryDTO> results=new ArrayList<SavedSearchSummaryDTO>();
			Object test=session.getAttribute("savedsearchsummaries");
			if (test != null) {
				results=(List<SavedSearchSummaryDTO>) test;
			}
			return results;
		} catch (Exception e)
		{
			String errMsg="Error Retrieving Saved Searches:" + e.getMessage();
			if (e.getCause() != null && !e.getCause().getMessage().equals(e.getMessage()))
			{
				errMsg=errMsg + " (" + e.getCause().getMessage() + ")";
			}
			throw new Exception(errMsg);
		} finally {
		}
	}
	
	@Override
	public List<SearchDTO> getSavedSearchesFullInfo(String distinguishedName) throws Exception {
		try {
			List<SearchDTO> results=new ArrayList<SearchDTO>();
			Object test=session.getAttribute("savedsearches");
			if (test != null) {
				results=(List<SearchDTO>) test;
			}
			return results;
		} catch (Exception e)
		{
			String errMsg="Error Retrieving Saved Searches:" + e.getMessage();
			if (e.getCause() != null && !e.getCause().getMessage().equals(e.getMessage()))
			{
				errMsg=errMsg + " (" + e.getCause().getMessage() + ")";
			}
			throw new Exception(errMsg);
		} finally {
		}
	}

	@Override
	public List<SavedSearchSummaryDTO> getSavedSearches(String distinguishedName,int numSearches) throws Exception {		
		
		try {
			List<SavedSearchSummaryDTO> results=new ArrayList<SavedSearchSummaryDTO>();
			Object test=session.getAttribute("savedsearchsummaries");
			if (test != null) {
				results=(List<SavedSearchSummaryDTO>) test;
			}
			Collections.sort(results, new SavedSearchComparator());

			List<SavedSearchSummaryDTO> results2=new ArrayList<SavedSearchSummaryDTO>();
			for (int i=0; i < results.size();i++)
			{
				if (i < numSearches) {
					results2.add(results.get(i));
				}
			}
		    return results2;	    
		} catch (Exception e)
		{
			String errMsg="Error Retrieving Saved Searches:" + e.getMessage();
			if (e.getCause() != null && !e.getCause().getMessage().equals(e.getMessage()))
			{
				errMsg=errMsg + " (" + e.getCause().getMessage() + ")";
			}
			throw new Exception(errMsg);
		} finally {			 
					}
	}
	
	public Integer findExistingSearch(SearchDTO searchDTO) throws Exception
	{
		List<SearchDTO> searches=getSavedSearchesFullInfo("");

		for (int i=0; i < searches.size(); i++ )
		{
			SearchDTO test=searches.get(i);
			if (test.getUniqueIdentifier().equals(searchDTO.getUniqueIdentifier())
					&& test.getCmdStackHash().equals(searchDTO.getCmdStackHash()) 
							&& test.getSourceStackHash().equals(searchDTO.getSourceStackHash()))
							{
						return test.getId();
							}
		}
		return 0;
	}

	@Override
    public SearchDTO addSavedSearch(String distinguishedName, SearchDTO searchDTO) throws Exception
    {

	try {
        // sanity check--don't save empty dtos if they make it here
        if (searchDTO.getCmdStackXml().equals("")
                && searchDTO.getSourcesAsString().equals("")
                && searchDTO.getCountriesAsString().equals(""))
        {
            return searchDTO;
        }
    
        // do not save if the command stack is longer then 64k or the sources are longer than 64k.
        int maxlength = 64*1024;
        if (searchDTO.getCmdStackXml().length() > maxlength
                || searchDTO.getSourcesAsString().length() > maxlength)
        {
            return searchDTO;
        }

        Integer existingSearchID = this.findExistingSearch(searchDTO);
        if (existingSearchID==null || existingSearchID == 0)
        {

            List<SearchDTO> searches= getSavedSearchesFullInfo("");
            searches.add(searchDTO);
            session.setAttribute("savedsearches", searches);
        } else
        {
            List<SearchDTO> searches= getSavedSearchesFullInfo("");
            for (int i=0; i < searches.size();i++) {
            	SearchDTO srch=searches.get(i);
            	if (srch.getId().equals(existingSearchID))
            	{
            		searchDTO.setUuid(srch.getUuid());
            		searchDTO.setId(srch.getId());
            		
                    srch.setUpdateDate(new Date());
                    srch.setNumTimesRun(searchDTO.getNumTimesRun()+1);
                    srch.setTotalResults(searchDTO.getTotalResults());            		
            	}
            }
            session.setAttribute("savedsearches", searches);
        }
     } catch (Exception e)
        {
            String result = "Error processing Search Results:" + e.getMessage() ;
        	if (e.getCause() != null)
			{
				if (e.getCause() instanceof InvocationTargetException)
				{
					InvocationTargetException ie=(InvocationTargetException) e.getCause();
					if (ie.getTargetException() != null 
							&& ie.getTargetException().getMessage()!= null 
							)
					{
						result=result + " (" + ie.getTargetException().getMessage() + ")";
					}
					ie.getTargetException().getMessage();
				}
				else {
					Exception e2=(Exception) e.getCause();
					if (e2.getMessage()!= null && !e2.getMessage().equals(e.getMessage()))
					{
						result=result + " (" + e2.getMessage() + ")";
					}
				}
			}
            StackTraceElement[] theStackTrace = e.getStackTrace();
            throw new Exception(result);
        } finally
        {
        }
		return searchDTO;
    }

	@Override
	public SearchDTO getSavedSearch(String distinguishedName, Integer uuid) throws Exception{
	    List<SearchDTO> searches= getSavedSearchesFullInfo("");
        for (int i=0; i < searches.size(); i++) {
        	if (searches.get(i).getId().equals(uuid)) {
        		return searches.get(i);
        	}
        }	  
        return null;
	}

	@Override
	public void deleteAllSavedSearches() {
		session.setAttribute("savedsearches", new ArrayList<SearchDTO>());
		
	}
	@Override
	public void updateCount(SearchDTO ss) throws Exception
	{
	
		try {
			

            List<SearchDTO> searches= getSavedSearchesFullInfo("");
            for (int i=0; i < searches.size();i++) {
            	SearchDTO srch=searches.get(i);
            	if (srch.getId().equals(ss.getId()))
            	{
                  
                    srch.setTotalResults(ss.getTotalResults());            		
            	}
            }
            session.setAttribute("savedsearches", searches);
		}
	    catch (Exception e)
        {
          
            String result = "Error updating count for search " + String.valueOf( ss.getId()) + ":" + e.getMessage() ;
        	if (e.getCause() != null)
			{
				if (e.getCause() instanceof InvocationTargetException)
				{
					InvocationTargetException ie=(InvocationTargetException) e.getCause();
					if (ie.getTargetException() != null 
							&& ie.getTargetException().getMessage()!= null 
							)
					{
						result=result + " (" + ie.getTargetException().getMessage() + ")";
					}
					ie.getTargetException().getMessage();
				}
				else {
					Exception e2=(Exception) e.getCause();
					if (e2.getMessage()!= null && !e2.getMessage().equals(e.getMessage()))
					{
						result=result + " (" + e2.getMessage() + ")";
					}
				}
			}
         
            throw new Exception(result);
        } finally
        {
          
        }
	}

	@Override
	public void deleteUserSavedSearches(String distinguishedName) throws Exception {
		session.setAttribute("savedsearches", new ArrayList<SearchDTO>());
	}

}
