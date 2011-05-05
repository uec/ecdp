package edu.usc.epigenome.eccp.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.pane.ECPane;


public class ECCPBinderWidget extends Composite {

	private static ECCPBinderWidgetUiBinder uiBinder = GWT
			.create(ECCPBinderWidgetUiBinder.class);

	interface ECCPBinderWidgetUiBinder extends
			UiBinder<Widget, ECCPBinderWidget> {
	}
	
	@UiField 
	public static VerticalPanel addTabPanel;
	static DecoratedTabPanel toolTabPanel = new DecoratedTabPanel();
	
	
	public ECCPBinderWidget() 
	{
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	//@UiField
	//public static TabLayoutPanel toolTabPanel;
	/*@UiField
	public  static HTMLPanel controlAdd;
	
	
	public static  TabLayoutPanel getToolTabPanel() {
		return toolTabPanel;
	}

	public void setToolTabPanel(TabLayoutPanel toolTabPanel) {
		this.toolTabPanel = toolTabPanel;
	}

	public void setControlAdd(HTMLPanel controlAdd) {
		this.controlAdd = controlAdd;
	}

	public static  HTMLPanel getControlAdd() {
		return controlAdd;
	}*/
	
	public static void addReport(final ECPane toolWidget, FocusPanel fpanel, final String typeGe)
	{
		fpanel.addClickHandler(new ClickHandler() {
		
			public void onClick(ClickEvent event) 
			{
				//if(toolTabPanel.)
				
					toolTabPanel.add(toolWidget, typeGe);
					toolWidget.showTool();
					
					toolTabPanel.selectTab(toolTabPanel.getWidgetIndex(toolWidget));
					addTabPanel.add(toolTabPanel);
			}
		});
	}
	
	/*public static void addReport(ECPane toolWidget, String typeGe)
	{
		if(toolTabPanel.getWidgetIndex(toolWidget) < 0)
		{
			toolTabPanel.add(toolWidget, typeGe);
			controlAdd.add(toolWidget);
		}
		toolTabPanel.selectTab(toolTabPanel.getWidgetIndex(toolWidget));
	}*/
}