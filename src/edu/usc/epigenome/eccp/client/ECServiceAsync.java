package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.MethylationData;
import edu.usc.epigenome.eccp.client.data.SampleData;

/**
 * The async counterpart of <code>GreetingService</code>.
 */
public interface ECServiceAsync
{
	void getFlowcellsAll(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	void getFlowcellsFromGeneus(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	void getFlowcellsFromFS(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	void getFlowcellsIncomplete(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	void getFlowcellsComplete(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	void getSampleFromGeneus(AsyncCallback<ArrayList<SampleData>> callback) throws IllegalArgumentException;
	void getQCforFlowcell(String serial,AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	void getQCSampleFlowcell(String serial, String sampleID,
			AsyncCallback<FlowcellData> callback);
	
	void getFilesforFlowcell(String serial,AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	
	//void getFilesforFlowcellLane(String serial, AsyncCallback<SampleData> callback) throws IllegalArgumentException;
	void getCSVFiles(String serial, AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	
	void getCSVFromDisk(String filePath, AsyncCallback<String> String) throws IllegalArgumentException;
	void getAnalysisFromFS(AsyncCallback<ArrayList<FlowcellData>> callback) throws IllegalArgumentException;
	
	void getMethFromGeneus(AsyncCallback<ArrayList<MethylationData>> callback) throws IllegalArgumentException;
	void getFilesForMeth(String serial, AsyncCallback<MethylationData> callback)  throws IllegalArgumentException;
	void getQCforMeth(String serial, AsyncCallback<MethylationData> callback)  throws IllegalArgumentException;
	
	void clearCache(String cachefile, AsyncCallback<String> callback) throws IllegalArgumentException;
	void qstat(String queue, AsyncCallback<String[]> result) throws IllegalArgumentException;
	void encryptURLEncoded(String srcText, AsyncCallback<String> callback);
	void getEncryptedData(String globalText, String laneText, AsyncCallback<ArrayList<String>> callback);
	void decryptKeyword(String fcellText, String laneText, AsyncCallback<ArrayList<String>> callback);
	
	void getSampleDataFromGeneus(AsyncCallback<ArrayList<SampleData>> callback) throws IllegalArgumentException;
	void getLaneFlowcellSample(String string, String flowcellSerial,AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	void getFlowcellsforSample(String sampleProperty,AsyncCallback<SampleData> asyncCallback)throws IllegalArgumentException;
}
