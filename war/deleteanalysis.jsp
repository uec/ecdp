<%@ page language="java" contentType="text/plain; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.util.*,java.io.*,edu.usc.epigenome.eccp.client.data.*,com.google.gson.Gson,edu.usc.epigenome.eccp.server.ECServiceBackend,edu.usc.epigenome.eccp.client.data.*" %><%
try
{
	ECServiceBackend backend = new ECServiceBackend();
	backend.deleteAnalysis(request.getParameter("analysis_id"));
	out.println(request.getParameter("analysis_id") + " Removed");
}
catch(Exception e)
{
	StringWriter sw = new StringWriter();
	PrintWriter pw = new PrintWriter(sw);
	e.printStackTrace(pw);
	out.println(sw.toString());
}
%>
