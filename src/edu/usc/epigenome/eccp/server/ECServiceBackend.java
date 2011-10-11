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
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
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
import com.sun.mirror.apt.RoundCompleteEvent;


/**
 * The server side implementation of the RPC service.
 */
@SuppressWarnings("serial")
public class ECServiceBackend extends RemoteServiceServlet implements ECService
{
	/*********************************************************************
	 *Functions for Project specific Tree View  
	 *********************************************************************
	 */
	
	/* Function to get a list of all the projects from the database
	 * Input: a search string and boolean flag
	 * if the search flag (boolean yes) is set then perform a mysql full text search for the searchString in the database
	 * and return the list of projects matching the search criteria
	 */
	public ArrayList<String> getProjectsFromGeneus(String searchString, boolean yes) throws IllegalArgumentException
	{
		ArrayList<String> projects = new ArrayList<String>();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 

			//database connection parameters 
			String username = "zack";
			String password = "LQSadm80";

			//URL for database connection
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;
			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);
			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct projects
			String selectQuery ="select distinct(project) from view_run_metric order by Date_Sequenced";
			//If search flag set, then perform full text match on project, sample_name, organism, flowcell_serial, geneusID_sample fields
			if(yes)
			{
				//replace all the spaces by " +"  ('+' stands for 'and operation' in mysql fulltext search)
				String search = searchString.replaceAll("\\s+", " \\+");
				//Query to select distinct projects 
				selectQuery = "select distinct(project) from view_run_metric where MATCH(project, sample_name, organism, technician, flowcell_serial, geneusID_sample) against ('+"+search+"' IN BOOLEAN MODE) order by Date_Sequenced";
			}
			
			System.out.println("The query that is executed is " + selectQuery);
			ResultSet results = stat.executeQuery(selectQuery);
			
			 if(results.next())
			 {
			   do
			   {
				   String proj = results.getString("project");
				   projects.add(proj);
			   }while(results.next());
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
		//Return the projects ArrayList
		return projects;	
	}
	
	public HashMap<String, ArrayList<String>> decryptSearchProject(String toSearch) throws IllegalArgumentException
	{
		ArrayList<String> projects = new ArrayList<String>();
		HashMap<String, ArrayList<String>> map = new HashMap<String, ArrayList<String>>();
		ArrayList<String> decryptContents = decryptKeyword(toSearch, toSearch);
		map.put("decrypted", decryptContents);
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 

			//database connection parameters 
			String username = "zack";
			String password = "LQSadm80";

			//URL for database connection
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;
			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);
			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct projects using a fulltext search match
			String contents = decryptContents.get(0).replaceAll("\\s+", " \\+");
			String selectQuery = "select distinct(project) from view_run_metric where MATCH(project, sample_name, organism, technician, flowcell_serial, geneusID_sample) against ('+"+contents+"' IN BOOLEAN MODE) order by Date_Sequenced";
			
			System.out.println("The query that is executed is " + selectQuery);
			ResultSet results = stat.executeQuery(selectQuery);
			
			 if(results.next())
			 {
			   do
			   {
				   String proj = results.getString("project");
				   projects.add(proj);
			   }while(results.next());
			}
			 map.put("project", projects);
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
		//Return the projects ArrayList
		return map;	
	}
	
	
	/*
	 * Function to get a list of samples for a given projectName
	 * Input project name 
	 * Output arraylist of SampleData containing sample information for the given projectName
	 */
	public ArrayList<SampleData> getSamplesForProject(String projectName, String searchString, boolean yes)throws IllegalArgumentException 
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
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct sample_names for the given projectName
			String selectQuery ="select distinct(sample_name) from view_run_metric where project like '%"+projectName+"%'";
			if(yes)
			{
				String contents = searchString.replaceAll("\\s+", " \\+");
				selectQuery = "select distinct(sample_name) from view_run_metric where project like '%"+projectName+"%' and MATCH(project, sample_name, organism, technician, flowcell_serial, geneusID_sample) against ('+"+contents+"' IN BOOLEAN MODE)";
			}
			System.out.println("The query that is executed is " + selectQuery);
			ResultSet results = stat.executeQuery(selectQuery);
			//Iterate over the samples
			 if(results.next())
			 {
			   do
			   {
				   String libraryID = results.getString("sample_name");
				   SampleData sample = new SampleData();
				   
				   Statement st1 = myConnection.createStatement();
				  //Get data for each of the sample  
				   String samplePropSelect = "select project, organism, Date_Sequenced, geneusID_sample from view_run_metric where sample_name ='"+libraryID + "' and project like '%"+projectName+"%'";            
				   ResultSet rs1 = st1.executeQuery(samplePropSelect);
				   //Add sample Properties for each of the sample
				   while(rs1.next())
				   {
					   sample.sampleProperties.put("library", libraryID);
					   sample.sampleProperties.put("project", rs1.getString("project"));
					   sample.sampleProperties.put("organism", rs1.getString("organism"));
					   if(rs1.getString("Date_Sequenced") == null || rs1.getString("Date_Sequenced").equals(""))
			    			 sample.sampleProperties.put("date", "Unknown");
					   else
					   { 
			    		 try
			    		 {
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
				   //Get flowcells for a given sample
				   SampleData s = getFlowcellsforSample(libraryID);
				   sample.sampleFlowcells = s.sampleFlowcells;
				   
				/*   for(String fcellSerial : sample.sampleFlowcells.keySet())
				   {
					   FlowcellData fcell = getLaneFlowcellSample(libraryID, fcellSerial);
					   sample.sampleFlowcells.get(fcellSerial).lane = fcell.lane;
					   
					   for(final Integer laneNo : fcell.lane.keySet())
					   {
						   FlowcellData f = getQCSampleFlowcell(fcellSerial, libraryID, laneNo);
						   sample.sampleFlowcells.get(fcellSerial).laneQC = f.laneQC;
					   }
				   }*/
				   samples.add(sample);
				   
			   }while(results.next());
			   results.close();
			   stat.close();
			 }
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		finally
		{
		  try {myConnection.close();}
		  catch (SQLException e) 
		  {e.printStackTrace();}
		}	   	
		return samples;
	}
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getFlowcellsforSample(java.lang.String)
	 * For the tree view structure, get all the flowcells for a given sample_name 
	 * 
	 */
	public SampleData getFlowcellsforSample(String libraryID) throws IllegalArgumentException
	{
		SampleData sample = new SampleData();
		
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 

			//database connection parameters 
			String username = "zack";
			String password = "LQSadm80";

			//URL for database connection
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct flowcells for the given sample_name
			String sampFlowcell = "select distinct(flowcell_serial) from view_run_metric where sample_name = '"+libraryID +"'";
			ResultSet  rs1 = stat.executeQuery(sampFlowcell);
			//Iterate over the resultSet and get flowcellProperties for each of the flowcell   
			while(rs1.next())
			{
			   String flowcellID = rs1.getString("flowcell_serial");  
			   FlowcellData flowcell = new FlowcellData();
			   Statement st2 = myConnection.createStatement();
			   //query to get flowcellproperties for a given sampleName and flowcell
			   String fcellPropSelect = "select technician, geneusId_run, protocol, ControlLane from view_run_metric where sample_name ='"+libraryID+"' and flowcell_serial ='"+flowcellID+"'";
			   ResultSet rs2 = st2.executeQuery(fcellPropSelect);
					  
				while(rs2.next())
				{
					flowcell.flowcellProperties.put("technician", rs2.getString("technician").replace("å", ""));
					flowcell.flowcellProperties.put("geneusId_run", rs2.getString("geneusId_run"));
				 }
				 rs2.close();
				 st2.close();
				 sample.sampleFlowcells.put(flowcellID, flowcell);
			  }
			   rs1.close();
			   stat.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
		   try {myConnection.close();}
		   catch (SQLException e) {
			e.printStackTrace();}
		}	   
		return sample;
	}
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getLaneFlowcellSample(java.lang.String, java.lang.String)
	 *  Project specific tree view
	 *  Function to get a list of runId's(analysis_id) for each of the lanes 
	 *  Input: given library and flowcell 
	 */
	public FlowcellData getLaneFlowcellSample(String Library, String flowcellSerial) throws IllegalArgumentException 
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
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//get the distinct lane for the given flowcell and sample_name
			String selectQuery ="select distinct(lane) from view_run_metric where flowcell_serial = '"+flowcellSerial + "' and sample_name = '"+Library+ "' and Date_Sequenced !='NULL' order by lane";
			ResultSet results = stat.executeQuery(selectQuery);
			
			//Iterate over the distinct lanes 
			//For each of the lane get the analysis_id and add it to the ArrayList
			if(results.next())
			{
			  do	
			  {
				  Integer lane_no = results.getInt(1);
				  ArrayList<String> laneRunId = new ArrayList<String>();
				  Statement st1 = myConnection.createStatement();
				  //Query to get the analysis_id for given flowcell, library and lane
				  String samplePropSelect = "select analysis_id from view_run_metric where flowcell_serial = '"+flowcellSerial + "' and sample_name = '"+Library+ "' and lane = '"+lane_no + "' and Date_Sequenced !='NULL' order by lane";            
				  ResultSet rs1 = st1.executeQuery(samplePropSelect);
				   
				  //Iterate over the resultSet and add to the ArrayList
				  while(rs1.next())
				  {
					  laneRunId.add(rs1.getString("analysis_id"));  
				  }
				  rs1.close();
				  st1.close();
				
				  //For each laneNo add the ArrayList containing analysis_id
				  flowcell.QClist.put(lane_no, laneRunId);
			  }while(results.next());
			}
		}catch (Exception e) 
		{e.printStackTrace();}
		finally
		{
		   try {myConnection.close();}
		   catch (SQLException e) {
			e.printStackTrace();}
		}	  
		return flowcell;
	}
	
	/*********************************************************************
	 * Functions for Flowcell specific Tree View  
	 *********************************************************************
	 */
	
	/*
	 * For the flowcell specific view
	 * Get an ArrayList of all the flowcells from the database(data structure FlowcellData)
	 */ 
	
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
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct geneusId_run   
			String selectQuery ="select distinct(geneusID_run) from view_run_metric";
			ResultSet results = stat.executeQuery(selectQuery);
			
			//Iterate over the resultset consisting of GeneusID
		   if(results.next())
		   {
		     do
			 {
		    	 FlowcellData flowcell = new FlowcellData();
		    	 String lims_id = results.getString("geneusId_run");
		    	 Statement st1 = myConnection.createStatement();
		    	 //for each geneusid get the flowcell serial no, protocol, technician, the date and the control lane 
		    	 String innSelect = "select distinct flowcell_serial, protocol, technician, Date_Sequenced, ControlLane from view_run_metric where geneusID_run ='"+lims_id + "' group by geneusId_run";            
		    	 ResultSet rs = st1.executeQuery(innSelect);
		    	 //Iterate over the resultset and add the flowcellproperties for each of the flowcells
		    	 while(rs.next())
		    	 {
		    		 flowcell.flowcellProperties.put("serial", rs.getString("flowcell_serial"));
		    		 flowcell.flowcellProperties.put("limsID", lims_id);
		    		 flowcell.flowcellProperties.put("technician", rs.getString("technician").replace("å", ""));
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
				String LaneProp ="select distinct(lane) from view_run_metric where geneusID_run ='"+lims_id+"'";
				ResultSet RsProp = statLane.executeQuery(LaneProp);	
				//Iterate over the lane numbers 
				while(RsProp.next())
				{
					int lane_no =  RsProp.getInt("lane");
					HashMap<String,String> sampleData = new HashMap<String,String>();
					Statement cellprop = myConnection.createStatement();
					//for each lane of a flowcell get the processing, sample_name, organism and project associated with it.
					String st2 ="select processing, sample_name, geneusID_sample, organism, project from view_run_metric where geneusID_run ='"+lims_id+"' and lane ="+ lane_no;
					ResultSet Prop = cellprop.executeQuery(st2);
						
					//Iterate over the information and populate the lane information for each of the flowcell
					while(Prop.next())
					{
						sampleData.put("processing", Prop.getString("processing"));
						String sample_name = Prop.getString("sample_name");
						String sampleID = Prop.getString("geneusID_sample");
						String organism = Prop.getString("organism");
						//For multiple samples in a Lane, concatenate the sample_name, organism, sampleID using '+' 
						if(sampleData.containsKey("name"))
						{
							String tempName = sampleData.get("name");
							if(!(tempName.contains(sample_name)))
								sampleData.put("name", sampleData.get("name").concat("!").concat(sample_name));
						}
						else
							sampleData.put("name", sample_name);
							
						if(sampleData.containsKey("organism"))
						{
							String tempOrg = sampleData.get("organism");
							if(!(tempOrg.contains(organism)))
								sampleData.put("organism", sampleData.get("organism").concat("!").concat(organism));
						}
						else
							sampleData.put("organism", Prop.getString("organism"));
						
						if(sampleData.containsKey("sampleID"))
						{
							String tempSampleID = sampleData.get("sampleID");
							if(!(tempSampleID.contains(sampleID)))
								sampleData.put("sampleID", sampleData.get("sampleID").concat("!").concat(sampleID));
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
			   //flowcells = getFlowcellsFromGeneusFiles();
		   	}
		}
		catch (Exception e)
		{e.printStackTrace();}
		finally
		{
		  try {myConnection.close();} 
		  catch (SQLException e) {
			e.printStackTrace(); }
		}
		return flowcells;	
	}
	
	/*************************************************************************
	 * Functions common to both Flowcell specific Tree View and Project Specific Tree View  
	 *************************************************************************
	 */
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getQCSampleFlowcell(java.lang.String, java.lang.String)
	 * Get the QC for a given flowcell and sample
	 */
	public FlowcellData getQCSampleFlowcell(String serial, String sampleName, int laneNo, String userType) throws IllegalArgumentException
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
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//get the distinct analysis_id's for the given flowcell, sample_name and lane number
			String selectQuery ="select distinct(analysis_id) from view_run_metric where flowcell_serial = '"+serial + "' and sample_name = '"+sampleName+ "' and lane = '"+laneNo +"' and Date_Sequenced !='NULL' order by analysis_id";
			ResultSet results = stat.executeQuery(selectQuery);
			System.out.println("the user type passed is  " + userType);
			//Iterate over the result set
			if(results.next())
			{
			  do	
			 {
				String analysis_id = results.getString("analysis_id");
				//System.out.println("analysis_id is " + analysis_id);
				Statement st1 = myConnection.createStatement();
				//for each analysis_id get the QC information from the database
				String innSelect = "select  * from view_run_metric where analysis_id ='" +  analysis_id + "' and flowcell_serial = '"+serial + "' and sample_name = '"+sampleName+ "' and Date_Sequenced !='NULL'";
				
				if(userType.equalsIgnoreCase("guest"))
				{
					String toSelect = "flowcell_serial, sample_name, lane, geneusID_sample, organism, protocol, ControlLane,  barcode, Date_Sequenced, RunParam_RTAVersion, contamSeqs, genome";
					//String toSelect = getUserMeticNames();
					innSelect = "select " + toSelect + " from view_run_metric where analysis_id ='" +  analysis_id + "' and flowcell_serial = '"+serial + "' and sample_name = '"+sampleName+ "' and Date_Sequenced !='NULL'";
				}
				System.out.println("The query executed is " + innSelect);
				ResultSet rs = st1.executeQuery(innSelect);
				ResultSetMetaData rsMetaData = rs.getMetaData();
				
				LinkedHashMap<Integer,LinkedHashMap<String,String>> qcReport = new LinkedHashMap<Integer,LinkedHashMap<String,String>>();
				while(rs.next())
				{
					LinkedHashMap<String,String> qcProperties = new LinkedHashMap<String,String>();
					qcProperties.put("lane", rs.getString("lane"));
					//qcProperties.put("geneusID_sample", rs.getString("'geneusID_sample'"));
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
		}
		catch(Exception E)
		{E.printStackTrace();}			
		finally
		{
		  try{myConnection.close();}
		  catch (SQLException e) 
		  {e.printStackTrace();}
		}
		return flowcell;
	}
	
	/*
	 * Sample specific View
	 * Function to get Files for a given run and sampleID 
	 * Input: takes Run_id, the flowcell serial and the SampleID 
	 * output: List of files with their properties for the given input 
	 */
	public FlowcellData getFilesforRunSample(String run_id, String serial, String sampleID) throws IllegalArgumentException
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
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);
			
			if(myConnection != null)
			{
				//create statement handle for executing queries
				Statement stat = myConnection.createStatement();
				//get the run_sample_id from the run_sample table for the given analysis_id and the given sampleID
				String selectQuery ="select id from run_sample where analysis_id = '"+run_id + "' and id_sample = (select id from sample where geneus_id = '"+sampleID +"')";
				ResultSet results = stat.executeQuery(selectQuery);
				
				//Iterate over the resultSet 
				if(results.next())
				{
					do
					{
						String run_sample_id = results.getString("id");
						Statement st1 = myConnection.createStatement();
						String selectFiles = "select f.file_fullpath, file_type.id_category, c.name from file f left outer join file_type on f.id_file_type = file_type.id left outer join category c on file_type.id_category = c.id where f.id_run_sample ='"+run_sample_id + "'";            
						ResultSet rs1 = st1.executeQuery(selectFiles);
						
						Pattern pattern = Pattern.compile(".*/storage.+(flowcells|incoming|analysis|runs|gastorage[1|2])/");
						Matcher matcher;
						Pattern laneNumPattern = Pattern.compile("(s|"+serial+")_(\\d+)[\\._]+");
						Matcher laneNumMatcher;
						
						while(rs1.next())
						{
							String fullPath = rs1.getString("f.file_fullpath");
							String category = rs1.getString("c.name");
							LinkedHashMap<String,String> qcFileProperties = new LinkedHashMap<String,String>();	
							matcher = pattern.matcher(fullPath);
							
							if(matcher.find())
							{
								qcFileProperties.put("base", getFileName(fullPath));
								qcFileProperties.put("fullpath", fullPath);
								if(category == null)
									qcFileProperties.put("type", "Unknown");
								else
									qcFileProperties.put("type", category);
								
								qcFileProperties.put("label", fullPath.substring(matcher.end(), fullPath.lastIndexOf('/')));
								qcFileProperties.put("encfullpath", encryptURLEncoded(fullPath));
							
								laneNumMatcher = laneNumPattern.matcher(qcFileProperties.get("base"));
								if(laneNumMatcher.find())
										qcFileProperties.put("lane", laneNumMatcher.group(2));
								else
										qcFileProperties.put("lane", "0");
							
								flowcell.fileList.add(qcFileProperties);
							}
						}
						rs1.close();
						st1.close();
						
					}while(results.next());
					results.close();
					stat.close();
				}
			}		
		}
		catch (Exception e) 
		{e.printStackTrace();}
		 finally
		 {
		   try{myConnection.close();}
		   catch (SQLException e) 
		   {e.printStackTrace();}
		 }
		return flowcell;
	}
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getCSVFiles(java.lang.String, java.lang.String, java.lang.String)
	 * Function to get List of files to generate QC Plots
	 * Input given flowcell, sampleID  and run_id(analysis_id)
	 */
	public FlowcellData getCSVFiles(String run_id, String serial, String sampleID) throws IllegalArgumentException
	{
		FlowcellData flowcell;
		System.out.println("The runID and sample ID is " + run_id + sampleID);
		if(run_id.equals("") && sampleID.equals(""))
			flowcell = getFilesforFlowcell(serial);
		else
		 flowcell = getFilesforRunSample(run_id, serial, sampleID);
		
		ArrayList<LinkedHashMap<String,String>> filesList = flowcell.fileList;
		ArrayList<LinkedHashMap<String, String>> filesToRemove = new ArrayList<LinkedHashMap<String,String>>();
		
		for(int i=0;i<filesList.size();i++)
		{
			LinkedHashMap<String, String>f = filesList.get(i);
			if(!f.get("base").contains(".csv"))
			{
				filesToRemove.add(f);
			}
		}
		//System.out.println("The size of filesToRemove " + filesToRemove.size());
		for(HashMap<String, String> file : filesToRemove)
		{
			filesList.remove(file);
		}
		//System.out.println("The size of filesList is  " + filesList.size());
		return flowcell;
	}
	
	/*********************************************************************
	 * Functions for "OLD" Flowcell specific View (Stack Panel)  
	 *********************************************************************
	 */
	
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
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getFlowcellsFromFS()
	 * Get the list of flowcells from files (Old: Used in the stack panel view)
	 */
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

	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getFlowcellsIncomplete()
	 * Get list of incomplete flowcells (Old: used in the stackpanel view)
	 */
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

	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getFlowcellsComplete()
	 * Get a list of all complete flowcells (Old: Used in the stackpanel view) 
	 */
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

	/*
	 * Get the QC metrics data from the files for a given Flowcell
	 * Execute report.pl script with flowcell serial and qc as parameters
	 * Parse the generated xml by using DocumentBuilder(DOM parser) and get the QC metrics information
	 * in flowcell.laneQC data structure
	 */
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
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getQCforFlowcell(java.lang.String)
	 * For a given flowcell serial get the QC metrics data from the database
	 */
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
		  String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
			  + username + "&password=" + password;
		  //create the connection
		  myConnection = DriverManager.getConnection(dbURL);
		  //create statement handle for executing queries
		  Statement stat = myConnection.createStatement();
		  //get the distinct analysis_id's for the given flowcell
		  String selectQuery ="select distinct(analysis_id) from view_run_metric where flowcell_serial = '"+serial + "' and Date_Sequenced !='NULL' order by analysis_id";
		  ResultSet results = stat.executeQuery(selectQuery);
		  
		  //Iterate over the result set
		  if(results.next())
		  {
			do	
			{
			   String analysis_id = results.getString("analysis_id");
			   Statement st1 = myConnection.createStatement();
			   //for each analysis_id get the QC information from the database
			   String innSelect = "select  * from view_run_metric where analysis_id ='" +  analysis_id + "'and Date_Sequenced !='NULL' group by lane";
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
		}catch(Exception e)
		{e.printStackTrace();}			
		finally
		{
			try
			{myConnection.close();}
			catch (SQLException e) 
			{e.printStackTrace();}
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

	/*
	 * Get files for the flowcell specific view
	 * Takes the flowcell as the input parameter and returns the files for the particular flowcell
	 */
	public FlowcellData getFilesforFlowcell(String serial) throws IllegalArgumentException
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
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;
			//create the connection
			myConnection = DriverManager.getConnection(dbURL);
			
			if(myConnection != null)
			{
				//create statement handle for executing queries
				Statement stat = myConnection.createStatement();
				//get the distinct files and their category from the file table for the given flowcell
				String selectQuery ="select distinct(f.file_fullpath), file_type.id_category, c.name from file f left outer join file_type on f.id_file_type = file_type.id left outer join category c on file_type.id_category = c.id where f.file_fullpath like'%"+serial + "%'";            
				ResultSet results = stat.executeQuery(selectQuery);
			
				Pattern pattern = Pattern.compile(".*/storage.+(flowcells|incoming|analysis|runs|gastorage[1|2])/");
				Matcher matcher;
				Pattern laneNumPattern = Pattern.compile("(s|"+serial+")_(\\d+)[\\._]+");
				Matcher laneNumMatcher;
				//Iterate over the result set
				if(results.next())
				{
					do	
						{
							String fullPath = results.getString("f.file_fullpath");
							String category = results.getString("c.name");
							LinkedHashMap<String,String> qcFileProperties = new LinkedHashMap<String,String>();	
							matcher = pattern.matcher(fullPath);
						
							if(matcher.find())
							{
								qcFileProperties.put("base", getFileName(fullPath));
								qcFileProperties.put("fullpath", fullPath);
								if(category == null)
									qcFileProperties.put("type", "Unknown");
								else
									qcFileProperties.put("type", category);
								
								qcFileProperties.put("label", fullPath.substring(matcher.end(), fullPath.lastIndexOf('/')));
								qcFileProperties.put("encfullpath", encryptURLEncoded(fullPath));
							
								laneNumMatcher = laneNumPattern.matcher(qcFileProperties.get("base"));
								if(laneNumMatcher.find())
										qcFileProperties.put("lane", laneNumMatcher.group(2));
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
	 }catch (Exception e) 
	 {e.printStackTrace();}
	 finally
	 {
		try {myConnection.close();}
		catch (SQLException e) 
		{e.printStackTrace();}
	 }
	return flowcell;
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
	 * Get files for the flowcell and add to the sampleData object
	 */
	public String getFileName(String fullPath)
	{
		int sep = fullPath.lastIndexOf('/');
		return fullPath.substring(sep+1,fullPath.length());
	}
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#encryptURLEncoded(java.lang.String)
	 * URLEncode the md5 and AES encrypted string
	 */
	@SuppressWarnings("deprecation")
	public String encryptURLEncoded(String srcText) throws IllegalArgumentException
	{
		return java.net.URLEncoder.encode(encryptString(srcText));
	}

	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getEncryptedData(java.lang.String, java.lang.String)
	 * remote method to md5 and then encrypt and url encode the input.
	 * returns an ArrayList of the encrypted data. 
	 */
	public ArrayList<String> getEncryptedData(String globalText) throws IllegalArgumentException 
	{
		try
		{
			ArrayList<String> retCipher = new ArrayList<String>();
			String mdGlobal = md5(globalText);
			//String mdLane = md5(laneText);
			String tempGlobal = globalText.concat(mdGlobal);
			//String tempLane = laneText.concat(mdLane);
			retCipher.add(encryptURLEncoded(tempGlobal));
			//retCipher.add(encryptURLEncoded(tempLane));
			return retCipher;
		}		
		catch (Exception e)
		{e.printStackTrace();}
		return null;
	}

	/*
	 * Method to get the md5 hash of the input string
	 * takes string as an input parameter
	 * and returns the md5 hash of the input string
	 */
	private static String md5(String text)
	{
		MessageDigest md;
		try
		{
			md = MessageDigest.getInstance("MD5");	
	        md.update(text.getBytes());
	        byte byteData[] = md.digest();
	 
	        //convert the byte to hex format method
	        StringBuffer sb = new StringBuffer();
	        for (int i = 0; i < byteData.length; i++) 
	        	sb.append(Integer.toString((byteData[i] & 0xff) + 0x100, 16).substring(1));
	        return sb.toString();
		} 
		catch (NoSuchAlgorithmException e)
		{e.printStackTrace();}
		return text;		
	}

	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#decryptKeyword(java.lang.String, java.lang.String)
	 * Method to decrypt the string parameters passed to the function.
	 */
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
			
			//Get the byte array using the BASE64Decoder
			byte[] fcellEncodedBytes = new BASE64Decoder().decodeBuffer(fcellData);
			byte[] laneEncodedBytes = new BASE64Decoder().decodeBuffer(laneData);
			byte[] fcellBytes = desCipher.doFinal(fcellEncodedBytes);
			byte[] laneBytes = desCipher.doFinal(laneEncodedBytes);
			//Get string of the decoded byte arrays
			fcellAfterDecrypt = new String(fcellBytes);
			laneAfterDecrypt = new String(laneBytes);
			System.out.println("laneAfterDecrypt is " + laneAfterDecrypt + "   fcellAfterDecrypt is " + fcellAfterDecrypt);
			String tempFcell = fcellAfterDecrypt.substring(0,fcellAfterDecrypt.length()-32);
			String tempLane = laneAfterDecrypt.substring(0, laneAfterDecrypt.length()-32);
			System.out.println("tempLane is " + tempLane + "   tempFcell is " + tempFcell);
			
			//Check the decrypted value with the md5 value 
			if(md5(tempLane).equals(laneAfterDecrypt.substring(laneAfterDecrypt.length()-32, laneAfterDecrypt.length())) && 
					md5(tempFcell).equals(fcellAfterDecrypt.substring(fcellAfterDecrypt.length()-32, fcellAfterDecrypt.length())))
			{
				//System.out.println("laneAfterDecrypt is " + laneAfterDecrypt + "   fcellAfterDecrypt is " + fcellAfterDecrypt);
				System.out.println("tempLane is " + tempLane + "   tempFcell is " + tempFcell);
				decryptedContents.add(tempFcell);
				decryptedContents.add(tempLane);
				return decryptedContents;
			}
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		//Else add the original string into the decryptedContents array
		decryptedContents.add(fcellData);
		decryptedContents.add(laneData);
		return decryptedContents;
	}

	/*
	 * Method to AES encrypt the given string.
	 * return the cipher text after AES encryption. 
	 */
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
		{e.printStackTrace();}
		return srcText;
	}
	
	/*
	 * Method to format the given input string.
	 */
	
	public String NoFormat(String temp)
	{
		NumberFormat formatter = NumberFormat.getInstance();
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
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getCSVFromDisk(java.lang.String)
	 * Function to read data points from the given file to display plots
	 */
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
	
	
	/*
	 * Function to get a String of Metrics to display to the user
	 */
	public String getUserMeticNames()
	{
		 StringBuilder userMetric = new StringBuilder();
		java.sql.Connection myConnection = null;
		try
		{
		  Class.forName("com.mysql.jdbc.Driver").newInstance(); 
		  //database connection code 
		  String username = "zack";
		  String password = "LQSadm80";
		  //URL to connect to the database
		  String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
			  + username + "&password=" + password;
		  //create the connection
		  myConnection = DriverManager.getConnection(dbURL);
		  //create statement handle for executing queries
		  Statement stat = myConnection.createStatement();
		  //get the metrics for the user(guest user)
		  String selectQuery ="select metric from metric order by id where usage_enum = 'user'";
		  
		  //String selectItems = "flowcell_serial, sample_name, lane, geneusID_sample, organism, protocol, ControlLane,  barcode, Date_Sequenced, RunParam_RTAVersion, contamSeqs, genome";
		  //String selectQuery = "select " + selectItems + " from metric";  
		  ResultSet results = stat.executeQuery(selectQuery);
		  //Iterate over the result set
		  String prefix = "";
		  while(results.next())
		  {
			  userMetric.append(prefix);
			  prefix=",";
			  userMetric.append(results.getString("metric"));
			System.out.println("the appended string is " + userMetric.toString());
		  }
		}
		catch(Exception e)
		{e.printStackTrace();}
		finally
		{
			try {
				myConnection.close();
			 } catch (SQLException e) {
				e.printStackTrace();
			 }
		}
		System.out.println("the user Metrics string is " + userMetric.toString());
		return userMetric.toString();
	}
	
	/*********************************************************************
	 * Functions to get Methylation data ("OLD" stack panel view)   
	 *********************************************************************
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
					{System.out.println(e.getMessage());}
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

	/*********************************************************************
	 * Functions to get HPCC PBS status information ("OLD" stack panel view)   
	 *********************************************************************
	 */
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
	
	/*********************************************************************
	 * Functions to clear contents of Cache ("OLD" stack panel view)   
	 *********************************************************************
	 */
/*
 * (non-Javadoc)
 * @see edu.usc.epigenome.eccp.client.ECService#clearCache(java.lang.String)
 * function to clear the contents of cache in the /tmp directory
 */
	public String clearCache(String cachefile)
	{
		String[] cachefiles = {"/tmp/genFileCache", "/tmp/genURLcache"};
		for(String f : cachefiles)
			if(cachefile.contentEquals(f))
				new File(f).delete();
		
		return "cache cleared";
	}
	
	public ArrayList<FlowcellData> getAnalysisFromFS() throws IllegalArgumentException 
	{	
		return null;
	}

	
	
	/*********************************************************************
	 * Extra Functions
	 *********************************************************************
	 */
	
	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.ECService#getSampleFromGeneus()
	 * Get a list of all the samples from the database
	 */
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
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct geneusId's 
			String selectQuery ="select distinct(geneus_id) from sample order by id";
			ResultSet results = stat.executeQuery(selectQuery);
			
			//For each of the samples,  Get sample properties 
			 if(results.next())
			 {
			   do
			   {
				   String libraryID = results.getString("geneus_id");
				   SampleData sample = new SampleData();
				   
				   Statement st1 = myConnection.createStatement();
				   //Query to select properties for a sampleID
				   String samplePropSelect = "select project, organism, Date_Sequenced, sample_name from view_run_metric where geneusID_sample ='"+libraryID + "'";            
				   ResultSet rs1 = st1.executeQuery(samplePropSelect);
				   //Iterate over the resultSet and add sampleProperties
				   while(rs1.next())
				   {
					   sample.sampleProperties.put("geneusID_sample", libraryID);
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
					   sample.sampleProperties.put("library", rs1.getString("sample_name"));
				   }
				   rs1.close();
				   st1.close();
				   
				 /*  st1 = myConnection.createStatement();
				   String sampFlowcell = "select distinct(flowcell_serial) from view_run_metric where geneusID_sample = '"+libraryID +"'";
				   rs1 = st1.executeQuery(sampFlowcell);
				   
				   while(rs1.next())
				   {
					  String flowcellID = rs1.getString("flowcell_serial");
					  FlowcellData flowcellProp = new FlowcellData();
					  //HashMap<String, String> flowcellProp = new HashMap<String, String>();
					  Statement st2 = myConnection.createStatement();
					  String fcellPropSelect = "select technician, geneusId_run, protocol, ControlLane from view_run_metric where geneusID_sample ='"+libraryID+"' and flowcell_serial ='"+flowcellID+"'";
					  ResultSet rs2 = st2.executeQuery(fcellPropSelect);
					  
					  while(rs2.next())
					  {
						  flowcellProp.flowcellProperties.put("technician", rs2.getString("technician").replace("å", ""));
						  flowcellProp.flowcellProperties.put("geneusId_run", rs2.getString("geneusId_run"));
						 // flowcellProp.put("technician", rs2.getString("technician").replace("å", ""));
						  //flowcellProp.put("geneusId_run", rs2.getString("geneusId_run"));
					  }
					  rs2.close();
					  st2.close();
					  sample.sampleFlowcells.put(flowcellID, flowcellProp);
					  //sample.flowcellInfo.put(flowcellID, flowcellProp);
				   }
				   rs1.close();
				   st1.close();*/
				   
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
	
	public ArrayList<FlowcellData> getFlowcellsTreeGeneus() throws IllegalArgumentException
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
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct geneusId's 
			String selectQuery ="select distinct(flowcell_serial) from view_run_metric";
			ResultSet results = stat.executeQuery(selectQuery);
			
			//Iterate over the resultset consisting of GeneusID(limsid)
		   if(results.next())
		   {
		     do
			 {
		    	 FlowcellData flowcell = new FlowcellData();
		    	 String fcellSerial = results.getString("flowcell_serial");
		    	 Statement st1 = myConnection.createStatement();
		    	 //for each geneusid get the flowcell serial no, protocol, technician, the date and the control lane 
		    	 String innSelect = "select  protocol, technician, Date_Sequenced, ControlLane from view_run_metric where flowcell_serial ='"+fcellSerial + "' group by flowcell_serial";            
		    	 ResultSet rs = st1.executeQuery(innSelect);
		    	 //Iterate over the resultset and add the flowcellproperties for each of the flowcells
		    	 while(rs.next())
		    	 {
		    		 flowcell.flowcellProperties.put("serial", fcellSerial);
		    		 //flowcell.flowcellProperties.put("limsID", fcellSerial);
		    		 flowcell.flowcellProperties.put("technician", rs.getString("technician").replace("å", ""));
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
				String LaneProp ="select distinct(lane) from view_run_metric where flowcell_serial ='"+fcellSerial+"'";
				ResultSet RsProp = statLane.executeQuery(LaneProp);	
				//Iterate over the lane numbers 
				while(RsProp.next())
				{
					int lane_no =  RsProp.getInt("lane");
					HashMap<String,String> sampleData = new HashMap<String,String>();
					Statement cellprop = myConnection.createStatement();
					//for each lane of a flowcell get the processing, sample_name, organism and project associated with it.
					String st2 ="select processing, sample_name, geneusID_sample, organism, project from view_run_metric where geneusID_run ='"+fcellSerial+"' and lane ="+ lane_no;
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
						   singleFcell.flowcellProperties.put("technician", fcellResult.getString("technician").replace("å", ""));
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
	/*
	 
	
	/*public ArrayList<SampleData> getProjectsFromGeneus() throws IllegalArgumentException
	{
		ArrayList<SampleData> projSamples = new ArrayList<SampleData>();
		java.sql.Connection myConnection = null;
		try
		{
			Class.forName("com.mysql.jdbc.Driver").newInstance(); 

			//database connection parameters 
			String username = "zack";
			String password = "LQSadm80";

			//URL for database connection
			String dbURL = "jdbc:mysql://epifire2.epigenome.usc.edu:3306/sequencing_devel?user="
				+ username + "&password=" + password;

			//create the connection
			 myConnection = DriverManager.getConnection(dbURL);

			//create statement handle for executing queries
			Statement stat = myConnection.createStatement();
			//Get all the distinct projects
			String selectQuery ="select distinct(project) from view_run_metric order by Date_Sequenced";
			ResultSet results = stat.executeQuery(selectQuery);
			
			 if(results.next())
			 {
			   do
			   {
				   String project = results.getString("project");
				   SampleData sample = new SampleData();
				   sample.projectProperties.put("project", project);
				   
				   projSamples.add(sample);
			   }while(results.next());
			}
		}
		catch(Exception e)
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
		return projSamples;
	}*/
	
	
	

	
}
