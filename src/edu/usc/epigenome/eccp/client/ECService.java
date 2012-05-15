package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;

/**
 * The client side stub for the RPC service.
 */
@RemoteServiceRelativePath("ecservice")
public interface ECService extends RemoteService
{
	ArrayList<LibraryData> getLibraries(LibraryDataQuery queryParams);
	// Utility Functions
	//Encrypt the contents passed for Guest User
	ArrayList<String> getEncryptedData(String globalText) throws IllegalArgumentException;
	//Get the csv files for generating file list for plots
	String getCSVFromDisk(String filePath) throws IllegalArgumentException;	
}
