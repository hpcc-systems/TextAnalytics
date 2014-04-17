import $;
export SearchString := module 
export SearchLayout := {, maxlength(0x1000 ) 
   unicode searchStr;
}; 
export TermLayout := { 
  unicode term;
  integer8 term_hash := 0;
  unsigned term_count :=0 ; 
}; 
export QueryLayout := { 
  unsigned query_position;
  unicode term;
  integer8 term_hash := 0;
  unsigned term_count := 0;
  string term_type := '';
  integer8 type_hash := 0;
  unsigned position_term_count := 0;
}; 
// export SplitTypeLogogram(dataset(SearchLayout) searchSet) := function 
			// loopbody(dataset(SearchLayout) ds) := project(ds, transform(recordof(ds) , 
						// self.searchStr :=regexreplace(u'([^:+ ]+):(\\p{Han})(\\p{Han}+)', left.searchStr, u'$1:$2+$3'); 
						// self:=left)); 
						
			// return loop(searchSet, regexfind(u'[^:+ ]+:\\p{Han}\\p{Han}',rows(left)[1].searchStr) ,loopbody(rows(left))) ; 
// end; 
// export SplitLogogram(dataset(SearchLayout) searchSet) := function 
			// splitTypes := SplitTypeLogogram(searchSet); 
			// return PROJECT(splitTypes, transform(recordof(splitTypes) , 
					// self.searchStr := regexreplace(u'(\\p{Han})(?=\\p{Han})', left.searchStr, u'$1+'); 
					// self:=left)); 
// end; 
export SplitLogogram(dataset(SearchLayout) searchSet) := function 
			return PROJECT(searchSet, transform(recordof(searchSet) , 
					interimSearchStr := regexreplace(u'(\\p{Han})(\\p{Han})', left.searchStr, u'$1+$2'); 
					self.searchStr := regexreplace(u'(\\p{Han})(\\p{Han})', interimSearchStr, u'$1+$2'); 
					self:=left)); 
end; 
shared pattern termWord := pattern('[^ ]+'); 
shared pattern space := pattern(' '); 
shared pattern termType := pattern('[^ :+]+'); 
shared pattern colon := pattern(':'); 
shared rule termGroup :=( first | space) opt(termType colon) termWord; 
shared rule individualTerm := pattern('[^+ ]+'); 
export parseQueryInside(unicode query, string defaultType) := function 
			convert2Space :=regexreplace(u'[\\&?]',query, u'+'); 
			removeChars :=regexreplace(u'[\'"$#%`-]',convert2Space, u'') ; 
			removeBeginningChars :=regexreplace(u'(^| )[.:@_\\\\/~]',removeChars , u'$1') ; 
			removeEndChars :=regexreplace(u'[.:@_\\\\/~]( |$)',removeBeginningChars, u'$1') ; 
			ds := DATASET( [{removeEndChars}], SearchLayout);
			
			QueryLayout extractTerms(SearchLayout match) := transform 
			  termMatch :=matchunicode(termWord); 
			  typeMatch := IF(matched(termType) , matchunicode(termType) , u'') ; 
			  isBadType := regexfind(u'(A(PRODUCTREPORTIHTTPS?)$|\\d)',typeMatch) ; 
			  self.query_position := matchposition(termGroup); 
			  self.term_type := IF(matched(termType) and not isBadType, (string)matchunicode(termType) , defaultType) ; 
			  self.term :=IF(isBadType, typeMatch + u':'+ termMatch, termMatch) ; 
      end; 
    QueryLayout extractTerms2(QueryLayout match) := transform 
			singleTerm := matchunicode(individualTerm); 
			termHash :=hash64(singleTerm); 
			typeHash := if(match.term_type != '', hash64(match.term_type), 0) ; 
			self.term := singleTerm; 
			self.term_hash := termHash;
			self.type_hash := typeHash; 
			self.query_position := if (match.query_position < matchposition(individualTerm), matchposition(individualTerm), match.query_position);
			self := match;
		end;
		
    querySet :=parse(ds, searchStr, termGroup, extractTerms(left), SCAN, FIRST); 
    querySet2 :=parse(querySet, term, individualTerm, extractTerms2(left), SCAN, FIRST) ;
    queryMins :=table(querySet2, {query_position, cnt :=min(group, term_count) }, query_position) ; 
    querySet3 :=join(querySet2, queryMins, left.query_position = right.query_position,
							transform(QueryLayout, self.position_term_count := right.cnt; 
							self := left)); 
    qs4 := sort(querySet3, position_term_count, query_position, term_count);
		return qs4;
end; 
export parseQuery(unicode query, string defaultType, typeof($.Indexes.CntSuperKey) WordCntIndex) := function 
  pds := parseQueryInside(query, defaultType);
	jpds1 := JOIN(pds, WordCntIndex, LEFT.term_hash = RIGHT.value_hash,// AND LEFT.type_hash = RIGHT.type_hash,
	   TRANSFORM(recordof(pds), SELF.term_count := RIGHT.word_cnt; SELF := LEFT));
	jpds2 := SORT(jpds1, term_hash, type_hash);
	jpds3 := ROLLUP(jpds2, LEFT.term_hash = RIGHT.term_hash AND LEFT.type_hash = RIGHT.type_hash,
	   TRANSFORM(recordof(pds), SELF.term_count := LEFT.term_count + RIGHT.term_count; SELF := LEFT));
	return jpds3;
END;
export parseQueryNoCount(unicode query, string defaultType) := function 
  pds := parseQueryInside(query, defaultType);
	return pds;
END;
END;
