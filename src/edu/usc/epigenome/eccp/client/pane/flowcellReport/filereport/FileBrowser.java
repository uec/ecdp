package edu.usc.epigenome.eccp.client.pane.flowcellReport.filereport;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.TreeMap;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.KeyboardListener;
import com.google.gwt.user.client.ui.KeyboardListenerAdapter;
import com.google.gwt.user.client.ui.MenuBar;
import com.google.gwt.user.client.ui.MenuItem;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;

public class FileBrowser extends Composite {

	private static FileBrowserUiBinder uiBinder = GWT
			.create(FileBrowserUiBinder.class);

	interface FileBrowserUiBinder extends UiBinder<Widget, FileBrowser> {
	}
	
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}

	@UiField FlowPanel vp;
	@UiField HorizontalPanel menu_items;
	@UiField MenuBar mainbar;
	@UiField MenuItem locationSort;
	@UiField MenuItem laneSort;
	@UiField MenuItem typeSort;
	@UiField TextBox searchbox;
	@UiField Button searchbutton;
	@UiField FlowPanel filePanel;
	@UiField FlowPanel fileGroups;
	
	public FileBrowser() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	ArrayList<LinkedHashMap<String,String>> flowcellFileList;
	
	public FileBrowser(ArrayList<LinkedHashMap<String,String>> fileListIn)
	{
		flowcellFileList = fileListIn;
		initWidget(uiBinder.createAndBindUi(this));
		
		//for(LinkedHashMap<String,String> set_type : flowcellFileList)
			//set_type.put("type", FileTable.getNiceType(set_type.get("base")));
		
		locationSort.setCommand(new Command()
		{	
			public void execute() 
			{
				organizeBy("label");
				searchbox.setValue("");
			}
		});
		
		laneSort.setCommand(new Command()
		{	
			public void execute() 
			{
				organizeBy("lane");
			}
		});
		
		typeSort.setCommand(new Command()
		{
			public void execute() 
			{
				organizeBy("type");
			}
		});
		
		
		searchbox.addClickHandler(new ClickHandler() {
			
			public void onClick(ClickEvent event) {
				// TODO Auto-generated method stub
				searchbox.setValue("");
			}
		});
		
		organizeBy("type");
		
		/*
		 * The search button functionality goes here
		 * Search the arraylist for the text entered in the search box and if present
		 * a flextable consisting of all the matched results is returned.
		 * Else nothing is displayed
		 */
		searchbutton.addClickHandler(new ClickHandler(){
			public void onClick(ClickEvent event)
			{
				filePanel.clear();
				fileGroups.clear();
				String[] text = searchbox.getText().trim().toLowerCase().split("\\s");
				ArrayList<LinkedHashMap<String, String>> searchHits =  new ArrayList<LinkedHashMap<String, String>>();
				for(LinkedHashMap<String,String> flow : flowcellFileList)
				{	
					//SHOULD THIS BE AND/OR?
					Boolean found = false;
					for(String subsearch : text)
						if(flow.get("base").toLowerCase().contains(subsearch) || flow.get("label").toLowerCase().contains(subsearch) || flow.get("type").toLowerCase().contains(subsearch))
							found = found || true;
					if(found)
						searchHits.add(flow);
				}

				if(searchHits.size()>0)
					filePanel.add(new FileTable("Search Results",searchHits));
			}});	
		
		SubmitListener listenEnterClick = new SubmitListener();
		searchbox.addKeyboardListener(listenEnterClick);
	}
	
	public void organizeBy(String orgby) 
	{	
		ArrayList<LinkedHashMap<String,String>> sortedFiles = flowcellFileList;
		//remove duplicates from the ArrayList
		HashSet<LinkedHashMap<String, String>> noDups = new HashSet<LinkedHashMap<String, String>>(sortedFiles);
		sortedFiles.clear();
		sortedFiles.addAll(noDups);
		//get the Arraylist sorted by the selection made
		sortedFiles= sortBy(orgby);
		//ArrayList<LinkedHashMap<String,String>> sortedFiles = sortBy(orgby);
		filePanel.clear();
		//Set the TreeNode image
		fileGroups.clear();
		TreeMap<String, ArrayList<LinkedHashMap<String, String>>> organizedFiles = new TreeMap<String, ArrayList<LinkedHashMap<String, String>>>();
		for(int i=0; i < sortedFiles.size(); i++)
		{
			LinkedHashMap<String,String> f = sortedFiles.get(i);			
			if(organizedFiles.containsKey(f.get(orgby)))
			{
				ArrayList<LinkedHashMap<String, String>> valret = (ArrayList<LinkedHashMap<String, String>>)organizedFiles.get(f.get(orgby));
				valret.add(f);
				organizedFiles.put(f.get(orgby), valret);
			}
			else
			{
				ArrayList<LinkedHashMap<String, String>> putval = new ArrayList<LinkedHashMap<String, String>>();
				putval.add(f);
				organizedFiles.put(f.get(orgby), putval);
			}
		}
			for(String organizedByThis : organizedFiles.keySet())
			{
				fileGroups.add(new FileTable(organizedByThis, organizedFiles.get(organizedByThis)));
				
			}
	}
	
	//Function to sort the arraylist by the option selected 
	@SuppressWarnings("unchecked")
	public ArrayList<LinkedHashMap<String,String>> sortBy(final String key)
	{
		final ArrayList<LinkedHashMap<String,String>> sortedFiles = (ArrayList<LinkedHashMap<String, String>>) flowcellFileList.clone();
		Collections.sort(sortedFiles, new Comparator<LinkedHashMap<String, String>>()
		{
			public int compare(LinkedHashMap<String, String> o1, LinkedHashMap<String, String> o2)
			{
				return o1.get(key).compareTo(o2.get(key));
			}
		});
		return sortedFiles;
	}
	
	@SuppressWarnings("deprecation")
	private class SubmitListener extends KeyboardListenerAdapter {
	    public void onKeyPress(Widget sender, char key, int mods) {
	      if (KeyboardListener.KEY_ENTER == key)
	       searchbutton.click();
	    }
	  }
	
}
