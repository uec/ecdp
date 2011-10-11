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
		String selectQuery ="select flowcell_serial, lane, geneusID_sample, sample_name, barcode, sample_name, ControlLane, processing, technician from sequencing.view_run_metric where flowcell_serial ='"+fcell_serial + "' group by geneusID_sample, lane order by lane";
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
					if(i == 8)
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
		String selectQuery ="select geneusID_sample, lane, sample_name, barcode,  project, processing, protocol, organism from sequencing.view_run_metric where flowcell_serial ='"+fcell_serial + "'";
		ResultSet results = stat.executeQuery(selectQuery);
	
		ServletOutputStream myOut = null;
		try
		{
			myOut = response.getOutputStream();
			response.setContentType("text/plain");
			response.addHeader("Content-Disposition", "inline; filename=" + fcell_serial + "_pipeline.txt");
			int i=0;
		
			myOut.print("ClusterSize = 1" + "\n" + "queue = laird" + "\n" + "FlowCellName = " + fcell_serial + "\n" +  "MinMismatches = 2 " + "\n" + "MaqPileupQ = 30" + "\n" + "referenceLane = 1 " + "\n" + "randomSubset = 300000");
			myOut.println();
			while(results.next())
			{
				myOut.println();
				i++;
				myOut.println("#Sample: " + results.getString("sample_name") + " (" + results.getString("project") + ")");
				myOut.println("Sample."+ i + ".SampleID = " + results.getString("geneusID_sample"));
				String lane = results.getString("lane");
				String barcode = results.getString("barcode");
				myOut.println("Sample."+ i + ".Lane = " + lane);
				
				if(results.getString("protocol").contains("Paired"))
				{
					if(results.getString("barcode").contains("NO BARCODE"))
						myOut.println("Sample."+ i + ".Input = s_" + lane + "_1_sequence.txt,s_" + lane + "_2_sequence.txt");
					else
						myOut.println("Sample."+ i + ".Input = s_" + lane + "_1_" + barcode +"_sequence.txt,s_" + lane + "_2_" + barcode + "_sequence.txt");
				}
				else if(results.getString("protocol").contains("Single"))
				{
					if(results.getString("barcode").contains("NO BARCODE"))
						myOut.println("Sample."+ i + ".Input = s_" + lane + "_sequence.txt");
					else
						myOut.println("Sample."+ i + ".Input = s_" + lane + "_" + barcode + "_sequence.txt");
				}
				
				if(results.getString("processing").contains("ChIP-seq"))
					myOut.println("Sample."+ i + ".Workflow = chipseq");
				else if(results.getString("processing").contains("BS-seq"))
					myOut.println("Sample."+ i + ".Workflow = bisulfite");
				else if(results.getString("processing").contains("RNA-seq"))
					myOut.println("Sample."+ i + ".Workflow = rnaseq");
				else
					myOut.println("Sample."+ i + ".Workflow = regular");
				
				
				if(results.getString("organism").contains("Mus"))
					myOut.println("Sample."+ i + ".Reference = /home/uec-00/shared/production/genomes/mm9_unmasked/mm9_unmasked.fa");
				else if(results.getString("organism").contains("Phi"))
					myOut.println("Sample."+ i + ".Reference = /home/uec-00/shared/production/genomes/phi-X174/phi_plus_SNPs.fa");
				else if(results.getString("processing").contains("RNA-seq"))
					myOut.println("Sample."+ i + ".Reference = /home/uec-00/shared/production/genomes/bowtie/hg19");
				else if(results.getString("processing").contains("BS-seq"))
					myOut.println("Sample."+ i + ".Reference = /home/uec-00/shared/production/genomes/hg19_rCRSchrm/hg19_rCRSchrm.fa");
				else
					myOut.println("Sample."+ i + ".Reference = /home/uec-00/shared/production/genomes/hg19_rCRSchrm/hg19_rCRSchrm.fa");
	
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