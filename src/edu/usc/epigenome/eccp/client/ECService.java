package edu.usc.epigenome.eccp.client;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import edu.usc.epigenome.eccp.client.data.FlowcellData;

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
	FlowcellData getQCforFlowcell(String serial) throws IllegalArgumentException;
	FlowcellData getFilesforFlowcell(String serial) throws IllegalArgumentException;
	String getCSVFromDisk(String filePath) throws IllegalArgumentException;
	//PBS reporting
	public String[] qstat(String queue);
}
