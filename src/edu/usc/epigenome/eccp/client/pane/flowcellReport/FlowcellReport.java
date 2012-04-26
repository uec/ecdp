package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.pane.ECPane;

public class FlowcellReport extends ECPane{

	private static FlowcellReportUiBinder uiBinder = GWT.create(FlowcellReportUiBinder.class);

	interface FlowcellReportUiBinder extends UiBinder<Widget, FlowcellReport> {}

	static 
	{UserPanelResources.INSTANCE.userPanel().ensureInjected();}
	
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	public enum ReportType 	{ShowSamples, ShowAll, ShowGeneus, ShowFS, ShowComplete,ShowIncomplete}
	private ReportType reportType;
	
	@UiField FlowPanel searchPanel;
	@UiField TextBox laneSearchBox;
	//@UiField TextBox globalSearchBox;
	@UiField FlowPanel vp;
	@UiField Button searchButton;
	
	public FlowcellReport()
	{
	   initWidget(uiBinder.createAndBindUi(this));
	   //showTool();
	}

	public FlowcellReport(ReportType reprotTypein)
	{
		reportType = reprotTypein;
		initWidget(uiBinder.createAndBindUi(this));
		vp.add(new Image("images/progress.gif"));
		searchButton.addClickHandler(new ClickHandler() 
		{	
		   public void onClick(ClickEvent event) 
		   {
			 if(searchPanel.getWidgetCount() > 1)
			 {searchPanel.clear();}
			 
			 vp.clear();
			 vp.add(new Image("images/progress.gif"));
			 showTool();
		}});
	}

	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.pane.ECPane#showTool()
	 * Remote Service call to the backend to get list of all the flowcells.
	 *Also perform search for the searchItem entered in the text box and get a filtered list
	 */
	public void showTool() 
	{
	  AsyncCallback<ArrayList<FlowcellData>> DisplayFlowcellCallback = new AsyncCallback<ArrayList<FlowcellData>>()
	  {
		public void onFailure(Throwable caught)
		{
		  vp.clear();	
		  caught.printStackTrace();				
		}
		public void onSuccess(ArrayList<FlowcellData> result)
		{
		  vp.clear();
		  for(FlowcellData flowcell : result)
		  //if(flowcell.flowcellContains(globalSearchBox.getText()))
		  if(flowcell.filterLanesThatContain(laneSearchBox.getText()))
		  {
			 FlowcellSingleItem flowcellItem = new FlowcellSingleItem(flowcell);
			 vp.add(flowcellItem);
		  }
		}
	};
	 switch(reportType)
	{
	  case ShowGeneus: remoteService.getFlowcellsFromGeneus(DisplayFlowcellCallback);break;
	  default: remoteService.getFlowcellsAll(DisplayFlowcellCallback);break;			
	}
  }

	public Image getToolLogo() {
		return null;
	}

	public com.google.gwt.user.client.ui.Label getToolTitle() {
		return null;
	}

}
