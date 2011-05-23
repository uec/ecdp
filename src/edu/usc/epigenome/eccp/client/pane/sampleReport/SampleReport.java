package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.Tree;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.SampleData;
import edu.usc.epigenome.eccp.client.pane.ECPane;
import edu.usc.epigenome.eccp.client.pane.flowcellReport.SampleSingleItem;

public class SampleReport extends ECPane{

	private static SampleReportUiBinder uiBinder = GWT
			.create(SampleReportUiBinder.class);

	interface SampleReportUiBinder extends UiBinder<Widget, SampleReport> {
	}
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	@UiField FlowPanel mainPanel;
	@UiField FlowPanel searchPanel;
	@UiField HorizontalPanel searchOptionsPanel;
	@UiField FlowPanel vp;
	@UiField Button searchButton;
	
	public SampleReport() {
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
		AsyncCallback<ArrayList<SampleData>> DisplayFlowcellCallback = new AsyncCallback<ArrayList<SampleData>>()
	    {
			public void onFailure(Throwable caught)
			{
				vp.clear();	
				caught.printStackTrace();				
			}
			public void onSuccess(ArrayList<SampleData> result)
			{
				vp.clear();
				for(SampleData sampl : result)
				{
					SampleSingleReport flowcellItem = new SampleSingleReport(sampl);
					vp.add(flowcellItem);
				}
			}
	    };remoteService.getSampleFromGeneus(DisplayFlowcellCallback);
		
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
