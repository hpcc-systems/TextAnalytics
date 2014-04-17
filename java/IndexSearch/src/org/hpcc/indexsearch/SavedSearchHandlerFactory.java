package org.hpcc.indexsearch;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

/**
 * Get a SavedSearchHandler by type.
 */
public final class SavedSearchHandlerFactory {
	// This map is built lazy so that we don't end up with search handlers we're not going to use.
	private static Map<String,SavedSearchHandler> searchHandlers = new HashMap<String,SavedSearchHandler>();
	private static Logger logger = Logger.getLogger(SavedSearchHandlerFactory.class);
	
	/** Hide the constructor. */
	private SavedSearchHandlerFactory() {}
	
	public static SavedSearchHandler getHandler(String type, int size,HttpSession session) throws Exception {
		type = type.toLowerCase();
		SavedSearchHandler value = searchHandlers.get(type);
		if (value == null) {
			synchronized(searchHandlers) {
				value = searchHandlers.get(type);
				if (value == null) {
					logger.info("Creating Saved Search Handler of type: "+type);
					if ("inmemory".equals(type)) {
						value = new SavedSearchInMemoryHandler(size, session);						
					} 
					if (value != null) {
						logger.info("Saved Search Handler created for type: "+type);
						searchHandlers.put(type,value);
					}
				}
			}
		}
		else if ("inmemory".equals(type)) {
			SavedSearchInMemoryHandler vals=(SavedSearchInMemoryHandler) value;
			vals.setSession(session);
			return vals;
		}
		return value;
	}
	
	/**
	 * Calling this method will cause all saved searches for all
	 * users for all loaded persistence models to be deleted.
	 */
	public static void deleteSavedSearches() {
		for(SavedSearchHandler h:searchHandlers.values()) {
			h.deleteAllSavedSearches();
		}
	}

	/**
	 * Calling this method will cause all saved searches for the
	 * named user for all loaded persistence models to be deleted.
	 * @param distinguishedName
	 */
	public static void deleteSavedSearches(String distinguishedName) throws Exception {
		for(SavedSearchHandler h:searchHandlers.values()) {
			h.deleteUserSavedSearches(distinguishedName);
		}
	}
}
