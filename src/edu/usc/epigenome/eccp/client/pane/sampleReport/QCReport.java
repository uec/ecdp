package edu.usc.epigenome.eccp.client.pane.sampleReport;

import com.google.gwt.core.client.GWT;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedPopupPanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECCPBinderWidget;
import edu.usc.epigenome.eccp.client.ECControlCenter;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.GenUserBinderWidget;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.SampleData;

public class QCReport extends Composite {

	private static QCReportUiBinder uiBinder = GWT
			.create(QCReportUiBinder.class);

	interface QCReportUiBinder extends UiBinder<Widget, QCReport> {
	}
	
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	String flowcellSerial;
	FlowcellData flowcell;
	int laneNo;
	String run;
	
	@UiField Label Statistics;
	@UiField VerticalPanel popup;
	@UiField FlowPanel summaryChart;
	
	
	public QCReport() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	/*
	 * Constructor to get QC metrics information from the database
	 */
	public QCReport(final FlowcellData flowcellIn, final String flowcellSerialIn, final int lane, final String runId, final String library, final String sampleID)
	{
		flowcellSerial = flowcellSerialIn;
		flowcell = flowcellIn;
		laneNo = lane;
		run = runId;
		initWidget(uiBinder.createAndBindUi(this));
		
		//popup.removeFromParent();
		
		//OnClick of the statistics label, remoteService call to the backend to get the QCmetrics information
		Statistics.addClickHandler(new ClickHandler() 
		{	
			public void onClick(ClickEvent arg0) 
			{
				//Depending on the userMode add the QC metrics for the respective user
				if(ECControlCenter.getUserType().equalsIgnoreCase("super"))
					ECCPBinderWidget.addtoTab(popup, "QC" + library + "_" + flowcellSerial);
				else if(ECControlCenter.getUserType().equalsIgnoreCase("guest"))
					GenUserBinderWidget.addtoTab(popup, "QC" +library + "_" + flowcellSerial);
				
				summaryChart.clear();
				summaryChart.add(new Label("Loading Data"));
				
				//RemoteService call to the backend to get the QC for the given flowcell, library and laneNo
				//Window.alert("the user type is " + ECControlCenter.getUserType());
				remoteService.getQCSampleFlowcell(flowcellSerial, library,laneNo,  ECControlCenter.getUserType(), new AsyncCallback<FlowcellData>()
				{	
					public void onFailure(Throwable arg0) 
					{
						summaryChart.clear();
						summaryChart.add(new Label("Error Loading, Try again Later...."));
					}
					public void onSuccess(FlowcellData result)
					{
						summaryChart.clear();
						MetricGridWidget grid = new MetricGridWidget();
						summaryChart.add(grid);
						/*summaryChart.clear();
						flowcell.laneQC = result.laneQC;
						summaryChart.add(new Label("Sample:" + library + " > Flowcell:" + flowcellSerial + " > Lane:"+ laneNo + " > Run:" + run));
						//Filter information retrieved from the backend
						flowcell.filterQC(lane);
						flowcell.filterAnalysis(flowcellSerial, laneNo, sampleID);
						flowcell.filterRuns(run);

						for(String location : flowcell.laneQC.keySet())
						{
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
											qcFlexTable.setText(j, 0, s);
											j++;
										}
										firstLine = false;
										j=0;
									}									
											
									flowcell.laneQC.get(location).get(i).remove("FlowCelln");
									for(String s : flowcell.laneQC.get(location).get(i).keySet())
									{
										qcFlexTable.setText(j, i, flowcell.laneQC.get(location).get(i).get(s));
										j++;
									}
								}
							}
							summaryChart.add(qcFlexTable);
						}*/
					} 
					}); //end remoteService call
			}});
	}

}


/*public QCReport(final SampleData sampleIn, final String flowcellSerialIn, final int lane, final String runId)
{
	flowcellSerial = flowcellSerialIn;
	sample = sampleIn;
	laneNo = lane;
	run = runId;
	initWidget(uiBinder.createAndBindUi(this));
	
	popup.removeFromParent();
	
	Statistics.addClickHandler(new ClickHandler() 
	{	
		public void onClick(ClickEvent arg0) 
		{
			if(ECControlCenter.getUserType().equalsIgnoreCase("super"))
				ECCPBinderWidget.addtoTab(popup, "QC" + sample.getSampleProperty("library") + "_" + flowcellSerial);
			else if(ECControlCenter.getUserType().equalsIgnoreCase("guest"))
				GenUserBinderWidget.addtoTab(popup, "QC" + sample.getSampleProperty("library") + "_" + flowcellSerial);
			
			summaryChart.clear();
			summaryChart.add(new Label("Loading Data"));
			
			
			remoteService.getQCSampleFlowcell(flowcellSerial, sample.sampleProperties.get("library"),laneNo,  new AsyncCallback<FlowcellData>()
			{	
				public void onFailure(Throwable arg0) 
				{
					summaryChart.clear();
					summaryChart.add(new Label("Error Loading, Try again Later...."));
				}
				public void onSuccess(FlowcellData result)
				{
					summaryChart.clear();
					sample.sampleFlowcells.get(flowcellSerial).laneQC = result.laneQC;
					//Window.alert(" serial passed " + flowcellSerial + " lane " + laneNo + " runId " + run);
					summaryChart.add(new Label("Sample:" + sample.getSampleProperty("library") + " > Flowcell:" + flowcellSerial + " > Lane:"+ laneNo + " > Run:" + run));
					sample.sampleFlowcells.get(flowcellSerial).filterQC(lane);
					sample.sampleFlowcells.get(flowcellSerial).filterAnalysis(flowcellSerial, laneNo, sample.getSampleProperty("geneusID_sample"));
					sample.sampleFlowcells.get(flowcellSerial).filterRuns(run);
					
					for(String location : sample.sampleFlowcells.get(flowcellSerial).laneQC.keySet())
					{
						//summaryChart.add(new Label("QC Metric from " + location));
						FlexTable qcFlexTable = new FlexTable();
						int j=0;
						Boolean firstLine = true;
						for(int i=1;i<=8;i++)
						{
							if(sample.sampleFlowcells.get(flowcellSerial).laneQC.get(location).containsKey(i))
							{	
								j=0;
								if(firstLine)
								{						
									sample.sampleFlowcells.get(flowcellSerial).laneQC.get(location).get(i).remove("FlowCelln");
									for(String s : sample.sampleFlowcells.get(flowcellSerial).laneQC.get(location).get(i).keySet())
									{								
										qcFlexTable.setText(j, 0, s);
										j++;
									}
									firstLine = false;
									j=0;
								}									
										
								sample.sampleFlowcells.get(flowcellSerial).laneQC.get(location).get(i).remove("FlowCelln");
								for(String s : sample.sampleFlowcells.get(flowcellSerial).laneQC.get(location).get(i).keySet())
								{
									qcFlexTable.setText(j, i, sample.sampleFlowcells.get(flowcellSerial).laneQC.get(location).get(i).get(s));
									j++;
								}
							}
						}
						//qcFlexTable.addStyleName("qctable");
						summaryChart.add(qcFlexTable);
					}
				}});
		}});
}*/
