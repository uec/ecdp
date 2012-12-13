package edu.usc.epigenome.eccp.server;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.http.HttpServletRequest;
import org.eclipse.jetty.util.MultiMap;
import org.eclipse.jetty.util.UrlEncoded;
import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.data.FileData;

import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.data.LibraryProperty;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;

/**
 * The server side implementation of the RPC service.
 */
@SuppressWarnings("serial")
public class ECServiceBackend extends RemoteServiceServlet implements ECService
{
	String db="jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing_production?user=";
	
	/*
	 * Method to get the md5 hash of the input string takes string as an input
	 * parameter and returns the md5 hash of the input string
	 */
	private static String md5(String text)
	{
		MessageDigest md;
		try
		{
			md = MessageDigest.getInstance("MD5");
			md.update(text.getBytes());
			byte byteData[] = md.digest();

			// convert the byte to hex format method
			StringBuffer sb = new StringBuffer();
			for (int i = 0; i < byteData.length; i++)
				sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
			return sb.toString();
		} catch (NoSuchAlgorithmException e)
		{
			e.printStackTrace();
		}
		return text;
	}

	/*********************************************************************
	 * Functions to clear contents of Cache ("OLD" stack panel view)
	 ********************************************************************* 
	 */
	/*
	 * (non-Javadoc)
	 * 
	 * @see edu.usc.epigenome.eccp.client.ECService#clearCache(java.lang.String)
	 * function to clear the contents of cache in the /tmp directory
	 */

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * edu.usc.epigenome.eccp.client.ECService#decryptKeyword(java.lang.String,
	 * java.lang.String) Method to decrypt the string parameters passed to the
	 * function.
	 */
	public String decryptTextMD5(String encWord)
	{
		String fcellAfterDecrypt = null;
		try
		{
			
			// Decode the text using cipher
			SecretKeySpec keySpec = new SecretKeySpec("ep1G3n0meh@xXing".getBytes(), "AES");
			Cipher desCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			desCipher.init(Cipher.DECRYPT_MODE, keySpec, desCipher.getParameters());

			// Get the byte array using the BASE64Decoder
			byte[] fcellEncodedBytes = new BASE64Decoder().decodeBuffer(encWord);
			byte[] fcellBytes = desCipher.doFinal(fcellEncodedBytes);
			// Get string of the decoded byte arrays
			fcellAfterDecrypt = new String(fcellBytes);
			System.out.println("Word AfterDecrypt is " + fcellAfterDecrypt);
			String tempFcell = fcellAfterDecrypt.substring(0, fcellAfterDecrypt.length() - 32);
			System.out.println("trimmed  tempFcell is " + tempFcell);

			// Check the decrypted value with the md5 value
			if (md5(tempFcell).equals(fcellAfterDecrypt.substring(fcellAfterDecrypt.length() - 32, fcellAfterDecrypt.length())))
			{
				System.out.println("post md5   tempFcell is " + tempFcell);
				return tempFcell;
			}

		} catch (Exception e)
		{
			e.printStackTrace();
		}
		// Else add the original string into the decryptedContents array
		
		return "NOTHINGBUTGARBAGE";
	}

	
	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * edu.usc.epigenome.eccp.client.ECService#encryptURLEncoded(java.lang.String
	 * ) URLEncode the md5 and AES encrypted string
	 */
	@SuppressWarnings("deprecation")
	public String encryptURLEncoded(String srcText) throws IllegalArgumentException
	{
		return java.net.URLEncoder.encode(encryptString(srcText));
	}

	
	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * edu.usc.epigenome.eccp.client.ECService#getCSVFromDisk(java.lang.String)
	 * Function to read data points from the given file to display plots
	 */
	public String getCSVFromDisk(String filePath) throws IllegalArgumentException
	{
		if (!(filePath.contains("Count") && filePath.endsWith(".csv") || filePath.endsWith("Metrics.txt")))
			return "security failed, blocked by ECCP access controls";

		byte[] buffer = new byte[(int) new File(filePath).length()];
		BufferedInputStream f = null;
		try
		{
			try
			{
				f = new BufferedInputStream(new FileInputStream(filePath));
			} catch (FileNotFoundException e)
			{
				e.printStackTrace();
			}
			try
			{
				f.read(buffer);
			} catch (IOException e)
			{
				e.printStackTrace();
			}
		} finally
		{
			if (f != null)
				try
				{
					f.close();
				} catch (IOException ignored)
				{
				}
		}
		return new String(buffer);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * edu.usc.epigenome.eccp.client.ECService#getEncryptedData(java.lang.String
	 * , java.lang.String) remote method to md5 and then encrypt and url encode
	 * the input. returns an ArrayList of the encrypted data.
	 */
	public ArrayList<String> getEncryptedData(String globalText) throws IllegalArgumentException
	{
		try
		{
			ArrayList<String> retCipher = new ArrayList<String>();
			String mdGlobal = md5(globalText);
			// String mdLane = md5(laneText);
			String tempGlobal = globalText.concat(mdGlobal);
			// String tempLane = laneText.concat(mdLane);
			retCipher.add(encryptURLEncoded(tempGlobal));
			// retCipher.add(encryptURLEncoded(tempLane));
			return retCipher;
		} catch (Exception e)
		{
			e.printStackTrace();
		}
		return null;
	}

	/*
	 * Function to get the name of file from the given full file path
	 */
	public String getFileName(String fullPath)
	{
		int sep = fullPath.lastIndexOf('/');
		return fullPath.substring(sep + 1, fullPath.length());
	}

	/*********************************************************************
	 * Utility Functions
	 ********************************************************************* 
	 */

	/*
	 * Get file path without the filename
	 */
	public String getFilePath(String fullPath)
	{
		int sep = fullPath.lastIndexOf('/');
		return fullPath.substring(0, sep);
	}

	/*
	 * Get files for the flowcell specific view Takes the flowcell as the input
	 * parameter and returns the files for the particular flowcell
	 */

	// Returns details from the QC table.
	public HashMap<String, HashMap<String, String>> getQCTypes()
	{
		java.sql.Connection myConnection = null;
		HashMap<String, HashMap<String, String>> metrics = new HashMap<String, HashMap<String, String>>();
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			// database connection code
			String username = "zack";
			String password = "LQSadm80";

			// URL to connect to the database
			String dbURL = db + username + "&password=" + password;
		//	String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing_production?user=" + username + "&password=" + password;
			//String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user=" + username + "&password=" + password;
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);

			// create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			// get the distinct analysis_id's for the given flowcell,
			// sample_name and lane number
			String selectQuery = "Select \n" + "	m.metric as metric, \n" + "	m.isNumeric as isNumeric, \n" + "	m.sort_order as sort_order,\n"
					+ "	IF(ISNULL(m.description),\"No Description\",m.description) as description,\n"
					+ "	IF(ISNULL(m.pretty_name),m.metric,m.pretty_name) as pretty_name,\n" + "	m.usage_enum as usage_enum,\n"
					+ "	IF(ISNULL(c.name),\"Unknown\",c.name) as category,  \n" + "	IF(ISNULL(f.parser),\"Unknown\",f.parser) as parser\n" + "from \n"
					+ "metric m left join category c on m.id_category = c.id left join file_type f on f.id = id_file_type\n" + " order by metric ";
			ResultSet results = stat.executeQuery(selectQuery);

			while (results.next())
			{
				HashMap<String, String> value = new HashMap<String, String>();
				for (int i = 1; i <= results.getMetaData().getColumnCount(); i++)
				{
					value.put(results.getMetaData().getColumnName(i), results.getString(i));

					// System.out.println("Found isNumeric column in metrics table ");
				}

				metrics.put(results.getString("metric"), value);
			}
		} catch (Exception e)
		{
			e.printStackTrace();
		} finally
		{
			try
			{
				myConnection.close();
			} catch (SQLException e)
			{
				e.printStackTrace();
			}
		}
		return metrics;
	}

	/*********************************************************************
	 * Extra Functions
	 ********************************************************************* 
	 */

	public String NoFormat(String temp)
	{
		NumberFormat formatter = NumberFormat.getInstance();
		String result = null;
		double no = Double.valueOf(temp);
		if (no == 0)
			result = temp;
		else if (no > 100000)
			result = formatter.format(no / 1000000) + "M";
		else if (no < 1.0)
		{
			result = formatter.format(no * 100) + "%";
		} else
			result = temp;

		return result;
	}

	/*
	 * Method to AES encrypt the given string. return the cipher text after AES
	 * encryption.
	 */
	private String encryptString(String srcText)
	{
		try
		{
			SecretKeySpec keySpec = new SecretKeySpec("ep1G3n0meh@xXing".getBytes(), "AES");
			Cipher desCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			desCipher.init(Cipher.ENCRYPT_MODE, keySpec);
			byte[] byteDataToEncrypt = srcText.getBytes();
			byte[] byteCipherText = desCipher.doFinal(byteDataToEncrypt);
			String strCipherText = new BASE64Encoder().encode(byteCipherText);
			return strCipherText;
		} catch (Exception e)
		{
			e.printStackTrace();
		}
		return srcText;
	}

	@Override
	public ArrayList<LibraryData> getLibraries(LibraryDataQuery queryParams)
	{
	

		ArrayList<LibraryData> data = new ArrayList<LibraryData>();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance();

			// database connection parameters
			String username = "zack";
			String password = "LQSadm80";

			// URL for database connection
			String dbURL = db + username + "&password=" + password;
		 // String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing_production?user=" + username + "&password=" + password;
			//String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user=" + username + "&password=" + password;
         //   String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_test?user=" + username + "&password=" + password;
			
			 // create the connection
			myConnection = DriverManager.getConnection(dbURL);

			
			//build the where clause using the LibraryDataQuery specification
			String where = "WHERE ";
			if (queryParams.getDBid() != null)
				where += " id_run_sample = " + queryParams.getDBid() + " AND ";
			if (queryParams.getFlowcell() != null)
				where += " flowcell_serial LIKE '%" + queryParams.getFlowcell() + "%' AND ";

			//filter based upon user ldap group!
			HttpServletRequest request = this.getThreadLocalRequest();
			if (request.getUserPrincipal() != null)
			{
				// debug for user role checking
				if (request.isUserInRole("ECCPWebAdmin"))
					System.out.println("ECCPWebAdmin:" + request.getUserPrincipal().getName());
				if (request.isUserInRole("solexaWebData"))
					System.out.println("solexaWebData:" + request.getUserPrincipal().getName());
				
				System.out.println("User:" + request.getUserPrincipal().getName());
				System.out.println("Query:" + request.getQueryString());
				System.out.println("URI:" + request.getRequestURL());
				System.out.println("map size:" + request.getParameterMap().size());
				System.out.println("ref:" + request.getHeader("referer"));
				
				URL url = new URL(request.getHeader("referer"));
				MultiMap<String> params = new MultiMap<String>();
				if(url.getQuery() != null)
					UrlEncoded.decodeTo(url.getQuery(), params, "UTF-8");
				if(request.isUserInRole("ECCPWebAdmin") && params.containsKey("superquery"))
					where += decryptTextMD5(params.getString("superquery")) + " AND ";
				else if (!request.isUserInRole("ECCPWebAdmin") || params.containsKey("t") || params.containsKey("q"))
				{
					String contents = "";
					if(params.containsKey("t"))
						contents += decryptTextMD5(params.getString("t"));
					if(params.containsKey("q"))
						contents += "  " + decryptTextMD5(params.getString("q"));
					if(contents.length() < 3)
						contents = "NOTHINGBUTGARBAGE";
					System.out.println("URL PARAM DEC: " + contents);
					where += "MATCH(project, sample_name, organism, technician, flowcell_serial, geneusID_sample) against ('+"+ contents + "' IN BOOLEAN MODE) AND ";
				}
			}
			
			where += "0=0";

			String columns = queryParams.getIsSummaryOnly() ? " id_run_sample, geneusID_sample, analysis_id, flowcell_serial, lane, project, sample_name, processing, \n" +
					"If(" +
					"	ISNULL(RunParam_RunID), " +
					"	STR_TO_DATE(concat(substring(Date_Sequenced,1,6),\",\",substring(Date_Sequenced,7,5)),'%M %d,%Y'), " +
					"	STR_TO_DATE(concat(\"20\",substring(RunParam_RunID,1,2),\",\",substring(RunParam_RunID,3,2),\",\",substring(RunParam_RunID,5,2)),'%Y,%m,%e')) " +
					"as Date_Sequenced "
				: " * ,"+
				"If(" +
				"	ISNULL(RunParam_RunID), " +
				"	STR_TO_DATE(concat(substring(Date_Sequenced,1,6),\",\",substring(Date_Sequenced,7,5)),'%M %d,%Y'), " +
				"	STR_TO_DATE(concat(\"20\",substring(RunParam_RunID,1,2),\",\",substring(RunParam_RunID,3,2),\",\",substring(RunParam_RunID,5,2)),'%Y,%m,%e')) " +
				"as Date_Sequenced_temp ";

			// create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			// Get all the distinct sample_names for the given projectName
			String selectQuery = "select" + columns + "from view_run_metric " + where;
			System.out.println("The query that is executed is " + selectQuery);
			ResultSet results = stat.executeQuery(selectQuery);
			HashMap<String, HashMap<String, String>> qcTypes = getQCTypes();
			// NumberFormat formatter = new DecimalFormat("##.##");
			DecimalFormat dbl = new DecimalFormat("0.##E00");
			DecimalFormat itgr = new DecimalFormat();
			itgr.setGroupingSize(3);
			dbl.setGroupingSize(3);

		
			//Iterate over the results
			 while(results.next())
			 {
				 LibraryData d = new LibraryData();
				 for(int i = 1 ; i <= results.getMetaData().getColumnCount(); i++)
				 {	 
					 LibraryProperty p = new LibraryProperty(); 
					 //Name
					 p.setName( results.getMetaData().getColumnName(i));
					 //Value
					 String tvalue = results.getString(i);
					 
				 if (qcTypes.containsKey(p.getName())) 
				 {
					// System.out.println("Metric Name: "+p.getName()+" "+qcTypes.get(p.getName()));
					 
					 if (qcTypes.get(p.getName()).get("isNumeric").equals("1")) 
					 {
				//		 System.out.println("Numeric metric: "+tname+" "+tvalue);
						 double dd = Double.valueOf(tvalue);
						 long n = (long)dd;
						 if ((dd-n) == 0 ) {
							 //System.out.println(itgr.format(n));
							 p.setValue(itgr.format(n));
							
						 }
						 else  {
							 
							 if (Math.abs(dd) < 1) {
        						 p.setValue(dbl.format(dd));
        						// System.out.println(dbl.format(dd));
							 }
							 else  {
								 p.setValue(itgr.format(dd));							
							     //System.out.println(itgr.format(dd));
							 }
						 }
					 }
					 else  {
						    // p.setValue(tvalue);
						// System.out.println("tvalue="+tvalue);
						 if (tvalue !=null)
						     p.setValue(formatString(tvalue));
						 else p.setValue(tvalue);
					 }
					 
				 }
				    
				 else 	 p.setValue(tvalue);
				
				 	 //Category
				 	if(!queryParams.getIsSummaryOnly())
				 	{
					 	 if(qcTypes.containsKey(p.getName()))
					 	 {
						 	 p.setCategory(qcTypes.get(p.getName()).get("category"));
						 	//sort_order
						 	 p.setSortOrder(qcTypes.get(p.getName()).get("sort_order"));
						 	//desc
						 	 p.setDescription(qcTypes.get(p.getName()).get("description"));
						 	//pretty_name
						 	 p.setPrettyName(qcTypes.get(p.getName()).get("pretty_name"));
						 	 //parser
						 	 p.setSource(qcTypes.get(p.getName()).get("parser"));
						 	//usage
						 	 p.setUsage(qcTypes.get(p.getName()).get("usage_enum"));
					 	 }
					 	 else
					 	 {
					 		 	// this is for moving geneusID_sample to "Less metrics". 
					 		    // the category and usage are set to be the same as for sample_name metric
					 		    if (p.getName().equals("geneusID_sample")) {
					 		 		 p.setPrettyName("LIMS id");
					 		 		 p.setCategory(qcTypes.get("sample_name").get("category"));
					 		 		 p.setUsage(qcTypes.get("sample_name").get("usage_enum"));
					 		 	 }
					 		 	 else  { 
					 		 		 //category
					 		 		 p.setCategory("Unknown");
									 //usage
								 	 p.setUsage("0");
									 //pretty_name
								 	 p.setPrettyName(p.getName());
					 		 	 }
							 	     //sort_order
							 	     p.setSortOrder("100000");
							 	     //desc
							 	     p.setDescription("No Description");
							 	     //parser
							 	     p.setSource("Unknown");

					 	 }
				 	}
				 	d.put(p.getName(), p);				 	  
				 	  
				 }
				 LibraryProperty date = d.get("Date_Sequenced");
				 String val = d.get("Date_Sequenced").getValue();
				 if (val !=null) {
				    if (d.containsKey("Date_Sequenced_temp")) {					
					    String newDate = d.get("Date_Sequenced_temp").getValue();
					    date.setValue(newDate);
					    d.remove("Date_Sequenced_temp");
				    }
				 }
				 else {
					 if (d.containsKey("Date_Sequenced_temp")) {					
						 String newDate = d.get("Date_Sequenced_temp").getValue();
						    if (newDate!=null) {
						          date.setValue(newDate);
						          d.remove("Date_Sequenced_temp");
						    }
						    else date.setValue("No Date Entered");
					    }
					 else date.setValue("No Date Entered");
				 }
				 //extract LibType data from database column "processing"
				 LibraryProperty libType = d.get("processing");
				 String libTypeValue = d.get("processing").getValue();
				 if (libTypeValue !=null ) {
			    	  String pattern = "(L\\d+\\s+)(.*)(\\s+processing.*)";
			    	  libType.setValue(libTypeValue.replaceAll(pattern, "$2"));
			    	  
				 }
				 else libType.setValue("Unknown");
				 
				 if(queryParams.getGetFiles())
					 d.setFiles(getFilesforLibrary(d));
				 data.add(d);
			 }
		}
		catch (Exception e) {
			e.printStackTrace();
		} finally
		{
			try
			{
				myConnection.close();
			} catch (SQLException e)
			{
				e.printStackTrace();
			}
		}
				
		return data;
	}
	
	
	public String formatString(String s) 
	{
		try
		{
			String row ="";
			double dd;
			DecimalFormat dbl = new DecimalFormat("0.##E00");
			if (s.matches("(\\s*(-?\\d+\\.\\d+(E[-|+]\\d+)?)\\s*,?)+")) {
				if (s.matches(".*,.*")) {
					String [] temp = s.split(",");
					for (int i=0; i < temp.length; i++) {
						dd = Double.valueOf( temp[i].replaceAll("\\s", ""));
						String formatted =  dbl.format(dd);
						 if (!(i == temp.length-1))
							    row=row+formatted+",";
					     else row=row+formatted;	
						
					}
					return row;
				}
				else return dbl.format(Double.valueOf(s));
				
			}
		}
		catch(Exception e)
		{
			return s;
		}
		return s;
	}
	public String humanReadableByteCount(long bytes, boolean si) {
	    int unit = si ? 1000 : 1024;
	    if (bytes < unit) return bytes + " B";
	    int exp = (int) (Math.log(bytes) / Math.log(unit));
	   // String pre = (si ? "kMGTPE" : "KMGTPE").charAt(exp-1) + (si ? "" : "i");
	    String pre = ("KMGTPE").charAt(exp-1)+"";
	    return String.format("%d %s", (int) (bytes / Math.pow(unit, exp)), pre);
	}
	
	//returns a list of files associated with the given library
	public ArrayList<FileData> getFilesforLibrary(LibraryData lib) throws IllegalArgumentException
	{
		ArrayList<FileData> files = new ArrayList<FileData>();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			// database connection code
			String username = "zack";
			String password = "LQSadm80";

			// URL to connect to the database
			String dbURL = db + username + "&password=" + password;
			//String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing_production?user=" + username + "&password=" + password;
		    //   String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_test?user=" + username + "&password=" + password;
			
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);

			if (myConnection != null)
			{
				Statement st1 = myConnection.createStatement();
				String selectFiles = "select f.file_fullpath, f.file_size, file_type.id_category, c.name, IF(ISNULL(file_type.description),\"No Description\",file_type.description) as description from file f left outer join file_type on f.id_file_type = file_type.id left outer join category c on file_type.id_category = c.id where f.id_run_sample =" + lib.get("id_run_sample").getValue();
				System.out.println("The query that is executed is " + selectFiles);
				ResultSet rs1 = st1.executeQuery(selectFiles);

				Pattern pattern = Pattern.compile(".*/storage.+(flowcells|incoming|analysis)/");
				Matcher matcher;
				Pattern laneNumPattern = Pattern.compile("(s|" + lib.get("flowcell_serial").getValue() + ")_(\\d+)[\\._]+");
				Matcher laneNumMatcher;

				while (rs1.next())
				{
					String fullPath = rs1.getString("f.file_fullpath");
					String type = rs1.getString("c.name");
					String description = rs1.getString("description");
					String size = rs1.getString("f.file_size");
					FileData file = new FileData();
					matcher = pattern.matcher(fullPath);

					if (matcher.find())
					{

						file.setName(getFileName(fullPath));
						file.setFullPath(fullPath);
						if (type == null)
							file.setType("Unknown");
						else
							file.setType(type);
						file.setLocation(fullPath.substring(matcher.end(), fullPath.lastIndexOf('/')));
						file.setDownloadLocation(encryptURLEncoded(fullPath));

						laneNumMatcher = laneNumPattern.matcher(file.getName());
						if (laneNumMatcher.find())
							file.setLane(laneNumMatcher.group(2));
						else
							file.setLane("0");
                        file.setDescription(description);
                        
                        if (size != null) 
                             file.setSize(humanReadableByteCount(Long.parseLong(size), true));
                        else file.setSize("N/A");
						files.add(file);
					}
				}
				rs1.close();
				st1.close();
			}
		} catch (Exception e)
		{
			e.printStackTrace();
		} finally
		{
			try
			{
				myConnection.close();
			} catch (SQLException e)
			{
				e.printStackTrace();
			}
		}
		return files;
	}

	@Override
	public String createMergeWorkflow(List<LibraryData> libs)
	{
		String ret = "";
//		for(LibraryData lib : libs)
//		{
//			
//			String libLine = lib.get("sample_name").getValue().replace(" ", "-") + " " + new File(lib.get("analysis_id").getValue()).getParent() + "\n"; 
//			
//			ret += "#" + libLine;
//		}
//		
		
		
		
		try
		{
			String[] aCmdArgs = { "/opt/tomcat6/webapps/eccpgxt/helperscripts/createMergingWorkflow.pl"};
			Runtime oRuntime = Runtime.getRuntime();
			Process oProcess = null;

			oProcess = oRuntime.exec(aCmdArgs);
			//oProcess.waitFor();
			/* dump output stream */
			BufferedReader is = new BufferedReader(new InputStreamReader(oProcess.getInputStream()));
			OutputStreamWriter os = new OutputStreamWriter(oProcess.getOutputStream());
			for(LibraryData lib : libs)
			{
				String libLine = lib.get("sample_name").getValue().replace(" ", "-") + " " + new File(lib.get("analysis_id").getValue()).getParent() + "\n"; 
				os.write(libLine);
				ret += "#" + libLine;
			}
			os.flush();
			
			String line = null;
			while((line = is.readLine()) != null)
				ret += line + "\n";
			
			oProcess.waitFor();

		} catch (Exception e)
		{
			ret += "ERROR ENCOUNTERED\n";
			e.printStackTrace();
		}
		return ret;
	}

}
