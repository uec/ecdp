package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.LinkedHashMap;

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
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECCPBinderWidget;
import edu.usc.epigenome.eccp.client.ECControlCenter;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.GenUserBinderWidget;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.FileData;
import edu.usc.epigenome.eccp.client.data.NameValue;
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
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
	String run;
	FlowcellData flowcell;
	
	@UiField Label downloadF;
	@UiField VerticalPanel popup;
	@UiField FlowPanel summaryChart;
	
	public FilesDownload() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	/*
	 * Constructor for the download files section
	 */
	public FilesDownload(final FlowcellData flowcellIn, final String flowcellSerialIn, final int lane, final String runId, final String library, final String sampleID)
	{
		flowcellSerial = flowcellSerialIn;
		flowcell = flowcellIn;
		laneNo = lane;
		run = runId;
		initWidget(uiBinder.createAndBindUi(this));
		
		//popup.removeFromParent();
		
		//On click of the downloadFiles button, remoteService call to the backend to get the files
		downloadF.addClickHandler(new ClickHandler() 
		{	
			public void onClick(ClickEvent arg0) 
			{
				//Check for the user type and accordingly add tab to the respective TabPanel
				if(ECControlCenter.getUserType().equalsIgnoreCase("super"))
					ECCPBinderWidget.addtoTab(popup, "Files" +library + "_" + flowcellSerial);
				else if(ECControlCenter.getUserType().equalsIgnoreCase("guest"))
					GenUserBinderWidget.addtoTab(popup, "Files" + library + "_" + flowcellSerial);
				
				summaryChart.clear();
				summaryChart.add(new Label("Loading Data"));
				
				//Remote service call to the backend to get the files for the specified sample, flowcell and run
				remoteService.getFilesforRunSample(run, flowcellSerial, sampleID, new AsyncCallback<FlowcellData>()
				{
					public void onFailure(Throwable caught)
					{
						summaryChart.clear();
						summaryChart.add(new Label(caught.getMessage()));				
					}
					public void onSuccess(FlowcellData result) 
					{
						summaryChart.clear();
						flowcell.fileList = result.fileList;
						//Filter the files and them to the summaryChart
						flowcell.filterFiles(lane, sampleID, run);
						final DownloadGridWidget grid = new DownloadGridWidget();
						grid.setHeadingText("Sample:" + library + " > Flowcell:" + flowcellSerial + " > Lane:"+ laneNo + " > Run: " + (run.length() > 40 ? "..." + run.subSequence(run.length() - 40, run.length()) : run));
						summaryChart.add(grid);
						final ArrayList<FileData> data = new ArrayList<FileData>();
						for (LinkedHashMap<String, String> record: flowcell.fileList) {
							FileData item = new FileData();
							//public void setAll(String name,	String location, String type,String source,	String category, String downloadLocation)
							item.setAll(record.get("base"), record.get("fullpath"), record.get("label"),record.get("type"),"","",record.get("encfullpath"));					
							data.add(item);
						}
						grid.populateGrid(data);
					//	FileBrowser f = new FileBrowser(flowcell.fileList);
					//	summaryChart.add(f);
					}	
				});
			}
		});
	}
}

/*public FilesDownload(final SampleData sampleIn, final String flowcellSerialIn, final int lane, final String runId)
{
	flowcellSerial = flowcellSerialIn;
	sample = sampleIn;
	laneNo = lane;
	run = runId;
	initWidget(uiBinder.createAndBindUi(this));
	
	popup.removeFromParent();
	
	downloadF.addClickHandler(new ClickHandler() 
	{	
		public void onClick(ClickEvent arg0) 
		{
			if(ECControlCenter.getUserType().equalsIgnoreCase("super"))
				ECCPBinderWidget.addtoTab(popup, "Files" +sample.getSampleProperty("library") + "_" + flowcellSerial);
			else if(ECControlCenter.getUserType().equalsIgnoreCase("guest"))
				GenUserBinderWidget.addtoTab(popup, "Files" + sample.getSampleProperty("library") + "_" + flowcellSerial);
			//popup.showRelativeTo(downloadF);
			//Window.open(arg0, arg1, arg2)
			summaryChart.clear();
			summaryChart.add(new Label("Loading Data"));
			
			remoteService.getFilesforRunSample(run, flowcellSerial, sample.getSampleProperty("geneusID_sample"), new AsyncCallback<FlowcellData>()
			{
				public void onFailure(Throwable caught)
				{
					summaryChart.clear();
					summaryChart.add(new Label(caught.getMessage()));				
				}
				public void onSuccess(FlowcellData result) {
					summaryChart.clear();
					//Window.alert("the size of result set is " + result.fileList.size());
					summaryChart.add(new Label("Sample:" + sample.getSampleProperty("library") + " > Flowcell:" + flowcellSerial + " > Lane:"+ laneNo + " > Run:" + run));
					sample.sampleFlowcells.get(flowcellSerial).fileList = result.fileList;
					sample.sampleFlowcells.get(flowcellSerial).filterFiles(lane, sample.getSampleProperty("geneusID_sample"), run);
					FileBrowser f = new FileBrowser(sample.sampleFlowcells.get(flowcellSerial).fileList);
					summaryChart.add(f);
				}	
			});
		}
	});
}*/
