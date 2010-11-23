package edu.usc.epigenome.eccp.client.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

import com.google.gwt.user.client.rpc.IsSerializable;

public class MethylationData extends FlowcellData implements IsSerializable
{
	public ArrayList<String> validateIntegrity(ArrayList<MethylationData> list)
	{
		ArrayList<String> errors = new ArrayList<String>();
		HashMap<String,ArrayList<String>> dupcheckBySample = new HashMap<String,ArrayList<String>>();
		HashMap<String,ArrayList<String>> dupcheckByBarcode = new HashMap<String,ArrayList<String>>();
		for(MethylationData m : list)
		{
			for(int l : m.lane.keySet())
			{
				String beadKey = m.getFlowcellProperty("serial") + m.getLaneProperty(l, "lane").replace(":1", "");
				String sampleKey = m.getLaneProperty(l,"name");
				
				//populate the data structure
				if(dupcheckBySample.containsKey(sampleKey))
					dupcheckBySample.get(sampleKey).add(beadKey);
				else
				{
					ArrayList<String> s = new ArrayList<String>();
					s.add(beadKey);
					dupcheckBySample.put(sampleKey, s);
				}
				
				if(dupcheckByBarcode.containsKey(beadKey))
					dupcheckByBarcode.get(beadKey).add(sampleKey);
				else
				{
					ArrayList<String> s = new ArrayList<String>();
					s.add(sampleKey);
					dupcheckByBarcode.put(beadKey, s);
				}
			}
		}
		
		for(String bkey : dupcheckByBarcode.keySet())
		{
			if(dupcheckByBarcode.get(bkey).size() > 1)
			{
				String allSamples = "";
				for(String s : dupcheckByBarcode.get(bkey))
				{
					allSamples += " " + s;
				}
				HashSet<String> h = new HashSet<String>(dupcheckByBarcode.get(bkey));
				if(h.size() > 1)
					errors.add("ERROR: Different samples on same barcode: " + bkey + ": " + allSamples);  
			}	
		}
		
		
		for(String skey : dupcheckBySample.keySet())
		{
			if(dupcheckBySample.get(skey).size() > 1)
			{
				String allSamples = "";
				for(String s : dupcheckBySample.get(skey))
				{
					allSamples += " " + s;
				}
				
				HashSet<String> h = new HashSet<String>(dupcheckBySample.get(skey));
				if(h.size() > 1)					
					errors.add("Warning: Same Sample ID on multiple barcodes: " + skey + ": " + allSamples);
				else
					errors.add("Warning: duplicate entry for barcode: "  + skey + ": " + allSamples);
					
			}	
		}
		
		return errors;
		
	}
}
