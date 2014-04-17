import $;
import lib_fileservices;
//import BitmapSearch;

 export Indexes := MODULE
 
 EXPORT ENTITY_LIST_FILENAME:='~indexer::data::EntityList'; 
 export REC_KEY_FILENAME :='~indexer::idx::RecSK'; 
 export VAL_KEY_FILENAME := '~indexer::idx::ValSK'; 
 export WORD_CNT_SINGLEINDEX := '~indexer::idx::WordCntIndex'; 
 export FILE_KEY_FILENAME := '~indexer::idx::fileLstSK'; 
 export BMP_KEY_FILENAME := '~indexer::idx::BitmapSK'; 
 export BMP_DATA_FILENAME := '~indexer::data::Bitmap'; 
 export BMP_DATA_SUPERFILE := '~indexer::data::BitmapSF'; 
 export SUBSTRING_MIDDLE_FILENAME := '~indexer::idx::SubstringMiddle'; 
 export SUBSTRING_FIRSTLAST_FILENAME :='~indexer::idx::SubstringFirstLast'; 

 export SOURCE_LIST_SUPERFILE := '~indexer::data::sourceListSF'; 
 export SOURCE_LIST_FILE := '~indexer::data::sourceListFile';
 export CONCEPT_LIST_FILE := '~indexer::data::conceptListFile';
 export WORD_CNT_SK := '~indexer::idx::WordCntSK'; 
 
 export WORD_POS_SUPERFILE := '~indexer::data::colWordPosSF';
 export WORD_POS_COMBINDEX := '~indexer::idx::CompiledColWordPosNdx';
 export REC_COMBINDEX := '~indexer::idx::CompiledRecNdx';
 export REC_DATA_FILENAME :='~indexer::data::CompiledRecData'; 

/*
*  Superfiles for quick moving data.
*/
 export DAILY_BMP_DATA_FILENAME := '~indexer::data::DailyBitmap'; 
 export DAILY_BMP_DATA_SUPERFILE := '~indexer::data::DailyBitmapSF'; 
 export DAILY_BMP_KEY_FILENAME := '~indexer::idx::DailyBitmapSK'; 
 export DAILY_REC_KEY_FILENAME :='~indexer::idx::DailyRecSK'; 
 export DAILY_REC_COMBINDEX := '~indexer::idx::DailyCompiledRecNdx';
 export DAILY_REC_DATA_FILENAME :='~indexer::data::DailyCompiledRecData'; 
 export DAILY_VAL_KEY_FILENAME := '~indexer::idx::DailyValSK'; 
 export DAILY_WORD_CNT_SK := '~indexer::idx::DailyWordCntSK'; 
 export DAILY_WORD_POS_SUPERFILE := '~indexer::data::DailyColWordPosSF';
 export DAILY_WORD_POS_COMBINDEX := '~indexer::idx::DailyCompiledColWordPosNdx';
  


		export Layout_int := {
				 UNSIGNED4 val;
			 };

   export layout_ret := {
     DATASET(layout_int) word {MAXLENGTH(32768)};
     DATASET(layout_int) offset {MAXLENGTH(32768)};
   };
	 
	 

 
/*
*
*
Value index
*
*
*/
				
 export ValLayout := {, maxlength($.Constants.INDEX_LAYOUT_MAX_LEN) 
		unicode searchable_value, 
		string entity_type, 
		integer8 value_hash, 
		integer8 type_hash, 
		integer8 source_id, 
		unsigned8 record_id, 
		unsigned2 col, 
		unsigned2 col_item, 
		unsigned2 col_position, 
}; 
					
 export ValIndex(dataset(ValLayout) ds, string filename) := 
		index(ds, 
					{, 	maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
							value_hash , 
							type_hash, 
							source_id, 
							record_id, 
							col, 
							col_item, 
							col_position,
						},
						{, maxlength($.constants.INDEX_LAYOUT_MAX_LEN)
							entity_type 
						},
						filename);

export ValSuperKey :=ValIndex(dataset( [] , valLayout) , VAL_KEY_FILENAME) ; 
 export ColWordPosIdx(dataset(ValLayout) ds, string filename) := 
		index(ds, {source_id, record_id, value_hash}, {col, col_position, entity_type}, filename);
 export ColWordPosCompiledIdx := ColWordPosIdx(dataset([], ValLayout), WORD_POS_COMBINDEX);
 export DailyColWordPosCompiledIdx := ColWordPosIdx(dataset([], ValLayout), DAILY_WORD_POS_COMBINDEX);
 
 
/*
*
*
substring middle index
*
*
*/
 export SubstringMiddleLayout :={, MAXLENGTH($.constants.INDEX_LAYOUT_MAX_LEN) 
		UNSIGNED2 firstletter; 
		UNSIGNED2 secondletter; 
		UNSIGNED2 thirdletter; 
		UNICODE3 triple; 
		UNICODE searchable_value; 
}; 

 export SubstringMiddleIndex(dataset(SubstringMiddleLayout) ds, string filename) :=INDEX
					(ds, 
						{ 
							firstletter, 
							secondletter, 
							thirdletter 
						} , 
						{, maxlength(256) 
							triple, 
							searchable_value 
						}, 
					filename) ; 
export SubstringMiddleIndexKey := SubstringMiddleIndex(dataset([], SubstringMiddleLayout), SUBSTRING_MIDDLE_FILENAME); 
 
/*
*
*
substring first-last index
*
*
*/
					
export SubstringFirstLastLayout := {, MAXLENGTH($.constants.INDEX_LAYOUT_MAX_LEN) 
		UNSIGNED2 firstletter; 
		UNSIGNED2 lastletter; 
		UNICODE2 letters; 
		UNICODE searchable_value; 
} ; 
					
 export SubstringFirstLastIndex(dataset(SubstringFirstLastLayout) ds, 
																string filename) :=INDEX (ds, 
					{ 
						firstletter, 
						lastletter 
					} , 
					{, maxlength(256) 
						searchable_value 
					} ,
				filename) ; 
 export substringFirstLastIndexKey :=SubstringFirstLastIndex(DATASET( [], SubstringFirstLastLayout), SUBSTRING_FIRSTLAST_FILENAME) ; 
				
/*
*
*
record index
*
*
*/


export RecDataLayout := {
		string id:='',
    string entity_type, 
    unicode searchable_value, 
    unicode original_value, 
    unicode pre_display_text:= u'', 
    unicode post_display_text:= u'',
    unsigned1 error_code, 
    unsigned8 source_id, 
    unsigned8 record_id, 
    unsigned2 col, 
    unsigned2 col_item, 
    string queryable:='false' ,
    string field_label :='',
 } ;
 
 export RecIndexThin(dataset({recDataLayout, UNSIGNED8 fpos{virtual(fileposition)}}) ds, string filename) :=
		index(ds, 
					{
						source_id, 
						record_id, 
					} , 
					{
            fpos
          } , 
					filename
         ) ;
  export RecIndex(dataset($.layouts.l_entity) ds, string filename) :=
		index(ds, 
					{, 	maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
						source_id, 
						record_id, 
					} , 
					{, 	maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
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
 export RecDataCombined := dataset(REC_DATA_FILENAME, RecDataLayout, THOR, __COMPRESSED__);
 export RecIdxCombined := RecIndexThin(DATASET([], {RecDataLayout, UNSIGNED8 fpos{virtual(fileposition) }}) , REC_COMBINDEX);
 export DailyRecDataCombined := dataset(DAILY_REC_DATA_FILENAME, RecDataLayout, THOR, __COMPRESSED__);
 export DailyRecIdxCombined := RecIndexThin(DATASET([], {RecDataLayout, UNSIGNED8 fpos{virtual(fileposition) }}) , DAILY_REC_COMBINDEX);

/*
*
*
wotd count index
*
*
*/
 
 
 export WordCntLayout := {, maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
		integer8 value_hash, 
		integer8 type_hash, 
		unicode searchable_value, 
		string entity_type, 
		unsigned6 word_cnt, 
}; 

 export WordCntIndex(dataset(WordCntLayout) ds, string filename) :=
		index(ds, 
					{, 	maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
						value_hash, 
						type_hash 
					}, 
					{, 	maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
						searchable_value, 
						entity_type , 
						word_cnt 
					}, 
					filename) ;
export CntSingleIndex := WordCntIndex(dataset( [], wordCntLayout), WORD_CNT_SINGLEINDEX) ; 
 
/*
*
*
file list index
*
*
*/
 
export FileListLayout := {, maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
	string concept_name, 
	string this_file_name, 
	string root_file, 
	string date_added, 
	integer8 source_hash, 
}; 
  
 export FileListIndex(dataset(FileListLayout) ds, string filename) :=
				index(ds , 
				{, maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
					source_hash, 
				}, 
				{, 	maxlength($.constants.INDEX_LAYOUT_MAX_LEN) 
					concept_name, 
					this_file_name, 
					root_file, 
					date_added, 
				} , 
				filename) ;
 export FileSuperKey :=FileListIndex(DATASET( [], FileListLayout), FILE_KEY_FILENAME) ; 
				
/*
*
*
bitmap index
*
*
*/				
 export BitmapLayout := {
		ValLayout; 
		UNSIGNED bpos; // word number within data, 0 based 
		DATASET(layout_int) word{MAXLENGTH(20480)}; 
		DATASET(layout_int) offset{MAXLENGTH(20480)}; 
	}; 
 export BitmapIndex(dataset({BitmapLayout,UNSIGNED8 fpos{virtual(fileposition)}}) ds, string filename) :=
		index(ds, 
					{
						value_hash, type_hash, source_id, col_item, fpos
					}, 
					filename) ; 
export BitmapData := DATASET(BMP_DATA_FILENAME, {BitmapLayout, UNSIGNED8 fpos{virtual(fileposition) }}, THOR); 
 export BitmapSuperKey := BitmapIndex(dataset( [] , {BitmapLayout , UNSIGNED8 fpos{virtual(fileposition)}}), BMP_KEY_FILENAME);  
 export DailyBitmapData := DATASET(DAILY_BMP_DATA_FILENAME, {BitmapLayout, UNSIGNED8 fpos{virtual(fileposition) }}, THOR); 
 export DailyBitmapSuperKey := BitmapIndex(dataset( [] , {BitmapLayout , UNSIGNED8 fpos{virtual(fileposition)}}), DAILY_BMP_KEY_FILENAME); 
 
								
 
  /*
   * Changes to aggregate the datasets used by BatchTasks and DailyBatchTasks on
   * an as needed basis instead of having them in a SuperFile
 //*/
  export STRING oldestDate := '1970-01-01T00:00:01';
  // Find the age of the previous MAIN index files, built by BatchTasks
  shared mainRecData := TOPN(NOTHOR(FileServices.logicalFileList(REC_DATA_FILENAME[2..] + '-*')), 1, -modified);
  export mainBmpData := TOPN(NOTHOR(FileServices.logicalFileList(BMP_DATA_FILENAME[2..] + '-*')), 1, -modified);
  shared mainPosData := TOPN(NOTHOR(FileServices.logicalFileList(WORD_POS_COMBINDEX[2..] + '-*')), 1, -modified);
  export STRING mainRecDate := mainRecData[1].modified;
  export STRING mainBmpDate := mainBmpData[1].modified;
  export STRING mainPosDate := mainPosData[1].modified;
  shared layout_name := {
     STRING name {MAXLENGTH(1024000)};
  };
	
  export STRING fileNameList(STRING fileNameRegex, STRING compareDate) := FUNCTION
     list1 := NOTHOR(FileServices.LogicalFileList(fileNameRegex)(cluster = $.Constants.CLUSTER_NAME));
     list2 := list1($.Utility.newer(compareDate, modified));
     filenames1 := PROJECT(list2, layout_name);
     filenames2 := ROLLUP(filenames1, TRUE, TRANSFORM(layout_name, SELF.name := LEFT.name + ',' + RIGHT.name; SELF := LEFT));
     STRING filenames := filenames2[1].name;
     RETURN filenames;
  END;
	
	   export combinedBmpRec := {
     UNSIGNED4 search_id := 0;
     unsigned2 stack_id;
     unsigned8 opcode_num;
     unicode term {MAXLENGTH(256)}, 
     recordof(BitmapSuperKey);
   };
	 
  // Handle Rec Index dataset
  export STRING dailyrecfilenames := fileNameList('indexer::idx::*_rec', mainRecDate);
  export DailyRecSuperKey := RecIndex(dataset( [], $.Layouts.l_entity), '~{'+dailyrecfilenames+'}') ;
  export STRING recfilenames := fileNameList('indexer::idx::*_rec', oldestDate);
  export RecSuperKey := RecIndex(dataset( [], $.Layouts.l_entity), '~{'+recfilenames+'}') ;
  // Handle Bmp Data dataset
  export STRING dailybmpfilenames := fileNameList('indexer::data::*_bmp', mainBmpDate);
  export DailyBitmapDataSuperFile := DATASET('~{'+dailybmpfilenames+'}', BitmapLayout, THOR);
  export STRING bmpfilenames := fileNameList('indexer::data::*_bmp', oldestDate);
  export BitmapDataSuperFile := DATASET('~{'+bmpfilenames+'}', BitmapLayout, THOR);
  // Handle Pos Index dataset
  export STRING dailyPosfilenames := fileNameList('indexer::idx::*_pos', mainPosDate);
  export DailyColWordPosIdxSuperKey := ColWordPosIdx(dataset( [], ValLayout), '~{'+dailyPosfilenames+'}') ;
  export STRING Posfilenames := fileNameList('indexer::idx::*_pos', oldestDate);
  export ColWordPosIdxSuperKey := ColWordPosIdx(dataset( [], ValLayout), '~{'+Posfilenames+'}') ;
  // Handle Cnt Index dataset
  export STRING cntfilenames := fileNameList('indexer::idx::*_cnt', oldestDate);
  export CntSuperKey := WordCntIndex(dataset( [], wordCntLayout), '~{'+cntfilenames+'}') ;
  // Handle source entity count (cc) file name
  export STRING sccfilenames := '~{'+fileNameList('indexer::data::*scc', oldestDate)+'}';
end;
