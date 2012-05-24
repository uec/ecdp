package edu.usc.epigenome.eccp.client.sampleList;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.ResizeEvent;
import com.google.gwt.event.logical.shared.ResizeHandler;
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
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.dnd.core.client.GridDragSource;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.Dialog;
import com.sencha.gxt.widget.core.client.Dialog.PredefinedButton;
import com.sencha.gxt.widget.core.client.button.TextButton;
import com.sencha.gxt.widget.core.client.container.FlowLayoutContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.event.RowClickEvent;
import com.sencha.gxt.widget.core.client.event.RowClickEvent.RowClickHandler;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.form.StoreFilterField;
import com.sencha.gxt.widget.core.client.form.TextArea;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.ColumnModel;
import com.sencha.gxt.widget.core.client.grid.Grid;
import com.sencha.gxt.widget.core.client.grid.GroupingView;
import com.sencha.gxt.widget.core.client.info.Info;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataModelFactory;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.events.ECCPEventBus;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEvent;
import edu.usc.epigenome.eccp.client.pane.sampleReport.MetricGridWidget;
import edu.usc.epigenome.eccp.client.sencha.ResizeGroupingView;

public class sampleList extends Composite 
{

	private static sampleListUiBinder uiBinder = GWT.create(sampleListUiBinder.class);

	interface sampleListUiBinder extends UiBinder<Widget, sampleList>{}

	
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);

	@UiField ContentPanel gridPanel;
	@UiField FlowLayoutContainer content;
	@UiField VerticalLayoutContainer vlc;
	@UiField TextButton share;
	
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
	ColumnConfig<LibraryData, String> flowcellCol,libCol,runCol,laneCol,projCol,dateCol,geneusCol,folderCol;
	ListStore<LibraryData> store;
	Grid<LibraryData> grid;
	

	@UiConstructor
	public sampleList() 
	{
		initWidget(uiBinder.createAndBindUi(this));
	    createGrid();
	    gridPanel.addTool(filter);
	    filter.setEmptyText("Search...");
	    //hide share button when already in a shared search 
	    if(Window.Location.getQueryString().length() > 0 )
	    	share.hide();
	    	
	    
	//    vlc.setHeight(Window.getClientHeight());
	    grid.setHeight(Window.getClientHeight()-100);
	   /* Window.addResizeHandler(new ResizeHandler() {

			@Override
			public void onResize(ResizeEvent event) {
				// TODO Auto-generated method stub
				 Info.display("Resize", "widget resized");
				 content.setHeight(Window.getClientHeight()-100);
				 setPixelSize(Window.getClientHeight(),Window.getClientWidth());				
			}
	    	
	    });
	   */
	   //  content.setHeight(Window.getClientHeight());
	  //  content.setScrollMode(ScrollMode.AUTO);
	  //  vlc.setScrollMode(ScrollMode.NONE);
	    
	}
	
	public void createGrid() {
		//SET UP COLUMNS
		 List<ColumnConfig<LibraryData, ?>> columnDefs = new ArrayList<ColumnConfig<LibraryData, ?>>();
		 flowcellCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("flowcell_serial"), 80, "Flowcell");
		 flowcellCol.setCell(new SimpleSafeHtmlCell<String>(new AbstractSafeHtmlRenderer<String>() 
		 {
		      public SafeHtml render(String object) 
		      {  
		    	  return SafeHtmlUtils.fromTrustedString("<a target=\"new\" href=\"http://webapp.epigenome.usc.edu/eccpgxt/ReportDnld.jsp?fcserial=" + object + "&report=rep1\">"+ object + "</a>");		        
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
		 geneusCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("geneusID_sample"), 80, "LIMS id");
		 projCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("project"), 120, "Project");
		 dateCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("Date_Sequenced"), 80, "Date");
		// folderCol = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("RunParam_RunID"), 80, "Storage Folder");
		 columnDefs.add(projCol);
		 columnDefs.add(libCol);
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
		 view.groupBy(projCol);
		 grid = new Grid<LibraryData>(store, columnModel);
		 grid.setView(view);
		 new GridDragSource<LibraryData>(grid);
		 
		 
		 grid.addRowClickHandler(new RowClickHandler()
		 {
			@Override
			public void onRowClick(RowClickEvent event)
			{
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
							else
								Info.display("Error","Failed to get Library");
						}});
			}
		});
		 
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
		 
	}
	
	public void populateGrid(ArrayList<LibraryData> data)
	{
		store.replaceAll(data);
		view.collapseAllGroups();
		Info.display("Notice", "Library List Loaded");		
		
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
	
	@UiHandler("resize")
	public void fitIt(SelectEvent event)
	{
		view.doResize();
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
				 text.setText("http://webapp.epigenome.usc.edu/eccpgxt/ECControlCenter.html?t=" + result.get(0));
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

	
}
	
