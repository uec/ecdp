package edu.usc.epigenome.eccp.client.controlPanel;

import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiConstructor;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;
import edu.usc.epigenome.eccp.client.ECCPBinderWidget;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.FlowcellReport;


public class ControlPanelWidget extends Composite{

	private static ControlPanelWidgetUiBinder uiBinder = GWT
			.create(ControlPanelWidgetUiBinder.class);

	interface ControlPanelWidgetUiBinder extends
			UiBinder<Widget, ControlPanelWidget> {
	}

	public ControlPanelWidget()
	{
		initWidget(uiBinder.createAndBindUi(this));
	}
		
@UiField FocusPanel fp;
@UiField HorizontalPanel hp;

/*
 * Constructor to handle the Composite Widget added to ECCPBinderWidget
 */
	@UiConstructor
	public ControlPanelWidget(final String typeGeneus, final String typeGroup)
	{	
		initWidget(uiBinder.createAndBindUi(this));
		hp.setTitle(typeGeneus);
		hp.add(new HTML(typeGeneus));	
		ECCPBinderWidget.addReport(new FlowcellReport(FlowcellReport.ReportType.valueOf(typeGroup)), fp, typeGeneus);
	}	
}
