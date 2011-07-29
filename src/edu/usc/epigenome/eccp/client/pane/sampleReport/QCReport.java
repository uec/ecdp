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
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECCPBinderWidget;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
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
	SampleData sample;
	int laneNo;
	
	@UiField FlowPanel LabPanel;
	@UiField Label Statistics;
	@UiField FlowPanel popup;
	@UiField FlowPanel mainPanel;
	@UiField FlowPanel summaryChart;
	//@UiField Button closeButton;
	
	
	public QCReport() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	public QCReport(final SampleData sampleIn, final String flowcellSerialIn, final int lane)
	{
		flowcellSerial = flowcellSerialIn;
		sample = sampleIn;
		laneNo = lane;
		initWidget(uiBinder.createAndBindUi(this));
		
		popup.removeFromParent();
		
	/*	closeButton.addClickHandler(new ClickHandler() {
			
			@Override
			public void onClick(ClickEvent arg0) 
			{
				popup.hide();
			}
		});*/
		
		Statistics.addClickHandler(new ClickHandler() 
		{	
			public void onClick(ClickEvent arg0) 
			{
				ECCPBinderWidget.addtoTab(popup, "QCReport"+sample.getSampleProperty("library") + " " + flowcellSerial + " " + lane);
				//popup.showRelativeTo(Statistics);
				//Window.open(arg0, arg1, arg2)
				summaryChart.clear();
				summaryChart.add(new Label("Loading Data"));
				
				remoteService.getQCSampleFlowcell(flowcellSerial, sample.sampleProperties.get("library"), new AsyncCallback<SampleData>()
				{	
					public void onFailure(Throwable arg0) 
					{
						summaryChart.clear();
						summaryChart.add(new Label("Error Loading, Try again Later...."));
					}
					public void onSuccess(SampleData result)
					{
						summaryChart.clear();
						sample.flowcellLaneQC = result.flowcellLaneQC;
						sample.filterQC(lane);
						sample.filterAnalysis(flowcellSerial, laneNo);
						
						for(String location : sample.flowcellLaneQC.keySet())
						{
							summaryChart.add(new Label("QC Metric from " + location));
							FlexTable qcFlexTable = new FlexTable();
							int j=0;
							Boolean firstLine = true;
							for(int i=1;i<=8;i++)
							{
								if(sample.flowcellLaneQC.get(location).containsKey(i))
								{	
									j=0;
									if(firstLine)
									{						
										sample.flowcellLaneQC.get(location).get(i).remove("FlowCelln");
										for(String s : sample.flowcellLaneQC.get(location).get(i).keySet())
										{								
											qcFlexTable.setText(0, j, s);
											j++;
										}
										firstLine = false;
										j=0;
									}									
											
									sample.flowcellLaneQC.get(location).get(i).remove("FlowCelln");
									for(String s : sample.flowcellLaneQC.get(location).get(i).keySet())
									{
										qcFlexTable.setText(i, j, sample.flowcellLaneQC.get(location).get(i).get(s));
										j++;
									}
								}
							}
							qcFlexTable.addStyleName("qctable");
							summaryChart.add(qcFlexTable);
						}
					}});
			}});
	}

}
