package edu.usc.epigenome.eccp.client.Resources;

import com.google.gwt.core.client.GWT;
import com.google.gwt.resources.client.ClientBundle;
import com.google.gwt.resources.client.CssResource;
import com.google.gwt.resources.client.CssResource.NotStrict;

public interface UserPanelResources extends ClientBundle
{
	public static final UserPanelResources INSTANCE =  GWT.create(UserPanelResources.class);
	
	
	public interface UserPanelCss extends CssResource
	{
		String flowcellsearch();
		String samplesearch();
		String flowcellitem();
		String flowcellitemlane();
		String fileGroupsDisplay();
		String displayContext();
		String contentTableDisplay();
		String displayfilehorizontal();
		String samplereportitem();
		String viewdisplaylabel();
		String samplereportvp();
		String popupdisplaypanel();
	}
	
	@NotStrict
	@Source("ECControlCenter.css")
	UserPanelCss userPanel();
	
	
}
