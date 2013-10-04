<%@ page import="java.io.FileInputStream"%>
<%@ page import="java.io.InputStreamReader"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.io.BufferedInputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.IOException"%>
<%@ page import="javax.crypto.Cipher"%>
<%@ page import="javax.crypto.spec.SecretKeySpec"%>
<%@ page import="sun.misc.BASE64Decoder"%>


<%
	// you  can get your base and parent from the database
	String encFileName = request.getParameter("resource");
    // make a timestamp
    java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("MM/dd/yy H:mm:ss");
    String timestamp = formatter.format(new java.util.Date())+" ";

	try
	{
		//Decode the text using cipher
		SecretKeySpec keySpec = new SecretKeySpec("ep1G3n0meh@xXing".getBytes(), "AES");
		Cipher desCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
		desCipher.init(Cipher.DECRYPT_MODE, keySpec, desCipher.getParameters());
		byte[] encodedBytes = new BASE64Decoder().decodeBuffer(encFileName);
		String filePath = new String(desCipher.doFinal(encodedBytes));
		
		if (request.getUserPrincipal() != null)
		{
			System.err.println(timestamp + request.getUserPrincipal().getName() + " downloading " + filePath);
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
					System.err.println(timestamp + "symlinks traced with perl fork: " + inputPath);
				System.out.flush();
				filePath = inputPath;

			} catch (Exception e)
			{
				System.out.println(timestamp +"error executing perl smylinks finder, using original path:" + filePath);
				e.printStackTrace();
			}


			
			
			myOut = response.getOutputStream();
			File myfile = new File(filePath);
			FileInputStream input = new FileInputStream(myfile);
			buf = new BufferedInputStream(input);
			int readBytes = 0;

			//set response headers
			response.setContentType("application/octet-stream");
			
			//handle symlink names, we want the downloaded name to match the symlink itself, not the target.
			//response.addHeader("Content-Disposition", "attachment; filename=" + myfile.getName());
			if(myfile.getName().endsWith(".gz") && !originalFileName.endsWith(".gz"))
			{
				response.addHeader("Content-Disposition", "attachment; filename=" + originalFileName + ".gz");
			}
			else if(myfile.getName().endsWith(".zip") && !originalFileName.endsWith(".zip"))
			{
				response.addHeader("Content-Disposition", "attachment; filename=" + originalFileName + ".zip");
			}
			else if(myfile.getName().endsWith(".bz2") && !originalFileName.endsWith(".bz2"))
			{
				response.addHeader("Content-Disposition", "attachment; filename=" + originalFileName + ".bz2");
			}
			else
				response.addHeader("Content-Disposition", "attachment; filename=" + originalFileName);
	
			
			//set file length
			if (myfile.length() <= Integer.MAX_VALUE)
				response.setContentLength((int) myfile.length());
			else
				response.setHeader("Content-Length", Long.toString(myfile.length()));

			//read from the file; write to the ServletOutputStream
			System.err.println(timestamp + "Streaming file: " + filePath);
			while ((readBytes = buf.read()) != -1)
				myOut.write(readBytes);

		} catch (IOException ioe)
		{
			out.println(timestamp + "Unauthorized File Request");
			throw new ServletException(ioe.getMessage());
		} finally
		{
			//close the input/output streams
			if (myOut != null)
				myOut.close();
			if (buf != null)
				buf.close();
		}
	} catch (Exception e)
	{
		out.println(timestamp + "Unauthorized File Request");
		e.printStackTrace();
	}
	
%>
