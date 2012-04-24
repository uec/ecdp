package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.widget.core.client.button.TextButton;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.event.SelectEvent.SelectHandler;
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
//	ECServiceAsync myServer = (GxtTestServiceAsync) GWT.create(GxtTestService.class);
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);

	@UiField VerticalLayoutContainer content;
	@UiField ToolBar buttons;
	TextButton adminButton = new TextButton("Admin view");
	TextButton userButton = new TextButton("User View");
	TextButton organizeLocation = new TextButton("Organize by File location");
	TextButton organizeType = new TextButton("Organize by File Type");
	TextButton organizeName = new TextButton("Organize by File Name");
	
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

	public MetricGridWidget(String type) {
		initWidget(uiBinder.createAndBindUi(this));
		 
		 if (type.equals("statistics")) {
			    createStatisticsGrid();
				buttons.add(adminButton);
				buttons.add(userButton);								
	      }
		 
		 else if (type.equals("fileDownload")) {
			 createFileDownloadGrid();
			  buttons.add(organizeLocation);
			  buttons.add(organizeType);
		//	  buttons.add(organizeName);
			  buttons.add(filter);		     
	     }
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
		 final GroupingView<NameValue> view = new GroupingView<NameValue>();
		  view.setShowGroupedColumn(false);
		  view.setStripeRows(true);
		  view.setForceFit(true);
		  grid = new Grid<NameValue>(store, geneColumnModel);
		  grid.setView(view);
		  view.groupBy(cc2);
		  content.add(grid);				
	}
	public void createFileDownloadGrid() {
		//SET UP COLUMNS
		 List<ColumnConfig<NameValue, ?>> columnDefs = new ArrayList<ColumnConfig<NameValue, ?>>();
		 cc1 = new ColumnConfig<NameValue, String>(properties.name(), 200, "File Name");
		 cc2 = new ColumnConfig<NameValue, String>(properties.type(), 220, "File Type");
		 cc3 = new ColumnConfig<NameValue, String>(properties.value(), 200, "File Location");
		 columnDefs.add(cc1);
		 columnDefs.add(cc2);		
		 columnDefs.add(cc3);
         geneColumnModel = new ColumnModel<NameValue>(columnDefs);
		  store = new ListStore<NameValue>(properties.key());
		 final GroupingView<NameValue> view = new GroupingView<NameValue>();
		  view.setShowGroupedColumn(false);
		  view.setStripeRows(true);
		  view.setForceFit(true);
		  grid = new Grid<NameValue>(store, geneColumnModel);
		  grid.setView(view);
		  view.groupBy(cc2);
		  setFileDownloadClickHandlers(view);
		  content.add(grid);		
		  
	}
	
	public void populateGrid(ArrayList<NameValue> data)
	{
		store.replaceAll(data);
		Info.display("Notice", "data loaded");
	}
	
	public void setFileDownloadClickHandlers(final GroupingView<NameValue> view) 
	{
		organizeName.addSelectHandler(new SelectHandler() {
			public void onSelect(SelectEvent event) {
				  view.groupBy(cc1);			
			}});
	    organizeLocation.addSelectHandler(new SelectHandler() {
			 public void onSelect(SelectEvent event) {
					  view.groupBy(cc3);			
				}});
	    organizeType.addSelectHandler(new SelectHandler() {
			 public void onSelect(SelectEvent event) {
					  view.groupBy(cc2);			
				}});
		
	}
	
	/*void populateGrid()
	{
		myServer.getGenes(mode, new AsyncCallback<ArrayList<NameValue>>(){
			@Override
			public void onFailure(Throwable caught) {
				// TODO Auto-generated method stub
				Info.display("Error", "Cannot get roots from server");
			}
			@Override
			public void onSuccess(ArrayList<NameValue> result) 
			{
				store.replaceAll(result);
				Info.display("Notice", "getGenes ok");
			}
		});
		
	}*/
	/*@UiHandler("userButton")
	void collapse(SelectEvent event)
	{
		Info.display("Notice", "user button clicked");
		mode="user";
		populateGrid();
	}	
	
	@UiHandler("adminButton")
	void expand(SelectEvent event)
	{
		Info.display("Notice", "admin button clicked");
		mode="admin";	
		populateGrid();
	}*/

}
