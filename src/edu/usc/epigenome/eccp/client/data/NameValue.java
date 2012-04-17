package edu.usc.epigenome.eccp.client.data;

import java.io.Serializable;
import java.util.Random;

public class NameValue implements Serializable
{
	public long key;
	public String name;
	public String type;
	public String value;

	
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


	public String getType()
	{
		return type;
	}


	public void setType(String type)
	{
		this.type = type;
	}


	public String getValue()
	{
		return value;
	}


	public void setValue(String value)
	{
		this.value = value;
	}


	
	
	public void setall(String name, String chrm, String pos)
	{
		this.setKey(new Random().nextLong());
		this.name=name;
		this.type=chrm;
		this.value=pos;
				
	}
}
