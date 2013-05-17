package edu.usc.epigenome.eccp.client.sampleReport.charts;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.visualization.client.DataTable;
import com.google.gwt.visualization.client.VisualizationUtils;
import com.google.gwt.visualization.client.AbstractDataTable.ColumnType;
import com.google.gwt.visualization.client.visualizations.MotionChart;
import com.google.gwt.visualization.client.visualizations.MotionChart.Options;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import java.util.ArrayList;
import java.util.HashMap;

public class MotionChartWidget extends MetricChart
{

	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);
	String inputDataCSVPath;
	public MotionChartWidget(String inputDataCSVPath)
	{
		this.inputDataCSVPath = inputDataCSVPath;
	}
	
	@Override
	public void show()
	{
		show(750,700);

	}

	@Override
	public void show(final int width, final int height)
	{
		myServer.getCSVFromDisk(inputDataCSVPath, new AsyncCallback<String>(){

			@Override
			public void onFailure(Throwable caught)
			{
				
				
			}

			@Override
			public void onSuccess(String result)
			{
				String inputDataCSV = result;
				final DecoratedTabPanel mainPanel = new DecoratedTabPanel();
				final String resultRows[] = inputDataCSV.split("\\n");
				final ArrayList<ArrayList<String>> data = new ArrayList<ArrayList<String>>();
				final HashMap<String,Integer> totals = new HashMap<String,Integer>();
				final HashMap<String, Integer> accTotals = new HashMap<String, Integer>();
				final HashMap<String, Float> accSum = new HashMap<String, Float>();
				
				
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
								
								//data container for Accumulative counts for qualities
								DataTable dataMatrixAccumulative = DataTable.create();
								dataMatrixAccumulative.addColumn(ColumnType.STRING, "Base-Qual");
								dataMatrixAccumulative.addColumn(ColumnType.NUMBER, "Quality");
								dataMatrixAccumulative.addColumn(ColumnType.NUMBER, "Cycle");							    
								dataMatrixAccumulative.addColumn(ColumnType.NUMBER, "Count");
								dataMatrixAccumulative.addColumn(ColumnType.STRING, "Base");
								dataMatrixAccumulative.addRows(resultRows.length);
								
								
								DataTable dataMatrixAccPercent = DataTable.create();
								dataMatrixAccPercent.addColumn(ColumnType.STRING, "Base-Qual");
								dataMatrixAccPercent.addColumn(ColumnType.NUMBER, "Quality");
								dataMatrixAccPercent.addColumn(ColumnType.NUMBER, "Cycle");							    
								dataMatrixAccPercent.addColumn(ColumnType.NUMBER, "Percentage");
								dataMatrixAccPercent.addColumn(ColumnType.STRING, "Base");
								dataMatrixAccPercent.addRows(resultRows.length);
								
								String str1;
								//variable to hold the summation value
								int summation;
								float sum;
					
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
									
									//get the base-qual and count value for the first element in the data arraylist
									str1 = data.get(i).get(0);
									summation = Integer.parseInt(data.get(i).get(3));
									sum = Float.parseFloat(data.get(i).get(3));
									
									//start a for loop from (i+1th) element 
									for(int j=i+1;j<data.size();j++)
									{
										//compare if elements belong to the same base and cycle
										if(str1.equals(data.get(j).get(0)))
										{
											//if yes, add the count to the summation
											summation = summation + Integer.parseInt(data.get(j).get(3));
											sum = sum + Float.parseFloat(data.get(j).get(3));
										}
										else
										{
											//break 
											break;
										}
									}//end of inner for loop (j)
									
									accSum.put((data.get(i).get(4) + data.get(i).get(2) + Integer.parseInt(data.get(i).get(1))), sum);
									
									if(accTotals.containsKey(data.get(i).get(2) + Integer.parseInt(data.get(i).get(1))))
										accTotals.put(data.get(i).get(2) + Integer.parseInt(data.get(i).get(1)),accTotals.get(data.get(i).get(2) + Integer.parseInt(data.get(i).get(1))) + summation); 
									else
										accTotals.put(data.get(i).get(2) + Integer.parseInt(data.get(i).get(1)),summation);	
									
									//set values in the data table along with the summation value
									dataMatrixAccumulative.setValue(i, 0, data.get(i).get(0));
									dataMatrixAccumulative.setValue(i, 1, Integer.parseInt(data.get(i).get(1)));
									dataMatrixAccumulative.setValue(i, 2, Integer.parseInt(data.get(i).get(2)));
									dataMatrixAccumulative.setValue(i, 3, summation);
									dataMatrixAccumulative.setValue(i, 4, data.get(i).get(4));
								}//end for						
								
								//for displaying accumulative qualities by percentage
								/*float percentSum;
								String str2;
								for(int i = 0;i < data.size(); i++)
								{
									str2 = data.get(i).get(0);
									percentSum = Float.parseFloat(data.get(i).get(3));
									
									//start a for loop from (i+1th) element 
									for(int j=i+1;j<data.size();j++)
									{
										//compare if elements belong to the same base and cycle
										if(str2.equals(data.get(j).get(0)))
										{
											//if yes, add the count to the summation
											percentSum = percentSum + Float.parseFloat(data.get(j).get(3));
										}
										else
										{
											//break 
											break;
										}
									}
									dataMatrixAccPercent.setValue(i, 0, data.get(i).get(0));
									dataMatrixAccPercent.setValue(i, 1, Integer.parseInt(data.get(i).get(1)));
									dataMatrixAccPercent.setValue(i, 2, Integer.parseInt(data.get(i).get(2)));
									float percentAccu = (percentSum) / accTotals.get(data.get(i).get(2) + data.get(i).get(1));
									dataMatrixAccPercent.setValue(i, 3, 100 * percentAccu);
									dataMatrixAccPercent.setValue(i, 4, data.get(i).get(4));
								}*/
								
								for(int i=0; i< data.size(); i++)
								{
									dataMatrixAccPercent.setValue(i, 0, data.get(i).get(0));
									dataMatrixAccPercent.setValue(i, 1, Integer.parseInt(data.get(i).get(1)));
									dataMatrixAccPercent.setValue(i, 2, Integer.parseInt(data.get(i).get(2)));
									float percentAccu = accSum.get((data.get(i).get(4) + data.get(i).get(2) + Integer.parseInt(data.get(i).get(1)))) / accTotals.get(data.get(i).get(2) + data.get(i).get(1));
									dataMatrixAccPercent.setValue(i, 3, 100 * percentAccu);
									dataMatrixAccPercent.setValue(i, 4, data.get(i).get(4));
								}
								
								//System.out.println("The accTotals for 261015 is " + accTotals.get("261015"));
								//System.out.println("The accSum for A 261015 is " + accSum.get("A261015"));
								//System.out.println("The size of accSum is " + accSum.size());
								
								MotionChart motion = new MotionChart(dataMatrixRawCounts, createOptions());
								MotionChart motionPercentage = new MotionChart(dataMatrixNormalized, createOptions());
								MotionChart motionAccu = new MotionChart(dataMatrixAccumulative, createOptions());
								MotionChart motionAccuPercentage = new MotionChart(dataMatrixAccPercent, createOptions());
								mainPanel.add(motion, "View by Raw Counts");
								mainPanel.add(motionPercentage, "View by Percentage");
								mainPanel.add(motionAccu,"View by Accumulative Qualities");
								mainPanel.add(motionAccuPercentage, "View by Accumulative Percentage");
								mainPanel.selectTab(1);
								
								showDialog("Base Quality Cycle Distrobution",mainPanel,width,height);
												
					}}, MotionChart.PACKAGE);
			}});

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
