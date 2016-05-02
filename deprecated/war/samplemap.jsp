<%@ page language="java" contentType="text/plain; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.util.*,edu.usc.epigenome.eccp.server.ECServiceBackend,edu.usc.epigenome.eccp.client.data.*" %><%
try
{
        ECServiceBackend e = new ECServiceBackend();
        ArrayList<MethylationData> allBeadArrays = e.getMethFromGeneus();

        for(MethylationData beadArray : allBeadArrays)
        {
                List<Integer> keys = new ArrayList<Integer>(beadArray.lane.keySet());
                Collections.sort(keys);
                for(int i : keys)
                {
                        out.println(beadArray.getFlowcellProperty("serial") + "	" + beadArray.getLaneProperty(i,"lane").replace(":1","") + "	" +   beadArray.getLaneProperty(i,"name") + "	" +  beadArray.getLaneProperty(i,"sex") + "	" +  beadArray.getLaneProperty(i,"tissue"));

                }
                
                
        }
}
catch(Exception e)
{
        out.println(e.toString());
}
%>
