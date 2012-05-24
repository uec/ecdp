package edu.usc.epigenome.eccp.client.sencha;

import com.sencha.gxt.widget.core.client.grid.GroupingView;

public class ResizeGroupingView<M> extends GroupingView<M>
{
	public void doResize()
	{
		this.layout();
	}
}
