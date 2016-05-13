package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.data.LibraryProperty;


/**
 * The async counterpart of <code>GreetingService</code>.
 */
public interface ECServiceAsync
{
	void getLibraries(LibraryDataQuery queryParams, AsyncCallback<ArrayList<LibraryData>> callback);
	
	//Get the files for the plots
	void getCSVFromDisk(String filePath, AsyncCallback<String> String) throws IllegalArgumentException;
	void getEncryptedData(String globalText, AsyncCallback<ArrayList<String>> callback);

	//create a merging workflow for use at hpcc
	void createMergeWorkflow(List<LibraryData> libs, AsyncCallback<String> callback);

	void getLibrariesJSON(LibraryDataQuery queryParams, AsyncCallback<String> callback);

	void getIlluminaParams(String flowcell, AsyncCallback<String> callback);

	void getWorkflowParams(String flowcell, AsyncCallback<String> callback);
	void logWriter(String text, AsyncCallback<String> callback);

	void getSummaryColumns(AsyncCallback<ArrayList<LibraryProperty>> callback);
}
