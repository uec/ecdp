package edu.usc.epigenome.eccp.client.pane.flowcellReport.chart;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer.ChartType;

public class ChartBrowser extends Composite {

	private static ChartBrowserUiBinder uiBinder = GWT
			.create(ChartBrowserUiBinder.class);

	interface ChartBrowserUiBinder extends UiBinder<Widget, ChartBrowser> {
	}

	ArrayList<LinkedHashMap<String, String>> fileList;
	@UiField FlowPanel addCharts;
	
	public ChartBrowser() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	public ChartBrowser(ArrayList<LinkedHashMap<String, String>> fileListIn)
	{
		fileList = fileListIn;
		initWidget(uiBinder.createAndBindUi(this));
		
		fileList = sortBy("base");
		addCharts();
		
	}
	
	public void addCharts()
	{
		for(int n=0; n<fileList.size(); n++)
		{
			LinkedHashMap<String, String> f = fileList.get(n);
			String fileURI = f.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCP/retrieve.jsp?resource=" + f.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + f.get("dir") + "/" + f.get("base");
			addCharts.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
			if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
				addCharts.add(new ChartViewer(f.get("fullpath"), ChartType.Area));
			else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
				addCharts.add(new ChartViewer(f.get("fullpath"), ChartType.Column));
		}
	}
	
	public ArrayList<LinkedHashMap<String,String>> sortBy(final String key)
	{
		final ArrayList<LinkedHashMap<String,String>> sortedFiles = (ArrayList<LinkedHashMap<String, String>>) fileList.clone();
		Collections.sort(sortedFiles, new Comparator<LinkedHashMap<String, String>>()
		{
			public int compare(LinkedHashMap<String, String> o1, LinkedHashMap<String, String> o2)
			{
				return o1.get(key).compareTo(o2.get(key));
			}
		});
		return sortedFiles;
	}
}
