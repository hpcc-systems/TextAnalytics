 import $;
 import lib_unicodelib;
 export FN_LookupWord(UNICODE insrch,
											Typeof($.indexes.SubstringFirstLastIndexKey) WordIndexFirst, 
											Typeof($.indexes.SubstringMiddleIndexKey) WordIndexMiddle, 
											typeof($.indexes.CntSingleIndex) wordCountIndex, 
											unsigned4 maxwords) := FUNCTION 
//UNICODE srch :=u'*M*S*FA*M*'; 
			srch:=UnicodeLib.UnicodeToUpperCase(insrch);
			
			UNICODE srchcomma1 :=UnicodeLib.UnicodeFindReplace(srch, u'*', u',');
			UNICODE srchcomma2 :=UnicodeLib.UnicodeFindReplace(srchcomma1, u'?',u',');
			UNICODE srchcomma3 :=IF(srchcomma2[1] = u',', srchcomma2[2..], srchcomma2) ; 
			UNICODE srchcomma :=IF(srchcomma3[LENGTH(srchcomma3)] = u',', srchcomma3, srchcomma3 + u','); 
layout_l := {, MAXLENGTH(128) 
UNICODE letters; 
};
 
srchds1 := DATASET( [{srchcomma}], layout_l); 
srchds2 := NORMALIZE(srchds1, LENGTH(UnicodeLib.UnicodeFilter(srchcomma, u',')) 
, TRANSFORM(layout_l, SELF.letters := UnicodeLib.UnicodeExtract(LEFT.letters, COUNTER))); 
srchds3 := SORT(srchds2, -LENGTH(letters) , letters); 
UNICODE lookupstr := srchds3[1].letters; 
// Do lookup in middle indexS 

useindex :=IF(srch[1] IN [u'*', u'?'], true, false);
firstlet :=WordIndexMiddle.firstletter = $.Utility.TF(lookupstr[1]);
secndlet :=IF(LENGTH(lookupstr) > 1, WordIndexMiddle.secondletter=$.Utility.TF(lookupstr[2]), true);
thirdlet := IF(LENGTH(lookupstr) > 2, WordIndexMiddle.thirdletter=$.Utility.TF(lookupstr[3]), true);
ff1 := WordIndexMiddle( KEYED(firstlet AND secndlet AND thirdlet) 
			AND useindex AND UnicodeLib.UnicodeWildMatch(searchable_value, srch, false));
			
ff1a := PROJECT(ff1, TRANSFORM($.Layouts.L_Word, 
											SELF.word := LEFT.searchable_value; 
											SELF.value_hash :=$.utility.makeuhash(left.searchable_value);));
// Do lookup in firstlast index 
useflindex := IF(srch[1] IN [u'*', u'?'], false, true) ;
flet := WordIndexFirst.firstletter = $.Utility.TF(srch[1]) ;
lastlet := IF( srch[LENGTH(srch)] IN [u'*', u'?'], true, WordIndexFirst.lastletter = $.Utility.TF(srch[LENGTH(srch)])); 
ff2 := WordIndexFirst( KEYED(flet AND lastlet) AND useflindex AND UnicodeLib.UnicodeWildMatch(searchable_value, srch, false) ) ;
ff2a := PROJECT(ff2, TRANSFORM($.Layouts.L_Word, 
												SELF.word:=LEFT.searchable_value;
												SELF.value_hash:=$.utility.makeuhash(LEFT.searchable_value);)); 
retset := ff1a + ff2a;

return when(CHOOSEN(retset,maxwords),output(insrch)) ; 
END;
