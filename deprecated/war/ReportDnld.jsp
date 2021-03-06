<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.util.*,java.io.*,java.sql.DriverManager,java.sql.ResultSet,java.sql.ResultSetMetaData,java.sql.SQLException,java.sql.Statement,javax.naming.*,javax.sql.DataSource,edu.usc.epigenome.eccp.server.ECServiceBackend,edu.usc.epigenome.eccp.client.data.*" %><%
try{
	java.sql.Connection myConnection = null;
	Context initContext = new InitialContext();
	Context envContext = (Context)initContext.lookup("java:/comp/env");
	DataSource ds = (DataSource)envContext.lookup("jdbc/sequencing_devel");
	
	if(ds != null)
		myConnection =ds.getConnection();
	
	if(myConnection != null)
	{
	 Statement stat = myConnection.createStatement();
	if((request.getParameter("fcserial") != null) && (!request.getParameter("fcserial").isEmpty()) && (request.getParameter("report").equals("rep1")))
	{
		String fcell_serial = request.getParameter("fcserial");
		//Get data wrt to the given flowcell 
		String selectQuery ="select flowcell_serial, lane, geneusID_sample, sample_name, barcode, sample_name, ControlLane, processing, technician from view_run_metric where flowcell_serial ='"+fcell_serial + "' group by geneusID_sample, lane order by lane";
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
		String selectQuery ="select geneusID_sample, lane, sample_name, barcode,  project, processing, protocol, organism from view_run_metric where flowcell_serial ='"+fcell_serial + "' group by geneusID_sample, lane order by lane";
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
				myOut.println("#Sample: " + results.getString("sample_name") + " (" + results.getString("project") + " of " + results.getString("organism") +")");
				myOut.println("Sample."+ i + ".SampleID = " + results.getString("geneusID_sample"));
				String lane = results.getString("lane");
				String barcode = results.getString("barcode");
				myOut.println("Sample."+ i + ".Lane = " + lane);
				
				if(results.getString("protocol").contains("Paired"))
				{
					if(results.getString("barcode").contains("NO BARCODE"))
						myOut.println("Sample."+ i + ".Input = " + results.getString("sample_name") + "_NoIndex_L00" + lane + "_R1_001.fastq.gz," + results.getString("sample_name") + "_NoIndex_L00" + lane + "_R2_001.fastq.gz");
					else
						myOut.println("Sample."+ i + ".Input = " + results.getString("sample_name") + "_" + barcode + "_L00" + lane + "_R1_001.fastq.gz," + results.getString("sample_name") + "_" + barcode + "_L00" + lane + "_R2_001.fastq.gz");
				}
				else if(results.getString("protocol").contains("Single"))
				{
					if(results.getString("barcode").contains("NO BARCODE"))
						myOut.println("Sample."+ i + ".Input = " + results.getString("sample_name") + "_NoIndex_L00" + lane + "_R1_001.fastq.gz");
					else
						myOut.println("Sample."+ i + ".Input = " + results.getString("sample_name") + "_" + barcode + "_L00" + lane + "_R1_001.fastq.gz");
				}
				
				String workflow = "unaligned";
				String genome = "/home/uec-00/shared/production/genomes/unaligned/unaligned.fa";
				
				if(results.getString("processing").toLowerCase().contains("chip"))
					workflow = "chipseq";
				else if(results.getString("processing").toLowerCase().contains("bs") || results.getString("processing").toLowerCase().contains("silfit"))
					workflow = "bisulfite";
				else if(results.getString("processing").toLowerCase().contains("rna"))
					workflow = "rnaseqv2";
				else if(results.getString("processing").toLowerCase().contains("genom") || results.getString("processing").toLowerCase().contains("regul"))
					workflow = "regular";
				
				
				
				if(results.getString("organism").toLowerCase().contains("mus"))
					genome = "/home/uec-00/shared/production/genomes/mm9_unmasked/mm9_unmasked.fa";
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
					if(results.getString("processing").toLowerCase().contains("rna") || results.getString("processing").toLowerCase().contains("chip") )
						genome = "/home/uec-00/shared/production/genomes/encode_hg19_mf/male.hg19.fa";
					else
						genome = "/home/uec-00/shared/production/genomes/hg19_rCRSchrm/hg19_rCRSchrm.fa";
				}
				
				//handle rnaseq genomes
				if(results.getString("processing").toLowerCase().contains("rna"))
					genome = genome.substring(0, genome.length() - 3);
				
				myOut.println("Sample."+ i + ".Workflow = " + workflow);
				myOut.println("Sample."+ i + ".Reference = " + genome);
				
				
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
	
