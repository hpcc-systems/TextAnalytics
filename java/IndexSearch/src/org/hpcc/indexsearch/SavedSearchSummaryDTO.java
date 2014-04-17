package org.hpcc.indexsearch;

import java.io.Serializable;
import java.util.Date;

public class SavedSearchSummaryDTO implements Serializable{

	private static final long serialVersionUID = -912687414704220234L;
	
	private Integer id;
	private String searchstring;
	private String uniqueIdentifier;
	private Date updateDate;
	private Integer totalResults;
	private Boolean deleted;
	private Boolean alert;
	public Integer getTotalResults() {
		return totalResults;
	}

	public void setTotalResults(Integer totalResults) {
		this.totalResults = totalResults;
	}

	public Date getUpdateDate() {
		return updateDate;
	}
	
	public void setUpdateDate(Date updateDate) {
		this.updateDate = updateDate;
	}
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getSearchstring() {
		return searchstring;
	}
	public void setSearchstring(String searchstring) {
		this.searchstring = searchstring;
	}
	public String getUniqueIdentifier() {
		return uniqueIdentifier;
	}
	public void setUniqueIdentifier(String uniqueIdentifier) {
		this.uniqueIdentifier = uniqueIdentifier;
	}
	public Boolean getDeleted() {
		if (deleted==null)
		{
			deleted=false;
		}
		return deleted;
	}

	public void setDeleted(Boolean deleted) {
		if (deleted==null)
		{
			deleted=false;
		}
		this.deleted = deleted;
	}
	public Boolean getAlert() {
		if (alert == null) {
			alert = false;
		}
		return alert;
	}
	public void setAlert(Boolean alert) {
		if (alert == null) {
			alert = false;
		}
		this.alert = alert;
	}
}
