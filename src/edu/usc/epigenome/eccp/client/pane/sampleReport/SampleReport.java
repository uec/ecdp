package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.HashMap;

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
import edu.usc.epigenome.eccp.client.pane.ECPane;


public class SampleReport extends ECPane{

	private static SampleReportUiBinder uiBinder = GWT
			.create(SampleReportUiBinder.class);

	interface SampleReportUiBinder extends UiBinder<Widget, SampleReport> {
	}
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	@UiField FlowPanel searchPanel;
	@UiField HorizontalPanel searchOptionsPanel;
	@UiField FlowPanel vp;
	@UiField TextBox sampleSearchBox;
	@UiField Button searchButton;
	String searchText ="";
	//String fText ="";
	//variable yesSearch to determine if searchItem is entered
	boolean yesSearch = false;
	
	/*
	 * Constructor 
	 */
	public SampleReport() 
	{	
		initWidget(uiBinder.createAndBindUi(this));
		vp.add(new Image("images/progress.gif"));
		
		if(ECControlCenter.getUserType().equals("super"))
			ECCPBinderWidget.clearaddTabPanel();
		else if(ECControlCenter.getUserType().equals("guest"))
			GenUserBinderWidget.clearaddTabPanel();
		
		//Check if parameter t is not null and get the search contents
		if(Window.Location.getParameter("s") != null)
		{
			searchText = Window.Location.getParameter("s");
			searchPanel.setVisible(false);
		}
		
		//Click handler to handle clickEvent for searchButton
		searchButton.addClickHandler(new ClickHandler() 
		{	
			public void onClick(ClickEvent event) 
			{
				if(searchPanel.getWidgetCount() > 1){
					searchPanel.clear();
					searchPanel.add(searchOptionsPanel);
				}
				//Encrypt the text searched for and create a URL for the User
				AsyncCallback<ArrayList<String>> encrypstring = new AsyncCallback<ArrayList<String>>()
				{
					public void onSuccess(ArrayList<String> result) 
					{
						String url = "http://127.0.0.1:8888/ECControlCenter.html?gwt.codesvr=127.0.0.1:9997&"+"au=smp" + "&s=" + result.get(0);
						searchPanel.add(new HTML("share these search results: <a href='" + url + "'>" + url  + "</a>"));
					}
					public void onFailure(Throwable caught) 
					{
						caught.printStackTrace();
					}
				};
				remoteService.getEncryptedData(sampleSearchBox.getText(), encrypstring);
				
				vp.clear();
				vp.add(new Image("images/progress.gif"));
				//set yesSearch to true 
				yesSearch = true;
				showTool();
			}});
	}

	/*
	 * (non-Javadoc)
	 * @see edu.usc.epigenome.eccp.client.pane.ECPane#showTool()
	 * Function to get Projects.
	 * If yesSearch is false, then normal query to get list of all projects from the database
	 * If yesSearch is true, then mysql fullText query to get list of projects that match the searchItem 
	 * in sampleSearchBox
	 */
	@Override
	public void showTool()
	{
		AsyncCallback<ArrayList<String>> DisplayFlowcellCallback = new AsyncCallback<ArrayList<String>>()
	    {
			public void onFailure(Throwable caught)
			{
				vp.clear();	
				caught.printStackTrace();				
			}
			public void onSuccess(ArrayList<String> result)
			{
				vp.clear();
				for(String sampl : result)
				{
						SampleTreeView flowcellItem = new SampleTreeView(sampl, sampleSearchBox.getText(), yesSearch);
						vp.add(flowcellItem);
				}
			}
	    };remoteService.getProjectsFromGeneus(sampleSearchBox.getText(), yesSearch,DisplayFlowcellCallback);
	}
	
	/*
	 * Function specific to the Guest user.
	 * Function to decrypt the keys (from the URL) and perform search and get Projects meeting the specified searchItem
	 */
	public void decryptKeys()
	{
		remoteService.decryptSearchProject(searchText, new AsyncCallback<HashMap<String,ArrayList<String>>>() 
		{
			
			public void onFailure(Throwable caught)
			{
				vp.clear();
				caught.printStackTrace();
			}
		
			public void onSuccess(HashMap<String, ArrayList<String>> list) 
			{
				vp.clear();
				ArrayList<String> decryptContents = list.get("decrypted");
				ArrayList<String> projects = list.get("project");
				for(String proj : projects)
				{
				  SampleTreeView flowcellItem = new SampleTreeView(proj, decryptContents.get(0), true);
				  vp.add(flowcellItem);
				}
			}
		});
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
