package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.TreeMap;


import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.ui.Composite;

import com.google.gwt.user.client.ui.AbstractImagePrototype;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.KeyboardListener;
import com.google.gwt.user.client.ui.KeyboardListenerAdapter;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.MenuBar;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.TreeImages;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Tree;
import com.google.gwt.user.client.ui.TreeItem;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer.ChartType;

@SuppressWarnings("deprecation")
public class FileBrowser extends Composite
{
	VerticalPanel vp = new VerticalPanel();
	VerticalPanel filePanel = new VerticalPanel();
	HorizontalPanel menu_items = new HorizontalPanel();
	MenuBar mainbar = new MenuBar();
	Button searchbutton = new Button("Search");
	
	ArrayList<LinkedHashMap<String,String>> flowcellFileList;
	
	public FileBrowser(ArrayList<LinkedHashMap<String,String>> fileListIn)
	{
		flowcellFileList = fileListIn;
		for(int k=0; k< flowcellFileList.size(); k++)
		{
			LinkedHashMap<String,String> set_type = flowcellFileList.get(k);
			set_type.put("type", getNiceType(set_type.get("base")));
		}
		
		MenuBar organize_dropdown = new MenuBar(true);	
		
		HorizontalPanel searchpanel = new HorizontalPanel();
		searchpanel.addStyleName("displayfilehorizontal");
		final TextBox searchbox = new TextBox();
		
		searchpanel.add(new Label(" Enter Text:"));
		searchpanel.add(searchbox);
		searchpanel.add(searchbutton);
		
		organize_dropdown.addItem("File Location", new Command()
		{
			public void execute()
			{
				organizeBy("label");
				searchbox.setValue("");
			}
		});
		
		organize_dropdown.addItem("File Lane", new Command()
		{
			public void execute()
			{
				organizeBy("lane");
			}
		});
		
		organize_dropdown.addItem("File Type", new Command()
		{
			public void execute()
			{
				organizeBy("type");
			}
		});
		
		menu_items.addStyleName("displayfilemenu");
		mainbar.addItem("Organize By", organize_dropdown);
		menu_items.add(mainbar);
		menu_items.add(searchpanel);
		vp.add(menu_items);
		vp.add(filePanel);
		organizeBy("type");
		initWidget(vp);
		
		/*
		 * The search button functionality goes here
		 * Search the arraylist for the text entered in the search box and if present
		 * a flextable consisting of all the matched results is returned.
		 * Else nothing is displayed
		 */
		searchbutton.addClickHandler(new ClickHandler(){

			public void onClick(ClickEvent event)
			{
				
				FlexTable searchFlexTable = new FlexTable();
				searchFlexTable.addStyleName("filelist");
				
				
				String text = searchbox.getText().trim().toLowerCase();
				text = text.replaceAll("\\s+","");
				System.out.println("The contents entered are " + text);
				
				ArrayList<LinkedHashMap<String, String>> hm =  new ArrayList<LinkedHashMap<String, String>>();
				for(int j=0;j<flowcellFileList.size();j++)
				{
					LinkedHashMap<String,String> flow = flowcellFileList.get(j);		
					
					if(flowcellFileList.get(j).get("base").toLowerCase().contains(text) || flowcellFileList.get(j).get("label").toLowerCase().contains(text) || flowcellFileList.get(j).get("type").toLowerCase().replaceAll("\\s+","").contains(text))
					{
						hm.add(flow);
					}
					//System.out.println("The size of arraylist is " + hm.size());
				}
					if(hm.size()>0)
					{
						for(int j=0;j<hm.size();j++)
						{
							LinkedHashMap<String, String> flow = hm.get(j);
							searchFlexTable.setText(0, 0, "File Name");
							searchFlexTable.setText(0, 1, "File Type");
							searchFlexTable.setText(0, 2, "File Location");
							  
							HorizontalPanel chartPanel = new HorizontalPanel();
							filePanel.clear();
							String fileURI = flow.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCP/retrieve.jsp?resource=" +flow.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + flow.get("dir") + "/" + flow.get("base");
						
							chartPanel.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + flow.get("base") + "</a>"));
							if(flow.get("base").contains("ResultCount") && flow.get("base").contains(".csv"))
								chartPanel.add(new ChartViewer(flow.get("fullpath"), ChartType.ResultCount));
							else if(flow.get("base").contains("ReadCount") && flow.get("base").contains(".csv"))
								chartPanel.add(new ChartViewer(flow.get("fullpath"), ChartType.Area));
							else if(flow.get("base").contains("nmerCount") && flow.get("base").contains(".csv"))
								chartPanel.add(new ChartViewer(flow.get("fullpath"), ChartType.Column));
							searchFlexTable.setWidget(j+1, 0, chartPanel);
							searchFlexTable.setText(j+1, 1, getNiceType(flow.get("base")));
							searchFlexTable.setText(j+1, 2, flow.get("label"));	
							
					}
						searchbox.setValue("");
				}
					else if(hm.size()<=0)
					{
					//	System.out.println("IN THE ELSE CONDITION FOR SEARCH");
						searchbox.setValue("");
						filePanel.clear();
					}
					filePanel.add(searchFlexTable);
			}});
		
			SubmitListener s1 = new SubmitListener();
			searchbox.addKeyboardListener(s1);
			
	}
			
	
	public void organizeBy(String orgby) 
	{	
	  	//System.out.println("The string passed is " + orgby);
		//System.out.println("The sorted list by location is" +  sortBy(orgby));
		
		//get the Arraylist sorted by the selection made 
		ArrayList<LinkedHashMap<String,String>> sortedFiles = sortBy(orgby);
		filePanel.clear();
		
		//Set the TreeNode image
		TreeImages images = (TreeImages)GWT.create(MyTreeImages.class);
		TreeItem addinfo = null;
		Tree t = new Tree(images);
		
		//System.out.println("The size of the sorted list is " + sortedFiles.size());
		TreeMap<String, ArrayList<LinkedHashMap<String, String>>> hm = new TreeMap<String, ArrayList<LinkedHashMap<String, String>>>();
		for(int i=0; i < sortedFiles.size(); i++)
		{
			LinkedHashMap<String,String> f = sortedFiles.get(i);			
			if(hm.containsKey(f.get(orgby)))
			{
				ArrayList<LinkedHashMap<String, String>> valret = (ArrayList<LinkedHashMap<String, String>>)hm.get(f.get(orgby));
				valret.add(f);
				hm.put(f.get(orgby), valret);
			}
			else
			{
				ArrayList<LinkedHashMap<String, String>> putval = new ArrayList<LinkedHashMap<String, String>>();
				putval.add(f);
				hm.put(f.get(orgby), putval);
			}
		}
			//System.out.println("The size of hashmap is " + hm.size());
			
			//Get an Iterator over the keys of the hashmap and create the tree structure
			Iterator<String> j = hm.keySet().iterator();
			while(j.hasNext())
			{
				String nodename = j.next().toString();
				addinfo= new TreeItem(nodename);
				ArrayList<LinkedHashMap<String, String>> nodevalue = hm.get(nodename);
				
				//System.out.println("The name of current node is " + nodename);
				
				//Create FlexTable to display the data of each treenode
				FlexTable displaytable = new FlexTable();
				displaytable.addStyleName("filelist");
				//Label bfilename = new Label("File Name");
				displaytable.setText(0, 0, "File Name");
				displaytable.setText(0, 1, "File Type");
				displaytable.setText(0, 2, "File Location");
				
				//Iterate over the arraylist for the particular nodevalue
				for(int n=0;n<nodevalue.size();n++)
				{
					LinkedHashMap<String, String> f = nodevalue.get(n);
					HorizontalPanel chartLaunchPanel = new HorizontalPanel();
					chartLaunchPanel.addStyleName("deshorizontalpanel");
					String fileURI = f.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCP/retrieve.jsp?resource=" + f.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + f.get("dir") + "/" + f.get("base");
					
					chartLaunchPanel.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
					if(f.get("base").contains("ResultCount") && f.get("base").contains(".csv"))
						chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.ResultCount));
					else if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
						chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.Area));
					else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
						chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.Column));
				
					displaytable.setWidget(n+1, 0, chartLaunchPanel);
					displaytable.setText(n+1, 1, getNiceType(f.get("base")));
					displaytable.setText(n+1, 2, f.get("label"));
					
				}
				//System.out.println("The arraylist for " + nodename + " is " + nodevalue);
				//add the flextable to the treenode
				addinfo.addItem(displaytable);
				//add the treenode to the tree
				t.addItem(addinfo);
			}
			//finally add the tree to the filepanel
			filePanel.add(t);			
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
	
	public void onClick(ClickEvent event)
	{
		
	}
	
	public String getNiceType(String ext)
	{
		String ret = "Unknown Type";
		if(ext.contains(".htm")) return "Web report";
		if(ext.contains(".wig")) return "Wiggle Track";
		if(ext.contains(".tdf")) return "IGV track";
		if(ext.contains(".bam")) return "Bam Alignment";
		if(ext.contains(".tdf")) return "IGV Track";
		if(ext.contains(".map")) return "Maq Alignment";
		if(ext.contains(".csv")) return "CSV Table";
		if(ext.contains(".srf")) return "Sequence Archive";
		if(ext.contains("eland")) return "Eland Alignment";
		if(ext.contains("export")) return "Export Alignment";
		if(ext.contains(".txt")) return "Fastq sequence";
		if(ext.contains(".peaks")) return "FindPeaks output";
		if(ext.contains(".map") && ext.contains("aligntest")) return "Align Contam Test";
		
		return ret;
	}
	
	//Interface to add images to the tree structure
	public interface MyTreeImages extends TreeImages{
		
		 @Resource("downArrow.png")
		    AbstractImagePrototype treeOpen();
		    
		    @Resource("rightArrow.png")
		    AbstractImagePrototype treeClosed();

	}
	
	/*
	 * Class to handle the click of ENTER Key for submitting any search item
	 */
	private class SubmitListener extends KeyboardListenerAdapter {
	    public void onKeyPress(Widget sender, char key, int mods) {
	      if (KeyboardListener.KEY_ENTER == key)
	    	  searchbutton.click();
	    }
	}
}


