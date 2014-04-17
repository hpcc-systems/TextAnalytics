import lib_unicodelib;
import lib_fileservices;
EXPORT Utility := MODULE
export INTEGER8 MakeUHash(Unicode val):=FUNCTION
val1:=UnicodeLib.UnicodeToUpperCase(TRIM(val,LEFT,RIGHT));
integer8 result:=HASH64(val1);
return if (val1=u'',0,result);
END;
//    
export INTEGER8 MakeHash(String val):=FUNCTION
val1:=UnicodeLib.UnicodeToUpperCase((Unicode)TRIM(val,LEFT,RIGHT));
integer8 result:=HASH64(val1);
return if (val1=u'',0,result);
END;
//    

//                                 1         2
//                        12345678901234567890
// Modified date format = 2012-08-31T18:44:51
export BOOLEAN newer(STRING modifiedDateL, STRING modifiedDateR) := FUNCTION
   INTEGER yearL := (INTEGER)modifiedDateL[1..4];
   INTEGER monthL := (INTEGER)modifiedDateL[6..7];
   INTEGER dayL := (INTEGER)modifiedDateL[9..10];
   INTEGER hourL := (INTEGER)modifiedDateL[12..13];
   INTEGER minuteL := (INTEGER)modifiedDateL[15..16];
   INTEGER secondL := (INTEGER)modifiedDateL[18..19];
   INTEGER yearR := (INTEGER)modifiedDateR[1..4];
   INTEGER monthR := (INTEGER)modifiedDateR[6..7];
   INTEGER dayR := (INTEGER)modifiedDateR[9..10];
   INTEGER hourR := (INTEGER)modifiedDateR[12..13];
   INTEGER minuteR := (INTEGER)modifiedDateR[15..16];
   INTEGER secondR := (INTEGER)modifiedDateR[18..19];
   BOOLEAN isnewer := MAP( yearL > yearR => false,
                        yearL < yearR => true,
                        // yearL == yearR
                        monthL > monthR => false,
                        monthL < monthR => true,
                        //monthL == monthR
                        dayL > dayR => false,
                        dayL < dayR => true,
                        // dayL == dayR
                        hourL > hourR => false,
                        hourL < hourR => true,
                        // hourL == hourR
                        minuteL > minuteR => false,
                        minuteL < minuteR => true,
                        // minuteL == minuteR
                        secondL > secondR => false,
                        secondL < secondR => true,
                        false);
   RETURN isnewer;
END;

export fixCharacters(unicode word) := FUNCTION
		convert2space := regexreplace(u'[+,;()\\[\\]\\{}!?\\&<>\\^*]',
		                              word,
		                              u' ');
		removeChars := regexreplace(u'[\'"$#%`\\-’“”]',
		                            convert2space,
		                            u'');
		removeBeginningChars := regexreplace(u'(^| )[.:@_\\\\/~]',
		                                     removeChars,
		                                     u'$1');
		removeEndChars := regexreplace(u'[.:@_\\\\/~]( |$)',                                   
		                               removeBeginningChars,
		                               u'$1');
		return removeEndChars;
END;

export TF(unicode word) := FUNCTION 
tl :=TRANSFER(word,unsigned2); 
return tl; 
END;


 export addIndexToSuperfile(string sk, string ndx) :=
		sequential( 
			IF(NOTHOR(~FileServices.SuperFileExists(sk)),NOTHOR(FileServices.CreateSuperFile(sk))),
			NOTHOR(FileServices.StartSuperFileTransaction()) , 
			if (NOTHOR(FileServices.FileExists(ndx)),
					NOTHOR(FileServices.AddSuperFile(sk,ndx))),
			NOTHOR(FileServices.FinishSuperFileTransaction() )
		) ; 
 export removeIndexFromSF(string sk, string ndx) :=
IF(NOTHOR(FileServices.SuperFileExists(sk)),
	sequential( NOTHOR(FileServices.StartSuperFileTransaction()),
	NOTHOR(FileServices.RemoveSuperFile(sk,ndx)),
	NOTHOR(FileServices.FinishSuperFileTransaction() )
	)) ; 
	
END;