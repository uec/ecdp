<%@ page import="java.io.FileInputStream"%>
<%@ page import="java.io.BufferedInputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.IOException"%>
<%@ page import="javax.crypto.Cipher"%>
<%@ page import="javax.crypto.spec.SecretKeySpec"%>
<%@ page import="sun.misc.BASE64Decoder"%>


<%
	// you  can get your base and parent from the database
	String encFileName = request.getParameter("resource");
	
	try
	{
		//Decode the text using cipher
		SecretKeySpec keySpec = new SecretKeySpec("ep1G3n0meh@xXing".getBytes(), "AES");
		Cipher desCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
		desCipher.init(Cipher.DECRYPT_MODE,keySpec,desCipher.getParameters());
		byte[] encodedBytes = new BASE64Decoder().decodeBuffer(encFileName);
		String filePath = new String( desCipher.doFinal(encodedBytes));
		
		if(!filePath.startsWith("/storage/"))
			return;
				
		
		//Retrieve the file
		BufferedInputStream buf = null;
		ServletOutputStream myOut = null;
		try
		{
			myOut = response.getOutputStream();
			File myfile = new File(filePath);
			FileInputStream input = new FileInputStream(myfile);
			buf = new BufferedInputStream(input);
			int readBytes = 0;

			//set response headers
			response.setContentType("application/octet-stream");
			response.addHeader("Content-Disposition", "attachment; filename=" + myfile.getName());
			if(myfile.length() <= Integer.MAX_VALUE)
				response.setContentLength((int) myfile.length());
			else
				response.setHeader("Content-Length", Long.toString(myfile.length()));
			
			//read from the file; write to the ServletOutputStream
			while ((readBytes = buf.read()) != -1)
				myOut.write(readBytes);
			
		} catch (IOException ioe)
		{
			out.println("Unauthorized File Request");	
			throw new ServletException(ioe.getMessage());
		} 
		finally
		{
			//close the input/output streams
			if (myOut != null)
				myOut.close();
			if (buf != null)
				buf.close();
		}
	}
	catch(Exception e)
	{
		out.println("Unauthorized File Request");	
	}
	
	
	

	



%>