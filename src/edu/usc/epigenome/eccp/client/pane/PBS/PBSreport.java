package edu.usc.epigenome.eccp.client.pane.PBS;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.DecoratedPopupPanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.MenuBar;
import com.google.gwt.user.client.ui.MenuItem;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.pane.ECPane;

public class PBSreport extends ECPane {

	private static PBSreportUiBinder uiBinder = GWT
			.create(PBSreportUiBinder.class);

	interface PBSreportUiBinder extends UiBinder<Widget, PBSreport> {
	}
	
	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}
	
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);

	@UiField FlowPanel vp;
	@UiField MenuItem Refresh;
	@UiField HorizontalPanel jobCounts;
	@UiField FlexTable pbsTable;
	@UiField Label queuedCountLabel;
	@UiField Label runningCountLabel;
	@UiField Label heldCountLabel;
	
	String queue = "laird";
	int queuedCount = 0;
	int runningCount = 0;
	int heldCount = 0;
	
	public PBSreport() {
		initWidget(uiBinder.createAndBindUi(this));
	}
	
	public PBSreport(String queueIn)
	{
		queue = queueIn.substring(3);
		initWidget(uiBinder.createAndBindUi(this));
	}
	

	@Override
	public void showTool() 
	{
		Refresh.setCommand(new Command()
		{	
			public void execute() 
			{
				doPBS();
			}
		});
		doPBS();
	}
	
	public void doPBS()
	{
		queuedCount = 0;
		runningCount = 0;
		heldCount = 0;
		pbsTable.clear();
		
		remoteService.qstat(queue, new AsyncCallback<String[]>() 
		{
			public void onFailure(Throwable arg0) 
			{
				arg0.printStackTrace();
			}
			public void onSuccess(String[] result) 
			{
				for (int i = 0; i < result.length; i++)
				{
					final String[] line = result[i].split("\\^");
					for (int j = 0; j < line.length; j++)
					{
						final Label label = new Label(line[j]);
						if (i == 0)
							label.addStyleName(UserPanelResources.INSTANCE.userPanel().TitleHeader());
						 if (j == 1)
						{
							if (line[3].contains("r"))
							{
								label.addStyleName(UserPanelResources.INSTANCE.userPanel().Running());
								runningCount++;
							}
							else if (line[3].contains("qw"))
							{
								label.addStyleName(UserPanelResources.INSTANCE.userPanel().Queued());
								queuedCount++;
							}
							else if (line[3].contains("h"))
							{
								label.addStyleName(UserPanelResources.INSTANCE.userPanel().Hold());
								heldCount++;
							}
								else if (line[3].contains("e"))
								label.addStyleName(UserPanelResources.INSTANCE.userPanel().Error());
						} 
						else if(j==0)
						{
							label.addStyleName(UserPanelResources.INSTANCE.userPanel().Jobid());
						}
						else
							label.addStyleName(UserPanelResources.INSTANCE.userPanel().Normal());
						 
						 if(i>0 && j==0)
						 {
							label.addClickHandler(new ClickHandler()
							{
								public void onClick(ClickEvent event)
								{
									DecoratedPopupPanel p = new DecoratedPopupPanel(true);
									FlexTable details = new FlexTable();
									details.setWidget(0, 0, new Label("Submit Args"));
									details.setWidget(0, 1, new Label(line[6]));
									details.setWidget(1, 0, new Label("CPU Time"));
									details.setWidget(1, 1, new Label(line[7]));
									details.setWidget(2, 0, new Label("Memory"));
									details.setWidget(2, 1, new Label(line[8]));
									details.setWidget(3, 0, new Label("Wall Time"));
									details.setWidget(3, 1, new Label(line[9]));
									details.setWidget(4, 0, new Label("Nodes used"));
									details.setWidget(4, 1, new Label(line[10]));
									details.setWidget(5, 0, new Label("Output Path"));
									details.setWidget(5, 1, new Label(line[11]));
									p.add(details);
									p.setPopupPosition(label.getAbsoluteLeft() + 80, label.getAbsoluteTop());
									p.show();			
								}});							
							}
							if(j<6)
								pbsTable.setWidget(i, j, label);
						}
					}
					queuedCountLabel.setText( "- " + queuedCount + " jobs queued ");
					runningCountLabel.setText(" " + runningCount + " jobs running - ");
					heldCountLabel.setText("- " + heldCount + " jobs held ");
			}});
	}

	@Override
	public Image getToolLogo() 
	{
		return null;
	}

	@Override
	public Label getToolTitle() 
	{
		return null;
	}

	

}
