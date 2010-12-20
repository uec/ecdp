package edu.usc.epigenome.eccp.client.pane.methylation;

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
import edu.usc.epigenome.eccp.client.data.MethylationData;
import edu.usc.epigenome.eccp.client.pane.ECPane;


public class MethylationReport extends ECPane
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	final VerticalPanel mainPanel = new VerticalPanel();
	final VerticalPanel vp = new VerticalPanel();
	final HorizontalPanel searchOptionsPanel = new HorizontalPanel();
	final VerticalPanel searchPanel = new VerticalPanel();
	final TextBox globalSearchBox = new TextBox();
	final TextBox laneSearchBox = new TextBox();
	final Button searchButton = new Button("search");
	String laneText = null;
	String fcellText = null;
	
	public MethylationReport()
	{
		searchPanel.add(searchOptionsPanel);
		searchPanel.addStyleName("flowcellsearch");
		searchOptionsPanel.add(new Label("Bead Array Properties: "));
		searchOptionsPanel.add(globalSearchBox);
		searchOptionsPanel.add(new Label("Sample Properties: "));
		searchOptionsPanel.add(laneSearchBox);
		searchOptionsPanel.add(searchButton);
		searchOptionsPanel.addStyleName("flowcellsearch");
		mainPanel.add(searchPanel);
		mainPanel.add(vp);
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
		
		if(Window.Location.getParameter("t") != null)
			laneText = Window.Location.getParameter("t");
		
		if(Window.Location.getParameter("q") != null)
			fcellText = Window.Location.getParameter("q");
		
		if(Window.Location.getParameter("t") != null || Window.Location.getParameter("q") != null)
			searchPanel.setVisible(false);
		
		initWidget(mainPanel);
		searchButton.addClickHandler(new ClickHandler(){

			public void onClick(ClickEvent event)
			{
				if(searchPanel.getWidgetCount() > 1)
					searchPanel.remove(1);
				
				AsyncCallback<ArrayList<String>> encrypstring = new AsyncCallback<ArrayList<String>>(){

					@Override
					public void onFailure(Throwable caught)
					{
						caught.printStackTrace();
					}

					@Override
					public void onSuccess(ArrayList<String> result) 
					{
						String url = "http://webapp.epigenome.usc.edu/gareports/Gareports.html?"+"au=meth" + "&t=" + result.get(1) + "&q=" + result.get(0);
						searchPanel.add(new HTML("share these search results: <a href='" + url + "'>" + url + "</a>"));
						searchPanel.setWidth("720px");
					}
				};
 	 			remoteService.getEncryptedData(globalSearchBox.getText(), laneSearchBox.getText(), encrypstring);
 	 			
				vp.clear();
				vp.add(new Image("images/progress.gif"));
				showTool();				
			}});
	}
	
	@Override
	public Image getToolLogo()
	{
		return new Image("images/report.jpg");
	}

	@Override
	public Label getToolTitle()
	{
		String labelString = "Infinium Methylation 27K";
		return new Label(labelString);
	}

	@Override
	public void showTool()
	{		
		AsyncCallback<ArrayList<MethylationData>> DisplayFlowcellCallback = new AsyncCallback<ArrayList<MethylationData>>()
		{
			public void onFailure(Throwable caught)
			{
				vp.clear();
				vp.add(new Label(caught.getMessage()));
				caught.printStackTrace();				
			}

			public void onSuccess(ArrayList<MethylationData> result)
			{
				vp.clear();
				for(MethylationData flowcell : result)
					if(flowcell.flowcellContains(globalSearchBox.getText()))
						if(flowcell.filterLanesThatContain(laneSearchBox.getText()))
						{
							MethtylationReportSingleItem flowcellItem = new MethtylationReportSingleItem(flowcell);
							vp.add(flowcellItem);
						}
			}
		};	
		
		remoteService.getMethFromGeneus(DisplayFlowcellCallback);	
				
	}
	
	public void decryptKeys()
	{
		AsyncCallback<ArrayList<String>> GotPlainText = new AsyncCallback<ArrayList<String>>() {

			@Override
			public void onFailure(Throwable caught) {
				caught.printStackTrace();
			}

			@Override
			public void onSuccess(ArrayList<String> result) {	
				globalSearchBox.setText(result.get(0));
				laneSearchBox.setText(result.get(1));
			}
		};
		remoteService.decryptKeyword(fcellText, laneText, GotPlainText);
	}

}
