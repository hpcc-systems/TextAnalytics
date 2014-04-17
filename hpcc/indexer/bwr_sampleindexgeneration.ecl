import indexer;
import java;

shared UNICODE Segment(UNICODE input)   := 
    IMPORT(java,'org/hpcc/ECLStanfordSegmenter.segment:(Ljava/lang/String;)Ljava/lang/String;');
		
//get dataset to index
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
unicode BMIDDLE_PIC,
unicode ORIGINAL_PIC,
unicode THUMBNAIL_PIC,
unicode REPOSTS_COUNT,
unicode COMMENTS_COUNT,
unicode ANNOTATIONS,
unicode GEO,
unicode USERID,
unicode RETWEETEDSTATUSID,
unicode STATUS_TYPEID,
unicode CTISTATUS,
unicode tTYPE,
unicode PARENTID,
unicode ATUSERID,
unicode IS_RETWEETED,
unicode CHANNEL,
unicode IS_IMPORTANT,
unicode MOOD,
unicode KEYWORDS,
unicode DEAL_AGENT,
unicode INTERACTION_ID,
unicode DEAL_AT,
unicode IS_TREND,
unicode TREND,
unicode CAMPAIGN,
unicode CAMPAIGN_STATUSID,
unicode SUB_TYPE,
unicode PARENT_COMMENT_ID,
unicode TAGS,
unicode IS_HOT,
unicode IS_CRISIS,
unicode PLATFORM,
unicode URL_CRC,
unicode IS_TASK,
unicode SESSIONID,
END;

fname := '~indexer::data::chindata';
dsraw:=DATASET(fname,l_chin,CSV(Heading(1),separator('~'),UNICODE));

//splitting chinese text goes here
l_ext := RECORD
l_chin,
unicode split_text;
END;

ds := PROJECT(dsraw, TRANSFORM(l_ext,
SELF.split_text := Segment(LEFT.txt);
SELF := LEFT;
));
output(ds);


//add a source id & record id field to the file. The source will by the
//hash64 of fname and the record_id is a counter . the field names added 
//will be "source_id" and "record_id"
indexer.Transforms.AddRecSource(ds,fname,source_id,record_id,dsrec);

indexer.Transforms.MakeEntity(dsrec,'External Record ID',r,r,source_id,record_id,1,1,'External Record ID',dsr)
indexer.Transforms.MakeEntity(dsrec,'Created Time',created_at,created_at,source_id,record_id,2,1,'Created Time',dscreated_at)
indexer.Transforms.MakeEntity(dsrec,'Status ID',statusid,statusid,source_id,record_id,3,1,'Status ID',dsstatusid)
indexer.Transforms.MakeEntity(dsrec,'Text',split_text,txt,source_id,record_id,4,1,'Text',dstxt)
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

indexname:='testdata'; //indexname := 'haier' + WORKUNIT;

indx:=sequential(
//generate data file for this set of entities to be added to superfile
//		~indexer::data::testdata_bmp created, accessible via dynamic superfile
//		  indexer.Indexes.BitmapDataSuperFile (it includes anything like '~indexer::data::*_bmp' added after the last bitmap index was compiled)
indexer.buildindexes.removebuildadd(dsentities,indexname)

//from the above BitmapDataSuperFile, generate indexes and add them to superfiles:
//		~indexer::idx::bitmapsk-testdata created, added to SK indexer::idx::bitmapsk <-used for bitmap search
//		~indexer::idx::compiledrecndx-testdata created, added to SK indexer::idx::compiledrecndx <-used for bitmap search
//		~indexer::idx::compiledcolwordposndx-testdata created, added to SK indexer::idx::compiledcolwordposndx  <- used for phrase searching
//		~indexer::data::bitmap-testdata, added to SF ~indexer::data::bitmap  <- used for retrieving addtl data for recs once bmp search is done

,indexer.buildindexes.RollupIndexes(indexname)

//indexer.buildindexes.RollupRecentIndexes(indexname); //create indexes from any data added with removebuildadd after the last rollupindexes was called

//generate the word count index and substring indexes for wildcard searches (* & ?). 
//this can be done less frequently, especially across a corpus with limited vocabulary
,indexer.buildindexes.IRMetaDataBatchTasks
);

//indx;