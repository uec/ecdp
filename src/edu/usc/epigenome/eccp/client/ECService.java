package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.data.LibraryProperty;

/**
 * The client side stub for the RPC service.
 */
@RemoteServiceRelativePath("ecservice")
public interface ECService extends RemoteService
{
	ArrayList<LibraryData> getLibraries(LibraryDataQuery queryParams);
	String getLibrariesJSON(LibraryDataQuery queryParams);
	// Utility Functions
	//Encrypt the contents passed for Guest User
	ArrayList<String> getEncryptedData(String globalText) throws IllegalArgumentException;
	//Get the csv files for generating file list for plots
	String getCSVFromDisk(String filePath) throws IllegalArgumentException;
	String createMergeWorkflow(List<LibraryData> libs);
	String getIlluminaParams(String flowcell);
	String getWorkflowParams(String flowcell);
	String logWriter(String text);
	ArrayList<LibraryProperty> getSummaryColumns();
}
