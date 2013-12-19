<%@ page import="java.io.FileInputStream"%>
<%@ page import="java.io.InputStreamReader"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.io.BufferedInputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.IOException"%>
<%@ page import="javax.crypto.Cipher"%>
<%@ page import="javax.crypto.spec.SecretKeySpec"%>
<%@ page import="sun.misc.BASE64Decoder"%>
<%@ page import="edu.usc.epigenome.eccp.server.ECServiceBackend"%>
<%@ page import="java.net.URLDecoder"%>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <title>convert to hpcc paths @ usc epigenome center</title>
        <LINK REL="stylesheet" href="style.css" type="text/css"/>
  </head>
  <body>
  		<h2>Enter your links to convert to hpcc paths. one link per line</h2>
         <form action="retrieveHPCC.jsp" method="post">
           <textarea cols="100" rows="20" name="links"></textarea>
           <br/>
           <input type="submit" value="Submit" />
        </form>



<%
	// you  can get your base and parent from the database
	
	
	if(request.getParameter("links") != null && request.getParameter("links").length() > 10)
	{
		String[] urls = request.getParameter("links").split("\n");
		for(String s : urls)
		{
			String s2 = s.replaceAll("^.+resource=", "");
			String encFileName = URLDecoder.decode(s2);	
				
			try
			{
				//Decode the text using cipher
				ECServiceBackend backend = new ECServiceBackend();
				SecretKeySpec keySpec = new SecretKeySpec("ep1G3n0meh@xXing".getBytes(), "AES");
				Cipher desCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
				desCipher.init(Cipher.DECRYPT_MODE, keySpec, desCipher.getParameters());
				byte[] encodedBytes = new BASE64Decoder().decodeBuffer(encFileName);
				String filePath = new String(desCipher.doFinal(encodedBytes));
				
				if (request.getUserPrincipal() != null)
				{
					backend.logWriter(request,"starting download: " + filePath);
				}
		
				if (!filePath.startsWith("/storage/"))
					return;
				
				String originalFileName = new File(filePath).getName();
				
				
				//Retrieve the file
				BufferedInputStream buf = null;
				ServletOutputStream myOut = null;
				try
				{
					//since java6 cant do symlinks fork off a perl script to detect if file is gone and has been replaced with a file.gz||file.bz2||file.zip
				
					try
					{
						String inputPath = new String(filePath);
						String[] aCmdArgs = { "/opt/tomcat6/webapps/eccpgxt/helperscripts/symlink.pl", inputPath};
						Runtime oRuntime = Runtime.getRuntime();
						Process oProcess = null;
		
						oProcess = oRuntime.exec(aCmdArgs);
						oProcess.waitFor();
						/* dump output stream */
						BufferedReader is = new BufferedReader(new InputStreamReader(oProcess.getInputStream()));
						if ((inputPath = is.readLine()) != null)
							backend.logWriter(request,"download symlink traced to: " + inputPath);
						System.out.flush();
						filePath = inputPath;
		
					} catch (Exception e)
					{
						backend.logWriter(request,"error executing perl smylinks finder, using original path:" + filePath);
						e.printStackTrace();
					}
		
		
					
					
					//myOut = response.getOutputStream();
					File myfile = new File(filePath);
					out.print(filePath.replace("/storage/hpcc","/export") + "</br>\n");
				
		
				} catch (IOException ioe)
				{
					out.println("invalid link");
					throw new ServletException(ioe.getMessage());
				} 
			} catch (Exception e)
			{
				out.println("invalid link");
				e.printStackTrace();
			}
		}
	}
%>

    </body>
  </html>    
