package edu.usc.epigenome.eccp.client.data;

import java.io.Serializable;

public class FileData implements Serializable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	public long key;
	String name;
	String location;
	String type;
	String source;
	String category;
	String downloadLocation;
	
	public void setAll(String name,	String location, String type,String source,	String category, String downloadLocation)
	{
		this.name=name;
		this.location=location;
		this.type=type;
		this.source=source;
		this.category=category;
		this.downloadLocation=downloadLocation;
	}
	
	public String getDownloadLocation()
	{
		return downloadLocation;
	}
	public void setDownloadLocation(String downloadLocation)
	{
		this.downloadLocation = downloadLocation;
	}
	public long getKey()
	{
		return key;
	}
	public void setKey(long key)
	{
		this.key = key;
	}
	public String getName()
	{
		return name;
	}
	public void setName(String name)
	{
		this.name = name;
	}
	public String getLocation()
	{
		return location;
	}
	public void setLocation(String location)
	{
		this.location = location;
	}
	public String getType()
	{
		return type;
	}
	public void setType(String type)
	{
		this.type = type;
	}
	public String getSource()
	{
		return source;
	}
	public void setSource(String source)
	{
		this.source = source;
	}
	public String getCategory()
	{
		return category;
	}
	public void setCategory(String category)
	{
		this.category = category;
	}

}
