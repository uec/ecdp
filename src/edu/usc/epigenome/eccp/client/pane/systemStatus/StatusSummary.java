package edu.usc.epigenome.eccp.client.pane.systemStatus;

import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.pane.ECPane;

public class StatusSummary extends ECPane
{
	final VerticalPanel vp = new VerticalPanel();
	public StatusSummary()
	{
		initWidget(vp);	
	}
	@Override
	public Image getToolLogo()
	{	
		return new Image("images/globe_process.png");
	}

	@Override
	public Label getToolTitle()
	{
		return new Label("Local System Status");
	}

	@Override
	public void showTool()
	{
		vp.add(new HTML("<iframe src=\"http://epiweb.usc.edu/zcheck/index.html\" width=\"800px\" height=\"440px\"></iframe>"));		
	}


}
