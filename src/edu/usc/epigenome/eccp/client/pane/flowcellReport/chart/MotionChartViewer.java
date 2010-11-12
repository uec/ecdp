package edu.usc.epigenome.eccp.client.pane.flowcellReport.chart;

import java.util.ArrayList;
import java.util.HashMap;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.visualization.client.DataTable;
import com.google.gwt.visualization.client.VisualizationUtils;
import com.google.gwt.visualization.client.AbstractDataTable.ColumnType;
import com.google.gwt.visualization.client.visualizations.MotionChart;
import com.google.gwt.visualization.client.visualizations.MotionChart.Options;

public class MotionChartViewer extends Composite
{
	DecoratedTabPanel mainPanel = new DecoratedTabPanel();
	public MotionChartViewer(final String inputDataCSV)
	{
		final String resultRows[] = inputDataCSV.split("\\n");
		final ArrayList<ArrayList<String>> data = new ArrayList<ArrayList<String>>();
		final HashMap<String,Integer> totals = new HashMap<String,Integer>();
		
		for (int i = 0; i < resultRows.length; i++)
		{
			String resultColumns[] = resultRows[i].split(",");
			String paddedCyc = resultColumns[3];
			if(resultColumns[3].length() == 1) paddedCyc = "00" + resultColumns[3];
			else if(resultColumns[3].length() == 2) paddedCyc = "0" + resultColumns[3];
			
			ArrayList<String> row = new ArrayList<String>();
			
			row.add(resultColumns[1].toUpperCase() + ":c" + paddedCyc); //Base-Qual
			
			int qual = 1000 + Integer.parseInt(resultColumns[4]);
			row.add(String.valueOf(qual)); //Quality
			
			String cycle = resultColumns[3];
			row.add(cycle); //Cycle
			
			String count=resultColumns[5];
			row.add(count); //Count
			
			row.add(resultColumns[1].toUpperCase()); //Base
			
			data.add(row);
			
			//for normalized
			if(totals.containsKey(cycle + qual))
				totals.put(cycle+qual,totals.get(cycle + qual) + Integer.parseInt(count)); 
			else
				totals.put(cycle+qual,Integer.parseInt(count));			
		}
		
		VisualizationUtils.loadVisualizationApi(new Runnable(){
			public void run()
			{
						//data container for raw counts
						DataTable dataMatrixRawCounts = DataTable.create();
					    dataMatrixRawCounts.addColumn(ColumnType.STRING, "Base-Qual");
					    dataMatrixRawCounts.addColumn(ColumnType.NUMBER, "Quality");
					    dataMatrixRawCounts.addColumn(ColumnType.NUMBER, "Cycle");							    
					    dataMatrixRawCounts.addColumn(ColumnType.NUMBER, "Count");
					    dataMatrixRawCounts.addColumn(ColumnType.STRING, "Base");
						dataMatrixRawCounts.addRows(resultRows.length);
						
						//data container for percentage counts
						DataTable dataMatrixNormalized = DataTable.create();
					    dataMatrixNormalized.addColumn(ColumnType.STRING, "Base-Qual");
					    dataMatrixNormalized.addColumn(ColumnType.NUMBER, "Quality");
					    dataMatrixNormalized.addColumn(ColumnType.NUMBER, "Cycle");							    
					    dataMatrixNormalized.addColumn(ColumnType.NUMBER, "Percentage");
					    dataMatrixNormalized.addColumn(ColumnType.STRING, "Base");
						dataMatrixNormalized.addRows(resultRows.length);
						
						
						for (int i = 0; i < data.size(); i++)
						{									
							dataMatrixRawCounts.setValue(i, 0, data.get(i).get(0));
							dataMatrixRawCounts.setValue(i, 1, Integer.parseInt(data.get(i).get(1)));
							dataMatrixRawCounts.setValue(i, 2, Integer.parseInt(data.get(i).get(2)));
							dataMatrixRawCounts.setValue(i, 3, Integer.parseInt(data.get(i).get(3)));
							dataMatrixRawCounts.setValue(i, 4, data.get(i).get(4));
							
							dataMatrixNormalized.setValue(i, 0, data.get(i).get(0));
							dataMatrixNormalized.setValue(i, 1, Integer.parseInt(data.get(i).get(1)));
							dataMatrixNormalized.setValue(i, 2, Integer.parseInt(data.get(i).get(2)));
							float percentage = Float.parseFloat(data.get(i).get(3)) / totals.get(data.get(i).get(2) + data.get(i).get(1));
							dataMatrixNormalized.setValue(i, 3, 100 * percentage);
							dataMatrixNormalized.setValue(i, 4, data.get(i).get(4));
							
						}								
						MotionChart motion = new MotionChart(dataMatrixRawCounts, createOptions());
						MotionChart motionPercentage = new MotionChart(dataMatrixNormalized, createOptions());
						mainPanel.add(motion, "View by Raw Counts");
						mainPanel.add(motionPercentage, "View by Percentage");
						mainPanel.selectTab(1);
										
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
