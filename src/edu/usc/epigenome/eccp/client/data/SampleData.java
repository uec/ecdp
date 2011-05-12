package edu.usc.epigenome.eccp.client.data;

import com.google.gwt.user.client.rpc.IsSerializable;
import java.util.*;

	public class SampleData implements IsSerializable
	{
		public HashMap<String, ArrayList<FlowcellData>> sampleInfo;
		
		public SampleData()
		{
			sampleInfo = new HashMap<String, ArrayList<FlowcellData>>();
		}
	}
