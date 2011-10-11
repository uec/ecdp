package edu.usc.epigenome.eccp.client.data;

import com.google.gwt.user.client.rpc.IsSerializable;
import java.util.*;

/*
 * Data Structure to hold sample specific data which is  
 * serialized to be used with ECServiceBackend.java(Backend code)
 */
	public class SampleData implements IsSerializable
	{
		//Data Structure to hold sample specific properties
		public HashMap<String, String> sampleProperties;
		public HashMap<String, FlowcellData> sampleFlowcells;
		String sampleFilter = "";
		
		public SampleData()
		{
			sampleProperties = new HashMap<String, String>();
			sampleFlowcells = new HashMap<String, FlowcellData>();
		}
		
		/*
		 * Function to get Sample properties from sampleProperties HashMap
		 */
		public String getSampleProperty(String key)
		{
			try
			{
				return sampleProperties.containsKey(key) ? sampleProperties.get(key) : "unknown";
			}
			catch (Exception e)
			{
				return "unknown";
			}
		}
		
		public boolean sampleContains(String query)
		{
			sampleFilter = query;
			if(query == null || query.length() < 1 || query.equals(""))
				return true;
			ArrayList<Boolean> foundList = new ArrayList<Boolean>();
			String[] words = query.split("\\s+");
			
			for(String word : words)
			{
				Boolean found = false;
				for(String v : sampleProperties.values())
				{
					if(v.toLowerCase().contains(word.toLowerCase()))
							found = true;
				}
				foundList.add(found);
			}
			if(foundList.contains(true) && !foundList.contains(false))
				return true;
			else 
				return false;
		}
	}
