package edu.usc.epigenome.eccp.client.tab;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;

import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;

import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.widget.core.client.ContentPanel;

import com.sencha.gxt.widget.core.client.TabItemConfig;
import com.sencha.gxt.widget.core.client.TabPanel;
import com.sencha.gxt.widget.core.client.container.HasLayout;

import com.sencha.gxt.widget.core.client.container.Viewport;

import edu.usc.epigenome.eccp.client.events.ECCPEventBus;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEvent;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEventHandler;



public class TabbedReport extends Composite implements HasLayout
{

	private static TabbedReportUiBinder uiBinder = GWT.create(TabbedReportUiBinder.class);

	interface TabbedReportUiBinder extends UiBinder<Widget, TabbedReport> 	{}
	
	@UiField TabPanel tabPanel;

	public TabbedReport()
	{
		initWidget(uiBinder.createAndBindUi(this));
		//showHelp();
		 		
		// A handler to resize the tab content on tab selection event		
		SelectionHandler<Widget> handler = new SelectionHandler<Widget>() {
		      @Override
		      public void onSelection(SelectionEvent<Widget> event) {
		        HasLayout w = (HasLayout)event.getSelectedItem();
		        w.forceLayout();
		        tabPanel.forceLayout();
		      }			
		    };
		    
		tabPanel.addSelectionHandler(handler);
		tabPanel.setTabScroll(true);
		//setAnnounceTab();

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
	
	// Adds ECCPHelp tab with a "Help pages" link to online help
	public void showHelp() {
		
				TabItemConfig config = new TabItemConfig();
				Viewport vp = new Viewport();
			//	HTML help = new HTML("<a target=\"new\" href=\"http://wiki.epigenome.usc.edu/twiki/bin/view/Main/ScreenShots\"> Help</a>");
				Label help = new Label("Help pages");
				vp.add(help);
				config.setText("ECCP Help");
				tabPanel.add(vp, config);
			
				 ClickHandler ch = new ClickHandler() {
				 
					@Override
					public void onClick(ClickEvent event) {
						String winName = "Test Window";
				        String url = "http://wiki.epigenome.usc.edu/twiki/bin/view/Main/ScreenShots";
						openNewWindow (winName, url);						
					}				
				    };
				help.addClickHandler(ch);			
		
	}
	
	// Opens a new browser window (hopefully not a pop-up) with a specified URL. 
	public  void openNewWindow(String name, String url) {
	    Window.open(url, name.replace(" ", "_"),
	           "menubar=no," + 
	           "location=false," + 
	           "resizable=yes," + 
	           "scrollbars=yes," + 
	           "status=no," + 
	           "dependent=true");
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
    
	public void setAnnounceTab() {
		TabItemConfig config = new TabItemConfig();
		config.setText("Announcements");
		config.setClosable(true);
		ContentPanel c = new ContentPanel();
		Image im = new Image("images/workshop_ad.png");
		c.add(im);
		c.setResize(false);
		Viewport v = new Viewport();
		v.add(c);
		tabPanel.add(v, config);
		
	}

	

}
