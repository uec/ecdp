package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.SampleData;

public class FlowcellSingleItem extends Composite  {

	private static FlowcellSingleItemUiBinder uiBinder = GWT
			.create(FlowcellSingleItemUiBinder.class);

	interface FlowcellSingleItemUiBinder extends
			UiBinder<Widget, FlowcellSingleItem> {
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	FlowcellData flowcell;
	SampleData sampGeneus;
	
	public FlowcellSingleItem() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	@UiField FlowPanel vp;
	@UiField FlexTable flowcellTable;
	@UiField FlexTable flowcellTableSample;
	@UiField DisclosurePanel qcPanel;
	//@UiField DisclosurePanel filePanel;
	@UiField FlowPanel qcvp;
	
	public FlowcellSingleItem(final FlowcellData flowcellIn)
	{
		flowcell=flowcellIn;
		initWidget(uiBinder.createAndBindUi(this));
		//VerticalPanel vp = new VerticalPanel();
		//FlexTable flowcellTable = new FlexTable();
		//flowcellTable.addStyleName("flowcellitem");
		flowcellTable.setText(0,0, "Flowcell ID: " + flowcell.getFlowcellProperty("serial"));
		flowcellTable.setText(0,1, "Lims ID: " + flowcell.getFlowcellProperty("limsID"));
		flowcellTable.setText(0,2, flowcell.getFlowcellProperty("technician") +" " + flowcell.getFlowcellProperty("date"));
		flowcellTable.setText(1,0, "Protocol: " + flowcell.getFlowcellProperty("protocol"));
		flowcellTable.setText(1,1, "Status: " + flowcell.getFlowcellProperty("status"));
		flowcellTable.setText(1,2, "Control Lane: " + flowcell.getFlowcellProperty("control"));
		
		//FlexTable flowcellTableSample = new FlexTable();
			
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
		
		qcPanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
		{
			public void onOpen(OpenEvent<DisclosurePanel> arg0) 
			{
				qcvp.add(new Image("images/progress.gif"));
				remoteService.getQCforFlowcell(flowcell.getFlowcellProperty("serial"), new AsyncCallback<FlowcellData>()
				{
					public void onFailure(Throwable caught)
					{
						qcPanel.clear();
						qcPanel.add(new Label(caught.getMessage()));	
					}	
					public void onSuccess(FlowcellData result)
					{
						qcvp.clear();
						flowcell.laneQC = result.laneQC;
						flowcell.filterLanesThatContain();
						for(String location : flowcell.laneQC.keySet())
						{
							qcvp.add(new Label("QC Metrics from " + location));
							FlexTable qcFlexTable = new FlexTable();
							int j=0;
							Boolean firstLine = true;
							for(int i=1;i<=8;i++)
							{
								if(flowcell.laneQC.get(location).containsKey(i))
								{	
									j=0;
									if(firstLine)
									{						
										flowcell.laneQC.get(location).get(i).remove("FlowCelln");
										for(String s : flowcell.laneQC.get(location).get(i).keySet())
										{								
											qcFlexTable.setText(0, j, s);
											j++;
										}
										firstLine = false;
										j=0;
									}									
									
									flowcell.laneQC.get(location).get(i).remove("FlowCelln");
									for(String s : flowcell.laneQC.get(location).get(i).keySet())
									{
										qcFlexTable.setText(i, j, flowcell.laneQC.get(location).get(i).get(s));
										j++;
									}
								}
							}
							qcvp.add(qcFlexTable);
						}
					}});
			}
		});
	  }
	}
