package edu.usc.epigenome.eccp.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.core.client.util.Margins;
import com.sencha.gxt.widget.core.client.container.BorderLayoutContainer;
import com.sencha.gxt.widget.core.client.container.BorderLayoutContainer.BorderLayoutData;
import com.sencha.gxt.widget.core.client.container.MarginData;
import com.sencha.gxt.widget.core.client.container.SimpleContainer;

import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.sampleList.sampleList;
import edu.usc.epigenome.eccp.client.tab.TabbedReport;


public class ECCPBinderWidget extends Composite {

	private static ECCPBinderWidgetUiBinder uiBinder = GWT.create(ECCPBinderWidgetUiBinder.class);

	interface ECCPBinderWidgetUiBinder extends	UiBinder<Widget, ECCPBinderWidget> {}
	
	static {   UserPanelResources.INSTANCE.userPanel().ensureInjected();}
	
	@UiField BorderLayoutContainer  main;

	public ECCPBinderWidget() 
	{
		
		initWidget(uiBinder.createAndBindUi(this));
		BorderLayoutData westData = new BorderLayoutData(600);
		westData.setMaxSize(1000);
	    westData.setMargins(new Margins(5, 0, 5, 5));
	    westData.setSplit(true);
	    westData.setCollapsible(true);
	    SimpleContainer west = new SimpleContainer();
	    main.setWestWidget(west,westData);
	    west.add(new sampleList());
	    
	    BorderLayoutData centerData = new BorderLayoutData();
	    centerData.setSplit(true);
	    centerData.setMargins(new Margins(5, 0, 5, 5));
	    
	   
	    SimpleContainer center = new SimpleContainer();
	    //center.setHeight(800);
	    //center.add(new TabbedReport());
	    main.setCenterWidget(new TabbedReport(),centerData);
	    
	    
	    
	}
}