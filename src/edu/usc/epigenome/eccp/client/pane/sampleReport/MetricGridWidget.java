package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.google.gwt.core.client.GWT;

import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;

import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.dnd.core.client.DND.Operation;
import com.sencha.gxt.dnd.core.client.DndDropEvent;
import com.sencha.gxt.dnd.core.client.DropTarget;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer.VerticalLayoutData;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.form.StoreFilterField;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.ColumnModel;
import com.sencha.gxt.widget.core.client.grid.Grid;
import com.sencha.gxt.widget.core.client.grid.GroupingView;
import com.sencha.gxt.widget.core.client.info.Info;
import com.sencha.gxt.widget.core.client.toolbar.ToolBar;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.data.LibraryProperty;
import edu.usc.epigenome.eccp.client.data.LibraryPropertyModel;
import edu.usc.epigenome.eccp.client.data.MultipleLibraryProperty;
import edu.usc.epigenome.eccp.client.data.MultipleLibraryPropertyModelFactory;

public class MetricGridWidget extends Composite {

	private static MetricGridUiBinder uiBinder = GWT.create(MetricGridUiBinder.class);

	interface MetricGridUiBinder extends UiBinder<Widget, MetricGridWidget> {
	}
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);
	HashMap<String,MultipleLibraryProperty> mergedLibraryData;
	List<LibraryData> libraries;
	@UiField ContentPanel gridPanel;
	@UiField VerticalLayoutContainer content;

	@UiField ToolBar buttons;
	@UiField HorizontalPanel buttonsHP;
	@UiField VerticalLayoutContainer vlc;
	String usageMode = "user";
	List<LibraryData> data;

	
	
	StoreFilterField<MultipleLibraryProperty> filter = new StoreFilterField<MultipleLibraryProperty>() {
		@Override
		protected boolean doSelect(Store<MultipleLibraryProperty> store, MultipleLibraryProperty parent,MultipleLibraryProperty item, String filter) 
		{
			return item.getName().toLowerCase().contains(filter.toLowerCase());
		}
	};
	

	

	private static final LibraryPropertyModel properties = GWT.create(LibraryPropertyModel.class);

	public MetricGridWidget() {
		initWidget(uiBinder.createAndBindUi(this));
		//	createGridColumns();
		buttons.add(filter);
	}
	
	public MetricGridWidget(List<LibraryData> data) {
		initWidget(uiBinder.createAndBindUi(this));
		this.data=data;
		this.setLayoutData(new VerticalLayoutData(-1,-1));
		vlc.setLayoutData(new VerticalLayoutData(-1,-1));
		vlc.getWidget(0).setLayoutData(new VerticalLayoutData(-1,30));
		//ZR I hate this dirty hack for making the toolbar appear.
		
		filter.setEmptyText("Search...");
		buttonsHP.add(filter);
		libraries = data;
		mergeData();
		drawTable();
		Widget w = vlc.getWidget(0);
		vlc.remove(0);
		vlc.insert(w, 0,new VerticalLayoutData(-1,-1));
	}
	
	void mergeData()
	{
		HashMap<String,MultipleLibraryProperty> libdata = new HashMap<String,MultipleLibraryProperty>();
		for(int i = 0; i < libraries.size() ; i ++)
		{
			for(String key : libraries.get(i).keySet())
			{
				if(!libdata.containsKey(key))
					libdata.put(key, new MultipleLibraryProperty());
				MultipleLibraryProperty m = libdata.get(key);
				LibraryProperty p = libraries.get(i).get(key);
				m.setName(p.getName());
				m.setType(p.getType());
				m.setCategory(p.getCategory());
				m.setDescription(p.getDescription());
				m.setSortOrder(p.getSortOrder());
				m.setSource(p.getSource());
				m.setUsage(p.getUsage());					
				while(m.getValueSize() < i)
					m.addValue("");
				m.addValue(p.getValue());
			}
		}
		mergedLibraryData = libdata;	
	}
	
	public void drawTable() {
		//SET UP COLUMNS
		 List<ColumnConfig<MultipleLibraryProperty, ?>> columnDefs = new ArrayList<ColumnConfig<MultipleLibraryProperty, ?>>();
		 ColumnConfig<MultipleLibraryProperty, String> cc1 = new ColumnConfig<MultipleLibraryProperty, String>(properties.name(), 200, "Metric");
		 ColumnConfig<MultipleLibraryProperty, String> cc2 = new ColumnConfig<MultipleLibraryProperty, String>(properties.category(), 220, "Category");
		 columnDefs.add(cc1);
		 columnDefs.add(cc2);		
		 
		 for(int i = 0 ; i < mergedLibraryData.get("flowcell_serial").getValueSize(); i++)
		 {
			 ColumnConfig<MultipleLibraryProperty, String> cc = new ColumnConfig<MultipleLibraryProperty, String>(MultipleLibraryPropertyModelFactory.getValueProvider(i), 220, mergedLibraryData.get("sample_name").getValue(i));
			 columnDefs.add(cc);
		 }		 
		 
		 ColumnModel<MultipleLibraryProperty> colModel = new ColumnModel<MultipleLibraryProperty>(columnDefs);
		 final ListStore<MultipleLibraryProperty> store = new ListStore<MultipleLibraryProperty>(properties.key());
		 GroupingView<MultipleLibraryProperty> view = new GroupingView<MultipleLibraryProperty>();
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 view.setForceFit(true);
		 
		 final	Grid<MultipleLibraryProperty> grid = new Grid<MultipleLibraryProperty>(store, colModel);
		 grid.setHeight(Window.getClientHeight() - 130);
		 grid.setView(view);
		 content.add(grid);				
		 filter.bind(store);
		 store.replaceAll(new ArrayList<MultipleLibraryProperty>(mergedLibraryData.values()));
		 view.collapseAllGroups();
		 view.groupBy(cc2);
		 DropTarget target = new DropTarget(grid)
		 {
		      @Override
		      protected void onDragDrop(DndDropEvent event) 
		      {
		        super.onDragDrop(event);
		        @SuppressWarnings("unchecked")
				ArrayList<LibraryData> droppedSummarizedLibs = (ArrayList<LibraryData>) event.getData();
		        for(LibraryData summarizedLibrary : droppedSummarizedLibs)
		        {
					 LibraryDataQuery query = new LibraryDataQuery();
					 query.setIsSummaryOnly(false);
					 query.setGetFiles(true);
					 query.setDBid(summarizedLibrary.get("id_run_sample").getValue());
					 myServer.getLibraries(query, new AsyncCallback<ArrayList<LibraryData>>(){
							@Override
							public void onFailure(Throwable caught)
							{
								Info.display("Error","Failed to add library to table ");
							}
	
	
							@Override
							public void onSuccess(ArrayList<LibraryData> result)
							{
							    libraries.addAll(result);
							    content.remove(0);
						        mergeData();
								drawTable();
					        	Info.display("Notice","added to table:" + result.get(0).get("sample_name").getValue());
							}
					});
		        }
		      }
		 };
		 target.setOperation(Operation.COPY);
	}
	
	public void setHeadingText(String title)
	{
		gridPanel.setHeadingText(title);
	}
	
	@UiHandler("adminButton")
	public void setAdminView(SelectEvent event)
	{
		
		usageMode="admin";
		ArrayList<LibraryProperty> data = getUsageModeData();
	//	populateGrid(data);
		
	}
	
	@UiHandler("userButton")
	public void setUserView(SelectEvent event)
	{
		
		usageMode="user";
		ArrayList<LibraryProperty> data = getUsageModeData();
	//	populateGrid(data);
		
	}
	public ArrayList<LibraryProperty> getUsageModeData() {
        
		ArrayList<LibraryProperty> usageModeData = new ArrayList<LibraryProperty>();
		if (usageMode.equals("user")) {
			Info.display("TODO", "user view");
	/*		for (LibraryProperty property: data) {
			//	 System.out.println("Usage number: "+property.getUsage());
				 if (property.getUsage().equals("4")) usageModeData.add(property);
			} */
				 
			}
		if (usageMode.equals("admin")) {
			Info.display("TODO", "admin view");
			
		/*	for (LibraryProperty property: data)  {
				//System.out.println("Usage number: "+property.getUsage());
				 if (property.getUsage().matches("0|1|2|3|4") ) usageModeData.add(property);
				 
			}*/
				 
		}
		Info.display("Size of Array", usageModeData.size()+"");
		return usageModeData;
		}

	}

	

