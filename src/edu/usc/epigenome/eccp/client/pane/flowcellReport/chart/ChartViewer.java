package edu.usc.epigenome.eccp.client.pane.flowcellReport.chart;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedPopupPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;

public class ChartViewer extends Composite
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);	
	VerticalPanel mainPanel = new VerticalPanel();
	VerticalPanel chartPanel = new VerticalPanel();
	DecoratedPopupPanel popup = new DecoratedPopupPanel();
	Button closeButton = new Button("close");
	public static enum ChartType
	{
		Area,
		ResultCount,
		Column
	}
	
	
	public ChartViewer(final String csvPath, final ChartType t)
	{
		final Label view = new Label(": view chart");
		view.addStyleName("viewchartlabel");
		
		mainPanel.add(new Label(csvPath.replaceAll(".+/", "")));
		mainPanel.add(chartPanel);
		mainPanel.add(closeButton);
		
	    popup.add(mainPanel);
	    closeButton.addClickHandler(new ClickHandler(){
			public void onClick(ClickEvent event)
			{
				popup.hide();				
			}});
	    
	    view.addClickHandler(new ClickHandler()
	    {
			public void onClick(ClickEvent event)
			{
				popup.showRelativeTo(view);
				chartPanel.clear();
				chartPanel.add(new Label ("Loading data"));
				remoteService.getCSVFromDisk(csvPath, new AsyncCallback<String>()
				{
					public void onFailure(Throwable caught)
					{
						chartPanel.clear();
						chartPanel.add(new Label ("Error loading data!"));
					}
					public void onSuccess(String result)
					{
						chartPanel.clear();
						if(t == ChartType.ResultCount)
							chartPanel.add(new MotionChartViewer(result));
						else if(t == ChartType.Area)
							chartPanel.add(new AreaChartViewer(result));
						else if(t == ChartType.Column)
							chartPanel.add(new ColumnChartViewer(result));
					}
				});				
			}
		});
		initWidget(view);	
	}
}
