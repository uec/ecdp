package edu.usc.epigenome.eccp.client.data;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.user.client.rpc.IsSerializable;

public class MethylationData extends FlowcellData implements IsSerializable
{
	public ArrayList<String> validateIntegrity(ArrayList<MethylationData> list)
	{
		ArrayList<String> errors = new ArrayList<String>();
		HashMap<String,String> dupcheck = new HashMap<String,String>();
		for(MethylationData m : list)
		{
			for(int l : m.lane.keySet())
			{
				String beadKey = m.getFlowcellProperty("serial") + m.getLaneProperty(l, "lane").replace(":1", "");
				String sampleKey = m.getLaneProperty(l,"name");
				
				if(dupcheck.containsKey(beadKey))
				{
					errors.add("Warning: duplicate entry for barcode: " + beadKey);
					if(!dupcheck.get(beadKey).contains(sampleKey))
						errors.add("ERROR: Diff samples on same barcode: " + sampleKey + " on " + beadKey +"," + dupcheck.get(sampleKey));
					dupcheck.put(beadKey, dupcheck.get(beadKey) + sampleKey + ",") ;
				}
				else
					dupcheck.put(beadKey, sampleKey + ",");
				
				
				if(dupcheck.containsKey(sampleKey) && sampleKey.toUpperCase().startsWith("TCGA"))
				{
					errors.add("Warning: TCGA ID on multiple barcodes: " + sampleKey + " on " + beadKey +"," + dupcheck.get(sampleKey));
					dupcheck.put(sampleKey, dupcheck.get(sampleKey) + beadKey + ",") ;
				}
				else
					dupcheck.put(sampleKey, beadKey + ",");
				
				
				if(sampleKey.toUpperCase().startsWith("TCGA") && false) // sampleKey.matches("????-\\w+-\\w+-\\w+-\\w+-\\w+-\\w+"))
				{
					errors.add("Warning: TCGA ID naming does not conform to standard: " + sampleKey);
				}
			}
		}
		
		return errors;
		
	}
}
