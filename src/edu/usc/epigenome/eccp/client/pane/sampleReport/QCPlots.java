package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECCPBinderWidget;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.AreaChartViewer;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ColumnChartViewer;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.MotionChartViewer;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer.ChartType;

public class QCPlots extends Composite {

	private static QCPlotsUiBinder uiBinder = GWT.create(QCPlotsUiBinder.class);

	interface QCPlotsUiBinder extends UiBinder<Widget, QCPlots> {
	}
	
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	String flowcellSerial;
	int laneNo;
	SampleData sample;
	
	@UiField Label showPlots;
	@UiField FlowPanel popup;
	@UiField FlowPanel summaryChart;
	@UiField FlowPanel mainPanel;
	
	public QCPlots() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	public QCPlots(final SampleData sampleIn, final String flowcellSerialIn, final int lane)
	{
		flowcellSerial = flowcellSerialIn;
		sample = sampleIn;
		laneNo = lane;
		initWidget(uiBinder.createAndBindUi(this));
		
		showPlots.addClickHandler(new ClickHandler() {
			
			public void onClick(ClickEvent arg0) 
			{
				
				ECCPBinderWidget.addtoTab(popup, "Plots" + sample.getSampleProperty("library") + " " + flowcellSerial + " " + lane);
				summaryChart.clear();
				summaryChart.add(new Image("images/progress.gif"));
				
				remoteService.getCSVFiles(flowcellSerial, new AsyncCallback<SampleData>() 
				{	
					public void onFailure(Throwable caught) 
					{
						summaryChart.clear();
						summaryChart.add(new Label(caught.getMessage()));
					}
					public void onSuccess(SampleData result) 
					{
						summaryChart.clear();
						sample.flowcellFileList = result.flowcellFileList;
						sample.filterFiles(lane);
						sortBy("base");
						
						
						for(int n=0; n<sample.flowcellFileList.size(); n++)
						{
							LinkedHashMap<String, String> f = sample.flowcellFileList.get(n);
							//Window.alert("size of file list is " + f);
							//chartLaunchPanel.addStyleName("deshorizontalpanel");
							String fileURI = f.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCP/retrieve.jsp?resource=" + f.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + f.get("dir") + "/" + f.get("base");
							summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
							String base = f.get("base");
							//summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
							/*if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
								showChart(f.get("fullpath"), ChartType.Area, fileURI, base);
							else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
								showChart(f.get("fullpath"), ChartType.Column, fileURI, base);*/
							if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.Area));
							else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.Column));
							else if(f.get("base").contains("ResultCount") && f.get("base").contains(".csv"))
							{
								//summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.ResultCount));
							}
						}
					}	
			});
		}});
	}
	
	public void showChart(final String csvPath,final ChartType t, final String fileURI, final String base)
	{
		remoteService.getCSVFromDisk(csvPath, new AsyncCallback<String>()
		{
				public void onFailure(Throwable caught)
				{
					summaryChart.clear();
					summaryChart.add(new Label ("Error loading data!"));
				}
				public void onSuccess(String result)
				{
					if(t == ChartType.Area)
						summaryChart.add(new AreaChartViewer(result));
					else if(t == ChartType.Column)
						summaryChart.add(new ColumnChartViewer(result));
					
					summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + base + "</a>"));
				}
			});	
	}
	
	public void sortBy(final String key)
	{
		Collections.sort(sample.flowcellFileList, new Comparator<LinkedHashMap<String, String>>()
		{
			public int compare(LinkedHashMap<String, String> o1, LinkedHashMap<String, String> o2)
			{
				return o1.get(key).compareTo(o2.get(key));
			}
		});
	}
}
