package edu.usc.epigenome.eccp.client.tab;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
//import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.widget.core.client.TabItemConfig;
import com.sencha.gxt.widget.core.client.TabPanel;
import com.sencha.gxt.widget.core.client.container.HasLayout;

import edu.usc.epigenome.eccp.client.events.ECCPEventBus;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEvent;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEventHandler;
import edu.usc.epigenome.eccp.client.pane.sampleReport.MetricGridWidget;

public class TabbedReport extends Composite implements HasLayout
{

	private static TabbedReportUiBinder uiBinder = GWT.create(TabbedReportUiBinder.class);

	interface TabbedReportUiBinder extends UiBinder<Widget, TabbedReport> 	{}
	
	@UiField TabPanel tabPanel;

	public TabbedReport()
	{
		initWidget(uiBinder.createAndBindUi(this));
		// This handler handles tab content resize on a tab click
		SelectionHandler<Widget> handler = new SelectionHandler<Widget>() {
		      @Override
		      public void onSelection(SelectionEvent<Widget> event) {
		        MetricGridWidget w = (MetricGridWidget)event.getSelectedItem();
		        w.forceLayout();
		      }
			
		    };
		tabPanel.addSelectionHandler(handler);
		ECCPEventBus.EVENT_BUS.addHandler(ShowGlobalTabEvent.TYPE, new ShowGlobalTabEventHandler()  
		
		{
			@Override
			public void onShowWidgetInTab(ShowGlobalTabEvent event)
			{
				TabItemConfig config = new TabItemConfig();
				config.setClosable(true);
				config.setText(event.getTabTitle());
				tabPanel.add(event.getWidgetToShow(),config);
				tabPanel.setActiveWidget(event.getWidgetToShow()); 
//ZR removed to allow full window width fill								
//				HorizontalPanel p = new HorizontalPanel();
//				tabPanel.add(p,config);
//				tabPanel.setActiveWidget(p);
//				p.add(event.getWidgetToShow());
			}	        
	    });
	}

	@Override
	public void forceLayout() {
		tabPanel.forceLayout();
		
	}

	@Override
	public boolean isLayoutRunning() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean isOrWasLayoutRunning() {
		// TODO Auto-generated method stub
		return false;
	}


}
