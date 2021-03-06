package edu.usc.epigenome.eccp.server;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
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

import com.google.gson.Gson;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;

/**
 * The server side implementation of the RPC service.
 */

@SuppressWarnings("serial")
public class ECServiceBackend extends RemoteServiceServlet implements ECService
{
	
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
			String tempFcell = fcellAfterDecrypt.substring(0, fcellAfterDecrypt.length() - 32);
			logWriter("Word AfterDecrypt is " + fcellAfterDecrypt + "  Trimmed  tempFcell is " + tempFcell);

			// Check the decrypted value with the md5 value
			if (md5(tempFcell).equals(fcellAfterDecrypt.substring(fcellAfterDecrypt.length() - 32, fcellAfterDecrypt.length())))
			{
				logWriter("post md5   tempFcell is " + tempFcell);
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
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
    		
    		
    		Class.forName(prop.getProperty("dbDriver")).newInstance();
			// get database details from param file
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");

			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);

			// create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			// get the distinct analysis_id's for the given flowcell,
			// sample_name and lane number
			String selectQuery = "Select \n" + "	m.metric as metric, \n" + "	m.isNumeric as isNumeric, \n" + "	m.sort_order as sort_order,\n"
					+ "	IF(ISNULL(m.description),\"No Description\",m.description) as description,\n"
					+ "	IF(ISNULL(m.pretty_name),m.metric,m.pretty_name) as pretty_name,\n" + "	m.usage_enum as usage_enum,\n"
					+ "	IF(ISNULL(c.name),\"Unknown\",c.name) as category,  \n" + "	IF(ISNULL(f.parser),\"Unknown\",f.parser) as parser, "
					+ " m.qc_formula as qc_formula " 
					+ " from metric m left join category c on m.id_category = c.id left join file_type f on f.id = id_file_type\n" + " order by metric ";
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
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));

    		Class.forName(prop.getProperty("dbDriver")).newInstance();
			// get database details from param file
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");
			
			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);

			
			//build the where clause using the LibraryDataQuery specification
			String where = "WHERE ";
			if (queryParams.getDBid() != null)
				where += " v.id_run_sample = " + queryParams.getDBid() + " AND ";
			if (queryParams.getFlowcell() != null)
				where += " flowcell_serial LIKE '%" + queryParams.getFlowcell() + "%' AND ";

			//filter based upon user ldap group!
			HttpServletRequest request = this.getThreadLocalRequest();
			MultiMap<String> params = new MultiMap<String>();
			URL url = new URL(request.getHeader("referer"));
			if(url.getQuery() != null)
				UrlEncoded.decodeTo(url.getQuery(), params, "UTF-8");
			if (params.containsKey("t") || params.containsKey("q"))
			{
				String contents = "";
				if(params.containsKey("t"))
					contents += decryptTextMD5(params.getString("t"));
				if(params.containsKey("q"))
					contents += "  " + decryptTextMD5(params.getString("q"));
				if(contents.length() < 3)
					contents = "NOTHINGBUTGARBAGE";
				logWriter("URL PARAM DEC: " + contents);
				
				String columns = "";
				//ZR KLUDGE!!! we hardcode the exclusion of "formatted" metric columns from the view since mariadb fails when they are in a MATCH call. 
				String columnsQuery = "select group_concat(metric) as c from metric where ShowInSampleBrowser > 0 AND metric NOT LIKE '%ormatted%' order by ShowInSampleBrowser ASC";
				Statement stat = myConnection.createStatement();
				ResultSet results = stat.executeQuery(columnsQuery);
				if(results.next())
					columns = results.getString(1);
				
				where += "MATCH(" + columns + ") against ('+"+ contents + "' IN BOOLEAN MODE) AND ";
			}
			
			
			if (request != null && request.getUserPrincipal() != null)
			{
				// debug for user role checking
				if (request.isUserInRole(prop.getProperty("adminGroup")))
					logWriter(prop.getProperty("adminGroup"));
				if (request.isUserInRole(prop.getProperty("userGroup")))
					logWriter(prop.getProperty("userGroup"));
			
				//logWriter("Query:" + request.getQueryString());
				logWriter("URI:" + request.getRequestURL() + "  REF:" + request.getHeader("referer") );
				//logWriter("map size:" + request.getParameterMap().size());
				//logWriter("ref:" + request.getHeader("referer"));
				
				if(url.getQuery() != null)
					UrlEncoded.decodeTo(url.getQuery(), params, "UTF-8");
				if(request.isUserInRole(prop.getProperty("adminGroup")) && params.containsKey("superquery"))
					where += decryptTextMD5(params.getString("superquery")) + " AND ";
				
			}
			
			where += "0=0";         
			String columns =  " v.* ";
			if(queryParams.getIsSummaryOnly())
			{
				String columnsQuery = "select group_concat(metric) as c from metric where ShowInSampleBrowser > 0 order by ShowInSampleBrowser ASC";
				Statement stat = myConnection.createStatement();
				ResultSet results = stat.executeQuery(columnsQuery);
				if(results.next())
					columns = "v.id_run_sample, " + results.getString(1);
				else
					throw new Exception("");
			}
			
			// columns = queryParams.getIsSummaryOnly() ? " v.id_run_sample, geneusID_sample, analysis_id, flowcell_serial, lane, project, sample_name, processing_formatted, protocol, Date_Sequenced_formatted, if(count(distinct f.id_file_type) > 1, \"Analysis Avail\",  if(count(distinct f.id_file_type) < 1, \"Processing\", \"Reads Avail\")) as status " : " v.* ";				

			// create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			// Get all the distinct sample_names for the given projectName
			String selectQuery = "select " + columns + " from main_lib_view v left join file f on f.id_run_sample = v.id_run_sample and f.id_file_type IN (40,41,51,33,14,38,54) " + where + " group by v.id_run_sample ORDER BY Date_Sequenced_formatted DESC";
			logWriter("SQL Query: " + selectQuery);
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
						 	 //validation
						 	p.setValidation(qcTypes.get(p.getName()).get("qc_formula"));
					 	 }
					 	 else
					 	 {
			 		 		//ZR 140125 if there are always defaults, why not set them in the constructor 
			 		 		 //category
			 		 		 p.setCategory("Unknown");
							 //usage
						 	 p.setUsage("0");
							 //pretty_name
						 	 p.setPrettyName(p.getName());
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
			//load a properties file with db info
			Properties prop = new Properties();
			
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));

    		Class.forName(prop.getProperty("dbDriver")).newInstance();
			// get database details from param file
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");

			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);

			if (myConnection != null)
			{
				Statement st1 = myConnection.createStatement();
			//	String selectFiles = "select f.file_fullpath, f.file_size, file_type.id_category, c.name, IF(ISNULL(file_type.description),\"No Description\",file_type.description) as description from file f left outer join file_type on f.id_file_type = file_type.id left outer join category c on file_type.id_category = c.id where f.id_run_sample =" + lib.get("id_run_sample").getValue();
				String selectFiles = "select f.file_fullpath, f.file_size, IFNULL(t.id_category,0) as category, c.name, IFNULL(t.description,\"No Description\") as description from file f left outer join file_type t on f.file_fullpath RLIKE t.file_match_regex left outer join category c on t.id_category = c.id where f.id_run_sample =" + lib.get("id_run_sample").getValue();				
				logWriter("SQL Query: " + selectFiles);
				ResultSet rs1 = st1.executeQuery(selectFiles);

				Pattern pattern = Pattern.compile(".*/storage.+(flowcells|incoming|analysis|merges|external_analysis)/");
				Matcher matcher;
				Pattern laneNumPattern = Pattern.compile("(s|" + lib.get("flowcell_serial").getValue() +")_(\\d+)[\\._]+");
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
						file.setLocation(fullPath.substring(matcher.end(), fullPath.lastIndexOf('/')));
						file.setDownloadLocation(encryptURLEncoded(fullPath));
						
						/* Set types and descriptions for files:
						   Filter out bam/bai from all matched NC_001416 files and assign to "006. Lambda Control Files"
						   Assign all the rest of NC_001416 files to "008. Intermediate internal pipeline files" 
						   and set one description for all NC_001416 files
						*/
						String fileName = file.getName();
						fileName = fileName.replaceAll("(\\r|\\n|\\s)", "");
						if (fileName.matches(".*NC_001416.*")) {
							if (fileName.matches(".*NC_001416\\.fa(\\.mdups)?\\.bam(\\.bai)?$")) {
								 file.setType("006. Lambda Control Files");	

							}
							   else file.setType("008. Intermediate internal pipeline files");
							   file.setDescription("Lambda control alignments (QC only)");
						}
						else {
							   if (type == null) file.setType("Unknown");
						       else file.setType(type);						       
		                       file.setDescription(description);
						}

						laneNumMatcher = laneNumPattern.matcher(file.getName());
						if (laneNumMatcher.find())
							file.setLane(laneNumMatcher.group(2));
						else
							file.setLane("0");
                        
                        if (size != null) 
                             file.setSize(humanReadableByteCount(Long.parseLong(size), true));
                        else file.setSize("N/A");
                        boolean fileDuplicate=false;
                        
                        for (FileData f: files) {
                        	if (file.getFullPath().equals(f.getFullPath()))
                        		fileDuplicate=true;
                        }
						if (!fileDuplicate) files.add(file);
						
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
			
			String[] aCmdArgs = { "/var/lib/tomcat/webapps/eccpgxt/helperscripts/createMergingWorkflow.pl"};
			Runtime oRuntime = Runtime.getRuntime();
			Process oProcess = null;
			
			oProcess = oRuntime.exec(aCmdArgs);			
			//oProcess.waitFor();
			/* dump output stream */
			BufferedReader is = new BufferedReader(new InputStreamReader(oProcess.getInputStream()));
			OutputStreamWriter os = new OutputStreamWriter(oProcess.getOutputStream());
			
			String line = null;
			
			
			for(LibraryData lib : libs)
			{
				String libLine = lib.get("sample_name").getValue().replace(" ", "-") + " " + new File(lib.get("analysis_id").getValue()).getParent() + "\n"; 
				os.write(libLine);
				ret += "#" + libLine;
			}
			os.flush();
			os.close();
		
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

	@Override
	public String getLibrariesJSON(LibraryDataQuery queryParams)
	{
		Gson gson = new Gson();
		return gson.toJson(getLibraries(queryParams));
	}

	//get the workflow params or illumina casava params for a flowcell
	
	public String getIlluminaParams(String flowcell_serial)
	{
		String paramText = "";
		java.sql.Connection myConnection = null;
		try
		{
			//load a properties file with db info
			Properties prop = new Properties();
			
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));

    		Class.forName(prop.getProperty("dbDriver")).newInstance();
			// get database details from param file
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");

			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);

			if (myConnection != null)
			{
				
				String selectQuery ="select flowcell_serial, lane, geneusID_sample, sample_name, barcode, sample_name, ControlLane, processing_formatted, technician from main_lib_view where flowcell_serial ='"+flowcell_serial + "' group by geneusID_sample, lane order by lane";
				Statement stat = myConnection.createStatement();
				ResultSet results = stat.executeQuery(selectQuery);
				int cols = results.getMetaData().getColumnCount();

				paramText += "FCID" + "," + "Lane" + "," + "SampleID" + "," + "SampleRef" + "," + "Index"  + "," + "Description" + "," + "Control" + "," +"Recipe" + "," + "Operator\n";
				while(results.next())
				{
					for(int i=1;i<=cols;i++)
					{
						if(i == 8)
							paramText +="Unknown";
						else
							paramText += results.getString(i);
						paramText += ",";
					}
					paramText += "\n";
				}
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
		return paramText;
	}
	
	public String getWorkflowParams(String  flowcell_serial)
	{
		String paramText = "";
		java.sql.Connection myConnection = null;
		try
		{
			//load a properties file with db info
			Properties prop = new Properties();
			
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));

    		Class.forName(prop.getProperty("dbDriver")).newInstance();
			// get database details from param file
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");

			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);

			if (myConnection != null)
			{
				
				String selectQuery ="select geneusID_sample, lane, sample_name, barcode,  project, processing_formatted, protocol, organism from main_lib_view where flowcell_serial ='"+flowcell_serial + "' group by geneusID_sample, lane order by lane";
				Statement stat = myConnection.createStatement();
				ResultSet results = stat.executeQuery(selectQuery);
			
								
				int i=0;
			
				paramText += "ClusterSize = 1" + "\n" + "queue = laird" + "\n" + "FlowCellName = " + flowcell_serial + "\n" +  "MinMismatches = 2 " + "\n" + "MaqPileupQ = 30" + "\n" + "referenceLane = 1 " + "\n" + "randomSubset = 300000\n";
				while(results.next())
				{
					paramText += "\n";
					i++;
					paramText += "#Sample: " + results.getString("sample_name") + " (" + results.getString("project") + " of " + results.getString("organism") +")\n";
					paramText += "Sample."+ i + ".SampleID = " + results.getString("geneusID_sample") + "\n";
					String lane = results.getString("lane");
					String barcode = results.getString("barcode");
					paramText += "Sample."+ i + ".Lane = " + lane + "\n";
					
					if(results.getString("protocol").toLowerCase().contains("paired") || results.getString("protocol").toLowerCase().contains("pe"))
					{
						if(results.getString("protocol").toLowerCase().contains("next"))
							paramText += "Sample."+ i + ".Input = " + results.getString("sample_name") + "_L000_R1_001.fastq.gz," + results.getString("sample_name") + "_L000_R2_001.fastq.gz\n";
						else if(results.getString("barcode").contains("NO BARCODE"))
							paramText += "Sample."+ i + ".Input = " + results.getString("sample_name") + "_NoIndex_L00" + lane + "_R1_001.fastq.gz," + results.getString("sample_name") + "_NoIndex_L00" + lane + "_R2_001.fastq.gz\n";
						else
							paramText += "Sample."+ i + ".Input = " + results.getString("sample_name") + "_" + barcode + "_L00" + lane + "_R1_001.fastq.gz," + results.getString("sample_name") + "_" + barcode + "_L00" + lane + "_R2_001.fastq.gz\n";
					}
					else if(results.getString("protocol").toLowerCase().contains("single") || results.getString("protocol").toLowerCase().contains("sr"))
					{
						if(results.getString("protocol").toLowerCase().contains("next"))
							paramText += "Sample."+ i + ".Input = " + results.getString("sample_name") + "_L000_R1_001.fastq.gz\n";
						else if(results.getString("barcode").contains("NO BARCODE"))
							paramText += "Sample."+ i + ".Input = " + results.getString("sample_name") + "_NoIndex_L00" + lane + "_R1_001.fastq.gz\n";
						else
							paramText += "Sample."+ i + ".Input = " + results.getString("sample_name") + "_" + barcode + "_L00" + lane + "_R1_001.fastq.gz\n";
					}
					else
					{
						paramText += "Sample."+ i + ".Input = " + results.getString("sample_name") + "_" + barcode + "_L00" + lane + "_R1_001.fastq.gz\n";
					}
					
					String workflow = "unaligned";
					String genome = "/home/uec-00/shared/production/genomes/unaligned/unaligned.fa";
					
					if(results.getString("processing_formatted").toLowerCase().contains("chip"))
						workflow = "chipseq";
					else if(results.getString("processing_formatted").toLowerCase().contains("bs") || results.getString("processing_formatted").toLowerCase().contains("sulfit"))
						workflow = "bisulfite";
					else if(results.getString("processing_formatted").toLowerCase().contains("rna"))
						workflow = "rnaseqv2";
					else if(results.getString("processing_formatted").toLowerCase().contains("genom") || results.getString("processing_formatted").toLowerCase().contains("regul"))
						workflow = "regular";
					
					if(results.getString("organism").toLowerCase().contains("mus"))
						genome = "/home/uec-00/shared/production/genomes/mm10/mm10.fa";
					else if(results.getString("organism").toLowerCase().contains("phi"))
						genome = "/home/uec-00/shared/production/genomes/phi-X174/phi_plus_SNPs.fa";
					else if(results.getString("organism").toLowerCase().contains("phi"))
						genome = "/home/uec-00/shared/production/genomes/phi-X174/phi_plus_SNPs.fa";
					else if(results.getString("organism").toLowerCase().contains("rabidop"))
						genome = "/home/uec-00/shared/production/genomes/arabidopsis/tair8.pluscontam.fa";
					else if(results.getString("organism").toLowerCase().contains("gallus"))
						genome = "/home/uec-00/shared/production/genomes/chicken/Gallus_gallus.WASHUC2.68.dna.toplevel.fa";
					//handle human
					else if(results.getString("organism").toLowerCase().contains("homo") || results.getString("organism").toLowerCase().contains("human"))
					{
						if(results.getString("processing_formatted").toLowerCase().contains("bs") || results.getString("processing_formatted").toLowerCase().contains("sulfit"))
							genome = "/home/uec-00/shared/production/genomes/hg19_rCRSchrm/hg19_rCRSchrm.fa";							
						else
							genome = "/home/uec-00/shared/production/genomes/encode_hg19_mf/male.hg19.fa";
					}
					
					//handle rnaseq genomes
					if(results.getString("processing_formatted").toLowerCase().contains("rna"))
						genome = genome.substring(0, genome.length() - 3);
					
					paramText += "Sample."+ i + ".Workflow = " + workflow + "\n";
					paramText += "Sample."+ i + ".Reference = " + genome + "\n";
				}
				paramText += "\n";			
			
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
		return paramText;
	}

	public String getTimestamp() {
        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("MM/dd/yy H:mm:ss");
        java.util.Date currentDate= new java.util.Date();
		return formatter.format(currentDate);
		
	}
	
	public String logWriter(HttpServletRequest request, String text) 
	{
		String userID = "unknown";
		String site = "unknown";
		String ip = "unknown";
		if (request != null && request.getUserPrincipal() != null)
			userID=request.getUserPrincipal().getName();
		if (request != null && request.getRequestURI() != null)
		{
			if(request.getRequestURI().contains("beta"))
				site="ecdp-beta";
			else if(request.getRequestURI().contains("alpha"))
				site="ecdp-alpha";
			else if(request.getRequestURI().contains("demo"))
				site="ecdp-demo";
			else if(request.getRequestURI().contains("eccp"))
				site="ecdp";
			else if(request.getRequestURI().contains("garepo"))
				site="gareports";
		}
		if(request != null && request.getRemoteAddr() != null)
			ip =  request.getRemoteAddr();
		      
		System.out.println(getTimestamp() + " " +  "User:" + userID +"@" + ip + " Site:" + site + "\t" + text);
		return null; //return null since gwt asyncs need a return val
	}
	
	public String logWriter(String text) 
	{
		this.logWriter(this.getThreadLocalRequest(), text);
		return null; //return null since gwt asyncs need a return val
	}

	//get a list of the summary-only columns used for browsing the list of samples
	@Override
	public ArrayList<LibraryProperty> getSummaryColumns() 
	{
		java.sql.Connection myConnection = null;
		ArrayList<LibraryProperty> columns = new ArrayList<LibraryProperty>();
		try{
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
			// get database details from param file
			Class.forName(prop.getProperty("dbDriver")).newInstance();
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");
	
			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);
	
			if (myConnection != null)
			{
				String columnsQuery = "select metric, pretty_name, description from metric where ShowInSampleBrowser > 0 order by ShowInSampleBrowser ASC";
				Statement stat = myConnection.createStatement();
				ResultSet results = stat.executeQuery(columnsQuery);
				while(results.next())
				{
					LibraryProperty l = new LibraryProperty();
					l.setName(results.getString(1));
					l.setPrettyName(results.getString(2));
					l.setDescription(results.getString(3));
					l.setValue("NULL");
					columns.add(l);
				}
			}
		}	catch(Exception e)
		{
			e.printStackTrace();
		}
		return columns;
	}
	
	//insert a new analysis and return the id;
	public int insertAnalysis(String ExperimentID,String SampleID, String AnalysisID)
	{
		int rsid = -1;
		java.sql.Connection myConnection = null;
		try{
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
			// get database details from param file
			Class.forName(prop.getProperty("dbDriver")).newInstance();
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");
	
			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);
	
			if (myConnection != null)
			{
				String queryString = "CALL insert_lane(?,?,?)";
				PreparedStatement query = myConnection.prepareStatement(queryString);
				query.setString(1, ExperimentID);
				query.setString(2, SampleID);
				query.setString(3, AnalysisID);
				ResultSet results = query.executeQuery();
				
				while(results.next())
					rsid = results.getInt(1);
				
			}
		}	catch(Exception e)
		{
			e.printStackTrace();
		}
		return rsid;
	}
	
	public void insertMetric(int ResultSetID, String metricName, String metricValue)
	{
		java.sql.Connection myConnection = null;
		try{
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
			// get database details from param file
			Class.forName(prop.getProperty("dbDriver")).newInstance();
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");
	
			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);
	
			if (myConnection != null)
			{
				String queryString = "CALL insert_metric(?,?,?)";
				PreparedStatement query = myConnection.prepareStatement(queryString);
				query.setInt(1, ResultSetID);
				query.setString(2, metricName);
				query.setString(3, metricValue);
				query.executeUpdate();
			}
		}	catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	public void insertMetric(int ResultSetID, String metricName, String metricValue,int fileID)
	{
		java.sql.Connection myConnection = null;
		try{
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
			// get database details from param file
			Class.forName(prop.getProperty("dbDriver")).newInstance();
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");
	
			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);
	
			if (myConnection != null)
			{
				String queryString = "CALL Ninsert_metric(?,?,?,?,?,?,?)";
				PreparedStatement query = myConnection.prepareStatement(queryString);
				query.setInt(1, ResultSetID);
				query.setString(2, metricName);
				query.setString(3, metricValue);
				query.setInt(4, 4); ///default category if metric does not exist
				query.setInt(5, 11); //default type if file_type does not exist
				query.setInt(6, fileID);
				query.setInt(7, 0); // not used, so 0
				query.executeUpdate();
			}
		}	catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	public int insertFileURI(String Path, int ResultSetID, long fileSize)
	{
		int fileId = -1;
		java.sql.Connection myConnection = null;
		try{
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
			// get database details from param file
			Class.forName(prop.getProperty("dbDriver")).newInstance();
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");
	
			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);
	
			if (myConnection != null)
			{
				String queryString = "CALL Ninsert_file(?,?,?)";
				PreparedStatement query = myConnection.prepareStatement(queryString);
				query.setString(1, Path);
				query.setInt(2, ResultSetID);
				query.setLong(3, fileSize);
				ResultSet results = query.executeQuery();
				
				while(results.next())
					fileId = results.getInt(1);
			}
		}	catch(Exception e)
		{
			e.printStackTrace();
		}
		return fileId;
	}
	public void deleteAnalysis(String AnalysisID)
	{
		java.sql.Connection myConnection = null;
		try{
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
			// get database details from param file
			Class.forName(prop.getProperty("dbDriver")).newInstance();
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");
	
			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);
	
			if (myConnection != null)
			{
				String queryString = "delete from run_sample where analysis_id = ?";
				PreparedStatement query = myConnection.prepareStatement(queryString);
				query.setString(1, AnalysisID);
				query.executeUpdate();
			}
		}	catch(Exception e)
		{
			e.printStackTrace();
		}
	}
	public void generateDB()
	{
		java.sql.Connection myConnection = null;
		try{
			//load a properties file with db info
			Properties prop = new Properties();
			prop.load(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.properties"));
			// get database details from param file
			Class.forName(prop.getProperty("dbDriver")).newInstance();
			String username = prop.getProperty("dbUserName");
			String password = prop.getProperty("dbPassword");
	
			// URL to connect to the database
			String dbURL = prop.getProperty("dbConnetion") + username + "&password=" + password;
		
			// create the connection
			myConnection = DriverManager.getConnection(dbURL);
	
			if (myConnection != null)
			{
				String queryString = "call run_metric_dynamic_crosstab()";
				PreparedStatement query = myConnection.prepareStatement(queryString);
				query.setQueryTimeout(3600);
				query.executeUpdate();
			}
		}	catch(Exception e)
		{
			e.printStackTrace();
		}
	}
}
