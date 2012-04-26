package edu.usc.epigenome.eccp.client.tab;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.widget.core.client.TabPanel;
import com.sencha.gxt.widget.core.client.button.TextButton;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryProperty;
import edu.usc.epigenome.eccp.client.events.ECCPEventBus;
import edu.usc.epigenome.eccp.client.events.LibrarySelectedEvent;
import edu.usc.epigenome.eccp.client.events.LibrarySelectedEventHandler;
import edu.usc.epigenome.eccp.client.pane.sampleReport.DownloadGridWidget;
import edu.usc.epigenome.eccp.client.pane.sampleReport.MetricGridWidget;

public class TabbedReport extends Composite 
{

	private static TabbedReportUiBinder uiBinder = GWT.create(TabbedReportUiBinder.class);

	interface TabbedReportUiBinder extends UiBinder<Widget, TabbedReport> 	{}
	
	@UiField TabPanel tabPanel;

	public TabbedReport()
	{
		initWidget(uiBinder.createAndBindUi(this));
		tabPanel.add(new TextButton("blah"), "text1");
		tabPanel.add(new TextButton("blah2"), "text2");
		ECCPEventBus.EVENT_BUS.addHandler(LibrarySelectedEvent.TYPE, new LibrarySelectedEventHandler()     
		{
					@Override
			public void onLibrarySelected(LibrarySelectedEvent event)
			{
				LibraryData d = event.getLibrary();
				MetricGridWidget metric = new MetricGridWidget(new ArrayList<LibraryProperty>(d.values()));
				tabPanel.add(metric,"metric");
				
				DownloadGridWidget fileDL = new DownloadGridWidget(d.getFiles());
				tabPanel.add(fileDL,"files");
			}	        
	    });
	}

}
