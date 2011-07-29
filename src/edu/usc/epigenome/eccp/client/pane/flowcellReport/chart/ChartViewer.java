package edu.usc.epigenome.eccp.client.pane.flowcellReport.chart;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;

public class ChartViewer extends Composite  
{
	private static ChartViewerUiBinder uiBinder = GWT
			.create(ChartViewerUiBinder.class);

	interface ChartViewerUiBinder extends UiBinder<Widget, ChartViewer> {
	}
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	@UiField Label view;
	@UiField FlowPanel mainPanel;
	@UiField FlowPanel chartPanel;
	@UiField FlowPanel popup;
	@UiField Button closeButton;

	public static enum ChartType
	{
		Area,
		ResultCount,
		Column
	}
	
	public ChartViewer() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	
	public ChartViewer(final String csvPath, final ChartType t)
	{
		initWidget(uiBinder.createAndBindUi(this));
		
		closeButton.setVisible(false);
		
		closeButton.addClickHandler(new ClickHandler()
		{
			public void onClick(ClickEvent arg0) 
			{
				chartPanel.clear();
				closeButton.setVisible(false);
			}
		});
	
		//showChart(t, csvPath);
		
		view.addClickHandler(new ClickHandler()
		{
			public void onClick(ClickEvent arg0) 
			{
				//chartPanel.clear();
				//chartPanel.add(new Label ("Loading data"));
				
				remoteService.getCSVFromDisk(csvPath, new AsyncCallback<String>() 
				{	
					public void onSuccess(String result) 
					{
						chartPanel.clear();
						if(t == ChartType.ResultCount)
							chartPanel.add(new MotionChartViewer(result));
						else if(t == ChartType.Area)
							chartPanel.add(new AreaChartViewer(result));
						else if(t == ChartType.Column)
							chartPanel.add(new ColumnChartViewer(result));
						
						closeButton.setVisible(true);
					}
					public void onFailure(Throwable arg0) 
					{
						chartPanel.clear();
						chartPanel.add(new Label ("Error loading data!"));	
					}
				});
			}});
		
	}
	
	public void showChart(final ChartType t, final String csvPath)
	{
		AsyncCallback<String> CSVCallback = new AsyncCallback<String>()
		{	
			@Override
			public void onSuccess(String result) 
			{
				//chartPanel.clear();
				if(t == ChartType.ResultCount)
					chartPanel.add(new MotionChartViewer(result));
				else if(t == ChartType.Area)
					chartPanel.add(new AreaChartViewer(result));
				else if(t == ChartType.Column)
					chartPanel.add(new ColumnChartViewer(result));
			}
			
			@Override
			public void onFailure(Throwable arg0) 
			{
				//chartPanel.clear();
				chartPanel.add(new Label ("Error loading data!"));	
			}
		};remoteService.getCSVFromDisk(csvPath, CSVCallback);
	}

}
