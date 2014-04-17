import $;

Export Layouts:=MODULE

 export L_EntityRefData :={ 
	integer8 id;
	STRING name;
	STRING label;
	boolean active := true;
	boolean display := true;	
	SET OF integer8 child_ids :=[] ;
END;

/*layouts for data being added to indexes*/
		export l_entity := {,MAXLENGTH(0x2000)
		string id:='',
		unsigned8 source_id,  //the source file for this concept
			unsigned8 record_id, //the record this concept was generated from
			unsigned2 col, //the column this concept was generated from
			unsigned2 col_item, //the token in the column this concept contains
			unsigned8 col_position;
			string entity_type, //what "type" of concept this is--date, ID, city, name, etc.
			unicode searchable_value, //the cleaned/searchable value for this concept
			unicode original_value, //the raw original value of this concept
			unicode pre_display_text:= u'', // For tables or lists, the (U)markup before the text
			unicode post_display_text:= u'', // For tables or lists, the (U)markup after the text
			unsigned1 error_code, // 0 is normal, 1 is do not display, 2 is collapse display, 3 is a table, 4 is a list
			string queryable:='false' , //whether or not this value is returned by a search query
			string field_label :='', //the label shown in search results for this concept
			UNSIGNED1 salt_header_field := 0;
			
		} ;
	   export L_word :=RECORD 
		UNICODE word; 
		INTEGER8 type_hash :=0; 
		INTEGER8 value_hash:=0; 
		UNSIGNED8 word_count :=0; 
END; 
 export L_Partial_Word_Match :=RECORD 
		UNICODE wildcardWord; 
		UNICODE value_hash; 
		INTEGER8 type_hash; 
		UNSIGNED8 word_cnt; 
END; 
 export CommandStack :=RECORD
      unsigned2 stack_id;
      unsigned8 opcode_num := 0; 
      unicode term {MAXLENGTH(256)}, 
      integer8 term_hash := 0; 
      string type_name {MAXLENGTH(64)} := '';
      integer8 type_hash := 0;
      boolean not_phrase := false; // is this part of the AND NOT boolean section
      UNSIGNED4 search_id := 0;
   END; 
// Search results 
 export L_SearchResult := RECORD 
		unsigned8 record_id; 
		unsigned8 source_id; 
		unsigned8 type_hash; 
		unsigned8 value_hash; 
		unsigned2 col; 
		unsigned2 col_position; 
	
END; 
 export L_SearchResults :=	{

			UNSIGNED1 error_code,
			UNICODE pre_display_text :=u'',
			UNICODE post_display_text :=u'',
      STRING entity_type {MAXLENGTH(32)},
			STRING entity_label {MAXLENGTH(32)},
      UNICODE searchable_value {MAXLENGTH(4096)},
			UNICODE original_value {MAXLENGTH(4096)},
			UNSIGNED8 source_id,
			UNSIGNED8 record_id,
			UNSIGNED2 col,
			UNSIGNED2 col_item,
			UNSIGNED8 group_id:=0,
			STRING field_label {MAXLENGTH(64)} :='',
			INTEGER1 collapse:=0;
	
   };
	 export l_entitytypelist := {
	 unsigned8 source_id;
	 unicode entity_type;
	 };
	 
 export L_sourceEntityCnt := {, MAXLENGTH(512) 
		unsigned8 source_id;
		STRING source_label:='';
		UNSIGNED8 total := 1;
		STRING concept_type;
		UNSIGNED8 cnt := 1;
	};

 export L_entitySourceCnt := {, MAXLENGTH(512) 
		STRING concept_type, 
		UNSIGNED8 total := 1;
		unsigned8 source_id :=0;
		STRING source_label :='';
		UNSIGNED8 cnt := 1; 
	} ;

END;