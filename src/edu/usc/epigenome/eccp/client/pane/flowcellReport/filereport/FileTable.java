package edu.usc.epigenome.eccp.client.pane.flowcellReport.filereport;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer.ChartType;

public class FileTable extends Composite {

	private static FileTableUiBinder uiBinder = GWT
			.create(FileTableUiBinder.class);

	interface FileTableUiBinder extends UiBinder<Widget, FileTable> {
	}

	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}
	
	ArrayList<LinkedHashMap<String, String>> files;
	
	public FileTable() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	@UiField FlowPanel main;
	@UiField HorizontalPanel header;
	@UiField Label headerText;
	@UiField Image headerIcon;
	@UiField Label contentCountText;
	@UiField FlexTable contentTable;
	
	FileTable(String headerIn, ArrayList<LinkedHashMap<String, String>> filesIn)
	{
		files = filesIn;
		
		initWidget(uiBinder.createAndBindUi(this));
		
		//headerIcon = new Image("images/rightArrow.png");
		headerText.setText(headerIn);
		contentCountText.setText(" (" + files.size() + " items)");
		
		contentTable.setVisible(false);
		if(headerIn.contains("Search Res"))
		{
			headerIcon.setUrl("images/downArrow.png");
			drawTable();
			contentTable.setVisible(true);
		}
		
		ClickHandler expand = new ClickHandler(){
			public void onClick(ClickEvent event)
			{
				drawTable();
				if(contentTable.isVisible() == false)
				{
					contentTable.setVisible(true);
					headerIcon.setUrl("images/downArrow.png");
				}
				else
				{
					contentTable.setVisible(false);
					headerIcon.setUrl("images/rightArrow.png");
				}
			}};
			
		headerText.addClickHandler(expand);
		headerIcon.addClickHandler(expand);	
	}
	
	public void drawTable()
	{
		contentTable.clear();
		//contentTable.addStyleName("filelist");
		Label fileNameLabel = new Label("File Name");
		fileNameLabel.addClickHandler(new ClickHandler(){
			public void onClick(ClickEvent event)
			{
				sortBy("base");
			}});
		Label fileTypeLabel = new Label("File Type");
		fileTypeLabel.addClickHandler(new ClickHandler(){
			public void onClick(ClickEvent event)
			{
				sortBy("type");
			}});
		Label fileLocationLabel = new Label("File Location");
		fileLocationLabel.addClickHandler(new ClickHandler(){
			public void onClick(ClickEvent event)
			{
				sortBy("label");
			}});
		
		contentTable.setWidget(0, 0, fileNameLabel);
		contentTable.setWidget(0, 1, fileTypeLabel);
		contentTable.setWidget(0, 2, fileLocationLabel);

		//Iterate over the arraylist for the particular nodevalue
		for(int n=0; n<files.size(); n++)
		{
			LinkedHashMap<String, String> f = files.get(n);
			HorizontalPanel chartLaunchPanel = new HorizontalPanel();
			String fileURI = f.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCPBinder/retrieve.jsp?resource=" + f.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + f.get("dir") + "/" + f.get("base");
			
			chartLaunchPanel.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
			if(f.get("base").contains("ResultCount") && f.get("base").contains(".csv"))
				chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.ResultCount));
			else if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
				chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.Area));
			else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
				chartLaunchPanel.add(new ChartViewer(f.get("fullpath"), ChartType.Column));
			contentTable.setWidget(n+1, 0, chartLaunchPanel);
			contentTable.setText(n+1, 1, f.get("type"));
			contentTable.setText(n+1, 2, f.get("label"));			
		}	
	}
	
	public void sortBy(final String key)
	{
		Collections.sort(files, new Comparator<LinkedHashMap<String, String>>()
		{
			public int compare(LinkedHashMap<String, String> o1, LinkedHashMap<String, String> o2)
			{
				return o1.get(key).compareTo(o2.get(key));
			}
		});
		drawTable();
	}
	
	public static String getNiceType(String ext)
	{
		String ret = "Unknown Type";
		if(ext.contains(".htm")) return "Web report";
		if(ext.contains(".wig")) return "Wiggle Track";
		if(ext.contains(".tdf")) return "IGV track";
		if(ext.endsWith(".bam") || ext.endsWith(".bai")) return "Bam Alignment";
		if(ext.contains(".tdf")) return "IGV Track";
		if(ext.contains(".map")) return "Maq Alignment";
		if(ext.contains(".csv")) return "CSV Table";
		if(ext.contains(".srf")) return "Sequence Archive";
		if(ext.contains("eland")) return "Eland Alignment";
		if(ext.contains("export")) return "Export Alignment";
		if(ext.contains(".txt") && ext.contains("sequence")) return "Fastq sequence";
		if(ext.contains(".peaks")) return "FindPeaks output";
		if(ext.contains(".map") && ext.contains("aligntest")) return "Align Contam Test";
		
		return ret;
	}
}
