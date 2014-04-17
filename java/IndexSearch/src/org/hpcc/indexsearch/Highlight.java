package org.hpcc.indexsearch;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Highlight
{
    static Pattern searchableValueElemPattern = Pattern.compile("<searchable_value>.+</searchable_value>|<original_value>.+</original_value>");
    public static void highlightResults(SearchDTO searchDTO)
    {
        Pattern highlightWordPattern = null;
        for (String word:searchDTO.getRegexsearchwords())
        {
            // phrases have spaces in them, replace with all space-like characters
            // if there are more than 3 chars between them, do not highlight
            word = word.replaceAll(" +", " ");
            word = word.replace(" ", "[ +,;()\\[\\]\\{}!?\\&\\^*'\"$#%`-’“”]{1,3}");
            try {
              //highlightWordPattern = Pattern.compile(">([^<]*)?\\b(" + word +")\\b([^>]*)?<",Pattern.CASE_INSENSITIVE|Pattern.UNICODE_CASE|Pattern.CANON_EQ);
                highlightWordPattern = Pattern.compile("\\b(" + word +")\\b",Pattern.CASE_INSENSITIVE|Pattern.UNICODE_CASE|Pattern.CANON_EQ);
            } catch (Exception e)
            {
                //some words w some unicode characters (like synonyms for RIAZ) fail to compile using canonical equivalence, due to bugs in Java Pattern;
              //highlightWordPattern = Pattern.compile(">([^<]*)?\\b(" + word +")\\b([^>]*)?<",Pattern.CASE_INSENSITIVE|Pattern.UNICODE_CASE);
                highlightWordPattern = Pattern.compile("\\b(" + word +")\\b",Pattern.CASE_INSENSITIVE|Pattern.UNICODE_CASE);
            }
           if (highlightWordPattern != null)
           {
               String currXmlResult = searchDTO.getCurrentXMLResult();
               Matcher searchableValMatcher = searchableValueElemPattern.matcher(currXmlResult);
               while(searchableValMatcher.find())
               {
                   String currSearchableText = searchableValMatcher.group();
                   Matcher tagmatch = highlightWordPattern.matcher(currSearchableText);
                   if (tagmatch.find())
                   {
                       //searchDTO.setCurrentXMLResult(tagmatch.replaceAll(">$1<a class=\"highlight\">$2</a>$3<"));
                       //searchDTO.setCurrentXMLResult(tagmatch.replaceAll("<a class=\"highlight\">$1</a>"));
                       String newSearchableText = tagmatch.replaceAll("&lt;a class=\"highlight\"&gt;$1&lt;/a&gt;");
                       currXmlResult = currXmlResult.replace(currSearchableText, newSearchableText);
                   }
               }
               searchDTO.setCurrentXMLResult(currXmlResult);
           }
        }
        for (String word:searchDTO.getCJKRegexsearchwords())
        {
            word = word.replaceAll(" +", " ");
            word = word.replace(" ", "[ +,;()\\[\\]\\{}!?\\&\\^*'\"$#%`-’“”]{0,2}");
            try {
                highlightWordPattern=Pattern.compile(">([^<]*)?(" + word +")([^>]*)?<",Pattern.CASE_INSENSITIVE|Pattern.UNICODE_CASE|Pattern.CANON_EQ);
            } catch (Exception e)
            {
                //some words w some unicode characters (like synonyms for RIAZ) fail to compile using canonical equivalence, due to bugs in Java Pattern;
                highlightWordPattern=Pattern.compile(">([^<]*)?(" + word +")([^>]*)?<",Pattern.CASE_INSENSITIVE|Pattern.UNICODE_CASE);
            }
           if (highlightWordPattern != null)
           {
               Matcher tagmatch = highlightWordPattern.matcher(searchDTO.getCurrentXMLResult());                      
               while (tagmatch.find())
               {                       
                   searchDTO.setCurrentXMLResult(tagmatch.replaceAll(">$1&lt;a class=\"highlight\"&gt;$2&lt;/a&gt;$3<"));
               } 
           }
        }
    }

    public static void highlightResultsText(SearchDTO searchDTO)
    {
        //TODO: change search so that if any part of a phrase is CJK, all of the phrase is CJK
        // if CJK do not use \\b for word boundaries
        // if containsPhrase
        //    if CJK put phrases together with 
        //    if not CJK put phrases together with word boundaries
        
        boolean phrase = false; // searchDTO.onlyphrase();
        // build word patterns
        Pattern highlightWordPattern = null;
        StringBuffer wordPattern = new StringBuffer();
        //ArrayList<Pattern> wordPatterns = new ArrayList<Pattern>();
        String wordBoundaryPattern = "\\b";
        if(searchDTO.getCJKRegexsearchwords().size() > 0){
            wordBoundaryPattern = "";
        }

        ArrayList<String> words = new ArrayList<String>();
        words.addAll(searchDTO.getRegexsearchwords());
        words.addAll(searchDTO.getCJKRegexsearchwords());
        Iterator<String> wordIter = words.iterator();
        while(wordIter.hasNext()){
            wordPattern.append(wordBoundaryPattern);
            wordPattern.append(wordIter.next());
            wordPattern.append(wordBoundaryPattern);
            if(wordIter.hasNext()){
                if(phrase){
                    wordPattern.append("[\b ]*");
                }
                else {
                    wordPattern.append("|");
                }
            }
        }
        
        try {
            highlightWordPattern = Pattern.compile(wordPattern.toString(),Pattern.CASE_INSENSITIVE|Pattern.UNICODE_CASE|Pattern.CANON_EQ);
        } catch(Exception e){
            highlightWordPattern = Pattern.compile(wordPattern.toString(),Pattern.CASE_INSENSITIVE|Pattern.UNICODE_CASE);
        }
        
        // Use the pattern on all of the text elements
        String xmlstr = searchDTO.getCurrentXMLResult();
        StringBuffer outbuffer = new StringBuffer();
        StringBuffer buf = new StringBuffer();
        boolean intag = true;
        for(int i=0; i<xmlstr.length(); i++)
        {
            char c = xmlstr.charAt(i);
            if(c == '<'){
                intag = true;
                if(buf.length() > 0){
                    String textblock = buf.toString();
                    Matcher tagmatch = highlightWordPattern.matcher(textblock);                      
                    while (highlightWordPattern != null && tagmatch.find())
                    {                       
                        textblock = tagmatch.replaceAll("&lt;a class=\"highlight\"&gt;$0&lt;/a&gt;");
                    } 
                    //System.out.println(textblock);
                    outbuffer.append(textblock);
                    buf.setLength(0);
                }
                outbuffer.append(c);
            } 
            else if(c == '>'){
                outbuffer.append(c);
                intag = false;
            } 
            else if(!intag){
                buf.append(c);
            }
            else {
                outbuffer.append(c);
            }
        }
        searchDTO.setCurrentXMLResult(outbuffer.toString());
    }
    
    public static void textElements(SearchDTO searchDTO)
    {
        String xmlstr = searchDTO.getCurrentXMLResult();
        StringBuffer buf = new StringBuffer();
        boolean intag = true;
        for(int i=0; i<xmlstr.length(); i++)
        {
            char c = xmlstr.charAt(i);
            if(c == '<'){
                intag = true;
                if(buf.length() > 0){
                    System.out.println(buf.toString());
                    buf.setLength(0);
                }
            } 
            else if(c == '>'){
                intag = false;
            } 
            else if(!intag){
                if(buf.length() == 0){}
                buf.append(c);
            }
            // else NOOP
        }
    }
}
