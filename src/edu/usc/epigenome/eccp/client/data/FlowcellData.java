package edu.usc.epigenome.eccp.client.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;

import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.IsSerializable;

public class FlowcellData implements IsSerializable
{
	//DS to hold the flowcell properties as <propertyName, value>
	public HashMap<String,String> flowcellProperties;
	//DS to hold the laneNo and properties associated with the lane as <laneNo, <propertyName, value>
	public HashMap<Integer,HashMap<String,String>> lane;
	//DS to hold the laneNo and the runID's associated with it as <laneNo, ArrayList<runId's>
	public HashMap<Integer,ArrayList<String>>QClist;
	//DS to hold a list of files with properties as ArrayList<<Propertyname, value>>
	public ArrayList<LinkedHashMap<String, String>> fileList;
	//DS to hold runID (analysis_id) which in turn holds the laneNo and the QC metrics for that lane as 
	//<runID, <laneNo, <QCmetricName, metricValue>>>
	public LinkedHashMap<String,LinkedHashMap<Integer,LinkedHashMap<String,String>>> laneQC;
	public String flowcellFilter = "";
	public String laneFilter = "";
	
	public FlowcellData()
	{
		flowcellProperties = new HashMap<String,String>();
		lane = new HashMap<Integer,HashMap<String,String>>();
		QClist = new HashMap<Integer, ArrayList<String>>();
		laneQC = new LinkedHashMap<String,LinkedHashMap<Integer,LinkedHashMap<String,String>>>();
		fileList = new ArrayList<LinkedHashMap<String,String>>();
	}	
	
	/*
	 * Get the value of the given flowcell property
	 */
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
	
	/*
	 * Get the value for the given lane and property name
	 */
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
		flowcellFilter = query;
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
	
	public boolean filterLanesThatContain()
	{
		return filterLanesThatContain(laneFilter);
	}
	
	public boolean filterLanesThatContain(String query)
	{
		laneFilter = query;
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
		}
		lanesToRemove.clear();
		
		//remove qc lanes
		for(String location : laneQC.keySet())
			for(Integer i : laneQC.get(location).keySet())
				if(!lanesToKeep.contains(i))
					lanesToRemove.add(i);
		for(String location : laneQC.keySet())
			for(Integer i : lanesToRemove)
				laneQC.get(location).remove(i);
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

	public void filterSamplesLanes(String sampleID) 
	{
			Object a[] = lane.keySet().toArray();
			ArrayList<Integer> lanesToKeep = new ArrayList<Integer>();
			ArrayList<Integer> lanesToRemove = new ArrayList<Integer>();
			
			for(int i=0;i<a.length;i++)
				 lanesToKeep.add((Integer)a[i]);
			
			for(String analysisID : laneQC.keySet())
				for(Integer i : laneQC.get(analysisID).keySet())
					if(!lanesToKeep.contains(i))
						lanesToRemove.add(i);
			for(String analysisID : laneQC.keySet())
				for(Integer i : lanesToRemove)
					laneQC.get(analysisID).remove(i);
			lanesToRemove.clear();		
	}
	
	/*
	 * Filter files for a given lane, sample and runId
	 */
	public void filterFiles(int lane, String sampleId, String runId)
	{
		ArrayList<Integer> lanesToKeep = new ArrayList<Integer>();
		ArrayList<HashMap<String, String>> filesToRemove = new ArrayList<HashMap<String,String>>();
		
		lanesToKeep.add(lane);
		
		//Iterate over the fileList
		for(HashMap<String, String> file : fileList)
		{
			//If file's fullpath has sampleId
			if(!file.get("fullpath").contains(sampleId))
			{
				//remove files that don't have the laneNo
				if(!lanesToKeep.contains(Integer.parseInt(file.get("lane"))))
					filesToRemove.add(file);
			}
			//Remove files that don't have the laneNo
			else
			{
				if(!lanesToKeep.contains(Integer.parseInt(file.get("lane"))))
					filesToRemove.add(file);
			}
		}
		for(HashMap<String, String> file : filesToRemove)
		{
			fileList.remove(file);
		}
	}
	
	/*
	 * Filter QC data for the given lane
	 * Remove lanes from flowcell.laneQC that don't match the laneNo provided
	 */
	public void filterQC(int lane)
	{
		ArrayList<Integer> lanesToKeep = new ArrayList<Integer>();
		ArrayList<Integer> lanesToRemove = new ArrayList<Integer>();
		
		lanesToKeep.add(lane);
		
		for(String locaiton : laneQC.keySet())
			for(Integer i : laneQC.get(locaiton).keySet())
				if(!lanesToKeep.contains(i))
					lanesToRemove.add(i);
		
		for(String location : laneQC.keySet())
			for(Integer i : lanesToRemove)
			laneQC.get(location).remove(i);
		lanesToRemove.clear();
		
	}
	
	/*
	 * Filter the analysis_id with respect to the flowcell, lane 
	 * and geneusID_sample
	 */
	public void filterAnalysis(String flowcell, int lane, String libraryID)
	{
		ArrayList<String> analysisToRemove = new ArrayList<String>();
		//Iterate over each key in laneQC
		for(String location : laneQC.keySet())
		{
			if(laneQC.get(location) != null)
			{
				//If the key is of the form flowcell(Serial)_lane(laneNo) then check if it has the geneusID_sample 
				if(location.contains(flowcell+"_"+lane+"_"))
				{
					//remove the keys not having the geneusId_sample
					if(!location.contains(libraryID))
						analysisToRemove.add(location);
				}
			}
		}	
		
		for(String rem : analysisToRemove)
			laneQC.remove(rem);
			
		analysisToRemove.clear();
	}
	
	public void filterRuns(String runId)
	{
		ArrayList<String> analysisToKeep = new ArrayList<String>();
		ArrayList<String> analysisToRemove = new ArrayList<String>();
		
		analysisToKeep.add(runId);
		for(String location : laneQC.keySet())
		{
			if(!analysisToKeep.contains(location))
			{
				analysisToRemove.add(location);
			}
		}	
		for(String remove : analysisToRemove)
			laneQC.remove(remove);
		
		analysisToRemove.clear();
	}
	
}
