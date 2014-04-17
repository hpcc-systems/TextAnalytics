package test;

import org.hpcc.indexsearch.util.SOAPHelper;
import org.hpcc.indexsearch.util.Utility;
import org.w3c.dom.NodeList;


public class ECLGeneratorTest
{

    /**
     * @param args
     */
    public static void main(String[] args)
    { 
        String hpccURL = "http://10.173.147.1:8010/WsWorkunits/WUInfo?Wuid=20130101";
        String workunitURL = "wsWorkunits?";
        String url = hpccURL + workunitURL;
        String hpccResult;
        try
        {
        	hpccResult = Utility.processRequest(url, "", "username","password",null);
            String status=Utility.getNodeValueString(hpccResult,"/Workunit/State");
            System.out.println(status);
            NodeList listdom = Utility.getNodes(hpccResult,"/Workunit/Exceptions");
            System.out.println(listdom.getLength());
        } catch (Exception e)
        {
            e.printStackTrace();
        }
    }
}
