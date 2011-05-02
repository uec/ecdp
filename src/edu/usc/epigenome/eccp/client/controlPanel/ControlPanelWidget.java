package edu.usc.epigenome.eccp.client.controlPanel;

import java.util.ArrayList;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Element;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiConstructor;
import com.google.gwt.uibinder.client.UiFactory;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.History;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.ClickListener;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HTMLPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TabLayoutPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.pane.flowcellReport.FlowcellReport;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.FlowcellReport.ReportType;

public class ControlPanelWidget extends Composite{

	private static ControlPanelWidgetUiBinder uiBinder = GWT
			.create(ControlPanelWidgetUiBinder.class);

	interface ControlPanelWidgetUiBinder extends
			UiBinder<Widget, ControlPanelWidget> {
	}
	
	@UiField HTMLPanel controlAdd;
	@UiField Label ShowGeneus;
	public String initToken = History.getToken();
	
	public ControlPanelWidget()
	{
		initWidget(uiBinder.createAndBindUi(this));
		
		ShowGeneus.addClickHandler(new ClickHandler() {
			
			public void onClick(ClickEvent event) {
				//Window.alert(ShowGeneus.getText());
				//FcellReport.clear();
				//controlAdd.clear();
				controlAdd.add(new FlowcellReport(FlowcellReport.ReportType.ShowGeneus));
				
			}
		});
	}

	
	/*@UiConstructor
	public ControlPanelWidget(final String typeGeneus, final String typeGroup)
	{
		FocusPanel fp = new FocusPanel();
		initWidget(uiBinder.createAndBindUi(this));
		fp.setTitle(typeGeneus);
		fp.add(new HTML(typeGeneus));
		fp.addClickHandler(new ClickHandler() {
			
			@Override
			public void onClick(ClickEvent event) 
			{
				Window.alert(typeGeneus);
				Window.alert(typeGroup);
			}
		});
	}*/
}
