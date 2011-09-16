package edu.usc.epigenome.eccp.client.controlPanel;

import java.util.ArrayList;
import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.Element;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.resources.client.ClientBundle;
import com.google.gwt.resources.client.ImageResource;
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
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TabLayoutPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECCPBinderWidget;
import edu.usc.epigenome.eccp.client.pane.PBS.PBSreport;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.FlowcellReport;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.FlowcellReport.ReportType;
import edu.usc.epigenome.eccp.client.pane.methylation.MethylationReport;
import edu.usc.epigenome.eccp.client.pane.methylation.MethylationSanityCheck;
import edu.usc.epigenome.eccp.client.pane.sampleReport.SampleReport;

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
	
	@UiConstructor
	public ControlPanelWidget(final String typeGeneus, final String typeGroup)
	{	
		initWidget(uiBinder.createAndBindUi(this));
		hp.setTitle(typeGeneus);
		hp.add(new HTML(typeGeneus));
			
		if(typeGroup.contains("ShowSamples"))
		{
			ECCPBinderWidget.addReport(new SampleReport(), fp, typeGeneus);
		}
		else if(typeGroup.contains("MethylationReports"))
		{
			ECCPBinderWidget.addReport(new MethylationReport(), fp, typeGeneus);
		}
		else if(typeGroup.contains("MethylationSanity"))
		{
			ECCPBinderWidget.addReport(new MethylationSanityCheck(), fp, typeGeneus);
		}
		else if(typeGroup.contains("PBS"))
		{
			ECCPBinderWidget.addReport(new PBSreport(typeGroup), fp, typeGeneus);
		}
		else
		{
			ECCPBinderWidget.addReport(new FlowcellReport(FlowcellReport.ReportType.valueOf(typeGroup)), fp, typeGeneus);
		}
	}	
}
