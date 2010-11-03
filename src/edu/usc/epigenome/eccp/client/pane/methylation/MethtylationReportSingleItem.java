package edu.usc.epigenome.eccp.client.pane.methylation;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.MethylationData;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.FileBrowser;

public class MethtylationReportSingleItem extends Composite
{
	public DisclosurePanel qcPanel = new DisclosurePanel("Summary Statistics");
	public DisclosurePanel filePanel = new DisclosurePanel("Download Files");
	//public DisclosurePanel tilesPanel = new DisclosurePanel("View Tile Images");
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	MethylationData beadArray;
	public MethtylationReportSingleItem(final MethylationData flowcellIn)
	{
		beadArray=flowcellIn;
		VerticalPanel vp = new VerticalPanel();
		FlexTable flowcellTable = new FlexTable();
		flowcellTable.addStyleName("flowcellitem");
		flowcellTable.setText(0,0, "Bead Array ID: " + beadArray.getFlowcellProperty("serial"));
		flowcellTable.setText(0,1, "Lims ID: " + beadArray.getFlowcellProperty("limsID"));
//		flowcellTable.setText(0,2, beadArray.getFlowcellProperty("technician") +" " + beadArray.getFlowcellProperty("date"));
		//flowcellTable.setText(1,0, "Protocol: " + beadArray.getFlowcellProperty("protocol"));
		//flowcellTable.setText(1,1, "Status: " + beadArray.getFlowcellProperty("status"));
		//flowcellTable.setText(1,2, "Control Lane: " + beadArray.getFlowcellProperty("control"));
		
		FlexTable flowcellTableSample = new FlexTable();
		flowcellTableSample.addStyleName("flowcellitemlane");
			
//		//HEADERS
		int row = 0;
		flowcellTableSample.setText(row,0, "Location");
		flowcellTableSample.setText(row,1, "Library");
		flowcellTableSample.setText(row,2, "Organism");
		flowcellTableSample.setText(row,3, "Sex");
		flowcellTableSample.setText(row,4, "Tissue");
		flowcellTableSample.setText(row,5, "Project");
		flowcellTableSample.setText(row,6, "Date");
		List<Integer> keys = new ArrayList<Integer>(beadArray.lane.keySet());
		Collections.sort(keys);
		
		for(int i : keys)
		{
			row++;
			flowcellTableSample.setText(row,0, beadArray.getLaneProperty(i,"lane"));
			flowcellTableSample.setText(row,1, beadArray.getLaneProperty(i,"name"));
			flowcellTableSample.setText(row,2, beadArray.getLaneProperty(i,"organism"));
			flowcellTableSample.setText(row,3, beadArray.getLaneProperty(i,"sex"));
			flowcellTableSample.setText(row,4, beadArray.getLaneProperty(i,"tissue"));
			flowcellTableSample.setText(row,5, beadArray.getLaneProperty(i,"project"));
			flowcellTableSample.setText(row,6, beadArray.getLaneProperty(i,"date"));
		}
		vp.add(flowcellTable);
		vp.add(flowcellTableSample);
		vp.add(qcPanel);
		vp.add(filePanel);
		//vp.add(tilesPanel);
		
		qcPanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
		{
			public void onOpen(OpenEvent<DisclosurePanel> event)
			{
				qcPanel.add(new Image("images/progress.gif"));
				remoteService.getQCforMeth(beadArray.getFlowcellProperty("serial"), new AsyncCallback<MethylationData>(){

					public void onFailure(Throwable caught)
					{
						qcPanel.clear();
						qcPanel.add(new Label(caught.getMessage()));
						
					}

					public void onSuccess(MethylationData result)
					{
						qcPanel.clear();
						beadArray.laneQC = result.laneQC;
						beadArray.filterLanesThatContain();
						VerticalPanel qcvp = new VerticalPanel();
						qcPanel.add(qcvp);
						for(String location : beadArray.laneQC.keySet())
						{
							qcvp.add(new Label("QC Metrics from " + location));
							FlexTable qcFlexTable = new  FlexTable();
							int j=0;
							Boolean firstLine = true;
							for(int i=1;i<=8;i++)
							{
								if(beadArray.laneQC.get(location).containsKey(i))
								{	
									j=0;
									if(firstLine)
									{						
										beadArray.laneQC.get(location).get(i).remove("FlowCelln");
										for(String s : beadArray.laneQC.get(location).get(i).keySet())
										{								
											qcFlexTable.setText(0, j, s);
											j++;
										}
										firstLine = false;
										j=0;
									}									
									
									beadArray.laneQC.get(location).get(i).remove("FlowCelln");
									for(String s : beadArray.laneQC.get(location).get(i).keySet())
									{
										qcFlexTable.setText(i, j, beadArray.laneQC.get(location).get(i).get(s));
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
				remoteService.getFilesForMeth(beadArray.getFlowcellProperty("serial"), new AsyncCallback<MethylationData>(){

					public void onFailure(Throwable caught)
					{
						filePanel.clear();
						filePanel.add(new Label(caught.getMessage()));
						
					}

					public void onSuccess(MethylationData result)
					{
						filePanel.clear();
						beadArray.fileList = result.fileList;
						beadArray.filterLanesThatContain();
						FileBrowser f = new FileBrowser(beadArray.fileList);
						filePanel.add(f);
					}});				
			}			
		});


		initWidget(vp);
	}
}
