package edu.usc.epigenome.eccp.client.sampleReport.charts;
import java.util.List;
import com.google.gwt.visualization.client.DataTable;
import com.google.gwt.visualization.client.VisualizationUtils;
import com.google.gwt.visualization.client.AbstractDataTable.ColumnType;
import com.google.gwt.visualization.client.visualizations.ColumnChart;
import com.google.gwt.visualization.client.visualizations.ColumnChart.Options;
import com.sencha.gxt.widget.core.client.info.Info;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.MultipleLibraryProperty;

public class BarChartWidget  extends MetricChart
{
	MultipleLibraryProperty metric;
	List<LibraryData> libraries;
	
	public BarChartWidget(MultipleLibraryProperty metric, List<LibraryData> libraries)
	{
		this.metric = metric;
		this.libraries = libraries;	
	}

	@Override
	public void show()
	{
		try
		{
			VisualizationUtils.loadVisualizationApi(new Runnable(){
				public void run()
				{
							
							DataTable dataMatrix = DataTable.create();
						    dataMatrix.addColumn(ColumnType.STRING, metric.getName());
						    dataMatrix.addColumn(ColumnType.NUMBER,  metric.getName());
						    dataMatrix.addRows(metric.getValueSize());
							
						    for(int i=0;i< metric.getValueSize();i++)
							{									
								dataMatrix.setValue(i, 0, libraries.get(i).get("sample_name").getValue());
								dataMatrix.setValue(i, 1, Double.parseDouble(metric.getValue(i).replace(",", "")));
							}								
							
							Options options = Options.create();
							options.setWidth(600);
							options.setHeight(600);
							ColumnChart motion = new ColumnChart(dataMatrix, options);
							
							//show the plot
							showDialog(metric.getName(),motion);
				}}, ColumnChart.PACKAGE);	
		}
		catch(Exception e)
		{
			Info.display("Error","You can only plot numeric data");
		}		
		
	}

}
