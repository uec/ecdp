package edu.usc.epigenome.eccp.client.data;

import com.google.gwt.user.client.rpc.IsSerializable;
import java.util.*;

	public class SampleData implements IsSerializable
	{
		//public HashMap<String, ArrayList<FlowcellData>> sampleInfo;
		public HashMap<String, String> sampleProperties;
		public HashMap<String, FlowcellData> sampleFlowcells;
		
		
		//public HashMap<String, String> projectProperties;
		//public HashMap<String, HashMap<String, String>> flowcellInfo;
		//public HashMap<Integer, HashMap<String, String>> flowcellLane;
		//public LinkedHashMap<String, LinkedHashMap<Integer, LinkedHashMap<String, String>>> flowcellLaneQC;
		//public ArrayList<LinkedHashMap<String, String>> flowcellFileList;
		//public LinkedHashMap<String, LinkedHashMap<String,String>> laneQC;
		String sampleFilter = "";
		public SampleData()
		{
			//sampleInfo = new HashMap<String, ArrayList<FlowcellData>>();
			//projectProperties = new HashMap<String, String>();
			
			sampleProperties = new HashMap<String, String>();
			sampleFlowcells = new HashMap<String, FlowcellData>();
			
			//flowcellInfo = new HashMap<String, HashMap<String,String>>();
			//flowcellLane = new HashMap<Integer, HashMap<String, String>>();
			//flowcellLaneQC = new LinkedHashMap<String, LinkedHashMap<Integer,LinkedHashMap<String,String>>>();
			//flowcellFileList = new ArrayList<LinkedHashMap<String,String>>();
			//laneQC = new LinkedHashMap<String, LinkedHashMap<String,String>>();
		}
		
		
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
