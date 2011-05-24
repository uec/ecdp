package edu.usc.epigenome.eccp.client.pane.sampleReport;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.logical.shared.CloseEvent;
import com.google.gwt.event.logical.shared.CloseHandler;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.DisclosurePanelImages;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Tree;
import com.google.gwt.user.client.ui.TreeItem;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.SampleData;

public class SampleSingleReport extends Composite {

	private static SampleSingleReportUiBinder uiBinder = GWT
			.create(SampleSingleReportUiBinder.class);

	interface SampleSingleReportUiBinder extends
			UiBinder<Widget, SampleSingleReport> {
	}
	
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	SampleData sampGeneus;
	
	public SampleSingleReport() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	/*//@UiField TreeItem sampleData;
	@UiField Tree root;
	//@UiField FlexTable data;
	
	public SampleSingleReport(final SampleData sampleIn)
	{
		sampGeneus = sampleIn;
		initWidget(uiBinder.createAndBindUi(this));
		
		StringBuffer sb = new StringBuffer("Library: " + sampGeneus.getSampleProperty("library"));
		sb.append("    Project: " + sampGeneus.getSampleProperty("project"));
		//sampleData.setHTML(sb.toString());
		//FlexTable data = new FlexTable();
		TreeItem sampleData = new TreeItem("Library");
		root.addItem(sampleData);
		//sampleData.addItem(data);
		//data.setText(0, 0, "Library: " + sampGeneus.getSampleProperty("library"));
		//data.setText(0, 1, "Project: " + sampGeneus.getSampleProperty("project"));
		//data.setText(0, 2, "Organism: " + sampGeneus.getSampleProperty("organism"));
		//data.setText(0, 3, "Date: " + sampGeneus.getSampleProperty("date"));
		
	}*/

	@UiField FlowPanel vp;
	@UiField FlexTable sampleData;
	@UiField FlowPanel dataDisplay;
	@UiField DisclosurePanel sampleInfoPanel;
	@UiField HorizontalPanel sampHeader;
	@UiField Image headerIcon;
	
	public SampleSingleReport(final SampleData sampleIn)
	{
		sampGeneus = sampleIn;
		initWidget(uiBinder.createAndBindUi(this));
		
		//headerIcon.setUrl("images/rightArrow.png");
		sampleData.setText(0, 0, "Library: " + sampGeneus.getSampleProperty("library"));
		sampleData.setText(0, 1, "Project: " + sampGeneus.getSampleProperty("project"));
		sampleData.setText(0, 2, "Organism: " + sampGeneus.getSampleProperty("organism"));
		sampleData.setText(0, 3, "Date: " + sampGeneus.getSampleProperty("date"));
		
		
		sampleInfoPanel.addCloseHandler(new CloseHandler<DisclosurePanel>() 
		{	
			public void onClose(CloseEvent<DisclosurePanel> arg0) 
			{
				headerIcon.setUrl("images/panelclosed.png");
			}
		});
		sampleInfoPanel.addOpenHandler(new OpenHandler<DisclosurePanel>() 
		{
			public void onOpen(OpenEvent<DisclosurePanel> arg0) 
			{
				headerIcon.setUrl("images/panelopen.png");
				dataDisplay.clear();
				for(final String flowcellSerial : sampGeneus.flowcellInfo.keySet())
				{
					HorizontalPanel fcellPanel = new HorizontalPanel();
					FlexTable fcellInfo  = new FlexTable();
					final Image fcellInfoImage = new Image("images/panelclosed.png");
					fcellInfo.setText(0,0,"Flowcell ID: " + flowcellSerial);
					fcellInfo.setText(0, 1, "Technician: " + sampGeneus.flowcellInfo.get(flowcellSerial).get("technician"));
					
					fcellPanel.add(fcellInfoImage);
					fcellPanel.add(fcellInfo);
					
					@SuppressWarnings("deprecation")
					final DisclosurePanel flowcellShow = new DisclosurePanel(fcellPanel);
					flowcellShow.setAnimationEnabled(true);
					
					flowcellShow.addCloseHandler(new CloseHandler<DisclosurePanel>() {

						public void onClose(CloseEvent<DisclosurePanel> arg0) {
								
							fcellInfoImage.setUrl("images/panelclosed.png");
						}});
					
					flowcellShow.addOpenHandler(new OpenHandler<DisclosurePanel>() 
					{
						public void onOpen(OpenEvent<DisclosurePanel> arg0) 
						{
							fcellInfoImage.setUrl("images/panelopen.png");
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
									FlowPanel holdLane = new FlowPanel();
									flowcellShow.add(holdLane);
									
									for(final Integer laneNo : sampGeneus.flowcellLane.keySet())
									{
										HorizontalPanel holdLanePanel = new HorizontalPanel();
										//content of flowcellshow panel is holdLane (consisting of lanes and images)
										
										FlexTable laneInfoTable = new FlexTable();
										final Image laneInfoImage = new Image("images/panelclosed.png");
										laneInfoTable.setText(0,0,"Lane No: " + laneNo);
										laneInfoTable.setText(0,1,"Processing: " + sampGeneus.flowcellLane.get(laneNo).get("processing"));
										holdLanePanel.add(laneInfoImage);
										holdLanePanel.add(laneInfoTable);
										
										@SuppressWarnings("deprecation")
										final DisclosurePanel laneInfoPanel = new DisclosurePanel(holdLanePanel);
										laneInfoPanel.setAnimationEnabled(true);
										//laneInfoPanel.setHeader(laneInfoTable);
										
										laneInfoPanel.addCloseHandler(new CloseHandler<DisclosurePanel>(){
											public void onClose(CloseEvent<DisclosurePanel> arg0) {
												laneInfoImage.setUrl("images/panelclosed.png");
											}});
										
										laneInfoPanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
										{
											public void onOpen(OpenEvent<DisclosurePanel> arg0) 
											{
												laneInfoImage.setUrl("images/panelopen.png");
												laneInfoPanel.clear();
												
												FlowPanel ReportPanel = new FlowPanel();
												FlowPanel DownloadPanel = new FlowPanel();
												FlowPanel QCDownloadPanel = new FlowPanel();
												laneInfoPanel.add(QCDownloadPanel);
												QCDownloadPanel.add(ReportPanel);
												QCDownloadPanel.add(DownloadPanel);
												ReportPanel.add(new QCReport(sampGeneus, flowcellSerial, laneNo));
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
