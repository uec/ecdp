package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;


import com.google.gwt.event.dom.client.ClickEvent;

import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.ui.Composite;

import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.MenuBar;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer.ChartType;

public class FileBrowser extends Composite
{
	VerticalPanel vp = new VerticalPanel();
	VerticalPanel filePanel = new VerticalPanel();
	ArrayList<LinkedHashMap<String,String>> flowcellFileList;
	
	public FileBrowser(ArrayList<LinkedHashMap<String,String>> fileListIn)
	{
		flowcellFileList = fileListIn;
		MenuBar m = new MenuBar();
		m.addItem("Sort by location", new Command()
		{
			public void execute()
			{
				sortBy("label");
			}
		});
		m.addItem("Sort by type", new Command()
		{
			public void execute()
			{
				sortBy("type");
			}
		});
		m.addItem("Sort by name", new Command()
		{
			public void execute()
			{
				sortBy("base");
			}
		});
		m.addItem("Sort by lane", new Command()
		{
			public void execute()
			{
				sortBy("lane");
			}
		});
		
		vp.add(m);
		vp.add(filePanel);
		sortBy("type");
		initWidget(vp);
	}
	
	@SuppressWarnings("unchecked")
	public void sortBy(final String key)
	{
		final ArrayList<LinkedHashMap<String,String>> sortedFiles = (ArrayList<LinkedHashMap<String, String>>) flowcellFileList.clone();
		
		filePanel.clear();
		Collections.sort(sortedFiles, new Comparator<LinkedHashMap<String, String>>()
		{
			public int compare(LinkedHashMap<String, String> o1, LinkedHashMap<String, String> o2)
			{
				return o1.get(key).compareTo(o2.get(key));
			}
		});
				
		
		FlexTable filesFlexTable = new FlexTable();
		filesFlexTable.addStyleName("filelist");
		filesFlexTable.setText(0, 0, "File Name");
		filesFlexTable.setText(0, 1, "File Type");
		filesFlexTable.setText(0, 2, "File Location");
		
		for(int i=0; i < sortedFiles.size(); i++)
		{
			LinkedHashMap<String,String> f = sortedFiles.get(i);			
			HorizontalPanel chartLaunchPanel = new HorizontalPanel();
			String fileURI = f.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCP/retrieve.jsp?resource=" + f.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + f.get("dir") + "/" + f.get("base");
			
			chartLaunchPanel.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
			if(f.get("base").contains("ResultCount") && f.get("base").contains(".csv"))
				chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.ResultCount));
			else if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
				chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.Area));
			else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
				chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.Column));
			filesFlexTable.setWidget(i+1, 0, chartLaunchPanel);
			//filesFlexTable.setText(i+1, 1, f.get("type").substring(1 + f.get("type").indexOf("_")));
			filesFlexTable.setText(i+1, 1, getNiceType(f.get("base")));
			filesFlexTable.setText(i+1, 2, f.get("label"));			
		}
		
		filePanel.add(filesFlexTable);
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
	
}


