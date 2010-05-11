package edu.usc.epigenome.eccp.client.pane.flowcellReport;
import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.pane.ECPane;

public class FlowcellReport extends ECPane
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	final VerticalPanel mainPanel = new VerticalPanel();
	final VerticalPanel vp = new VerticalPanel();
	final HorizontalPanel searchOptionsPanel = new HorizontalPanel();
	final VerticalPanel searchPanel = new VerticalPanel();
	final TextBox globalSearchBox = new TextBox();
	final TextBox laneSearchBox = new TextBox();
	final Button searchButton = new Button("search");
	public enum ReportType 	{ShowAll, ShowGeneus, ShowFS, ShowComplete,ShowIncomplete}
	private ReportType reportType; 
	
	public FlowcellReport(ReportType reportTypein)
	{
		searchPanel.add(searchOptionsPanel);
		searchPanel.addStyleName("flowcellsearch");
		searchOptionsPanel.add(new Label("Flowcell Properties: "));
		searchOptionsPanel.add(globalSearchBox);
		searchOptionsPanel.add(new Label("Lane Properties: "));
		searchOptionsPanel.add(laneSearchBox);
		searchOptionsPanel.add(searchButton);
		searchOptionsPanel.addStyleName("flowcellsearch");
		mainPanel.add(searchPanel);
		mainPanel.add(vp);
		reportType = reportTypein;
		vp.add(new Image("images/progress.gif"));
		if(Window.Location.getParameter("g") != null)
		{
			String decoded = "";
			for(int i=0;i<Window.Location.getParameter("g").length();i+=3)
				decoded += (char)Integer.parseInt(Window.Location.getParameter("g").substring(i,i+3));
			globalSearchBox.setText(decoded);
		}
		if(Window.Location.getParameter("l") != null)
		{
			String decoded = "";
			for(int i=0;i<Window.Location.getParameter("l").length();i+=3)
				decoded += (char)Integer.parseInt(Window.Location.getParameter("l").substring(i,i+3));
			laneSearchBox.setText(decoded);
		}
		if(Window.Location.getParameter("g") != null || Window.Location.getParameter("l") != null)
			searchPanel.setVisible(false);
		
		initWidget(mainPanel);
		searchButton.addClickHandler(new ClickHandler(){

			public void onClick(ClickEvent event)
			{
				if(searchPanel.getWidgetCount() > 1)
					searchPanel.remove(1);
				String encodedGlobal = "";
				String encodedLane = "";
				for(char c : laneSearchBox.getText().toCharArray())
					encodedLane += (int) c > 99 ? String.valueOf((int) c) : "0" + String.valueOf((int) c) ;
				for(char c : globalSearchBox.getText().toCharArray())
					encodedGlobal += (int) c > 99 ? String.valueOf((int) c) : "0" + String.valueOf((int) c) ;
				
				String url = "http://webapp.epigenome.usc.edu/gareports/gareports.html?" + "g=" + encodedGlobal + "&l=" + encodedLane;
				searchPanel.add(new HTML("share these search results: <a href='" + url + "'>" + url + "</a>"));
				
				vp.clear();
				vp.add(new Image("images/progress.gif"));
				showTool();				
			}});
	}
	
	public FlowcellReport()
	{
		reportType = ReportType.ShowAll;
		searchOptionsPanel.add(globalSearchBox);
		searchOptionsPanel.add(searchButton);
		mainPanel.add(searchOptionsPanel);
		mainPanel.add(vp);
		vp.add(new Image("images/progress.gif"));
		initWidget(mainPanel);	
		searchButton.addClickHandler(new ClickHandler(){

			public void onClick(ClickEvent event)
			{
				vp.clear();
				vp.add(new Image("images/progress.gif"));
				showTool();					
			}});
	}
	
	//class FlowcellSubreport

	@Override
	public Image getToolLogo()
	{
		return new Image("images/report.jpg");
	}

	@Override
	public Label getToolTitle()
	{
		String labelString = "All Flowcells";
		switch(reportType)
		{
			case ShowGeneus: labelString="Flowcells from Geneus";break;
			case ShowFS: labelString="Flowcells from Disk";break;
			case ShowIncomplete: labelString="Incomplete Flowcells";break;
			case ShowComplete: labelString="Complete Flowcells";break;
			default: labelString="All Flowcells";break;		
		}
		
		return new Label(labelString);
	}

	@Override
	public void showTool()
	{		
		AsyncCallback<ArrayList<FlowcellData>> DisplayFlowcellCallback = new AsyncCallback<ArrayList<FlowcellData>>()
		{
			public void onFailure(Throwable caught)
			{
				vp.clear();
				vp.add(new Label(caught.getMessage()));
				caught.printStackTrace();				
			}

			public void onSuccess(ArrayList<FlowcellData> result)
			{
				vp.clear();
				for(FlowcellData flowcell : result)
					if(flowcell.flowcellContains(globalSearchBox.getText()))
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
			case ShowFS: remoteService.getFlowcellsFromFS(DisplayFlowcellCallback);break;
			case ShowIncomplete: remoteService.getFlowcellsIncomplete(DisplayFlowcellCallback);break;
			case ShowComplete: remoteService.getFlowcellsComplete(DisplayFlowcellCallback);break;
			default: remoteService.getFlowcellsAll(DisplayFlowcellCallback);break;			
		}		
	}
	
}
