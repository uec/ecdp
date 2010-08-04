package edu.usc.epigenome.eccp.client.pane.flowcellReport.chart;

import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.visualization.client.DataTable;
import com.google.gwt.visualization.client.VisualizationUtils;
import com.google.gwt.visualization.client.AbstractDataTable.ColumnType;
import com.google.gwt.visualization.client.visualizations.ColumnChart;
import com.google.gwt.visualization.client.visualizations.ColumnChart.Options;

public class ColumnChartViewer extends Composite
{
	VerticalPanel mainPanel = new VerticalPanel();
	public ColumnChartViewer(final String inputDataCSV)
	{		
		VisualizationUtils.loadVisualizationApi(new Runnable(){
			public void run()
			{
						String resultRows[] = inputDataCSV.split("\\n");
						DataTable dataMatrix = DataTable.create();
					    dataMatrix.addColumn(ColumnType.STRING, "NMER");
					    dataMatrix.addColumn(ColumnType.NUMBER, "Observed%");
					    dataMatrix.addColumn(ColumnType.NUMBER, "Expected%");					    
					    dataMatrix.addColumn(ColumnType.NUMBER, "O/E");
					    dataMatrix.addRows(20);
						
					    int i = 1;
					    int j = 0;
						while(i  < resultRows.length)
						{									
							String resultColumns[] = resultRows[i].split("\\s+");
							dataMatrix.setValue(j, 0, resultColumns[0]);
							dataMatrix.setValue(j, 1, Double.parseDouble(resultColumns[2]) * 100.0);						
							dataMatrix.setValue(j, 2, Double.parseDouble(resultColumns[3]) * 100.0);
							dataMatrix.setValue(j, 3, Double.parseDouble(resultColumns[4]));
							i = i==9 ? (resultRows.length - 11) : (i+1);
							j++;
						}								
						ColumnChart motion = new ColumnChart(dataMatrix, createOptions());
						mainPanel.add(motion);
										
			}}, ColumnChart.PACKAGE);
		initWidget(mainPanel);
	}
	
	private Options createOptions() 
	{
	    Options options = Options.create();
	    options.setWidth(800);
	    options.setHeight(400);
	    options.setTitle("Counts: Top 10, Bottom 10");
	    //options.setLogScale(true);
	    return options;
	}
}