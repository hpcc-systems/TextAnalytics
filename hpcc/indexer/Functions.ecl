export Functions:=MODULE


export FN_TypeHashSet(DATASET($.Layouts.CommandStack) instack) := FUNCTION
   layout_command_stack_type_set := {
      $.Layouts.CommandStack;
      SET OF INTEGER8 type_hash_set {MAXCOUNT(100)};
   };
   stack2 := JOIN(instack, $.EntityTypes.entity_search_map, LEFT.type_hash = RIGHT.type_hash
      , TRANSFORM(layout_command_stack_type_set,
                  SELF.type_hash_set := IF(LEFT.type_hash<>0 AND RIGHT.type_hash = 0, [LEFT.type_hash], [RIGHT.search_hash]);
                  SELF := LEFT;)
      , LEFT OUTER, MANY LOOKUP);
   stack := ROLLUP(SORT(stack2, search_id, stack_id), LEFT.search_id = RIGHT.search_id AND LEFT.stack_id = RIGHT.stack_id
      , TRANSFORM(layout_command_stack_type_set, SELF.type_hash_set := LEFT.type_hash_set + RIGHT.type_hash_set; SELF := LEFT));
   return(stack);
END;

export FN_HasAChanceFilter(DATASET($.indexes.combinedBmpRec) bmpi, DATASET($.Layouts.CommandStack) stack) := FUNCTION
layout_add_missing := {
  bmpi;
  BOOLEAN valid := FALSE;
};
haveachance1 := SORT(bmpi, search_id, source_id, col_item); // don't need type_hash because the lookup specifies a type_hash
haveachance2 := GROUP(haveachance1, search_id, source_id, col_item);
haveachance3 := PROJECT(haveachance2, layout_add_missing);
// ADD missing command stack elements
// Add missing recprds
/* 
 * Joining the results of the join against the bitmap index and data with
 * the command stack to add missing pieces of the command stack back into
 * the results.
 * This is necessary because the results are evaluated in a reverse polish
 * notation (RPN) form. For example, the search (term_a AND term_b)
 * will be treated like term_a, term_b, AND
 * 
 */ 
layout_add_missing addMissingViaJoin(haveachance3 L, stack R) := TRANSFORM
  SELF.term := IF(L.value_hash = R.term_hash, L.term, u'');
  SELF.value_hash := IF(L.value_hash = R.term_hash, L.value_hash, 0);
  SELF.type_hash := IF(L.value_hash = R.term_hash, L.type_hash, 0);
  SELF.source_id := L.source_id;
  SELF.col_item := L.col_item;
  SELF.stack_id := R.stack_id;
  SELF.opcode_num := R.opcode_num;
  SELF.fpos := IF(L.value_hash = R.term_hash, L.fpos, 0);
  SELF.search_id := L.search_id;
  SELF.valid := L.value_hash = R.term_hash;
  SELF := L;
END;
jsr1 := JOIN(haveachance3, stack, LEFT.search_id = RIGHT.search_id, addMissingViaJoin(LEFT, RIGHT), GROUPED);
jsr2 := SORT(jsr1, search_id, source_id, col_item, stack_id, -term);
jsr3 := DEDUP(jsr2, search_id, source_id, col_item, stack_id);
layout_bmpi_cnt := {
  DATASET($.Indexes.combinedBmpRec) rt{MAXLENGTH(8192)};
  bmpi;  
  BOOLEAN valid  := FALSE;
  BOOLEAN accum  := FALSE;
  BOOLEAN accum1 := FALSE;
  BOOLEAN accum2 := FALSE;
  BOOLEAN accum3 := FALSE;
};
haveachance4 := PROJECT(jsr3, transform(layout_bmpi_cnt, SELF.valid := LEFT.valid; SELF.rt := ROW(LEFT, $.indexes.combinedBmpRec); SELF := LEFT));
// ROLLUP "hava a chance"
layout_bmpi_cnt rollupJoin(layout_bmpi_cnt L, layout_bmpi_cnt R) := TRANSFORM
   SELF.accum := MAP(R.opcode_num = $.Constants.PUSH_OPCODE_NUM => L.valid
      , R.opcode_num = $.Constants.POP_AND_OPCODE_NUM => L.accum1
      , R.opcode_num = $.Constants.POP_OR_OPCODE_NUM => L.accum1
      , L.accum);
   SELF.accum1 := MAP(R.opcode_num = $.Constants.PUSH_OPCODE_NUM => L.accum
      , R.opcode_num = $.Constants.POP_AND_OPCODE_NUM => L.accum2
      , R.opcode_num = $.Constants.POP_OR_OPCODE_NUM => L.accum2
      , L.accum1);
   SELF.accum2 := MAP(R.opcode_num = $.Constants.PUSH_OPCODE_NUM => L.accum1
      , R.opcode_num = $.Constants.POP_AND_OPCODE_NUM => L.accum3
      , R.opcode_num = $.Constants.POP_OR_OPCODE_NUM => L.accum3
      , L.accum2);
   SELF.accum3 := MAP(R.opcode_num = $.Constants.PUSH_OPCODE_NUM => L.accum2
      , R.opcode_num = $.Constants.POP_AND_OPCODE_NUM => FALSE
      , R.opcode_num = $.Constants.POP_OR_OPCODE_NUM => FALSE
      , L.accum3);
   retsetsOR  := L.valid OR R.valid;
   retsetsAND := L.valid AND R.valid;
   //retsetsPUSH := word and offset are taken directly from the right
   retsetsPopOR := L.valid OR L.accum;
   retsetsPopAND := L.valid AND L.accum;
   SELF.valid := MAP(R.opcode_num = $.Constants.PUSH_OPCODE_NUM => R.valid
      , R.opcode_num = $.Constants.OR_OPCODE_NUM => retsetsOR
      , R.opcode_num = $.Constants.AND_OPCODE_NUM => retsetsAND
      , R.opcode_num = $.Constants.POP_AND_OPCODE_NUM => retsetsPopAND
      , R.opcode_num = $.Constants.POP_OR_OPCODE_NUM => retsetsPopOR
      , R.valid);
   SELF.rt := L.rt + R.rt;
   SELF := R;
END;
haveachance11 := ROLLUP(haveachance4, LEFT.search_id = RIGHT.search_id AND LEFT.source_id = RIGHT.source_id AND LEFT.col_item = RIGHT.col_item, rollupJoin(LEFT, RIGHT));
haveachance12 := haveachance11(valid);
haveachance13 := NORMALIZE(haveachance12, COUNT(LEFT.rt), TRANSFORM(recordof(bmpi), SELF := LEFT.rt[COUNTER]));
haveachance14 := haveachance13(value_hash <> 0); // eliminate added stack items that weren't in bitmap input (bmpi)
return haveachance14;
END;

export set of unsigned4 compareSets(set of unsigned4 firstset, set of unsigned4 secondset) := BEGINC++
	#include <stdlib.h>
  int sort(const void *x, const void *y) {
    return (*(uint*)x - *(uint*)y);
  }
	#body
	uint * leftSet = (uint *)firstset;
	uint * rightSet = (uint *)secondset;
	unsigned * theresults;
	unsigned leftCounter = 0;
	unsigned rightCounter = 0;
	unsigned matchCount = 0;
	unsigned distance = 1;
  uint len = lenFirstset > lenSecondset ? lenFirstset : lenSecondset;
	unsigned * interim = (unsigned *)rtlMalloc(len);
  qsort(leftSet, lenFirstset/sizeof(uint), sizeof(uint), sort);
  qsort(rightSet, lenSecondset/sizeof(uint), sizeof(uint), sort);
  uint prevleft = 0;
  uint prevright = 0;
  // Iterate over both arrays
  while(leftCounter < lenFirstset/sizeof(uint) && rightCounter < lenSecondset/sizeof(uint))
  {
    uint leftval = leftSet[leftCounter];
    uint rightval = (rightSet[rightCounter] - 1);
    if(prevleft == leftval) {
      leftCounter++;
      prevleft = leftval;
    }
    else if(prevright == rightval) {
      rightCounter++;
      prevright = rightval;
    }
    else if(leftval == rightval) {
      interim[matchCount] = rightSet[rightCounter];
      matchCount++;
      leftCounter++;
      rightCounter++;
      prevleft = leftval;
      prevright = rightval;
    }
    else if(leftval < rightval) {
      leftCounter++;
      prevleft = leftval;
    }
    else if(leftval > rightval) {
      rightCounter++;
      prevright = rightval;
    }
    else {
      leftCounter++;
      prevleft = leftval;
    }
  }
	// for (outerCounter = 0; outerCounter < lenFirstset/sizeof(uint); outerCounter++) {
		// for (innerCounter = 0; innerCounter < lenSecondset/sizeof(uint); innerCounter++) {
			// if (leftSet[outerCounter] == rightSet[innerCounter] - 1) {
				// interim[matchCount] = rightSet[innerCounter];
				// matchCount++;
				// }
			// }
		// }
		
	unsigned * out = (unsigned *)rtlMalloc(matchCount * sizeof(uint));
	if (matchCount > 0) {
		theresults = out;
		for (unsigned m=0; m<matchCount; m++) {
			theresults[m] = interim[m];
			}
		}
	rtlFree(interim);
 __lenResult = matchCount * sizeof(uint);
 __result = out;
 __isAllResult = false;
 
ENDC++;


export FN_MatchPhrase(grouped dataset($.Indexes.ValLayout) normresultDS, 
                      dataset($.Layouts.CommandStack)commandStack,
							 typeof($.Indexes.ColWordPosIdxSuperKey) colWordPosIdx) := function
	
	L_combined := record
		$.Indexes.ValLayout;
		unsigned8 opcode_num;
		unsigned4 stack_id;
	end;
	
	L_combined buildCombinedDS($.Indexes.ValLayout L, integer cnt) := transform
		self.source_id := L.source_id;
		self.record_id := L.record_id;
		self.value_hash := commandStack[cnt].term_hash;
		self.opcode_num := commandStack[cnt].opcode_num;
		self.stack_id := commandStack[cnt].stack_id;
		self := l;
	end;
	
	combinedCmdStack := normalize(CHOOSEN(normresultDS, 10000), count(commandStack), buildCombinedDS(left, counter));
	
	L_combinedPlus := record
		L_combined;
		boolean keepRec:=true;
		boolean accumRec := false;
		boolean accumRec2 := false;
		set of unsigned4 positions {MAXCOUNT(5000)};
	end;
	// Join those records against the index that has the column position
   allMatchingWordsDS := join(combinedCmdStack, colWordPosIdx
        , keyed(left.source_id = right.source_id and left.record_id = right.record_id and left.value_hash = right.value_hash)
        , transform({L_combinedPlus}, self.col := right.col, self.col_position := right.col_position, 
                                      self.positions := [self.col_position + ((self.col - 1)* 250)],
                                      self.value_hash := right.value_hash, self.entity_type := right.entity_type, self := left)
        , left outer);
   L_combinedPlus consolidateColumns(L_combinedPlus L, L_combinedPlus R) := transform
		self.positions := l.positions + r.positions;
	   self := r;
   end;
   phraseMatchCandidates1 := sort(allMatchingWordsDS, source_id, record_id, stack_id, col, entity_type, col_position);
   phraseMatchCandidates2 := DEDUP(phraseMatchCandidates1, source_id, record_id, stack_id, col, entity_type, col_position);
   phraseMatchCandidates3 := rollup(phraseMatchCandidates2, left.source_id = right.source_id and left.record_id = right.record_id and left.stack_id = right.stack_id,
                   consolidateColumns(left, right));
   L_combinedPlus findMatches(L_combinedPlus L, L_combinedPlus R) := transform
    SET OF UNSIGNED4 intersection := compareSets(l.positions, r.positions);
    BOOLEAN anyoverlap := IF(COUNT(intersection) > 0, TRUE, FALSE);
    SELF.positions := IF(R.opcode_num = $.Constants.PRE_1_OPCODE_NUM, intersection, R.positions);
		SELF.accumRec := MAP(R.opcode_num = $.Constants.PUSH_OPCODE_NUM => L.keepRec
				, R.opcode_num = $.Constants.POP_AND_OPCODE_NUM => L.accumRec2
				, R.opcode_num = $.Constants.POP_OR_OPCODE_NUM => L.accumRec2
				, R.opcode_num = $.Constants.POP_AND_NOT_OPCODE_NUM => L.accumRec2
				, L.accumRec);
      SELF.accumRec2 := MAP(R.opcode_num = $.Constants.PUSH_OPCODE_NUM => L.accumRec
				, R.opcode_num = $.Constants.POP_AND_OPCODE_NUM => false
				, R.opcode_num = $.Constants.POP_OR_OPCODE_NUM => false
				, R.opcode_num = $.Constants.POP_AND_NOT_OPCODE_NUM => false
				, L.accumRec2);				
		self.keepRec := map ( R.opcode_num = $.Constants.PUSH_OPCODE_NUM => (R.value_hash != 0),
		                      R.opcode_num = $.Constants.POP_AND_OPCODE_NUM => if (l.keepRec and l.accumRec, true, false),
									 R.opcode_num = $.Constants.POP_OR_OPCODE_NUM => if (l.keepRec or l.accumRec, true, false),
									 R.opcode_num = $.Constants.AND_OPCODE_NUM => if (l.keepRec and (l.value_hash != 0 and r.value_hash != 0), true, false),
		                      R.opcode_num = $.Constants.OR_OPCODE_NUM => if (l.keepRec or (l.value_hash != 0 or r.value_hash != 0), true, false),
									 R.opcode_num = $.Constants.PRE_1_OPCODE_NUM => if (anyoverlap, true, false),
									 R.opcode_num = $.Constants.AND_NOT_OPCODE_NUM => if (l.keepRec and (l.value_hash != 0 and r.value_hash = 0), true, false),
									 R.opcode_num = $.Constants.POP_AND_NOT_OPCODE_NUM => if ((l.keepRec = false) and l.accumRec, true, false),
									 false);
      self.value_hash := map (R.opcode_num = $.Constants.POP_AND_OPCODE_NUM and self.keepRec = true => 1,
		                        R.opcode_num = $.Constants.POP_OR_OPCODE_NUM and self.keepRec = true => 1,
										R.opcode_num = $.Constants.POP_AND_NOT_OPCODE_NUM and self.keepRec = true => 1,
										r.value_hash);
	   self := r;
   end;
	
	rolledUpResults := rollup(phraseMatchCandidates3, left.source_id = right.source_id and left.record_id = right.record_id, findMatches(left, right));
	matchedPhraseRecsDS := project(rolledUpResults(keepRec = true), transform($.Indexes.ValLayout, self := left));
	return group(matchedPhraseRecsDS, source_id, col_item);
end;

END;