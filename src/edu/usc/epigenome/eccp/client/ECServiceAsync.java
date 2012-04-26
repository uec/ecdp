package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.user.client.rpc.AsyncCallback;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.data.SampleData;

/**
 * The async counterpart of <code>GreetingService</code>.
 */
public interface ECServiceAsync
{
	void getFlowcellsAll(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	void getFlowcellsFromGeneus(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	
	//Get projects from sample view
	void getProjectsFromGeneus(String toSearch, boolean yesSearch, AsyncCallback<ArrayList<String>> callback) throws IllegalArgumentException;
	void decryptSearchProject(String toSearch, AsyncCallback<HashMap<String, ArrayList<String>>>callback) throws IllegalArgumentException;
	
	void getSamplesForProject(String projectName, String searchString, boolean yes, AsyncCallback<ArrayList<SampleData>> callback) throws IllegalArgumentException;
	
	void getSampleFromGeneus(AsyncCallback<ArrayList<SampleData>> callback) throws IllegalArgumentException;
	//Get QC for given flowcell (flowcell view)
	void getQCforFlowcell(String serial,AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	//Get QC for the given flowcell, sample and lane (sample view)
	void getQCSampleFlowcell(String serial, String sampleID,int laneNo, String userType, AsyncCallback<FlowcellData> callback);
	
	//Get files for a given flowcell (flowcell view)
	void getFilesforFlowcell(String serial,AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	//Get the files for Files Download section for the sample view
	void getFilesforRunSample(String run_id, String serial, String sampleID, AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	//Get the files for the plots
	void getCSVFiles(String run_id, String serial, String sampleID, AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	void getCSVFromDisk(String filePath, AsyncCallback<String> String) throws IllegalArgumentException;
	void getAnalysisFromFS(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	
	
	void encryptURLEncoded(String srcText, AsyncCallback<String> callback);
	void getEncryptedData(String globalText, AsyncCallback<ArrayList<String>> callback);
	void decryptKeyword(String fcellText, String laneText, AsyncCallback<ArrayList<String>> callback);
	
	void getLaneFlowcellSample(String string, String flowcellSerial,AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	void getFlowcellsforSample(String sampleProperty,AsyncCallback<SampleData> asyncCallback)throws IllegalArgumentException;
	void getQCTypes(AsyncCallback<HashMap<String, String>> callback);
	void getLibraries(LibraryDataQuery queryParams, AsyncCallback<ArrayList<LibraryData>> callback);
}
