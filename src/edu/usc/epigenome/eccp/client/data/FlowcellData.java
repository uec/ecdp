package edu.usc.epigenome.eccp.client.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

import com.google.gwt.user.client.rpc.IsSerializable;

public class FlowcellData implements IsSerializable
{
	public HashMap<String,String> flowcellProperties;
	public HashMap<Integer,HashMap<String,String>> lane;
	public ArrayList<LinkedHashMap<String, String>> fileList;
	public LinkedHashMap<Integer,LinkedHashMap<String,String>> laneQC;
	
	public FlowcellData()
	{
		flowcellProperties = new HashMap<String,String>();
		lane = new HashMap<Integer,HashMap<String,String>>();
		laneQC = new LinkedHashMap<Integer,LinkedHashMap<String,String>>();
		fileList = new ArrayList<LinkedHashMap<String,String>>();
	}	
	
	public String getFlowcellProperty(String key)
	{
		try
		{
			return flowcellProperties.containsKey(key) ? flowcellProperties.get(key) : "unknown";
		}
		catch (Exception e)
		{
			return "unknown";
		}
	}
	
	public String getLaneProperty(int laneNumber,String key)
	{		
		try
		{
			return lane.get(laneNumber).get(key);
		}
		catch (Exception e)
		{
			return "unknown";
		}
	}
	
	public boolean contains(String query)
	{
		ArrayList<Boolean> foundList = new ArrayList<Boolean>();
		String[] words = query.split("\\s+");
		for(String word : words)
		{
			Boolean found = false; 
			for(String v : flowcellProperties.values())
			{
				if(v.toLowerCase().contains(word.toLowerCase()))
					found = true;
			}
			for(int i : lane.keySet())
			{
				for(String v : lane.get(i).values())
				{
					if(v.toLowerCase().contains(word.toLowerCase()))
						found = true;
				}				
			}
			foundList.add(found);
		}
		if(foundList.contains(true) && !foundList.contains(false))
			return true;
		else 
			return false;		
	}
	
	public void keepOnlyLanes(ArrayList<Integer> lanesToKeep)
	{
		lanesToKeep.add(0);
		for(Integer i : lane.keySet())
		{
			if(!lanesToKeep.contains(i))
			{
				lane.remove(i);
				laneQC.remove(i);				
			}
		}
		for(HashMap<String,String> file : fileList)
		{
			if(file.containsKey("lane"))
			{
				if(!lanesToKeep.contains(Integer.parseInt(file.get("lane"))))
				{
					fileList.remove(file);
				}
			}
		}
	}
}
