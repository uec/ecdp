package edu.usc.epigenome.eccp.client;
import edu.usc.epigenome.eccp.client.controlPanel.ControlPanelWidget;
import edu.usc.epigenome.eccp.client.pane.ECPane;
import edu.usc.epigenome.eccp.client.pane.PBS.PBSreport;
import edu.usc.epigenome.eccp.client.pane.analysisReport.AnalysisReport;
import edu.usc.epigenome.eccp.client.pane.cacheManagement.CacheManager;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.FlowcellReport;
import edu.usc.epigenome.eccp.client.pane.methylation.MethylationReport;
import edu.usc.epigenome.eccp.client.pane.methylation.MethylationSanityCheck;
import edu.usc.epigenome.eccp.client.pane.systemStatus.StatusSummary;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.RootLayoutPanel;
import com.google.gwt.user.client.ui.RootPanel;



/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class ECControlCenter implements EntryPoint
{
ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	/**
	 * This is the entry point method.
	 */
	public void onModuleLoad() 
	{
		ECCPBinderWidget sbw = new ECCPBinderWidget();
	    RootLayoutPanel.get().add(sbw);
	}
}
