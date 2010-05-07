package edu.usc.epigenome.eccp.client.pane.PBS;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.DecoratedPopupPanel;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.MenuBar;
import com.google.gwt.user.client.ui.VerticalPanel;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.pane.ECPane;

public class PBSreport extends ECPane
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	final VerticalPanel vp = new VerticalPanel();
	VerticalPanel vPanel = new VerticalPanel();
	HorizontalPanel jobCounts = new HorizontalPanel();
	FlexTable pbsTable = new FlexTable();
	final DecoratedPopupPanel loadingGraphic = new DecoratedPopupPanel(false);
	final Image loadingGraphicImg = new Image("images/progress.gif");
	MenuBar menu = new MenuBar();
	String queue = "laird";
	int queuedCount = 0;
	int runningCount = 0;
	int heldCount = 0;
	Label queuedCountLabel = new Label(" 0 jobs queued ");
	Label runningCountLabel = new Label(" 0 jobs running ");
	Label heldCountLabel = new Label(" 0 jobs held ");
	
	
	public PBSreport(String queueIn)
	{
		queue = queueIn;
		vp.add(new Label("Loading"));
		initWidget(vp);	
	}
	@Override
	public Image getToolLogo()
	{
		return new Image("images/pbs.png");
	}

	@Override
	public Label getToolTitle()
	{
		return new Label("PBS Jobs: " + queue);
	}

	@Override
	public void showTool()
	{
		vp.clear();
		vPanel.setWidth("100%");
		vPanel.addStyleName("pbs");
		vp.add(vPanel);
		menu.addItem("Refresh", new Command()
		{
			public void execute()
			{
				doPBS();				
			}
		});
		vPanel.add(menu);
		//vPanel.setWidth("600");
		jobCounts.add(runningCountLabel);
		jobCounts.add(new Label(" - "));
		jobCounts.add(heldCountLabel);
		jobCounts.add(new Label(" - "));
		jobCounts.add(queuedCountLabel);
		vPanel.add(jobCounts);
		vPanel.add(pbsTable);
		loadingGraphic.add(loadingGraphicImg);
		pbsTable.addStyleName("Lane-Table");
		doPBS();
	}
	public void doPBS()
	{
		queuedCount = 0;
		runningCount = 0;
		heldCount = 0;
		loadingGraphic.center();
		pbsTable.clear();
		remoteService.qstat(queue, new AsyncCallback<String[]>()
		{

			public void onFailure(Throwable caught)
			{

				caught.printStackTrace();
				loadingGraphic.hide();
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
							label.addStyleName("Title-Header");
						else if (j == 1)
						{
							if (line[3].contains("r"))
							{
								label.addStyleName("Running");
								runningCount++;
							}
							else if (line[3].contains("qw"))
							{
								label.addStyleName("Queued");
								queuedCount++;
							}
							else if (line[3].contains("h"))
							{
								label.addStyleName("Hold");
								heldCount++;
							}
								else if (line[3].contains("e"))
								label.addStyleName("Error");
						} 
						else if(j==0)
						{
							label.addStyleName("Jobid");
						}
						else
							label.addStyleName("Normal");

						if(i>0 && j==0)
						{
							label.addClickHandler(new ClickHandler(){

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
				loadingGraphic.hide();
				queuedCountLabel.setText("- " + queuedCount + " jobs queued ");
				runningCountLabel.setText(" " + runningCount + " jobs running -");
				heldCountLabel.setText("- " + heldCount + " jobs held -");
				
			}
		});

	}


}
