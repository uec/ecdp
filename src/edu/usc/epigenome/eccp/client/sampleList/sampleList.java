package edu.usc.epigenome.eccp.client.sampleList;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.NativeEvent;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ContextMenuEvent;
import com.google.gwt.event.dom.client.ContextMenuHandler;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.event.dom.client.KeyDownHandler;
import com.google.gwt.event.logical.shared.ResizeEvent;
import com.google.gwt.event.logical.shared.ResizeHandler;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.event.shared.EventHandler;
import com.google.gwt.safehtml.shared.SafeHtml;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.text.shared.AbstractSafeHtmlRenderer;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiConstructor;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Event;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HTML;

import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.cell.core.client.SimpleSafeHtmlCell;
import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.core.client.XTemplates;
import com.sencha.gxt.core.client.XTemplates.XTemplate;
import com.sencha.gxt.core.client.util.Format;
import com.sencha.gxt.core.client.util.KeyNav;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.SortDir;
import com.sencha.gxt.data.shared.SortInfoBean;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.data.shared.Store.StoreSortInfo;
import com.sencha.gxt.dnd.core.client.GridDragSource;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.Dialog;
import com.sencha.gxt.widget.core.client.Dialog.PredefinedButton;
import com.sencha.gxt.widget.core.client.box.MessageBox;
import com.sencha.gxt.widget.core.client.button.CellButtonBase;
import com.sencha.gxt.widget.core.client.button.TextButton;
import com.sencha.gxt.widget.core.client.container.FlowLayoutContainer;
import com.sencha.gxt.widget.core.client.container.HasLayout;
import com.sencha.gxt.widget.core.client.container.HorizontalLayoutContainer;
import com.sencha.gxt.widget.core.client.container.HtmlLayoutContainer;
import com.sencha.gxt.widget.core.client.container.SimpleContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer.VerticalLayoutData;
import com.sencha.gxt.widget.core.client.event.HideEvent;
import com.sencha.gxt.widget.core.client.event.HideEvent.HideHandler;
import com.sencha.gxt.widget.core.client.event.RowClickEvent;
import com.sencha.gxt.widget.core.client.event.RowClickEvent.RowClickHandler;
import com.sencha.gxt.widget.core.client.event.RowDoubleClickEvent;
import com.sencha.gxt.widget.core.client.event.RowDoubleClickEvent.RowDoubleClickHandler;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.event.SelectEvent.SelectHandler;
import com.sencha.gxt.widget.core.client.form.StoreFilterField;
import com.sencha.gxt.widget.core.client.form.TextArea;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.ColumnModel;
import com.sencha.gxt.widget.core.client.grid.Grid;
import com.sencha.gxt.widget.core.client.grid.GroupingView;
import com.sencha.gxt.widget.core.client.grid.GroupingView.GroupingData;
import com.sencha.gxt.widget.core.client.info.Info;
import com.sencha.gxt.widget.core.client.menu.Item;
import com.sencha.gxt.widget.core.client.menu.Menu;
import com.sencha.gxt.widget.core.client.menu.MenuItem;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataModelFactory;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.data.MultipleLibraryProperty;
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
	@UiField Anchor userManual;
	
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
	Grid<LibraryData> grid;
	StoreSortInfo<LibraryData> sortByDate;
	MenuItem menuItem;
	Comparator<String>  dateComparator;

	

	@UiConstructor
	public sampleList() 
	{
		initWidget(uiBinder.createAndBindUi(this));
	    createGrid();
	    gridPanel.addTool(filter);	   
	    String link="<a target=\"new\" href=\"https://sites.google.com/site/uscecwiki/home/Natalia-personal-page/ecdp-user-manual-1\"><img src=\"images/book_open_small.png\" title=\"User Manual\"</a>";	
	    SafeHtml shtml = SafeHtmlUtils.fromTrustedString(link);
	    userManual.setHTML(shtml);
	    filter.setEmptyText("Search...");
	    //hide share button when already in a shared search 
	    if(Window.Location.getQueryString().length() > 0 )
	    	share.hide();
	    
	    if(Window.Location.getQueryString().contains("GODMODE"))
	    	godmode();
	    
	}
	
	public void createGrid() {
		//SET UP COLUMNS
		 List<ColumnConfig<LibraryData, ?>> columnDefs = new ArrayList<ColumnConfig<LibraryData, ?>>();
		 flowcellCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("flowcell_serial"), 90, "Flowcell");
		 flowcellCol.setCell(new SimpleSafeHtmlCell<String>(new AbstractSafeHtmlRenderer<String>() 
		 {
		      public SafeHtml render(String object) 
		      {  
		    	  //only show param links if admin (ie no query string)
		    	  if(Window.Location.getQueryString().length() < 1 )
		    		  return SafeHtmlUtils.fromTrustedString(object + " <a target=\"new\" href=\"/gareports/ReportDnld.jsp?fcserial=" + object + "&report=rep1\"" +"title=\"Illumina parameters\""+"> (i)</a> " +
		    			  "<a target=\"new\" href=\"/gareports/ReportDnld.jsp?fcserial=" + object + "&report=rep2\"" +"title=\"Pipeline parameters\""+"> (p)</a>");
		    	  else
		    		  return SafeHtmlUtils.fromTrustedString(object);
		      }
		 }));
		 libCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("sample_name"), 120, "Library");
		 
		 runCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("analysis_id"), 100, "Run");
		 runCol.setCell(new SimpleSafeHtmlCell<String>(new AbstractSafeHtmlRenderer<String>() 
		{
		      public SafeHtml render(String object) 
		      {  
		    	  String ret = new String(object);
		    	  ret = ret.replace("/storage/hpcc/uec-gs1/laird/shared/production/ga/flowcells/", "");
		    	  String[] vals = ret.split("/");
		    	  ret = vals.length > 2 ? vals[1] : object;
		    	  
		    	  return SafeHtmlUtils.fromString(object.length() > 30 ? ret : object);		        
		      }
		}));
		 
		 laneCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("lane"), 30, "Lane");
		 libTypeCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("processing"), 30, "LibType");
		/* libTypeCol.setCell(new SimpleSafeHtmlCell<String>(new AbstractSafeHtmlRenderer<String>() 
	     {
			 public SafeHtml render(String object) 
		      {  
		    	  String type = new String(object);
		    	  String pattern = "(L\\d+\\s+)(.*)(\\s+processing.*)";
		    	  type = type.replaceAll(pattern, "$2");
				return SafeHtmlUtils.fromString(type);
		    	 	        
		      }			 
	     }));*/
		 libTypeCol.setWidth(80);
		 geneusCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("geneusID_sample"), 80, "LIMS id");
		 projCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("project"), 120, "Project");
		 dateCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("Date_Sequenced"), 80, "Date");
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
		 grid.setView(view);
	//	 ArrayList<GroupingData<?>> groups = new ArrayList<GroupingData<?>>();
	//	 ArrayList<String> concatColumn = new ArrayList<String>();
		 
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
					                   String msg = Format.substitute("The '{0}' button was pressed", btn.getHideButton().getText());					          
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
		 filter.bind(store);
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
				populateGrid(result);
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
						            metric.setUsageMode("user");
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
						getContextData(library);
												 					
					}});
	         
	}
	
	public void populateGrid(ArrayList<LibraryData> data)
	{
		store.replaceAll(data);
		view.collapseAllGroups();
		Info.display("Notice", "Library List Loaded");		
		
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
	@UiHandler("hideMerged")
	public void onChange(ChangeEvent event) {
		
	}
	
	@Override
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

	
}
	
