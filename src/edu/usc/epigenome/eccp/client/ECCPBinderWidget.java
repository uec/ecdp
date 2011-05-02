package edu.usc.epigenome.eccp.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Widget;

public class ECCPBinderWidget extends Composite {

	private static ECCPBinderWidgetUiBinder uiBinder = GWT
			.create(ECCPBinderWidgetUiBinder.class);

	interface ECCPBinderWidgetUiBinder extends
			UiBinder<Widget, ECCPBinderWidget> {
	}

	//@UiField Label ShowGeneus;
	//@UiField HTMLPanel controlAdd;
	
	public ECCPBinderWidget() 
	{
		initWidget(uiBinder.createAndBindUi(this));
	}
	
}
