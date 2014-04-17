import $;

export ParseWords(STRING LineIn) := FUNCTION
PATTERN Ltrs := PATTERN('[A-Za-z]');
PATTERN Char := Ltrs | '-' | '\'';
TOKEN Word := Char+;
ds := DATASET([{LineIn}],{STRING line});
RETURN PARSE(ds,line,Word,{STRING Pword := MATCHTEXT(Word)});
END;