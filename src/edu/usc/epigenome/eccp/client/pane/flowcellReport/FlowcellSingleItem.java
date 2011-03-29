package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.filereport.FileBrowser;

public class FlowcellSingleItem extends Composite
{
	public DisclosurePanel qcPanel = new DisclosurePanel("Summary Statistics");
	public DisclosurePanel filePanel = new DisclosurePanel("Download Files");
	public DisclosurePanel reportPanel = new DisclosurePanel("Pipeline Parameters");
	//public DisclosurePanel tilesPanel = new DisclosurePanel("View Tile Images");
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	FlowcellData flowcell;
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
		flowcellTableSample.addStyleName("flowcellitemlane");
			
		//HEADERS
		flowcellTableSample.setText(0,0, "Processing");
		flowcellTableSample.setText(0,1, "Library");
		flowcellTableSample.setText(0,2, "Organism");
		flowcellTableSample.setText(0,3, "Project");
		for(int i = 1; i<=8;i++)
		{
			flowcellTableSample.setText(i,0, flowcell.getLaneProperty(i,"processing"));
			String library = flowcell.getLaneProperty(i, "name").replace("+", "<br/>");
			flowcellTableSample.setWidget(i,1, new HTML(library));
			String organism = flowcell.getLaneProperty(i,"organism").replace("+", "<br/>");
			flowcellTableSample.setWidget(i,2, new HTML(organism));
			flowcellTableSample.setText(i,3, flowcell.getLaneProperty(i,"project"));						
		}
		vp.add(flowcellTable);
		vp.add(flowcellTableSample);
		vp.add(qcPanel);
		vp.add(filePanel);
		vp.add(reportPanel);
		
		//vp.add(tilesPanel);
		
		qcPanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
		{
			public void onOpen(OpenEvent<DisclosurePanel> event)
			{
				qcPanel.add(new Image("images/progress.gif"));
				remoteService.getQCforFlowcell(flowcell.getFlowcellProperty("serial"), new AsyncCallback<FlowcellData>(){

					public void onFailure(Throwable caught)
					{
						qcPanel.clear();
						qcPanel.add(new Label(caught.getMessage()));
						
					}

					public void onSuccess(FlowcellData result)
					{
						qcPanel.clear();
						flowcell.laneQC = result.laneQC;
						flowcell.filterLanesThatContain();
						VerticalPanel qcvp = new VerticalPanel();
						qcPanel.add(qcvp);
						for(String location : flowcell.laneQC.keySet())
						{
							qcvp.add(new Label("QC Metrics from " + location));
							FlexTable qcFlexTable = new  FlexTable();
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
							qcFlexTable.addStyleName("qctable");
							qcvp.add(qcFlexTable);							
						}						
					}});				
			}			
		});
		filePanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
		{

			public void onOpen(OpenEvent<DisclosurePanel> event)
			{
				filePanel.add(new Image("images/progress.gif"));
				remoteService.getFilesforFlowcell(flowcell.getFlowcellProperty("serial"), new AsyncCallback<FlowcellData>(){

					public void onFailure(Throwable caught)
					{
						filePanel.clear();
						filePanel.add(new Label(caught.getMessage()));
						
					}

					public void onSuccess(FlowcellData result)
					{
						filePanel.clear();
						flowcell.fileList = result.fileList;
						flowcell.filterLanesThatContain();
						FileBrowser f = new FileBrowser(flowcell.fileList);
						filePanel.add(f);
					}});				
			}			
		});
		
		reportPanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
		{

			public void onOpen(OpenEvent<DisclosurePanel> event) 
			{
				String tabDnldUrl = "http://webapp.epigenome.usc.edu/ECCP/ReportDnld.jsp?fcserial=" + flowcell.getFlowcellProperty("serial") + "&report=rep1";
				String wflowDnldUrl = "http://webapp.epigenome.usc.edu/ECCP/ReportDnld.jsp?fcserial=" + flowcell.getFlowcellProperty("serial") + "&report=rep2";
				Anchor tab = new Anchor("Illumina Sample Sheet", tabDnldUrl, "_blank");
				Anchor wflow = new Anchor("UEC Pipeline Parameters", wflowDnldUrl, "_blank");
				//HorizontalPanel toHold = new HorizontalPanel();
				FlexTable toHold = new FlexTable();
				//toHold.add(tab);
				toHold.setWidget(0, 0,tab);
				toHold.setWidget(1,0,wflow);
				reportPanel.add(toHold);
			}
		});
		
//		tilesPanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
//		{
//
//			public void onOpen(OpenEvent<DisclosurePanel> event)
//			{				
//				tilesPanel.clear();
//				TileViewer t = new TileViewer("123ABCXX");
//				tilesPanel.add(t);
//			}
//			
//		});

		initWidget(vp);
	}
}
