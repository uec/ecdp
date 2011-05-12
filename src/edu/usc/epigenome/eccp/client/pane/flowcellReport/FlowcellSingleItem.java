package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.SampleData;

public class FlowcellSingleItem extends Composite 
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	FlowcellData flowcell;
	SampleData sampGeneus;
	
	public FlowcellSingleItem(final SampleData sampleIn)
	{
		sampGeneus = sampleIn;
		VerticalPanel vp = new VerticalPanel();
		for(String sampleID : sampGeneus.sampleInfo.keySet())
		{
			vp.add(new Label("Sample ID: " + sampleID));
			ArrayList<FlowcellData> fcells = sampGeneus.sampleInfo.get(sampleID);
			
			for(int j=0;j<fcells.size();j++)
			{
				FlowcellData flowcell = fcells.get(j);
				
				FlexTable flowcellTable = new FlexTable();
				flowcellTable.addStyleName("flowcellitem");
				flowcellTable.setText(0,0, "Flowcell ID: " + flowcell.getFlowcellProperty("serial"));
				flowcellTable.setText(0,1, "Lims ID: " + flowcell.getFlowcellProperty("limsID"));
				flowcellTable.setText(0,2, flowcell.getFlowcellProperty("technician") +" " + flowcell.getFlowcellProperty("date"));
				flowcellTable.setText(1,0, "Protocol: " + flowcell.getFlowcellProperty("protocol"));
				flowcellTable.setText(1,1, "Status: " + flowcell.getFlowcellProperty("status"));
				flowcellTable.setText(1,2, "Control Lane: " + flowcell.getFlowcellProperty("control"));
				
				FlexTable flowcellTableSample = new FlexTable();
					
				//HEADERS
				flowcellTableSample.setText(0,0, "Processing");
				flowcellTableSample.setText(0,1, "Library");
				//flowcellTableSample.setText(0,2, "Geneusid");
				flowcellTableSample.setText(0,2, "Organism");
				flowcellTableSample.setText(0,3, "Project");
				for(int i = 1; i<=flowcell.lane.keySet().size();i++)
				{
					flowcellTableSample.setText(i,0, flowcell.getLaneProperty(i,"processing"));
					flowcellTableSample.setText(i,1, flowcell.getLaneProperty(i,"library"));
					flowcellTableSample.setText(i,2, flowcell.getLaneProperty(i,"organism"));
					
					//String library = flowcell.getLaneProperty(i, "name").replace("+", "<br/>");
					//flowcellTableSample.setWidget(i,1, new HTML(library));
					//String sampleID = flowcell.getLaneProperty(i, "sampleID").replace("+", "<br/>");
					//flowcellTableSample.setWidget(i, 2, new HTML(sampleID));
					//String organism = flowcell.getLaneProperty(i,"organism").replace("+", "<br/>");
					//flowcellTableSample.setWidget(i,3, new HTML(organism));
					flowcellTableSample.setText(i,3, flowcell.getLaneProperty(i,"project"));						
				}
				vp.add(flowcellTable);
				vp.add(flowcellTableSample);
				
			}
		}
		initWidget(vp);
	}
	
	public FlowcellSingleItem(final FlowcellData flowcellIn)
	{
		flowcell=flowcellIn;
		VerticalPanel vp = new VerticalPanel();
		FlexTable flowcellTable = new FlexTable();
		flowcellTable.addStyleName("flowcellitem");
		flowcellTable.setText(0,0, "Flowcell ID: " + flowcell.getFlowcellProperty("serial"));
		flowcellTable.setText(0,1, "Lims ID: " + flowcell.getFlowcellProperty("limsID"));
		flowcellTable.setText(0,2, flowcell.getFlowcellProperty("technician") +" " + flowcell.getFlowcellProperty("date"));
		flowcellTable.setText(1,0, "Protocol: " + flowcell.getFlowcellProperty("protocol"));
		flowcellTable.setText(1,1, "Status: " + flowcell.getFlowcellProperty("status"));
		flowcellTable.setText(1,2, "Control Lane: " + flowcell.getFlowcellProperty("control"));
		
		FlexTable flowcellTableSample = new FlexTable();
			
		//HEADERS
		flowcellTableSample.setText(0,0, "Processing");
		flowcellTableSample.setText(0,1, "Library");
		//flowcellTableSample.setText(0,2, "Geneusid");
		flowcellTableSample.setText(0,2, "Organism");
		flowcellTableSample.setText(0,3, "Project");
		for(int i = 1; i<=8;i++)
		{
			flowcellTableSample.setText(i,0, flowcell.getLaneProperty(i,"processing"));
			String library = flowcell.getLaneProperty(i, "name").replace("+", "<br/>");
			flowcellTableSample.setWidget(i,1, new HTML(library));
			//String sampleID = flowcell.getLaneProperty(i, "sampleID").replace("+", "<br/>");
			//flowcellTableSample.setWidget(i, 2, new HTML(sampleID));
			String organism = flowcell.getLaneProperty(i,"organism").replace("+", "<br/>");
			flowcellTableSample.setWidget(i,2, new HTML(organism));
			flowcellTableSample.setText(i,3, flowcell.getLaneProperty(i,"project"));						
		}
		vp.add(flowcellTable);
		vp.add(flowcellTableSample);
		initWidget(vp);
	}
	
	/*public FlowcellSingleItem(final SampleData flowcellIn, String sample)
	{
		sampGeneus=flowcellIn;
		VerticalPanel vp = new VerticalPanel();
	
		for(String sampleID : flowcell.sample.keySet())
		{
			vp.add(new Label("Sample ID: " + sampleID));
			
			//ArrayList<String> fcell = flowcell.sample.get(sampleID);
			HashMap<String,HashMap<Integer, HashMap<String, String>>> fcell = flowcell.sample.get(sampleID);
			
			for(String fcellID : fcell.keySet())
			{
				HashMap<Integer, HashMap<String, String>> laneInfo = fcell.get(fcellID);
				FlexTable flowcellTable = new FlexTable();
				DisclosurePanel fcPanel = new DisclosurePanel("Flowcell is " + fcellID);
				flowcellTable.setText(0,0, "Processing");
				flowcellTable.setText(0,1, "Library");
				//flowcellTable.setText(0,2, "Geneusid");
				flowcellTable.setText(0,2, "Organism");
				flowcellTable.setText(0,3, "Project");
				
				int i = 1;
				for(Integer laneNo : laneInfo.keySet())
				{
					HashMap<String, String> sampleInfo = laneInfo.get(laneNo);
					flowcellTable.setText(i,0,sampleInfo.get("processing"));
					flowcellTable.setText(i, 1, sampleInfo.get("sample_name"));
					flowcellTable.setText(i, 2, sampleInfo.get("organism"));
					flowcellTable.setText(i, 3, sampleInfo.get("project"));
					i++;
				}
				fcPanel.add(flowcellTable);
				vp.add(fcPanel);
			}
		}			
		initWidget(vp);	
		
		//int noElements = fcell.size();
		//for(int i=0;i< noElements;i++)
		//{
			//FlexTable flowcellTable = new FlexTable();
			//DisclosurePanel qcPanel = new DisclosurePanel("Flowcell is ");
			//flowcellTable.setText(i,0, "Flowcell ID: " + fcell.get(i));
			//qcPanel.add(flowcellTable);
			//vp.add(qcPanel);
		//}
		}*/
	
	/*public FlowcellSingleItem()
	{
		VerticalPanel tableHold = new VerticalPanel();
		FlexTable flowcellTable = new FlexTable();
		flowcellTable.setText(0,0, "Flowcell ID: " + "B03BUABXX");
		flowcellTable.setText(0,1, "Lims ID: " + "GW2-CNX-110427-24-3043");
		flowcellTable.setText(0,2, "Tejas" +" " + "2011-04-20");
		flowcellTable.setText(1,0, "Protocol: " + "paired end");
		flowcellTable.setText(1,1, "Status: " + "In geneus");
		flowcellTable.setText(1,2, "Control Lane: " + "lane 1");
		tableHold.add(flowcellTable);
		initWidget(tableHold);
	}*/
}	

