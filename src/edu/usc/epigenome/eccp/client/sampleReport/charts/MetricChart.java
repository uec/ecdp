package edu.usc.epigenome.eccp.client.sampleReport.charts;

import com.google.gwt.event.logical.shared.ResizeEvent;
import com.google.gwt.event.logical.shared.ResizeHandler;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.widget.core.client.Dialog;
import com.sencha.gxt.widget.core.client.Dialog.PredefinedButton;
import com.sencha.gxt.widget.core.client.info.Info;

public abstract class MetricChart
{
	protected void showDialog(String title, Widget chart, int width, int height)
	{
		//show the plot
		final Dialog simple = new Dialog();
		simple.setHeadingText(title);
		simple.setPredefinedButtons(PredefinedButton.OK);
		simple.setBodyStyleName("pad-text");
		simple.add(chart);
		simple.setHideOnButtonClick(true);
		simple.setWidth(width);
		simple.setHeight(height);
		simple.show();
		simple.addResizeHandler(new ResizeHandler(){

			@Override
			public void onResize(ResizeEvent event)
			{
				simple.hide();
				show( event.getWidth(), event.getHeight());
			}});
	}
	
	public abstract void show();
	public abstract void show(int width,int height);
}
