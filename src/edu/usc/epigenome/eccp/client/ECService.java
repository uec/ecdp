package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;

/**
 * The client side stub for the RPC service.
 */
@RemoteServiceRelativePath("ecservice")
public interface ECService extends RemoteService
{
	ArrayList<LibraryData> getLibraries(LibraryDataQuery queryParams);

	
	
	/*
	 * Utility Functions
	 */
	//Encrypt the given string 
	String encryptURLEncoded(String srcText) throws IllegalArgumentException;
	//Encrypt the contents passed for Guest User
	ArrayList<String> getEncryptedData(String globalText) throws IllegalArgumentException;
	//Decrypt the contents passed for Guest User
	ArrayList<String> decryptKeyword(String fcellText, String laneText)throws IllegalArgumentException;
	
	HashMap<String, ArrayList<String>> decryptSearchProject(String toSearch) throws IllegalArgumentException;
	//Get the csv files for generating file list for plots
	FlowcellData getCSVFiles(String run_id, String serial, String sampleID) throws IllegalArgumentException;
	String getCSVFromDisk(String filePath) throws IllegalArgumentException;
	

	
}
