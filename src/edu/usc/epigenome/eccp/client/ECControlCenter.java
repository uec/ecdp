package edu.usc.epigenome.eccp.client;
import edu.usc.epigenome.eccp.client.controlPanel.ControlPanelWidget;
import edu.usc.epigenome.eccp.client.pane.ECPane;
import edu.usc.epigenome.eccp.client.pane.PBS.PBSreport;
import edu.usc.epigenome.eccp.client.pane.analysisReport.AnalysisReport;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.FlowcellReport;
import edu.usc.epigenome.eccp.client.pane.systemStatus.StatusSummary;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.RootPanel;



/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class ECControlCenter implements EntryPoint
{
	DecoratedTabPanel mainTabPanel = new DecoratedTabPanel();
	ControlPanelWidget cp = new ControlPanelWidget();
	HorizontalPanel mainPanel = new HorizontalPanel();
	
	public void onModuleLoad()
	{
		mainPanel.setVerticalAlignment(HasVerticalAlignment.ALIGN_TOP);
		mainPanel.add(cp);
		mainPanel.add(mainTabPanel);
		mainTabPanel.setAnimationEnabled(true);
				
		//add flowcell reports
		addToControlPanel(new FlowcellReport(FlowcellReport.ReportType.ShowAll),"Flowcell Reports");
		addToControlPanel(new FlowcellReport(FlowcellReport.ReportType.ShowGeneus),"Flowcell Reports");
		addToControlPanel(new FlowcellReport(FlowcellReport.ReportType.ShowFS),"Flowcell Reports");
		addToControlPanel(new FlowcellReport(FlowcellReport.ReportType.ShowIncomplete),"Flowcell Reports");
		addToControlPanel(new FlowcellReport(FlowcellReport.ReportType.ShowComplete),"Flowcell Reports");
		
		//add analysis reports
		addToControlPanel(new AnalysisReport(AnalysisReport.ReportType.ShowFS),"Analysis Reports");
		
		//add pbs reports
		addToControlPanel(new PBSreport("all"),"HPCC PBS");
		addToControlPanel(new PBSreport("laird"),"HPCC PBS");
		addToControlPanel(new PBSreport("lairdprio"),"HPCC PBS");
		
		//add system reports
		addToControlPanel(new StatusSummary(),"System Status");
		
		RootPanel.get().add(mainPanel);		
	}
	private void addToControlPanel(ECPane p, String header)
	{		
		cp.addPane(p, header,mainTabPanel);
	}
}
