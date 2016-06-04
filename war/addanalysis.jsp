<%@ page language="java" contentType="text/plain; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.util.*,java.io.*,edu.usc.epigenome.eccp.client.data.*,com.google.gson.Gson,edu.usc.epigenome.eccp.server.ECServiceBackend,edu.usc.epigenome.eccp.client.data.*" %><%
try
{
	ECServiceBackend backend = new ECServiceBackend();
	Gson gson = new Gson();
	 StringBuffer jb = new StringBuffer();
	  String line = null;
	  
	    BufferedReader reader = request.getReader();
	   while ((line = reader.readLine()) != null)
	         jb.append(line);
	   
	   
	   
	   //test
// 	   DataModification update = new DataModification(); update.setAnalysisID("aaan");update.setExperimentID("eexpppp");update.setSampleId("sampleeee");
// 	   DataModificationMetric[] d = new  DataModificationMetric[3];
// 	   d[0] = new DataModificationMetric();
// 	   d[0].setMetricFileName("fileee");
// 	   d[0].setMetricFileSize(123123);
// 	   d[0].setMetricName("ffff");
// 	   d[0].setMetricValue("uuuu");
// 	   d[1] = new DataModificationMetric();
// 	   d[1].setMetricFileName("fileee");
// 	   d[1].setMetricFileSize(123123);
// 	   d[1].setMetricName("ffff");
// 	   d[1].setMetricValue("uuuu");
// 	   d[2] = new DataModificationMetric();
// 	   d[2].setMetricFileName("fileee");
// 	   d[2].setMetricFileSize(123123);
	   
// 	   update.setMetrics(d);
	   
	   
// 	   String s = gson.toJson(update);
// 	   out.println(s);
	   
	   
	   DataModification update = gson.fromJson(jb.toString(),DataModification.class);
	   int rsid = backend.insertAnalysis(update.getExperimentID(), update.getSampleId(), update.getAnalysisID());
	   
	   for(DataModificationMetric m : update.getMetrics())
	   {
		   int fileID = 0;
		   if(m.getMetricFileName() != null)
			  fileID = backend.insertFileURI(m.getMetricFileName(), rsid, m.getMetricFileSize());
		   if(m.getMetricName() != null && m.getMetricValue() != null)
			   backend.insertMetric(rsid, m.getMetricName(), m.getMetricValue(), fileID);	   		   	
	   }
	   out.println("added to DB, new entries will not display until you rebuild the table");
}
catch(Exception e)
{
	StringWriter sw = new StringWriter();
	PrintWriter pw = new PrintWriter(sw);
	e.printStackTrace(pw);
	out.println(sw.toString());
}
%>
