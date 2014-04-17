export Constants := module
export CLUSTER_NAME:='mythor';
export CONCEPT_MAX_LENGTH := 20000;
export INDEX_MAX_LENGTH := 20000;
export MAX_LENGTH := 20000;
export INDEX_LAYOUT_MAX_LEN := 20000; 


export CommandType := ENUM(unsignedl, 
					OP_EQ , 
					OP_NEQ, 
					OP_GT, 
					OP_NGT, 
					OP_GTE, 
					OP_NGTE, 
					OP_LT, 
					OP_NLT, 
					OP_LTE, OP_NLTE, OP_OR, OP_AND, OP_NOT, OP_PHRASE) ; 
 export CommandFilter := [CommandType.OP_EQ, CommandType.OP_NEQ, 
													CommandType.OP_GT, CommandType.OP_NGT, 
													CommandType.OP_GTE, CommandType .OP_NGTE, 
													CommandType.OP_LT, CommandType.OP_NLT, 
													CommandType.OP_LTE, CommandType.OP_NLTE]; 
 export CommandOp := [CommandType.OP_OR, CommandType. OP_AND,CommandType.OP_PHRASE] ;
 
 
  export OR_OPCODE_NUM := 1;
   export AND_OPCODE_NUM := 2;
   export PRE_1_OPCODE_NUM := 3;
   export AND_NOT_OPCODE_NUM := 9;
   export PUSH_OPCODE_NUM := 10;
   export POP_AND_OPCODE_NUM := 11;
   export POP_OR_OPCODE_NUM := 12;
   export POP_AND_NOT_OPCODE_NUM := 19;
end;