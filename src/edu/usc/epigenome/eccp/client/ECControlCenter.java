package edu.usc.epigenome.eccp.client;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.ui.RootLayoutPanel;
import com.sencha.gxt.widget.core.client.container.Viewport;

/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class ECControlCenter implements EntryPoint
{
	/**
	 * This is the entry point method.
	 * Check for the parameters and set the user type(either super or guest user)
	 * and bind to that particular template
	 */
	public void onModuleLoad() 
	{
			ECCPBinderWidget sbw = new ECCPBinderWidget();
			Viewport viewport = new Viewport();
		    viewport.setWidget(sbw);
			RootLayoutPanel.get().add(viewport);
	}
}
