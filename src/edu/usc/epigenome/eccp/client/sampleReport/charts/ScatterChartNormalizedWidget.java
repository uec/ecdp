package edu.usc.epigenome.eccp.client.sampleReport.charts;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.TreeSet;

import com.google.gwt.core.client.GWT;
import com.google.gwt.visualization.client.DataTable;
import com.google.gwt.visualization.client.VisualizationUtils;
import com.google.gwt.visualization.client.AbstractDataTable.ColumnType;
import com.google.gwt.visualization.client.visualizations.ScatterChart;
import com.google.gwt.visualization.client.visualizations.ScatterChart.Options;
import com.google.web.bindery.autobean.shared.AutoBean;
import com.google.web.bindery.autobean.shared.AutoBeanCodex;
import com.sencha.gxt.widget.core.client.info.Info;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.MultipleLibraryProperty;
import edu.usc.epigenome.eccp.client.data.XYDataFactory;
import edu.usc.epigenome.eccp.client.data.XYData;
public class ScatterChartNormalizedWidget  extends MetricChart
{
	MultipleLibraryProperty metric;
	List<LibraryData> libraries;
	
	public ScatterChartNormalizedWidget(MultipleLibraryProperty metric, List<LibraryData> libraries)
	{
		this.metric = metric;
		this.libraries = libraries;	
	}

	@Override
	public void show()
	{
		try
		{
			final HashMap<Double,ArrayList<Double>> data = new HashMap<Double,ArrayList<Double>>();
			final ArrayList<String> series = new ArrayList<String>();
			final ArrayList<String> title = new ArrayList<String>();
			
			for(int i=0;i<metric.getValueSize();i++)
				series.add(libraries.get(i).get("sample_name").getValue());
			
			for(int i=0;i<metric.getValueSize();i++)
			{
				try
				{
					XYDataFactory scatterFactory = GWT.create(XYDataFactory.class);
					AutoBean<XYData> autoBeanXYData = AutoBeanCodex.decode(scatterFactory, XYData.class, metric.getValue(i).replaceFirst("\\s+", ""));
					XYData scatter = autoBeanXYData.as();
					
					Double sum=0d;
					for(int j=0;j< scatter.getY().size();j++)
						sum+=scatter.getY().get(j);
						
					for(int j=0;j< scatter.getX().size();j++)
					{					
						Double x = scatter.getX().get(j);
						Double y = scatter.getY().get(j);
						if(!data.containsKey(x))
						{
							data.put(x,new ArrayList<Double>());
							for(int k=0;k<metric.getValueSize();k++)
								data.get(x).add(0d);
						}
						data.get(x).set(i, y/sum);
					}
					title.add(scatter.getTitle());
				}
				catch(Exception e)
				{
					Info.display("ERROR", "Could not plot data from library " + i);
					e.printStackTrace();
				}
			}
			
			
			VisualizationUtils.loadVisualizationApi(new Runnable(){
				public void run()
				{
					DataTable dataMatrix = DataTable.create();
				    dataMatrix.addColumn(ColumnType.NUMBER, "X");
				    for(String label : series)
				    	dataMatrix.addColumn(ColumnType.NUMBER,  label);
				    
				    dataMatrix.addRows(data.size());
				    TreeSet<Double> keys = new TreeSet<Double>(data.keySet());
				    
				    int i =0;
				    for(Double x : keys)
					{									
						dataMatrix.setValue(i, 0, x);
						for(int j = 0; j<data.get(x).size();j++)
							if( data.get(x).get(j) != 0d)
							dataMatrix.setValue(i, j+1, data.get(x).get(j));
						i++;
					}								
					
					Options options = Options.create();
					options.setTitle(title.get(0));
					options.setWidth(700);
					options.setHeight(600);
					ScatterChart motion = new ScatterChart(dataMatrix, options);
					
					
					//show the plot
					showDialog(metric.getName(),motion);
				}}, ScatterChart.PACKAGE);	
		}
		catch(Exception e)
		{
			Info.display("Error","You can only plot numeric data");
		}		
		
	}

}