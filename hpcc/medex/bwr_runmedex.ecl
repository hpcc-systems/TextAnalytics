IMPORT java;
import indexer;
IMPORT lib_unicodelib;

shared UNICODE MedTag(UNICODE input,UNICODE rec_id)   := 
    IMPORT(java,'org/apache/medex/ECLMedex.MedTag:(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;');

shared dsraw:=DATASET($.Filenames.f_raw,$.layouts.l_raw,csv(HEADING(0),terminator('£'),separator('$'),maxlength(100000)));

indexer.Transforms.AddRecSource(dsraw,$.Filenames.f_raw,source_id,record_id,ds);

UNSIGNED8 source_id:=ds[1].source_id;

dsInput:=project(ds,transform($.layouts.l_medex_result,
SELF.intext := LEFT.line;
SELF.source_id:=LEFT.source_id;
SELF.record_id:=LEFT.record_id;                              
unicode medtag:=MedTag(LEFT.line,(Unicode) LEFT.record_id);                             
SELF.outtext := u'<result>' + medtag + u'</result>';
)):persist('~drea::persist::mede2x');

//xmlout := PROJECT(dsInput,transform({unicode xmlout}, SELF.xmlout:=LEFT.outtext;));

//OUTPUT(xmlout,,'~drea::nlp::interim',CSV(HEADING(0)));


$.layouts.l_sig_container T1 := TRANSFORM 
UNSIGNED8 rec_id := (UNSIGNED8)xmltext('medex/parent_id');
SELF.record_id:=rec_id;
SELF.source_id:=source_id;
SELF.signatures:= XMLPROJECT('medex/signature',
						TRANSFORM($.layouts.l_signature, 
						SELF.source_id:=source_id;
								SELF.id:= 0;
								SELF.section_id := (UNSIGNED8) xmltext('id');
                                  SELF.record_id := rec_id;
								SELF.drugname := xmltext('drugname');
								SELF.drugbegin := (UNSIGNED4)xmltext('drugbegin');
								SELF.drugend :=(UNSIGNED4)xmltext('drugend');
								SELF.brand := xmltext('brand');
								SELF.brandbegin := (UNSIGNED4)xmltext('brandbegin');
								SELF.brandend := (UNSIGNED4)xmltext('brandend');
								SELF.dose_form := xmltext('dose_form');
								SELF.dose_formbegin := (UNSIGNED4)xmltext('dose_formbegin');
								SELF.dose_formend := (UNSIGNED4)xmltext('dose_formend');
								SELF.strength := xmltext('strength');
								SELF.strengthbegin := (UNSIGNED4)xmltext('strengthbegin');
								SELF.strengthend := (UNSIGNED4)xmltext('strengthend');
								SELF.dose_amt := xmltext('dose_amt');
								SELF.dose_amtbegin := (UNSIGNED4)xmltext('dose_amtbegin');
								SELF.dose_amtend := (UNSIGNED4)xmltext('dose_amtend');
								SELF.route := xmltext('route');
								SELF.routebegin := (UNSIGNED4)xmltext('routebegin');
								SELF.routeend := (UNSIGNED4)xmltext('routeend');
								SELF.frequency := xmltext('frequency');
								SELF.frequencybegin := (UNSIGNED4)xmltext('frequencybegin');
								SELF.frequencyend := (UNSIGNED4)xmltext('frequencyend');
								SELF.duration := xmltext('duration');
								SELF.durationbegin :=(UNSIGNED4)xmltext('durationbegin');
								SELF.durationend := (UNSIGNED4)xmltext('durationend');
								SELF.necessity := xmltext('necessity');
								SELF.necessitybegin := (UNSIGNED4)xmltext('necessitybegin');
								SELF.necessityend := (UNSIGNED4)xmltext('necessityend');
								SELF.umls_code := xmltext('umls_code');
								SELF.rx_code := xmltext('rx_code');
								SELF.unknown1 := xmltext('unknown1');
								SELF.generic_name := xmltext('generic_name');
								SELF.sent_text := xmltext('sent_text');
								
						));
END;

 parsedsigs := PARSE( dsInput,outtext,  T1, XML('result'));

rolled := ROLLUP(parsedsigs,true,transform(recordof(parsedsigs),
  SELF.signatures:=LEFT.signatures + RIGHT.signatures;
  SELF:= LEFT;
  ));
denorm:=project(rolled[1].signatures, TRANSFORM(recordof(rolled[1].signatures),
SELF.id:=COUNTER;
SELF:= LEFT;));
OUTPUT(ds[1..10]);
OUTPUT(denorm(drugnam != 'colon' and brand !='' or dose_form !='' or dose_amt !='' or route !='' or frequency !='' or duration !=''),,$.filenames.f_signature,THOR,overwrite);
//OUTPUT(ds,,$.filenames.f_clean,THOR,overwrite);

