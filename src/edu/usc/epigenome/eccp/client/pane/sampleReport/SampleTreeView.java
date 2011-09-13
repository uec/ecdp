package edu.usc.epigenome.eccp.client.pane.sampleReport;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.InsertPanel.ForIsWidget;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Tree;
import com.google.gwt.user.client.ui.TreeItem;
import com.google.gwt.user.client.ui.TreeListener;
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
		
		//Tree t = new Tree();
		TreeItemClick sampleCellItem = new TreeItemClick("Library", sampGeneus.getSampleProperty("library"), "Project", sampGeneus.getSampleProperty("project"));
		final TreeItem sampleRoot = new TreeItem(sampleCellItem);
		t.addItem(sampleRoot);
		sampleRoot.addItem("");
		
		t.addOpenHandler(new OpenHandler<TreeItem>() 
		{
		 @Override
		 public void onOpen(OpenEvent<TreeItem> event)
		 {
		   TreeItem libName = event.getTarget();
		   if(libName.getText().contains("Library"))
		   {
			 sampleRoot.removeItems();
			 remoteService.getFlowcellsforSample(sampGeneus.getSampleProperty("library"), new AsyncCallback<SampleData>() 
			 {
			   public void onSuccess(SampleData sData)
			   {
				 sampGeneus.sampleFlowcells = sData.sampleFlowcells;
				 if(sData.sampleFlowcells.isEmpty())
				 {
				   TreeItem flowcellItem = new TreeItem("");
				   sampleRoot.addItem(flowcellItem);
				 }
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
					   TreeItem item = event.getTarget();
					   if(item.getText().contains("Flowcell"))
					   {
						//if(item.getChildCount()<=sampGeneus.sampleFlowcells.keySet().size())
						flowcellItem.removeItems();
						remoteService.getLaneFlowcellSample(sampGeneus.getSampleProperty("library"), flowcellSerial, new AsyncCallback<FlowcellData>()
						{
						  public void onSuccess(FlowcellData result) 
						  {
							sampGeneus.sampleFlowcells.get(flowcellSerial).lane = result.lane;
							if(result.lane.isEmpty())
							{
							  TreeItem laneItem = new TreeItem("");
							  flowcellItem.addItem(laneItem);
							}
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
								  TreeItem innerItem = innerEvent.getTarget();
								  if(innerItem.getText().contains("Lane"))
								  {
								   String str = innerItem.getText().substring(9, 10);
								   //final int i = Integer.parseInt(str);
								   //laneItem.removeItems();
								   remoteService.getQCSampleFlowcell(flowcellSerial, sampGeneus.getSampleProperty("library"), new AsyncCallback<FlowcellData>()
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
									  {
										TreeItem runItem = new TreeItem("");
										laneItem.addItem(runItem);
									  }
									  else
									  {
									    for(String runId : sampGeneus.sampleFlowcells.get(flowcellSerial).laneQC.keySet())
										{
										  TreeItemClick runClick = new TreeItemClick("Run", runId , "", "");
										  TreeItem runItem = new TreeItem(runClick);		 
										  laneItem.addItem(runItem);
										  runItem.addItem(new QCReport(sampGeneus, flowcellSerial, laneNo, runId));
										  runItem.addItem(new FilesDownload(sampGeneus, flowcellSerial, laneNo, runId));
										  runItem.addItem(new QCPlots(sampGeneus, flowcellSerial, laneNo, runId));
										}
									 }	
								 }});
								 }
							  }});
							  flowcellItem.addItem(laneItem);		
							}
						  }
						}
						public void onFailure(Throwable arg0) 
						{
						 arg0.printStackTrace();
						}			
				     });
				   }
			    }});
				sampleRoot.addItem(flowcellItem);
				}
			}
		}
		public void onFailure(Throwable arg1)
		{
		  arg1.printStackTrace();
		}
	 });
	}
	}});
 }
}
