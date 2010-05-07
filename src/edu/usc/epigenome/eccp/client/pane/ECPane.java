package edu.usc.epigenome.eccp.client.pane;

import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;

abstract public class ECPane extends Composite implements ECPaneInterface
{
		
	public ECPane()
	{
		
	}
	
	abstract public void showTool();
	
	abstract public Image getToolLogo();

	abstract public Label getToolTitle();
}
