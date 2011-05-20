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
import java.sql.DriverManager;
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
import edu.usc.epigenome.eccp.client.data.SampleData;

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
	
/*	public ArrayList<SampleData> getSampleDataFromGeneus() throws IllegalArgumentException
	{
		ArrayList<SampleData> samples = new ArrayList<SampleData>();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 

			//database connection parameters 
			String username = "zack";
			String password = "LQSadm80";

			//URL for database connection
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct geneusId's 
			
			String selectQuery ="select distinct(geneusID_sample) from sequencing.view_run_metric";
			ResultSet results = stat.executeQuery(selectQuery);
			
			 if(results.next())
			 {
			   do
			   {
				   String libraryID = results.getString("geneusId_sample");
				   SampleData samp = new SampleData();
				   Statement st1 = myConnection.createStatement();
				   ArrayList<FlowcellData> fcells = new ArrayList<FlowcellData>();
				   String innSelect = "select distinct flowcell_serial from sequencing.view_run_metric where geneusID_sample ='"+libraryID + "'";            
				   ResultSet rs = st1.executeQuery(innSelect);
				   
				   while(rs.next())
				   {
					   String flowcell_serial = rs.getString("flowcell_serial");
					   FlowcellData singleFcell = new FlowcellData();
					   Statement fcellProp = myConnection.createStatement();
				    	//for each geneusID_sample and flowcell_serial get the geneusID_run, protocol, technician, the date and the control lane 
					   String fcellPropSelect = "select geneusId_run, protocol, technician, Date_Sequenced, ControlLane from sequencing.view_run_metric where geneusID_sample ='"+libraryID + "' and flowcell_serial ='"+flowcell_serial +"' group by flowcell_serial";            
					   ResultSet fcellResult = fcellProp.executeQuery(fcellPropSelect);
				    	 //Iterate over the resultset and add the flowcellproperties for each of the flowcells
					   while(fcellResult.next())
					   {
						   singleFcell.flowcellProperties.put("limsID", fcellResult.getString("geneusId_run"));
						   singleFcell.flowcellProperties.put("technician", fcellResult.getString("technician").replace("�", ""));
						   //@SuppressWarnings("deprecation")  
						 //  if(fcellResult.getString("Date_Sequenced") == null || fcellResult.getString("Date_Sequenced").equals(""))
							//   singleFcell.flowcellProperties.put("date", "Unknown");
						   //else
						   //{
							 //  Date d = new Date(fcellResult.getString("Date_Sequenced"));
							   //singleFcell.flowcellProperties.put("date", (1900 + d.getYear())  + "-" + String.format("%02d",d.getMonth() + 1) + "-" + String.format("%02d",d.getDate()));
						   //}
						   //flowcell.flowcellProperties.put("date", rs.getString("Date_Sequenced"));
						   singleFcell.flowcellProperties.put("protocol", fcellResult.getString("protocol"));
						   singleFcell.flowcellProperties.put("status","in geneus");
						   singleFcell.flowcellProperties.put("control", fcellResult.getString("ControlLane"));
						   singleFcell.flowcellProperties.put("serial", flowcell_serial);
					   }
					   fcellResult.close();
					   fcellProp.close();
				    	 
					   //for each flowcell get the lane information
					   Statement statLane = myConnection.createStatement();
					   String LaneProp ="select distinct(lane) from sequencing.view_run_metric where geneusID_sample ='"+libraryID+"' and flowcell_serial='"+flowcell_serial+"'";
					   ResultSet RsProp = statLane.executeQuery(LaneProp);	
					   //Iterate over the lane numbers 
					   while(RsProp.next())
					   {
						   int lane_no =  RsProp.getInt("lane");
						   HashMap<String,String> sampleData = new HashMap<String,String>();
						   Statement cellprop = myConnection.createStatement();
						   //for each lane of a flowcell get the processing, sample_name, organism and project associated with it.
						   String st2 ="select processing, sample_name, organism, project from sequencing.view_run_metric where geneusID_sample ='"+libraryID+"' and flowcell_serial ='"+flowcell_serial+"' and lane ="+ lane_no;
						   ResultSet Prop = cellprop.executeQuery(st2);
								
							//Iterate over the information and populate the lane information
							while(Prop.next())
							{
								sampleData.put("processing", Prop.getString("processing"));
								sampleData.put("library", Prop.getString("sample_name"));
								sampleData.put("organism", Prop.getString("organism"));
								//sampleData.put("Geneusid", rs.getString("geneusID_sample"));
								sampleData.put("project", Prop.getString("project"));
							}
							Prop.close();
							cellprop.close();
							
							singleFcell.lane.put(lane_no, sampleData);	
						}
						RsProp.close();
						statLane.close();
						
						fcells.add(singleFcell);
						
				   }
				   rs.close();
				   st1.close();
				   samp.sampleInfo.put(libraryID, fcells);
				   //System.out.println("fcells contents " + fcells.toString());
				   //System.out.println("Each samp has contents " + samp.sampleInfo.toString());
				   samples.add(samp);
						
			    }while(results.next());
			     results.close();
			     stat.close();
			     
			     
			 }
		}
		catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		
		return samples;
	}*/
	
	public ArrayList<SampleData> getSampleFromGeneus() throws IllegalArgumentException
	{
		ArrayList<SampleData> samples = new ArrayList<SampleData>();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 

			//database connection parameters 
			String username = "zack";
			String password = "LQSadm80";

			//URL for database connection
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct geneusId's 
			
			String selectQuery ="select distinct(sample_name) from sequencing.view_run_metric";
			ResultSet results = stat.executeQuery(selectQuery);
			
			 if(results.next())
			 {
			   do
			   {
				   String libraryID = results.getString("sample_name");
				   SampleData sample = new SampleData();
				   
				   Statement st1 = myConnection.createStatement();
				   //ArrayList<FlowcellData> fcells = new ArrayList<FlowcellData>();
				   String samplePropSelect = "select project, organism, Date_Sequenced, geneusId_sample from sequencing.view_run_metric where sample_name ='"+libraryID + "'";            
				   ResultSet rs1 = st1.executeQuery(samplePropSelect);
				   
				   while(rs1.next())
				   {
					   sample.sampleProperties.put("library", libraryID);
					   sample.sampleProperties.put("project", rs1.getString("project"));
					   sample.sampleProperties.put("organism", rs1.getString("organism"));
					   //sample.sampleProperties.put("Date_Sequenced", rs1.getString("Date_Sequenced"));
					   if(rs1.getString("Date_Sequenced") == null || rs1.getString("Date_Sequenced").equals(""))
			    			 sample.sampleProperties.put("date", "Unknown");
			    		 else
			    		 { 
			    			 try{
			    			Date d = new Date(rs1.getString("Date_Sequenced"));
			    			sample.sampleProperties.put("date", (1900 + d.getYear())  + "-" + String.format("%02d",d.getMonth() + 1) + "-" + String.format("%02d",d.getDate()));
			    			 }
			    			 catch(Exception e){
			    				 e.printStackTrace();
			    			 }
			    		 }
					   sample.sampleProperties.put("geneusID_sample", rs1.getString("geneusID_sample"));
				   }
				   rs1.close();
				   st1.close();
				   
				   st1 = myConnection.createStatement();
				   String sampFlowcell = "select distinct(flowcell_serial) from sequencing.view_run_metric where sample_name = '"+libraryID +"'";
				   rs1 = st1.executeQuery(sampFlowcell);
				   
				   while(rs1.next())
				   {
					  String flowcellID = rs1.getString("flowcell_serial");
					  HashMap<String, String> flowcellProp = new HashMap<String, String>();
					  Statement st2 = myConnection.createStatement();
					  String fcellPropSelect = "select technician, geneusId_run, protocol, ControlLane from sequencing.view_run_metric where sample_name ='"+libraryID+"' and flowcell_serial ='"+flowcellID+"'";
					  ResultSet rs2 = st2.executeQuery(fcellPropSelect);
					  
					  while(rs2.next())
					  {
						  flowcellProp.put("technician", rs2.getString("technician").replace("�", ""));
						  flowcellProp.put("geneusId_run", rs2.getString("geneusId_run"));
					  }
					  rs2.close();
					  st2.close();
					  sample.flowcellInfo.put(flowcellID, flowcellProp);
				   }
				   rs1.close();
				   st1.close();
				   
				   samples.add(sample);
				   
			     }while(results.next());
			   	 results.close();
			   	 stat.close();
			  }
		}catch (Exception e) {
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
		return samples;
		
	}
	
	
	/*
	 * Get flowcells from Geneus information from the database
	 */
	@SuppressWarnings("deprecation")
	public ArrayList<FlowcellData> getFlowcellsFromGeneus() throws IllegalArgumentException
	{
		ArrayList<FlowcellData> flowcells = new ArrayList<FlowcellData>();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 

			//database connection code 
			String username = "zack";
			String password = "LQSadm80";

			//URL
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
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
		    		 flowcell.flowcellProperties.put("technician", rs.getString("technician").replace("�", ""));
		    		 //@SuppressWarnings("deprecation")  
		    		 if(rs.getString("Date_Sequenced") == null || rs.getString("Date_Sequenced").equals(""))
		    			 flowcell.flowcellProperties.put("date", "Unknown");
		    		 else
		    		 {
		    			 Date d = new Date(rs.getString("Date_Sequenced"));
		    			 flowcell.flowcellProperties.put("date", (1900 + d.getYear())  + "-" + String.format("%02d",d.getMonth() + 1) + "-" + String.format("%02d",d.getDate()));
		    		 }
		    		 //flowcell.flowcellProperties.put("date", rs.getString("Date_Sequenced"));
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
					String st2 ="select processing, sample_name, organism, project from sequencing.view_run_metric where geneusID_run ='"+lims_id+"' and lane ="+ lane_no;
					ResultSet Prop = cellprop.executeQuery(st2);
						
					//Iterate over the information and populate the lane information
					while(Prop.next())
					{
						sampleData.put("processing", Prop.getString("processing"));
						String sample_name = Prop.getString("sample_name");
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
			   //flowcells = getFlowcellsFromGeneusFiles();
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
		try
		{
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
		}catch (Exception e) {
			e.printStackTrace();
		}
		  //else
		  //{
			//  continue;
		 // }
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
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 
			//database connection code 
			String username = "zack";
			String password = "LQSadm80";
			
			//URL to connect to the database
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
				+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//get the distinct analysis_id's for the given flowcell
			String selectQuery ="select distinct(analysis_id) from sequencing.view_run_metric where flowcell_serial = '"+serial + "' and Date_Sequenced !='NULL' order by analysis_id";
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
			 myConnection.close();
		}
		else
		{
			System.out.println("In the else clause for QC");
			flowcell = getQCforFlowcellFiles(serial);
		}
	 }catch( Exception E )
		{ 
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
	
	
	public SampleData getQCSampleFlowcell(String serial, String sampleID) throws IllegalArgumentException
	{
		SampleData flowcell = new SampleData();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 
			//database connection code 
			String username = "zack";
			String password = "LQSadm80";
			
			//URL to connect to the database
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
				+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//get the distinct analysis_id's for the given flowcell
			String selectQuery ="select distinct(analysis_id) from sequencing.view_run_metric where flowcell_serial = '"+serial + "' and sample_name = '"+sampleID+ "' and Date_Sequenced !='NULL' order by analysis_id";
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
				String innSelect = "select  * from sequencing.view_run_metric where analysis_id ='" +  analysis_id + "' and flowcell_serial = '"+serial + "' and sample_name = '"+sampleID+ "' and Date_Sequenced !='NULL'";
				ResultSet rs = st1.executeQuery(innSelect);
				ResultSetMetaData rsMetaData = rs.getMetaData();
				
				LinkedHashMap<Integer,LinkedHashMap<String,String>> qcReport = new LinkedHashMap<Integer,LinkedHashMap<String,String>>();
				while(rs.next())
				{
					LinkedHashMap<String,String> qcProperties = new LinkedHashMap<String,String>();
					qcProperties.put("lane", rs.getString("lane"));
					qcProperties.put("geneusID_sample", rs.getString("sample_name"));
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
				flowcell.flowcellLaneQC.put(analysis_id, qcReport);
			 }while(results.next());
			
			 results.close();
			 stat.close();
			 myConnection.close();
		  }
		}
		catch( Exception E )
		{ 
			System.out.println( E.getMessage());	
		}			
		finally
		{
			try{myConnection.close();}
			catch (SQLException e) {
				e.printStackTrace();
			}
		}
			return flowcell;
	}
	
	/*public FlowcellData getQCSampleFlowcell(String serial, String sampleID) throws IllegalArgumentException
	{
		FlowcellData flowcell = new FlowcellData();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 
			//database connection code 
			String username = "zack";
			String password = "LQSadm80";
			
			//URL to connect to the database
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
				+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//get the distinct analysis_id's for the given flowcell
			String selectQuery ="select distinct(analysis_id) from sequencing.view_run_metric where flowcell_serial = '"+serial + "' and geneusID_sample = '"+sampleID+ "' and Date_Sequenced !='NULL' order by analysis_id";
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
				String innSelect = "select  * from sequencing.view_run_metric where analysis_id ='" +  analysis_id + "' and flowcell_serial = '"+serial + "' and geneusID_sample = '"+sampleID+ "' and Date_Sequenced !='NULL'";
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
			 myConnection.close();
		  }
		}
		catch( Exception E )
		{ 
			System.out.println( E.getMessage());	
		}			
		finally
		{
			try{myConnection.close();}
			catch (SQLException e) {
				e.printStackTrace();
			}
		}
			return flowcell;
	}*/
		
	@Override
	public SampleData getFilesforFlowcellLane(String serial) throws IllegalArgumentException
	{
		SampleData flowcell = new SampleData();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 
			//database connection code 
			String username = "zack";
			String password = "LQSadm80";
		
			//URL to connect to the database
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
			+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//get the distinct analysis_id's for the given flowcell
			String selectQuery ="select file_fullpath from sequencing.flowcell_file where flowcell_serial = '"+serial + "'";
			ResultSet results = stat.executeQuery(selectQuery);
			
			Pattern pattern = Pattern.compile(".*/storage.+(flowcells|incoming|analysis|runs|gastorage[1|2])/");
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
							
							flowcell.flowcellFileList.add(qcFileProperties);
						}
						
					}while(results.next());
			 }
	 }
		catch (Exception e) 
		{
				e.printStackTrace();
		}
		return flowcell;
 }
	
	public String getFileName(String fullPath)
	{
		int sep = fullPath.lastIndexOf('/');
		return fullPath.substring(sep+1,fullPath.length());
	}
	
	@Override
	public FlowcellData getFilesforFlowcell(String serial)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
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

	@Override
	public ArrayList<FlowcellData> getAnalysisFromFS()
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

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

	@Override
	public MethylationData getFilesForMeth(String serial)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public MethylationData getQCforMeth(String serial)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String[] qstat(String queue) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String clearCache(String cachefile) throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String encryptURLEncoded(String srcText)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ArrayList<String> getEncryptedData(String globalText, String laneText)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ArrayList<String> decryptKeyword(String fcellText, String laneText)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
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

	@Override
	public ArrayList<SampleData> getSampleDataFromGeneus()
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public SampleData getLaneFlowcellSample(String Library, String flowcellSerial) throws IllegalArgumentException 
	{
		SampleData flowcell = new SampleData();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 
			//database connection code 
			String username = "zack";
			String password = "LQSadm80";
			
			//URL to connect to the database
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
				+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//get the distinct analysis_id's for the given flowcell
			String selectQuery ="select distinct(lane), processing from sequencing.view_run_metric where flowcell_serial = '"+flowcellSerial + "' and sample_name = '"+Library+ "' and Date_Sequenced !='NULL' order by lane";
			ResultSet results = stat.executeQuery(selectQuery);
			
			//Iterate over the result set
			if(results.next())
			{
			  do	
			  {
				  Integer lane_no = results.getInt(1);
				  HashMap<String, String> laneInfo = new HashMap<String, String>();
				  laneInfo.put("lane", results.getString("lane"));
				  laneInfo.put("processing", results.getString("processing"));
				
				  flowcell.flowcellLane.put(lane_no, laneInfo);
			  }while(results.next());
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return flowcell;
	}
	
	/*	public ArrayList<FlowcellData> getSampleFromGeneus() throws IllegalArgumentException
	{
		ArrayList<FlowcellData> samples = new ArrayList<FlowcellData>();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 

			//database connection code 
			String username = "zack";
			String password = "LQSadm80";

			//URL
			String dbURL = "jdbc:mysql://webapp.epigenome.usc.edu:3306/sequencing?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct geneusId's 
			String selectQuery ="select distinct(geneusID_sample) from sequencing.view_run_metric";
			ResultSet results = stat.executeQuery(selectQuery);
			
			  if(results.next())
			   {
			     do
				 {
			    	 FlowcellData flowcell = new FlowcellData();
			    	 String libraryID = results.getString("geneusId_sample");
			    	 Statement st1 = myConnection.createStatement();
			    	 HashMap<String, HashMap<Integer, HashMap<String, String>>> fcell = new HashMap<String, HashMap<Integer,HashMap<String, String>>>();
			    	 String innSelect = "select distinct flowcell_serial from sequencing.view_run_metric where geneusID_sample ='"+libraryID + "'";            
			    	 ResultSet rs = st1.executeQuery(innSelect);
			    	 //Iterate over the resultset and add the flowcellproperties for each of the flowcells
			    	 while(rs.next())
			    	 {
			    		String flowcell_serial = rs.getString("flowcell_serial");
			    		HashMap<Integer,HashMap<String,String>> fcellLaneData = new HashMap<Integer,HashMap<String,String>>();
			    		
			    		Statement statLane = myConnection.createStatement();
						String LaneProp ="select distinct(lane) from sequencing.view_run_metric where flowcell_serial ='"+flowcell_serial + "' and geneusID_sample ='"+libraryID+"'";
						ResultSet RsProp = statLane.executeQuery(LaneProp);	
						//Iterate over the lane numbers 
						while(RsProp.next())
						{
							int lane_no =  RsProp.getInt("lane");
							HashMap<String,String> sampleData = new HashMap<String,String>();
							Statement cellprop = myConnection.createStatement();
							String cellQuery ="select processing, sample_name, organism, project from sequencing.view_run_metric where flowcell_serial ='"+flowcell_serial + "' and geneusID_sample ='"+libraryID+"' and lane ="+ lane_no;
							
							ResultSet Prop = cellprop.executeQuery(cellQuery);
							//Iterate over the information and populate the lane information
							while(Prop.next())
							{
								sampleData.put("processing", Prop.getString("processing"));
								sampleData.put("sample_name", Prop.getString("sample_name"));
								sampleData.put("organism", Prop.getString("organism"));
								sampleData.put("project", Prop.getString("project"));
							}
							Prop.close();
							cellprop.close();
							fcellLaneData.put(lane_no, sampleData);
						}
						RsProp.close();
						statLane.close();
						fcell.put(flowcell_serial, fcellLaneData);
			    	 }	
			    	 rs.close();
			    	 st1.close();
			    	 flowcell.sample.put(libraryID, fcell);
			    	 
			    	 samples.add(flowcell);
				 }while(results.next());
			     
			     results.close();
				 stat.close();
			   }
			   else
			   	{
				   System.out.println("In the else clause for FLOWCELLS");
				   //flowcells = getFlowcellsFromGeneusFiles();
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
			return samples;	
		}*/
}
