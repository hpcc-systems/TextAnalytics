import $;
export FormatSearchOutput(DATASET($.indexes.ValLayout) initResults) := Function
			 
			   recsk := $.Indexes.RecDataCombined;
				  thinInput := PROJECT(initResults, {UNSIGNED8 source_id,UNSIGNED8 record_id});
   thinInputSortDedup := DEDUP(SORT(thinInput, source_id, record_id), source_id, record_id);
		resultswide:= JOIN(thinInputSortDedup, recsk, LEFT.source_id=RIGHT.source_id and LEFT.record_id=RIGHT.record_id,transform(right));
		
   $.Layouts.L_searchResults toSearchResults(recordof(resultswide) L) := TRANSFORM
					SELF.searchable_value := L.searchable_value ;					
					SELF.entity_type     := TRIM(L.entity_type);
					SELF.record_id        := L.record_id;
          SELF.original_value   := IF(LENGTH(L.original_value) > 256, L.original_value[1..256], L.original_value);
					SELF.entity_label:=L.field_label;
					SELF := L;
    END;
		
    resultsMain := PROJECT(resultswide,toSearchResults(LEFT));
   // sortedResultsMain := SORT(resultsMain, source_id, record_id, entity_type, searchable_value);
   resultsDedup:=DEDUP(SORT(resultsMain, source_id, record_id, col,col_item, searchable_value,SKEW(1.0)),
                                   source_id, record_id, col,col_item,searchable_value);
    //determine whether to use clustered results or not	
		resultsToUse := resultsDedup;
		finalResults:=resultsToUse;
	/*	
	  finalResults := JOIN(resultsToUse,$.Datasets.dsEntityTypes,LEFT.entity_type=RIGHT.name,
			TRANSFORM( recordof( resultsToUse ) ,
			SELF.entity_label := if(RIGHT.label != '', RIGHT.label, LEFT.entity_label );
			SELF := LEFT;) ,LEFT OUTER) ;			
*/
    return when(finalResults,PARALLEL(output(thinInput),output(resultswide)));
END;
