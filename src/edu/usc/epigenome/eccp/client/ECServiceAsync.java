package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.user.client.rpc.AsyncCallback;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;


/**
 * The async counterpart of <code>GreetingService</code>.
 */
public interface ECServiceAsync
{
	void getLibraries(LibraryDataQuery queryParams, AsyncCallback<ArrayList<LibraryData>> callback);
	
	//Get projects from sample view
	void decryptSearchProject(String toSearch, AsyncCallback<HashMap<String, ArrayList<String>>>callback) throws IllegalArgumentException;
	//Get the files for the plots
	void getCSVFiles(String run_id, String serial, String sampleID, AsyncCallback<FlowcellData> callback) throws IllegalArgumentException;
	void getCSVFromDisk(String filePath, AsyncCallback<String> String) throws IllegalArgumentException;
	void encryptURLEncoded(String srcText, AsyncCallback<String> callback);
	void getEncryptedData(String globalText, AsyncCallback<ArrayList<String>> callback);
	void decryptKeyword(String fcellText, String laneText, AsyncCallback<ArrayList<String>> callback);
	

	
}
