package org.hpcc.indexsearch;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.lang3.StringUtils;



/**
 * This class holds the data for searches.
 * 
 * NOTE: If saved searches are being persisted to disk or database
 * then changes to this class (adding or removing fields) can cause
 * changes to be needed in the SavedSearchHandler implementations
 * to persist or stop persisting those fields.
 */
public class SearchDTO implements Serializable {

	private static final long serialVersionUID = -9674173749431805L;

	public enum SearchDataType{
			SEARCH_RESULTS, 
			BROWSE_SOURCE, 
			VIEW_RELATIONSHIPS, 
			VIEW_CLUSTER
	 }
			
	private String eclURL="";
	private String roxieQuery="";

	private String cmdStackXml="";
	private String sourceXml="";
	private String excludeSourceXml="";
	
	
	private String distinguishedName="";
	private boolean debug=false;
	private int pageSize=20;
	private int offset=0;
	private int page=1;
	private String groupByElement="record_id";
	private Integer id=0;
	private String currentXMLResult="";
	private boolean isBatch=false;
	private boolean isAdvanced=false;
	private boolean isAlert=false;
	private boolean isAlertable=true;
	private String searchstring="";
	private String remoteIP="";
	private String outputFormat="html";
	private boolean moreResults=false;
	private Integer numResults=0;
	private String allContentTypes="";
	private Set<SearchDTOItem> items=new TreeSet<SearchDTOItem>();	;
	//private String batchortype="";
	private ArrayList<String> countries=new ArrayList<String>();
	private ArrayList<String> sourcegroups=new ArrayList<String>();
	private ArrayList<String> sources=new ArrayList<String>();
	private ArrayList<String> excludeSources=new ArrayList<String>();
	private ArrayList<String> selectedsourceoptions=new ArrayList<String>();	
	private String allCountries="";
	private String allSourceGroups="";
	private String allSources="";
	private String clusterID="0";
	private Date createDate = new Date();
    private boolean browseRelationships = false;
	private boolean getRelationships=false;
    private boolean getSingleRecord=false;
	private HashMap<String,String> allSourceList=new HashMap<String,String>();
	private ArrayList<String> regexsearchwords=new ArrayList<String>();
	private ArrayList<String> cjkregexsearchwords=new ArrayList<String>();	
	private boolean clustered=false;
	private Date updateDate=new Date();
	private String roxieServerURL="";
	private String dateRange="";
	private String beginDate="";
	private String endDate="";
	private String lastXDays="";
	private String uuid="";
	private boolean countOnly=false;
	private Integer numTimesRun;
	private String searchResultSources;
	private Integer totalResults=0;
	private Date priorUpdate;
	private boolean deleted=false;
	private String customlabel="";
	private boolean showSearchForm=true;
	private String postData;
	
	public Boolean getDeleted() {
		return deleted;
	}

	public void setDeleted(Boolean deleted) {
		if (deleted==null)
		{
			deleted=false;
		}
		this.deleted = deleted;
	}

	public Integer getTotalResults() {
		return totalResults;
	}

	public void setTotalResults(Integer totalResults) {
		this.totalResults = totalResults;
	}

	public String getSearchResultSources() {
		return searchResultSources;
	}

	public void setSearchResultSources(String searchResultSources) {
		this.searchResultSources = searchResultSources;
	}

	public String getExcludeSourceXml() {
		return excludeSourceXml;
	}

	public void setExcludeSourceXml(String excludeSourceXml) {
		this.excludeSourceXml = excludeSourceXml;
	}

	public ArrayList<String> getExcludeSources() {
		return excludeSources;
	}

	public void setExcludeSources(ArrayList<String> excludeSources) {
		this.excludeSources = excludeSources;
	}

	public Integer getNumTimesRun() {
		if (this.numTimesRun==null)
		{
			this.numTimesRun=1;
		}
		return numTimesRun;
	}

	public void setNumTimesRun(Integer num) {
		if (num==null)
		{
			this.numTimesRun = 1;
		} 
		else {
			this.numTimesRun=num;
		}
	}

	public Boolean isCountOnly() {
		return countOnly;
	}

	public void setCountOnly(Boolean countOnly) {
		this.countOnly = countOnly;
	}

	public String getUuid() {
		return uuid;
	}

	public void setUuid(String uuid) {
		this.uuid = uuid;
	}

	public String getRoxieServerURL() {
		return roxieServerURL;
	}

	public void setRoxieServerURL(String roxieServerURL) {
		this.roxieServerURL = roxieServerURL;
	}

	public Date getUpdateDate() {
		return updateDate;
	}

	public void setUpdateDate(Date updateDate) {
		if (priorUpdate==null || (updateDate!= null && (priorUpdate==null || !updateDate.equals(priorUpdate))))
		{
			priorUpdate=this.updateDate;
		}
		this.updateDate = updateDate;
	}

	public String getDateRange() {
		return dateRange;
	}

	public void setDateRange(String dateRange) {
		this.dateRange = dateRange;
	}

	public String getBeginDate() {
		return beginDate;
	}

	public void setBeginDate(String beginDate) {
		this.beginDate = beginDate;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	public String getLastXDays() {
		return lastXDays;
	}

	public void setLastXDays(String lastXDays) {
		this.lastXDays = lastXDays;
	}
	
	public SearchDataType getActionType()
	{
		if (( cmdStackXml==null || cmdStackXml.equals(""))
			&& allSourceList != null && allSourceList.size()>0)
		{
			return SearchDataType.BROWSE_SOURCE;
		}
		else if (isGetRelationships())
		{ 
			return SearchDataType.VIEW_RELATIONSHIPS;
		}
		else if (!this.clusterID.equals("0"))
		{ 
			return SearchDataType.VIEW_CLUSTER;
		}
		else {
			return SearchDataType.SEARCH_RESULTS;
		}
		
	}
	
	public boolean isBrowseSource()
	{
		return SearchDataType.BROWSE_SOURCE.equals(getActionType());
	}

	public boolean isViewCluster()
	{
		return SearchDataType.VIEW_CLUSTER.equals(getActionType());
	}
	public boolean isViewRelationships()
	{
		return SearchDataType.VIEW_RELATIONSHIPS.equals(getActionType());
	}
	public boolean isSearchResults()
	{
		return SearchDataType.SEARCH_RESULTS.equals(getActionType());
	}

	public boolean getShowSearchForm()
	{
		return showSearchForm;
	}
	
	public void setShowSearchForm(boolean showform)
	{
		showSearchForm=showform;
	}
	public void setLabel(String labl)
	{
		customlabel=labl;
	}
	public String getLabel()
	{
		if (customlabel != null && customlabel != "")
		{
			return customlabel;
		}
		
		switch(getActionType())
		{
		case VIEW_CLUSTER:
			return "View Related Records";
		case BROWSE_SOURCE:
			StringBuilder sb=new StringBuilder("Browse ");			
			if (allSourceList != null && allSourceList.size()>0)
			{
				for (String srcname:allSourceList.values())
				{
					sb.append(srcname).append(" ");
				}
			}
			return sb.toString();		
		case VIEW_RELATIONSHIPS:
			return "View Associates";
		default:
			return " Search Results";
		}
	}
	
    public boolean isBrowseRelationships() {
        return browseRelationships;
    }

    public void setBrowseRelationships(boolean inBrowseRelationships)
    {
        this.browseRelationships = inBrowseRelationships;
    }

	public Boolean isGetRelationships() {
		return getRelationships;
	}

	public void setGetRelationships(Boolean getRelationships) {
		if (getRelationships==null)
		{
			getRelationships=false;
		}
		this.getRelationships = getRelationships;
	}

    public Boolean isGetSingleRecord() {
        return getSingleRecord;
    }

    public void setGetSingleRecord(Boolean singleRecord) {
        if (singleRecord == null)
        {
            this.getSingleRecord = false;
        }
        this.getSingleRecord = singleRecord;
        
    }

    public boolean isClustered() {
		return clustered;
	}

	public void setClustered(Boolean clustered) {
		if (clustered==null)
		{
			clustered=false;
		}
		this.clustered = clustered;
	}

	public String getClusterID() {
		return clusterID;
	}

	public void setClusterID(String clusterID) {
		this.clusterID = clusterID;
	}

	public String getRoxieQueryUrl() {
		return roxieQuery;
	}

	public void setRoxieQueryUrl(String roxieQuery) {
		this.roxieQuery = roxieQuery;
	}
	public String getAllCountries() {
		return allCountries;
	}

	public void setAllCountries(String allCountries) {
		this.allCountries = allCountries;
	}

	public HashMap<String, String> getAllSourceList() {
		return allSourceList;
	}

	public void setAllSourceList(HashMap<String, String> allSourceList) {
		this.allSourceList = allSourceList;
	}

	public String getAllSourceGroups() {
		return allSourceGroups;
	}

	public void setAllSourceGroups(String allSourceGroups) {
		this.allSourceGroups = allSourceGroups;
	}

	public String getAllSources() {
		return allSources;
	}

	public void setAllSources(String allSources) {
		this.allSources = allSources;
	}

	
	public String getSelectedCountries()
	{
		if (countries==null) {return allCountries;} 	
		String selCountries=allCountries;
	 	for (String country:countries)
	 	{ 	
	 		selCountries=selCountries.replace("value=\"" + country + "\">", "value=\"" + country + "\" selected=\"selected\">");
	 	}
		return selCountries;
	}
	
	public String getSelectedSourceGroups()
	{
		if (sourcegroups==null) {return allSourceGroups;} 	
		String selGroups=allSourceGroups;
	 	for (String group:sourcegroups)
	 	{ 	
	 		selGroups=selGroups.replace("value=\"" + group + "\">", "value=\"" + group + "\" selected=\"selected\">");
	 	}
		return selGroups;
	}
	
	public String getSelectedSources()
	{
		if (selectedsourceoptions==null) {return allSources;} 	
		String selSources=allSources;
	 	for (String src:selectedsourceoptions)
	 	{ 	
	 		selSources=selSources.replace("value=\"" + src + "\">", "value=\"" + src + "\" selected=\"selected\">");
	 	}
		return selSources;
	}
	public String getAllContentTypes() {
		return allContentTypes;
	}
	public void setAllContentTypes(String allContentTypes) {
		this.allContentTypes = allContentTypes;
	}

	public Boolean getMoreResults() {
		return moreResults;
	}
	public void setMoreResults(Boolean moreResults) {
		this.moreResults = moreResults;
	}
	public Integer getNumResults() {
		return numResults;
	}
	public void setNumResults(Integer numResults) {
		this.numResults = numResults;
	}
	public void setOffset(Integer off) {
		if (off==null)
		{
			off=0;
		}
		this.offset = off;
	}

	public Set<SearchDTOItem> getItems() {
		return items;
	}
	public void setItems(Set<SearchDTOItem> values) {
		this.items = values;
	}
	
	private ArrayList<SearchDTOItem> getItemSubset(String formSection)
	{
		ArrayList<SearchDTOItem> andItems=new ArrayList<SearchDTOItem>();
		Iterator<SearchDTOItem> it=items.iterator();
		while (it.hasNext())
		{
			SearchDTOItem item=it.next();
			if (item.getFormSection().equals(formSection))
			{
				andItems.add(item);
			}
		}
		Collections.sort(andItems);
		if (andItems.size()==0)
		{
			SearchDTOItem item=new SearchDTOItem("","",false,getAllContentTypes(),"");			
			andItems.add(item);
		}
		for (int i=andItems.size(); i <4; i++)
		{
			SearchDTOItem item=new SearchDTOItem("","",false,getAllContentTypes(),"display:none");			
			andItems.add(item);
		}
		return andItems;	
	}
	public ArrayList<SearchDTOItem> getAndItems() {
		return getItemSubset("and");
	}
	
	public ArrayList<SearchDTOItem> getOrItems() {
		return getItemSubset("or");
	}
	
	public ArrayList<SearchDTOItem> getExcludeItems() {
		return getItemSubset("exclude");
	}
	
	public SearchDTOItem getBatchItem() {
		ArrayList<SearchDTOItem> result= getItemSubset("batch");
		return result.get(0);
	}
	
	/*
	public String getBatchortype() {
		return batchortype;
	}
	public void setBatchortype(String batchortype) {
		this.batchortype = batchortype;
	}*/
	
	public ArrayList<String> getCountries() {
		return countries;
	}
	public void setCountries(ArrayList<String> countries) {
		this.countries = countries;
	}
	
	public String getCountriesAsString() {
		String result="";
		if (countries != null && countries.size() > 0)
		{
			String[] a=new String[countries.size()];
			countries.toArray(a);
		    result=StringUtils.join(a,"~|~");
		}
		return result;
	}
	
	public void setCountriesAsString(String words)
	{
		countries.clear();
		if (words != null) {
			String[] wrds=words.split("~|~");
			for (int i=0; i < wrds.length;i++)
			{
				countries.add(wrds[i]);
			}
		}
	}

	
	public ArrayList<String> getSelectedSourceOptions() {
		if (selectedsourceoptions==null)
		{
			selectedsourceoptions=new ArrayList<String>();
		}
		return selectedsourceoptions;
	}

	public void setSelectedSourceOptions(ArrayList<String> selectedsourceoptions) {
		this.selectedsourceoptions = selectedsourceoptions;
	}

	public String getSelectedSourceOptionsAsString() {
		String result="";
		if (selectedsourceoptions != null && selectedsourceoptions.size() > 0)
		{
			String[] a=new String[selectedsourceoptions.size()];
			selectedsourceoptions.toArray(a);
		    result=StringUtils.join(a,"~|~");
		}
		return result;
	}
	
	public void setSelectedSourceOptionsAsString(String words)
	{
		selectedsourceoptions.clear();
		if (words != null) {
			String[] wrds=words.split("~|~");
			for (int i=0; i < wrds.length;i++)
			{
				selectedsourceoptions.add(wrds[i]);
			}
		}
	}
	
	public ArrayList<String> getSourcegroups() {
		return sourcegroups;
	}
	public void setSourcegroups(ArrayList<String> sourcegroups) {
		this.sourcegroups = sourcegroups;
	}
	public String getSourceGroupsAsString() {
		String result="";
		if (sourcegroups != null && sourcegroups.size() > 0)
		{
			String[] a=new String[sourcegroups.size()];
			sourcegroups.toArray(a);
		    result=StringUtils.join(a,"~|~");
		}
		return result;
	}
	
	public void setSourceGroupsAsString(String words)
	{
		sourcegroups.clear();
		if (words != null) {
			String[] wrds=words.split("~|~");
			for (int i=0; i < wrds.length;i++)
			{
				sourcegroups.add(wrds[i]);
			}
		}
	}
	public ArrayList<String> getSources() {
		return sources;
	}
	public void setSources(ArrayList<String> sources) {
		this.sources = sources;
	}
	public String getSourcesAsString() {
		String result="";
		if (sources != null && sources.size() > 0)
		{
			String[] a=new String[sources.size()];
			sources.toArray(a);
		    result=StringUtils.join(a,"~|~");
		}
		//TODO: Remove this temp fix
		// source column limited to 500 characters
		if(result.length() > 499) {
		    return "";
		}
		return result;
	}
	
	public void setSourcesAsString(String words)
	{
		sources.clear();
		if (words != null) {
			String[] wrds=words.split("~|~");
			for (int i=0; i < wrds.length;i++)
			{
				sources.add(wrds[i]);
			}
		}
	}
	public String getOutputFormat() {
		return outputFormat;
	}
	public void setOutputFormat(String outputFormat) {
		this.outputFormat = outputFormat;
	}
	public String getSearchstring() {		
			return searchstring;				
	}
	public void setSearchstring(String searchstring) {
		this.searchstring = searchstring;
	}
	public ArrayList<String> getRegexsearchwords() {
		return regexsearchwords;
	}
	public void setRegexsearchwords(ArrayList<String> regexsearchwords) {
		this.regexsearchwords = regexsearchwords;
	}

	public ArrayList<String> getCJKRegexsearchwords() {
		return cjkregexsearchwords;
	}
	public void setCJKRegexsearchwords(ArrayList<String> regexsearchwords) {
		this.cjkregexsearchwords = regexsearchwords;
	}

	public long getSecondsSinceLastRun()
	{
		if (this.priorUpdate==null || this.updateDate==null)
		{
			return 0;
		}
		return (updateDate.getTime()-priorUpdate.getTime())/1000;
	}
	
	public String getRegexSearchWordsAsString() {
		String result="";
		if (regexsearchwords != null && regexsearchwords.size() > 0)
		{
			String[] a=new String[regexsearchwords.size()];
		    regexsearchwords.toArray(a);
		    result=StringUtils.join(a,"~|~");
		}
		return result;
	}
	
	public void setRegexSearchWordsAsString(String words)
	{
		regexsearchwords.clear();
		if (words != null) {
			String[] wrds=words.split("~|~");
			for (int i=0; i < wrds.length;i++)
			{
				regexsearchwords.add(wrds[i]);
			}
		}
	}

	public String getCjkRegexSearchWordsAsString() {
		String result="";
		if (cjkregexsearchwords != null && cjkregexsearchwords.size() > 0)
		{
			String[] a=new String[cjkregexsearchwords.size()];
			cjkregexsearchwords.toArray(a);
		    result=StringUtils.join(a,"~|~");
		}
		return result;
	}
	
	public void setCjkRegexSearchWordsAsString(String words)
	{
		cjkregexsearchwords.clear();
		if (words != null) {
			String[] wrds=words.split("~|~");
			for (int i=0; i < wrds.length;i++)
			{
				cjkregexsearchwords.add(wrds[i]);
			}
		}
	}
	
	public boolean isBatch() {
		return isBatch;
	}
	public void setBatch(Boolean isBatch) {
		if (isBatch==null)
		{
			isBatch=false;
		}
		this.isBatch = isBatch;
	}
	public boolean isAdvanced() {
		return isAdvanced;
	}
	public void setAdvanced(Boolean isAdvanced) {
		if (isAdvanced==null)
		{
			isAdvanced=false;
		}
		this.isAdvanced = isAdvanced;
	}
	public boolean isAlert() {
		return isAlert;
	}
	public void setAlert(Boolean isAlert) {
		if (isAlert == null) {
			isAlert = false;
		}
		this.isAlert = isAlert;
	}
	public boolean isAlertable() {
		if (isAlert) {
			return false;
		}
		return isAlertable;
	}
	public void setAlertable(Boolean isAlertable) {
		if (isAlertable == null) {
			isAlertable = false;
		}
		this.isAlertable = isAlertable;
	}
	public String getCurrentXMLResult() {
		return currentXMLResult;
	}
	public void setCurrentXMLResult(String currentXMLResult) {
		this.currentXMLResult = currentXMLResult;
	}
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	
	public String getGroupByElement() {
		return groupByElement;
	}
	public void setGroupByElement(String groupByElement) {
		this.groupByElement = groupByElement;
	}
	public Integer getPageSize() {
		return pageSize;
	}
	public void setPageSize(Integer pg) {
		if (pg==null)
		{
			pg=0;
		}
		this.pageSize = pg;
	}
	public Integer getOffset() {
		return offset;
	}
	public Integer getPage() {
		return page;
	}
	public void setPage(Integer page) {
		if (page==null)
		{
			page=0;
		}
		this.page = page;
	}
	public boolean isDebug() {
		return debug;
	}
	public void setDebug(boolean debug) {
		this.debug = debug;
	}
	public String getDistinguishedName() {
		return distinguishedName;
	}
	public void setDistinguishedName(String distinguishedName) {
		this.distinguishedName = distinguishedName;
	}
	public String getEclURL() {
		return eclURL;
	}
	public void setEclURL(String eclURL) {
		this.eclURL = eclURL;
	}

	public String getCmdStackXml() {
		return cmdStackXml;
	}
	public void setCmdStackXml(String cmdStackXml) {
		if (cmdStackXml != null)
		{
			this.cmdStackXml = cmdStackXml.trim().replaceAll("[\n\r\t]", "");
		}
	}
	public String getSourceXml() {
		return sourceXml;
	}
	public void setSourceXml(String sourceXml) {
		if (sourceXml != null)
		{
		this.sourceXml = sourceXml.trim().replaceAll("[\n\r\t]", "");
		}
	}
	

	public String getClusteredChecked() {
		if (clustered) {return "checked";}
		else {return "";}
	}
	public String getUniqueIdentifier()
	{
		if (distinguishedName==null)
		{
			return remoteIP;
		} else {
			return distinguishedName;
		}
	}
	public void setUniqueIdentifier(String d)
	{

	}
	public String getRemoteIP() {
		return remoteIP;
	}
	public void setRemoteIP(String remoteIP) {
		this.remoteIP = remoteIP;
	}
	
	public String getSearchstring(int length)
	{
		if (getSearchstring().length()>length)
		{
			return getSearchstring().substring(0,length-1);
		}
		else
		{
			return getSearchstring();
		}
	}

	public Date getCreateDate() {
		return createDate;
	}
	
	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}
	
	public Integer getCmdStackHash()
	{
		if (cmdStackXml==null)
		{
			return 0;
		}
		else 
		{
			return cmdStackXml.hashCode();
		}
	}
	
	public void setCmdStackHash(Integer hc)
	{
		
	}
	
	public Integer getSourceStackHash()
	{
		if (sourceXml==null)
		{
			return 0;
		}
		else 
		{
			return sourceXml.hashCode();
		}
	}
	
	public void setSourceStackHash(Integer hc)
	{
		
	}
	
	public void addItem(SearchDTOItem item,String formSection)
	{
		item.setParent(this);
		item.setFormSection(formSection);
		item.setPosition(items.size()+1);
		if (!item.getValue().trim().equals(""))
		{
			items.add(item);
		}
	}
	
	public SearchDTO clone()
	{
	    SearchDTO myclone = new SearchDTO();
	    myclone.setAdvanced(isAdvanced());
	    myclone.setBatch(isBatch());
	    myclone.setClustered(isClustered());
	    myclone.setCmdStackXml(getCmdStackXml());
	    myclone.setCountries(getCountries());
	    myclone.setCreateDate(getCreateDate());
	    myclone.setCurrentXMLResult(getCurrentXMLResult());
	    myclone.setEclURL(getEclURL());
	    myclone.setGroupByElement(getGroupByElement());
	    myclone.setId(getId());
	    myclone.setItems(getItems());
	    myclone.setOffset(getOffset());
	    myclone.setOutputFormat(getOutputFormat());
	    myclone.setPage(getPage());
	    myclone.setPageSize(getPageSize());
	    myclone.setSearchstring(getSearchstring());
	    myclone.setSourceXml(getSourceXml());
	    myclone.setSourcegroups(getSourcegroups());
	    myclone.setSources(getSources());
	    myclone.setTotalResults(getTotalResults());
	    myclone.setUpdateDate(getUpdateDate());
	    myclone.setUuid(getUuid());
	    return myclone;
	}
	
	public boolean equals(Object obj) {
    	if (obj == null)
    		return false;         
    	if (obj == this)
    		return true;
    	if (obj.getClass() != getClass())
    		return false;
    	SearchDTO ss2 = (SearchDTO) obj;
    	if (ss2.getId().equals(getId()) ||
    		(ss2.getCmdStackXml().equals(getCmdStackXml()) &&
    		 ss2.getSourceXml().equals(getSourceXml()) &&
    		 ss2.isClustered()==isClustered()))
    	{
    		return true;
    	} else {
    		
    		
    		return false;
    	}
    }
	
	public String toString()
	{
		StringBuffer sb=new StringBuffer();		
		sb.append("Id:").append(String.valueOf(id));
		sb.append("\nunique userid:").append(this.getUniqueIdentifier());
		sb.append("\nsearchstring:").append(this.getSearchstring());
		return sb.toString();
	}

	public String getPostData() {
		return postData;
	}
	public void setPostData(String postData) {
		this.postData=postData;
		// TODO Auto-generated method stub
		
	}
}
