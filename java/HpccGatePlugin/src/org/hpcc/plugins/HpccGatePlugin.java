package org.hpcc.plugins;

/*
 *  StandAloneAnnie.java
 *
 */


import java.util.*;
import java.io.*;
import java.net.*;

import org.apache.commons.lang.StringEscapeUtils;

import com.thoughtworks.xstream.XStream;


import gate.CorpusController;
import gate.*;
import gate.creole.*;
import gate.util.*;
import gate.util.persistence.PersistenceManager;
import gate.corpora.RepositioningInfo;

/**
 * This class illustrates how to use ANNIE as a sausage machine
 * in another application - put ingredients in one end (URLs pointing
 * to documents) and get sausages (e.g. Named Entities) out the
 * other end.
 * <P><B>NOTE:</B><BR>
 * For simplicity's sake, we don't do any exception handling.
 */
public class HpccGatePlugin  {

  private static HashMap<String,CorpusController> corpusControllers=new HashMap<String,CorpusController>();
  private static Boolean initializedGate=false;
  
  public static void init(String overridePluginDir) throws Exception {
	    String dir=HpccGatePlugin.class.getProtectionDomain().getCodeSource().getLocation().getPath();
	    File test=new File(dir);

		File pluginDir=null;
	
		if ( overridePluginDir != null) {
			
			if (overridePluginDir != null && overridePluginDir != "") {
				pluginDir=new File(overridePluginDir);
				if (!pluginDir.exists()) 
				{
					throw new Exception("Override plugin dir " + overridePluginDir + " not found");
				}
			}
		}
		
		else {
				test=test.getParentFile();
				pluginDir=new File(test.getAbsolutePath() + "/plugins");
				if (!pluginDir.exists()) {
					throw new Exception("Default plugin dir " + test.getAbsolutePath() + "/plugins not found");
				}
			}
		Out.prln("Initialising GATE...");
	    Gate.setPluginsHome(pluginDir);
	    File siteconfig=new File(pluginDir,"gate.xml");
	    if (!siteconfig.exists()) {
	    	throw new Exception("Site config file " + siteconfig.getAbsolutePath() + " not found.");
	    }
	    Gate.setSiteConfigFile(siteconfig);
	    Gate.init();
	    initializedGate=true;
	    Out.prln("...GATE initialised");
  }

  /**
   * Initialise a corpus. This creates a "corpus pipeline"
   * application that can be used to run sets of documents through
   * the extraction system.
 * @throws Exception 
   */
  public static CorpusController initCorpusController(String corpusName, String configFilename) throws Exception {
    Out.prln("Initialising " + corpusName + "...");

    CorpusController corpusController=null;
	try {
		File corpusPlugin=new File(Gate.getPluginsHome(), corpusName);
			if (!corpusPlugin.exists()) {
					throw new Exception("Corpus plugin dir " + corpusPlugin.getAbsolutePath() + " not found");
			}
			File corpusGapp = new File(corpusPlugin, configFilename);
		    corpusController =(CorpusController) PersistenceManager.loadObjectFromFile(corpusGapp);
	}catch (Exception e) {
		e.printStackTrace();
		throw new Exception("Error loading corpus "  + corpusName + ":" + e.getMessage());		
	}
    Out.prln("..." + corpusName + " loaded");	
	return corpusController;
  } // initAnnie()


  public static String execute(String text,String corpusName, String config) throws Exception {
	  return execute(text,corpusName,config,null);
  }
  //todo: config contains xml features/parameters, parse out for more control
  public static String execute(String text,String corpusName, String config, String overridePluginsDir) throws Exception {
	if (initializedGate==false) {
		try {
			init(overridePluginsDir);
		} catch (Exception e) {
			return "<result>" + e.getMessage() + "</result>";
		}
	}
	  CorpusController cont=null;
	  if (!corpusControllers.containsKey(corpusName.toUpperCase()))
	  {
		  try {
			  cont=initCorpusController(corpusName,config);
		  } catch (Exception e) {
				return "<result>" + e.getMessage() + "</result>";
		  }
		  if (cont==null) {
			  return "<Error>Could not initialize Controller for " + corpusName + "</Error>";
		  }
		  corpusControllers.put(corpusName.toUpperCase(), cont);
	  } else {
		  cont=corpusControllers.get(corpusName.toUpperCase());
	  }

      FeatureMap params = Factory.newFeatureMap();
      //params.put("sourceUrl", u);
      //params.put("preserveOriginalContent", new Boolean(true));
      params.put("collectRepositioningInfo", new Boolean(true));
      String error ="";
      Document indoc = Factory.newDocument(text);
      indoc.setFeatures(params);
      Corpus corpus = Factory.newCorpus("Temp corpus");
      corpus.add(indoc);
      cont.setCorpus(corpus);
      
      try {
    	  cont.execute();
      } catch (Exception e) {
    	  error=e.getMessage();
    	  e.printStackTrace();
    	  return "<result><error>" + error + "</error></result>";
      }
      Iterator it=corpus.iterator();
      Document doc = (Document) it.next();
      AnnotationSet defaultAnnotSet = doc.getAnnotations();
      Set annotTypesRequired = new HashSet();
      annotTypesRequired.add("Person");
      annotTypesRequired.add("Location");
      annotTypesRequired.add("Organization");
      annotTypesRequired.add("Money");
      annotTypesRequired.add("Percent");
      annotTypesRequired.add("Date");
      annotTypesRequired.add("Address");
      annotTypesRequired.add("Identifier");
      annotTypesRequired.add("Unknown");
      Set<Annotation> peopleAndPlaces =new HashSet<Annotation>(defaultAnnotSet.get(annotTypesRequired));

      String xmlDocument = doc.toXml(peopleAndPlaces, false);
      //xmlDocument=doc.toXml();
      Iterator it2 = peopleAndPlaces.iterator();
      Annotation currAnnot;
      XStream xstream=new XStream();

      StringBuffer sb=new StringBuffer();
      while(it2.hasNext()) {
        currAnnot = (Annotation) it2.next();
        sb.append("<annotation>").append("<type>").append(currAnnot.getType()).append("</type>");
        int beginOffset=currAnnot.getStartNode().getOffset().intValue();
        int endOffset=currAnnot.getEndNode().getOffset().intValue();
        
        sb.append("<beginOffset>").append(String.valueOf(beginOffset)).append("</beginOffset>");
        sb.append("<endOffset>").append(String.valueOf(endOffset)).append("</endOffset>");
        sb.append("<value>").append(StringEscapeUtils.escapeXml(text.substring(beginOffset,endOffset))).append("</value>");
        sb.append("</annotation>");
        //todo: better xml export
      //  sb.append(xstream.toXML(currAnnot));
      } // while

      String result= "<result><input>" + StringEscapeUtils.escapeXml(text) + "</input><annotations>" + sb.toString() + "</annotations></result>";
      return result;

  }

  /**
   * Run from the command-line, with a list of URLs as argument.
   * <P><B>NOTE:</B><BR>
   * This code will run with all the documents in memory - if you
   * want to unload each from memory after use, add code to store
   * the corpus in a DataStore.
   */
  public static void main(String args[]) throws Exception {
    // initialise the GATE library


	  String plugindir=null;//C:/workspace/nlp/gateplugins";
	  if (args.length > 0 && args[0] != null) {
		  plugindir=args[0];
	  }
    String result=HpccGatePlugin.execute("John Smith, president of Umbrella Corporation, worked in Atlanta Georgia and lived at 123 S. Main St in August of 2002", 
    		"ANNIE","ANNIE_with_defaults.gapp",plugindir);
    System.out.println(result);
    /*
    // for each document, get an XML document with the
    // person and location names added
    Iterator iter = corpus.iterator();
    int count = 0;
    String startTagPart_1 = "<span GateID=\"";
    String startTagPart_2 = "\" title=\"";
    String startTagPart_3 = "\" style=\"background:Red;\">";
    String endTag = "</span>";

    while(iter.hasNext()) {
      Document doc = (Document) iter.next();
      AnnotationSet defaultAnnotSet = doc.getAnnotations();
      Set annotTypesRequired = new HashSet();
      annotTypesRequired.add("Person");
      annotTypesRequired.add("Location");
      Set<Annotation> peopleAndPlaces =
        new HashSet<Annotation>(defaultAnnotSet.get(annotTypesRequired));

      FeatureMap features = doc.getFeatures();
      String originalContent = (String)
        features.get(GateConstants.ORIGINAL_DOCUMENT_CONTENT_FEATURE_NAME);
      RepositioningInfo info = (RepositioningInfo)
        features.get(GateConstants.DOCUMENT_REPOSITIONING_INFO_FEATURE_NAME);

      ++count;
      File file = new File("StANNIE_" + count + ".HTML");
      Out.prln("File name: '"+file.getAbsolutePath()+"'");
      if(originalContent != null && info != null) {
        Out.prln("OrigContent and reposInfo existing. Generate file...");

        Iterator it = peopleAndPlaces.iterator();
        Annotation currAnnot;
        SortedAnnotationList sortedAnnotations = new SortedAnnotationList();

        while(it.hasNext()) {
          currAnnot = (Annotation) it.next();
          sortedAnnotations.addSortedExclusive(currAnnot);
        } // while

        StringBuffer editableContent = new StringBuffer(originalContent);
        long insertPositionEnd;
        long insertPositionStart;
        // insert anotation tags backward
        Out.prln("Unsorted annotations count: "+peopleAndPlaces.size());
        Out.prln("Sorted annotations count: "+sortedAnnotations.size());
        for(int i=sortedAnnotations.size()-1; i>=0; --i) {
          currAnnot = (Annotation) sortedAnnotations.get(i);
          insertPositionStart =
            currAnnot.getStartNode().getOffset().longValue();
          insertPositionStart = info.getOriginalPos(insertPositionStart);
          insertPositionEnd = currAnnot.getEndNode().getOffset().longValue();
          insertPositionEnd = info.getOriginalPos(insertPositionEnd, true);
          if(insertPositionEnd != -1 && insertPositionStart != -1) {
            editableContent.insert((int)insertPositionEnd, endTag);
            editableContent.insert((int)insertPositionStart, startTagPart_3);
            editableContent.insert((int)insertPositionStart,
                                                          currAnnot.getType());
            editableContent.insert((int)insertPositionStart, startTagPart_2);
            editableContent.insert((int)insertPositionStart,
                                                  currAnnot.getId().toString());
            editableContent.insert((int)insertPositionStart, startTagPart_1);
          } // if
        } // for

        FileWriter writer = new FileWriter(file);
        writer.write(editableContent.toString());
        writer.close();
      } // if - should generate
      else if (originalContent != null) {
        Out.prln("OrigContent existing. Generate file...");

        Iterator it = peopleAndPlaces.iterator();
        Annotation currAnnot;
        SortedAnnotationList sortedAnnotations = new SortedAnnotationList();

        while(it.hasNext()) {
          currAnnot = (Annotation) it.next();
          sortedAnnotations.addSortedExclusive(currAnnot);
        } // while

        StringBuffer editableContent = new StringBuffer(originalContent);
        long insertPositionEnd;
        long insertPositionStart;
        // insert anotation tags backward
        Out.prln("Unsorted annotations count: "+peopleAndPlaces.size());
        Out.prln("Sorted annotations count: "+sortedAnnotations.size());
        for(int i=sortedAnnotations.size()-1; i>=0; --i) {
          currAnnot = (Annotation) sortedAnnotations.get(i);
          insertPositionStart =
            currAnnot.getStartNode().getOffset().longValue();
          insertPositionEnd = currAnnot.getEndNode().getOffset().longValue();
          if(insertPositionEnd != -1 && insertPositionStart != -1) {
            editableContent.insert((int)insertPositionEnd, endTag);
            editableContent.insert((int)insertPositionStart, startTagPart_3);
            editableContent.insert((int)insertPositionStart,
                                                          currAnnot.getType());
            editableContent.insert((int)insertPositionStart, startTagPart_2);
            editableContent.insert((int)insertPositionStart,
                                                  currAnnot.getId().toString());
            editableContent.insert((int)insertPositionStart, startTagPart_1);
          } // if
        } // for

        FileWriter writer = new FileWriter(file);
        writer.write(editableContent.toString());
        writer.close();
      }
      else {
        Out.prln("Content : "+originalContent);
        Out.prln("Repositioning: "+info);
      }

      String xmlDocument = doc.toXml(peopleAndPlaces, false);
      String fileName = new String("StANNIE_toXML_" + count + ".HTML");
      FileWriter writer = new FileWriter(fileName);
      writer.write(xmlDocument);
      writer.close();

    } // for each doc
    */
  } // main

} // class StandAloneAnnie