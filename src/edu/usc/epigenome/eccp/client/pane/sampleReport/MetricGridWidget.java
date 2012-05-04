package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;

import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.core.client.dom.ScrollSupport.ScrollMode;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.button.TextButton;
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
import edu.usc.epigenome.eccp.client.data.LibraryProperty;
import edu.usc.epigenome.eccp.client.data.LibraryPropertyModel;

public class MetricGridWidget extends Composite {

	private static MetricGridUiBinder uiBinder = GWT.create(MetricGridUiBinder.class);

	interface MetricGridUiBinder extends UiBinder<Widget, MetricGridWidget> {
	}
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);

	@UiField ContentPanel gridPanel;
	@UiField VerticalLayoutContainer content;

	@UiField ToolBar buttons;
	@UiField HorizontalPanel buttonsHP;
	@UiField VerticalLayoutContainer vlc;

	
	GroupingView<LibraryProperty> view = new GroupingView<LibraryProperty>();
	StoreFilterField<LibraryProperty> filter = new StoreFilterField<LibraryProperty>() {
		@Override
		protected boolean doSelect(Store<LibraryProperty> store, LibraryProperty parent,LibraryProperty item, String filter) 
		{
			return item.getName().toLowerCase().contains(filter.toLowerCase());
		}
	};
	String mode = "user";
	ColumnModel<LibraryProperty> colModel;
	ColumnConfig<LibraryProperty, String> cc1,cc2,cc3;
	ListStore<LibraryProperty> store;
	Grid<LibraryProperty> grid;
	private static final LibraryPropertyModel properties = GWT.create(LibraryPropertyModel.class);

	public MetricGridWidget() {
		initWidget(uiBinder.createAndBindUi(this));
		createStatisticsGrid();
		buttons.add(filter);
	}
	
	public MetricGridWidget(List<LibraryProperty> data) {
		initWidget(uiBinder.createAndBindUi(this));
		this.setLayoutData(new VerticalLayoutData(-1,-1));
		vlc.setLayoutData(new VerticalLayoutData(-1,-1));
		vlc.getWidget(0).setLayoutData(new VerticalLayoutData(-1,30));
		
		createStatisticsGrid();
		//ZR I hate this dirty hack for making the toolbar appear.
		
		filter.setEmptyText("Search...");
		buttonsHP.add(filter);
		populateGrid(data);	
		Widget w = vlc.getWidget(0);
		vlc.remove(0);
		vlc.insert(w, 0,new VerticalLayoutData(-1,-1));
	}
	
	public void createStatisticsGrid() {
		//SET UP COLUMNS
		 List<ColumnConfig<LibraryProperty, ?>> columnDefs = new ArrayList<ColumnConfig<LibraryProperty, ?>>();
		 cc1 = new ColumnConfig<LibraryProperty, String>(properties.name(), 200, "Metric");
		 cc2 = new ColumnConfig<LibraryProperty, String>(properties.category(), 220, "Category");
		 cc3 = new ColumnConfig<LibraryProperty, String>(properties.value(), 300, "Value");
		 columnDefs.add(cc2);
		 columnDefs.add(cc1);		
		 columnDefs.add(cc3);
         colModel = new ColumnModel<LibraryProperty>(columnDefs);
		 store = new ListStore<LibraryProperty>(properties.key());
		 view = new GroupingView<LibraryProperty>();
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 view.setForceFit(true);
		 grid = new Grid<LibraryProperty>(store, colModel);
		 grid.setHeight(Window.getClientHeight() - 130);
		 grid.setView(view);
		 view.groupBy(cc2);
		 content.add(grid);				
		 filter.bind(store);
		
	}
	
	public void populateGrid(List<LibraryProperty> data)
	{
		store.replaceAll(data);
		view.collapseAllGroups();
		Info.display("Notice", "data loaded");
	}
	
	public void setHeadingText(String title)
	{
		gridPanel.setHeadingText(title);
	}
	
	@UiHandler("adminButton")
	public void groupByType(SelectEvent event)
	{
		Info.display("TODO", "admin view");
	}
	
	@UiHandler("userButton")
	public void groupByLocation(SelectEvent event)
	{
		Info.display("TODO", "user view");
	}
	
}
