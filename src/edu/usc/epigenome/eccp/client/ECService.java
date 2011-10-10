package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.MethylationData;
import edu.usc.epigenome.eccp.client.data.SampleData;

/**
 * The client side stub for the RPC service.
 */
@RemoteServiceRelativePath("ecservice")
public interface ECService extends RemoteService
{
	/*
	 * Flowcell reporting
	 */
	ArrayList<FlowcellData> getFlowcellsAll() throws IllegalArgumentException;
	ArrayList<FlowcellData> getFlowcellsFromGeneus() throws IllegalArgumentException;
	ArrayList<FlowcellData> getFlowcellsFromFS() throws IllegalArgumentException;
	ArrayList<FlowcellData> getFlowcellsIncomplete() throws IllegalArgumentException;
	ArrayList<FlowcellData> getFlowcellsComplete() throws IllegalArgumentException;
	//Get QC for the given flowcell serial
	FlowcellData getQCforFlowcell(String serial) throws IllegalArgumentException;
	//Get files for flowcell
	FlowcellData getFilesforFlowcell(String serial) throws IllegalArgumentException;
	//Flowcell (Merged) Analysis Reporting
	ArrayList<FlowcellData> getAnalysisFromFS() throws IllegalArgumentException;
	
	/*
	 * Sample Reporting (For tree view structure)
	 */
	ArrayList<SampleData> getSampleFromGeneus() throws IllegalArgumentException;
	//Get projects from geneus
	ArrayList<String> getProjectsFromGeneus(String toSearch, boolean yesSearch) throws IllegalArgumentException;
	HashMap<String, ArrayList<String>> decryptSearchProject(String toSearch) throws IllegalArgumentException;
	
	
	//Get QC for the given sample, flowcell and laneNo (for tree view flowcell and sample)
	FlowcellData getQCSampleFlowcell(String serial, String sampleID, int laneNo, String userType) throws IllegalArgumentException;
	//Get the files for given run_id, flowcell serial and sample
	FlowcellData getFilesforRunSample(String run_id, String serial, String sampleID) throws IllegalArgumentException;
	//Get the csv files for generating file list for plots
	FlowcellData getCSVFiles(String run_id, String serial, String sampleID) throws IllegalArgumentException;
	//Get the lane for given flowcell and sample
	FlowcellData getLaneFlowcellSample(String sample_name, String flowcellSerial) throws IllegalArgumentException;
	//Get the flowcells for a given sample_name
	SampleData getFlowcellsforSample(String sampleProperty) throws IllegalArgumentException;
	//Get Samples for the given project (use the searchString to perform search if boolean variable is yes)
	ArrayList<SampleData>getSamplesForProject(String projectName, String searchString, boolean yes) throws IllegalArgumentException;
	String getCSVFromDisk(String filePath) throws IllegalArgumentException;
	
	
	/*
	 * Methylation Reporting
	 */
	ArrayList<MethylationData> getMethFromGeneus() throws IllegalArgumentException;	
	MethylationData getFilesForMeth(String serial) throws IllegalArgumentException;
	MethylationData getQCforMeth(String serial) throws IllegalArgumentException;

	//PBS reporting
	public String[] qstat(String queue);
	//Cache management
	String clearCache(String cachefile) throws IllegalArgumentException;
	
	/*
	 * Utility Functions
	 */
	//Encrypt the given string 
	String encryptURLEncoded(String srcText) throws IllegalArgumentException;
	//Encrypt the contents passed for Guest User
	ArrayList<String> getEncryptedData(String globalText) throws IllegalArgumentException;
	//Decrypt the contents passed for Guest User
	ArrayList<String> decryptKeyword(String fcellText, String laneText)throws IllegalArgumentException;
	
}
