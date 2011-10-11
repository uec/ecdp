package edu.usc.epigenome.eccp.client;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTMLPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.StackLayoutPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.pane.sampleReport.SampleReport;

public class GenUserBinderWidget extends Composite {

	private static GenUserBinderWidgetUiBinder uiBinder = GWT
			.create(GenUserBinderWidgetUiBinder.class);

	interface GenUserBinderWidgetUiBinder extends
			UiBinder<Widget, GenUserBinderWidget> {
	}

	@UiField public static VerticalPanel addTabPanel;
	@UiField static HTMLPanel layoutReport;
	//Declared DecoratedTabPanel in the code as it doesn't work with the ScrollPanel
	static DecoratedTabPanel tabQCDownload = new DecoratedTabPanel();
	
	/*
	 * Constructor  
	 * The guest user initialization and binding
	 */
	public GenUserBinderWidget() 
	{
		initWidget(uiBinder.createAndBindUi(this));
		SampleReport sp = new SampleReport();
		if(!sp.isAttached())
		{
			//Window.alert("the user " + ECControlCenter.getUserType());
			layoutReport.add(sp);
			sp.decryptKeys();
		}
	}

	/*
	 * static method to clear the tabPanel (to add tabs)
	 */
	public static void clearaddTabPanel()
	{
		addTabPanel.clear();
	}
	
	/*
	 * static method to add tabs to the tab panel
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
