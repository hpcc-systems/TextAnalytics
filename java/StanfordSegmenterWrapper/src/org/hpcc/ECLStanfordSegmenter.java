package org.hpcc;

import java.io.File;
import java.net.URLDecoder;
import java.util.Properties;

import edu.stanford.nlp.ie.crf.CRFClassifier;
import edu.stanford.nlp.ling.CoreLabel;


public class ECLStanfordSegmenter {

	private static String dataDirectory="";
    private static CRFClassifier<CoreLabel> segmenter =null;

/** This is a very simple demo of calling the Chinese Word Segmenter
 *  programmatically.  It assumes an input file in UTF8.
 *  <p/>
 *  <code>
 *  Usage: java -mx1g -cp seg.jar SegDemo fileName
 *  </code>
 *  This will run correctly in the distribution home directory.  To
 *  run in general, the properties for where to find dictionaries or
 *  normalizations have to be set.
 *
 *  @author Christopher Manning
 */

public static String segment(String segmentin) throws Exception
{
	if (segmenter==null) { loadSegmenter(null);}
    String result=segmenter.classifyToString(segmentin,"slashTags",false);
    return result;
	
}

public static void loadSegmenter(String datadir) throws Exception {
	if (datadir==null || datadir.isEmpty()) {
		File test=new File(ECLStanfordSegmenter.class.getProtectionDomain().getCodeSource().getLocation().getPath());
		if (test.exists()) {
			test=test.getParentFile();
			dataDirectory=test.getAbsolutePath() + "/" + "stanfordsegdata";
			dataDirectory=dataDirectory.replace(";","");
		}
		else {
			dataDirectory="";
		}
	
	} else {
		dataDirectory=datadir;
	}
	System.out.println("Data directory:" + dataDirectory);
	if (!new File(dataDirectory).exists()) {
		throw new Exception("Data directory " + dataDirectory + " not found.");
	}
	Properties props = new Properties();
    props.setProperty("sighanCorporaDict",dataDirectory);
    // props.setProperty("NormalizationTable", "data/norm.simp.utf8");
    // props.setProperty("normTableEncoding", "UTF-8");
    // below is needed because CTBSegDocumentIteratorFactory accesses it
    props.setProperty("serDictionary",dataDirectory + "/dict-chris6.ser.gz");
    //props.setProperty("testFile", args[0]);
    props.setProperty("inputEncoding", "UTF-8");
    props.setProperty("sighanPostProcessing", "true");

    segmenter = new CRFClassifier<CoreLabel>(props);
    segmenter.loadClassifierNoExceptions(dataDirectory + "/ctb.gz", props);	
}

  public static void main(String[] args) throws Exception {

	    String result=segment("因为冰箱本身的设计寿命是十年左右，时间长了，肯定大部分零部件是要老化的/可怜");
	    System.out.println(result);
	    result=segment("因为冰箱本身的设计寿命是十年左右，时间长了，肯定大部分零部件是要老化的/可怜");
	    System.out.println(result);
  }

}
