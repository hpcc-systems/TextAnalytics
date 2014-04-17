package org.hpcc.indexsearch;

import java.io.Serializable;

/**
 * This class holds data for a single search modifier.
 * 
 * NOTE: If saved searches are being persisted to disk or database
 * then changes to this class (adding or removing fields) can cause
 * changes to be needed in the SavedSearchHandler implementations
 * to persist or stop persisting those fields.
 */
public class SearchDTOItem implements Serializable,Comparable {

	private static final long serialVersionUID = -8993219314816864306L;
	
	String value="";
	String type="";
	Boolean synonym=false;
	String allContentTypes="";
	String formdisplay="";
	String formSection="";
	Integer savedSearchID=0;
	Integer id=0;
	Integer position=1;


	SearchDTO parent=null;
	
	public SearchDTOItem()
	{
		
	}
	
	public SearchDTOItem(String value,String type, Boolean synonym,String contentTypes,String formdisplay)
	{
		this.value=value;
		this.type=type;
		this.synonym=synonym;
		this.allContentTypes=contentTypes;
		this.formdisplay=formdisplay;		
	}
	
	
	public String getFormSection() {
		return formSection;
	}
	public void setFormSection(String formsection) {
		this.formSection = formsection;
	}
	
	public String getValue() {
		if (value==null)
		{
			value="";
		}
		return value;
	}
	
	public Integer getSavedSearchID() {
		return savedSearchID;
	}
	public void setSavedSearchID(Integer savedSearchID) {
		this.savedSearchID = savedSearchID;
	}
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public void setValue(String value) {
		if (value==null)
		{
			value="";
		}
		this.value = value;
	}
	public String getType() {
		if (type==null)
		{
			type="";
		}
		return type;
	}
	public void setType(String type) {
		if (type==null)
		{
			type="";
		}
		this.type = type;
	}
	public Boolean getSynonym() {
		return synonym;
	}
	public void setSynonym(Boolean synonym) {
		if (synonym==null)
		{
			synonym=false;
		}
		this.synonym = synonym;
	}
	public String getDisplayValue()
	{
		if (value == null)
		{
			value="";
		}
		return value.replace("\"", "&quot;");
	}
	public void setDisplay(String display)
	{
		if (display==null) {
			display="";
		}
		formdisplay=display;
	}
	public String getDisplay()
	{
		return formdisplay;
		
	}
	public String getSynonymChecked()
	{
		if (synonym)
		{
			return "checked";
		}
		else {
			return "";
		}
	}

	public SearchDTO getParent() {
		return parent;
	}

	public void setParent(SearchDTO parent) {
		this.parent = parent;
	}
	public String getSelectedOptionList()
	{
		if (type==null) {return allContentTypes;} 	
		String theseContentTypes=allContentTypes.replace("value=\"" + type + "\">", "value=\"" + type + "\" selected=\"selected\">");
		return theseContentTypes;	
	}

	public String getAllContentTypes() {
		return allContentTypes;
	}

	public void setAllContentTypes(String allContentTypes) {
		this.allContentTypes = allContentTypes;
	}
	public Integer getPosition() {
		return position;
	}

	public void setPosition(Integer position) {
		this.position = position;
	}

	@Override
	public int compareTo(Object o) {
		if (o==null || !(o instanceof SearchDTOItem))
		{
			return 1;
		}
		else {
			SearchDTOItem other=(SearchDTOItem) o;
			return this.position.compareTo(other.position);
		}
		
	}


}