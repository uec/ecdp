package edu.usc.epigenome.eccp.client.sampleList;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
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
import com.sencha.gxt.core.client.dom.ScrollSupport.ScrollMode;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.container.FlowLayoutContainer;
import com.sencha.gxt.widget.core.client.container.SimpleContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer.VerticalLayoutData;
import com.sencha.gxt.widget.core.client.event.RowClickEvent;
import com.sencha.gxt.widget.core.client.event.RowClickEvent.RowClickHandler;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.event.ViewReadyEvent;
import com.sencha.gxt.widget.core.client.event.ViewReadyEvent.ViewReadyHandler;
import com.sencha.gxt.widget.core.client.form.StoreFilterField;
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
import edu.usc.epigenome.eccp.client.events.LibrarySelectedEvent;

public class sampleList extends Composite 
{

	private static sampleListUiBinder uiBinder = GWT.create(sampleListUiBinder.class);

	interface sampleListUiBinder extends UiBinder<Widget, sampleList>{}

	
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);

	@UiField ContentPanel gridPanel;
	@UiField FlowLayoutContainer content;
	
	GroupingView<LibraryData> view = new GroupingView<LibraryData>();
	StoreFilterField<LibraryData> filter = new StoreFilterField<LibraryData>() {
		@Override
		protected boolean doSelect(Store<LibraryData> store, LibraryData parent,LibraryData item, String filter) {
				return item.get("project").getValue().toLowerCase().contains(filter.toLowerCase()) || item.get("sample_name").getValue().toLowerCase().contains(filter.toLowerCase()) ||  item.get("flowcell_serial").getValue().toLowerCase().contains(filter.toLowerCase()) ||  item.get("analysis_id").getValue().toLowerCase().contains(filter.toLowerCase());
					
		}
		
	};
	String mode = "user";
	ColumnModel<LibraryData> columnModel;
	ColumnConfig<LibraryData, String> cc1,cc2,cc3,cc4,cc5,cc6;
	ListStore<LibraryData> store;
	Grid<LibraryData> grid;
	

	@UiConstructor
	public sampleList() 
	{
		initWidget(uiBinder.createAndBindUi(this));
	    createGrid();
	    gridPanel.addTool(filter);
	    filter.setEmptyText("Search...");
	    grid.setHeight(Window.getClientHeight() - 100);
	    
	}
	
	public void createGrid() {
		//SET UP COLUMNS
		 List<ColumnConfig<LibraryData, ?>> columnDefs = new ArrayList<ColumnConfig<LibraryData, ?>>();
		 cc1 = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("flowcell_serial"), 100, "Flowcell");
		 cc2 = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("sample_name"), 120, "Library");
		 cc3 = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("analysis_id"), 150, "Run");
		 cc3.setCell(new SimpleSafeHtmlCell<String>(new AbstractSafeHtmlRenderer<String>() 
		{
		      public SafeHtml render(String object) 
		      {  
		        return SafeHtmlUtils.fromString(object.length() > 40 ? "..." + object.subSequence(object.length() - 40, object.length()) : object);		        
		      }
		}));
		 
		 cc4 = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("lane"), 30, "Lane");
		 cc5 = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("project"), 120, "Project");
		 cc6 = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("Date_Sequenced"), 80, "Date");
		 cc6 = new ColumnConfig<LibraryData, String>(LibraryDataModelFactory.getValueProvider("RunParam_RunID"), 80, "Storage Folder");
		 columnDefs.add(cc5);
		 columnDefs.add(cc2);		
		 columnDefs.add(cc1);
		 columnDefs.add(cc4);
		 columnDefs.add(cc6);
		 columnDefs.add(cc3);
		 
		 
         columnModel = new ColumnModel<LibraryData>(columnDefs);
		 store = new ListStore<LibraryData>(LibraryDataModelFactory.getModelKeyProvider());
		 view = new GroupingView<LibraryData>();
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 view.setForceFit(true);
		 view.groupBy(cc5);
		 grid = new Grid<LibraryData>(store, columnModel);
		 grid.setView(view);
		 
		 
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
								ECCPEventBus.EVENT_BUS.fireEvent(new LibrarySelectedEvent(result.get(0)));
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
				Info.display("Error","Failed to get Flowcells");
				
			}

			@Override
			public void onSuccess(ArrayList<LibraryData> result)
			{
				populateGrid(result);
			}});
		 
	}
	
	public void populateGrid(ArrayList<LibraryData> data)
	{
		store.replaceAll(data);
		view.collapseAllGroups();
		Info.display("Notice", "data loaded");		
		
	}
	
	public void setHeadingText(String title)
	{
		gridPanel.setHeadingText(title);
	}
	
	@UiHandler("byFlowcell")
	public void groupByF(SelectEvent event)
	{
		view.groupBy(cc1);
		view.collapseAllGroups();
	}
	
	@UiHandler("byLibrary")
	public void groupByL(SelectEvent event)
	{
		view.groupBy(cc2);
		view.collapseAllGroups();
	}
	
	@UiHandler("byProject")
	public void groupByP(SelectEvent event)
	{
		view.groupBy(cc5);
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
	
}
	
