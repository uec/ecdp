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
import com.sencha.gxt.widget.core.client.TabItemConfig;
import com.sencha.gxt.widget.core.client.TabPanel;

import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.pane.ECPane;
import edu.usc.epigenome.eccp.client.pane.sampleReport.SampleReport;


public class ECCPBinderWidget extends Composite {

	private static ECCPBinderWidgetUiBinder uiBinder = GWT
			.create(ECCPBinderWidgetUiBinder.class);

	interface ECCPBinderWidgetUiBinder extends
			UiBinder<Widget, ECCPBinderWidget> {
	}
	
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}
	
	@UiField public static VerticalPanel addTabPanel;
	@UiField static HTMLPanel FcellReport;
	@UiField static HTMLPanel layoutReport;
	@UiField static Label label;
	//static DecoratedTabPanel toolTabPanel = new DecoratedTabPanel();
	static DecoratedTabPanel tabQCDownload = new DecoratedTabPanel();
	static TabPanel tabPanel = new TabPanel();

	public ECCPBinderWidget() 
	{
		initWidget(uiBinder.createAndBindUi(this));
		label.setText("Switch to Sample View");
		label.addClickHandler(new ClickHandler() 
		{
		  public void onClick(ClickEvent arg0) 
		  {
			 if(label.getText().contains("Flowcell"))
			 {
			   addTabPanel.clear();
			   layoutReport.clear();
			   layoutReport.add(label);
			   layoutReport.add(FcellReport);
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
	
	/*
	 * static method to clear the tabPanel (to add tabs)
	 */
	public static void clearaddTabPanel()
	{
		addTabPanel.clear();
	}
	
	/*
	 * For the Flowcell View
	 * Function to add different reports to the tab
	 * Input: the Widget to be added, focus panel and the String to be represented on the Tab
	 */
	public static void addReport(final ECPane toolWidget, FocusPanel fpanel, final String typeGe)
	{
		fpanel.addClickHandler(new ClickHandler() 
		{
			public void onClick(ClickEvent event) 
			{
				layoutReport.add(toolWidget);
				toolWidget.showTool();
			}});
	}
	
	public static void addTab(VerticalPanel vp, String displayName) {
		TabItemConfig item = new TabItemConfig();
		item.setClosable(true);
		item.setText(displayName);
		tabPanel.add(vp,item);
		tabPanel.setActiveWidget(tabPanel.getWidget(tabPanel.getWidgetCount() - 1));
		addTabPanel.add(tabPanel);
	}
	
	
	
	
	
	
	/*
	 * Function to add tabs based on the selection made on the left hand side of the panel 
	 *Input: Takes the panel to be added and the displayName for the tab
	 */
	public static void addtoTab(final VerticalPanel fp, String displayName)
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
		tabQCDownload.selectTab(tabQCDownload.getWidgetIndex(fp));
		addTabPanel.add(tabQCDownload);
		
		/*
		 * Tabbed Browsing 
		 * Logic to navigate tabs while closing them 
		 * Click handler on the click of the 'x' mark (image) on the Tab
		 */
		image.addClickHandler(new ClickHandler()
		{
			public void onClick(ClickEvent arg0) 
			{
				int tabsCount = tabQCDownload.getWidgetCount();
				int curIndex = tabQCDownload.getWidgetIndex(fp);
				
				if(curIndex == 0 && tabsCount > 0)
				{
					tabQCDownload.selectTab(curIndex +1);
					tabQCDownload.remove(curIndex);
				}
				else if(curIndex == tabsCount-1)
				{
					tabQCDownload.selectTab(curIndex-1);
					tabQCDownload.remove(curIndex);
				}
				else if(curIndex > 0 && curIndex < tabsCount)
				{
					tabQCDownload.selectTab(curIndex + 1);
					tabQCDownload.remove(curIndex);
				}
				else 
				{
					tabQCDownload.remove(curIndex);
				}		
			}
		});
	}
}