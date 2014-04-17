
/**
 * toggles search options
 * */
function ToggleSearchType(type)
{

	if (type =="")
	{
		document.getElementById("partial").value="false";
		document.getElementById("soundslike").value="false";
	} else if (type=="partial")
	{
		document.getElementById("partial").value="true";
		document.getElementById("soundslike").value="false";
		
	} else if (type=="soundslike")
	{
		document.getElementById("partial").value="false";
		document.getElementById("soundslike").value="true";
	}

}

function GoToSearchForm()
{
	window.location="#top";
}
function NewSearch()
{
	ClearAdvancedForm();
	ClearBasicForm();
	GoToSearchForm();
	
}

function ClearAll()
{
	ClearBasicForm();
	ClearAdvancedForm();	
//	ClearForm();
}
function ClearBasicForm()
{
	document.getElementById("value0").value="";
	document.getElementById("type0").options[0].selected="true";

}

function ClearForm()
{
//	document.getElementById("orvalue").value="";
//	document.getElementById("ortype").options[0].selected="true";	
}
function ClearAdvancedForm()
{
	removeFieldsRow('','1');
	removeFieldsRow('','2');
	removeFieldsRow('','3');
	removeFieldsRow('or','1');
	removeFieldsRow('or','2');
	removeFieldsRow('or','3');
	removeFieldsRow('exclude','1');
	removeFieldsRow('exclude','2');
	removeFieldsRow('exclude','3');
	
	document.getElementById("orvalue0").value="";
	document.getElementById("ortype0").options[0].selected="true";

	
	document.getElementById("excludevalue0").value="";	
/*
	
	selectList=document.getElementById("csourcelist");
	selectList.options[0].selected="true";
	 for (var i = 1; i < selectList.length; i++)
	 {
		 selectList.options[i].selected=false;
	 }
	 selectList=document.getElementById("collsourcelist");
	 selectList.options[0].selected="true";
	 for (var i = 1; i < selectList.length; i++)
	 {
		 selectList.options[i].selected=false;
	 }
	*/	 
		
}

/**
 * toggles search options
 * */
function ToggleAdvancedDisplay(value)
{

	if (value=="true")
	{
		document.getElementById("advanced").style.display="";
		document.getElementById("isadvanced").value="true";
		document.getElementById("advancedsearchtips").style.display="";
		document.getElementById("basicsearchtips").style.display="none";
		document.getElementById("advancedtab").className="active";
		document.getElementById("basictab").className="";
		document.getElementById("").style.display="none";
		document.getElementById("fieldsrowadd").style.display="";
		document.getElementById("orfieldsrowadd").style.display="";
		document.getElementById("excludefieldsrowadd").style.display="";
		document.getElementById("tab").className="";
		document.getElementById("fieldsrow").style.display="";		
		document.getElementById("searchtips").style.display="none";
		document.getElementById("is").value="false";
		ClearForm();

	}
	else if (value=="false")
	{
		ClearAdvancedForm();
		ClearForm();
		document.getElementById("isadvanced").value="false";		
		document.getElementById("advancedtab").className="";
		document.getElementById("basictab").className="active";
		document.getElementById("advancedsearchtips").style.display="none";
		document.getElementById("basicsearchtips").style.display="";
		document.getElementById("advanced").style.display="none";
		document.getElementById("").style.display="none";
		document.getElementById("fieldsrowadd").style.display="none";
		document.getElementById("tab").className="";
		document.getElementById("fieldsrow").style.display="";
		document.getElementById("searchtips").style.display="none";
		document.getElementById("is").value="false";
	}
	else if (value=="")
		{
			ClearBasicForm();
			ClearAdvancedForm();
			document.getElementById("advancedtab").className="";
			document.getElementById("basictab").className="";
			document.getElementById("tab").className="active";
			document.getElementById("isadvanced").value="false";
			document.getElementById("is").value="true";
			document.getElementById("advanced").style.display="none";
			document.getElementById("fieldsrowadd").style.display="none";
			document.getElementById("advancedsearchtips").style.display="none";
			document.getElementById("basicsearchtips").style.display="none";
			document.getElementById("searchtips").style.display="";
			document.getElementById("").style.display="";
			document.getElementById("fieldsrow").style.display="none";

		}
}

function addFieldsRow(prefix){

	 var tbl = document.getElementById(prefix + "fieldsrow");
	 for (var i=0; i < 4; i++){
	 	if (document.getElementById(prefix + "fieldsrow" + i).style.display=="none")
		{
			 document.getElementById(prefix + "fieldsrow" + i).style.display="";
			 if (i==3)
			 {	 document.getElementById(prefix + "fieldsrowadd").style.display="none";
			 }
			 return;
		}
	}

}

function removeFieldsRow(prefix,rownum)
{

	 document.getElementById(prefix + "fieldsrow" + rownum).style.display="none";	 

	 document.getElementById(prefix + "fieldsrowadd").style.display="";
	 document.getElementById(prefix + "value" + rownum).value="";
	 //document.getElementById(prefix + "synonym" + rownum).removeAttribute("selected");
	// document.getElementById(prefix + "synonym" + rownum).checked=false;
	 selectList=document.getElementById(prefix + "type" + rownum);	 

	 selectList.options[0].selected="true";
	 for (var i = 1; i < selectList.length; i++)
	 {
		 selectList.options[i].selected=false;
	 }	

}

function openWindow(url,options)
{

	newURL = window.location.protocol + "://" + window.location.host + "/cdce/" +url;
	window.open(url,'popup',options);

}
function transferOptionsToHiddenVar(selectList,hiddenVar) {
	
    var result = ""; 
    for (var i = 0; i < selectList.length; i++) { 
        if (selectList.options[i].selected) { 
            result += selectList.options[i].value;
	    if (result != "" && i < selectList.length-1) {
		result +="\n";
	    } 
        } 
    } 
	 result = result.replace(/\n$/,"");	
	 hiddenVar.value=result;	
}


/**
 * toggles search options
 * */
function ToggleSearchType(type)
{

	if (type =="")
	{
		document.getElementById("partial").value="false";
		document.getElementById("soundslike").value="false";
	} else if (type=="partial")
	{
		document.getElementById("partial").value="true";
		document.getElementById("soundslike").value="false";
		
	} else if (type=="soundslike")
	{
		document.getElementById("partial").value="false";
		document.getElementById("soundslike").value="true";
	}

}

function GoToSearchForm()
{
	window.location="#top";
}
function NewSearch()
{
	ClearAdvancedForm();
	ClearBasicForm();
	GoToSearchForm();
	
}

function ClearAll()
{
	ClearBasicForm();
	ClearAdvancedForm();	
	ClearForm();
}
function ClearBasicForm()
{
	document.getElementById("value0").value="";
	document.getElementById("type0").options[0].selected="true";
//	document.getElementById("synonym0").selected=null;
 //   document.getElementById("phonenormoptions0").style.display = "none";
}

function ClearForm()
{
	document.getElementById("orvalue0").value="";
	document.getElementById("ortype0").options[0].selected="true";	
}
function ClearAdvancedForm()
{
	removeFieldsRow('','1');
	removeFieldsRow('','2');
	removeFieldsRow('','3');
	removeFieldsRow('or','1');
	removeFieldsRow('or','2');
	removeFieldsRow('or','3');
	removeFieldsRow('exclude','1');
	removeFieldsRow('exclude','2');
	removeFieldsRow('exclude','3');
	
	document.getElementById("orvalue0").value="";
	document.getElementById("ortype0").options[0].selected="true";
//	document.getElementById("orsynonym0").checked=false;	
 //   document.getElementById("orphonenormoptions0").style.display = "none";
	
	document.getElementById("excludevalue0").value="";
	document.getElementById("excludetype0").options[0].selected="true";	
//	document.getElementById("excludesynonym0").checked=false;
//	document.getElementById("excludephonenormoptions0").style.display = "none";
	/*
	selectList=document.getElementById("csourcelist");
	selectList.options[0].selected="true";
	 for (var i = 1; i < selectList.length; i++)
	 {
		 selectList.options[i].selected=false;
	 }
	 selectList=document.getElementById("collsourcelist");
	 selectList.options[0].selected="true";
	 for (var i = 1; i < selectList.length; i++)
	 {
		 selectList.options[i].selected=false;
	 }
	 selectList=document.getElementById("sourcelistdd");
	 selectList.options[0].selected="true";
	 for (var i = 1; i < selectList.length; i++)
	 {
		 selectList.options[i].selected=false;
	 }*/
		
}

/**
 * toggles search options
 * */
function ToggleAdvancedDisplay(value)
{

	if (value=="true")
	{
		document.getElementById("advanced").style.display="";
		document.getElementById("isadvanced").value="true";
		document.getElementById("recenttab").className="";
		document.getElementById("advancedsearchtips").style.display="";
		document.getElementById("basicsearchtips").style.display="none";
		document.getElementById("advancedtab").className="active";
		document.getElementById("basictab").className="";
		document.getElementById("").style.display="none";
		document.getElementById("fieldsrowadd").style.display="";
		document.getElementById("orfieldsrowadd").style.display="";
		document.getElementById("excludefieldsrowadd").style.display="";
		document.getElementById("tab").className="";
		document.getElementById("fieldsrow").style.display="";		
		document.getElementById("searchtips").style.display="none";
		document.getElementById("is").value="false";
		document.getElementById("recentsearches").style.display="none";
		document.getElementById("clusterrow").style.display="";
		document.getElementById("drangediv").style.display="";		
//		document.getElementById("rightside").style.display="";
		ClearForm();

	}
	else if (value=="false")
	{
		ClearAdvancedForm();
		ClearForm();
		document.getElementById("recenttab").className="";
		document.getElementById("isadvanced").value="false";		
		document.getElementById("advancedtab").className="";
		document.getElementById("basictab").className="active";
		document.getElementById("advancedsearchtips").style.display="none";
		document.getElementById("basicsearchtips").style.display="";
		document.getElementById("advanced").style.display="none";
		document.getElementById("").style.display="none";
		document.getElementById("fieldsrowadd").style.display="none";
		document.getElementById("tab").className="";
		document.getElementById("fieldsrow").style.display="";
		document.getElementById("searchtips").style.display="none";
		document.getElementById("is").value="false";
		document.getElementById("recentsearches").style.display="none";
		document.getElementById("clusterrow").style.display="";
		document.getElementById("drangediv").style.display="none";
	//	document.getElementById("rightside").style.display="";
	}
	else if (value=="")
		{
			ClearBasicForm();
			ClearAdvancedForm();
			document.getElementById("advancedtab").className="";
			document.getElementById("basictab").className="";
			document.getElementById("recenttab").className="";
			document.getElementById("tab").className="active";
			document.getElementById("isadvanced").value="false";
			document.getElementById("is").value="true";
			document.getElementById("advanced").style.display="none";
			document.getElementById("fieldsrowadd").style.display="none";
			document.getElementById("advancedsearchtips").style.display="none";
			document.getElementById("basicsearchtips").style.display="none";
			document.getElementById("searchtips").style.display="";
			document.getElementById("").style.display="";
			document.getElementById("fieldsrow").style.display="none";
			document.getElementById("recentsearches").style.display="none";
			document.getElementById("clusterrow").style.display="";
			document.getElementById("drangediv").style.display="none";
			//document.getElementById("rightside").style.display="";
		}
		else if (value=="recent")
		{
			ClearBasicForm();
			ClearAdvancedForm();
			ClearForm();
			document.getElementById("advancedtab").className="";
			document.getElementById("basictab").className="";
			document.getElementById("tab").className="";
			document.getElementById("recenttab").className="active";
			document.getElementById("advanced").style.display="none";
			document.getElementById("fieldsrowadd").style.display="none";
			document.getElementById("advancedsearchtips").style.display="none";
			document.getElementById("basicsearchtips").style.display="none";
			document.getElementById("searchtips").style.display="none";
			document.getElementById("").style.display="none";
			document.getElementById("fieldsrow").style.display="none";
			document.getElementById("recentsearches").style.display="";
			document.getElementById("clusterrow").style.display="none";
			document.getElementById("rightside").style.display="none";
			
		}
}

function addFieldsRow(prefix){

	 var tbl = document.getElementById(prefix + "fieldsrow");
	 for (var i=0; i < 4; i++){
	 	if (document.getElementById(prefix + "fieldsrow" + i).style.display=="none")
		{
			 document.getElementById(prefix + "fieldsrow" + i).style.display="";
			 if (i==3)
			 {	 document.getElementById(prefix + "fieldsrowadd").style.display="none";
			 }
			 return;
		}
	}

}

function removeFieldsRow(prefix,rownum)
{

	 document.getElementById(prefix + "fieldsrow" + rownum).style.display="none";	 

	 document.getElementById(prefix + "fieldsrowadd").style.display="";
	 document.getElementById(prefix + "value" + rownum).value="";
	 //document.getElementById(prefix + "synonym" + rownum).removeAttribute("selected");
//	 document.getElementById(prefix + "synonym" + rownum).checked=false;
	 selectList=document.getElementById(prefix + "type" + rownum);	 

	 selectList.options[0].selected="true";
	 for (var i = 1; i < selectList.length; i++)
	 {
		 selectList.options[i].selected=false;
	 }	

}

function openWindow(url,options)
{

	newURL = window.location.protocol + "://" + window.location.host + "/cdce/" +url;
	window.open(url,'popup',options);

}
function transferOptionsToHiddenVar(selectList,hiddenVar) {
	
    var result = ""; 
    for (var i = 0; i < selectList.length; i++) { 
        if (selectList.options[i].selected) { 
            result += selectList.options[i].value;
	    if (result != "" && i < selectList.length-1) {
		result +="\n";
	    } 
        } 
    } 
	 result = result.replace(/\n$/,"");	
	 hiddenVar.value=result;	
}



var viewLinkHTML={};
var viewLinkHref={};
var hideLinkHTML={};
var hideLinkHref={};
var emptyHTML={};

function viewAjax(linkid, url,outputElementName)
{
	
	if (emptyHTML[outputElementName]==undefined 
			|| emptyHTML[outputElementName]=='')
	{
		emptyHTML[outputElementName]=document.getElementById(outputElementName).innerHTML;
	}

	viewLinkHTML[outputElementName]=document.getElementById(linkid).innerHTML;
	hideLinkHTML[outputElementName]=viewLinkHTML[outputElementName];
	hideLinkHTML[outputElementName]=hideLinkHTML[outputElementName].toString().replace('View ','Hide ');
		
	viewLinkHref[outputElementName]=document.getElementById(linkid).href;
	hideLinkHref[outputElementName]=viewLinkHref[outputElementName];
	hideLinkHref[outputElementName]=hideLinkHref[outputElementName].toString().replace('javascript:view','javascript:hide');				

    if(emptyHTML[outputElementName] != undefined
    		&& document.getElementById(outputElementName).innerHTML == emptyHTML[outputElementName])
    {
        ajaxURL(url,outputElementName);
    }	
	document.getElementById(outputElementName).style.display="";
	document.getElementById(linkid).innerHTML=hideLinkHTML[outputElementName];
	document.getElementById(linkid).href=hideLinkHref[outputElementName];
}

function hideAjax(linkid, url,outputElementName)
{
	hideLinkHTML[outputElementName]=document.getElementById(linkid).innerHTML;
	viewLinkHTML[outputElementName]=hideLinkHTML[outputElementName];
	viewLinkHTML[outputElementName]=viewLinkHTML[outputElementName].toString().replace('Hide ', 'View ');
		
	hideLinkHref[outputElementName]=document.getElementById(linkid).href;
	viewLinkHref[outputElementName]=hideLinkHref[outputElementName];
	viewLinkHref[outputElementName]=viewLinkHref[outputElementName].toString().replace('javascript:hide','javascript:view');				

	document.getElementById(outputElementName).style.display="none";
	document.getElementById(linkid).innerHTML=viewLinkHTML[outputElementName];
	document.getElementById(linkid).href=viewLinkHref[outputElementName];
}

var xmlHttp;
var currentOutputElementName='';

function ajaxURL(url,outputElementName)
{
	ajaxURL(url,outputElementName,null);
}
function ajaxURL(url,outputElementName,callbackfunction) {

	url=url + "&bustCache=" + Math.random(); 
  xmlHttp = false;
   try {
     xmlHttp = new ActiveXObject("Msxml2.XMLHTTP")  // For Old Microsoft Browsers
   }
   catch (e) {
     try {
       xmlHttp = new ActiveXObject("Microsoft.XMLHTTP")  // For Microsoft IE 6.0+
     }
     catch (e2) {
       xmlHttp = false   // No Browser accepts the XMLHTTP Object then false
     }
   }
   if (!xmlHttp && typeof XMLHttpRequest != 'undefined') {
     xmlHttp = new XMLHttpRequest();        //For Mozilla, Opera Browsers
   }

  currentOutputElementName=outputElementName;

  if(xmlHttp) { 
    xmlHttp.open("GET",url,true); //gettime will be the servlet name
    if (callbackfunction==null)
    {
    	xmlHttp.onreadystatechange  = handleServerResponse;
    }
    else 
    {
    	xmlHttp.onreadystatechange  = callbackFunction;
    }
    xmlHttp.setRequestHeader('Content-Type', 'text/html');
    xmlHttp.send(null);
  }
}

  
function handleServerResponse() {
   if (xmlHttp.readyState == 4) {
     if(xmlHttp.status == 200) {
    document.getElementById(currentOutputElementName).innerHTML= document.getElementById(currentOutputElementName).innerHTML.toString().replace("Loading...","");
	document.getElementById(currentOutputElementName).innerHTML=document.getElementById(currentOutputElementName).innerHTML + xmlHttp.responseText;
     }
     else {
        //alert("Error during AJAX call. Please try again");
     }
   }
}


function loadTasks(ssid)
{

    if (ssid != '' && ssid != '0')
    {
	outputElement=document.getElementById('resultcount');
	if (outputElement != null)
	{
//		document.getElementById('resultcount').innerHTML="Calculating..."

		url="IRSearch?savedsearch=true&searchuuid=" + ssid + "&countonly=true&pageSize=50000";
		//alert(url);
		ajaxURL(url,'resultcount');
		
	}
    }
}

    function showHideByName(theName, obj)
    {    
        var theElems = document.getElementsByName(theName);
        for(var i=0; i<theElems.length; i++)
        {
            var theElem = theElems[i];
            if (theElem.style.display == "none") { // || theElem.style.display == "") {
                theElem.style.display = "";
                obj.src = "images/minus.gif";
            }
            else {
                theElem.style.display = "none";
                obj.src = "images/plus.gif";
            }
        }
    }
