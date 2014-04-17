import $;
export testcommamndstacks:= module

			 
   // Test 1 - A pre/1 B
	export DS_test1 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
   // Test 2 -  A and B
	export DS_test2 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.AND_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
   // Test 3 - A or B
	export DS_test3 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.OR_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
   // Test 4 - (A pre/1 B) or (C pre/1 D)	
	export DS_test4 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0}
					  , {5, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
   // Test 5 - (A pre/1 B) and (C pre/1 D)
	export DS_test5 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0}
					  , {5, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
   // (A or B or C pre/1 D) and (E or F or G pre/1 H)
   export DS_test6 := DATASET([{1, 0, u'C', HASH64(u'C'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0}
					  , {3, indexer.Constants.OR_OPCODE_NUM, u'A', HASH64(u'A'), '', 0}
					  , {4, indexer.Constants.OR_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {5, indexer.Constants.PUSH_OPCODE_NUM, u'G', HASH64(u'G'), '', 0}
					  , {6, indexer.Constants.PRE_1_OPCODE_NUM, u'H', HASH64(u'H'), '', 0}
					  , {7, indexer.Constants.OR_OPCODE_NUM, u'E', HASH64(u'E'), '', 0}
					  , {8, indexer.Constants.OR_OPCODE_NUM, u'F', HASH64(u'F'), '', 0}
					  , {9, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
									 
// (A pre/1 B or C pre/1 D) and (E pre/1 F or G pre/1 H)
   export DS_test7 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0}
					  , {5, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {6, indexer.Constants.PUSH_OPCODE_NUM, u'E', HASH64(u'E'), '', 0}
					  , {7, indexer.Constants.PRE_1_OPCODE_NUM, u'F', HASH64(u'F'), '', 0}
					  , {8, indexer.Constants.PUSH_OPCODE_NUM, u'G', HASH64(u'G'), '', 0}
					  , {9, indexer.Constants.PRE_1_OPCODE_NUM, u'H', HASH64(u'H'), '', 0}
					  , {10, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {11, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
// ((A pre/1 B or C pre/1 D) and K) and (E pre/1 F or G pre/1 H)
   export DS_test8 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0}
					  , {5, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {6, indexer.Constants.AND_OPCODE_NUM, u'X', HASH64(u'X'), '', 0}
					  , {7, indexer.Constants.PUSH_OPCODE_NUM, u'E', HASH64(u'E'), '', 0}
					  , {8, indexer.Constants.PRE_1_OPCODE_NUM, u'F', HASH64(u'F'), '', 0}
					  , {9, indexer.Constants.PUSH_OPCODE_NUM, u'G', HASH64(u'G'), '', 0}
					  , {10, indexer.Constants.PRE_1_OPCODE_NUM, u'H', HASH64(u'H'), '', 0}
					  , {11, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {12, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
// ((A pre/1 B or C pre/1 D or E pre/1 F)
   export DS_test9 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0}
					  , {5, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {6, indexer.Constants.PUSH_OPCODE_NUM, u'E', HASH64(u'E'), '', 0}
					  , {7, indexer.Constants.PRE_1_OPCODE_NUM, u'F', HASH64(u'F'), '', 0}
					  , {8, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);									 
// ((A pre/1 B pre/1 G)
   export DS_test10 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PRE_1_OPCODE_NUM, u'G', HASH64(u'G'), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
// (A or B or C) and (E or F) and (X or Y or Z)
   export DS_test11 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.OR_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.OR_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PUSH_OPCODE_NUM, u'E', HASH64(u'E'), '', 0}
					  , {5, indexer.Constants.OR_OPCODE_NUM, u'F', HASH64(u'F'), '', 0}
					  , {6, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {7, indexer.Constants.PUSH_OPCODE_NUM, u'X', HASH64(u'X'), '', 0}
					  , {8, indexer.Constants.OR_OPCODE_NUM, u'Y', HASH64(u'Y'), '', 0}
					  , {9, indexer.Constants.OR_OPCODE_NUM, u'Z', HASH64(u'Z'), '', 0}
					  , {10, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0}
                                                                                                    ], indexer.Layouts.CommandStack);
// (A and not C)
   export DS_test12 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.AND_NOT_OPCODE_NUM, u'C', HASH64(u'C'), '', 0, true}
                                                                                                    ], indexer.Layouts.CommandStack);
   // (A pre/1 B) and not (C pre/1 D)
	export DS_test13 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'C', HASH64(u'C'), '', 0, true}
					  , {4, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0, true}
					  , {5, indexer.Constants.POP_AND_NOT_OPCODE_NUM, u'', HASH64(u''), '', 0, true}
                                                                                                    ], indexer.Layouts.CommandStack);
// (A or B or C pre/1 D) and not (E or F or G pre/1 H)
   export DS_test14 := DATASET([{1, 0, u'C', HASH64(u'C'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0}
					  , {3, indexer.Constants.OR_OPCODE_NUM, u'A', HASH64(u'A'), '', 0}
					  , {4, indexer.Constants.OR_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {5, indexer.Constants.PUSH_OPCODE_NUM, u'G', HASH64(u'G'), '', 0, true}
					  , {6, indexer.Constants.PRE_1_OPCODE_NUM, u'H', HASH64(u'H'), '', 0, true}
					  , {7, indexer.Constants.OR_OPCODE_NUM, u'E', HASH64(u'E'), '', 0, true}
					  , {8, indexer.Constants.OR_OPCODE_NUM, u'F', HASH64(u'F'), '', 0, true}
					  , {9, indexer.Constants.POP_AND_NOT_OPCODE_NUM, u'', HASH64(u''), '', 0, true}
                                                                                                    ], indexer.Layouts.CommandStack);
// (A pre/1 B or C pre/1 D) and not (E pre/1 F or G pre/1 H)
   export DS_test15 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PRE_1_OPCODE_NUM, u'D', HASH64(u'D'), '', 0}
					  , {5, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {6, indexer.Constants.PUSH_OPCODE_NUM, u'E', HASH64(u'E'), '', 0, true}
					  , {7, indexer.Constants.PRE_1_OPCODE_NUM, u'F', HASH64(u'F'), '', 0, true}
					  , {8, indexer.Constants.PUSH_OPCODE_NUM, u'G', HASH64(u'G'), '', 0, true}
					  , {9, indexer.Constants.PRE_1_OPCODE_NUM, u'H', HASH64(u'H'), '', 0, true}
					  , {10, indexer.Constants.POP_OR_OPCODE_NUM, u'', HASH64(u''), '', 0, true}
					  , {11, indexer.Constants.POP_AND_NOT_OPCODE_NUM, u'', HASH64(u''), '', 0, true}
                                                                                                    ], indexer.Layouts.CommandStack);
// (A or B) and not (X and Y)
   export DS_test16 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.and_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'X', HASH64(u'X'), '', 0, true}
					  , {4, indexer.Constants.AND_OPCODE_NUM, u'Y', HASH64(u'Y'), '', 0, true}
					  , {5, indexer.Constants.POP_AND_NOT_OPCODE_NUM, u'', HASH64(u''), '', 0, true}
                                                                                                    ], indexer.Layouts.CommandStack);
// (A pre/1 B) and not (F)
   export DS_test17 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.PRE_1_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.PUSH_OPCODE_NUM, u'F', HASH64(u'F'), '', 0, true}
					  , {4, indexer.Constants.POP_AND_NOT_OPCODE_NUM, u'', HASH64(u''), '', 0, true}
                                                                                                    ], indexer.Layouts.CommandStack);
// (A or B or C) and (E or F) and not (X or Y or Z)
   export DS_test18 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.OR_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.OR_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PUSH_OPCODE_NUM, u'E', HASH64(u'E'), '', 0}
					  , {5, indexer.Constants.OR_OPCODE_NUM, u'F', HASH64(u'F'), '', 0}
					  , {6, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {7, indexer.Constants.PUSH_OPCODE_NUM, u'X', HASH64(u'X'), '', 0, true}
					  , {8, indexer.Constants.OR_OPCODE_NUM, u'Y', HASH64(u'Y'), '', 0, true}
					  , {9, indexer.Constants.OR_OPCODE_NUM, u'Z', HASH64(u'Z'), '', 0, true}
					  , {10, indexer.Constants.POP_AND_NOT_OPCODE_NUM, u'', HASH64(u''), '', 0, true}
                                                                                                    ], indexer.Layouts.CommandStack);
										
// (A or B or C) and (E or F) and (X)
   export DS_test19 := DATASET([{1, 0, u'A', HASH64(u'A'), '', 0}
	                          , {2, indexer.Constants.OR_OPCODE_NUM, u'B', HASH64(u'B'), '', 0}
					  , {3, indexer.Constants.OR_OPCODE_NUM, u'C', HASH64(u'C'), '', 0}
					  , {4, indexer.Constants.PUSH_OPCODE_NUM, u'E', HASH64(u'E'), '', 0}
					  , {5, indexer.Constants.OR_OPCODE_NUM, u'F', HASH64(u'F'), '', 0}
					  , {6, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0}
					  , {7, indexer.Constants.PUSH_OPCODE_NUM, u'X', HASH64(u'X'), '', 0, false}
					  , {8, indexer.Constants.POP_AND_OPCODE_NUM, u'', HASH64(u''), '', 0, false}
                                                                                                    ], indexer.Layouts.CommandStack);
end;
