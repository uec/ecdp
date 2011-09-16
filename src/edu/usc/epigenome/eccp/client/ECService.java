package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;

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
	//Flowcell reporting
	ArrayList<FlowcellData> getFlowcellsAll() throws IllegalArgumentException;
	ArrayList<FlowcellData> getFlowcellsFromGeneus() throws IllegalArgumentException;
	ArrayList<FlowcellData> getFlowcellsFromFS() throws IllegalArgumentException;
	ArrayList<FlowcellData> getFlowcellsIncomplete() throws IllegalArgumentException;
	ArrayList<FlowcellData> getFlowcellsComplete() throws IllegalArgumentException;
	ArrayList<SampleData> getSampleFromGeneus() throws IllegalArgumentException;
	ArrayList<SampleData> getSampleDataFromGeneus() throws IllegalArgumentException;
	
	FlowcellData getQCforFlowcell(String serial) throws IllegalArgumentException;
	FlowcellData getQCSampleFlowcell(String serial, String sampleID, int laneNo) throws IllegalArgumentException;
	FlowcellData getFilesforFlowcell(String serial) throws IllegalArgumentException;
	//SampleData getFilesforFlowcellLane(String serial) throws IllegalArgumentException;
	FlowcellData getFilesforRunSample(String run_id, String serial, String sampleID) throws IllegalArgumentException;
	
	FlowcellData getCSVFiles(String run_id, String serial, String sampleID) throws IllegalArgumentException;
	String getCSVFromDisk(String filePath) throws IllegalArgumentException;
	//Flowcell (Merged) Analysis Reporting
	ArrayList<FlowcellData> getAnalysisFromFS() throws IllegalArgumentException;
	
	//Methylation Reporting
	ArrayList<MethylationData> getMethFromGeneus() throws IllegalArgumentException;	
	MethylationData getFilesForMeth(String serial) throws IllegalArgumentException;
	MethylationData getQCforMeth(String serial) throws IllegalArgumentException;

	//PBS reporting
	public String[] qstat(String queue);
	//Cache management
	String clearCache(String cachefile) throws IllegalArgumentException;
	
	String encryptURLEncoded(String srcText) throws IllegalArgumentException;
	ArrayList<String> getEncryptedData(String globalText, String laneText) throws IllegalArgumentException;
	ArrayList<String> decryptKeyword(String fcellText, String laneText)throws IllegalArgumentException;
	FlowcellData getLaneFlowcellSample(String string, String flowcellSerial) throws IllegalArgumentException;
	SampleData getFlowcellsforSample(String sampleProperty) throws IllegalArgumentException;
	
	
}
