package edu.usc.epigenome.eccp.client.pane.methylation;

import java.util.ArrayList;
import com.google.gwt.core.client.GWT;

import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.MethylationData;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.pane.ECPane;

public class MethylationReport extends ECPane {

	private static MethylationReportUiBinder uiBinder = GWT
			.create(MethylationReportUiBinder.class);

	interface MethylationReportUiBinder extends
			UiBinder<Widget, MethylationReport> {
	}
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	@UiField FlowPanel mainPanel;
	@UiField FlowPanel searchPanel;
	@UiField HorizontalPanel searchOptionsPanel;
	@UiField FlowPanel vp;
	@UiField Button searchButton;
	
	public MethylationReport() {
		
		initWidget(uiBinder.createAndBindUi(this));
		vp.add(new Image("images/progress.gif"));
		
		searchButton.addClickHandler(new ClickHandler() 
		{	
			public void onClick(ClickEvent event) 
			{
				if(searchPanel.getWidgetCount() > 1)
				{
					searchPanel.clear();
					//searchPanel.add(searchOptionsPanel);
				}
				vp.clear();
				vp.add(new Image("images/progress.gif"));
				showTool();
			}});
		
	}

		@Override
		public void showTool() 
		{
			AsyncCallback<ArrayList<MethylationData>> DisplayFlowcellCallback = new AsyncCallback<ArrayList<MethylationData>>()
			{
				public void onFailure(Throwable caught)
				{
					vp.clear();
					vp.add(new Label(caught.getMessage()));
					caught.printStackTrace();				
				}

				public void onSuccess(ArrayList<MethylationData> result)
				{
					vp.clear();
					for(MethylationData flowcell : result)
							{
						MethylationReportSingleItem flowcellItem = new MethylationReportSingleItem(flowcell);
								vp.add(flowcellItem);
							}
				}
			};	remoteService.getMethFromGeneus(DisplayFlowcellCallback);	
		
		}

	@Override
	public Image getToolLogo() {
		return null;
	}

	@Override
	public Label getToolTitle() {
		return null;
	}

	
	

}
