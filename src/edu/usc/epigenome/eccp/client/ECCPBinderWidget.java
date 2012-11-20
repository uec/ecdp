package edu.usc.epigenome.eccp.client;

//import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.ResizeEvent;
import com.google.gwt.event.logical.shared.ResizeHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.Window;
//import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.core.client.util.Margins;
//import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.container.BorderLayoutContainer;
//import com.sencha.gxt.widget.core.client.container.BorderLayoutContainer.BorderLayoutData;
import com.sencha.gxt.widget.core.client.container.MarginData;
import com.sencha.gxt.widget.core.client.container.SimpleContainer;
import com.sencha.gxt.widget.core.client.info.Info;

import edu.usc.epigenome.eccp.client.sampleList.sampleList;
import edu.usc.epigenome.eccp.client.tab.TabbedReport;
import edu.usc.epigenome.eccp.client.tab.TabbedReportTest;


public class ECCPBinderWidget extends BorderLayoutContainer{

	//private static ECCPBinderWidgetUiBinder uiBinder = GWT.create(ECCPBinderWidgetUiBinder.class);

	interface ECCPBinderWidgetUiBinder extends	UiBinder<Widget, ECCPBinderWidget> {}
	
	
	
	@UiField BorderLayoutContainer  main;
	SimpleContainer west;
	SimpleContainer center;
	sampleList sample;


	public ECCPBinderWidget() 
	{
		
	//	initWidget(uiBinder.createAndBindUi(this));
		monitorWindowResize = true;
	    Window.enableScrolling(false);
	    setPixelSize(Window.getClientWidth(), Window.getClientHeight());
	    
		BorderLayoutData westData = new BorderLayoutData(600);
		westData.setMaxSize(1000);
	    westData.setMargins(new Margins(5, 0, 5, 5));
	    
	    westData.setSplit(true);
	    westData.setCollapsible(true);
	    westData.setCollapseHidden(true);
	    westData.setCollapseMini(true);
    
	    west = new SimpleContainer();
	    center = new SimpleContainer();
	    west.addResizeHandler(new ResizeHandler() {

			@Override
			public void onResize(ResizeEvent event) {
				 west.forceLayout();			
			}	
	    });
	    center.addResizeHandler(new ResizeHandler() {

			@Override
			public void onResize(ResizeEvent event) {
				 center.forceLayout();			
			}	
	    });
	    
	    west.setBorders(true);
	//    west.setPixelSize(500, 500);
	    setWestWidget(west,westData);
	    sample = new sampleList();
	    west.add(sample);
	  //  BorderLayoutData centerData = new BorderLayoutData();

	    MarginData centerData = new MarginData();
	    centerData.setMargins(new Margins(5));
	    center.add(new TabbedReport());
	//    center.add(new TabbedReportTest());
	    setCenterWidget(center,centerData);
	    

	}
	@Override
	  protected void onWindowResize(int width, int height) {
	    setPixelSize(width, height);
	  }
}