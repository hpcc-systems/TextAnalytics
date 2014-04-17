import $;
/*
 * Much like SearchIndex, but does not support phrases
 *
 * The command stack will contain the expanded wildcard terms and sounds-like terms
 * for example cat* would have cat, catepillar, catalog ... in the command stack
L_CommandStack :=RECORD, MAXLENGTH(20000) 
    unsigned2 stack_id;
		unsigned8 opcode_num :=0; 
		unicode term, 
		unsigned8 term_hash :=0; 
		string type_name:='';
		integer8 type_hash:=0;		
END; 
Test search
// (A or B or CD or MN) AND (E and (F or G or XY))
Explicitly parenthesized search
// (A or (B or ((C and D) or (M and N))) and (E and (F or (G or (X and Y))))
stack := DATASET([
  { 1, 0, 'C', ''}
, { 2, 2, 'D', 'AND'}
, { 3, 1, 'B', 'OR'}
, { 4, 1, 'A', 'OR'}
, { 5, 10, 'X', 'PUSH'}
, { 6, 2, 'Y', 'AND'}
, { 7, 1, 'G', 'OR'}
, { 8, 1, 'F', 'OR'}
, { 9, 2, 'E', 'AND'}
, {10, 11, '', 'POP AND'}
], layout_stack);
*/
export SearchIndexSimple(DATASET($.layouts.CommandStack) stack,
              typeof($.indexes.BitmapSuperKey) bitmapIndex,
              typeof($.indexes.ColWordPosIdxSuperKey) colWordPosIndex,
              string rawBitmapDataFileName,
              integer startoffset,
              set of integer inSourceSet = [],
              set of integer excludeSourceSet = [],
              integer pageSize) := function 
   MAX_RECORDS := 200;
   OR_OPCODE_NUM := $.Constants.OR_OPCODE_NUM;
   AND_OPCODE_NUM := $.Constants.AND_OPCODE_NUM;
   PRE_OPCODE_NUM := $.Constants.PRE_1_OPCODE_NUM;
   NOT_OPCODE_NUM := $.Constants.AND_NOT_OPCODE_NUM;
   PUSH_OPCODE_NUM := $.Constants.PUSH_OPCODE_NUM;
   POP_AND_OPCODE_NUM := $.Constants.POP_AND_OPCODE_NUM;
   POP_OR_OPCODE_NUM := $.Constants.POP_OR_OPCODE_NUM;
   POP_AND_NOT_OPCODE_NUM := $.Constants.POP_AND_NOT_OPCODE_NUM;
////////////////////////////
/// BITMAP INDEX SEARCH HERE
/// 
/// 
BitmapLayout := $.indexes.BitmapLayout;
layout_ret := $.indexes.layout_ret;
layout_int := $.indexes.layout_int;
combinedBmpRec := $.indexes.combinedBmpRec;
stack1 := $.Functions.FN_TypeHashSet(stack);
bmpi := JOIN(stack1, bitmapIndex, LEFT.term_hash = RIGHT.value_hash AND RIGHT.type_hash IN LEFT.type_hash_set
AND IF(COUNT(inSourceSet) > 0, RIGHT.source_id IN inSourceSet, TRUE)
AND IF(COUNT(excludeSourceSet) > 0, RIGHT.source_id NOT IN excludeSourceSet, TRUE)
        , TRANSFORM(combinedBmpRec, SELF.search_id := LEFT.search_id; SELF.stack_id := LEFT.stack_id; SELF.opcode_num := LEFT.opcode_num; SELF.term := LEFT.term; SELF := RIGHT));
//haveachance := IF(COUNT(stack) > 1 AND COUNT(stack) < 20, $.FN_HasAChanceFilter(bmpi, stack), GROUP(SORTED(bmpi, source_id, item), source_id, item));
haveachance := bmpi;
rawBitmapDataDS := DATASET(rawBitmapDataFileName, {BitmapLayout, UNSIGNED8 fpos{virtual(fileposition) }}, THOR); 
recf := FETCH(rawBitmapDataDS, haveachance, RIGHT.fpos);
rec  := PROJECT(recf, TRANSFORM(recordof(recf), SELF.record_id := 1; SELF := LEFT));
sr := SORT(rec, source_id, col_item, search_id, stack_id, value_hash, type_hash);
// Layout with accumulator
layout_accum := {
   DATASET(layout_int) accumWord{MAXLENGTH(20480)};
   DATASET(layout_int) accumOffset{MAXLENGTH(20480)};
   DATASET(layout_int) accumWord1{MAXLENGTH(20480)};
   DATASET(layout_int) accumOffset1{MAXLENGTH(20480)};
   recordof(sr);
   INTEGER missingCnt := 1;
};
// GROUP records by 
groupsr := GROUP(sr, source_id, col_item, search_id);
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
layout_accum addMissingViaJoin(groupsr L, stack R) := TRANSFORM
  SELF.searchable_value := IF(L.value_hash = R.term_hash, L.searchable_value, u'');
  SELF.entity_type := IF(L.value_hash = R.term_hash, L.entity_type, R.type_name);
  SELF.value_hash := IF(L.value_hash = R.term_hash, L.value_hash, 0);
  SELF.type_hash := IF(L.value_hash = R.term_hash, L.type_hash, 0);
  SELF.source_id := L.source_id;
  SELF.record_id := L.record_id;
  SELF.col := L.col;
  SELF.col_item := L.col_item;
  SELF.col_position := L.col_position;
  SELF.bpos := L.bpos;
  SELF.word := IF(L.value_hash = R.term_hash, L.word, DATASET([], layout_int));
  SELF.offset := IF(L.value_hash = R.term_hash, L.offset, DATASET([], layout_int));
  SELF.stack_id := R.stack_id;
  SELF.opcode_num := R.opcode_num;
  SELF.term := R.term;
  SELF.fpos := L.fpos;
  SELF.search_id := L.search_id;
  SELF.accumWord := [];
  SELF.accumOffset := [];
  SELF.accumWord1 := [];
  SELF.accumOffset1 := [];
END;
jsr1 := JOIN(groupsr, stack, LEFT.search_id = RIGHT.search_id, addMissingViaJoin(LEFT, RIGHT), LEFT OUTER, GROUPED, ALL);
jsr2 := SORT(jsr1, source_id, col_item, search_id, stack_id, -searchable_value);
jsr3 := DEDUP(jsr2, source_id, col_item, search_id, stack_id);
groupsr8 := PROJECT(jsr3, TRANSFORM(layout_accum, SELF.accumWord := [], SELF.accumOffset := [], 
                           SELF.accumWord1 := [], SELF.accumOffset1 := [], SELF := LEFT));
// ROLLUP
layout_accum rollupBitmap(layout_accum L, layout_accum R) := TRANSFORM
SELF.accumWord := MAP(R.opcode_num = PUSH_OPCODE_NUM => L.word
, R.opcode_num = POP_AND_OPCODE_NUM => L.accumWord1
, R.opcode_num = POP_OR_OPCODE_NUM => L.accumWord1
, R.opcode_num = POP_AND_NOT_OPCODE_NUM => L.accumWord1
, L.accumWord);
SELF.accumOffset := MAP(R.opcode_num = PUSH_OPCODE_NUM => L.offset
, R.opcode_num = POP_AND_OPCODE_NUM => L.accumOffset1
, R.opcode_num = POP_OR_OPCODE_NUM => L.accumOffset1
, R.opcode_num = POP_AND_NOT_OPCODE_NUM => L.accumOffset1
, L.accumOffset);
SELF.accumWord1 := MAP(R.opcode_num = PUSH_OPCODE_NUM => L.accumWord
, R.opcode_num = POP_AND_OPCODE_NUM => DATASET([], layout_int)
, R.opcode_num = POP_OR_OPCODE_NUM => DATASET([], layout_int)
, R.opcode_num = POP_AND_NOT_OPCODE_NUM => DATASET([], layout_int)
, L.accumWord1);
SELF.accumOffset1 := MAP(R.opcode_num = PUSH_OPCODE_NUM => L.accumOffset
, R.opcode_num = POP_AND_OPCODE_NUM => DATASET([], layout_int)
, R.opcode_num = POP_OR_OPCODE_NUM => DATASET([], layout_int)
, R.opcode_num = POP_AND_NOT_OPCODE_NUM => DATASET([], layout_int)
, L.accumOffset1);
retsetsOR  := $.datasets.orintsets(L.word, L.offset, R.word, R.offset);
retsetsAND := $.datasets.andintsets(L.word, L.offset, R.word, R.offset);
retsetsNOT := $.datasets.andnotintsets(L.word, L.offset, R.word, R.offset);
//retsetsPUSH := word and offset are taken directly from the right
retsetsPopOR := $.datasets.orintsets(L.accumWord, L.accumOffset, L.word, L.offset);
retsetsPopAND := $.datasets.andintsets(L.accumWord, L.accumOffset, L.word, L.offset);
retsetsPopANDNOT := $.datasets.andnotintsets(L.accumWord, L.accumOffset, L.word, L.offset);
SELF.word := MAP(R.opcode_num = PUSH_OPCODE_NUM => R.word
, R.opcode_num = OR_OPCODE_NUM => retsetsOR.word
, R.opcode_num = AND_OPCODE_NUM => retsetsAND.word
, R.opcode_num = PRE_OPCODE_NUM => retsetsAND.word
, R.opcode_num = NOT_OPCODE_NUM => retsetsNOT.word
, R.opcode_num = POP_AND_OPCODE_NUM => retsetsPopAND.word
, R.opcode_num = POP_OR_OPCODE_NUM => retsetsPopOR.word
, R.opcode_num = POP_AND_NOT_OPCODE_NUM => retsetsPopANDNOT.word
, R.word);
SELF.offset := MAP(R.opcode_num = PUSH_OPCODE_NUM => R.offset
, R.opcode_num = OR_OPCODE_NUM => retsetsOR.offset
, R.opcode_num = AND_OPCODE_NUM => retsetsAND.offset
, R.opcode_num = PRE_OPCODE_NUM => retsetsAND.offset
, R.opcode_num = NOT_OPCODE_NUM => retsetsNOT.offset
, R.opcode_num = POP_AND_OPCODE_NUM => retsetsPopAND.offset
, R.opcode_num = POP_OR_OPCODE_NUM => retsetsPopOR.offset
, R.opcode_num = POP_AND_NOT_OPCODE_NUM => retsetsPopANDNOT.offset
, R.offset);
SELF.searchable_value := L.searchable_value + u', ' + R.searchable_value;
SELF := R;
END;
rolledsr := ROLLUP(groupsr8, LEFT.source_id = RIGHT.source_id AND LEFT.col_item = RIGHT.col_item, rollupBitmap(LEFT, RIGHT));
rolledsrHAC := rolledsr(COUNT(word) > 0);
// convert from bitmaps to documents
vallayout := {
  $.Indexes.ValLayout;
  UNSIGNED4 word;
};
valLayout toValLayout(layout_accum L, INTEGER C) := TRANSFORM
  SELF.record_id := L.offset[C].val * 32;
  SELF.word := L.word[C].val;
  SELF := L;
END;
normresult := NORMALIZE(rolledsrHAC, COUNT(LEFT.word), toValLayout(LEFT, COUNTER));
$.indexes.ValLayout toValLt(valLayout L, INTEGER C) := TRANSFORM
  dist := IF(C = 32, 0, C);
  UNSIGNED4 doc := ((UNSIGNED4)(L.word << dist)) >> 31;
  SELF.record_id := IF(doc > 0, (L.record_id) + (32 - dist), SKIP);
  SELF := L;
END;
normresult2 := NORMALIZE(normresult, 32, toValLt(LEFT, COUNTER));
normresult4 := CHOOSEN(normresult2, pageSize, startoffset);
sortedresult := SORT(normresult4, source_id, record_id);
   return sortedresult;
end;

