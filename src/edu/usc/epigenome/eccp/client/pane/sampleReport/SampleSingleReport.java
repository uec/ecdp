package edu.usc.epigenome.eccp.client.pane.sampleReport;

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
import com.google.gwt.user.client.ui.DisclosurePanelImages;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.SampleData;

public class SampleSingleReport extends Composite {

	private static SampleSingleReportUiBinder uiBinder = GWT
			.create(SampleSingleReportUiBinder.class);

	interface SampleSingleReportUiBinder extends
			UiBinder<Widget, SampleSingleReport> {
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	SampleData sampGeneus;
	
	public SampleSingleReport() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	@UiField FlowPanel vp;
	@UiField FlexTable sampleData;
	@UiField FlowPanel dataDisplay;
	//@UiField FlexTable flowcellInfo;
	@UiField DisclosurePanel sampleInfoPanel;
	
	public SampleSingleReport(final SampleData sampleIn)
	{
		sampGeneus = sampleIn;
		initWidget(uiBinder.createAndBindUi(this));
		
		sampleData.setText(0, 0, "Library: " + sampGeneus.getSampleProperty("library"));
		sampleData.setText(0, 1, "Project: " + sampGeneus.getSampleProperty("project"));
		sampleData.setText(0, 2, "Organism: " + sampGeneus.getSampleProperty("organism"));
		sampleData.setText(0, 3, "Date: " + sampGeneus.getSampleProperty("date"));
		
		sampleInfoPanel.addOpenHandler(new OpenHandler<DisclosurePanel>() 
		{
			public void onOpen(OpenEvent<DisclosurePanel> arg0) 
			{
				dataDisplay.clear();
				for(final String flowcellSerial : sampGeneus.flowcellInfo.keySet())
				{
					Label fcellInfo = new Label();
					fcellInfo.setText("Flowcell ID: " + flowcellSerial + "\t Technician: " + sampGeneus.flowcellInfo.get(flowcellSerial).get("technician"));
					//FlexTable fcellInfo  = new FlexTable();
					//fcellInfo.setText(0,0,"Flowcell ID: " + flowcellSerial);
					//fcellInfo.setText(0, 1, "Technician: " + sampGeneus.flowcellInfo.get(flowcellSerial).get("technician"));
					@SuppressWarnings("deprecation")
					final DisclosurePanel flowcellShow = new DisclosurePanel(fcellInfo);
					flowcellShow.setAnimationEnabled(true);
					//flowcellShow.setHeader(fcellInfo);
					//flowcellShow.
					//final DisclosurePanel flowcellShow = new DisclosurePanel
					
					flowcellShow.addOpenHandler(new OpenHandler<DisclosurePanel>() 
					{
						public void onOpen(OpenEvent<DisclosurePanel> arg0) 
						{
							remoteService.getLaneFlowcellSample(sampGeneus.sampleProperties.get("library"), flowcellSerial, new AsyncCallback<SampleData>() 
							{
								public void onFailure(Throwable arg0) 
								{
									flowcellShow.clear();
								}
								public void onSuccess(SampleData result) 
								{
									flowcellShow.clear();
									sampGeneus.flowcellLane = result.flowcellLane;
									VerticalPanel holdLane = new VerticalPanel();
									flowcellShow.add(holdLane);
									
									for(final Integer laneNo : sampGeneus.flowcellLane.keySet())
									{
										FlexTable laneInfoTable = new FlexTable();
										laneInfoTable.setText(0,0,"Lane No: " + laneNo);
										laneInfoTable.setText(0,1,"Processing: " + sampGeneus.flowcellLane.get(laneNo).get("processing"));
										
										@SuppressWarnings("deprecation")
										final DisclosurePanel laneInfoPanel = new DisclosurePanel(laneInfoTable);
										laneInfoPanel.setAnimationEnabled(true);
										//laneInfoPanel.setHeader(laneInfoTable);
										
										laneInfoPanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
										{
											public void onOpen(OpenEvent<DisclosurePanel> arg0) 
											{
												laneInfoPanel.clear();
												FlowPanel ReportPanel = new FlowPanel();
												FlowPanel DownloadPanel = new FlowPanel();
												FlowPanel QCDownloadPanel = new FlowPanel();
												laneInfoPanel.add(QCDownloadPanel);
												QCDownloadPanel.add(ReportPanel);
												QCDownloadPanel.add(DownloadPanel);
												ReportPanel.add(new QCReport(sampGeneus, flowcellSerial));
												DownloadPanel.add(new FilesDownload(sampGeneus, flowcellSerial, laneNo));
											}
										});
										holdLane.add(laneInfoPanel);
									}		
								}});
						}});
					dataDisplay.add(flowcellShow);
				}
			}});
	}
}
