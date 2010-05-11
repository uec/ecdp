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
	
	public boolean flowcellContains(String query)
	{
		if(query == null || query.length() < 1)
			return true;
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
	
	public boolean filterLanesThatContain(String query)
	{
		if(query == null || query.length() < 1)
			return true;
		ArrayList<Integer> lanesToKeep = new ArrayList<Integer>();
		String[] words = query.split("\\s+");
					
		for(int i : lane.keySet())
		{
			ArrayList<Boolean> foundList = new ArrayList<Boolean>();
			for(String word : words)
			{
				Boolean found = false;
				for(String v : lane.get(i).values())
					if(v.toLowerCase().contains(word.toLowerCase()))
						found = true;					
				
				foundList.add(found);				
			}
			if(foundList.contains(true) && !foundList.contains(false))
				lanesToKeep.add(i);
		}
		keepOnlyLanes(lanesToKeep);
		if(lanesToKeep.size() > 1)
			return true;
		else
			return false;
		
	}
	
	public void keepOnlyLanes(ArrayList<Integer> lanesToKeep)
	{
		lanesToKeep.add(0);
		ArrayList<Integer> lanesToRemove = new ArrayList<Integer>();
		ArrayList<HashMap<String,String>> filesToRemove = new ArrayList<HashMap<String,String>>();
		for(Integer i : lane.keySet())
		{
			if(!lanesToKeep.contains(i))
				lanesToRemove.add(i);		
		}
		
		for(Integer i : lanesToRemove)
		{
			lane.remove(i);
			laneQC.remove(i);
		}
		lanesToRemove.clear();
		
		for(HashMap<String,String> file : fileList)
		{
			if(file.containsKey("lane"))
			{
				if(!lanesToKeep.contains(Integer.parseInt(file.get("lane"))))
					filesToRemove.add(file);
			}
		}
		
		for(HashMap<String,String> file : filesToRemove)
		{
			fileList.remove(file);		
		}
		
	}
}
