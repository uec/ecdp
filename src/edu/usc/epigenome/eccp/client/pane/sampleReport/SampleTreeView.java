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
		TreeItem sampleRoot = new TreeItem(sampleCellItem);
		t.addItem(sampleRoot);
		
		for(final String flowcellSerial : sampGeneus.flowcellInfo.keySet())
		{
			final TreeItemClick cellItem = new TreeItemClick("Flowcell ID", flowcellSerial, "Technician", sampGeneus.flowcellInfo.get(flowcellSerial).get("technician"));
			final TreeItem flowcellItem = new TreeItem(cellItem);

			t.addOpenHandler(new OpenHandler<TreeItem>() 
			{	
				@Override
				public void onOpen(OpenEvent<TreeItem> event) 
				{
					TreeItem item = event.getTarget();
					if(item.getText().contains("Flowcell"))
					{
						flowcellItem.removeItems();
						remoteService.getLaneFlowcellSample(sampGeneus.getSampleProperty("library"), flowcellSerial, new AsyncCallback<SampleData>()
						{
							public void onSuccess(SampleData result) 
							{
								if(result.flowcellLane.isEmpty())
								{
									TreeItem laneItem = new TreeItem("");
									flowcellItem.addItem(laneItem);
								}
								else
								{
									for(Integer laneNo : result.flowcellLane.keySet())
									{
										TreeItemClick laneClick = new TreeItemClick("Lane No", laneNo.toString(), "Processing", result.flowcellLane.get(laneNo).get("processing"));
										TreeItem laneItem = new TreeItem(laneClick);
										laneItem.addItem(new QCReport(sampGeneus, flowcellSerial, laneNo));
										laneItem.addItem(new FilesDownload(sampGeneus, flowcellSerial, laneNo));
										laneItem.addItem(new QCPlots(sampGeneus, flowcellSerial, laneNo));
										flowcellItem.addItem(laneItem);		
									}
								}
							}
							public void onFailure(Throwable arg0) 
							{}			
					 });
				}
			}});
			sampleRoot.addItem(flowcellItem);
			flowcellItem.addItem("");
		}
	}
}
