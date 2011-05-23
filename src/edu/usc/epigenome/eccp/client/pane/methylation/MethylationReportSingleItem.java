package edu.usc.epigenome.eccp.client.pane.methylation;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.MethylationData;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.filereport.FileBrowser;

public class MethylationReportSingleItem extends Composite {

	private static MethylationReportSingleItemUiBinder uiBinder = GWT
			.create(MethylationReportSingleItemUiBinder.class);

	interface MethylationReportSingleItemUiBinder extends
			UiBinder<Widget, MethylationReportSingleItem> {
	}

	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	MethylationData beadArray;
	//SampleData sampGeneus;
	
	public MethylationReportSingleItem() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	@UiField FlowPanel vp;
	@UiField FlexTable flowcellTable;
	@UiField FlexTable flowcellTableSample;
	@UiField DisclosurePanel qcPanel;
	@UiField DisclosurePanel filePanel;
	@UiField FlowPanel qcvp;
	@UiField FlowPanel filesvp;
	
	public MethylationReportSingleItem(final MethylationData flowcellIn)
	{
		beadArray=flowcellIn;
		initWidget(uiBinder.createAndBindUi(this));
	
		flowcellTable.setText(0,0, "Bead Array ID: " + beadArray.getFlowcellProperty("serial"));
		flowcellTable.setText(0,1, "Lims ID: " + beadArray.getFlowcellProperty("limsID"));
		
		int row = 0;
		flowcellTableSample.setText(row,0, "Location");
		flowcellTableSample.setText(row,1, "Library");
		flowcellTableSample.setText(row,2, "Organism");
		flowcellTableSample.setText(row,3, "Sex");
		flowcellTableSample.setText(row,4, "Tissue");
		flowcellTableSample.setText(row,5, "Project");
		flowcellTableSample.setText(row,6, "Date");
		List<Integer> keys = new ArrayList<Integer>(beadArray.lane.keySet());
		Collections.sort(keys);
		
		for(int i : keys)
		{
			row++;
			flowcellTableSample.setText(row,0, beadArray.getLaneProperty(i,"lane"));
			flowcellTableSample.setText(row,1, beadArray.getLaneProperty(i,"name"));
			flowcellTableSample.setText(row,2, beadArray.getLaneProperty(i,"organism"));
			flowcellTableSample.setText(row,3, beadArray.getLaneProperty(i,"sex"));
			flowcellTableSample.setText(row,4, beadArray.getLaneProperty(i,"tissue"));
			flowcellTableSample.setText(row,5, beadArray.getLaneProperty(i,"project"));
			flowcellTableSample.setText(row,6, beadArray.getLaneProperty(i,"date"));
		}
		
		qcPanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
		{
			public void onOpen(OpenEvent<DisclosurePanel> event)
			{
				qcPanel.add(new Image("images/progress.gif"));
				remoteService.getQCforMeth(beadArray.getFlowcellProperty("serial"), new AsyncCallback<MethylationData>() {

				public void onFailure(Throwable caught)
				{
					qcPanel.clear();
					qcPanel.add(new Label(caught.getMessage()));
								
				}
				public void onSuccess(MethylationData result)
				{
					qcPanel.clear();
					beadArray.laneQC = result.laneQC;
					beadArray.filterLanesThatContain();
					VerticalPanel qcvp = new VerticalPanel();
					qcPanel.add(qcvp);
					for(String location : beadArray.laneQC.keySet())
					{
						qcvp.add(new Label("QC Metrics from " + location));
						FlexTable qcFlexTable = new  FlexTable();
						int j=0;
						Boolean firstLine = true;
						for(int i=1;i<=8;i++)
						{
							if(beadArray.laneQC.get(location).containsKey(i))
							{	
								j=0;
								if(firstLine)
								{						
									beadArray.laneQC.get(location).get(i).remove("FlowCelln");
									for(String s : beadArray.laneQC.get(location).get(i).keySet())
									{								
										qcFlexTable.setText(0, j, s);
										j++;
									}
									firstLine = false;
									j=0;
								}									
											
								beadArray.laneQC.get(location).get(i).remove("FlowCelln");
								for(String s : beadArray.laneQC.get(location).get(i).keySet())
								{
									qcFlexTable.setText(i, j, beadArray.laneQC.get(location).get(i).get(s));
									j++;
								}
							}
						}							
						qcFlexTable.addStyleName("qctable");
						qcvp.add(qcFlexTable);							
					}						
				}});				
			}			
		});
		
				filePanel.addOpenHandler(new OpenHandler<DisclosurePanel>()
				{

					public void onOpen(OpenEvent<DisclosurePanel> event)
					{
						filesvp.add(new Image("images/progress.gif"));
						remoteService.getFilesForMeth(beadArray.getFlowcellProperty("serial"), new AsyncCallback<MethylationData>(){

							public void onFailure(Throwable caught)
							{
								filesvp.clear();
								filesvp.add(new Label(caught.getMessage()));
								
							}

							public void onSuccess(MethylationData result)
							{
								filesvp.clear();
								beadArray.fileList = result.fileList;
								beadArray.filterLanesThatContain();
								FileBrowser f = new FileBrowser(beadArray.fileList);
								filesvp.add(f);
						}});				
					}			
				});
	}
}
