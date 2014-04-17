import indexer;
/*dsinput, id 0ac60b3c_4fa5_4720_98d6_8ab8139065ab*/
/*Dataset Input*/
l_chin := RECoRD, LOCALE('CN')
UNICODE R,
UNICODE CREATED_AT,
UNICODE STATUSID,
UNICODE TXT,
UNICODE SOURCE,
UNICODE FAVORITED,
UNICODE TRUNCATED,
UNICODE IN_REPLY_TO_STATUS_ID,
UNICODE IN_REPLY_TO_USER_ID,
UNICODE IN_REPLY_TO_SCREEN_NAME,
UNICODE MID,
UNICODE32 BMIDDLE_PIC,
UNICODE32 ORIGINAL_PIC,
UNICODE32 THUMBNAIL_PIC,
UNICODE32 REPOSTS_COUNT,
UNICODE32 COMMENTS_COUNT,
UNICODE32 ANNOTATIONS,
UNICODE32 GEO,
UNICODE32 USERID,
UNICODE32 RETWEETEDSTATUSID,
UNICODE32 STATUS_TYPEID,
UNICODE32 CTISTATUS,
UNICODE32 tTYPE,
UNICODE32 PARENTID,
UNICODE32 ATUSERID,
UNICODE32 IS_RETWEETED,
UNICODE32 CHANNEL,
UNICODE32 IS_IMPORTANT,
UNICODE32 MOOD,
UNICODE32 KEYWORDS,
UNICODE32 DEAL_AGENT,
UNICODE32 INTERACTION_ID,
UNICODE32 DEAL_AT,
UNICODE32 IS_TREND,
UNICODE32 TREND,
UNICODE32 CAMPAIGN,
UNICODE32 CAMPAIGN_STATUSID,
UNICODE32 SUB_TYPE,
UNICODE32 PARENT_COMMENT_ID,
UNICODE32 TAGS,
UNICODE32 IS_HOT,
UNICODE32 IS_CRISIS,
UNICODE32 PLATFORM,
UNICODE32 URL_CRC,
UNICODE32 IS_TASK,
UNICODE32 SESSIONID
END;

l_test:=record
DATA bigline;
END;
l_test2:=record
UNICODE bigline;
END;

fname:='~drea::chintext';
ds:=DATASET(fname,l_chin,CSV(Heading(1),separator('~'),UNICODE));

indexer.Transforms.AddRecSource(ds,fname,source_id,record_id,dsrec);
indexer.Transforms.MakeEntity(dsrec,'External Record ID',r,r,source_id,record_id,1,1,'External Record ID',dsr)
indexer.Transforms.MakeEntity(dsrec,'Created Time',created_at,created_at,source_id,record_id,2,1,'Created Time',dscreated_at)
indexer.Transforms.MakeEntity(dsrec,'Status ID',statusid,statusid,source_id,record_id,3,1,'Status ID',dsstatusid)
indexer.Transforms.MakeEntity(dsrec,'Text',txt,txt,source_id,record_id,4,1,'Text',dstxt)
indexer.Transforms.MakeEntity(dsrec,'Source',source,source,source_id,record_id,5,1,'Source',dssource)
indexer.Transforms.MakeEntity(dsrec,'Favorited',favorited,favorited,source_id,record_id,6,1,'Favorited',dsfavorited)
indexer.Transforms.MakeEntity(dsrec,'Truncated',truncated,truncated,source_id,record_id,7,1,'Truncated',dstruncated)
indexer.Transforms.MakeEntity(dsrec,'In Reply To Status',in_reply_to_status_id,in_reply_to_status_id,source_id,record_id,8,1,'In Reply To Status',dsin_reply_to_status_id)
indexer.Transforms.MakeEntity(dsrec,'In Reply To user ID',in_reply_to_user_id,in_reply_to_user_id,source_id,record_id,9,1,'In Reply To user ID',dsin_reply_to_user_id)
indexer.Transforms.MakeEntity(dsrec,'In Reply To Screen Name',in_reply_to_screen_name,in_reply_to_screen_name,source_id,record_id,10,1,'In Reply To Screen Name',dsin_reply_to_screen_name)
indexer.Transforms.MakeEntity(dsrec,'Mid',mid,mid,source_id,record_id,11,1,'Mid',dsmid)
indexer.Transforms.MakeEntity(dsrec,'Bmiddle pic',bmiddle_pic,bmiddle_pic,source_id,record_id,12,1,'Bmiddle pic',dsbmiddle_pic)
indexer.Transforms.MakeEntity(dsrec,'Original pic',original_pic,original_pic,source_id,record_id,13,1,'Original pic',dsoriginal_pic)
indexer.Transforms.MakeEntity(dsrec,'Thumbnail pic',thumbnail_pic,thumbnail_pic,source_id,record_id,14,1,'Thumbnail pic',dsthumbnail_pic)
indexer.Transforms.MakeEntity(dsrec,'Reposts count',reposts_count,reposts_count,source_id,record_id,15,1,'Reposts count',dsreposts_count)
indexer.Transforms.MakeEntity(dsrec,'Comments count',comments_count,comments_count,source_id,record_id,16,1,'Comments count',dscomments_count)
indexer.Transforms.MakeEntity(dsrec,'Annotations',annotations,annotations,source_id,record_id,17,1,'Annotations',dsannotations)
indexer.Transforms.MakeEntity(dsrec,'Geo',geo,geo,source_id,record_id,18,1,'Geo',dsgeo)
indexer.Transforms.MakeEntity(dsrec,'Userid',userid,userid,source_id,record_id,19,1,'Userid',dsuserid)
indexer.Transforms.MakeEntity(dsrec,'Retweeted Status',retweetedstatusid,retweetedstatusid,source_id,record_id,20,1,'Retweeted Status',dsretweetedstatusid)
indexer.Transforms.MakeEntity(dsrec,'Status type id',status_typeid,status_typeid,source_id,record_id,21,1,'Status type id',dsstatus_typeid)
indexer.Transforms.MakeEntity(dsrec,'ctistatus',ctistatus,ctistatus,source_id,record_id,22,1,'ctistatus',dsctistatus)
indexer.Transforms.MakeEntity(dsrec,'Ttype',ttype,ttype,source_id,record_id,23,1,'Ttype',dsttype)
indexer.Transforms.MakeEntity(dsrec,'Parent id',parentid,parentid,source_id,record_id,24,1,'Parent id',dsparentid)
indexer.Transforms.MakeEntity(dsrec,'AT User ID',atuserid,atuserid,source_id,record_id,25,1,'AT User ID',dsatuserid)
indexer.Transforms.MakeEntity(dsrec,'Retweeted',is_retweeted,is_retweeted,source_id,record_id,26,1,'Retweeted',dsis_retweeted)
indexer.Transforms.MakeEntity(dsrec,'Channel',channel,channel,source_id,record_id,27,1,'Channel',dschannel)
indexer.Transforms.MakeEntity(dsrec,'Important',is_important,is_important,source_id,record_id,28,1,'Important',dsis_important)
indexer.Transforms.MakeEntity(dsrec,'Mood',mood,mood,source_id,record_id,29,1,'Mood',dsmood)
indexer.Transforms.MakeEntity(dsrec,'Keywords',keywords,keywords,source_id,record_id,30,1,'Keywords',dskeywords)
indexer.Transforms.MakeEntity(dsrec,'Deal Agent',deal_agent,deal_agent,source_id,record_id,31,1,'Deal Agent',dsdeal_agent)
indexer.Transforms.MakeEntity(dsrec,'Intersection ID',interaction_id,interaction_id,source_id,record_id,32,1,'Intersection ID',dsinteraction_id)
indexer.Transforms.MakeEntity(dsrec,'Deal At',deal_at,deal_at,source_id,record_id,33,1,'Deal At',dsdeal_at)
indexer.Transforms.MakeEntity(dsrec,'Is Trend',is_trend,is_trend,source_id,record_id,34,1,'Is Trend',dsis_trend)
indexer.Transforms.MakeEntity(dsrec,'Trend',trend,trend,source_id,record_id,35,1,'Trend',dstrend)
indexer.Transforms.MakeEntity(dsrec,'Campaign',campaign,campaign,source_id,record_id,36,1,'Campaign',dscampaign)
indexer.Transforms.MakeEntity(dsrec,'Campaign Status',campaign_statusid,campaign_statusid,source_id,record_id,37,1,'Campaign Status',dscampaign_statusid)
indexer.Transforms.MakeEntity(dsrec,'Subtype',sub_type,sub_type,source_id,record_id,38,1,'Subtype',dssub_type)
indexer.Transforms.MakeEntity(dsrec,'Parent Comment ID',parent_comment_id,parent_comment_id,source_id,record_id,39,1,'Parent Comment ID',dsparent_comment_id)
indexer.Transforms.MakeEntity(dsrec,'Tags',tags,tags,source_id,record_id,40,1,'Tags',dstags)
indexer.Transforms.MakeEntity(dsrec,'Is Hot',is_hot,is_hot,source_id,record_id,41,1,'Is Hot',dsis_hot)
indexer.Transforms.MakeEntity(dsrec,'Is Crisis',is_crisis,is_crisis,source_id,record_id,42,1,'Is Crisis',dsis_crisis)
indexer.Transforms.MakeEntity(dsrec,'Platform',platform,platform,source_id,record_id,43,1,'Platform',dsplatform)
indexer.Transforms.MakeEntity(dsrec,'url',url_crc,url_crc,source_id,record_id,44,1,'url',dsurl_crc)
indexer.Transforms.MakeEntity(dsrec,'Task',is_task,is_task,source_id,record_id,45,1,'Task',dsis_task)
indexer.Transforms.MakeEntity(dsrec,'Session ID',sessionid,sessionid,source_id,record_id,46,1,'Session ID',dssessionid)				
//output(dsrec);
dsentities:=dsr+dscreated_at+dsstatusid+dstxt+dssource+dsfavorited+dstruncated+dsin_reply_to_status_id+dsin_reply_to_user_id+dsin_reply_to_screen_name+dsmid+dsbmiddle_pic+dsoriginal_pic+dsthumbnail_pic+dsreposts_count+dscomments_count+dsannotations+dsgeo+dsuserid+dsretweetedstatusid+dsstatus_typeid+dsctistatus+dsttype+dsparentid+dsatuserid+dsis_retweeted+dschannel+dsis_important+dsmood+dskeywords+dsdeal_agent+dsinteraction_id+dsdeal_at+dsis_trend+dstrend+dscampaign+dscampaign_statusid+dssub_type+dsparent_comment_id+dstags+dsis_hot+dsis_crisis+dsplatform+dsurl_crc+dsis_task+dssessionid;
//output(dsentities);

//indexer.buildindexes.removebuildadd(dsentities,'test');
//indexer.buildindexes.RollupIndexes;
//indexer.buildindexes.DailyBatchtasks;
//output(indexer.Indexes.DailyBitmapDataSuperFile,all);
	//output(indexer.indexes.mainBmpData);
//output(indexer.indexes.fileNameList('indexer::data::*_bmp', indexer.indexes.oldestDate));
//output(indexer.Indexes.BMP_DATA_FILENAME +'-'+ 'test');
//output(indexer.Indexes.BitmapDataSuperFile,,indexer.Indexes.BMP_DATA_FILENAME +'-'+ 'test', OVERWRITE); 
/*

UNICODE myInput := u'0' : stored('value');
string myType  := '' : stored('type');
integer pageSize  := 100  : stored('pageSize');
Dataset(indexer.Layouts.CommandStack) commandStack := DATASET([], indexer.Layouts.CommandStack) : STORED('commandStack',few);
layout_insources := {
   INTEGER source;
};
DATASET(layout_insources) insources := DATASET([], layout_insources) : STORED('sourceSet', few);
DATASET(layout_insources) excludeSources := DATASET([], layout_insources) : STORED('excludeSourceSet', few);
SET OF INTEGER inSourceSet := SET(insources, source);
SET OF INTEGER excludeSourceSet := SET(excludeSources, source);
integer myOffset := 1 : stored('offset');
//boolean clustered := false : stored('clustered');
boolean dedupresults := true : stored('dedupresults');
recsk := indexer.Indexes.RecIdxCombined;
bitmapSk := indexer.Indexes.BitmapSuperKey;
bitmapName := indexer.Indexes.BMP_DATA_FILENAME;
colWordPosIdx := indexer.Indexes.ColWordPosCompiledIdx;
dailyrecsk := indexer.Indexes.DailyRecIdxCombined;
dailybitmapSk := indexer.Indexes.DailyBitmapSuperKey;
dailybitmapName := indexer.Indexes.DAILY_BMP_DATA_FILENAME;
dailycolWordPosIdx := indexer.Indexes.DailyColWordPosCompiledIdx;
stack1 := PROJECT(commandStack, TRANSFORM(indexer.Layouts.CommandStack, 
		term :=indexer.Utility.FixCharacters(LEFT.term) ;
	 SELF.term_hash :=if (LEFT.term = u'' and LEFT. term_hash !=0, left.term_hash, indexer.Utility.MakeUHash(term));   
   SELF.type_hash := IF(LEFT.type_name = '', 0, indexer.Utility.MakeHash(StringLib.StringToUppercase(LEFT.type_name))); 
   SELF := LEFT));
// generate a stack from value if available
   STRING myType1 := StringLib.StringToUpperCase(myType);
   //data mySearch_data_utf8 := transfer(myInput, data);
   //unicode mySearch := tounicode(mySearch_data_utf8, 'UTF-8');
   unicode search2 := UnicodeLib.UnicodeToUpperCase(myInput);
   searchds1 := indexer.SearchString.parseQueryNoCount(search2,  myType1);
   searchds2 := SORT(searchds1, term_count);
   indexer.Layouts.CommandStack toStack(searchds2 L, INTEGER C) := TRANSFORM
      SELF.stack_id := C;
      SELF.opcode_num := indexer.constants.AND_OPCODE_NUM;
      SELF := L;
   END;
   stackds := PROJECT(searchds2, toStack(LEFT, COUNTER));
// decide which stack to use. Always used the passed in stack if available
stack := IF(COUNT(stack1) > 0, stack1, stackds);
// Add time stamping.....
  // rtl := SERVICE
 //     unsigned4 msTick() :  holertl,library='holertl',entrypoint='rtlTick';
 //  END;
 //  unsigned4 StartTime := rtl.mstick() : stored('StartTime');
   initresultsMain  := Indexer.SearchIndex(stack,
                                  bitmapSk,
                                  colWordPosIdx,
                                  bitmapName,
																	myOffset,
																	inSourceSet,
																	excludeSourceSet,
																	pageSize);
   initresultsDaily := Indexer.SearchIndex(stack,
                                  dailybitmapSk,
                                  dailycolWordPosIdx,
                                  dailybitmapName,
																	myOffset,
																	inSourceSet,
																	excludeSourceSet,
																	pageSize);
	 // Sort/dedup of results is done in FormatOutput.
	 initResults := initresultsMain+initresultsDaily;
	 finalResults :=initResults;//indexer.FormatSearchOutput(initResults);
				
	 // can specify FEW because there will be fewer than 10,000 results
   slimResults := TABLE(finalResults, {source_id, record_id}, source_id, record_id, FEW);
	 recordSources    := DEDUP(SORT(slimResults, source_id, record_id), source_id, record_id); 
	
  
   // Get stop time...compute the difference.							
 //  unsigned4 StopTime := rtl.mstick();
 //  decimal8_2 ResponseTime := (StopTime - StartTime) / 1000.00;
	 
outputs:=PARALLEL(
	  output(  recordsources, NAMED('UniqueSources')),
	 output('wsIR.bitmap',named('ecl_service')),
//	  OUTPUT(ResponseTime,named('Results_ExecuteTime')),
   output(stack, NAMED('CommandStack')),
   output(insources, NAMED('Sources')), 
 	 output(excludeSources, NAMED('ExcludeSources')),
   output(finalResults, named('Matching_Records'))	 
	 );
	 return outputs;
end;*/