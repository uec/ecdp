<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.util.*,java.io.*,java.sql.DriverManager,java.sql.ResultSet,java.sql.ResultSetMetaData,java.sql.SQLException,java.sql.Statement,javax.naming.*,javax.sql.DataSource,edu.usc.epigenome.eccp.server.ECServiceBackend,edu.usc.epigenome.eccp.client.data.*" %><%
try{
	java.sql.Connection myConnection = null;
	Context initContext = new InitialContext();
	Context envContext = (Context)initContext.lookup("java:/comp/env");
	DataSource ds = (DataSource)envContext.lookup("jdbc/sequencing");
	
	if(ds != null)
		myConnection =ds.getConnection();
	
	if(myConnection != null)
	{
	 Statement stat = myConnection.createStatement();
	if((request.getParameter("fcserial") != null) && (!request.getParameter("fcserial").isEmpty()) && (request.getParameter("report").equals("rep1")))
	{
		String fcell_serial = request.getParameter("fcserial");
		//Get data wrt to the given flowcell 
		String selectQuery ="select flowcell_serial, lane, geneusID_sample, sample_name, analysis_id, sample_name, ControlLane, processing, technician from sequencing.view_run_metric where flowcell_serial ='"+fcell_serial + "'";
		ResultSet results = stat.executeQuery(selectQuery);
		ServletOutputStream myOut = null;
		try
		{
			myOut = response.getOutputStream();
			response.setContentType("text/plain");
			response.addHeader("Content-Disposition", "inline; filename=" + fcell_serial + "_sample.csv");
			int cols = results.getMetaData().getColumnCount();

			myOut.print("FCID" + "," + "Lane" + "," + "SampleID" + "," + "SampleRef" + "," + "Index"  + "," + "Description" + "," + "Control" + "," +"Recipe" + "," + "Operator");
			myOut.println();
			while(results.next())
			{
				for(int i=1;i<=cols;i++)
				{
					if(i == 5 || i == 8)
						myOut.print("Unknown");
					else
					myOut.print(results.getString(i));
					
					myOut.print(",");
				}
				myOut.println();
			}
		}
		catch (IOException ioe)
		{
			out.println("Unauthorized File Request");	
			throw new ServletException(ioe.getMessage());
		}	 
		finally
		{
			if (myOut != null)
				myOut.close();
		}
	}
	else if((request.getParameter("fcserial") != null) && (!request.getParameter("fcserial").isEmpty()) && (request.getParameter("report").equals("rep2")))
	{
		String fcell_serial = request.getParameter("fcserial");
		//Get data wrt to the given flowcell 
		String selectQuery ="select geneusID_sample, lane, sample_name, processing, Clusters_PF_R2 from sequencing.view_run_metric where flowcell_serial ='"+fcell_serial + "'";
		ResultSet results = stat.executeQuery(selectQuery);
	
		ServletOutputStream myOut = null;
		try
		{
			myOut = response.getOutputStream();
			response.setContentType("text/plain");
			response.addHeader("Content-Disposition", "inline; filename=" + fcell_serial + "_pipeline.txt");
			int i=0;
		
			myOut.print("ClusterSize = 8" + "\n" + "queue = laird" + "\n" + "FlowcellName = " + fcell_serial + "\n" +  "MinMismatches = 2 " + "\n" + "MaqPileupQ = 30" + "\n" + "referenceLane = 1 " + "\n" + "randomSubset = 300000");
			myOut.println();
			while(results.next())
			{
				myOut.println();
				i++;
				myOut.println("Sample."+ i + ".SampleID = " + results.getString("geneusID_sample"));
				String lane = results.getString("lane");
				myOut.println("Sample."+ i + ".Lane = " + lane);
				if(results.getString("Clusters_PF_R2").equals("0"))
					myOut.println("Sample."+ i + ".Input = s_" + lane + "_1_sequence.txt,s_" + lane + "_2_sequence.txt");
				else
					myOut.println("Sample."+ i + ".Input = s_1_sequence.txt,s_2_sequence.txt");
				
				if(results.getString("processing").contains("ChIP-seq"))
					myOut.println("Sample."+ i + ".Workflow = Chipseq");
				else if(results.getString("processing").contains("BS-seq"))
					myOut.println("Sample."+ i + ".Workflow = Bisulfite");
				else if(results.getString("processing").contains("RNA-seq"))
					myOut.println("Sample."+ i + ".Workflow = RNA-seq");
				else
					myOut.println("Sample."+ i + ".Workflow = Basic");
				
				myOut.println("Sample."+ i + ".Reference = hg18");
			}
			myOut.println();
		}
		catch (IOException ioe)
		{
			out.println("Unauthorized File Request");	
			throw new ServletException(ioe.getMessage());
		}	 
		finally
		{
			if (myOut != null)
				myOut.close();
		}
	}
  }
}catch(Exception exp){out.println("No project exists by this name");}
	%>
	