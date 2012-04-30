package edu.usc.epigenome.eccp.client.tab;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.widget.core.client.TabItemConfig;
import com.sencha.gxt.widget.core.client.TabPanel;
import com.sencha.gxt.widget.core.client.container.SimpleContainer;

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
		ECCPEventBus.EVENT_BUS.addHandler(LibrarySelectedEvent.TYPE, new LibrarySelectedEventHandler()     
		{
			@Override
			public void onLibrarySelected(LibrarySelectedEvent event)
			{
				LibraryData d = event.getLibrary();
			
				
				
				TabItemConfig config2 = new TabItemConfig();
				config2.setClosable(true);
				config2.setText("Files: " + d.get("sample_name").getValue());
				DownloadGridWidget download = new DownloadGridWidget(d.getFiles());
				HorizontalPanel p2 = new HorizontalPanel();
				tabPanel.add(p2,config2);
				p2.setWidth("100%");
				tabPanel.setActiveWidget(p2);
				p2.add(download);
				
				
				TabItemConfig config = new TabItemConfig();
				config.setClosable(true);
				config.setText("QC: " + d.get("sample_name").getValue());
				MetricGridWidget metric = new MetricGridWidget(new ArrayList<LibraryProperty>(d.values()));
				SimpleContainer p = new SimpleContainer();
				tabPanel.add(p,config);
				tabPanel.setActiveWidget(p);
				p.add(metric);
			}	        
	    });
	}

}
