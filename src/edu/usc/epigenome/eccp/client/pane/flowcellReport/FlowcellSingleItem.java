package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FlowcellData;

public class FlowcellSingleItem extends Composite 
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	FlowcellData flowcell;
	
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
		vp.add(flowcellTable);
		initWidget(vp);
	}
	
}
