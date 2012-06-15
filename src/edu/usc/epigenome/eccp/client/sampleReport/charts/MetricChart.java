package edu.usc.epigenome.eccp.client.sampleReport.charts;

import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.widget.core.client.Dialog;
import com.sencha.gxt.widget.core.client.Dialog.PredefinedButton;

public abstract class MetricChart
{
	protected void showDialog(String title, Widget chart)
	{
		//show the plot
		final Dialog simple = new Dialog();
		simple.setHeadingText(title);
		simple.setPredefinedButtons(PredefinedButton.OK);
		simple.setBodyStyleName("pad-text");
		simple.add(chart);
		simple.setHideOnButtonClick(true);
		simple.setWidth(650);
		simple.setHeight(650);
		simple.show();
	}
	
	public abstract void show();
}
