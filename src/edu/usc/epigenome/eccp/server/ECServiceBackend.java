package edu.usc.epigenome.eccp.server;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.MethylationData;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;


/**
 * The server side implementation of the RPC service.
 */
@SuppressWarnings("serial")
public class ECServiceBackend extends RemoteServiceServlet implements ECService
{

	public ArrayList<FlowcellData> getFlowcellsAll() throws IllegalArgumentException
	{
		ArrayList<FlowcellData> flowcellsFS = getFlowcellsFromFS();
		ArrayList<FlowcellData> flowcellsGeneus = getFlowcellsFromGeneus();
		ArrayList<FlowcellData> flowcellsAll = new ArrayList<FlowcellData>();
		HashMap<String,Boolean> fcFound = new HashMap<String,Boolean>();
		
		for(FlowcellData g : flowcellsGeneus)
		{
			flowcellsAll.add(g);
			fcFound.put(g.getFlowcellProperty("serial"),true);			
		}
		for(FlowcellData g : flowcellsFS)
		{
			if(!fcFound.containsKey(g.getFlowcellProperty("serial")) && g.getFlowcellProperty("status").contains("run complete"))
			{
				fcFound.put(g.getFlowcellProperty("serial"),true);
				flowcellsAll.add(g);
			}
		}
		for(FlowcellData g : flowcellsFS)
		{
			if(!fcFound.containsKey(g.getFlowcellProperty("serial")))		
			{
				fcFound.put(g.getFlowcellProperty("serial"),true);
				flowcellsAll.add(g);
			}
		}
		
		Collections.sort(flowcellsAll, new Comparator<FlowcellData>()
		{
			public int compare(FlowcellData o2, FlowcellData o1)
			{
				return o1.getFlowcellProperty("date").compareTo(o2.getFlowcellProperty("date"));
			}
		});
		
		return flowcellsAll;
		
	}
	
	public ArrayList<FlowcellData> getFlowcellsFromGeneusFiles() throws IllegalArgumentException
	{
		ArrayList<FlowcellData> flowcells = new ArrayList<FlowcellData>();
		try
		{
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			String[] qcCommand = {"/opt/tomcat6/webapps/ECCP/helperscripts/flowcell.pl"};
			Process execQc = Runtime.getRuntime().exec(qcCommand);
			InputStream inputStream = execQc.getInputStream();
			
			Document document = db.parse(inputStream);
			NodeList flowcellNodeList = document.getElementsByTagName("flowcell");
			for(int i = 0; i < flowcellNodeList.getLength(); i++)
			{
				Node flowcellNode = flowcellNodeList.item(i);
				FlowcellData flowcell = new FlowcellData();
				for(int j = 0; j < flowcellNode.getAttributes().getLength(); j++)
				{
					flowcell.flowcellProperties.put(flowcellNode.getAttributes().item(j).getNodeName(), flowcellNode.getAttributes().item(j).getNodeValue());
				}
				flowcell.flowcellProperties.put("status", "in geneus");
				
				NodeList sampleNodeList =flowcellNode.getChildNodes();
				for(int j = 0; j < sampleNodeList.getLength(); j++)
				{
					Node sampleNode = sampleNodeList.item(j);
					HashMap<String,String> sampleData = new HashMap<String,String>();
					for(int k = 0; k < sampleNode.getAttributes().getLength(); k++)
					{
						sampleData.put(sampleNode.getAttributes().item(k).getNodeName(), sampleNode.getAttributes().item(k).getNodeValue());
					}
					flowcell.lane.put(Integer.parseInt(sampleNode.getAttributes().getNamedItem("lane").getNodeValue()), sampleData);					
				}
				
				flowcells.add(flowcell);
			}
			inputStream.close();			
		}
		catch (Exception e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Collections.sort(flowcells, new Comparator<FlowcellData>()
		{
			public int compare(FlowcellData o2, FlowcellData o1)
			{
				return o1.getFlowcellProperty("date").compareTo(o2.getFlowcellProperty("date"));
			}
		});
		return flowcells;
		
	}
	/*
	 * Get flowcells from Geneus information from the database
	 */
	public ArrayList<FlowcellData> getFlowcellsFromGeneus() throws IllegalArgumentException
	{
		ArrayList<FlowcellData> flowcells = new ArrayList<FlowcellData>();
		java.sql.Connection myConnection = null;
		DataSource ds = null;
		try
		{
			//Class.forName("com.mysql.jdbc.Driver").newInstance(); 
			Context initCtx = new InitialContext();
			Context ctx = (Context)initCtx.lookup("java:/comp/env");

			if(ctx == null)
				throw new Exception("Context is null");
			
			ds = (DataSource)ctx.lookup("jdbc/sequencing");
			
			if(ds != null)
				myConnection  = ds.getConnection();
			
				if(myConnection != null)
				{
					Statement stat = myConnection.createStatement();
					//Get all the distinct geneusId's 
					String selectQuery ="select distinct(geneusID_run) from sequencing.view_run_metric";
					ResultSet results = stat.executeQuery(selectQuery);
				
					//Iterate over the resultset consisting of GeneusID(limsid)
				  if(results.next())
				  {
				   do
					 {
						FlowcellData flowcell = new FlowcellData();
						String lims_id = results.getString("geneusId_run");
						Statement st1 = myConnection.createStatement();
						//for each geneusid get the flowcell serial no, protocol, technician, the date and the control lane 
						String innSelect = "select distinct flowcell_serial, protocol, technician, Date_Sequenced, ControlLane from sequencing.view_run_metric where geneusID_run ='"+lims_id + "' group by geneusId_run";            
						ResultSet rs = st1.executeQuery(innSelect);
						//Iterate over the resultset and add the flowcellproperties for each of the flowcells
						while(rs.next())
						{
							flowcell.flowcellProperties.put("serial", rs.getString("flowcell_serial"));
							flowcell.flowcellProperties.put("limsID", lims_id);
							flowcell.flowcellProperties.put("technician", rs.getString("technician").replace("å", ""));
							  
							if(rs.getString("Date_Sequenced") == null || rs.getString("Date_Sequenced").equals(""))
								flowcell.flowcellProperties.put("date", "Unknown");
							else
							{
								Date d = new Date(rs.getString("Date_Sequenced"));
								flowcell.flowcellProperties.put("date", (1900 + d.getYear())  + "-" + String.format("%02d",d.getMonth() + 1) + "-" + String.format("%02d",d.getDate()));
							}
			   
							flowcell.flowcellProperties.put("protocol", rs.getString("protocol"));
							flowcell.flowcellProperties.put("status","in geneus");
							flowcell.flowcellProperties.put("control", rs.getString("ControlLane"));
						}
						rs.close();
						st1.close();
						
						//Select distinct lanes for each of the flowcells
						Statement statLane = myConnection.createStatement();
						String LaneProp ="select distinct(lane) from sequencing.view_run_metric where geneusID_run ='"+lims_id+"'";
						ResultSet RsProp = statLane.executeQuery(LaneProp);	
						//Iterate over the lane numbers 
						while(RsProp.next())
						{
							int lane_no =  RsProp.getInt("lane");
							HashMap<String,String> sampleData = new HashMap<String,String>();
							Statement cellprop = myConnection.createStatement();
							//for each lane of a flowcell get the processing, sample_name, organism and project associated with it.
							String st2 ="select processing, sample_name, geneusID_sample, organism, project from sequencing.view_run_metric where geneusID_run ='"+lims_id+"' and lane ="+ lane_no;
							ResultSet Prop = cellprop.executeQuery(st2);
							
							//Iterate over the information and populate the lane information
							while(Prop.next())
							{
								sampleData.put("processing", Prop.getString("processing"));
								String sample_name = Prop.getString("sample_name");
								String sampleID = Prop.getString("geneusID_sample");
								String organism = Prop.getString("organism");
								if(sampleData.containsKey("name"))
								{
									String tempName = sampleData.get("name");
									if(!(tempName.contains(sample_name)))
										sampleData.put("name", sampleData.get("name").concat("+").concat(sample_name));
								}
								else
									sampleData.put("name", sample_name);
								
								if(sampleData.containsKey("organism"))
								{
									String tempOrg = sampleData.get("organism");
									if(!(tempOrg.contains(organism)))
										sampleData.put("organism", sampleData.get("organism").concat("+").concat(organism));
								}
								else
									sampleData.put("organism", Prop.getString("organism"));
								
								if(sampleData.containsKey("sampleID"))
								{
									String tempSampleID = sampleData.get("sampleID");
									if(!(tempSampleID.contains(sampleID)))
										sampleData.put("sampleID", sampleData.get("sampleID").concat("+").concat(sampleID));
								}
								else
									sampleData.put("sampleID", sampleID);
								
							    	sampleData.put("project", Prop.getString("project"));
							}
							Prop.close();
							cellprop.close();
							flowcell.lane.put(lane_no, sampleData);	
					   }
						RsProp.close();
						statLane.close();
						//add each of the flowcell to the arraylist
						flowcells.add(flowcell);
					
					}while(results.next());
			    
				   results.close();
				   stat.close();
				 }
				  else
			   		{
					  System.out.println("In the else clause for FLOWCELLS");
					  flowcells = getFlowcellsFromGeneusFiles();
			   		}
			  }
			 else
			 {
				System.out.println("In the else clause for FLOWCELLS");
				 flowcells = getFlowcellsFromGeneusFiles();
			 }
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			try {
				myConnection.close();
			 } catch (SQLException e) {
				e.printStackTrace();
			 }
		}
		return flowcells;	
	}
	
	@SuppressWarnings("deprecation")
	public ArrayList<FlowcellData> getFlowcellsFromFS() throws IllegalArgumentException
	{
		File[] dirs = {new File("/storage/hsc/gastorage1/slxa/incoming"),new File("/storage/hsc/gastorage2/slxa/incoming")};
		ArrayList<FlowcellData> flowcells = new ArrayList<FlowcellData>();
		
		FilenameFilter filter = new FilenameFilter()
		{
			public boolean accept(File dir, String name)
			{
				return ((name.toUpperCase().contains("AAXX") || name.toUpperCase().contains("ABXX")) && !name.contains(".")); 
			}
		};
		
		for(File dir : dirs)
		{
			System.out.println(dir.getPath());
			for (File run : dir.listFiles(filter))
			{
				System.out.println(run.getPath());
				FlowcellData flowcell = new FlowcellData();
				try
				{
					Pattern serialPattern = Pattern.compile("(\\w{5}A[AB]XX)");
					Matcher serialMatcher = serialPattern.matcher(run.getName());
					if(run.isDirectory() && serialMatcher.find())
					{
						System.out.println(serialMatcher.group(1));
						flowcell.flowcellProperties.put("serial", serialMatcher.group(1));
						Date d = new Date(run.lastModified());
						flowcell.flowcellProperties.put("date", (1900 + d.getYear())  + "-" + String.format("%02d",d.getMonth() + 1) + "-" + String.format("%02d",d.getDate()));
						flowcell.flowcellProperties.put("limsID", "N/A (" + run.getName() + ")");
						flowcell.flowcellProperties.put("status", "run incomplete or in progress");
						for(String fileName : run.list())
						{
							if(fileName.toLowerCase().contains("run.completed"))
							{
								flowcell.flowcellProperties.put("status", "run complete");
							}
						}
						flowcells.add(flowcell);
					}
				}
				catch (Exception e)
				{
					System.out.println(e.getMessage());					
				}
			}
		}
		Collections.sort(flowcells, new Comparator<FlowcellData>()
				{
					public int compare(FlowcellData o2, FlowcellData o1)
					{
						return o1.getFlowcellProperty("date").compareTo(o2.getFlowcellProperty("date"));
					}
				});
		return flowcells;
	}

	public ArrayList<FlowcellData> getFlowcellsIncomplete() throws IllegalArgumentException
	{
		ArrayList<FlowcellData> flowcellsAll = getFlowcellsAll();
		ArrayList<FlowcellData> flowcellsIncomplete = new ArrayList<FlowcellData>();
		for(FlowcellData f : flowcellsAll)
		{
			if(f.getFlowcellProperty("status").contains("incomplete"))
				flowcellsIncomplete.add(f);
		}
		
		Collections.sort(flowcellsIncomplete, new Comparator<FlowcellData>()
				{
					public int compare(FlowcellData o2, FlowcellData o1)
					{
						return o1.getFlowcellProperty("date").compareTo(o2.getFlowcellProperty("date"));
					}
				});
		return flowcellsIncomplete;
	}
	
	public FlowcellData getQCforFlowcellFiles(String serial) throws IllegalArgumentException
	{
		FlowcellData flowcell = new FlowcellData();
		try
		{
			String[] qcCommand = {"/opt/tomcat6/webapps/ECCP/helperscripts/report.pl", serial,"qc"};
			Process execQc = Runtime.getRuntime().exec(qcCommand);
			InputStream inputStream = execQc.getInputStream();
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			Document document = db.parse(inputStream);
		
			NodeList qcReportListNodes = document.getElementsByTagName("qcreport");
			for(int i = 0; i < qcReportListNodes.getLength(); i++)
			{				
				LinkedHashMap<Integer,LinkedHashMap<String,String>> qcReport = new LinkedHashMap<Integer,LinkedHashMap<String,String>>();
				Node qcReportNode = qcReportListNodes.item(i);
				String location = qcReportNode.getAttributes().getNamedItem("path").getNodeValue();
				NodeList qcLaneListNodes = qcReportNode.getChildNodes();
				for(int j = 0; j < qcLaneListNodes.getLength(); j++)
				{
					Node qcEntry = qcLaneListNodes.item(j);
					NodeList qcLanePropertyListNodes = qcEntry.getChildNodes();
					LinkedHashMap<String,String> qcProperties = new LinkedHashMap<String,String>();
					for(int k = 0; k < qcLanePropertyListNodes.getLength(); k++)
					{
						Node qcProperty = qcLanePropertyListNodes.item(k);
						qcProperties.put(qcProperty.getNodeName(), qcProperty.getFirstChild().getNodeValue());
						System.out.println(qcProperty.getNodeName() + " " + qcProperty.getFirstChild().getNodeValue());
					}				
					qcReport.put(Integer.parseInt(qcProperties.get("laneNum")), qcProperties);					
				}
				flowcell.laneQC.put(location, qcReport);				
				
			}
			inputStream.close();			
		}
		catch (Exception e)
		{
						e.printStackTrace();
						System.out.println(e.getMessage());
		}
		return flowcell;
	}
	
	public FlowcellData getQCforFlowcell(String serial) throws IllegalArgumentException
	{
		FlowcellData flowcell = new FlowcellData();
		java.sql.Connection myConnection = null;
		try
		{
			Context initContext = new InitialContext();
			Context envContext = (Context)initContext.lookup("java:/comp/env");
			DataSource ds = (DataSource)envContext.lookup("jdbc/sequencing");
			
			if(envContext == null)
				throw new Exception("Error: NO Context");
			
			if(ds == null)
				throw new Exception("Error: No DataSource");
			
			if(ds != null)
				myConnection = ds.getConnection();
			
			if(myConnection != null)
			{
				//create statement handle for executing queries
				Statement stat = myConnection.createStatement();
				//get the distinct analysis_id's for the given flowcell
				String selectQuery ="select distinct(analysis_id) from sequencing.view_run_metric where flowcell_serial = '"+serial + "' and Date_Sequenced !='NULL' and analysis_id not REGEXP '^\\/storage.+(analysis)' order by analysis_id";
				ResultSet results = stat.executeQuery(selectQuery);
			
				//Iterate over the result set
				if(results.next())
				{
					do	
					{
						String analysis_id = results.getString("analysis_id");
						//System.out.println("analysis_id is " + analysis_id);
						Statement st1 = myConnection.createStatement();
						//for each analysis_id get the QC information from the database
						String innSelect = "select  * from sequencing.view_run_metric where analysis_id ='" +  analysis_id + "'and Date_Sequenced !='NULL' group by lane";
						ResultSet rs = st1.executeQuery(innSelect);
						ResultSetMetaData rsMetaData = rs.getMetaData();
				
						LinkedHashMap<Integer,LinkedHashMap<String,String>> qcReport = new LinkedHashMap<Integer,LinkedHashMap<String,String>>();
						while(rs.next())
						{
							LinkedHashMap<String,String> qcProperties = new LinkedHashMap<String,String>();
							qcProperties.put("lane", rs.getString("lane"));
							qcProperties.put("geneusID_sample", rs.getString("geneusID_sample"));
							for(int i = 5; i<=rsMetaData.getColumnCount();i++)
							{
								if(rsMetaData.getColumnTypeName(i).equals("VARCHAR"))
								{
									if(rs.getString(i) == null || rs.getString(i).equals(""))
										qcProperties.put(rsMetaData.getColumnName(i),"NA");
									else
										qcProperties.put(rsMetaData.getColumnName(i), rs.getString(i));
								}
								else
								{
									if(rs.getString(i) == null || rs.getString(i).equals(""))
										qcProperties.put(rsMetaData.getColumnName(i),"0");
									else
										qcProperties.put(rsMetaData.getColumnName(i),NoFormat(rs.getString(i)));
								}
							}
							qcReport.put(rs.getInt("lane"), qcProperties);
						}
						rs.close();
						st1.close();
						//add the qcReport LinkedHashmap to the flowcell laneQC	
						flowcell.laneQC.put(analysis_id, qcReport);
					}while(results.next());
					results.close();
					stat.close();
				}
				else
				{
					System.out.println("In the else clause for QC");
					flowcell = getQCforFlowcellFiles(serial);
				}
			}
			else
			{
				System.out.println("In the else clause for QC");
				flowcell = getQCforFlowcellFiles(serial);
			}
	  }catch( Exception E ){ 
		 System.out.println( E.getMessage());	
	  	}			
	  	finally
	  	{
	  		try
	  		{
			myConnection.close();
	  		}
	  		catch (SQLException e) 
	  		{
	  			e.printStackTrace();
	  		}
	  	}
	    return flowcell;
   }
	
	
	public FlowcellData getFilesforFlowcellOld(String serial) throws IllegalArgumentException
	{
		FlowcellData flowcell = new FlowcellData();
		try
		{
			String[] qcCommand = {"/opt/tomcat6/webapps/ECCP/helperscripts/report.pl", serial};
			Process execQc = Runtime.getRuntime().exec(qcCommand);
			InputStream inputStream = execQc.getInputStream();
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db;
			
			db = dbf.newDocumentBuilder();
			//URL url = new URL("http://www.epigenome.usc.edu/gareports/report.php?flowcell=" + serial + "&xmlfiles");
			//InputStream inputStream = url.openStream();
			Document document = db.parse(inputStream);
			NodeList qcFileList = document.getElementsByTagName("file");
			for(int i = 0; i < qcFileList.getLength(); i++)
			{
				Node qcFile = qcFileList.item(i);
				LinkedHashMap<String,String> qcFileProperties = new LinkedHashMap<String,String>();				
				for(int j = 0; j < qcFile.getAttributes().getLength(); j++)
				{
					qcFileProperties.put(qcFile.getAttributes().item(j).getNodeName(), qcFile.getAttributes().item(j).getNodeValue());
				}
				Pattern laneNumPattern = Pattern.compile("s_(\\d+)[\\._]+");
				Matcher laneNumMatcher = laneNumPattern.matcher(qcFileProperties.get("base"));
				qcFileProperties.put("encfullpath",  encryptURLEncoded(qcFileProperties.get("fullpath")));
				if(laneNumMatcher.find())
					qcFileProperties.put("lane", laneNumMatcher.group(1));
				else
					qcFileProperties.put("lane", "0");
				flowcell.fileList.add(qcFileProperties);
			}
			inputStream.close();			
		}
		catch (Exception e)
		{
						e.printStackTrace();
		}
		return flowcell;
	}
	
	
	public FlowcellData getFilesforFlowcell(String serial) throws IllegalArgumentException
	{
		FlowcellData flowcell = new FlowcellData();
		java.sql.Connection myConnection = null;
		try
		{
			Context initContext = new InitialContext();
			Context envContext = (Context)initContext.lookup("java:/comp/env");
			DataSource ds = (DataSource)envContext.lookup("jdbc/sequencing");
			
			if(envContext == null)
				throw new Exception("Error:NO Context");
			
			if(ds == null)
				throw new Exception("Error: No DataSource");
			
			if(ds != null)
				myConnection = ds.getConnection();
			
			if(myConnection != null)
			{
				//create statement handle for executing queries
				Statement stat = myConnection.createStatement();
				//get the distinct analysis_id's for the given flowcell
				String selectQuery ="select file_fullpath from sequencing.flowcell_file where flowcell_serial = '"+serial + "'";
				ResultSet results = stat.executeQuery(selectQuery);
			
				Pattern pattern = Pattern.compile(".*/storage.+(flowcells|incoming|runs|gastorage[1|2])/");
				Matcher matcher;
				Pattern laneNumPattern = Pattern.compile("s_(\\d+)[\\._]+");
				Matcher laneNumMatcher;
				//Iterate over the result set
				if(results.next())
				{
					do	
						{
							String fullPath = results.getString("file_fullpath");
							LinkedHashMap<String,String> qcFileProperties = new LinkedHashMap<String,String>();	
							matcher = pattern.matcher(fullPath);
						
							if(matcher.find())
							{
								qcFileProperties.put("base", getFileName(fullPath));
								qcFileProperties.put("fullpath", fullPath);
								qcFileProperties.put("type", "unknown");
								qcFileProperties.put("label", fullPath.substring(matcher.end(), fullPath.lastIndexOf('/')));
								qcFileProperties.put("encfullpath", encryptURLEncoded(fullPath));
							
								laneNumMatcher = laneNumPattern.matcher(qcFileProperties.get("base"));
								if(laneNumMatcher.find())
										qcFileProperties.put("lane", laneNumMatcher.group(1));
								else
										qcFileProperties.put("lane", "0");
							
								flowcell.fileList.add(qcFileProperties);
							}
						
						}while(results.next());
						results.close();
						stat.close();
				}
				else
				{
					System.out.println("In the else clause for files");
					flowcell = getFilesforFlowcellOld(serial);
				}
			}
			else
			{
				System.out.println("In the else clause for files");
				flowcell = getFilesforFlowcellOld(serial);
			}
	 }catch (Exception e) {
				e.printStackTrace();
		}
	 finally{
		 try {
			myConnection.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	 }
		return flowcell;
 }
	
	public String getFileName(String fullPath)
	{
		int sep = fullPath.lastIndexOf('/');
		return fullPath.substring(sep+1,fullPath.length());
	}
	
	
	public String getCSVFromDisk(String filePath) throws IllegalArgumentException
	{
		if(!(filePath.contains("Count") && filePath.endsWith(".csv") || filePath.endsWith("Metrics.txt")))
			return "security failed, blocked by ECCP access controls";
		
		byte[] buffer = new byte[(int) new File(filePath).length()];
	    BufferedInputStream f = null;
	    try {
	        try { f = new BufferedInputStream(new FileInputStream(filePath));} 
	        catch (FileNotFoundException e) {e.printStackTrace(); }
	        try { f.read(buffer);} 
	        catch (IOException e) { e.printStackTrace();}
	    } 
	    finally  {
	        if (f != null) 
	        	try { f.close(); } 
	        	catch (IOException ignored) { }
	    }
	    return new String(buffer);
	}
	
	public ArrayList<FlowcellData> getFlowcellsComplete() throws IllegalArgumentException
	{
		ArrayList<FlowcellData> flowcellsAll = getFlowcellsAll();
		ArrayList<FlowcellData> flowcellsComplete = new ArrayList<FlowcellData>();
		for(FlowcellData f : flowcellsAll)
		{
			if(!(f.getFlowcellProperty("status").contains("incomplete")))
				flowcellsComplete.add(f);
		}
		Collections.sort(flowcellsComplete, new Comparator<FlowcellData>()
				{
					public int compare(FlowcellData o2, FlowcellData o1)
					{
						return o1.getFlowcellProperty("date").compareTo(o2.getFlowcellProperty("date"));
					}
				});
		return flowcellsComplete;
	}
	
	
	
	@SuppressWarnings("deprecation")
	public ArrayList<FlowcellData> getAnalysisFromFS() throws IllegalArgumentException
	{
		File[] dirs = {new File("/storage/hpcc/uec-02/shared/production/ga/analysis")};
		ArrayList<FlowcellData> flowcells = new ArrayList<FlowcellData>();
		
		for(File dir : dirs)
		{
			System.out.println(dir.getPath());
			for (File run : dir.listFiles())
			{
				System.out.println(run.getPath());
				FlowcellData flowcell = new FlowcellData();
				try
				{
					if(run.isDirectory())
					{
			 			flowcell.flowcellProperties.put("serial", run.getName());
						Date d = new Date(run.lastModified());
						flowcell.flowcellProperties.put("date", (1900 + d.getYear())  + "-" + String.format("%02d",d.getMonth() + 1) + "-" + String.format("%02d",d.getDate()));
			 			flowcell.flowcellProperties.put("limsID", "N/A (" + run.getName() + ")");
						flowcells.add(flowcell);
					}
				}
				catch (Exception e)
				{
					System.out.println(e.getMessage());					
				}
			}
			
		}
		Collections.sort(flowcells, new Comparator<FlowcellData>()
				{
					public int compare(FlowcellData o2, FlowcellData o1)
					{
						return o1.getFlowcellProperty("date").compareTo(o2.getFlowcellProperty("date"));
					}
				});
		return flowcells;
	}
	
	public ArrayList<FlowcellData> getFlowcellsByKeyword(String flowcellQuery, String laneQuery)
	{
		ArrayList<FlowcellData> flowcells = getFlowcellsAll();
		ArrayList<FlowcellData> matchedFlowcells = new ArrayList<FlowcellData>();
		
		for(FlowcellData flowcell : flowcells)
		{
			if(flowcell.flowcellContains(flowcellQuery))
			{
				if(flowcell.filterLanesThatContain(laneQuery))
				{
					matchedFlowcells.add(flowcell);
				}
			}
		}
		
		return matchedFlowcells;
	}
	
	public ArrayList<String> decryptKeyword(String fcellData, String laneData)
	{
		ArrayList<String> decryptedContents = new ArrayList<String>();
		String fcellAfterDecrypt = null;
		String laneAfterDecrypt = null;
		try
		{
			//Decode the text using cipher
			SecretKeySpec keySpec = new SecretKeySpec("ep1G3n0meh@xXing".getBytes(), "AES");
			Cipher desCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			desCipher.init(Cipher.DECRYPT_MODE,keySpec,desCipher.getParameters());
			
			byte[] laneEncodedBytes = new BASE64Decoder().decodeBuffer(laneData);
			byte[] fcellEncodedBytes = new BASE64Decoder().decodeBuffer(fcellData);
			byte[] laneBytes = desCipher.doFinal(laneEncodedBytes);
			byte[] fcellBytes = desCipher.doFinal(fcellEncodedBytes);
			laneAfterDecrypt = new String(laneBytes);
			fcellAfterDecrypt = new String(fcellBytes);
			String tempLane = laneAfterDecrypt.substring(0, laneAfterDecrypt.length()-32);
			String tempFcell = fcellAfterDecrypt.substring(0,fcellAfterDecrypt.length()-32);
			
			if(md5(tempLane).equals(laneAfterDecrypt.substring(laneAfterDecrypt.length()-32, laneAfterDecrypt.length())) && 
					md5(tempFcell).equals(fcellAfterDecrypt.substring(fcellAfterDecrypt.length()-32, fcellAfterDecrypt.length())))
			{
				decryptedContents.add(tempFcell);
				decryptedContents.add(tempLane);
				return decryptedContents;
			}
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		decryptedContents.add(fcellData);
		decryptedContents.add(laneData);
		return decryptedContents;
	}
	
	/* METHODS FOR Methylation data retrieval
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#clearCache()
	 */
	
	
	public ArrayList<MethylationData> getMethFromGeneus() throws IllegalArgumentException
	{
		ArrayList<MethylationData> flowcells = new ArrayList<MethylationData>();
		try
		{
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			String[] qcCommand = {"/opt/tomcat6/webapps/ECCP/helperscripts/beadchip.pl"};
			Process execQc = Runtime.getRuntime().exec(qcCommand);
			InputStream inputStream = execQc.getInputStream();
			
			Document document = db.parse(inputStream);
			NodeList flowcellNodeList = document.getElementsByTagName("flowcell");
			for(int i = 0; i < flowcellNodeList.getLength(); i++)
			{
				Node flowcellNode = flowcellNodeList.item(i);
				MethylationData flowcell = new MethylationData();
				for(int j = 0; j < flowcellNode.getAttributes().getLength(); j++)
				{
					flowcell.flowcellProperties.put(flowcellNode.getAttributes().item(j).getNodeName(), flowcellNode.getAttributes().item(j).getNodeValue());
				}
				flowcell.flowcellProperties.put("status", "in geneus");
				
				NodeList sampleNodeList =flowcellNode.getChildNodes();
				for(int j = 0; j < sampleNodeList.getLength(); j++)
				{
					Node sampleNode = sampleNodeList.item(j);
					HashMap<String,String> sampleData = new HashMap<String,String>();
					for(int k = 0; k < sampleNode.getAttributes().getLength(); k++)
					{
						sampleData.put(sampleNode.getAttributes().item(k).getNodeName(), sampleNode.getAttributes().item(k).getNodeValue());
					}
					flowcell.lane.put((int) sampleNode.getAttributes().getNamedItem("lane").getNodeValue().charAt(0), sampleData);					
				}
				
				flowcells.add(flowcell);
			}
			inputStream.close();			
		}
		catch (Exception e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Collections.sort(flowcells, new Comparator<FlowcellData>()
		{
			public int compare(FlowcellData o2, FlowcellData o1)
			{
				return o1.getFlowcellProperty("serial").compareTo(o2.getFlowcellProperty("serial"));
			}
		});
		return flowcells;
		
	}
	
	public MethylationData getFilesForMeth(final String serial) throws IllegalArgumentException
	{
		File[] dirs = {new File("/storage/hpcc/uec-02/shared/production/methylation/meth27k"),new File("/storage/hpcc/uec-02/shared/production/methylation/meth450k")};
		ArrayList<LinkedHashMap<String, String>> fileList = new ArrayList<LinkedHashMap<String, String>>() ;
		MethylationData flowcell = new MethylationData();
		FilenameFilter filter = new FilenameFilter()
		{
			public boolean accept(File dir, String name)
			{
				return (name.contains(serial) && !name.contains(".")); 
			}
		};
		
		for(File topDir : dirs)
			for(File IntermediateDir : topDir.listFiles())
				for(File dataDir : IntermediateDir.listFiles(filter))
				{
					
					try
					{
						if(dataDir.isDirectory())
						{
							for(File dataFile : dataDir.listFiles())
							{
								LinkedHashMap<String,String> qcFileProperties = new LinkedHashMap<String,String>();
								qcFileProperties.put("base", dataFile.getName());
								qcFileProperties.put("fullpath", dataFile.getAbsolutePath());
								qcFileProperties.put("encfullpath",  encryptURLEncoded(dataFile.getAbsolutePath()));
								qcFileProperties.put("dir", "/" + topDir.getName() + "/" + IntermediateDir.getName() + "/" + dataDir.getName());
								qcFileProperties.put("label", IntermediateDir.getName() + "/" + dataDir.getName());
								qcFileProperties.put("type", "unknown");
								Pattern laneNumPattern = Pattern.compile("_(\\d+)[\\._]+");
								Matcher laneNumMatcher = laneNumPattern.matcher(qcFileProperties.get("base"));
								if(laneNumMatcher.find())
									qcFileProperties.put("lane", laneNumMatcher.group(1));
								else
									qcFileProperties.put("lane", "0");
								fileList.add(qcFileProperties);
							}
						}
					}
					catch (Exception e)
					{
						System.out.println(e.getMessage());					
					}
					
				}
		flowcell.fileList = fileList;
		return flowcell;
	}
	
	public MethylationData getQCforMeth(String serial) throws IllegalArgumentException
	{
		MethylationData flowcell = new MethylationData();
		try
		{
			for (HashMap<String,String> file : getFilesForMeth(serial).fileList)
			{
				if(file.get("base").contentEquals("Metrics.txt"))
				{
					//LinkedHashMap<String,LinkedHashMap<Integer,LinkedHashMap<String,String>>> laneQC;
					LinkedHashMap<Integer,LinkedHashMap<String,String>> row = new LinkedHashMap<Integer,LinkedHashMap<String,String>>();
					String contentsRaw = getCSVFromDisk(file.get("fullpath"));
					String[] contentLines = contentsRaw.split("\\n");
					String[] headers = contentLines[0].split("\\t");
					for(int i = 1; i < contentLines.length; i++)
					{
						String[] rowRaw = contentLines[i].split("\\t");
						LinkedHashMap<String,String> entry = new LinkedHashMap<String,String>();
						for(int j = 0; j < rowRaw.length; j++)
						{
							entry.put(headers[j], rowRaw[j]);
						}
						row.put(i, entry);						
					}
					flowcell.laneQC.put(file.get("fullpath"), row);
				}
			}
		}
		catch (Exception e)
		{
						e.printStackTrace();
						System.out.println(e.getMessage());
		}
		return flowcell;
	}
	
	/* System Administration Methods
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#clearCache()
	 */
	
	public String clearCache(String cachefile)
	{
		String[] cachefiles = {"/tmp/genFileCache", "/tmp/genURLcache"};
		for(String f : cachefiles)
			if(cachefile.contentEquals(f))
				new File(f).delete();
		
		return "cache cleared";
	}
	
	public String[] qstat(String queue) throws IllegalArgumentException
	{
		ArrayList<String> arr = new ArrayList<String>();
		arr.add("Job ID^Job Name^User^State^Submit Time^queue");
		try
		{
			String line;
			Process p = Runtime.getRuntime().exec("/usr/bin/zstatremote");
			
			BufferedReader input = new BufferedReader(new InputStreamReader(p.getInputStream()));
			while ((line = input.readLine()) != null)
			{
				if(line.contains("^"+ queue +"^"))
					arr.add(line);
				else if(queue.contains("all"))
					arr.add(line);
			}
			input.close();
		} catch (Exception err)
		{
			err.printStackTrace();
		}		
		return (String[])arr.toArray(new String[arr.size()]);
	}

	private String encryptString(String srcText)
	{		
		try
		{
			SecretKeySpec keySpec = new SecretKeySpec("ep1G3n0meh@xXing".getBytes(), "AES");
			Cipher desCipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
			desCipher.init(Cipher.ENCRYPT_MODE,keySpec);
			byte[] byteDataToEncrypt = srcText.getBytes();
			byte[] byteCipherText = desCipher.doFinal(byteDataToEncrypt); 
			String strCipherText = new BASE64Encoder().encode(byteCipherText);
			return strCipherText;
		}		
		catch (Exception e)
		{			
			e.printStackTrace();
		}
		return srcText;
	}
	
	public ArrayList<String> getEncryptedData(String globalText, String laneText)
	{
		try
		{
			ArrayList<String> retCipher = new ArrayList<String>();
			String mdGlobal = md5(globalText);
			String mdLane = md5(laneText);
			String tempGlobal = globalText.concat(mdGlobal);
			String tempLane = laneText.concat(mdLane);
			retCipher.add(encryptURLEncoded(tempGlobal));
			retCipher.add(encryptURLEncoded(tempLane));
			return retCipher;
		}		
		catch (Exception e)
		{			
			e.printStackTrace();
		}
		return null;
	}
	
	@SuppressWarnings("deprecation")
	public String encryptURLEncoded(String srcText) throws IllegalArgumentException
	{
		return java.net.URLEncoder.encode(encryptString(srcText));
	}
	
	private static String md5(String text)
	{
		MessageDigest md;
		try
		{
			md = MessageDigest.getInstance("MD5");
			
	        md.update(text.getBytes());
	 
	        byte byteData[] = md.digest();
	 
	        //convert the byte to hex format method 1
	        StringBuffer sb = new StringBuffer();
	        for (int i = 0; i < byteData.length; i++) 
	        	sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
	        return sb.toString();
		} 
		catch (NoSuchAlgorithmException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return text;		
	}
	
	NumberFormat formatter = NumberFormat.getInstance();
	public String NoFormat(String temp)
	{
		String result = null;
		double no = Double.valueOf(temp);
		if(no == 0)
			result = temp;
		else if(no > 100000)
			result = formatter.format(no/1000000) + "M";
		else if(no < 1.0)
		{
			result = formatter.format(no*100) +"%";
		}
		else
			result = temp;
		
		return result;
	}
	

}
