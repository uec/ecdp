package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.dev.asm.Label;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.pane.ECPaneInterface;

public class FlowcellReport extends Composite implements ECPaneInterface{

	private static FlowcellReportUiBinder uiBinder = GWT
			.create(FlowcellReportUiBinder.class);

	interface FlowcellReportUiBinder extends UiBinder<Widget, FlowcellReport> {
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	public enum ReportType 	{ShowAll, ShowGeneus, ShowFS, ShowComplete,ShowIncomplete}
	private ReportType reportType;
	
	@UiField FlowPanel mainPanel;
	@UiField FlowPanel searchPanel;
	@UiField HorizontalPanel searchOptionsPanel;
	@UiField VerticalPanel vp;
	@UiField Button searchButton;
	
	public FlowcellReport(){
		initWidget(uiBinder.createAndBindUi(this));
		//showTool();
	}

	public FlowcellReport(ReportType reprotTypein)
	{
		reportType = reprotTypein;
		initWidget(uiBinder.createAndBindUi(this));
		
		searchButton.addClickHandler(new ClickHandler() 
		{	
			@Override
			public void onClick(ClickEvent event) 
			{
				if(searchPanel.getWidgetCount() > 1)
				{
					searchPanel.clear();
					searchPanel.add(searchOptionsPanel);
				}	
			}
		});
		showTool();
	}

	@Override
	public void showTool() 
	{
		 //Window.alert("The report type is " +reportType);
		 
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
		  };remoteService.getFlowcellsFromGeneus(DisplayFlowcellCallback);
			
		 //VerticalPanel toHold = new VerticalPanel();
		//FlowcellSingleItem flowcellItem = new FlowcellSingleItem();
		//vp.add(flowcellItem);
	}

	@Override
	public Image getToolLogo() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public com.google.gwt.user.client.ui.Label getToolTitle() {
		// TODO Auto-generated method stub
		return null;
	}

}
