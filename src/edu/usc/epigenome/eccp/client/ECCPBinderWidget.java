package edu.usc.epigenome.eccp.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.HTMLPanel;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.pane.ECPane;



public class ECCPBinderWidget extends Composite {

	private static ECCPBinderWidgetUiBinder uiBinder = GWT.create(ECCPBinderWidgetUiBinder.class);

	interface ECCPBinderWidgetUiBinder extends	UiBinder<Widget, ECCPBinderWidget> {}
	
	static {   UserPanelResources.INSTANCE.userPanel().ensureInjected();}
	
	
	@UiField static HTMLPanel layoutReport;
	
	

	public ECCPBinderWidget() 
	{
		initWidget(uiBinder.createAndBindUi(this));
	}
}