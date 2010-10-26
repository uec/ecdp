package edu.usc.epigenome.eccp.client.pane.flowcellReport.chart;

import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.visualization.client.DataTable;
import com.google.gwt.visualization.client.VisualizationUtils;
import com.google.gwt.visualization.client.AbstractDataTable.ColumnType;
import com.google.gwt.visualization.client.visualizations.AreaChart;
import com.google.gwt.visualization.client.visualizations.AreaChart.Options;

public class AreaChartViewer extends Composite
{
	VerticalPanel mainPanel = new VerticalPanel();
	public AreaChartViewer(final String inputDataCSV)
	{		
		VisualizationUtils.loadVisualizationApi(new Runnable(){
			public void run()
			{
						String resultRows[] = inputDataCSV.split("\\n");
						DataTable dataMatrix = DataTable.create();
					    dataMatrix.addColumn(ColumnType.STRING, "X");
					    dataMatrix.addColumn(ColumnType.NUMBER, "Count/Total");
					    dataMatrix.addRows(resultRows.length);
						double total = 0;
						for (int i = 0; i < resultRows.length; i++)
						{
							String resultColumns[] = resultRows[i].split(",");
							total += Integer.parseInt(resultColumns[2]);
						}
						for (int i = 0; i < resultRows.length; i++)
						{									
							String resultColumns[] = resultRows[i].split(",");
							dataMatrix.setValue(i, 0, resultColumns[1]);
							dataMatrix.setValue(i, 1, 100.00 * (Integer.parseInt(resultColumns[2]) / total));						
						}								
						AreaChart motion = new AreaChart(dataMatrix, createOptions());
						mainPanel.add(motion);
										
			}}, AreaChart.PACKAGE);
		initWidget(mainPanel);
	}
	
	private Options createOptions() 
	{
	    Options options = Options.create();
	    options.setWidth(500);
	    options.setHeight(300);
	    options.setMax(100.00);
	    options.setMin(0.00);
	    options.setLogScale(true);
	    return options;
	}
}