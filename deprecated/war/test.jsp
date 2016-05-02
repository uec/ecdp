<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.util.*,edu.usc.epigenome.eccp.server.ECServiceBackend,edu.usc.epigenome.eccp.client.data.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<%
if(request.getParameter("xml") != null)
{
	ECServiceBackend e = new ECServiceBackend();
	ArrayList<FlowcellData> f = e.getFlowcellsFromGeneus();
	ArrayList<FlowcellData> clean = new ArrayList<FlowcellData>();
	for(FlowcellData x : f)
	{
	        if(x.flowcellContains(request.getParameter("project")))
	        	clean.add(x);
	        
	}
	
	for(FlowcellData x : clean)
	{
	        out.println(x.getFlowcellProperty("serial") + "<br/>"); 
	        for(HashMap<String,String> file :e.getFilesforFlowcell(x.getFlowcellProperty("serial")).fileList)
	        {
	                if(file.get("base").contains("tdf"))
	                        out.println( "<a target=\"new\" href=\"http://www.epigenome.usc.edu/webmounts/" + file.get("dir") + "/" + file.get("base") + "\">" + file.get("base") + "</a><br/>"  );
	        }
	        out.println("<br/><br/>");
	}
}

else
{
	out.println("http://www.broadinstitute.org/igvdata/annotations/hg18/hg18_annotations.xml");
	out.println("http://webapp.epigenome.usc.edu/ECCP/test2.jsp?project=" + request.getParameter("project") + "&xml=true");	
}
%>
</body>
</html>