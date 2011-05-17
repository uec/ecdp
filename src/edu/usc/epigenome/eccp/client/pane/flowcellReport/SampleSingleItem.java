package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import java.util.ArrayList;
import java.util.Set;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.SampleData;

public class SampleSingleItem extends Composite {
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	SampleData sampGeneus;
	
	public SampleSingleItem(final SampleData sampleIn)
	{
		sampGeneus = sampleIn;
		final VerticalPanel vp = new VerticalPanel();
		for(final String sampleID : sampGeneus.sampleInfo.keySet())
		{
			vp.add(new Label("Sample ID: " + sampleID));
			ArrayList<FlowcellData> fcells = sampGeneus.sampleInfo.get(sampleID);
			
			for(int j=0;j<fcells.size();j++)
			{
				final FlowcellData flowcell = fcells.get(j);
				
				 final DisclosurePanel fcellPanel = new DisclosurePanel("Flowcell ID: " + flowcell.getFlowcellProperty("serial"));
				 final DisclosurePanel qcPanel = new DisclosurePanel("Summary Statistics");
				 
				 final FlexTable flowcellTable = new FlexTable();
				 final FlexTable flowcellTableSample = new FlexTable();
				 final FlowPanel fp = new FlowPanel();
				 fp.add(flowcellTable);
				 fp.add(flowcellTableSample);
				 vp.add(fcellPanel);
				 fp.add(qcPanel);
				 fcellPanel.add(fp);
				fcellPanel.addOpenHandler(new OpenHandler<DisclosurePanel>() {
					
					public void onOpen(OpenEvent<DisclosurePanel> event) {
							
						flowcellTable.addStyleName("flowcellitem");
						flowcellTable.setText(0,0, "Flowcell ID: " + flowcell.getFlowcellProperty("serial"));
						flowcellTable.setText(0,1, "Lims ID: " + flowcell.getFlowcellProperty("limsID"));
						flowcellTable.setText(0,2, flowcell.getFlowcellProperty("technician") +" " + flowcell.getFlowcellProperty("date"));
						flowcellTable.setText(1,0, "Protocol: " + flowcell.getFlowcellProperty("protocol"));
						flowcellTable.setText(1,1, "Status: " + flowcell.getFlowcellProperty("status"));
						flowcellTable.setText(1,2, "Control Lane: " + flowcell.getFlowcellProperty("control"));
						
						//HEADERS
						flowcellTableSample.setText(0,0, "Processing");
						flowcellTableSample.setText(0,1, "Library");
						//flowcellTableSample.setText(0,2, "Geneusid");
						flowcellTableSample.setText(0,2, "Organism");
						flowcellTableSample.setText(0,3, "Project");
						
						Object a[] = flowcell.lane.keySet().toArray();
						for(int i=0;i<a.length;i++)
						{
							int laneNo =(Integer)a[i];
							flowcellTableSample.setText(i+1,0, flowcell.getLaneProperty(laneNo,"processing"));
							flowcellTableSample.setText(i+1,1, flowcell.getLaneProperty(laneNo,"library"));
							flowcellTableSample.setText(i+1,2, flowcell.getLaneProperty(laneNo,"organism"));
							flowcellTableSample.setText(i+1,3, flowcell.getLaneProperty(laneNo,"project"));
						}
					}});	
				
				qcPanel.addOpenHandler(new OpenHandler<DisclosurePanel>() 
				{
					public void onOpen(OpenEvent<DisclosurePanel> OEvent) 
					{
						qcPanel.add(new Image("images/progress.gif"));
						remoteService.getQCSampleFlowcell(flowcell.getFlowcellProperty("serial"), sampleID, new AsyncCallback<FlowcellData>() 
						{
							public void onFailure(Throwable caught) 
							{
								qcPanel.clear();
								qcPanel.add(new Label(caught.getMessage()));
							}
							public void onSuccess(FlowcellData sresult) 
							{
								qcPanel.clear();
								flowcell.laneQC = sresult.laneQC;
								flowcell.filterSamplesLanes(sampleID);
								VerticalPanel qcvp = new VerticalPanel();
								qcPanel.add(qcvp);
										
								for(String location : flowcell.laneQC.keySet())
								{
									qcvp.add(new Label("QC Metric from " + location));
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
					}});
				
				/*qcPanel.addOpenHandler(new OpenHandler<DisclosurePanel>() 
				{
					public void onOpen(OpenEvent<DisclosurePanel> OEvent) 
					{
						qcPanel.add(new Image("images/progress.gif"));
						remoteService.getQCforFlowcell(flowcell.getFlowcellProperty("serial"), new AsyncCallback<FlowcellData>() 
						{
							public void onFailure(Throwable caught) 
							{
								qcPanel.clear();
								qcPanel.add(new Label(caught.getMessage()));
							}
							public void onSuccess(FlowcellData sresult) 
							{
								qcPanel.clear();
								flowcell.laneQC = sresult.laneQC;
								flowcell.filterSamplesLanes(sampleID);
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
				});*/
			}
		}
		initWidget(vp);
	}

}
