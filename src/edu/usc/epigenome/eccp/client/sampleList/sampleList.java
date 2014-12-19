package edu.usc.epigenome.eccp.client.sampleList;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyDownHandler;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.safehtml.shared.SafeHtml;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.text.shared.AbstractSafeHtmlRenderer;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiConstructor;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.cell.core.client.SimpleSafeHtmlCell;
import com.sencha.gxt.core.client.util.Margins;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.SortDir;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.data.shared.Store.StoreSortInfo;
import com.sencha.gxt.dnd.core.client.DndDropEvent;
import com.sencha.gxt.dnd.core.client.DropTarget;
import com.sencha.gxt.dnd.core.client.GridDragSource;
import com.sencha.gxt.dnd.core.client.DND.Operation;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.Dialog;
import com.sencha.gxt.widget.core.client.Dialog.PredefinedButton;
import com.sencha.gxt.widget.core.client.box.MessageBox;
import com.sencha.gxt.widget.core.client.button.TextButton;
import com.sencha.gxt.widget.core.client.container.BorderLayoutContainer;
import com.sencha.gxt.widget.core.client.container.HasLayout;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.container.BorderLayoutContainer.BorderLayoutData;
import com.sencha.gxt.widget.core.client.event.HideEvent;
import com.sencha.gxt.widget.core.client.event.HideEvent.HideHandler;
import com.sencha.gxt.widget.core.client.event.RowDoubleClickEvent;
import com.sencha.gxt.widget.core.client.event.RowDoubleClickEvent.RowDoubleClickHandler;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.event.SelectEvent.SelectHandler;
import com.sencha.gxt.widget.core.client.event.TriggerClickEvent;
import com.sencha.gxt.widget.core.client.event.TriggerClickEvent.TriggerClickHandler;
import com.sencha.gxt.widget.core.client.form.StoreFilterField;
import com.sencha.gxt.widget.core.client.form.TextArea;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.ColumnModel;
import com.sencha.gxt.widget.core.client.grid.Grid;
import com.sencha.gxt.widget.core.client.info.DefaultInfoConfig;
import com.sencha.gxt.widget.core.client.info.Info;
import com.sencha.gxt.widget.core.client.menu.Item;
import com.sencha.gxt.widget.core.client.menu.Menu;
import com.sencha.gxt.widget.core.client.menu.MenuItem;
import com.sencha.gxt.widget.core.client.tips.QuickTip;
import com.sencha.gxt.widget.core.client.toolbar.ToolBar;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataModelFactory;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.events.ECCPEventBus;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEvent;
import edu.usc.epigenome.eccp.client.sampleReport.DownloadGridWidget;
import edu.usc.epigenome.eccp.client.sampleReport.MetricGridWidget;
import edu.usc.epigenome.eccp.client.sencha.ResizeGroupingView;



public class sampleList extends Composite implements HasLayout
{

	private static sampleListUiBinder uiBinder = GWT.create(sampleListUiBinder.class);
	interface sampleListUiBinder extends UiBinder<Widget, sampleList>{}

	
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);

	@UiField ContentPanel gridPanel;
	@UiField VerticalLayoutContainer content;
	@UiField VerticalLayoutContainer vlc;
	@UiField TextButton share;
	@UiField TextButton analyze;
	@UiField ToolBar toolbar;
	TextButton userManual = new TextButton("HELP");
		
	ResizeGroupingView<LibraryData> view = new ResizeGroupingView<LibraryData>();
	StoreFilterField<LibraryData> filter = new StoreFilterField<LibraryData>() {
		@Override
		protected boolean doSelect(Store<LibraryData> store, LibraryData parent,LibraryData item, String filter) {	
			    return 
						item.get("project").getValue().toLowerCase().contains(filter.toLowerCase()) || 
						item.get("sample_name").getValue().toLowerCase().contains(filter.toLowerCase()) ||  
						item.get("flowcell_serial").getValue().toLowerCase().contains(filter.toLowerCase()) ||  
						item.get("analysis_id").getValue().toLowerCase().contains(filter.toLowerCase()) ||
						item.get("geneusID_sample").getValue().toLowerCase().contains(filter.toLowerCase());
					
		}
		
	};
	String mode = "user";
	ColumnModel<LibraryData> columnModel;
	ColumnConfig<LibraryData, String> flowcellCol,libCol,runCol,laneCol,projCol,dateCol,geneusCol,libTypeCol;
	ListStore<LibraryData> store;
	ArrayList<LibraryData> completeData= new ArrayList<LibraryData>();
	Grid<LibraryData> grid;
	StoreSortInfo<LibraryData> sortByDate;
	MenuItem menuItem;
	Comparator<String>  dateComparator;

	@UiConstructor
	public sampleList() 
	{
		initWidget(uiBinder.createAndBindUi(this));
	    createGrid();
	  //  setUserManualLink();
	    setUserManualButton();
	    gridPanel.addTool(filter);	   
	    filter.setEmptyText("Search...");
	    //hide share button when already in a shared search 
	    if(Window.Location.getQueryString().length() > 0 || Window.Location.getHref().contains("ecdp-demo") ) {
	    	    toolbar.remove(share);
	    	    analyze.disable();
	    }

	    filter.addKeyDownHandler(new KeyDownHandler(){

			@Override
			public void onKeyDown(KeyDownEvent event) {
				
		        if (event.getNativeKeyCode() == KeyCodes.KEY_ENTER) {
		        	//System.out.println("Here in key down");
		        	
		        	String text = filter.getText().toLowerCase();
		        	List<LibraryData> tmp = new ArrayList<LibraryData>();
		        	for (LibraryData item : completeData) 
		        	{
		        		try 
		        		{
		        			if (item.get("project").getValue().toLowerCase().contains(text) || 
		        					item.get("sample_name").getValue().toLowerCase().contains(text) ||  
		        					item.get("flowcell_serial").getValue().toLowerCase().contains(text) ||  
		        					item.get("analysis_id").getValue().toLowerCase().contains(text) ||
		        					item.get("geneusID_sample").getValue().toLowerCase().contains(text) ||
		        					item.get("processing_formatted").getValue().toLowerCase().contains(text))
		        				tmp.add(item);
		        		} 
		        		catch (Exception e) 
		        		{
		        			logToServer("Search:" +text+ " is throwing a NULL exception, because some of the attributes are null: " + item.toString());
		        		}
		        	}

		        	store.replaceAll(tmp);
		        	tmp.clear();
		        	logToServer("Search:"+text); 
		        }	
			}	    	
	    });
	    filter.addTriggerClickHandler(new TriggerClickHandler(){

			@Override
			public void onTriggerClick(TriggerClickEvent event) {
				store.replaceAll(completeData);
				filter.setEmptyText("Search...");
			//	System.out.println("Reset clicked");
				logToServer("SearchReset"); 
			}
	    	
	    });
	    if(Window.Location.getQueryString().contains("GODMODE") && !Window.Location.getHref().contains("ecdp-demo"))
	    	godmode();
	    
	}
	
	public void createGrid() {
		
		//SET UP COLUMNS
		 List<ColumnConfig<LibraryData, ?>> columnDefs = new ArrayList<ColumnConfig<LibraryData, ?>>();
		 flowcellCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("flowcell_serial"), 90, "Flowcell");
		
		 libCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("sample_name"), 120, "Library");
		 
		 runCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("status"), 100, "Status");

		 laneCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("lane"), 30, "Lane");
		 libTypeCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("processing_formatted"), 30, "LibType");		
		 libTypeCol.setWidth(80);
		 geneusCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("geneusID_sample"), 80, "LIMS id");
		 projCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("project"), 120, "Project");
		 dateCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("Date_Sequenced_formatted"), 80, "Date");
		 dateComparator = new Comparator<String>(){

			public int compare(String o1, String o2) {
				String d = "No Date Entered";
				if (o1.matches(d)) 
					if (o2.matches(d)) return 0;
					else return -1;
				else if (o2.matches(d)) return 1;
				     else return (o1.compareTo(o2));
				
			}
			 
		 };
		 dateCol.setComparator(dateComparator);
		 columnDefs.add(projCol);
		 columnDefs.add(libCol);
		 columnDefs.add(libTypeCol);
		 columnDefs.add(geneusCol);
		 columnDefs.add(flowcellCol);
		 columnDefs.add(laneCol);
		 columnDefs.add(dateCol);
		 columnDefs.add(runCol);
		 	 
		 
         columnModel = new ColumnModel<LibraryData>(columnDefs);
		 store = new ListStore<LibraryData>(LibraryDataModelFactory.getModelKeyProvider());
		 view = new ResizeGroupingView<LibraryData>();
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 view.setForceFit(true);
		 view.groupBy(dateCol);
		 		 
		 grid = new Grid<LibraryData>(store, columnModel);
		 new QuickTip(grid);
		 grid.setView(view);
		 
		 new GridDragSource<LibraryData>(grid);		
		 
		 grid.addRowDoubleClickHandler(new RowDoubleClickHandler()
		 {
			@Override
			
			public void onRowDoubleClick(RowDoubleClickEvent event)
			{
				// final Boolean b = event.getEvent().getShiftKey();
				    
				 LibraryData summarizedLibrary = store.get(event.getRowIndex());
				 LibraryDataQuery query = new LibraryDataQuery();
				 query.setIsSummaryOnly(false);
				 query.setGetFiles(true);
				 query.setDBid(summarizedLibrary.get("id_run_sample").getValue());
				
				 myServer.getLibraries(query, new AsyncCallback<ArrayList<LibraryData>>(){
						@Override
						public void onFailure(Throwable caught)
						{							
							Info.display("Error","Failed to get Library");					    
						}

						@Override
						public void onSuccess(ArrayList<LibraryData> result)
						{
							if(result.size() > 0)
							{
								        MetricGridWidget metric = new MetricGridWidget(result);
								        logToServer("Double-Click: " +  result.get(0).get("flowcell_serial").getValue() + ":" + result.get(0).get("geneusID_sample").getValue());
								        ECCPEventBus.EVENT_BUS.fireEvent(new ShowGlobalTabEvent(metric,result.get(0).get("sample_name").getValue()));
						    }
							else {
							//	Info.display("Error_1","Failed to get Library");
							      MessageBox box = new MessageBox("Database was updated", "");
					              box.setPredefinedButtons(PredefinedButton.YES, PredefinedButton.CANCEL);
					              box.setIcon(MessageBox.ICONS.question());
					              box.setMessage("Would you like to reload the data?");
					              box.addHideHandler(new HideHandler() {
					 
					              @Override
					                 public void onHide(HideEvent event) {
					                   Dialog btn = (Dialog) event.getSource();
					                   //String msg = Format.substitute("The '{0}' button was pressed", btn.getHideButton().getText());					          
					                   if (btn.getHideButton().getText().equals("Yes")) {
					            	  // Info.display("MessageBox", msg);
					                	   Window.Location.reload();
					                   }
					                 }
					              });
					             box.show();
				   }}});
			}
			
		});
         
         contextMenu();
		// filter.bind(store);
		 content.add(grid);
		 LibraryDataQuery query = new LibraryDataQuery();
		 query.setIsSummaryOnly(true);
		 query.setGetFiles(false);
		 myServer.getLibraries(query, new AsyncCallback<ArrayList<LibraryData>>(){

			@Override
			public void onFailure(Throwable caught)
			{
				Info.display("Error","Failed to get Library List");
				
			}

			@Override
			public void onSuccess(ArrayList<LibraryData> result)
			{
				if(result.size() < 1)
					Info.display("Security Error","Access denied. Check your links or contact the Epigenome Center");
				completeData = result;
				ArrayList<LibraryData> partialData = new ArrayList<LibraryData>();
				for(int i = 0; i < 1200 && i < result.size(); i++)
					partialData.add(result.get(i));
				populateGrid(partialData);
				Info info = new Info();
				info.setPosition(100,100); // setting the position doesn't work
				if(result.size() > 1200)
					info.show(new DefaultInfoConfig("Notice", "1200 of " + result.size() + "  records are displayed, use search box to see all"));
				
			}});
		 // Add sorting by date column to the grid
         sortByDate = new StoreSortInfo<LibraryData>(dateCol.getValueProvider(), dateCol.getComparator(), SortDir.DESC);
         grid.getStore().addSortInfo(sortByDate);

	}
	
	public void getContextData(final LibraryData library) {
		 LibraryDataQuery query = new LibraryDataQuery();
		 query.setIsSummaryOnly(false);
		 query.setGetFiles(true);
		 query.setDBid(library.get("id_run_sample").getValue());
		 myServer.getLibraries(query, new AsyncCallback<ArrayList<LibraryData>>(){
				@Override
				public void onFailure(Throwable caught)
				{
					Info.display("Error","Failed to get Library");
				}

				@Override
				public void onSuccess(ArrayList<LibraryData> result)
				{
					if(result.size() > 0)
					{
						        if (menuItem.getText().equals("QC window")) {
						            MetricGridWidget metric = new MetricGridWidget(result);					            
						            ECCPEventBus.EVENT_BUS.fireEvent(new ShowGlobalTabEvent(metric,result.get(0).get("sample_name").getValue()));
						         }
						        if (menuItem.getText().equals("Download Files")) {
						            DownloadGridWidget download = new DownloadGridWidget(result.get(0).getFiles());
								    ECCPEventBus.EVENT_BUS.fireEvent(new ShowGlobalTabEvent(download,"files: " +  result.get(0).get("sample_name").getValue()));
							    }
						        if (menuItem.getText().equals("QC metrics to spreadsheet")) {
						            MetricGridWidget metric = new MetricGridWidget(result);
						            metric.setUsageMode("admin");
						            metric.showCSV(new SelectEvent());						            						      
						         }
						        
				    }
					else {
			//			Info.display("Error","Failed to get Library");
				      MessageBox box = new MessageBox("Database was updated", "");
		              box.setPredefinedButtons(PredefinedButton.YES, PredefinedButton.CANCEL);
		              box.setIcon(MessageBox.ICONS.question());
		              box.setMessage("Would you like to reload the data?");
		              box.addHideHandler(new HideHandler() {
		 
		              @Override
		                 public void onHide(HideEvent event) {
		                   Dialog btn = (Dialog) event.getSource();					          
		                   if (btn.getHideButton().getText().equals("Yes")) {
		                	   Window.Location.reload();
		                   }
		                 }
		              });
		             box.show();
					    
				}}});		   
	}
	
	public void contextMenu() {
		     Menu contextMenu= new Menu();
	         final MenuItem openQCGrid = new MenuItem();
	         openQCGrid.setText("QC window");
	         contextMenu.add(openQCGrid);
	         grid.setContextMenu(contextMenu);
	         openQCGrid.addSelectionHandler(new SelectionHandler<Item>(){

				@Override
				public void onSelection(SelectionEvent<Item> event) {					
				//	Info.display("Info","Open QC window clicked");
					LibraryData library = grid.getSelectionModel().getSelectedItem();
					menuItem = openQCGrid;
					logToServer("View Metrics Context click: " +  library.get("flowcell_serial").getValue() + ":" + library.get("geneusID_sample").getValue());
					getContextData(library);
											 					
				}});
	         final MenuItem openDownloadFiles = new MenuItem();
	         openDownloadFiles.setText("Download Files");
	         contextMenu.add(openDownloadFiles);
	         openDownloadFiles.addSelectionHandler(new SelectionHandler<Item>(){

					@Override
					public void onSelection(SelectionEvent<Item> event) {						
					//	Info.display("Info","Download Files window clicked");
						LibraryData library = grid.getSelectionModel().getSelectedItem();
						menuItem = openDownloadFiles;
						logToServer("Download Files Context click: " +  library.get("flowcell_serial").getValue() + ":" + library.get("geneusID_sample").getValue());
						getContextData(library);
												 					
					}});
	         final MenuItem spreadSheet = new MenuItem();
	         spreadSheet.setText("QC metrics to spreadsheet");
	         contextMenu.add(spreadSheet);
	         spreadSheet.addSelectionHandler(new SelectionHandler<Item>(){

					@Override
					public void onSelection(SelectionEvent<Item> event) {
						LibraryData library = grid.getSelectionModel().getSelectedItem();
						menuItem = spreadSheet;
						logToServer("To-Spreadsheet Context click: " +  library.get("flowcell_serial").getValue() + ":" + library.get("geneusID_sample").getValue());
						getContextData(library);
												 					
					}});
	         final MenuItem illuminaParam = new MenuItem();
		     illuminaParam.setText("Get Illumina parameters");
	         contextMenu.add(illuminaParam);
	         illuminaParam.addSelectionHandler(new SelectionHandler<Item>(){

					@Override
					public void onSelection(SelectionEvent<Item> event) {
						LibraryData library = grid.getSelectionModel().getSelectedItem();
						String flowcell=library.get("flowcell_serial").getValue();

						menuItem = illuminaParam;
						
						myServer.getIlluminaParams(flowcell, new AsyncCallback<String>(){

							@Override
							public void onFailure(Throwable caught) {
								Info.display("Error","Failed to get Illumina parameters");									
							}
							@Override
							public void onSuccess(String result) {
								showParamDialog(result, "Illumina parameters");								
							}							
						});												 					
					}});
	        
	         final MenuItem workflowParam = new MenuItem();
	         workflowParam.setText("Get workflow parameters");
	         contextMenu.add(workflowParam);
	         workflowParam.addSelectionHandler(new SelectionHandler<Item>(){

					@Override
					public void onSelection(SelectionEvent<Item> event) {
						LibraryData library = grid.getSelectionModel().getSelectedItem();
						menuItem = workflowParam;
						String flowcell=library.get("flowcell_serial").getValue();
						myServer.getWorkflowParams(flowcell, new AsyncCallback<String>(){

							@Override
							public void onFailure(Throwable caught) {
								Info.display("Error","Failed to get workflow parameters");									
							}
							@Override
							public void onSuccess(String result) {
								showParamDialog(result, "Workflow parameters");								
							}							
						});												 					
					}});
	         // hide parameter files from regular users
	         if(Window.Location.getQueryString().length() > 0 ) {
	        	 workflowParam.hide();
	        	 illuminaParam.hide();
	         }     
	}
	public void showParamDialog(String textToDisplay, String heading){
		 Dialog paramWindow = new Dialog();
		 paramWindow.setHeadingText(heading);
		 paramWindow.setPredefinedButtons(PredefinedButton.OK);
		 paramWindow.setBodyStyleName("pad-text");
		 TextArea text = new TextArea();
		 text.setText(textToDisplay);
		 paramWindow.add(text);
		 paramWindow.setHideOnButtonClick(true);
		 paramWindow.setWidth(700);
		 paramWindow.setHeight(500);
		 paramWindow.show();
	}
	
	public void populateGrid(ArrayList<LibraryData> thisdata)
	{
		store.replaceAll(thisdata);
		view.collapseAllGroups();
	//	Info.display("Notice", "Library List Loaded");		
		
	}
	
	public void godmode()
	{
		 final TextArea text = new TextArea();
		 final Dialog simple = new Dialog();
		 simple.setHeadingText("SELECT * from view_run_metric WHERE");
		 simple.setPredefinedButtons(PredefinedButton.OK);
		 simple.setBodyStyleName("pad-text");
		 simple.add(text);
		 simple.setHideOnButtonClick(true);
		 simple.setWidth(600);
		 simple.setHeight(200);
		 simple.show();
		 
		 TextButton ok = simple.getButtonById(PredefinedButton.OK.name());
		 final ArrayList<Boolean> showOnce= new ArrayList<Boolean>();
		 ok.addSelectHandler(new SelectHandler(){
			@Override
			public void onSelect(SelectEvent event)
			{
				myServer.getEncryptedData(text.getText(), new AsyncCallback<ArrayList<String>>(){
					@Override
					public void onFailure(Throwable caught)
					{	
						caught.printStackTrace();
					}
					@Override
					public void onSuccess(ArrayList<String> result)
					{
						text.setText("/gareports/ECControlCenter.html?superquery=" + result.get(0)); 
						simple.setHeadingText("Your query is available at the following link");
						if(showOnce.size() < 1)
							simple.show();
						showOnce.add(true);
					
					}});
				
			}});
		 
		 
	}
	
	public void setHeadingText(String title)
	{
		gridPanel.setHeadingText(title);
	}
	
	@UiHandler("byFlowcell")
	public void groupByF(SelectEvent event)
	{

		view.groupBy(flowcellCol);
		view.collapseAllGroups();

	}
	
	@UiHandler("byLibrary")
	public void groupByL(SelectEvent event)
	{
		view.groupBy(libCol);
		view.collapseAllGroups();
	}
	
	@UiHandler("byProject")
	public void groupByP(SelectEvent event)
	{
		view.groupBy(projCol);
		view.collapseAllGroups();
		store.getSortInfo().clear();
//		StoreSortInfo<LibraryData> sortInfo=new StoreSortInfo<LibraryData>(LibraryDataModelFactory.getValueProvider("Date_Sequenced"), dateCol.getComparator(), SortDir.DESC);	
		store.getSortInfo().add(0, view.getLastStoreSort());
        store.getSortInfo().add(1, sortByDate);

	}
	@UiHandler("byDate")
	public void groupByD(SelectEvent event)
	{

		 view.groupBy(dateCol);		 
		 view.collapseAllGroups();
		
	}
	@UiHandler("byLibType")
	public void groupByLT(SelectEvent event)
	{

		 view.groupBy(libTypeCol);		 
		 view.collapseAllGroups();
		
	}
	@UiHandler("collapse")
	public void colall(SelectEvent event)
	{
		view.collapseAllGroups();
	}
	
	@UiHandler("expand")
	public void expall(SelectEvent event)
	{
		view.expandAllGroups();
	}
	
	@UiHandler("share")
	public void share(SelectEvent event)
	{
		 if(filter.getText().length() < 3 || filter.getText().contains("Search..."))
		 {
			 Info.display("Error", "enter something is the search box before you can share");
			 return;
		 }
		 
		 myServer.getEncryptedData(filter.getText(), new AsyncCallback<ArrayList<String>>(){
			@Override
			public void onFailure(Throwable caught)
			{
				caught.printStackTrace();
			}
			@Override
			public void onSuccess(ArrayList<String> result)
			{
				 TextArea text = new TextArea();
				 text.setText("https://webapp.epigenome.usc.edu/gareports/ECControlCenter.html?t=" + result.get(0));
				 final Dialog simple = new Dialog();
				 simple.setHeadingText("This link will take you directly to the search results");
				 simple.setPredefinedButtons(PredefinedButton.OK);
				 simple.setBodyStyleName("pad-text");
				 simple.add(text);
				 simple.setHideOnButtonClick(true);
				 simple.setWidth(600);
				 simple.setHeight(200);
				 simple.show();
			}});
		 
	}
	@UiHandler("analyze")
	public void launch (SelectEvent e) {
   	 final Dialog mutect = new Dialog();
        mutect.setBodyBorder(false);
        
        mutect.setHeadingText("MuTect analysis");
        mutect.setWidth(600);
        mutect.setHeight(300);
        mutect.setHideOnButtonClick(true);
        final TextArea tumtext = new TextArea();
        tumtext.setEmptyText("Drag-n-drop tumor sample from the left panel");

        BorderLayoutContainer layout = new BorderLayoutContainer();
        mutect.add(layout);
        // Layout - west
        ContentPanel panel = new ContentPanel();
        panel.setHeadingText("Tumor");
        BorderLayoutData data = new BorderLayoutData(295);
        data.setMargins(new Margins(0, 5, 0, 0));
        panel.setLayoutData(data);
        panel.add(tumtext);
        layout.setWestWidget(panel);
        // Layout - center
        panel = new ContentPanel();
        panel.setHeadingText("Normal");
        final TextArea normtext = new TextArea();
        normtext.setEmptyText("Drag-n-drop normal sample from the left panel");
        panel.add(normtext);
        layout.setCenterWidget(panel);

		 DropTarget tumtarget = new DropTarget(tumtext)
		 {
		      @Override
		      protected void onDragDrop(DndDropEvent event) 
		      {
			        super.onDragDrop(event);
			        @SuppressWarnings("unchecked")
					ArrayList<LibraryData> droppedSummarizedLibs = (ArrayList<LibraryData>) event.getData();
			        for(LibraryData summarizedLibrary : droppedSummarizedLibs)
			        {
			          String sampleInfo = "Project: "+summarizedLibrary.get("project").getValue()+"\n"+
			        		        "Library: "+summarizedLibrary.get("sample_name").getValue()+"\n"+
			        		        "LibType: "+summarizedLibrary.get("processing_formatted").getValue()+"\n"+			        		    
			        		        "LIMS id: "+summarizedLibrary.get("geneusID_sample").getValue()+"\n"+
			        		        "Flowcell: "+summarizedLibrary.get("flowcell_serial").getValue()+"\n"+
			        		        "Lane: "+summarizedLibrary.get("lane").getValue()+"\n"+
			        		        "Analysis id: "+summarizedLibrary.get("analysis_id").getValue()+"\n";
			          tumtext.setText(sampleInfo);
			        }
			        
		      }
		 
		 };
		 tumtarget.setOperation(Operation.COPY);
		 DropTarget normtarget = new DropTarget(normtext)
		 {
		      @Override
		      protected void onDragDrop(DndDropEvent event) 
		      {
			        super.onDragDrop(event);
			        @SuppressWarnings("unchecked")
					ArrayList<LibraryData> droppedSummarizedLibs = (ArrayList<LibraryData>) event.getData();
			        for(LibraryData summarizedLibrary : droppedSummarizedLibs)
			        {
			          String sampleInfo = "Project: "+summarizedLibrary.get("project").getValue()+"\n"+
			        		        "Library: "+summarizedLibrary.get("sample_name").getValue()+"\n"+
			        		        "LibType: "+summarizedLibrary.get("processing_formatted").getValue()+"\n"+			        		    
			        		        "LIMS id: "+summarizedLibrary.get("geneusID_sample").getValue()+"\n"+
			        		        "Flowcell: "+summarizedLibrary.get("flowcell_serial").getValue()+"\n"+
			        		        "Lane: "+summarizedLibrary.get("lane").getValue()+"\n"+
			        		        "Analysis id: "+summarizedLibrary.get("analysis_id").getValue()+"\n";
			          normtext.setText(sampleInfo);
			        }
			        
		      }
		 
		 };
		 normtarget.setOperation(Operation.COPY);
		 mutect.show();
   	
   }
	
	/*@UiHandler("hideMerged")
	public void onChange(ChangeEvent event) {
		setVisible(false);
	}*/
	public void setUserManualLink() {
	   // String link="<a target=\"new\" href=\"https://sites.google.com/site/uscecwiki/home/Natalia-personal-page/ecdp-user-manual-1\"><img src=\"images/book_open_small.png\" title=\"User Manual\"alt=\"User Manual\"</a>";	
	    String link="<a style=\"color:red; text-decoration:none\" target=\"new\" href=\"https://sites.google.com/site/uscecwiki/home/Natalia-personal-page/ecdp-user-manual-1\">Help</a>";
	    SafeHtml shtml = SafeHtmlUtils.fromTrustedString(link);
		userManual.setHTML(shtml);		
	}
	public void setUserManualButton(){
	   // userManual.setStyleName("help-Button");
	    userManual.getElement().getStyle().setColor("orangered");	
	   // System.out.println("Style="+userManual.getStyleName());
	    userManual.addSelectHandler(new SelectHandler() {

			@Override
			public void onSelect(SelectEvent event) {
				Window.open("https://sites.google.com/site/uscecwiki/ecdp/documentation/ecdp-user-manual", "_blank", "");
                logToServer("UserManual");
			}});
	    toolbar.add(userManual);
	}
	public void forceLayout() {
		// TODO Auto-generated method stub
		vlc.forceLayout();
		gridPanel.forceLayout();
		content.forceLayout();
		view.doResize();
		grid.setHeight(Window.getClientHeight()-70);
	}

	@Override
	public boolean isLayoutRunning() {
		return false;
	}

	@Override
	public boolean isOrWasLayoutRunning() {
		return false;
	}
	
    public void logToServer(String text) 
    {
    	 myServer.logWriter("SampleList: " + text, new AsyncCallback<String>(){
			@Override
			public void onFailure(Throwable caught) { }

			@Override
			public void onSuccess(String result) {
				//do nothing
			}
		 });
    }	
	
}
	
