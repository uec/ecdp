package edu.usc.epigenome.eccp.client.data;

import com.google.gwt.user.client.rpc.IsSerializable;
import java.util.*;

	public class SampleData implements IsSerializable
	{
		//public HashMap<String, ArrayList<FlowcellData>> sampleInfo;
		public HashMap<String, String> sampleProperties;
		public HashMap<String, HashMap<String, String>> flowcellInfo;
		public HashMap<Integer, HashMap<String, String>> flowcellLane;
		public LinkedHashMap<String, LinkedHashMap<Integer, LinkedHashMap<String, String>>> flowcellLaneQC;
		public ArrayList<LinkedHashMap<String, String>> flowcellFileList;
		public LinkedHashMap<String, LinkedHashMap<String,String>> laneQC;
		
		public SampleData()
		{
			//sampleInfo = new HashMap<String, ArrayList<FlowcellData>>();
			sampleProperties = new HashMap<String, String>();
			flowcellInfo = new HashMap<String, HashMap<String,String>>();
			flowcellLane = new HashMap<Integer, HashMap<String, String>>();
			flowcellLaneQC = new LinkedHashMap<String, LinkedHashMap<Integer,LinkedHashMap<String,String>>>();
			flowcellFileList = new ArrayList<LinkedHashMap<String,String>>();
			laneQC = new LinkedHashMap<String, LinkedHashMap<String,String>>();
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
		
		public void filterQC(int lane)
		{
			ArrayList<Integer> lanesToKeep = new ArrayList<Integer>();
			ArrayList<Integer> lanesToRemove = new ArrayList<Integer>();
			
			lanesToKeep.add(lane);
			
			for(String locaiton : flowcellLaneQC.keySet())
				for(Integer i : flowcellLaneQC.get(locaiton).keySet())
					if(!lanesToKeep.contains(i))
						lanesToRemove.add(i);
			
			for(String location : flowcellLaneQC.keySet())
				for(Integer i : lanesToRemove)
				flowcellLaneQC.get(location).remove(i);
			lanesToRemove.clear();
			
		}
		
		public void filterAnalysis(String flowcell, int lane)
		{
			ArrayList<String> analysisToRemove = new ArrayList<String>();
			
			for(String location : flowcellLaneQC.keySet())
			{
				if(location.contains(flowcell+"_"+lane+"_"))
				{
					if(!location.contains(sampleProperties.get("geneusID_sample")))
					{
						analysisToRemove.add(location);
					}
				}
			}
			
				for(String rem : analysisToRemove)
					flowcellLaneQC.remove(rem);
				
			analysisToRemove.clear();
		}
		
		public void filterFiles(int lane)
		{
			//Object a[] = flowcellLane.keySet().toArray();
			ArrayList<Integer> lanesToKeep = new ArrayList<Integer>();
			ArrayList<HashMap<String, String>> filesToRemove = new ArrayList<HashMap<String,String>>();
			//ArrayList<HashMap<String, String>> filesToKeep = new ArrayList<HashMap<String,String>>();
			
			lanesToKeep.add(lane);
			//for(int i=0;i<a.length;i++)
				//lanesToKeep.add((Integer)a[i]);
			
			for(HashMap<String, String> file : flowcellFileList)
			{
				if(!file.get("fullpath").contains(sampleProperties.get("geneusID_sample")))
				{
					if(!lanesToKeep.contains(Integer.parseInt(file.get("lane"))))
						filesToRemove.add(file);
				}
				else
				{
					if(!lanesToKeep.contains(Integer.parseInt(file.get("lane"))))
						filesToRemove.add(file);
				}
			}
			for(HashMap<String, String> file : filesToRemove)
			{
				flowcellFileList.remove(file);
			}
			/*for(HashMap<String, String> file : flowcellFileList)
			{
				if(!file.get("fullpath").contains(sampleProperties.get("geneusID_sample")))
				{
					//Check for lane no
					if(!lanesToKeep.contains(Integer.parseInt(file.get("lane"))))
						filesToRemove.add(file);
				}
				
			}*/	
		}
	}
