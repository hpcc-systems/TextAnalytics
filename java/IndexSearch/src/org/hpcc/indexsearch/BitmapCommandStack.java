package org.hpcc.indexsearch;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;
import org.hpcc.indexsearch.util.DateUtility;
import org.hpcc.indexsearch.util.Utility;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;


public class BitmapCommandStack {

	 public enum CommandType{
				NO_OPCODE(0) , 
				OR_OPCODE_NUM(1) , 
				AND_OPCODE_NUM(2), 
				PRE_1_OPCODE_NUM(3), 
				AND_NOT_OPCODE_NUM(9), 
				PUSH_OPCODE_NUM(10), 
				POP_AND_OPCODE_NUM(11), 
				POP_OR_OPCODE_NUM(12), 
				POP_AND_NOT_OPCODE_NUM(19); 
				
				
			    private int code;   
			 
			    
			    private CommandType(int ecl_code) {   
			        this.code = ecl_code;   
			    }   
			    
			    public int getEclCode() {   
			        return code;   
			    } 

			    public static CommandType valueOf(int code)
			    {
			    	  switch(code)
				        {
				        case (0):
				        	return CommandType.NO_OPCODE;			        	
				        case(1):
				        	return CommandType.OR_OPCODE_NUM;
				        case(2):
				        	return CommandType.AND_OPCODE_NUM;
				        case(3):
				        	return CommandType.PRE_1_OPCODE_NUM;
				        case(9):
				        	return CommandType.AND_NOT_OPCODE_NUM;
				        case(10):
				        	return CommandType.PUSH_OPCODE_NUM;
				        case(11):
				        	return CommandType.POP_AND_OPCODE_NUM;
				        case(12):
				        	return CommandType.POP_OR_OPCODE_NUM;
				        case(19):
				        	return CommandType.POP_AND_NOT_OPCODE_NUM;
				        default:
				        	return CommandType.NO_OPCODE;
				        }   
			    }
			    public String getText() {   
			        switch(code)
			        {
			        case (0):
			        	return " ";			        	
			        case(1):
			        	return " OR ";
			        case(2):
			        	return " AND ";
			        case(3):
			        	return " ";
			        case(9):
			        	return " NOT ";
			        case(10):
			        	return "(";
			        case(11):
			        	return ")";
			        case(12):
			        	return "(";
			        case(19):
			        	return ")";
			        default:
			        	return this.name();
			        }   
			    } 
	 }; 

	 

	 public class CommandStackItem {
	 	 public int stack_id=0;
	 	 public BitmapCommandStack.CommandType opcode=CommandType.NO_OPCODE;
	 	 public String term="";
	 	 public String term_hash="";
	 	 public String type="";
	 	 public long type_hash=0;
	 	 String wildcardword="";
	 	 private boolean not_phrase;
	 	
	 	 
	 	 public boolean equalsIgnoreType(CommandStackItem other)
	 	 {
	 		 if (term.equals(other.term) && stack_id==other.stack_id && opcode.equals(other.opcode))
	 		 {
	 			 return true;
	 		 }
	 		 else {
	 			 return false;
	 		 }	 		 
	 	 }
	 	 public CommandStackItem(Element node)
	 	 {

	 		NodeList opcodes=node.getElementsByTagName("opcode_num");
			if (opcodes != null && opcodes.getLength()> 0)
			{
				int num=Integer.valueOf(opcodes.item(0).getTextContent().trim());
	 			this.opcode=CommandType.valueOf(num);
	 		}
	 		NodeList stackids=node.getElementsByTagName("stack_id");
			if (stackids != null && stackids.getLength()> 0)
			{
	 			this.stack_id=Integer.valueOf(stackids.item(0).getTextContent().trim());
	 		}
			
	 		if (node.getElementsByTagName("term") != null && node.getElementsByTagName("term").getLength() > 0)
	 		{
	 			this.term=node.getElementsByTagName("term").item(0).getTextContent().trim();	 			
	 		}
	 		if (node.getElementsByTagName("term_hash") != null && node.getElementsByTagName("term_hash").getLength() > 0)
	 		{
	 			this.term_hash=node.getElementsByTagName("term_hash").item(0).getTextContent().trim();
	 		}	 		
	 		if (node.getElementsByTagName("type_name") != null && node.getElementsByTagName("type_name").getLength() > 0)
	 		{
	 			this.type=node.getElementsByTagName("type_name").item(0).getTextContent().trim();
	 		}
	 		if (node.getElementsByTagName("type_hash") != null && node.getElementsByTagName("type_hash").getLength() > 0)
	 		{
	 			this.type_hash=Long.valueOf(node.getElementsByTagName("type_hash").item(0).getTextContent().trim());
	 		}
	 		if (node.getElementsByTagName("not_phrase") != null && node.getElementsByTagName("not_phrase").getLength() > 0)
	 		{
	 			this.not_phrase=Boolean.valueOf(node.getElementsByTagName("not_phrase").item(0).getTextContent().trim());
	 		}
	 	 }
	 	 public CommandStackItem(int line_number,String word,String word_hash, String wordType,
	 			 BitmapCommandStack.CommandType cmdType,boolean notphrase)
	 	 {
	 		 term=word.trim().toUpperCase();
	 		 term_hash=word_hash;
	 		 opcode=cmdType;
	 		 type=wordType;	 		
	 		 stack_id=line_number;
	 		 not_phrase=notphrase;
	 	 } 	 
	 	 public String ToXML()
	 	 {
	 		 String displayType=type;
	 		 if (opcode.equals(BitmapCommandStack.CommandType.POP_AND_NOT_OPCODE_NUM)
	 			 ||opcode.equals(BitmapCommandStack.CommandType.POP_AND_OPCODE_NUM)
	 			 || opcode.equals(BitmapCommandStack.CommandType.POP_OR_OPCODE_NUM)
	 		 )
	 		 {
	 			displayType=""; 
	 		 }
	 		 StringBuilder sb=new StringBuilder();
	 		 sb.append("\t<Row>\n");
	 		 sb.append("\t\t<stack_id>").append(String.valueOf(stack_id)).append("</stack_id>\n");
	 		 sb.append("\t\t<opcode_num>").append(String.valueOf(opcode.getEclCode())).append("</opcode_num>\n");	 		
			 sb.append("\t\t<term>").append(term).append("</term>\n");			
	 		 sb.append("\t\t<term_hash>").append(term_hash).append("</term_hash>\n");
	 		 sb.append("\t\t<type_name>").append(displayType).append("</type_name>\n");
	 		 sb.append("\t\t<type_hash>").append("0").append("</type_hash>\n");	 			 		 
	 		 sb.append("\t\t<not_phrase>").append(String.valueOf(not_phrase)).append("</not_phrase>\n");
	 		 sb.append("\t</Row>\n");
	 		 try {
		 		 return sb.toString();//new String(sb.toString().getBytes("ISO-8859-1"), "UTF-8");
	 		 }
	 		 catch (Exception e)
	 		 {
	 			 return "";
	 		 }
	 	 }
	 	 public String toString()
	 	 {
             StringBuilder sb=new StringBuilder();
             sb.append("stack_id:").append(String.valueOf(stack_id));
             sb.append("|opcode_num:").append(String.valueOf(opcode.getEclCode()));           
             sb.append("|term:").append(term);          
             return sb.toString();
	 	 }
	 	 public String getTerm()
	 	 {
	 		 if (term==null) {
	 			 term="";
	 		 }
	 		 return term;
	 	 }
	 }
	 
	 public String wildcardUrl="";
	 public String metaphoneUrl="";
	 public String placeSynonymUrl="";
	 public String synonymUrl="";
	 public String roxieUrl="";
	 public String idxType="";
	 public HttpSession session=null;
	 public int current_line=1;
	 public ArrayList<CommandStackItem> _commands=new ArrayList<CommandStackItem>();
 
	  
	 public BitmapCommandStack(HttpSession ssn)
	 {
		 roxieUrl = ssn.getServletContext().getInitParameter("RoxieServerURL");
		 wildcardUrl = roxieUrl + ssn.getServletContext().getInitParameter("wildcardUrl");
		 metaphoneUrl =roxieUrl +  ssn.getServletContext().getInitParameter("metaphoneUrl");
		 synonymUrl =roxieUrl +  ssn.getServletContext().getInitParameter("synonymUrl");
		 placeSynonymUrl =roxieUrl +  ssn.getServletContext().getInitParameter("PlaceSynonymUrl");		
		 session=ssn;
	 }

	 private  HashMap<Integer,CommandStackItem> parsePhrase(String wordlist, String wordtype, CommandType defaultCommandType, boolean not_phrase,boolean addSynonyms) throws Exception
	 {
		 wordlist=wordlist.toUpperCase().trim();
		 boolean local_not_phrase=not_phrase;
		 CommandType currentCommand;
		 HashMap<Integer, CommandStackItem> cmds=new HashMap<Integer,CommandStackItem>();
		 if (wordlist.equals("")) {return cmds;}
		 
		 //look for phrases: an optional and/not/or before a quoted phrase
		 Pattern p = Pattern.compile("(NOT\\s{1,10}|OR\\s{1,10}|AND\\s{1,10})?(\".*?\")",Pattern.DOTALL); 
		 Matcher matcher = p.matcher(wordlist.toUpperCase()); 
		 String[] phrase=null;
		 int matchCount=1;
		 while(matcher.find()) { 
			 CommandType popCmdType=null;
			 
			 //if there is an "or" before the quoted phrase,
			 //add a POP_OR after processing the phrase
			 if (matcher.group(1) != null && matchCount > 1 && matcher.group(1).trim().equalsIgnoreCase("OR"))
			 {
				 popCmdType=CommandType.POP_OR_OPCODE_NUM;
			 }
			 //if there is an "and" before the quoted phrase,
			 //add a POP_OR after processing the phrase
			 else if (matcher.group(1) != null && matchCount > 1 &&  matcher.group(1).trim().equalsIgnoreCase("AND"))
			 {
				 popCmdType=CommandType.POP_AND_OPCODE_NUM;
			 }
			 //if there is an "not" before the quoted phrase,
			 //add a POP_OR after processing the phrase
			 else if (matcher.group(1) != null && matchCount > 1 &&  matcher.group(1).trim().equalsIgnoreCase("NOT"))
			 {
				 local_not_phrase=true;
				 popCmdType=CommandType.POP_AND_NOT_OPCODE_NUM;
			 }
			 //if this is not the first quoted set of words being processed,
			 //used the default command type (and, or, not) to set the pop command  (pop_and,pop_or,pop_not)
			 else if (matchCount > 1 && popCmdType==null)
			 {
				 if (defaultCommandType.equals(CommandType.AND_OPCODE_NUM))
				 {
					 popCmdType=CommandType.POP_AND_OPCODE_NUM;
				 }
				 else if (defaultCommandType.equals(CommandType.OR_OPCODE_NUM))
				 {
					 popCmdType=CommandType.POP_OR_OPCODE_NUM;
				 }
				 else if (defaultCommandType.equals(CommandType.AND_NOT_OPCODE_NUM))
				 {
					 popCmdType=CommandType.POP_AND_NOT_OPCODE_NUM;
				 }
			 }
			 //if no word was found inside the quotes, go on to the next match
			 if (matcher.group(2)==null)
			 {
				 continue;
			 }
			 
			 //replace any quotes in the words
			 String thisMatch=matcher.group(2);
			 thisMatch=thisMatch.replace("\"","");

			 
			 //handle multi-word phrases
			 phrase=StringUtils.split(thisMatch," ");			 
			 for (int i=0; i < phrase.length; i++)
			 {
				 String thisWordType=wordtype;
				 String thisWord=phrase[i];
				 if (IsComposite(phrase[i]))
				 {
					 thisWordType=GetCompositeType(phrase[i]);
					 thisWord=GetCompositeValue(phrase[i]);
				 }
				 boolean current_not_phrase=local_not_phrase;
				 //by default set first phrase word to no_opcode if this word string only contains the
				 //quoted phrase; change to push_opcode_num later if other phrases exist
				 if (i==0) 
				 {
					 if (current_line==1)
					 {
						 currentCommand=CommandType.NO_OPCODE;
						 current_not_phrase=false;
					 }
					 else
					 {
						 currentCommand=CommandType.PUSH_OPCODE_NUM;
					 }
				 }
				 else 
				 {					 
					 currentCommand=CommandType.PRE_1_OPCODE_NUM;	 
				 }

				 CommandStackItem cmd=new CommandStackItem(current_line,thisWord,"",thisWordType,currentCommand,current_not_phrase);				 
				 cmds.put(current_line,cmd);
				 current_line++;
			 }			 
			 if (popCmdType != null && current_line > 1)
			 {
				 CommandStackItem cmd=new CommandStackItem(current_line,"","","",popCmdType,local_not_phrase);				 
				 cmds.put(current_line,cmd);
				 current_line++;
			 }
				 
			 matchCount++;
		 }

		 wordlist=matcher.replaceAll("");
		 //assumption: words/phrases with different opcodes will always be parenthesized.
		 //i.e., will be (a and b) or c, not "a and b or c"
		 String[] words=StringUtils.split(wordlist.trim()," ");
		 boolean wlContainsOrs=wordlist.toUpperCase().contains(" OR ");
		 boolean wlContainsAnds=wordlist.toUpperCase().contains(" AND ");
		 boolean wlContainsNots=wordlist.toUpperCase().contains(" NOT ");
		 
		 if (wlContainsOrs && !wlContainsAnds && !wlContainsNots)
		 {  
			defaultCommandType= CommandType.OR_OPCODE_NUM;
		 }
		 else if (wlContainsAnds && !wlContainsOrs &&!wlContainsNots )
		 {
			defaultCommandType= CommandType.AND_OPCODE_NUM;
		 }
		 else if (wlContainsNots && !wlContainsOrs && !wlContainsAnds )
		 {
			defaultCommandType= CommandType.AND_NOT_OPCODE_NUM;
			local_not_phrase=true;
		 }

		 //handle individual non-quoted-phrase words
		 for (int i=0; i < words.length; i++)
		 {
			 //ignore and/not/or
			 boolean current_not_phrase=local_not_phrase;
			 if (words[i].equalsIgnoreCase("OR") ||
					 words[i].equalsIgnoreCase("AND")||
					 words[i].equalsIgnoreCase("NOT"))
			 {
				 continue;
			 }
			 
			 //check if this is a composite word (where individual type/synonym indicators exist per word)
			 String thisWordType=wordtype;
			 String thisWord=words[i];
			 boolean thisAddSynonyms=addSynonyms;
			 if (IsComposite(words[i]))
			 {
				 thisWordType=GetCompositeType(words[i]);
				 thisWord=GetCompositeValue(words[i]);
				 thisAddSynonyms=GetCompositeSynonym(words[i]);
			 }
			 //if this is the very first word to be processed, it has no opcode;
			 //otherwise, use the default opcode for this list of words
			 if (current_line==1)
			 {
				 currentCommand=CommandType.NO_OPCODE;
				 current_not_phrase=false;
			 }
			 else
			 {
				 currentCommand=defaultCommandType;
			 }
		
			 
			 ArrayList<String> multiwords=new ArrayList<String>();

			 //if there are words in the wordlist other than the quoted phrase,push			 
			 if ((thisWord.contains("*") && !thisWord.contains("\\*")) 
					 || (thisWord.contains("?") && !thisWord.contains("\\?")))
			 {
				
				multiwords.addAll(GetWildcardWords(thisWord));
			 }
		 
			 if (multiwords.size() > 0)
			 {
				
				 boolean firstSet=false;
				 //if this set of ors is the first, no opcode; otherwise push
				 if (current_line==1)
				 {
					 currentCommand=CommandType.NO_OPCODE;
					 current_not_phrase=false;
					 firstSet=true;
				 }
				 else if (!defaultCommandType.equals(CommandType.OR_OPCODE_NUM))
				 {
					 currentCommand=CommandType.PUSH_OPCODE_NUM;
				 }
				 else
				 {
					 currentCommand=defaultCommandType;
				 }
				 

				for (String wcWord:multiwords)
				{
					 CommandStackItem cmd=new CommandStackItem(current_line,wcWord,"",thisWordType,currentCommand,current_not_phrase);
					 cmds.put(current_line,cmd);
					 current_line++;
					 currentCommand=CommandType.OR_OPCODE_NUM;					
				
				}
				//if the wildcard word wasn't the first word in the phrase and this isn't OR, pop it
				if (!firstSet && !defaultCommandType.equals(CommandType.OR_OPCODE_NUM))
				{
					CommandType popCmdType=CommandType.POP_AND_OPCODE_NUM;
					if (defaultCommandType.equals(CommandType.AND_OPCODE_NUM))
					 {
						 popCmdType=CommandType.POP_AND_OPCODE_NUM;
					 }
					 else if (defaultCommandType.equals(CommandType.OR_OPCODE_NUM))
					 {
						 popCmdType=CommandType.POP_OR_OPCODE_NUM;
					 }
					 else if (defaultCommandType.equals(CommandType.AND_NOT_OPCODE_NUM))
					 {
						 popCmdType=CommandType.POP_AND_NOT_OPCODE_NUM;
					 }
				     CommandStackItem cmd=new CommandStackItem(current_line,"","","",popCmdType,current_not_phrase);
				     cmds.put(current_line,cmd);
				      current_line++;
				}				
			 } else
			 {
				 CommandStackItem cmd=new CommandStackItem(current_line,thisWord,"",thisWordType,currentCommand,current_not_phrase);
				 cmds.put(current_line,cmd);
				 current_line++;
			 }
	
		 }
		 
		 return cmds;
	 }
	 
	 public void AddWordList(String wordlist, CommandType defaultWLCommandType, CommandType defaultJoinCommandType) throws Exception
	 {
		 AddWordList(wordlist,"",defaultWLCommandType,defaultJoinCommandType,false);
	 }
		
	 public void AddWordList(String wordlist,CommandType defaultWLCommandType) throws Exception
	 {
		 AddWordList(wordlist,"",defaultWLCommandType,CommandType.AND_OPCODE_NUM,false);
	 }
	 
	 public void AddWordList(String wordlist, String wordtype, CommandType defaultWLCommandType,
			 	CommandType defaultJoinCommandType,Boolean addSynonyms) throws Exception
	 {		 
		 ArrayList<CommandStackItem> wordlistcmds=new ArrayList<CommandStackItem>();
		 
		 wordlist=wordlist.toUpperCase().trim();
		 if (wordlist.equals("")) {return;}
		//handle parenthesized phrases
		 Pattern p = Pattern.compile("(NOT\\s{1,10}|OR\\s{1,10}|AND\\s{1,10})?\\((.*?)\\)",Pattern.DOTALL); 		 
		 Matcher matcher = p.matcher(wordlist.toUpperCase());
		 int matchCount=1;
		 while(matcher.find()) {  		
			 String foundString="";
			 boolean not_phrase=false;
			 if (defaultJoinCommandType.equals(CommandType.AND_NOT_OPCODE_NUM)) {not_phrase=true;}
			 
			 if (matcher.group(1) != null)
			 {
				foundString = foundString + matcher.group(1); 
			 }
			 if (matcher.group(2)==null)
			 {
				 continue;
			 }
			 foundString=foundString + "(" + matcher.group(2) + ")";
			 wordlist=wordlist.replace(foundString, "");
			 CommandType popCmdType=null;
			 if (matcher.group(1) != null && matcher.group(1).trim().equalsIgnoreCase("OR"))
			 {
				 popCmdType=CommandType.POP_OR_OPCODE_NUM;
			 }
			 if (matcher.group(1) != null && matcher.group(1).trim().equalsIgnoreCase("NOT"))
			 {
				 popCmdType=CommandType.POP_AND_NOT_OPCODE_NUM;
				 not_phrase=true;
			 }
			 else if (matcher.group(1) != null && matcher.group(1).trim().equalsIgnoreCase("AND"))
			 {
				 popCmdType=CommandType.POP_AND_OPCODE_NUM;
			 }
			 else if (matchCount > 1 && popCmdType==null)
			 {
				 if (defaultWLCommandType.equals(CommandType.AND_OPCODE_NUM))
				 {
					 popCmdType=CommandType.POP_AND_OPCODE_NUM;
				 }
				 else if (defaultWLCommandType.equals(CommandType.OR_OPCODE_NUM))
				 {
					 popCmdType=CommandType.POP_OR_OPCODE_NUM;
				 }
				 else if (defaultWLCommandType.equals(CommandType.AND_NOT_OPCODE_NUM))
				 {
					 popCmdType=CommandType.POP_AND_NOT_OPCODE_NUM;
				 }
			 }
			 
			ArrayList<CommandStackItem> thisParenCmds=new ArrayList<CommandStackItem>();				
			thisParenCmds.addAll(parsePhrase(matcher.group(2),wordtype,defaultWLCommandType,not_phrase,addSynonyms).values());
			Collections.sort(thisParenCmds, new CommandComparator());
			if (popCmdType != null && thisParenCmds.size()>0)
			 {
				 thisParenCmds.get(0).opcode=CommandType.PUSH_OPCODE_NUM;	
				 
				 int pushcount=0;
				 int popcount=0;
				 for (int i=0; i < thisParenCmds.size();i++)
				 {
					 if (thisParenCmds.get(i).opcode.equals(CommandType.PUSH_OPCODE_NUM))
					 {
						 pushcount++;
					 }
					 else if (thisParenCmds.get(i).opcode.equals(CommandType.POP_AND_OPCODE_NUM)
							 || thisParenCmds.get(i).opcode.equals(CommandType.POP_OR_OPCODE_NUM)
							 || thisParenCmds.get(i).opcode.equals(CommandType.POP_AND_NOT_OPCODE_NUM))
							 {
								 popcount++;
							 }
				 }
				 CommandStackItem cmd=new CommandStackItem(current_line,"","","",popCmdType,not_phrase);				 				
				 wordlistcmds.addAll(thisParenCmds);
				 if (pushcount == popcount + 1)
				 {
					 wordlistcmds.add(cmd);
					 current_line++;
				 }

			 } else
			 {
				 wordlistcmds.addAll(thisParenCmds);
			 }
		 	 matchCount++;
		 }
		 
		 boolean not_phrase=false;		 
		 if (defaultJoinCommandType.equals(CommandType.AND_NOT_OPCODE_NUM)) {not_phrase=true;}
		 HashMap<Integer,CommandStackItem> cmds=parsePhrase(wordlist,wordtype,defaultWLCommandType,not_phrase,addSynonyms);
		 wordlistcmds.addAll(cmds.values());
		 Collections.sort(wordlistcmds, new CommandComparator());
		 if (_commands.size() > 0 && wordlistcmds.size()>0)
		 {
			 wordlistcmds.get(0).opcode=CommandType.PUSH_OPCODE_NUM;

			 int pushcount=0;
			 int popcount=0;
			 for (int i=0; i < wordlistcmds.size();i++)
			 {
				 if (wordlistcmds.get(i).opcode.equals(CommandType.PUSH_OPCODE_NUM))
				 {
					 pushcount++;
				 }
				 else if (wordlistcmds.get(i).opcode.equals(CommandType.POP_AND_OPCODE_NUM)
						 || wordlistcmds.get(i).opcode.equals(CommandType.POP_OR_OPCODE_NUM)
						 || wordlistcmds.get(i).opcode.equals(CommandType.POP_AND_NOT_OPCODE_NUM))
						 {
							 popcount++;
						 }
			 }
			 CommandType phraseCommandType=CommandType.NO_OPCODE;
			 if (defaultJoinCommandType.equals(CommandType.AND_OPCODE_NUM))
			 {
				 phraseCommandType=CommandType.POP_AND_OPCODE_NUM;				 
			 }
			 else if (defaultJoinCommandType.equals(CommandType.OR_OPCODE_NUM))
			 {
				 phraseCommandType=CommandType.POP_OR_OPCODE_NUM;
			 }
			 else if (defaultJoinCommandType.equals(CommandType.AND_NOT_OPCODE_NUM))
			 {
				 phraseCommandType=CommandType.POP_AND_NOT_OPCODE_NUM;
			 }
			 if (pushcount == popcount + 1)
			 {
				 wordlistcmds.add(new CommandStackItem(current_line,"","","",phraseCommandType,not_phrase));
				 current_line++;
			 }			 
		 }
		 _commands.addAll(wordlistcmds);
	 }
		 
	 public ArrayList<String> GetWildcardWords(String word) throws Exception
	 {
		 if (session != null)
		 {
			 Object exists=session.getAttribute("wildcard" + word);
			 if (exists != null && exists instanceof ArrayList)
			 {
				 ArrayList<String> wwwords=(ArrayList<String>) exists;
				 if (wwwords.size()> 0)
				 {
					 return wwwords;
				 }			 
			 }
		 }
		 
		 String wcUrl=wildcardUrl.replace(Utility.BEGIN_DYNAMIC + "word" + Utility.END_DYNAMIC,URLEncoder.encode(word,"UTF-8"));
		 wcUrl=wcUrl.replace(Utility.BEGIN_DYNAMIC + "idxtype" + Utility.END_DYNAMIC,idxType);
		 String webresult=Utility.processRequest(wcUrl,"");
		 NodeList nodelist=Utility.getNodes(webresult, "Item");
		 ArrayList<String> items=new ArrayList<String>();
		 for (int i=0; i < nodelist.getLength(); i++)
		 {
			 items.add(nodelist.item(i).getTextContent());
		 }		
		 
		 if (items.size()==0)
		 {
			 items=new ArrayList<String>();
			 items.add(word);
		 }
		 
		 if (session != null)
		 {
			 session.setAttribute("wildcard" + word,items);
		 }
		 return items;		 		 
	 }

	
	

	 public String ToEDFSXml()
	 {
	     // Sorting _commands, when items are added from a HashMap
	     // the order is not guaranteed
	     Collections.sort(_commands, new CommandComparator());
		 StringBuilder sb=new StringBuilder();
		 sb.append("<commandstack>\n");
		 for (int i=0; i < _commands.size(); i++)
		 {
			 sb.append(_commands.get(i).ToXML());
		 }
		 sb.append("</commandstack>");
		 return sb.toString();
	 }


	 public String ToEDFSDebugString()
	 {
         // Sorting _commands, when items are added from a HashMap
         // the order is not guaranteed
         Collections.sort(_commands, new CommandComparator());
		 StringBuilder sb=new StringBuilder();
		 sb.append("DATASET([\n");
		 for (int i=0; i < _commands.size(); i++)
		 {
			 sb.append("\t");
			 if (i>0) {sb.append(",");}
			 sb.append(" {");
			 sb.append(String.valueOf(_commands.get(i).stack_id)).append(", ");
			 sb.append("BitmapSearch.Layouts.").append(_commands.get(i).opcode.name()).append(", ");
			 sb.append("u'").append(_commands.get(i).term).append("', ");
			 sb.append("HASH64(u'").append(_commands.get(i).term).append("'), ");
			 sb.append("'").append(_commands.get(i).type).append("', ");
			 sb.append(Boolean.toString(_commands.get(i).not_phrase));			 
			 sb.append("}\n");
		 }
		 sb.append("],BitmapSearch.Layouts.CommandStack);");
		 return sb.toString();
	 }
	 
    /**
     * convert list of commands to a list of words.
     *   word list will contain phrases. Highlight.highlightResults should
     *       modify the space in between words to be any space-like token.
     *       Use the opcode to see if it should be added to the previous word.
     *       opcode == PRE_1_OPCODE_NUM, see ECL BitmapSearch.Layouts.PRE_1_OPCODE_NUM
     * sort them by length and add them to the output list.
     * @return
     */
	public ArrayList<String> getRegexWords()
	{
        ArrayList<String> words = new ArrayList<String>();
        for(int i=0; i<_commands.size(); i++)
        {
            String word = _commands.get(i).getTerm();
            // check to see if it is empty or CJK
            if (word.equals("") || Utility.IsCJK(word)) {continue;}
            // remove characters that will screw up a regex
            word = word.replaceAll("(\\.|\\||\\(|\\)|\\[|\\]|\\\\|\\{|\\}|\\?|\\^|\\$|\\*|\\+)", "\\\\" + "$1");
            // check to see if the next word is part of a phrase
            while(i+1 < _commands.size() 
                    && _commands.get(i+1).opcode == CommandType.PRE_1_OPCODE_NUM)
            {
                i++;
                word += " ";
                word += _commands.get(i).getTerm();
            }
            words.add(word);
        }
        
        Collections.sort(words, new ReverseLengthComparator());
        return words;		
	 }

	 public ArrayList<String> getCJKRegexWords()
	 {
	        ArrayList<String> words = new ArrayList<String>();
	        for(int i=0; i<_commands.size(); i++)
	        {
	            String word = _commands.get(i).getTerm();
	            // check to see if it is empty or CJK
	            if (word.equals("") || !Utility.IsCJK(word)) {continue;}
	            // remove characters that will screw up a regex
	            word = word.replaceAll("(\\.|\\||\\(|\\)|\\[|\\]|\\\\|\\{|\\}|\\?|\\^|\\$|\\*|\\+)", "\\\\" + "$1");
	            // check to see if the next word is part of a phrase
	            while(i+1 < _commands.size() 
	                    && _commands.get(i+1).opcode == CommandType.PRE_1_OPCODE_NUM)
	            {
	                i++;
	                word += " ";
	                word += _commands.get(i).getTerm();
	            }
	            words.add(word);
	        }
	        
	        Collections.sort(words, new ReverseLengthComparator());
	        return words;       
	 }
	 
	 public String getRegexWordlist()
	 {
		 StringBuilder sb=new StringBuilder();
		 String result="";

		 int cmdcount= this._commands.size();
		 for (int i=0; i < cmdcount; i++)
		 {			 
			 String word=_commands.get(i).getTerm();
			 if (word.equals("")) {continue;}
			 word=word.replaceAll("(\\.|\\||\\(|\\)|\\[|\\]|\\\\|\\{|\\}|\\?|\\^|\\$|\\*|\\+)", "\\\\" + "$1");
			 sb.append(word);
			 if (i < cmdcount-1 && !_commands.get(i+1).getTerm().equals(""))
			 {
				 sb.append("|");
			 }
		 }
		 if (cmdcount > 0)
		 {
			 result= "(" + sb.toString() + ")";
		 }
		 else {
			 result= "";
		 }
		 return result;
		 
	 }
	 public String toBooleanSearchString()
	 {
		 String begindate="";
		 String enddate="";
         // Sorting _commands, when items are added from a HashMap
         // the order is not guaranteed
         Collections.sort(_commands, new CommandComparator());
		 StringBuffer sb=new StringBuffer();
		 StringBuffer tempPhrase=new StringBuffer();
		 for (int i=0; i < this._commands.size(); i++)
		 {			 
			 CommandStackItem it=this._commands.get(i);
			 String thisTerm=it.term;
			 if (it.type.trim().equals("UPDATEDATE"))
			 {
				 if (begindate.equals("")
					|| (it.term.compareTo(begindate)<0 && !it.term.equals("")))
				 {
					begindate=it.term; 
				 }
				 if (enddate.equals("")
					|| (it.term.compareTo(enddate)>0 && !it.term.equals("")))
				 {
					enddate=it.term; 
				 }
				 continue;
			 }
			 if (it.type != null && !it.type.trim().equals(""))
			 {
				 thisTerm=it.type + ":" + thisTerm;
			 }
			 if (it.opcode.equals(CommandType.PUSH_OPCODE_NUM))
			 {
				 sb.append(tempPhrase.toString());
				 tempPhrase=new StringBuffer(thisTerm);					 
		     }
			 else if (it.opcode.equals(CommandType.POP_AND_NOT_OPCODE_NUM))
			 {
				 sb.append(" NOT (").append(tempPhrase.toString()).append(" ").append(thisTerm).append(")");
				 tempPhrase=new StringBuffer();
			 }
			 else if (it.opcode.equals(CommandType.POP_OR_OPCODE_NUM))
			 {
				 sb.append(" OR (").append(tempPhrase.toString()).append(" ").append(thisTerm).append(")");
				 tempPhrase=new StringBuffer();
			 }
			 else if (it.opcode.equals(CommandType.POP_AND_OPCODE_NUM))
			 {
				 if (!sb.toString().equals(""))
				 {
					 sb.append(" AND (");
				 }
				sb.append(tempPhrase.toString()).append(" ").append(thisTerm).append(")");
				 tempPhrase=new StringBuffer();
			 }
			 else {
			     tempPhrase.append(it.opcode.getText());
			     tempPhrase.append(thisTerm);
			 }
		 }
		 sb.append(tempPhrase.toString());
		 String result=sb.toString();
		 if (!begindate.equals(""))
		 {
			 try {
			 String dates=" Added " + DateUtility.GetDateMMDDYYYY(DateUtility.ParseDate(begindate,null));
			 if (!enddate.equals(begindate))
			 {
				 dates=dates + "-" + DateUtility.GetDateMMDDYYYY(DateUtility.ParseDate(enddate,null));
			 }
			 result=result + " " + dates;
			 if (result.contains(")") && !result.contains("("))
			 {
				 result=result.replace(")","");
			 }
			 }catch (Exception e){}
		 }
		 return result;		 		 
	 }
	 
	 public void LoadFromXML(String strXml) throws Exception
	 {
		 NodeList list=Utility.getNodes(strXml,"Row");
			if (list==null || list.getLength()==0)
			{
				throw new Exception("Cannot load command stack " + strXml);
			}
			for (int i=0; i < list.getLength(); i++)
			{
				Element el=(Element)list.item(i);		
				CommandStackItem cmditem=new CommandStackItem(el);
				this._commands.add(cmditem);
				if (this.current_line <= cmditem.stack_id) {
					this.current_line = cmditem.stack_id+1;
				}
			}			 
	 }
	 
	 
	 public boolean equalsIgnoreType(BitmapCommandStack other)
	 {
		boolean match=true;
		if (other==null || this._commands.size() != other._commands.size())
		{
			 match=false;
		 }
		 else {
			 for (int i=0; i < this._commands.size(); i++)
			 {
				if (!_commands.get(i).equalsIgnoreType(other._commands.get(i)))
				{
					match=false;
					break;
				}
			 }
		 }
		 return match;

	 }
	 
	public boolean containsPhrases()
	 {
		 for (int i=0; i < this._commands.size(); i++)
		 {
			 if (this._commands.get(i).opcode.equals(CommandType.PRE_1_OPCODE_NUM))
			 {
				 return true;
			 }
		 }
		 return false;
	 }
	 private class CommandComparator implements Comparator<CommandStackItem>
	 {

        @Override
        public int compare(CommandStackItem o1, CommandStackItem o2)
        {
            if(o1.stack_id < o2.stack_id){ return -1; }
            else if(o1.stack_id > o2.stack_id){ return 1; }
            return 0;
        }
	     
	 }
	 
	 private class LengthComparator implements Comparator<CommandStackItem>
	 {

        @Override
        public int compare(CommandStackItem o1, CommandStackItem o2)
        {
        	if (o1==null || o2==null) {return 0;}
            if(o1.getTerm().length() < o2.getTerm().length()){ return -1; }
            else if(o1.getTerm().length() > o2.getTerm().length()){ return 1; }
            return 0;
        }
	     
	 }
	 
	 private class ReverseLengthComparator implements Comparator<String>
	 {

        @Override
        public int compare(String o1, String o2)
        {
        	if (o1==null || o2==null) {return 0;}
            if(o1.length() < o2.length()){ return 1; }
            else if(o1.length() > o2.length()){ return -1; }
            return 0;
        }
	     
	 }
	 
	 private static String SpaceReplaceChar="_^_";
	 private static String JoinChar="~|~";
	 private static String ConvertFromSpaces(String val)
	 {
		 if (val==null) {return null;}		 
		 val=val.replace(" ",SpaceReplaceChar);
		 return val;
	 }
	 
	 private static String ConvertToSpaces(String val)
	 {
		 if (val==null) {return null;}
		 val=val.replace(SpaceReplaceChar," ");
		 return val;
	 }
	 
	 public static String CreateCompositeValue(String intype, String invalue,boolean synonym)
	 {
		 String type=intype==null?"":intype.trim();
		 String value=invalue==null?"":invalue.trim();
		 if (value.equals("")) {value=" ";}
		 if (type.equals("")) {type=" ";}
		return ConvertFromSpaces(type) + JoinChar + ConvertFromSpaces(value) + JoinChar + String.valueOf(synonym); 
	 }
	 
	 public static boolean IsComposite(String inval)
	 {
		 if (inval==null) {return false;}
		 String[] vals=StringUtils.split(inval,JoinChar);
		 if (vals.length==3) {return true;}
		 else {return false;}
		 
	 }
	 
	 public static String GetCompositeType(String inval)
	 {
		 String[] vals=StringUtils.split(inval,JoinChar);
		 if (vals.length==3)
		 {
			 return ConvertToSpaces(vals[0]).trim();
		 } else {
			 return "";
		 }
	 }
	 
	 public static String GetCompositeValue(String inval)
	 {
		 String[] vals=StringUtils.split(inval,JoinChar);
		 if (vals.length==3)
		 {
			 return ConvertToSpaces(vals[1]);
		 } else {
			 return "";
		 }
	 }
	 
	 public static Boolean GetCompositeSynonym(String inval)
	 {
		 String[] vals=StringUtils.split(inval,JoinChar);
		 if (vals.length==3)
		 {
			 return Boolean.valueOf(vals[2]);
		 } else {
			 return false;
		 }
	 }

}
