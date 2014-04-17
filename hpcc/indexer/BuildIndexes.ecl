/*
*  
*  Normal usage of the attributes in this module:
*
*  ConceptRetrieval.BuildConceptIndexes.removeBuildAdd( Concept File, Name )
*    Called for each concept data set that is to be added to Information Retrieval
*  
*  ConceptRetrieval.BuildConceptIndexes.DailyBatchTasks
*    Called once per day to regenerate all of the indexes and files used by
*    Information Retrieval (CDCE Search)
*
*  ConceptRetrieval.BuildConceptIndexes.IRMetaDataBatchTasks
*    Called periodically to rebuild the indexes and files used for wildcard
*    searching
*/
import $;
import lib_unicodelib;
import lib_fileservices;
import lib_stringlib;
import lib_thorlib;
//import BitmapSearch;
//IMPORT ato;
//Import WorkunitUtilities;
export BuildIndexes :=module 
shared persistPrefix := '~indexer::persist::BuildIndexes::'; 
shared dtaPrefix :='~indexer::data::';
shared ndxPrefix :='~indexer::idx::';
shared valSuffix := '_val'; 
shared recSuffix := '_rec'; 
shared cntSuffix := '_cnt'; 
shared lstSuffix := '_1st '; 
shared bmpSuffix := '_bmp';
shared posSuffix := '_pos'; 
shared sccSuffix := 'scc'; 
shared substringMSuffix := '_ssgm'; 
shared substringFLSuffix := '_ssgfl'; 

 export DATASET($.Layouts.l_entity) ChunkValues(dataset($.Layouts.l_entity) cons, 
																						string persistSuffix) := function 

//number of characters in single searchable_value; split single long record into multiple recs
//with incrementing col_items
 chunksize:=500;
 
 $.Layouts.l_entity SplitLongValues($.Layouts.l_entity L, INTEGER C) := TRANSFORM
		endidx:=(c*chunksize);
		beginidx:=endidx-chunksize+1;
		val:= L.searchable_value[beginidx..endidx];
		val2:=L.searchable_value[endidx+1..];
				oval:= L.original_value[beginidx..endidx];
		oval2:=L.original_value[endidx+1..];
		spcidx:=unicodelib.UnicodeFind(val2,u' ',1);
		ospcidx:=unicodelib.UnicodeFind(oval2,u' ',1);
		val1:= if (beginidx > 1 and unicodelib.unicodeFind(val,u' ',1) > 1, val[unicodelib.unicodeFind(val,u' ',1)+1..length(val)],val);
	oval1:= if (beginidx > 1 and unicodelib.unicodeFind(oval,u' ',1) > 1, oval[unicodelib.unicodeFind(oval,u' ',1)+1..length(oval)],oval);
	valfinal:=IF ( spcidx > 1, val1 + val2[1..spcidx],val1);
		ovalfinal:=IF ( ospcidx > 1, oval1 + oval2[1..ospcidx],oval1);
		SELF.searchable_value:=valfinal;
		SELF.original_value:=ovalfinal;
		SELF.col_item:=C;
		SELF := L;
END;

chunked :=NORMALIZE(cons,if (length(left.searchable_value) > chunksize,length(left.searchable_value)/chunksize,1),SplitLongValues(LEFT,COUNTER));

return chunked;
END;

export CleanLayout := {, maxlength($.Constants.INDEX_LAYOUT_MAX_LEN) 
				unicode searchable_value, 
				string entity_type, 
				integer8 source_id, 
				unsigned6 record_id, 
				unsigned2 col, 
				unsigned2 col_item, 
	} ; 
 export SplitLayout :=$.Indexes.ValLayout; 
 export CountLayout :=$.Indexes.WordCntLayout; 
 export DATASET(CleanLayout) CleanEntities(dataset($.Layouts.l_entity) cons, 
																						string persistSuffix) := function 
		
		chunkedrecs:=ChunkValues(cons,persistSuffix);
		CleanLayout cleanTrans(recordof(cons) rec) := transform 
				trimValue := trim(rec.searchable_value, left, right); 
				cleanValue := UnicodeLib.UnicodeCleanSpaces(trimValue); 
				ucValue := UnicodeLib.UnicodeToUpperCase(cleanValue); 
				ucType := StringLib.StringToUpperCase(rec.entity_type); 
				self.searchable_value := ucValue; 
				self.entity_type := TRIM(StringLib.StringToUpperCase(ucType),LEFT,RIGHT); 
				self :=rec; 
		end; 
	cleanCons :=project(cons, cleanTrans(left)):persist(persistPrefix + 'CleanEntities::'+ persistSuffix) ; ; 

	return cleanCons; 
end; 

export DATASET(SplitLayout) SplitWords(dataset($.Layouts.l_entity) cons, 
																			string persistSuffix) := function 
   // breaking out full-text markup of the form [[entity_type:searchable_value]]
   PATTERN nondelimtxt := PATTERN('[^\\[\\]]+');
   PATTERN startdelim  := PATTERN('\\[\\[');
   PATTERN typedecl    := PATTERN('[a-zA-Z@]+');
   PATTERN colon       := PATTERN(':');
   PATTERN valdecl     := PATTERN('[^\\]]+');
   PATTERN enddelim    := PATTERN('\\]\\]');
   rule embeddedType := startdelim typedecl colon valdecl enddelim;
   recordof(cons) getspecialtrans(recordof(cons) rec) := TRANSFORM
      embeddedval := matchunicode(valdecl);
      typestring := matchunicode(typedecl);
      SELF.searchable_value := IF(embeddedval = u'', matchunicode(embeddedType), embeddedval);
      SELF.entity_type := IF(typestring = u'', rec.entity_type, (STRING)typestring);
      SELF := rec;
   END;
   markupcons :=parse(cons, searchable_value, embeddedType, getspecialtrans(left), FIRST, SCAN);
		cleanCons :=CleanEntities(cons + markupcons, persistSuffix); 
		rule word :=pattern('[^ \n]+'); // a word is a contiguous group of non-space characters 
		SplitLayout splitTrans(recordof(cleanCons) rec) :=transform 
				searchable_value := matchunicode(word); 
				valueHash := $.Utility.MakeUHash(searchable_value) ; 
				typeHash := if(rec.entity_type = '', 0, $.Utility.makehash(rec.entity_type)) ; 
				self.searchable_value := searchable_value; 
				self.value_hash := valueHash; 
				self.type_hash := typeHash; 
				self.col_position :=matchposition(word); 
				self :=rec; 
		end; 
	recordof(cleanCons) fixChars(recordof(cleanCons) rec) := transform
		self.searchable_value := $.Utility.FixCharacters(rec.searchable_value);
		self := rec;
	end;
		
		cleanCons2 :=project (cleanCons, fixChars(left)) ; 
	// regexreplace is used so that individual Han characters will be treated as words 
		splitValues :=parse(cleanCons2, 
												searchable_value, 
												word, 
												splitTrans(left) ,
												FIRST, SCAN) 
									:	persist(persistPrefix + 'SplitWords::'+ persistSuffix) ; 
		return splitValues; 
	
	end; 
	
	export Dataset($.Indexes.ValLayout) addNullTypes(dataset($.Indexes.ValLayout) cons,
					string persistSuffix) :=function
					
					ret:=NORMALIZE(cons, 2,TRANSFORM($.Indexes.ValLayout, 
									SELF.entity_type:=if(COUNTER=2,'',LEFT.entity_type);
									SELF.type_hash:=if(COUNTER=2,0,LEFT.type_hash);
									SELF:=left;
										)) ; 
					ret2:=dedup(sort(ret,value_hash,type_hash,source_id,record_id,col,col_item,col_position),
					value_hash,type_hash,source_id,record_id,col,col_item,col_position);
										return ret2;
					END;
					
 export DATASET(SplitLayout) AllSort(dataset($.Layouts.l_entity) cons, 
																		string persistSuffix) :=function 
			valSet := SplitWords(cons, persistSuffix); 
			valSort := sort(valSet, value_hash, type_hash, source_id, record_id, col, col_item, col_position) ; 
			positionFix :=iterate(valSort, transform(recordof(valSort) , 
											self.col_position := IF(left.source_id = right.source_id 
																					and left.record_id=right.record_id 
																					and left.col=right.col
                                          and left.col_item=right.col_item, 
																						left.col_position +1,
																						right.col_position) ; 
											self := right)) : persist(persistPrefix + 'AllSort::'+ persistSuffix) ; 
			
			nullsadded:=addNullTypes(valSort,persistSuffix);
			return nullsadded; 
end; 
 export DATASET(CountLayout) CountWords(DATASET($.Layouts.l_entity) cons, 
																				string persistSuffix) := function 
		splitVals := SplitWords(cons, persistSuffix); 
		randomDist := splitVals;//distribute(splitVals, random()); 
		localTable :=table(randomDist,{value_hash,type_hash,searchable_value,entity_type, word_cnt :=count(group) },  
											value_hash,type_hash,searchable_value,entity_type, local) ;  
		fullSort := sort(localTable, value_hash, type_hash); 
		countVals := rollup(fullSort, transform(recordof(localTable) , 
				self.word_cnt := left.word_cnt + right.word_cnt; 
				self := left), value_hash, type_hash) ; 
				
		countVals2 :=PROJECT(countVals, transform(CountLayout, self := left;)) 
					: persist(persistPrefix + 'CountWords::'+ persistSuffix) ; 
		return countVals2; 
end; 
 export BuildWordCnt(dataset($.Layouts.l_entity) cons, 
										string ndxInfix, 
										string persistSuffix) := function 
		cntSet :=CountWords(cons, persistSuffix); 
		cntNdx :=$.Indexes.WordCntIndex(cntSet, NdxPrefix + ndxInfix + cntSuffix) ; 
		return buildindex(cntNdx, sorted, overwrite); 
end; 

 export BuildSingleWordCountNdx() := function 
		
   cntIndex :=$.Indexes.CntSuperKey;
    layoutDs := { recordof(cntIndex) AND NOT word_cnt; unsigned6 cnt; };
    cntIndexDs := PROJECT(cntIndex, TRANSFORM(layoutDs, SELF.cnt := LEFT.word_cnt; SELF := LEFT));
    deduped := TABLE(cntIndexDs, {value_hash, type_hash, searchable_value, entity_type, word_cnt := SUM(GROUP, cnt)},value_hash, type_hash, searchable_value, entity_type);

		newCntIndex :=$.Indexes.WordCntIndex(PROJECT(deduped,$.Indexes.WordCntLayout) ,$.Indexes.WORD_CNT_SINGLEINDEX); 
		
		return buildindex(newCntIndex,overwrite) ; 
END; 
 export BuildWordSubstringNdx():= function 
	
		cntIndex :=$.Indexes.WordCntIndex(dataset([], $.Indexes.WordCntLayout), $.Indexes.WORD_CNT_SINGLEINDEX); 
		middle := NORMALIZE(cntIndex, LENGTH(LEFT.searchable_value),TRANSFORM($.Indexes.SubstringMiddleLayout, 
									SELF.firstletter := $.Utility.TF(LEFT.searchable_value[COUNTER]); 
									self.secondletter := $.Utility.TF(LEFT.searchable_value[COUNTER + 1]); 
									SELF.thirdletter := $.Utility.TF(left.searchable_value[COUNTER + 2]); 
									SELF.triple:=LEFT.searchable_value[COUNTER..COUNTER+2]; 
									SELF := LEFT; )) ; 
//filter out han/cjk characters that don't translate to "letters" 
		middleclean :=middle(firstletter != 0 or secondletter != 0 or thirdletter != 0); 
		firstlast :=PROJECT(cntIndex, TRANSFORM($.Indexes.SubstringFirstLastLayout, 
											self.firstletter := $.Utility.TF(left.searchable_value[1]) ; 
											self.lastletter := $.Utility.TF(LEFT.searchable_value[LENGTH(left.searchable_value)]); 
											SELF.letters :=LEFT.searchable_value[1] + LEFT.searchable_value[LENGTH(LEFT.searchable_value)]; 
											SELF := LEFT)); 
//filter out han/cjk characters that don't translate to "letters" 
		firstlastclean :=firstlast(firstletter != 0 or lastletter != 0); 
		substringMiddleNdx := $.Indexes.SubstringMiddleIndex(middleclean,$.Indexes.SUBSTRING_MIDDLE_FILENAME); 
		substringFLNdx := $.Indexes.SubstringFirstLastIndex(firstlastclean, $.Indexes.SUBSTRING_FIRSTLAST_FILENAME) ; 
		return PARALLEL(buildindex(substringMiddleNdx,OVERWRITE) ,buildindex(substringFLNdx,OVERWRITE)); 
END; 
export BuildVal(DATASET($.Layouts.l_entity) cons, 
									string ndxInfix, 
									string persistSuffix) :=function 
		valSet :=AllSort(cons, persistSuffix); 
		valNdx :=$.Indexes.valIndex(valSet, NdxPrefix + ndxInfix + valSuffix); 
		return buildindex(valNdx, sorted, overwrite); 
end; 

export AddConceptValue(dataset($.Layouts.l_entity) cons,
								STRING new_entity_type,
								UNICODE new_searchable_value,
								STRING new_field_label):=function
			
			//if any concepts are of the type to be added and are blank, set them to the new value
			//also add flag indicating if update date exists and if is valid
			cons1 := PROJECT(cons, TRANSFORM({, MAXLENGTH(0x20000) recordof(cons),boolean existsflag, boolean invaliddate},
			SELF.searchable_value := IF (LEFT.entity_type=new_entity_type and LEFT.searchable_value=u'',new_searchable_value,LEFT.searchable_value);
			SELF.original_value := IF (LEFT.entity_type=new_entity_type and LEFT.original_value=u'',new_searchable_value,LEFT.original_value);
			SELF.existsFlag := if (LEFT.entity_type=new_entity_type,true,false);
			SELF.invalidDate := if ((LEFT.entity_type=new_entity_type	
															and (UnicodeLib.UnicodeFilter(LEFT.searchable_value,u'0123456789')!=LEFT.searchable_value 
															or (LEFT.searchable_value != u'' and length(LEFT.searchable_value)< 8))),true,false);
			SELF := LEFT;));
			//make sure any existing update dates are in a valid format
		//	if (count(cons1(invalidDate=true))>0,	FAIL('Invalid entities of entity_type UPDATE_DATE in this dataset--must be in YYYYMMDD format'));
			//roll up dataset, keeping existing update date if exists, otherwise creating new update date
			cons2 := GROUP(SORT(cons1,source_id,record_id, -existsflag),source_id,record_id);
      // rollup groups. this should leave us with only 1 record, which contains the 
      // update date. If the group has only 1 record then a project will need to be
      // done to turn it into the update date record.
      cons2 addUpdateDate(cons2 L, cons2 R) := TRANSFORM
			   SELF.existsflag :=        if (L.existsflag=true, L.existsflag, R.existsflag);
			   SELF.entity_type :=      if (L.existsflag=true, L.entity_type, new_entity_type);
			   SELF.searchable_value :=     if (L.existsflag=true, L.searchable_value, new_searchable_value);
			   SELF.original_value:=     if (L.existsflag=true, L.original_value, new_searchable_value);
			   SELF.field_label :=       if (L.existsflag=true, L.field_label, new_field_label);
			   SELF.col :=               if (L.existsflag=true, L.col, if (L.col > R.col, L.col, R.col));
			   SELF.col_item :=              if (L.existsflag=true, L.col_item, 1);
         SELF.error_code := 0;
			   SELF := R;
      END;
			dsNew := ROLLUP(cons2, LEFT.source_id=RIGHT.source_id and LEFT.record_id=RIGHT.record_id, addUpdateDate(LEFT, RIGHT));
      // Now handle records with only 1 concept
      dsNew1 := PROJECT(dsNew, addUpdateDate(LEFT, LEFT));
			
      // remove records that came in with an update date
      // and make the column number for the new update date records
      // 1 larger than the largest column.
			dsNew2 := PROJECT(dsNew1(existsflag=false), TRANSFORM(recordof(dsNew),
			   SELF.col:=LEFT.col+1;
			   SELF := LEFT;)
      );
			final :=cons2+dsNew2;
		
			return PROJECT(ungroup(final), recordof(cons)); 
end;
export BuildRec(dataset($.Layouts.l_entity) cons, 
								string ndxInfix) :=function 
			
			chunked:=ChunkValues(cons,ndxInfix);
			rec2 :=PROJECT(chunked, TRANSFORM(recordof(cons),
			SELF.entity_type := TRIM(StringLib.StringToUpperCase(LEFT.entity_type),LEFT,RIGHT);
			SELF := LEFT;));
			
			recIndex := $.Indexes.recIndex(rec2, NdxPrefix + ndxInfix + recSuffix); 
			
			return sequential(output(chunked,named('chunked')),buildindex(recIndex, overwrite)); 
end; 
/************************************************************ 
													BuildBitmapFile 
************************************************************/
 export BuildBitmapFile(dataset($.Layouts.l_entity) cons, 
												string ndxInfix, 
												string persistSuffix) := function 
		valSet := AllSort(cons, persistSuffix); 
		sortedValSet1 := SORT(valSet, source_id, value_hash, type_hash, record_id) ; 
		sortedValSet :=DEDUP(sortedValSet1, source_id, value_hash, type_hash, record_id); 
		// change to 4-byte words to fit more efficiently in the cpu 
		layout_b :={, MAXLENGTH(4096) 
		SplitLayout; 
		UNSIGNED bpos; // word number within data, 0 based 
		UNSIGNED bitpos; // bit position within byte 
		UNSIGNED4 m; }; 
/** 
	32 -bit words 
	record numbers 		         1         2         3         4         5         6         7         8
	rec               12345678901234567890123456789012345678901234567890123456789012345678901234567890 
	positions          1         2         3           1         2         3         1         2         3 			 
	bit				1234567890123456789012345678901212345678901234567890123456789012345678901234567890123456789012 
	word      0000000000000000000000000000000011111111111111111111111111111111222222222222222222222222222222 
*/
	layout_b getPositions(SplitLayout L) := TRANSFORM 
			SELF.bpos := TRUNCATE((L.record_id-1) / 32);// start byte numbering at 0(words 0-n) 
			bitposstart := L.record_id % 32; 
			SELF.bitpos := IF(bitposstart=0, 32, bitposstart); // start bit numbering at 1(bits 1-32) 
      SELF.m := POWER(2, SELF.bitpos-1);
			// SELF. m := MAP( bitposstart= 1 => 1 
											// , bitposstart= 2 => 2 
											// , bitposstart= 3 => 4 
											// , bitposstart= 4 => 8 
											// , bitposstart= 5 => 16 
											// , bitposstart= 6 => 32 
											// , bitposstart= 7 => 64 
											// , bitposstart= 8 => 128 
											// , bitposstart= 9 => 256 
											// , bitposstart= 10 => 512 
											// , bitposstart= 11 => 1024 
											// , bitposstart= 12 => 2048 
											// , bitposstart= 13 => 4096 
											// , bitposstart= 14 => 8192 
											// , bitposstart= 15 => 16384 
											// , bitposstart= 16 => 32768 
											// , bitposstart= 17 => 65536 
											// , bitposstart= 18 => 131072 
											// , bitposstart= 19 => 262144 
											// , bitposstart= 20 => 524288 
											// , bitposstart= 21 => 1048576 
											// , bitposstart= 22 => 2097152 
											// , bitposstart= 23 => 4194304 
											// , bitposstart= 24 => 8388608 
											// , bitposstart= 25 => 16777216 
											// , bitposstart= 26 => 33554432 
											// , bitposstart= 27 => 67108864 
											// , bitposstart= 28 => 134217728 
											// , bitposstart= 29 => 268435456 
											// , bitposstart= 30 => 536870912 
											// , bitposstart= 31 => 1073741824 
											// , bitposstart=  0 => 2147483648 
											// , 0); // 4294967296 
											// self.word := x'00'; 
											SELF. col_item := ROUNDUP(L.record_id/131072); //(16-kbytes * 8-bits) 
											SELF := L; 
				END; 
				bValSet :=PROJECT(sortedValSet, getPositions(LEFT)); 
				// already sorted by record_number, so it will be sorted by item number. 
				rValSet := ROLLUP(bValSet, 
													LEFT. source_id = RIGHT.source_id 
													AND LEFT.value_hash = RIGHT.value_hash 
													AND LEFT.type_hash = RIGHT.type_hash 
													AND LEFT.bpos = RIGHT.bpos , 
												TRANSFORM(layout_b, 
													SELF.m := LEFT.m + RIGHT.m; 
													self:=LEFT)); 
			$.Indexes.BitmapLayout toData(layout_b L) := TRANSFORM 
					SELF.offset := DATASET( [{L.bpos}], $.Indexes.layout_int); 
					self.word := DATASET([{L.m}], $.Indexes.layout_int); 
					SELF := L; 
			END; 
			pValSet2 := PROJECT(rValSet, toData(LEFT)); 
			$.Indexes.BitmapLayout rollToData($.Indexes.BitmapLayout L, $.Indexes.BitmapLayout R) :=TRANSFORM 
					SELF.record_id := R.record_id; 
					SELF.bpos := L.bpos; 
					SELF.word := L.word + R.word; 
					SELF.offset :=L.offset + R. offset; 
					SELF := L; 
			END; 
			
			pValSet3 := ROLLUP(pValSet2, 
												LEFT.source_id = RIGHT.source_id 
												AND LEFT.value_hash = RIGHT.value_hash 
												AND LEFT.type_hash = RIGHT.type_hash 
												AND LEFT.col_item = RIGHT.col_item , 
										rollToData(LEFT, RIGHT)); 
      pValSet4 := DISTRIBUTE(pValSet3, value_hash);
			retval :=output(pValSet4, , dtaPrefix + ndxInfix + bmpSuffix, OVERWRITE) ; 
			return retval; 
end; 
/************************************************************ 
										CompileBitmapData 
*  Compiles the BITMAP DATA file in the BITMAP DATA super file
*  into the single Bitmap data file that is used by Information Retrieval
************************************************************/
 export CompileBitmapData(STRING namefix) := FUNCTION 
			inpValSet := $.Indexes.BitmapDataSuperFile; 
			
			bmpdata := SEQUENTIAL(
									$.utility.removeIndexFromSF($.Indexes.BMP_DATA_FILENAME, $.Indexes.BMP_DATA_FILENAME +'-'+ namefix), 
									output(inpValSet,,$.Indexes.BMP_DATA_FILENAME +'-'+ namefix, OVERWRITE)); 
			return bmpdata; 
	END; 
 export CompileBitmapDataDaily(STRING namefix) := FUNCTION 
			inpValSet := $.Indexes.DailyBitmapDataSuperFile; 
			bmpdata := SEQUENTIAL(
												$.utility.removeIndexFromSF($.Indexes.DAILY_BMP_DATA_FILENAME, $.Indexes.DAILY_BMP_DATA_FILENAME +'-'+ namefix), 
													output(inpValSet,,$.Indexes.DAILY_BMP_DATA_FILENAME +'-'+ namefix, OVERWRITE)); 
			return bmpdata; 
	END; 
/************************************************************ 
											BuildBitmapNdx 
*  Builds the Bitmap index used by Information Retrieval
************************************************************/
 export BuildBitmapNdx(STRING namefix) := function 
			inpValSet := DATASET($.Indexes.BMP_DATA_FILENAME +'-'+ namefix, {$.Indexes.BitmapLayout, UNSIGNED8 fpos{virtual(fileposition) }}, THOR); 
			bitmapIndex := $.Indexes.BitmapIndex(inpValSet, $.Indexes.BMP_KEY_FILENAME +'-'+ namefix); 
			bmpindex :=SEQUENTIAL(
									$.utility.removeIndexFromSF($.Indexes.BMP_KEY_FILENAME, $.Indexes.BMP_KEY_FILENAME +'-'+ namefix), 
									 BUILDINDEX(bitmapindex , OVERWRITE)); 
			return bmpindex; 
 end; 
 export BuildBitmapNdxDaily(STRING namefix) := function 
			// inpValSet := $.Indexes.DailyBitmapData; 
			inpValSet := DATASET($.Indexes.DAILY_BMP_DATA_FILENAME +'-'+ namefix, {$.Indexes.BitmapLayout, UNSIGNED8 fpos{virtual(fileposition) }}, THOR); 
			bitmapIndex := $.Indexes.BitmapIndex(inpValSet, $.Indexes.DAILY_BMP_KEY_FILENAME +'-'+ namefix); 
			bmpindex :=SEQUENTIAL(
									$.utility.removeIndexFromSF($.Indexes.DAILY_BMP_KEY_FILENAME, $.Indexes.DAILY_BMP_KEY_FILENAME +'-'+ namefix), 
									 BUILDINDEX(bitmapindex , OVERWRITE)); 
			return bmpindex; 
 end; 
/************************************************************ 
											CompileWordPosNdx 
*  Compiles the WORD POSITION indexes in the WORD POSITION super key
*  into the single index used by Information Retrieval
************************************************************/
export CompileWordPosNdx(STRING namefix) := function
   colWordPosSK := $.Indexes.ColWordPosIdxSuperKey;
   CompiledColWordPosIdx(dataset(recordof(colWordPosSK)) ds, string filename) := index(ds, {source_id, record_id, value_hash}, {col, col_position, entity_type}, filename);
   compiledNdx := CompiledColWordPosIdx(colWordPosSK, $.Indexes.WORD_POS_COMBINDEX +'-'+ namefix);
   retIndex := SEQUENTIAL(
									$.utility.removeIndexFromSF($.Indexes.WORD_POS_COMBINDEX, $.Indexes.WORD_POS_COMBINDEX +'-'+ namefix), 
									BUILDINDEX(compiledNdx, OVERWRITE));
   RETURN retIndex;
end;
export CompileWordPosNdxDaily(STRING namefix) := function
   colWordPosSK := $.Indexes.DailyColWordPosIdxSuperKey;
   CompiledColWordPosIdx(dataset(recordof(colWordPosSK)) ds, string filename) := index(ds, {source_id, record_id, value_hash}, {col, col_position, entity_type}, filename);
   compiledNdx := CompiledColWordPosIdx(colWordPosSK, $.Indexes.DAILY_WORD_POS_COMBINDEX +'-'+ namefix);
   retIndex := SEQUENTIAL(
									$.utility.removeIndexFromSF($.Indexes.DAILY_WORD_POS_COMBINDEX, $.Indexes.DAILY_WORD_POS_COMBINDEX +'-'+ namefix), 
									BUILDINDEX(compiledNdx, OVERWRITE));
   RETURN retIndex;
end;
/************************************************************ 
*											CompileRecData 
*
*  Compiles the REC (Record) indexes in the REC super key
*  into the single dataset used by Information Retrieval
************************************************************/
export CompileRecData(STRING namefix) := function
   inpValSet := PROJECT($.Indexes.RecSuperKey, $.Indexes.RecDataLayout);
   recData := SEQUENTIAL(
	 		$.utility.removeIndexFromSF($.Indexes.REC_DATA_FILENAME, $.Indexes.REC_DATA_FILENAME +'-'+ namefix), 
	 output(inpValSet,,$.Indexes.REC_DATA_FILENAME +'-'+ namefix, OVERWRITE, __COMPRESSED__)); 
   RETURN recData;
end;
export CompileRecDataDaily(STRING namefix) := function
   inpValSet := PROJECT($.Indexes.DailyRecSuperKey, $.Indexes.RecDataLayout);
   recData := SEQUENTIAL(	 		
				$.utility.removeIndexFromSF($.Indexes.DAILY_REC_DATA_FILENAME, $.Indexes.DAILY_REC_DATA_FILENAME +'-'+ namefix), 
				output(inpValSet,,$.Indexes.DAILY_REC_DATA_FILENAME +'-'+ namefix, OVERWRITE, __COMPRESSED__)); 
   RETURN recData;
end;
/************************************************************ 
*											CompileRecNdx 
*
*  Compiles the REC (Record) indexes in the REC super key
*  into the single index used by Information Retrieval
************************************************************/
export CompileRecNdx(STRING namefix) := function
   recData := DATASET($.Indexes.REC_DATA_FILENAME +'-'+ namefix
      , {$.Indexes.RecDataLayout, UNSIGNED8 fpos{virtual(fileposition) }}, THOR);
   compiledNdx := $.Indexes.RecIndexThin(recData, $.Indexes.REC_COMBINDEX +'-'+ namefix);
   retIndex := SEQUENTIAL(	 		
				$.utility.removeIndexFromSF($.Indexes.REC_COMBINDEX, $.Indexes.REC_COMBINDEX +'-'+ namefix), 
				BUILDINDEX(compiledNdx, OVERWRITE));
   RETURN retIndex;
end;
export CompileRecNdxDaily(STRING namefix) := function
   recData := DATASET($.Indexes.DAILY_REC_DATA_FILENAME +'-'+ namefix
      , {$.Indexes.RecDataLayout, UNSIGNED8 fpos{virtual(fileposition) }}, THOR);
   compiledNdx := $.Indexes.RecIndexThin(recData, $.Indexes.DAILY_REC_COMBINDEX +'-'+ namefix);
   retIndex := SEQUENTIAL(	 		
				$.utility.removeIndexFromSF($.Indexes.DAILY_REC_COMBINDEX, $.Indexes.DAILY_REC_COMBINDEX +'-'+ namefix), 
				BUILDINDEX(compiledNdx, OVERWRITE));
   RETURN retIndex;
end;
/**
*  BuildWordPosNdx( Concept Dataset, Name, Persist Suffix)
*
*  Creates the WORD Position index used to help search on phrases in 
*  Information Retrieval (CDCE Search)
*/
   export BuildWordPosNdx(Dataset($.Layouts.l_entity) cons,
                           string ndxInfix,
                           string persistSuffix) := function
									
		conceptsDS := AllSort(cons, persistSuffix);
		ConceptsSorted := dedup(sort(ConceptsDS(entity_type != ''), source_id, record_id, value_hash, col, col_item, col_position)
                                                               , source_id, record_id, value_hash, col, col_item, col_position);
		// 2012-04-15 - ubarsmx - remove item from criteria because colWordPosIndex does not have it
		ConceptsSorted resetPosition(recordof(ConceptsSorted) L, recordof(ConceptsSorted) R) := transform
			self.col_position := if (l.source_id = r.source_id and l.record_id = r.record_id and L.col = R.col, L.col_position+1, 1);
			self := R;
		end;
		cleanSet := sort(ConceptsSorted, source_id, record_id, col, col_item, col_position);
		inputSet := project(cleanSet, transform(recordof(cleanSet), self.col_position := 0, self := left));
		dsPosNormed := iterate(inputSet, resetPosition(left, right));
		
		buildTheIndex := buildindex($.Indexes.ColWordPosIdx(dsPosNormed, NdxPrefix + ndxInfix + posSuffix), overwrite);
		return buildTheIndex;
	end;

/**
*  Deletepersist
*  Removes the persist files associated with building indexes from concept files
*/
 export Deletepersist(string nameSuffix):=NOTHOR(sequential( 
			NOTHOR(FileServices.DeleteLogicalFile(persistPrefix + 'CleanEntities::'+ nameSuffix)), 
			NOTHOR(FileServices.DeleteLogicalFile(persistPrefix + 'SplitWords::'+ nameSuffix) ), 
			// FileServices.DeleteLogicalFile(persistPrefix + 'AllSort::' + nameSuffix), 
			NOTHOR(FileServices.DeleteLogicalFile(persistPrefix + 'CountWords::'+ nameSuffix) ))
	) ; 

/**
*  removeBuildAddSourceCounts( Concept Dataset, Name )
*
*  Used to build the indexes and data files that are used to generate a
*  source list in Information Retrieval
*
*  Removes the SOURCE LIST from the SOURCE LIST super file
*  Generates the SOURCE LIST file for this data set
*  Adds the new SOURCE LIST to the SOURCE LIST super file
*  Compiles the SOURCE LIST FILE used by IR frome the SOURCE LIST super file
*  Compiles the CONCEPT LIST FILE used by IR frome the SOURCE LIST super file
*/
/*
 export removeBuildAddSourceCountFile(DATASET($.Layouts.l_entity) cons, string nameInfix) := sequential( 
		SourceList.BuildSourceConceptCountFile(cons, dtaPrefix +nameInfix+ sccSuffix) 
	);
 export removeBuildAddSourceCounts() := sequential( 
		SourceList.generateSourceListFile($.Indexes.sccfilenames), 
		SourceList.generateConceptListFile($.Indexes.sccfilenames) 
*/
/**
*  removeBuildAdd( Concept Dataset, Name )
*
*  Used to build the indexes and data files. These super keys are later compiled into a single index before 
*  being deployed to Roxie.
*  
*  Creates the source count dataset used by the source list
*  Removes the VAL (values) index from the VAL super key
*  Removes the WORD COUNT index from the WORD COUNT super key
*  Removes the REC (records) index from the REC super key
*  Removes the WORD POSITION index from the WORD POSITION super key 
*  Removes the BITMAP data file from the BITMAP data super file
*  Generates the VAL (values) index
*  Generates the WORD COUNT index
*  Generates the REC (records) index
*  Generates the BITMAP data file
*  Generates the WORD POSITION index, used by the Bitmap search for phrase processing
*  Adds the new VAL (values) index to the VAL super key
*  Adds the new WORD COUNT index to the WORD COUNT super key
*  Adds the new REC (records) index to the REC super key
*  Adds the new WORD POSITION index to the WORD POSITION super key 
*  Adds the new BITMAP data file to the BITMAP data super file
*  Deletes the persist files generated in the above processes
*
*  2011/06/27 - Val and Mph index builds commented out
*/
export buildEntityTypeList():= FUNCTION
ds:=table($.Indexes.RecSuperKey,{source_id,entity_type},source_id,entity_type);
ds1:= project(ds,$.Layouts.l_entitytypelist);

return output(ds1,,$.Indexes.ENTITY_LIST_FILENAME, OVERWRITE);
END;
 export removeBuildAdd(dataset($.Layouts.l_entity) incons, 
															string nameInfix) := FUNCTION
						
						
						Unicode newDate:=(UNICODE)StringLib.GetDateYYYYMMDD();
						shared cons :=AddConceptValue(incons,$.EntityTypes.UPDATE_DATE,newDate,'Update Date')
                   : PERSIST('~persist::' + nameInfix + '.concept1');
						//batchtaskswu := WorkunitServices.WorkunitList(lowwuid := '', jobname := '*BATCHTASKS*', state := 'running')(wuid <> WORKUNIT);
						result:=sequential( 
           //     IF(COUNT(batchtaskswu) > 0, FAIL('*BATCHTASKS running')),
				//				removeBuildAddSourceCountFile(cons,nameInfix) ,
								// Build indexes and data files from this concept file
								// BuildVal(cons, nameInfix, nameInfix), 
								BuildWordCnt(cons, nameInfix, nameInfix), 								
								BuildRec(cons, nameInfix), 
								BuildBitmapFile(cons, nameInfix, nameInfix), 
								BuildWordPosNdx(cons, nameInfix, nameInfix)
					);
					return result;
				
					END;

/**
*  saveGeneration
*
*  Saves a copy of the current compiled indexes to ones labeled .genN
*  where N is the generation number.
*  
*/ 
export moveDataset(STRING basename, STRING fromExtension, STRING toExtension, BOOLEAN deleteTo) := FUNCTION
   STRING from := basename + fromExtension;
   STRING to := basename + toExtension;
   RETURN SEQUENTIAL(
      IF(deleteTo = TRUE AND NOTHOR(FileServices.FileExists(to)), NOTHOR(FileServices.deleteLogicalFile(to))),
      IF(NOTHOR(FileServices.FileExists(from)) AND NOT NOTHOR(FileServices.FileExists(to)), NOTHOR(FileServices.RenameLogicalFile(from, to)))
   );
END;
export copyDataset(STRING basename, STRING fromExtension, STRING toExtension, BOOLEAN deleteTo) := FUNCTION
   STRING from := basename + fromExtension;
   STRING to := basename + toExtension;
   RETURN SEQUENTIAL(
      IF(deleteTo = TRUE AND NOTHOR(FileServices.FileExists(to)), NOTHOR(FileServices.deleteLogicalFile(to))),
      IF(NOTHOR(FileServices.FileExists(from)) AND NOT NOTHOR(FileServices.FileExists(to)), NOTHOR(FileServices.Copy(from, ThorLib.cluster(), to)))
   );
END;
/**
* Populates the (daily) superkey files used by IR
* Each superkey holds a single file of the same name with an extension of the 
* WORKUNIT that created it.
*/
export populateDailyCompiledSF(String wkunit) := SEQUENTIAL(
   NOTHOR(FileServices.createSuperFile($.Indexes.DAILY_BMP_DATA_FILENAME, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.DAILY_BMP_DATA_FILENAME)),
   $.Utility.AddIndexToSuperfile($.Indexes.DAILY_BMP_DATA_FILENAME, $.Indexes.DAILY_BMP_DATA_FILENAME +'-'+wkunit),
   NOTHOR(FileServices.createSuperFile($.Indexes.DAILY_BMP_KEY_FILENAME, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.DAILY_BMP_KEY_FILENAME)),
   $.Utility.AddIndexToSuperfile($.Indexes.DAILY_BMP_KEY_FILENAME, $.Indexes.DAILY_BMP_KEY_FILENAME +'-'+wkunit),
   NOTHOR(FileServices.createSuperFile($.Indexes.DAILY_REC_DATA_FILENAME, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.DAILY_REC_DATA_FILENAME)),
   $.Utility.AddIndexToSuperfile($.Indexes.DAILY_REC_DATA_FILENAME, $.Indexes.DAILY_REC_DATA_FILENAME +'-'+wkunit),
   NOTHOR(FileServices.createSuperFile($.Indexes.DAILY_REC_COMBINDEX, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.DAILY_REC_COMBINDEX)),
   $.Utility.AddIndexToSuperfile($.Indexes.DAILY_REC_COMBINDEX, $.Indexes.DAILY_REC_COMBINDEX +'-'+wkunit),
   NOTHOR(FileServices.createSuperFile($.Indexes.DAILY_WORD_POS_COMBINDEX, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.DAILY_WORD_POS_COMBINDEX)),
   $.Utility.AddIndexToSuperfile($.Indexes.DAILY_WORD_POS_COMBINDEX, $.Indexes.DAILY_WORD_POS_COMBINDEX +'-'+wkunit)
);
/**
* Populates the (main) superkey files used by IR
* Each superkey holds a single file of the same name with an extension of the 
* WORKUNIT that created it.
*/
export populateCompiledSF(String wkunit) := SEQUENTIAL(
   NOTHOR(FileServices.createSuperFile($.Indexes.BMP_DATA_FILENAME, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.BMP_DATA_FILENAME)),
   $.Utility.AddIndexToSuperfile($.Indexes.BMP_DATA_FILENAME, $.Indexes.BMP_DATA_FILENAME +'-'+wkunit),
   NOTHOR(FileServices.createSuperFile($.Indexes.BMP_KEY_FILENAME, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.BMP_KEY_FILENAME)),
   $.Utility.AddIndexToSuperfile($.Indexes.BMP_KEY_FILENAME, $.Indexes.BMP_KEY_FILENAME +'-'+wkunit),
   NOTHOR(FileServices.createSuperFile($.Indexes.REC_DATA_FILENAME, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.REC_DATA_FILENAME)),
   $.Utility.AddIndexToSuperfile($.Indexes.REC_DATA_FILENAME, $.Indexes.REC_DATA_FILENAME +'-'+wkunit),
   NOTHOR(FileServices.createSuperFile($.Indexes.REC_COMBINDEX, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.REC_COMBINDEX)),
   $.Utility.AddIndexToSuperfile($.Indexes.REC_COMBINDEX, $.Indexes.REC_COMBINDEX +'-'+wkunit),
   NOTHOR(FileServices.createSuperFile($.Indexes.WORD_POS_COMBINDEX, FALSE, TRUE)),
   NOTHOR(FileServices.clearSuperFile($.Indexes.WORD_POS_COMBINDEX)),
   $.Utility.AddIndexToSuperfile($.Indexes.WORD_POS_COMBINDEX, $.Indexes.WORD_POS_COMBINDEX +'-'+wkunit)
);
/**
*  CleanDailySuperfiles 
*
*  Empties the "daily" superfiles and removes the compiled files.
*  The "daily" files are used until the "main" files can be rebuilt
*  and redeployed. This is for performance in adding data.
*/
export CleanDailySuperfiles(STRING namefix) := FUNCTION
return SEQUENTIAL(
								// FileServices.clearSuperFile($.Indexes.DAILY_BMP_DATA_SUPERFILE),
								NOTHOR(IF(FileServices.FileExists($.Indexes.DAILY_BMP_DATA_FILENAME),
                   FileServices.deleteLogicalFile($.Indexes.DAILY_BMP_DATA_FILENAME))),
                NOTHOR(IF(FileServices.FileExists($.Indexes.DAILY_BMP_KEY_FILENAME),
                   FileServices.deleteLogicalFile($.Indexes.DAILY_BMP_KEY_FILENAME))),
								// FileServices.clearSuperFile($.Indexes.DAILY_REC_KEY_FILENAME),
               NOTHOR( IF(FileServices.FileExists($.Indexes.DAILY_REC_DATA_FILENAME),
								   FileServices.deleteLogicalFile($.Indexes.DAILY_REC_DATA_FILENAME))),
                NOTHOR(IF(FileServices.FileExists($.Indexes.DAILY_REC_COMBINDEX),
								   FileServices.deleteLogicalFile($.Indexes.DAILY_REC_COMBINDEX))),
								// FileServices.clearSuperFile($.Indexes.DAILY_WORD_POS_SUPERFILE),
                NOTHOR(IF(FileServices.FileExists($.Indexes.DAILY_WORD_POS_COMBINDEX),
								   FileServices.deleteLogicalFile($.Indexes.DAILY_WORD_POS_COMBINDEX))),
             //   removeBuildAdd(EmptyConceptDsForIR, 'emptydefault'),
                // All of the parts from DailyBatchTasks needed with the empty dataset
								CompileBitmapDataDaily(namefix),							
							  BuildBitmapNdxDaily(namefix) ,
								CompileRecDataDaily(namefix),
								CompileRecNdxDaily(namefix),
								CompileWordPosNdxDaily(namefix),
                populateDailyCompiledSF(namefix)
);
END;
/**
*  RollupRecentIndexes
*
*
*  Compiles the BITMAP DATA super file into a single file 
*  Generates the BITMAP index from the compiled BITMAP DATA files
*  Compiles the REC index super key into a single index
*  Compiles the WORD POSITION super key into a single index
*/
export RollupRecentIndexes(STRING namefix) := FUNCTION
return SEQUENTIAL(
								// Verify all of the classification markings in records
								//verifyClassificationsDaily(),
            //    IF(COUNT(WorkunitServices.WorkunitList(lowwuid := '', jobname := '*SEARCHABLE*', state := 'running')) > 0
              //      , FAIL('removeBuildAdd running')),
              //  removeBuildAdd(EmptyConceptDsForIR, 'emptydefault'), // rebuild test data
               // removeBuildAddSourceCounts(),
								CompileBitmapDataDaily(namefix),							
							  BuildBitmapNdxDaily(namefix) ,
								CompileRecDataDaily(namefix),
								CompileRecNdxDaily(namefix),
								CompileWordPosNdxDaily(namefix),
             //   populateDailyCompiledSF(WORKUNIT)
								);
								END;
/**
*  RollupIndexes
*
*  Compiles the BITMAP DATA super file into a single file 
*  Generates the BITMAP index from the compiled BITMAP DATA files
*  Compiles the REC index super key into a single index
*  Compiles the WORD POSITION super key into a single index
*/
export RollupIndexes(STRING namefix) := FUNCTION
return SEQUENTIAL(
								//  Verify all of the classification markings in records
								//verifyClassifications(),
                //  Create the main compiled indexes
								CompileBitmapData(namefix),
							  BuildBitmapNdx(namefix),
								CompileRecData(namefix),
								CompileRecNdx(namefix),
								CompileWordPosNdx(namefix),
                // Compile the daily files
                if (~$.indexes.dailybmpfilenames='',RollupRecentIndexes(namefix)),
                populateCompiledSF(namefix)
);

END;
/**
*  IRMetaDataBatchTashs
*
*  Generates meta data used to assist searching in Information Retrieval
* 
*  Compiles the WORD COUNT indexes into a single index of unique words across the sources
*  Generates the substring indexes used for wild card searching
*/
export IRMetaDataBatchTasks := SEQUENTIAL(
								BuildSingleWordCountNdx(),
								BuildWordSubstringNdx(),
								BuildEntityTypeList()
);
								
end;
