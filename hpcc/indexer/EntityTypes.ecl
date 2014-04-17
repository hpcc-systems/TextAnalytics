import $;
export EntityTypes := module 
	export FULL_ADDRESS := 'FullAddress'; 	
	export BUSINESS_NAME := 'BusinessName';
  export GEOGRAPHIC := 'Geographic';	 
	export PERSON_NAME := 'PersonName'; 
	export PHONE_NUMBER := 'PhoneNumber'; 
		export FAX_NUMBER := 'FaxNumber'; 
	export ACCOUNT_NUMBER:='AccountNumber';
	export UNFORMATTED_STRING := 'unformattedString';
	export URL := 'URL' ;
	export IP_ADDRESS := 'IPv4' ;
	export USER_AT_DOMAIN:='user@domain' ;
	export USER_ID:='UserID' ;
	export STREET_ADDRESS:='StreetAddress' ;
	export CITY:='City' ;
	export PROVINCE:='State/Province' ;
	export POSTAL_CODE:='PostalCode' ;
	export DATE:='Date(YYYYMMDD)';
	export YEAR:='YEAR' ;
	export PERSON_IDENTIFIER := 'PersonIdentifier';
	export GENDER := 'Gender';
	export COUNTRY := 'Country';
	export UPDATE_DATE := 'UPDATEDATE';
  export IMAGE := 'Image';
  export DOCUMENT := 'Document';
	
export entity_search_map := DATASET([{0,0}],{UNSIGNED8 type_hash,UNSIGNED8 search_hash});
	
	
end;
 
