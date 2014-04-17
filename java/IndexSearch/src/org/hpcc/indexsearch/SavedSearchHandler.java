package org.hpcc.indexsearch;

import java.util.Collection;

import org.hpcc.indexsearch.SavedSearchSummaryDTO;
import org.hpcc.indexsearch.SearchDTO;


/**
 * Interface that defines the operations available for
 * saving searches.
 */
public interface SavedSearchHandler {
	public Collection<SavedSearchSummaryDTO> getSavedSearches(String distinguishedName) throws Exception;
	public Collection<SearchDTO> getSavedSearchesFullInfo(String distinguishedName) throws Exception;
	public Collection<SavedSearchSummaryDTO> getSavedSearches(String distinguishedName, int numSearches) throws Exception;
	public SearchDTO addSavedSearch(String distinguishedName,SearchDTO ss) throws Exception;
	public SearchDTO getSavedSearch(String distinguishedName, Integer uuid) throws Exception;
	public void deleteAllSavedSearches();
	public void updateCount(SearchDTO dto) throws Exception;
	public void deleteUserSavedSearches(String distinguishedName) throws Exception;
}
