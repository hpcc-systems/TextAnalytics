package org.hpcc.indexsearch;
import java.util.Comparator;

import org.hpcc.indexsearch.SavedSearchSummaryDTO;
import org.hpcc.indexsearch.SearchDTO;



	public class SavedSearchComparator implements Comparator<SavedSearchSummaryDTO>
	{
	   @Override
	   public int compare(SavedSearchSummaryDTO o1, SavedSearchSummaryDTO o2)
	   {
		   if (o2.getUpdateDate()==null || o1.getUpdateDate()==null) {return 0;}
		   return o2.getUpdateDate().compareTo(o1.getUpdateDate());
	   }
	}
