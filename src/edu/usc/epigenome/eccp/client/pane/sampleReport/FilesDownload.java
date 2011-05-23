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
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.filereport.FileBrowser;

public class FilesDownload extends Composite {

	private static FilesDownloadUiBinder uiBinder = GWT
			.create(FilesDownloadUiBinder.class);

	interface FilesDownloadUiBinder extends UiBinder<Widget, FilesDownload> {
	}

	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	String flowcellSerial;
	int laneNo;
	SampleData sample;
	
	@UiField FlowPanel LabPanel;
	@UiField Label downloadF;
	@UiField DecoratedPopupPanel popup;
	@UiField FlowPanel mainPanel;
	@UiField FlowPanel summaryChart;
	@UiField Button closeButton;
	
	
	public FilesDownload() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	public FilesDownload(final SampleData sampleIn, final String flowcellSerialIn, final int lane)
	{
		flowcellSerial = flowcellSerialIn;
		sample = sampleIn;
		laneNo = lane;
		initWidget(uiBinder.createAndBindUi(this));
		
		popup.removeFromParent();
		
		closeButton.addClickHandler(new ClickHandler() {
			
			@Override
			public void onClick(ClickEvent arg0) 
			{
				popup.hide();
			}
		});
		
		downloadF.addClickHandler(new ClickHandler() 
		{	
			public void onClick(ClickEvent arg0) 
			{
				//popup.showRelativeTo(Statistics);
				popup.showRelativeTo(LabPanel);
				//Window.open(arg0, arg1, arg2)
				summaryChart.clear();
				summaryChart.add(new Label("Loading Data"));
				
				remoteService.getFilesforFlowcellLane(flowcellSerial, new AsyncCallback<SampleData>()
				{
					
					public void onFailure(Throwable caught)
					{
						summaryChart.clear();
						summaryChart.add(new Label(caught.getMessage()));				
					}

					@Override
					public void onSuccess(SampleData result) {
						// TODO Auto-generated method stub
						summaryChart.clear();
						sample.flowcellFileList = result.flowcellFileList;
						sample.filterFiles(lane);
						FileBrowser f = new FileBrowser(sample.flowcellFileList);
						summaryChart.add(f);
					}	
				});
			}
		});
	}
}
