package edu.usc.epigenome.eccp.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.HTMLPanel;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Panel;
import com.google.gwt.user.client.ui.StackLayoutPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.pane.ECPane;
import edu.usc.epigenome.eccp.client.pane.sampleReport.SampleReport;


public class ECCPBinderWidget extends Composite {

	private static ECCPBinderWidgetUiBinder uiBinder = GWT
			.create(ECCPBinderWidgetUiBinder.class);

	interface ECCPBinderWidgetUiBinder extends
			UiBinder<Widget, ECCPBinderWidget> {
	}
	
	@UiField public static VerticalPanel addTabPanel;
	@UiField static StackLayoutPanel mainStack;
	@UiField static HTMLPanel layoutReport;
	@UiField static Label label;
	static DecoratedTabPanel toolTabPanel = new DecoratedTabPanel();
	static DecoratedTabPanel tabQCDownload = new DecoratedTabPanel();
	
	public ECCPBinderWidget() 
	{
		initWidget(uiBinder.createAndBindUi(this));
		label.setText("Switch to Sample View");
		
		//Window.alert("the user " + ECControlCenter.getUserType());
		label.addClickHandler( new ClickHandler() 
		{	
			public void onClick(ClickEvent arg0) 
			{
				if(label.getText().contains("Flowcell"))
				{
					addTabPanel.clear();
					layoutReport.clear();
					layoutReport.add(label);
					layoutReport.add(mainStack);
					label.setText("Switch to Sample View");
				}
				else if(label.getText().contains("Sample"))
				{
					addTabPanel.clear();
					layoutReport.clear();
					SampleReport sp = new SampleReport();
					layoutReport.add(label);
					if(!sp.isAttached())
					{	
						layoutReport.add(sp);
						sp.showTool();
					}
					label.setText("Switch to Flowcell View");
				}	
			}
			});
	}
	
	public static void clearaddTabPanel()
	{
		addTabPanel.clear();
	}
	
	public static void addReport(final ECPane toolWidget, FocusPanel fpanel, final String typeGe)
	{
		fpanel.addClickHandler(new ClickHandler() {
		
			public void onClick(ClickEvent event) 
			{
				/*if(typeGe.contains("Samples From Geneus"))
				{
					addTabPanel.clear();
					mainStack.clear();
					label.setText("Switch to Flowcell View");
					if(!toolWidget.isAttached())
					{	
						layoutReport.add(toolWidget);
						toolWidget.showTool();
					}
				}	
				else
				{*/
					if(toolTabPanel.getWidgetIndex(toolWidget) < 0)
					{
						toolTabPanel.add(toolWidget, typeGe);
						toolWidget.showTool();
					}	
					toolTabPanel.selectTab(toolTabPanel.getWidgetIndex(toolWidget));
					addTabPanel.add(toolTabPanel);
				}
			//}
		});
	}
	
	public static void addtoTab(final FlowPanel fp, String displayName)
	{
		HorizontalPanel hp = new HorizontalPanel();
		Image image = new Image();
		Label label = new Label(displayName);
		hp.add(label);
		hp.add(image);
	
		image.setUrl("images/close_icon.gif");
		if(tabQCDownload.getWidgetIndex(fp) < 0)
		{
			tabQCDownload.add(fp, hp);
		}
		tabQCDownload.setTitle(displayName);
		tabQCDownload.selectTab(tabQCDownload.getWidgetIndex(fp));
		addTabPanel.add(tabQCDownload);
		
		/*
		 * Tabbed Browsing 
		 * Logic to navigate tabs while closing them
		 */
		image.addClickHandler(new ClickHandler()
		{
			public void onClick(ClickEvent arg0) 
			{
				int tabsCount = tabQCDownload.getWidgetCount();
				int curIndex = tabQCDownload.getWidgetIndex(fp);
				
				if(curIndex == 0 && tabsCount > 0)
				{
					//Window.alert("In case curIndex == 0 and tabsCount > 0");
					tabQCDownload.selectTab(curIndex +1);
					tabQCDownload.remove(curIndex);
				}
				else if(curIndex == tabsCount-1)
				{
				//	Window.alert("In case tabsCount -1");
					tabQCDownload.selectTab(curIndex-1);
					tabQCDownload.remove(curIndex);
				}
				else if(curIndex > 0 && curIndex < tabsCount)
				{
					//Window.alert("In case curIndex > 0 and tabsCount < curIndex");
					tabQCDownload.selectTab(curIndex + 1);
					tabQCDownload.remove(curIndex);
				}
				else 
				{
					//Window.alert("In case curIndex == 0");
					tabQCDownload.remove(curIndex);
				}		
			}
		});
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
}