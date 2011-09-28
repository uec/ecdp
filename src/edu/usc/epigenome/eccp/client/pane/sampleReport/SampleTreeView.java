package edu.usc.epigenome.eccp.client.pane.sampleReport;

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
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.pane.composites.TreeItemClick;

public class SampleTreeView extends Composite
{
	private static SampleTreeViewUiBinder uiBinder = GWT
			.create(SampleTreeViewUiBinder.class);

	interface SampleTreeViewUiBinder extends UiBinder<Widget, SampleTreeView> {
	}
	
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);

	//@UiField FlowPanel vp;
	@UiField Tree t;
	//@UiField TreeItem sampleRoot;
	
	SampleData sampGeneus;
	
	public SampleTreeView() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	public SampleTreeView(final SampleData sampleIn)
	{
		sampGeneus = sampleIn;
		initWidget(uiBinder.createAndBindUi(this));
		
		TreeItemClick sampleCellItem = new TreeItemClick("Library", sampGeneus.getSampleProperty("library"), "Project", sampGeneus.getSampleProperty("project"));
		final TreeItem sampleRoot = new TreeItem(sampleCellItem);
		t.addItem(sampleRoot);
		sampleRoot.addItem("");
		
		t.addOpenHandler(new OpenHandler<TreeItem>() 
		{
		 @Override
		 public void onOpen(OpenEvent<TreeItem> event)
		 {
			if(sampleRoot.getChildCount() > 0 && sampleRoot.getChildCount()<=1)
			{
			   remoteService.getFlowcellsforSample(sampGeneus.getSampleProperty("library"), new AsyncCallback<SampleData>() 
			   {
				 public void onFailure(Throwable arg1)
				 {
					arg1.printStackTrace();
				 }
				public void onSuccess(SampleData sData)
				{
				  sampGeneus.sampleFlowcells = sData.sampleFlowcells;
				  if(sData.sampleFlowcells.isEmpty())
					sampleRoot.addItem(new TreeItem(""));
				 else
				 {
				   for(final String flowcellSerial : sampGeneus.sampleFlowcells.keySet())
				   {
					final TreeItemClick cellItem = new TreeItemClick("Flowcell ID", flowcellSerial, "Technician", sampGeneus.sampleFlowcells.get(flowcellSerial).flowcellProperties.get("technician"));
					final TreeItem flowcellItem = new TreeItem(cellItem);
					flowcellItem.addItem("");
								 
				   t.addOpenHandler(new OpenHandler<TreeItem>() 
				   {	
					@Override
					public void onOpen(OpenEvent<TreeItem> event) 
					{
						if(flowcellItem.getChildCount() > 0 && flowcellItem.getChildCount() <=1)
						{
						  remoteService.getLaneFlowcellSample(sampGeneus.getSampleProperty("library"), flowcellSerial, new AsyncCallback<FlowcellData>()
						  {
							public void onFailure(Throwable arg1)
							{
							  arg1.printStackTrace();
							}
						   public void onSuccess(FlowcellData result) 
						   {
							 sampGeneus.sampleFlowcells.get(flowcellSerial).lane = result.lane;
							 if(result.lane.isEmpty())
							 flowcellItem.addItem(new TreeItem(""));
							 else
							 {
							   for(final Integer laneNo : result.lane.keySet())
							   {
		   					     TreeItemClick laneClick = new TreeItemClick("Lane No", laneNo.toString(), "Processing", sampGeneus.sampleFlowcells.get(flowcellSerial).lane.get(laneNo).get("processing"));
			  				     final TreeItem laneItem = new TreeItem(laneClick);
			  				     laneItem.addItem("");
			  				     t.addOpenHandler(new OpenHandler<TreeItem>()
								 {
								  @Override
								   public void onOpen(OpenEvent<TreeItem> innerEvent) 
								   {
									  if(laneItem.getChildCount() > 0 && laneItem.getChildCount() <=1)
									  {
										  remoteService.getQCSampleFlowcell(flowcellSerial, sampGeneus.getSampleProperty("library"), laneNo, new AsyncCallback<FlowcellData>()
										  {
											public void onFailure(Throwable caught) {
											  caught.printStackTrace();
											}
											public void onSuccess(FlowcellData QCGot) 
											{
											  sampGeneus.sampleFlowcells.get(flowcellSerial).laneQC = QCGot.laneQC;
											  sampGeneus.sampleFlowcells.get(flowcellSerial).filterAnalysis(flowcellSerial, laneNo, sampGeneus.getSampleProperty("geneusID_sample"));
											  sampGeneus.sampleFlowcells.get(flowcellSerial).filterQC(laneNo);
																			
											  if(sampGeneus.sampleFlowcells.get(flowcellSerial).laneQC.isEmpty())
												  laneItem.addItem(new TreeItem(""));
											  else
											  {
												for(String runId : sampGeneus.sampleFlowcells.get(flowcellSerial).laneQC.keySet())
												{
												  TreeItemClick runClick = new TreeItemClick("Run", runId);
												  TreeItem runItem = new TreeItem(runClick);	
												  laneItem.addItem(runItem);
												  //Window.alert("Now the flowcell is " + sampGeneus.sampleFlowcells.get(flowcellSerial).laneQC.toString());
												  runItem.addItem(new QCReport(sampGeneus.sampleFlowcells.get(flowcellSerial), flowcellSerial, laneNo, runId, sampGeneus.getSampleProperty("library"), sampGeneus.getSampleProperty("geneusID_sample")));
												  runItem.addItem(new FilesDownload(sampGeneus.sampleFlowcells.get(flowcellSerial), flowcellSerial, laneNo, runId, sampGeneus.getSampleProperty("library"), sampGeneus.getSampleProperty("geneusID_sample")));
												  runItem.addItem(new QCPlots(sampGeneus, flowcellSerial, laneNo, runId));
												}
											  }
											}}); //End remoteService call for getting analysis_id (getQCSampleFlowcell)
									    }//End if child count for laneItem
									  }});//End open Handler for the laneItem
			  				     	flowcellItem.addItem(laneItem);
								 }//End for (adding each lane)
							   }
							 }});//End remoteService call for getting laneItem information(getLaneFlowcellSample)
			  			  }//End if child count for flowcellItem				
					   }});//End open Handler for flowcellItem
				   	  sampleRoot.addItem(flowcellItem);
				}//End for adding each flowcell
			  }
		 }});//End remoteService call for getting flowcells for sample(getFlowcellsforSample) 
		}
	  }});//End open handler for sampleItem
    }
	
	public void sampPrint()
	{
		
	}
}
