package edu.usc.epigenome.eccp.client.data;

import java.util.ArrayList;

public class MultipleLibraryProperty extends LibraryProperty
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	ArrayList<String> value;

	public String getValue(int i)
	{
		return value.get(i);
	}

	public void setValue(String val,int i)
	{
		if(this.value == null)
			this.value = new ArrayList<String>();
		this.value.set(i, val);
	}
	public void addValue(String val)
	{
		if(this.value == null)
			this.value = new ArrayList<String>();
		this.value.add(val);
	}
	
	public int getValueSize()
	{
		if(this.value == null)
			return 0;
		else 
			return this.value.size();
	}
	public String getAllValues() {
		String s="";
		if(this.value != null) {
		      for (String v: value) {
			          s+=v+"\t";
		       }
		}
	//	System.out.println(s);
		return s;
	}
	
}
