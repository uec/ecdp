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

import com.google.gwt.user.server.rpc.RemoteServiceServlet;


/**
 * The server side implementation of the RPC service.
 */
@SuppressWarnings("serial")
public class ECServiceBackend extends RemoteServiceServlet implements ECService
{
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

	@Override
	public ArrayList<FlowcellData> getFlowcellsAll()
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ArrayList<FlowcellData> getFlowcellsFromFS()
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ArrayList<FlowcellData> getFlowcellsIncomplete()
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ArrayList<FlowcellData> getFlowcellsComplete()
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public FlowcellData getQCforFlowcell(String serial)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public FlowcellData getFilesforFlowcell(String serial)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getCSVFromDisk(String filePath)
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ArrayList<FlowcellData> getAnalysisFromFS()
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ArrayList<MethylationData> getMethFromGeneus()
			throws IllegalArgumentException {
		// TODO Auto-generated method stub
		return null;
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
}
