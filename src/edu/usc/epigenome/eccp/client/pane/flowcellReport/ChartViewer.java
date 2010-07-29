package edu.usc.epigenome.eccp.client.pane.flowcellReport;



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

import com.google.gwt.visualization.client.VisualizationUtils;
import com.google.gwt.visualization.client.DataTable;

import com.google.gwt.visualization.client.AbstractDataTable.ColumnType;

import com.google.gwt.visualization.client.visualizations.MotionChart;
import com.google.gwt.visualization.client.visualizations.MotionChart.Options;


public class ChartViewer extends Composite
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	VerticalPanel mainPanel = new VerticalPanel();
	VerticalPanel chartPanel = new VerticalPanel();
	DecoratedPopupPanel popup = new DecoratedPopupPanel();
	Button closeButton = new Button("close");
	
	ChartViewer(final String csvPath)
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
				VisualizationUtils.loadVisualizationApi(new Runnable(){

					public void run()
					{
						remoteService.getCSVFromDisk(csvPath, new AsyncCallback<String>(){
							public void onFailure(Throwable caught)
							{
								chartPanel.clear();
								chartPanel.add(new Label ("Error loading data!"));
							}

							public void onSuccess(String result)
							{
								chartPanel.clear();
								String resultRows[] = result.split("\\n");
								DataTable dataMatrix = DataTable.create();
							    dataMatrix.addColumn(ColumnType.STRING, "Base-Qual");
							    dataMatrix.addColumn(ColumnType.NUMBER, "Cycle");
							    dataMatrix.addColumn(ColumnType.NUMBER, "Quality");
							    dataMatrix.addColumn(ColumnType.NUMBER, "Count");
							    dataMatrix.addColumn(ColumnType.STRING, "Base");
								dataMatrix.addRows(resultRows.length);
								
								for (int i = 0; i < resultRows.length; i++)
								{									
									String resultColumns[] = resultRows[i].split(",");
									String paddedQual = resultColumns[4].length() < 2 ? ("0" + resultColumns[4]) : resultColumns[4];
									
									dataMatrix.setValue(i, 0, resultColumns[1].toUpperCase() + ":q" + paddedQual );
									dataMatrix.setValue(i, 1, 1000 + Integer.parseInt(resultColumns[3]));
									dataMatrix.setValue(i, 2, Integer.parseInt(resultColumns[4]));
									dataMatrix.setValue(i, 3, Integer.parseInt(resultColumns[5]));
									dataMatrix.setValue(i, 4, resultColumns[1].toUpperCase());
								}								
								MotionChart motion = new MotionChart(dataMatrix, createOptions());
								chartPanel.add(motion);
							}});
						
					}}, MotionChart.PACKAGE);
				
			}
		});
		initWidget(view);	
	}

	private Options createOptions() {
		    Options options = Options.create();
		    options.setWidth(600);
		    options.setHeight(400);
		    options.setState("{\"dimensions\":{\"iconDimensions\":[\"dim0\"]},\"colorOption\":\"4\",\"yZoomedDataMin\":1,\"yAxisOption\":\"3\",\"sizeOption\":\"3\",\"xLambda\":1,\"orderedByY\":false,\"showTrails\":true,\"playDuration\":15000,\"iconKeySettings\":[],\"iconType\":\"BUBBLE\",\"xZoomedIn\":false,\"orderedByX\":false,\"xZoomedDataMin\":0,\"nonSelectedAlpha\":0.4,\"time\":\"1001\",\"xAxisOption\":\"2\",\"uniColorForNonSelected\":false,\"duration\":{\"multiplier\":1,\"timeUnit\":\"Y\"},\"yZoomedIn\":false}");
		    
		    return options;
		  }
}
