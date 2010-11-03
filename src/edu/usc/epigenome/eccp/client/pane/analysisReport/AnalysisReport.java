package edu.usc.epigenome.eccp.client.pane.analysisReport;

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


public class AnalysisReport extends ECPane
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
	
	public AnalysisReport(ReportType reportTypein)
	{
		searchPanel.add(searchOptionsPanel);
		searchPanel.addStyleName("flowcellsearch");
		searchOptionsPanel.add(new Label("Analysis Properties: "));
		searchOptionsPanel.add(globalSearchBox);
		//searchOptionsPanel.add(new Label("Lane Properties: "));
		//searchOptionsPanel.add(laneSearchBox);
		searchOptionsPanel.add(searchButton);
		searchOptionsPanel.addStyleName("flowcellsearch");
		mainPanel.add(searchPanel);
		mainPanel.add(vp);
		reportType = reportTypein;
		vp.add(new Image("images/progress.gif"));
		if(Window.Location.getParameter("a") != null)
		{
			String decoded = "";
			for(int i=0;i<Window.Location.getParameter("a").length();i+=3)
				decoded += (char)Integer.parseInt(Window.Location.getParameter("a").substring(i,i+3));
			globalSearchBox.setText(decoded);
		}
		if(Window.Location.getParameter("l") != null)
		{
			String decoded = "";
			for(int i=0;i<Window.Location.getParameter("l").length();i+=3)
				decoded += (char)Integer.parseInt(Window.Location.getParameter("l").substring(i,i+3));
			laneSearchBox.setText(decoded);
		}
		if(Window.Location.getParameter("a") != null || Window.Location.getParameter("l") != null)
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
				
				String url = "http://webapp.epigenome.usc.edu/gareports/Gareports.html?" + "r=solan&a=" + encodedGlobal + "&l=" + encodedLane;
				searchPanel.add(new HTML("share these search results: <a href='" + url + "'>" + url + "</a>"));
				
				vp.clear();
				vp.add(new Image("images/progress.gif"));
				showTool();				
			}});
	}
	
	public AnalysisReport()
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
		String labelString = "Analysis from disk";
		switch(reportType)
		{
			case ShowGeneus: labelString="Merged Analysis";break;
			case ShowFS: labelString="Merged Analysis";break;
			
			default: labelString="All Analysis ";break;		
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
							AnalysisSingleItem flowcellItem = new AnalysisSingleItem(flowcell);
							vp.add(flowcellItem);
						}
			}
		};	
		
		switch(reportType)
		{
			//case ShowGeneus: remoteService.getFlowcellsFromGeneus(DisplayFlowcellCallback);break;
			case ShowFS: remoteService.getAnalysisFromFS(DisplayFlowcellCallback);break;
			//case ShowIncomplete: remoteService.getFlowcellsIncomplete(DisplayFlowcellCallback);break;
			//case ShowComplete: remoteService.getFlowcellsComplete(DisplayFlowcellCallback);break;
			default: remoteService.getAnalysisFromFS(DisplayFlowcellCallback);break;			
		}		
	}
}
