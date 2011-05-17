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
import com.google.gwt.user.client.ui.Widget;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.pane.ECPane;


public class FlowcellReport extends ECPane{

	private static FlowcellReportUiBinder uiBinder = GWT
			.create(FlowcellReportUiBinder.class);

	interface FlowcellReportUiBinder extends UiBinder<Widget, FlowcellReport> {
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	public enum ReportType 	{ShowSamples, ShowAll, ShowGeneus, ShowFS, ShowComplete,ShowIncomplete}
	private ReportType reportType;
	
	@UiField FlowPanel mainPanel;
	@UiField FlowPanel searchPanel;
	@UiField HorizontalPanel searchOptionsPanel;
	@UiField FlowPanel vp;
	@UiField Button searchButton;
	
	public FlowcellReport(){
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
				Window.alert("Widgets are " + searchPanel.getWidgetCount());
				if(searchPanel.getWidgetCount() > 1)
				{	
					searchPanel.clear();
					searchPanel.add(searchOptionsPanel);
				}
				
				vp.clear();
				vp.add(new Image("images/progress.gif"));
				showTool();
			}});
	}

	@Override
	public void showTool() 
	{
		String name = reportType.name();
		if(name.equals("ShowSamples"))
		{
			AsyncCallback<ArrayList<SampleData>> DisplayFlowcellCallback = new AsyncCallback<ArrayList<SampleData>>()
		    {
				public void onFailure(Throwable caught)
				{
					vp.clear();	
					caught.printStackTrace();				
				}
				public void onSuccess(ArrayList<SampleData> result)
				{
					vp.clear();
					for(SampleData sampl : result)
					{
						SampleSingleItem flowcellItem = new SampleSingleItem(sampl);
						vp.add(flowcellItem);
					}
				}
		    };remoteService.getSampleDataFromGeneus(DisplayFlowcellCallback);
		}
		else
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
					{
						FlowcellSingleItem flowcellItem = new FlowcellSingleItem(flowcell);
						vp.add(flowcellItem);
					}
				}
		  };
		  
		  switch(reportType)
			{
				case ShowGeneus: remoteService.getFlowcellsFromGeneus(DisplayFlowcellCallback);break;
				case ShowFS: remoteService.getFlowcellsFromFS(DisplayFlowcellCallback);break;
				case ShowIncomplete: remoteService.getFlowcellsIncomplete(DisplayFlowcellCallback);break;
				case ShowComplete: remoteService.getFlowcellsComplete(DisplayFlowcellCallback);break;
				default: remoteService.getFlowcellsAll(DisplayFlowcellCallback);break;			
			}
		}
	}

	@Override
	public Image getToolLogo() {
		return null;
	}

	@Override
	public com.google.gwt.user.client.ui.Label getToolTitle() {
		return null;
	}

}
