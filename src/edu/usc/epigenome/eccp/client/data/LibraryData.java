package edu.usc.epigenome.eccp.client.data;
import java.util.HashMap;
import java.util.List;

public class LibraryData extends HashMap<String,LibraryProperty>
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	List<FileData> files;
	public List<FileData> getFiles()
	{
		return files;
	}
	public void setFiles(List<FileData> files)
	{
		this.files = files;
	}
}
