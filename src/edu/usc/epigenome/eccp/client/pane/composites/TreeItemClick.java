package edu.usc.epigenome.eccp.client.pane.composites;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.dom.client.HasClickHandlers;
import com.google.gwt.event.shared.HandlerRegistration;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;

public class TreeItemClick extends Composite implements ClickHandler, HasClickHandlers {

	private static TreeItemClickUiBinder uiBinder = GWT
			.create(TreeItemClickUiBinder.class);

	interface TreeItemClickUiBinder extends UiBinder<Widget, TreeItemClick> {
	}
	
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);

	String lib;
	String serial;
	@UiField VerticalPanel toClick;
	//@UiField Label addText;
	@UiField FlexTable addData;
	
	public TreeItemClick() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	public TreeItemClick(String Libname, final String library, String Serialname, final String fcellSerial)
	{
		lib = library;
		serial = fcellSerial;
		initWidget(uiBinder.createAndBindUi(this));
		addData.setText(0,0,  Libname + ": " + lib);
		addData.setText(0, 1, Serialname + ": " + serial);
		//addText.setText("Flowcell: " + serial);
		this.addClickHandler(this);
	}

	public void onClick(ClickEvent event) 
	{}

	@Override
	public HandlerRegistration addClickHandler(ClickHandler handler) 
	{
		return addDomHandler(handler, ClickEvent.getType());
	}

}

