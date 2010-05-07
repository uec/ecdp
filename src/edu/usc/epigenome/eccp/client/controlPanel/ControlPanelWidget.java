package edu.usc.epigenome.eccp.client.controlPanel;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;

import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FocusPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.StackLayoutPanel;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.pane.ECPane;

import java.util.HashMap;

public class ControlPanelWidget extends Composite 
{
    StackLayoutPanel toolBox = new StackLayoutPanel(Unit.EM);
    DisclosurePanel mainDropdown = new DisclosurePanel("Tools");
    HashMap<String,VerticalPanel> headers = new HashMap<String,VerticalPanel>();
        
	public ControlPanelWidget() 
    {
        // Place the check above the text box using a vertical panel.
		toolBox.addStyleName("toolbox");
		DOM.setElementAttribute(mainDropdown.getElement(),"id","controlpanel");
		mainDropdown.setAnimationEnabled(true);
		mainDropdown.add(toolBox);
		
        mainDropdown.addOpenHandler(new OpenHandler<DisclosurePanel>(){

			public void onOpen(OpenEvent<DisclosurePanel> event)
			{
				toolBox.setHeight("500px");
				toolBox.setWidth("200px");				
			}        	
        });
        mainDropdown.setOpen(true);
        // All composites must call initWidget() in their constructors.
        initWidget(mainDropdown);
    }
    public void addPane(final ECPane toolWidget, final String toolGroupName, final DecoratedTabPanel toolTabPanel)
    {
		FocusPanel fp = new FocusPanel();
    	HorizontalPanel hp = new HorizontalPanel();
		hp.setWidth("200px");
		hp.add(toolWidget.getToolLogo());
		hp.add(toolWidget.getToolTitle());
		fp.add(hp);
		fp.addClickHandler(new ClickHandler()
		{
			public void onClick(ClickEvent event)
			{			
				if(toolTabPanel.getWidgetIndex(toolWidget) < 0)
				{
					toolTabPanel.add(toolWidget, toolWidget.getToolTitle());
					toolWidget.showTool();
				}
				toolTabPanel.selectTab(toolTabPanel.getWidgetIndex(toolWidget));
			}
		});
		
    	if(!(headers.containsKey(toolGroupName)))
    	{
    				
    		headers.put(toolGroupName, new VerticalPanel());
    		headers.get(toolGroupName).add(fp);
    		toolBox.add(headers.get(toolGroupName), new HTML(toolGroupName), 2);
    	}
    	else
    	{	
    		headers.get(toolGroupName).add(fp);
    	}
    }
}
