<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.util.*,java.io.*,javax.crypto.Cipher,javax.crypto.spec.SecretKeySpec,sun.misc.BASE64Decoder,sun.misc.BASE64Encoder,edu.usc.epigenome.eccp.server.ECServiceBackend,edu.usc.epigenome.eccp.client.data.*" %><%
try{
if(request.getParameter("xml") != null)
{
	ECServiceBackend e = new ECServiceBackend();
	ArrayList<FlowcellData> f = e.getFlowcellsFromGeneus();
	ArrayList<FlowcellData> clean = new ArrayList<FlowcellData>();
	String encprojname = request.getParameter("project");
	
	SecretKeySpec keySpec = new SecretKeySpec("ep1G3n0meh@xXing".getBytes(), "AES");
	Cipher desCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
	desCipher.init(Cipher.DECRYPT_MODE,keySpec,desCipher.getParameters());
	byte[] encodedBytes = new BASE64Decoder().decodeBuffer(encprojname);
	String projname = new String(desCipher.doFinal(encodedBytes));
	
	for(FlowcellData x : f)
	{
	        if(x.flowcellContains(projname))
	           clean.add(x);	
	}
			out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
		
			out.print("<Global name=" + "\""+ projname + "\">");
			
	
	for(FlowcellData x : clean)
	{
	        out.print("<Category name=\"" + x.getFlowcellProperty("serial") + "\">");
	        
	        for(HashMap<String,String> file :e.getFilesforFlowcell(x.getFlowcellProperty("serial")).fileList)
	        {
	            if(file.get("base").contains("tdf"))
	            {
	       		  out.print("<Resource name=\"" + file.get("base") + "\"" + " path=\"" + "http://www.epigenome.usc.edu/webmounts/" + file.get("dir") + "/" + file.get("base"));
				  out.print("\"/>");
	            }

	        }
	out.println("</Category>");
	}
out.println("</Global>");
}
else
{out.println("http://webapp.epigenome.usc.edu/ECCP/Igvtrack.jsp?project=" + request.getParameter("project") + "&xml=true");	
}
}catch(Exception exp){out.println("No project exists by this name");}
%>

