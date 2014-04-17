
export wsTestRoxieSkCopy() := function

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

 export RecIndex(dataset(l_entity) ds, string filename) :=
		index(ds, 
					{, 	maxlength(20000) 
						source_id, 
						record_id, 
					} , 
					{, 	maxlength(20000) 
						id, 
						entity_type, 
						searchable_value, 
						original_value, 
						pre_display_text, 
						post_display_text, 
						error_code, 
						col, 
						col_item,
						field_label
					} , 
					filename) ;
 
 skidx:= RecIndex(dataset([],l_entity),'~roxiecopytest::idx_superkey');

 
 return skidx(source_id=8880155173721922624 and record_id between 2 and 20);
 
END;