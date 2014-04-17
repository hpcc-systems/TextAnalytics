
	import $;
	export Transforms:=MODULE
	
	export DATASET AddRecSource(dsin, insourcefname, source_fieldname,rec_fieldname,dsoutaddsourcerec) := MACRO
		#UNIQUENAME(lrecsourceext) 
		#UNIQUENAME(srcid) 
		%lrecsourceext% := RECORD
		unsigned8 source_fieldname;
		unsigned8 rec_fieldname;
		dsin;
		END;
		
		dsoutaddsourcerec :=PROJECT(dsin,TRANSFORM(%lrecsourceext%,
		%srcid%:=indexer.Utility.MakeHash(insourcefname);
		SELF.record_id:=COUNTER;
		SELF.source_id:=%srcid%;
		SELF := LEFT;
		));
		
	ENDMACRO;
	
	export DATASET MakeEntity(dsin,  entityType,
																	in_entity, 
																	infield_orig, 
																	infield_sourceID,
																	infield_recID,
																	position, 
																	itemNum=1, 
																	infieldlabel,
																	dsoutmakeentity) := MACRO 
				#UNIQUENAME(Trnsfm_Entity) 
				indexer.Layouts.l_entity %Trnsfm_Entity%(dsin rec, unsigned c) := transform 						
						self.entity_type := entityType;
						self.searchable_value := if((UNICODE)rec.in_entity != u'',(UNICODE) rec.in_entity, (UNICODE) skip) ;
						self.original_value:=(UNICODE) rec.infield_orig;
						self.error_code := 0;					
						self.source_id := rec.infield_sourceID;
						self.col_position:= 0;						
						self.record_id := rec.infield_recID;
						self.col:=position;
						self.col_item:=(unsigned)itemNum; 
						self.field_label := infieldlabel;
				end;
				 
				dsoutmakeentity := project(dsin, %Trnsfm_Entity%(left, counter));
		ENDMACRO; 
		
		END;
		