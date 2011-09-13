package edu.usc.epigenome.eccp.client.pane.sampleReport;

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
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECCPBinderWidget;
import edu.usc.epigenome.eccp.client.ECControlCenter;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.GenUserBinderWidget;
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.pane.ECPane;


public class SampleReport extends ECPane{

	private static SampleReportUiBinder uiBinder = GWT
			.create(SampleReportUiBinder.class);

	interface SampleReportUiBinder extends UiBinder<Widget, SampleReport> {
	}
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	@UiField FlowPanel mainPanel;
	@UiField FlowPanel searchPanel;
	@UiField HorizontalPanel searchOptionsPanel;
	@UiField FlowPanel vp;
	@UiField TextBox sampleSearchBox;
	@UiField Button searchButton;
	String searchText ="";
	String fText ="";
	
	public SampleReport() {
		initWidget(uiBinder.createAndBindUi(this));
		
		vp.add(new Image("images/progress.gif"));
		
		if(Window.Location.getParameter("t") != null)
		{
			searchText = Window.Location.getParameter("t");
			fText = Window.Location.getParameter("q");
			searchPanel.setVisible(false);
		}
		
		searchButton.addClickHandler(new ClickHandler() 
		{	
			public void onClick(ClickEvent event) 
			{
				if(searchPanel.getWidgetCount() > 1){
					searchPanel.clear();
					searchPanel.add(searchOptionsPanel);
				}
				if(ECControlCenter.getUserType().equals("super"))
					ECCPBinderWidget.clearaddTabPanel();
				else if(ECControlCenter.getUserType().equals("guest"))
					GenUserBinderWidget.clearaddTabPanel();
				
				AsyncCallback<ArrayList<String>> encrypstring = new AsyncCallback<ArrayList<String>>()
				{
					public void onSuccess(ArrayList<String> result) 
					{
						String url = "http://webapp.epigenome.usc.edu/ECCPBinder/ECControlCenter.html?"+"au=sol" + "&t=" + result.get(0) + "&q=" + result.get(1);
						searchPanel.add(new HTML("share these search results: <a href='" + url + "'>" + url  + "</a>"));
					}
					public void onFailure(Throwable caught) 
					{
						caught.printStackTrace();
					}
				};
				remoteService.getEncryptedData(sampleSearchBox.getText(), "", encrypstring);
				
				vp.clear();
				vp.add(new Image("images/progress.gif"));
				showTool();
			}});
	}

	@Override
	public void showTool() 
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
					if(sampl.sampleContains(sampleSearchBox.getText()))
					{
						SampleTreeView flowcellItem = new SampleTreeView(sampl);
						//SampleSingleReport flowcellItem = new SampleSingleReport(sampl);
						vp.add(flowcellItem);
					}
				}
			}
	    };remoteService.getSampleFromGeneus(DisplayFlowcellCallback);
		
	}
	
	public void decryptKeys()
	{
		AsyncCallback<ArrayList<String>> GotPlainText = new AsyncCallback<ArrayList<String>>() {

			public void onFailure(Throwable caught) 
			{
				caught.printStackTrace();
			}

			public void onSuccess(ArrayList<String> result) 
			{	
				//Window.alert("result is blank for " + result.get(0));
				if(result.get(0).equals("") || result.get(0).contentEquals(""))
				{
					//Window.alert("result is the blank section " + result.get(0));
				}
				else{
					//Window.alert("result is " + result.get(0));
					sampleSearchBox.setText(result.get(0));
				}
			}
		};
		remoteService.decryptKeyword(searchText, fText, GotPlainText);
	}

	@Override
	public Image getToolLogo() {
		
		return null;
	}

	@Override
	public Label getToolTitle() {
		
		return null;
	}

	

}
