package edu.usc.epigenome.eccp.client;
import java.util.Map;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.RootLayoutPanel;
import com.sencha.gxt.widget.core.client.container.Viewport;

/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class ECControlCenter implements EntryPoint
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	//static variable to keep track of the userType
	public static String userType = null;

	/*
	 * Method to get the user type (super user or guest user)
	 */
	public static String getUserType() {
		return userType;
	}

	/*
	 * Method to set the user type
	 */
	public static void setUserType(String userType) {
		ECControlCenter.userType = userType;
	}

	/**
	 * This is the entry point method.
	 * Check for the parameters and set the user type(either super or guest user)
	 * and bind to that particular template
	 */
	public void onModuleLoad() 
	{
		/********************************************************
		 * FOR DEPLOYMENT uncomment the following block of code
		 ********************************************************
		 */
	/*	if(Window.Location.getQueryString().equals("") && Window.Location.getPath().endsWith("/ECCPBinder/"))
		{
			userType = "super";
			ECCPBinderWidget sbw = new ECCPBinderWidget();
			RootLayoutPanel.get().add(sbw);
		}
		else
		{
			Map<String, java.util.List<String>> m = Window.Location.getParameterMap();
			if(m.containsKey("au"))
			{
				if(Window.Location.getParameter("au").contentEquals("smp"))
				{
					if((Window.Location.getParameter("s").length() > 0))
					{
						userType = "guest";
						GenUserBinderWidget gubw = new GenUserBinderWidget();
						RootLayoutPanel.get().add(gubw);
					}
				}
			else
			{
				RootLayoutPanel.get().add(new Label("Your access code is expired or does not exist. Please contact Zack Ramjan (ramjan @ usc edu) at the USC Epigenome Center for a new code"));
			}
		}
		else
		{
			RootLayoutPanel.get().add(new Label("Your access code is expired or does not exist. Please contact Zack Ramjan (ramjan @ usc edu) at the USC Epigenome Center for a new code"));
		}
	}*/
		
	/*******************************************************************
	 * 	FOR TESTING HOSTED MODE comment out the following section
	 *******************************************************************/
	if(Window.Location.getQueryString().contains("gwt"))
	{
		if(Window.Location.getQueryString().contains("au"))
		{
			if((Window.Location.getParameter("s").length() > 0))
			{
				userType = "guest";
				//GenUserBinderWidget gubw = new GenUserBinderWidget();
				//RootLayoutPanel.get().add(gubw);
			}
		}
		else
		{
			userType = "super";
			ECCPBinderWidget sbw = new ECCPBinderWidget();
			Viewport viewport = new Viewport();
		    viewport.setWidget(sbw);
			RootLayoutPanel.get().add(viewport);
		}
	}
  }
}
