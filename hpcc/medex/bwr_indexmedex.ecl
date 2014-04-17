import medex;
import indexer;
import lib_unicodelib;
//import $;


dsrec:=medex.Datasets.dsClean;
dssig:=medex.Datasets.dsSignatures;

//indexer.Transforms.MakeEntity(dsrec,'Patient Assessment',line,line,source_id,record_id,1,1,'Patient Assessment',dsline);
//indexer.Transforms.MakeEntity(dsrec,'Document ID',record_id,record_id,source_id,record_id,1,1,'Document ID',dslinerec);
indexer.Transforms.MakeEntity(dssig,'Assessment Section',sent_text,sent_text,source_id,id,16,1,'Assessment Section',dssection);
indexer.Transforms.MakeEntity(dssig,'Drug Name',drugname,drugname,source_id,id,4,1,'Drug Name',dsdrugname);
indexer.Transforms.MakeEntity(dssig,'Brand',brand,brand,source_id,id,5,1,'Brand',dsbrand);
indexer.Transforms.MakeEntity(dssig,'Dose Form',dose_form,dose_form,source_id,id,6,1,'Dose Form',dsdose_form);
indexer.Transforms.MakeEntity(dssig,'Dose Strength',strength,strength,source_id,id,7,1,'Dose Strength',dsstrength);
indexer.Transforms.MakeEntity(dssig,'Dose Amount',dose_amt,dose_amt,source_id,id,8,1,'Dose Amount',dsdose_amt);
indexer.Transforms.MakeEntity(dssig,'Drug Route',route,route,source_id,id,9,1,'Drug Route',dsroute);
indexer.Transforms.MakeEntity(dssig,'Dose Frequency',frequency,frequency,source_id,id,10,1,'Dose Frequency',dsfrequency);
indexer.Transforms.MakeEntity(dssig,'Dose Duration',duration,duration,source_id,id,11,1,'Dose Duration',dsduration);
indexer.Transforms.MakeEntity(dssig,'Drug Necessity',necessity,necessity,source_id,id,12,1,'Drug Necessity',dsnecessity);
indexer.Transforms.MakeEntity(dssig,'UMLS Code',umls_code,umls_code,source_id,id,13,1,'UMLS Code',dsumls_code);
indexer.Transforms.MakeEntity(dssig,'RX Code',rx_code,rx_code,source_id,id,14,1,'RX Code',dsrx_code);
indexer.Transforms.MakeEntity(dssig,'Document ID',record_id,record_id,source_id,id,14,1,'Document ID',dsdoc);
indexer.Transforms.MakeEntity(dssig,'Generic Drug Name',generic_name,generic_name,source_id,id,15,1,'Generic Drug Name',dsgeneric_name);

//output(dsrec);
dsentities:=dsdrugname+dsbrand+dsdose_form+dssection+dsstrength+dsdose_amt+dsroute+dsfrequency+dsduration+dsdoc+dsnecessity+dsumls_code+dsrx_code+dsgeneric_name:persist('~temp::medexidx');
dsentitiesdist:=DISTRIBUTE(dsentities,RANDOM());

shared iname:='testmedex'; //indexname := 'haier' + WORKUNIT;

result :=sequential(
indexer.buildindexes.removebuildadd(dsentitiesdist,iname)
,indexer.buildindexes.RollupIndexes(iname)
,indexer.buildindexes.IRMetaDataBatchTasks
);

result;