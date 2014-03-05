package edu.usc.epigenome.eccp.client.data;
import java.io.Serializable;

public class LibraryDataQuery implements Serializable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	String flowcell;
	String DBid;
	String runName;
	String LibraryName;
	String lane;
	Boolean isSummaryOnly;
	Boolean getFiles;
	
	public String getFlowcell()
	{
		return flowcell;
	}
	public void setFlowcell(String flowcell)
	{
		this.flowcell = flowcell;
	}
	public String getDBid()
	{
		return DBid;
	}
	public void setDBid(String dBid)
	{
		DBid = dBid;
	}
	public String getRunName()
	{
		return runName;
	}
	public void setRunName(String runName)
	{
		this.runName = runName;
	}
	public String getLibraryName()
	{
		return LibraryName;
	}
	public void setLibraryName(String libraryName)
	{
		LibraryName = libraryName;
	}
	public String getLane()
	{
		return lane;
	}
	public void setLane(String lane)
	{
		this.lane = lane;
	}
	public Boolean getIsSummaryOnly()
	{
		return isSummaryOnly;
	}
	public void setIsSummaryOnly(Boolean isSummaryOnly)
	{
		this.isSummaryOnly = isSummaryOnly;
	}
	public Boolean getGetFiles()
	{
		return getFiles;
	}
	public void setGetFiles(Boolean getFiles)
	{
		this.getFiles = getFiles;
	}

}
