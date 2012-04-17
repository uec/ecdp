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
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.ColumnModel;
import com.sencha.gxt.widget.core.client.grid.Grid;
import com.sencha.gxt.widget.core.client.grid.GroupingView;
import com.sencha.gxt.widget.core.client.info.Info;

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

	String mode = "user";
	ColumnModel<NameValue> geneColumnModel;
	ColumnConfig<NameValue, String> cc1,cc2,cc3;
	ListStore<NameValue> store;
	Grid<NameValue> grid;
	private static final NameValueModel properties = GWT.create(NameValueModel.class);

	public MetricGridWidget() {
		initWidget(uiBinder.createAndBindUi(this));
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
		//  populateGrid();
	}
	
	public void populateGrid(ArrayList<NameValue> data)
	{
		store.replaceAll(data);
		Info.display("Notice", "data loaded");
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
