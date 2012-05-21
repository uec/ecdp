package edu.usc.epigenome.eccp.client.tab;
import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.widget.core.client.TabItemConfig;
import com.sencha.gxt.widget.core.client.TabPanel;
import edu.usc.epigenome.eccp.client.events.ECCPEventBus;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEvent;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEventHandler;

public class TabbedReport extends Composite 
{

	private static TabbedReportUiBinder uiBinder = GWT.create(TabbedReportUiBinder.class);

	interface TabbedReportUiBinder extends UiBinder<Widget, TabbedReport> 	{}
	
	@UiField TabPanel tabPanel;

	public TabbedReport()
	{
		initWidget(uiBinder.createAndBindUi(this));
		ECCPEventBus.EVENT_BUS.addHandler(ShowGlobalTabEvent.TYPE, new ShowGlobalTabEventHandler()     
		{
			@Override
			public void onShowWidgetInTab(ShowGlobalTabEvent event)
			{
				TabItemConfig config = new TabItemConfig();
				config.setClosable(true);
				config.setText(event.getTabTitle());
				HorizontalPanel p = new HorizontalPanel();
				tabPanel.add(p,config);
				tabPanel.setActiveWidget(p);
				p.add(event.getWidgetToShow());
			}	        
	    });
	}

}
