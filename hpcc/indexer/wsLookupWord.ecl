/*--SOAP--
<message name="wsLookupWord">
<part name="word" type="xsd:string" required="1"/>
<part name="idxtype" type="xsd:string" required="1"/>
</message>
*/
/*--INFO-- Returns list of concept retrieval reference data.
*/
/*--HELP-- enter a word with wildcards (M*H*MD) for all words matching that pattern. 
*/
import indexer;
export wsLookupWord() := function
		unicode word := u'' : stored('word');
		string idxtype := '' : stored('idxtype');			
 
//TOTAL hack. TODO: figure out cause of garbage characters appeneded to unicode web query input
 uword:=if (length(word)>2 
							and indexer.Utility.tf(word[length(word)])=0
							and indexer.Utility.tf(word[length(word)-1])=0,
							word[1..length(word)-2],word);
							
		wordCntSk := Indexer.indexes.CntSingleIndex;
		substringSk := Indexer.indexes.SubstringMiddleIndexKey;
		substringFlSk := Indexer.indexes.SubstringFirstLastIndexKey;
emptyset:=DATASET([],Indexer.Layouts.L_Word);
words1 := Indexer.FN_LookupWord(uWord, substringFlSk, substringSk, wordCntSk, 1000);
words := DEDUP(SORT(words1, word), word);
result := IF (uWord=u'',emptyset,words);
wordset :=SET(result,word);
return parallel(output(length(uword),named('uwordlength')),
output(indexer.utility.tf(uword[4]),named('uword4')),
output(uword,named('originalword')),output(wordset,named('Words')));
END;
