package edu.usc.epigenome.eccp.client.pane.flowcellReport;


import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Tree;
import com.google.gwt.user.client.ui.TreeItem;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.FlowcellData;
import edu.usc.epigenome.eccp.client.pane.composites.TreeItemClick;
import edu.usc.epigenome.eccp.client.pane.sampleReport.FilesDownload;
import edu.usc.epigenome.eccp.client.pane.sampleReport.QCPlots;
import edu.usc.epigenome.eccp.client.pane.sampleReport.QCReport;

/*
 * Class to generate a Tree structure for the Flowcells
 */
public class FlowcellSingleItem extends Composite  {

	private static FlowcellSingleItemUiBinder uiBinder = GWT
			.create(FlowcellSingleItemUiBinder.class);

	interface FlowcellSingleItemUiBinder extends
			UiBinder<Widget, FlowcellSingleItem> {
	}
	
	//Enject resources (css styles)
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	@UiField Tree t;
	FlowcellData flowcell;
	
	public FlowcellSingleItem() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	/*
	 * Constructor that takes an instance of FlowcellData
	 * and create a tree structure
	 */
	public FlowcellSingleItem(final FlowcellData flowcellIn)
	{
	  flowcell=flowcellIn;
	  initWidget(uiBinder.createAndBindUi(this));
	  
	  //Create an instance of TreeItemClick with the elements to be added at a tree level
	  TreeItemClick fcellItem = new TreeItemClick("Fcell", flowcell.getFlowcellProperty("serial"), "technician", flowcell.getFlowcellProperty("technician"));
	  final TreeItem fcellRoot = new TreeItem(fcellItem);
	  //add Flowcell TreeItem to the top of the tree
	  t.addItem(fcellRoot);
	  fcellRoot.addItem("");
					
	  //Iterate over the laneNo for the flowcell
	  for(final Integer laneNo : flowcell.lane.keySet())
	  {
		//Get the sampleName belonging to this laneNo
		String samp_name = flowcell.getLaneProperty(laneNo, "name");
		//Split the sampleNames (SampleNames are separated by "!")
		final String sampNames[] = samp_name.split("\\!");
		TreeItemClick laneClick = new TreeItemClick("Lane", laneNo.toString(), "(count", Integer.toString(sampNames.length) + " items)");
		if(sampNames.length == 1)
			laneClick = new TreeItemClick("Lane", laneNo.toString(),"(Library ", sampNames[0] +")");
		
		//Create TreeItem for each of the laneNos
		final TreeItem laneItem = new TreeItem(laneClick);
		laneItem.addItem("");

		String sampleID = flowcell.getLaneProperty(laneNo, "sampleID");
		String sampId[] = sampleID.split("\\!");
		//Iterate over the samples and create TreeItems for each of the samples
		for(int i=0;i<sampId.length;i++)
		{
		   final String sName = sampNames[i];
		   final String sId = sampId[i];
		   TreeItemClick sampleClick = new TreeItemClick("Library", sName, "Project", flowcell.getLaneProperty(laneNo,"project"));
		   final TreeItem sampleItem = new TreeItem(sampleClick);
		   laneItem.addItem(sampleItem);
		   sampleItem.addItem("");
		   //On opening the sampleItem, a remote service call to the backend to get the runs for the given flowcell, lane and sample
		   t.addOpenHandler(new OpenHandler<TreeItem>()
		   {
			 
			  public void onOpen(OpenEvent<TreeItem> event1) 
			  {
				TreeItem item = event1.getTarget();
				if(sampleItem.getChildCount() > 0 && sampleItem.getChildCount() <=1 && item.getText().contains(sName))
				{
				  remoteService.getQCSampleFlowcell(flowcell.getFlowcellProperty("serial"), sName, laneNo, "super", new AsyncCallback<FlowcellData>()
				  {
					public void onFailure(Throwable arg0) {
					  arg0.getMessage();
					}
					public void onSuccess(FlowcellData QCGot) 
					{
					  flowcell.laneQC = QCGot.laneQC;
					  //Filter the results obtained by calling filterAnalysis and filterQC
					  flowcell.filterAnalysis(flowcell.getFlowcellProperty("serial"), laneNo, sId);
					  flowcell.filterQC(laneNo);
					  
					  //Iterate over each of the runs and create TreeItems for them and add to sampleItems
					  for(String runId : flowcell.laneQC.keySet())
					  {
						TreeItemClick runClick = new TreeItemClick("Run", runId , "", "");
						TreeItem runItem = new TreeItem(runClick);	
						sampleItem.addItem(runItem);
						//Add the QCReport, DownloadFiles and QCPlots section to the run(TreeItem)
						runItem.addItem(new QCReport(flowcell, flowcell.getFlowcellProperty("serial"), laneNo, runId, sName, sId));
						runItem.addItem(new FilesDownload(flowcell, flowcell.getFlowcellProperty("serial"), laneNo, runId, sName, sId));
						runItem.addItem(new QCPlots(flowcell, flowcell.getFlowcellProperty("serial"), laneNo, runId, sName, sId));
					  }
					}
				  });
				}
			  }});
		  }			
		  fcellRoot.addItem(laneItem);	
	   }
	 }
  }


/*t.addOpenHandler(new OpenHandler<TreeItem>()
{	
	@Override
	public void onOpen(OpenEvent<TreeItem> arg0) 
	{
		if(laneItem.getChildCount() > 0 && laneItem.getChildCount() <= 1)
		{
			String sampleID = flowcell.getLaneProperty(laneNo, "sampleID");
			String samp_name = flowcell.getLaneProperty(laneNo, "name");
			final String sampNames[] = samp_name.split("\\+");
			String sampId[] = sampleID.split("\\+");
			for(int i=0;i<sampId.length;i++)
			{
				final String sName = sampNames[i];
				final String sId = sampId[i];
				TreeItemClick sampleClick = new TreeItemClick("Library", sName);
				final TreeItem sampleItem = new TreeItem(sampleClick);
				sampleItem.addItem("");
				t.addOpenHandler(new OpenHandler<TreeItem>()
				{
					@Override
					public void onOpen(OpenEvent<TreeItem> arg0) 
					{
						if(sampleItem.getChildCount() > 0 && sampleItem.getChildCount() <=1)
						{
							remoteService.getQCSampleFlowcell(flowcell.getFlowcellProperty("serial"), sName, laneNo,new AsyncCallback<FlowcellData>()
							{
								public void onFailure(Throwable arg0) {
									arg0.getMessage();
								}
								public void onSuccess(FlowcellData QCGot) 
								{
									flowcell.laneQC = QCGot.laneQC;
									flowcell.filterAnalysis(flowcell.getFlowcellProperty("serial"), laneNo, sId);
									flowcell.filterQC(laneNo);
									
									if(flowcell.laneQC.isEmpty())
										sampleItem.addItem(new TreeItem(""));
									else
									{
										for(String runId : flowcell.laneQC.keySet())
										{
											TreeItemClick runClick = new TreeItemClick("Run", runId , "", "");
											TreeItem runItem = new TreeItem(runClick);	
											sampleItem.addItem(runItem);
											runItem.addItem(new QCReport(flowcell, flowcell.getFlowcellProperty("serial"), laneNo, runId, sName, sId));
										    runItem.addItem(new FilesDownload(flowcell, flowcell.getFlowcellProperty("serial"), laneNo, runId, sName, sId));
											//runItem.addItem(new QCPlots(sampGeneus, flowcellSerial, laneNo, runId));
										}
									}
								}
							});
						}
					}});
				laneItem.addItem(sampleItem);
			}		
		}		
	}
});*/
     		