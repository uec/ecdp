package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;

import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
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
import edu.usc.epigenome.eccp.client.data.NameValue;
import edu.usc.epigenome.eccp.client.data.NameValueModel;

public class MetricGridWidget extends Composite {

	private static MetricGridUiBinder uiBinder = GWT
			.create(MetricGridUiBinder.class);

	interface MetricGridUiBinder extends UiBinder<Widget, MetricGridWidget> {
	}
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);

	@UiField ContentPanel gridPanel;
	@UiField VerticalLayoutContainer content;
	@UiField ToolBar buttons;
	
	GroupingView<NameValue> view = new GroupingView<NameValue>();
	StoreFilterField<NameValue> filter = new StoreFilterField<NameValue>() {

		@Override
		protected boolean doSelect(Store<NameValue> store, NameValue parent,
				NameValue item, String filter) {
			// TODO Auto-generated method stub
			return false;
		}
		
	};
	String mode = "user";
	ColumnModel<NameValue> geneColumnModel;
	ColumnConfig<NameValue, String> cc1,cc2,cc3;
	ListStore<NameValue> store;
	Grid<NameValue> grid;
	private static final NameValueModel properties = GWT.create(NameValueModel.class);

	public MetricGridWidget() {
		initWidget(uiBinder.createAndBindUi(this));
		 
		
			    createStatisticsGrid();
			    buttons.add(filter);	 
	}
	
	public void createStatisticsGrid() {
		//SET UP COLUMNS
		 List<ColumnConfig<NameValue, ?>> columnDefs = new ArrayList<ColumnConfig<NameValue, ?>>();
		 cc1 = new ColumnConfig<NameValue, String>(properties.name(), 200, "Name");
		 cc2 = new ColumnConfig<NameValue, String>(properties.type(), 220, "type");
		 cc3 = new ColumnConfig<NameValue, String>(properties.value(), 200, "value");
		 columnDefs.add(cc2);
		 columnDefs.add(cc1);		
		 columnDefs.add(cc3);
         geneColumnModel = new ColumnModel<NameValue>(columnDefs);
		 store = new ListStore<NameValue>(properties.key());
		 view = new GroupingView<NameValue>();
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 view.setForceFit(true);
		 grid = new Grid<NameValue>(store, geneColumnModel);
		 grid.setView(view);
		 view.groupBy(cc2);
		
		 content.add(grid);				
	}
	
	public void populateGrid(ArrayList<NameValue> data)
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
