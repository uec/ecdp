package edu.usc.epigenome.eccp.client.pane.flowcellReport.chart;

import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.visualization.client.DataTable;
import com.google.gwt.visualization.client.VisualizationUtils;
import com.google.gwt.visualization.client.AbstractDataTable.ColumnType;
import com.google.gwt.visualization.client.visualizations.MotionChart;
import com.google.gwt.visualization.client.visualizations.MotionChart.Options;

public class MotionChartViewer extends Composite
{
	VerticalPanel mainPanel = new VerticalPanel();
	public MotionChartViewer(final String inputDataCSV)
	{		
		VisualizationUtils.loadVisualizationApi(new Runnable(){
			public void run()
			{
						String resultRows[] = inputDataCSV.split("\\n");
						DataTable dataMatrix = DataTable.create();
					    dataMatrix.addColumn(ColumnType.STRING, "Base-Qual");
					    dataMatrix.addColumn(ColumnType.NUMBER, "Quality");
					    dataMatrix.addColumn(ColumnType.NUMBER, "Cycle");							    
					    dataMatrix.addColumn(ColumnType.NUMBER, "Count");
					    dataMatrix.addColumn(ColumnType.STRING, "Base");
						dataMatrix.addRows(resultRows.length);
						
						for (int i = 0; i < resultRows.length; i++)
						{									
							String resultColumns[] = resultRows[i].split(",");
							//String paddedQual = resultColumns[4].length() < 2 ? ("0" + resultColumns[4]) : resultColumns[4];
							String paddedCyc = resultColumns[3];
							if(resultColumns[3].length() == 1) paddedCyc = "00" + resultColumns[3];
							else if(resultColumns[3].length() == 2) paddedCyc = "0" + resultColumns[3];
							
							//dataMatrix.setValue(i, 0, resultColumns[1].toUpperCase() + ":q" + paddedQual );
							dataMatrix.setValue(i, 0, resultColumns[1].toUpperCase() + ":c" + paddedCyc );
							dataMatrix.setValue(i, 1, 1000 + Integer.parseInt(resultColumns[4]));
							dataMatrix.setValue(i, 2, Integer.parseInt(resultColumns[3]));
							dataMatrix.setValue(i, 3, Integer.parseInt(resultColumns[5]));
							dataMatrix.setValue(i, 4, resultColumns[1].toUpperCase());
						}								
						MotionChart motion = new MotionChart(dataMatrix, createOptions());
						mainPanel.add(motion);
										
			}}, MotionChart.PACKAGE);
		initWidget(mainPanel);
	}
	
	private Options createOptions() 
	{
	    Options options = Options.create();
	    options.setWidth(800);
	    options.setHeight(600);
	    options.setState("{\"dimensions\":{\"iconDimensions\":[\"dim0\"]},\"colorOption\":\"4\",\"yZoomedDataMin\":1,\"yAxisOption\":\"3\",\"sizeOption\":\"3\",\"xLambda\":1,\"orderedByY\":false,\"showTrails\":true,\"playDuration\":15000,\"iconKeySettings\":[],\"iconType\":\"BUBBLE\",\"xZoomedIn\":false,\"orderedByX\":false,\"xZoomedDataMin\":0,\"nonSelectedAlpha\":0.4,\"time\":\"1001\",\"xAxisOption\":\"2\",\"uniColorForNonSelected\":false,\"duration\":{\"multiplier\":1,\"timeUnit\":\"Y\"},\"yZoomedIn\":false}");
	    return options;
	}
}
