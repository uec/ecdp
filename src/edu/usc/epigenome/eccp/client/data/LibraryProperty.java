package edu.usc.epigenome.eccp.client.data;

import java.io.Serializable;

public class LibraryProperty implements Serializable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	String name;
	String value;
	String type;
	String category;
	String description;
	String prettyName;
	String sortOrder;
	String source;
	String usage;
	
	public String getKey()
	{
		return name;
	}
	public void setKey(String name)
	{
		this.name = name;
	}
	public String getName()
	{
		return name;
	}
	public void setName(String name)
	{
		this.name = name;
	}
	public String getValue()
	{
		return value;
	}
	public void setValue(String value)
	{
		this.value = value;
	}
	public String getType()
	{
		return type;
	}
	public void setType(String type)
	{
		this.type = type;
	}
	public String getCategory()
	{
		return category;
	}
	public void setCategory(String category)
	{
		this.category = category;
	}
	public String getSource()
	{
		return source;
	}
	public void setSource(String source)
	{
		this.source = source;
	}
	public String getUsage()
	{
		return usage;
	}
	public void setUsage(String usage)
	{
		this.usage = usage;
	}
	public String getDescription()
	{
		return description;
	}
	public void setDescription(String description)
	{
		this.description = description;
	}
	public String getPrettyName()
	{
		return prettyName;
	}
	public void setPrettyName(String prettyName)
	{
		this.prettyName = prettyName;
	}
	public String getSortOrder()
	{
		return sortOrder;
	}
	public void setSortOrder(String sortOrder)
	{
		this.sortOrder = sortOrder;
	}

	
	
}
