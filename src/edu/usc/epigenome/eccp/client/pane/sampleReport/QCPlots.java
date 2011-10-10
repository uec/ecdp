package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.PopupPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECCPBinderWidget;
import edu.usc.epigenome.eccp.client.ECControlCenter;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.GenUserBinderWidget;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.chart.ChartViewer;
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
	String run;
	FlowcellData flowcell;
	
	@UiField Label showPlots;
	@UiField VerticalPanel popup;
	@UiField FlowPanel summaryChart;
	
	public QCPlots() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	/*
	 * Constructor for the QCPlots, remoteService call to the backend to get the files to plot charts
	 */
	public QCPlots(final FlowcellData flowcellIn, final String flowcellSerialIn, final int lane, final String runId, final String library, final String sampleID)
	{
		flowcell = flowcellIn;
		flowcellSerial = flowcellSerialIn;
		laneNo = lane;
		run = runId;
		initWidget(uiBinder.createAndBindUi(this));
		
		showPlots.addClickHandler(new ClickHandler() {
			
			public void onClick(ClickEvent arg0) 
			{
				//Check for the userType and accordingly add the tab to the tabPanel
				if(ECControlCenter.getUserType().equalsIgnoreCase("super"))
					ECCPBinderWidget.addtoTab(popup, "Plots" + library + "_" + flowcellSerial);
				else if(ECControlCenter.getUserType().equalsIgnoreCase("guest"))
					GenUserBinderWidget.addtoTab(popup, "Plots" + library + "_" + flowcellSerial);
				
				//Get files for the given run, flowcellSerial and sample
				remoteService.getCSVFiles(run, flowcellSerial, sampleID, new AsyncCallback<FlowcellData>() 
				{	
					public void onFailure(Throwable caught) 
					{
						summaryChart.clear();
						summaryChart.add(new Label(caught.getMessage()));
					}
					public void onSuccess(FlowcellData result) 
					{
						summaryChart.clear();
						summaryChart.add(new Label("Sample:" + library + " > Flowcell:" + flowcellSerial + " > Lane:"+ laneNo + " > Run:" + run));
						flowcell.fileList = result.fileList;
						//Filter the list of files received from the backend for the specific lane, sample and run
						flowcell.filterFiles(lane, sampleID, run);
						flowcell.fileList = sortBy("base");
						
						//Iterate over the list of files and add them to the summaryChart
						for(int n=0; n<flowcell.fileList.size(); n++)
						{
							LinkedHashMap<String, String> f = flowcell.fileList.get(n);
							String fileURI = f.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCPBinder/retrieve.jsp?resource=" + f.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + f.get("dir") + "/" + f.get("base");
							if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
							{
								summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.Area));
							}
							else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
							{
								summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.Column));
							}
							else if(f.get("base").contains("ResultCount") && f.get("base").contains(".csv"))
							{
								summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.ResultCount));
							}
						}
					}	
			});
		}});
	}
	
	public ArrayList<LinkedHashMap<String,String>> sortBy(final String key)
	{
		final ArrayList<LinkedHashMap<String,String>> sortedFiles = (ArrayList<LinkedHashMap<String, String>>) flowcell.fileList.clone();
		Collections.sort(sortedFiles, new Comparator<LinkedHashMap<String, String>>()
		{
			public int compare(LinkedHashMap<String, String> o1, LinkedHashMap<String, String> o2)
			{
				return o1.get(key).compareTo(o2.get(key));
			}
		});
		return sortedFiles;
	}
	
	
 /*	public QCPlots(final SampleData sampleIn, final String flowcellSerialIn, final int lane, final String runId)
	{
		flowcellSerial = flowcellSerialIn;
		sample = sampleIn;
		laneNo = lane;
		run = runId;
		initWidget(uiBinder.createAndBindUi(this));
		
		showPlots.addClickHandler(new ClickHandler() {
			
			public void onClick(ClickEvent arg0) 
			{
				
				if(ECControlCenter.getUserType().equalsIgnoreCase("super"))
					ECCPBinderWidget.addtoTab(popup, "Plots" + sample.getSampleProperty("library") + "_" + flowcellSerial);
				else if(ECControlCenter.getUserType().equalsIgnoreCase("guest"))
					GenUserBinderWidget.addtoTab(popup, "Plots" + sample.getSampleProperty("library") + "_" + flowcellSerial);
				
				remoteService.getCSVFiles(run, flowcellSerial, sample.getSampleProperty("geneusID_sample"), new AsyncCallback<FlowcellData>() 
				{	
					public void onFailure(Throwable caught) 
					{
						summaryChart.clear();
						summaryChart.add(new Label(caught.getMessage()));
					}
					public void onSuccess(FlowcellData result) 
					{
						summaryChart.clear();
						//path.setText("Sample:" + sample.getSampleProperty("library") + " > Flowcell:" + flowcellSerial + " > Lane:"+ laneNo + " > Run:" + run);
						summaryChart.add(new Label("Sample:" + sample.getSampleProperty("library") + " > Flowcell:" + flowcellSerial + " > Lane:"+ laneNo + " > Run:" + run));
						sample.sampleFlowcells.get(flowcellSerial).fileList = result.fileList;
						sample.sampleFlowcells.get(flowcellSerial).filterFiles(lane, sample.getSampleProperty("geneusID_sample"), run);
						sample.sampleFlowcells.get(flowcellSerial).fileList = sortBy("base");
						//ChartBrowser chBrowse = new ChartBrowser(sample.sampleFlowcells.get(flowcellSerial).fileList);
						//summaryChart.add(chBrowse);
						for(int n=0; n<sample.sampleFlowcells.get(flowcellSerial).fileList.size(); n++)
						{
							LinkedHashMap<String, String> f = sample.sampleFlowcells.get(flowcellSerial).fileList.get(n);
							String fileURI = f.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCPBinder/retrieve.jsp?resource=" + f.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + f.get("dir") + "/" + f.get("base");
							if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
							{
								summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.Area));
							}
							else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
							{
								summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.Column));
							}
							else if(f.get("base").contains("ResultCount") && f.get("base").contains(".csv"))
							{
								summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
								summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.ResultCount));
							}
						}
					}	
			});
		}});
	}*/
	
/*	public void showChart(final String csvPath,final ChartType t, final String fileURI, final String base)
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
	}*/
	

	
	
	/*for(int n=0; n<sample.flowcellFileList.size(); n++)
	{
		LinkedHashMap<String, String> f = sample.flowcellFileList.get(n);
		String fileURI = f.containsKey("encfullpath") ? "http://webapp.epigenome.usc.edu/ECCP/retrieve.jsp?resource=" + f.get("encfullpath") :  "http://www.epigenome.usc.edu/webmounts/" + f.get("dir") + "/" + f.get("base");
		summaryChart.add(new HTML("<a target=\"new\" href=\"" + fileURI + "\">" + f.get("base") + "</a>"));
		//String base = f.get("base");
	/*	if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
			showChart(f.get("fullpath"), ChartType.Area, fileURI, base);
		else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
			showChart(f.get("fullpath"), ChartType.Column, fileURI, base);*/
	/*	if(f.get("base").contains("ReadCount") && f.get("base").contains(".csv"))
			summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.Area));
		else if(f.get("base").contains("nmerCount") && f.get("base").contains(".csv"))
			summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.Column));
		else if(f.get("base").contains("ResultCount") && f.get("base").contains(".csv"))
		
			//summaryChart.add(new ChartViewer(f.get("fullpath"), ChartType.ResultCount));
		
	}*/
}
