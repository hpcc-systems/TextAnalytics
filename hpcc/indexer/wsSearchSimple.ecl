/*--SOAP--
<message name="Record Search">
<part name="value" type="xsd:string"/>
<part name="type" type="xsd:string"/>
<part name="commandStack" type="tns:XmlDataSet" cols="50" rows="10"/> 
<part name="sourceSet" type="tns:XmlDataSet" cols="50" rows="10"/> 
<part name="excludeSourceSet" type="tns:XmlDataSet" cols="50" rows="10"/> 
<part name="offset" type="xsd:integer"/>
<part name="pageSize" type="xsd:integer"/>
<part name="clustered" type="xsd:boolean"/>
<part name="dedupresults" type="xsd:boolean"/>
</message>
*/
/*--INFO-- Returns concepts where the value matches the input.
<pre>
OP Code Values
    OR_OPCODE_NUM := 1;
    AND_OPCODE_NUM := 2;
    PRE_1_OPCODE_NUM := 3;
    AND_NOT_OPCODE_NUM := 9;
    PUSH_OPCODE_NUM := 10;
    POP_AND_OPCODE_NUM := 11;
    POP_OR_OPCODE_NUM := 12;
    POP_AND_NOT_OPCODE_NUM := 19;
</pre>
*/
/*--HELP-- 
<pre>
 (MOHAMED pre/1 Youssef) and (Abou pre/1 Olleika)
&lt;DataSet&gt;
   &lt;row&gt;
      &lt;stack_id&gt;1&lt;/stack_id&gt;
      &lt;opcode_num&gt;0&lt;/opcode_num&gt;
      &lt;term&gt;MOHAMED&lt;/term&gt;
   &lt;/row&gt;
   &lt;row&gt;
      &lt;stack_id&gt;2&lt;/stack_id&gt;
      &lt;opcode_num&gt;3&lt;/opcode_num&gt;
      &lt;term&gt;YOUSSEF&lt;/term&gt;
   &lt;/row&gt;
   &lt;row&gt;
      &lt;stack_id&gt;3&lt;/stack_id&gt;
      &lt;opcode_num&gt;10&lt;/opcode_num&gt;
      &lt;term&gt;ABOU&lt;/term&gt;
   &lt;/row&gt;
   &lt;row&gt;
      &lt;stack_id&gt;4&lt;/stack_id&gt;
      &lt;opcode_num&gt;3&lt;/opcode_num&gt;
      &lt;term&gt;OLLEIKA&lt;/term&gt;
   &lt;/row&gt;
   &lt;row&gt;
      &lt;stack_id&gt;5&lt;/stack_id&gt;
      &lt;opcode_num&gt;11&lt;/opcode_num&gt;
      &lt;term&gt;&lt;/term&gt;
   &lt;/row&gt;
&lt;/DataSet&gt;
</pre>
*/

import indexer;
import lib_unicodelib;
import lib_stringlib;

export wsSearchSimple() := function

UNICODE myInput := u'' : stored('value');
string myType  := '' : stored('type');
integer inpageSize  := 100  : stored('pageSize');
Dataset(indexer.Layouts.CommandStack) commandStack := DATASET([], indexer.Layouts.CommandStack) : STORED('commandStack',few);
layout_insources := {
   INTEGER source;
};
   data mySearch_data_utf8 := transfer(myInput, data);
   unicode mySearch := tounicode(mySearch_data_utf8, 'UTF-8');
   unicode search22 := UnicodeLib.UnicodeToUpperCase(myInput);
pagesize := inpagesize ;
DATASET(layout_insources) insources := DATASET([], layout_insources) : STORED('sourceSet', few);
DATASET(layout_insources) excludeSources := DATASET([], layout_insources) : STORED('excludeSourceSet', few);
SET OF UNSIGNED8 inSourceSet := SET(insources, source);
SET OF UNSIGNED8 excludeSourceSet := SET(excludeSources, source);
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
   initresultsMain  := Indexer.SearchIndexSimple(stack,
                                  bitmapSk,
                                  colWordPosIdx,
                                  bitmapName,
																	myOffset,
																	inSourceSet,
																	excludeSourceSet,
																	pageSize);
																	
   initresultsDaily := Indexer.SearchIndexSimple(stack,
                                  dailybitmapSk,
                                  dailycolWordPosIdx,
                                  dailybitmapName,
																	myOffset,
																	inSourceSet,
																	excludeSourceSet,
																	pageSize);

	 // Sort/dedup of results is done in FormatOutput.
	 finalResults :=indexer.FormatSearchOutput(initResultsMain);
				
				finalRenumbered:=Iterate(finalResults,transform(recordof(finalresults),
				SELF.group_id:=map (COUNTER=1 =>myoffset,
														LEFT.record_id != RIGHT.record_id=>left.group_id + 1, 
														left.group_id);
				SELF:= RIGHT;));
	 // can specify FEW because there will be fewer than 10,000 results
   slimResults := TABLE(finalResults, {source_id, record_id}, source_id, record_id, FEW);
	 recordSources    := DEDUP(SORT(slimResults, source_id, record_id), source_id, record_id); 
	
  
   // Get stop time...compute the difference.							
 //  unsigned4 StopTime := rtl.mstick();
 //  decimal8_2 ResponseTime := (StopTime - StartTime) / 1000.00;
	//numrecs:=table(finalResults,{source_id, record_id, cnt:=count(group)},source_id,record_id);
outputs:=PARALLEL(	
//	  output(  recordsources, NAMED('UniqueSources')),
//	 output('wsIR.bitmap',named('ecl_service')),
//	  OUTPUT(ResponseTime,named('Results_ExecuteTime')),

	output(count(recordsources)+(myOffset-1),named('NumResults')),
   output(stack, NAMED('CommandStack')),
   output(pageSize, NAMED('pageSize')),
  output(insources, NAMED('Sources')), 
 	 output(excludeSources, NAMED('ExcludeSources')),
	 	  output(finalrenumbered, named('Matching_Records'),all)	, 
	  output(initresultsMain, named('uinit'),all)	 
	 );
	 return outputs;
end;
