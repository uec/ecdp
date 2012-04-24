package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;

import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.event.RowClickEvent;
import com.sencha.gxt.widget.core.client.event.RowClickEvent.RowClickHandler;
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
import edu.usc.epigenome.eccp.client.data.FileData;
import edu.usc.epigenome.eccp.client.data.FileDataModel;


public class DownloadGridWidget extends Composite
{
	private static DownloadGridWidgetUiBinder uiBinder = GWT.create(DownloadGridWidgetUiBinder.class);
	interface DownloadGridWidgetUiBinder extends UiBinder<Widget, DownloadGridWidget> 	{}
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);
	GroupingView<FileData> view = new GroupingView<FileData>();
	
	@UiField VerticalLayoutContainer content;
	@UiField ToolBar buttons;
	@UiField ContentPanel gridPanel;
	
	
	StoreFilterField<FileData> filter = new StoreFilterField<FileData>() {
		@Override
		protected boolean doSelect(Store<FileData> store, FileData parent,
				FileData item, String filter) {
			// TODO Auto-generated method stub
			return false;
		}
	};
	String mode = "user";
	ColumnModel<FileData> fileDataColumnModel;
	ColumnConfig<FileData, String> cc1,cc2,cc3;
	ListStore<FileData> store;
	Grid<FileData> grid;
	private static final FileDataModel properties = GWT.create(FileDataModel.class);

	public DownloadGridWidget() {
		initWidget(uiBinder.createAndBindUi(this));
		createFileDownloadGrid();
		buttons.add(filter);
	}

	public void createFileDownloadGrid() {
		//SET UP COLUMNS
		 List<ColumnConfig<FileData, ?>> columnDefs = new ArrayList<ColumnConfig<FileData, ?>>();
		 cc1 = new ColumnConfig<FileData, String>(properties.name(), 200, "File Name");
		 cc2 = new ColumnConfig<FileData, String>(properties.type(), 220, "File Type");
		 cc3 = new ColumnConfig<FileData, String>(properties.location(), 200, "File Location");
		 columnDefs.add(cc1);
		 columnDefs.add(cc2);		
		 columnDefs.add(cc3);
         fileDataColumnModel = new ColumnModel<FileData>(columnDefs);
		 store = new ListStore<FileData>(properties.key());
		 view = new GroupingView<FileData>();
		 
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 view.setForceFit(true);
		 grid = new Grid<FileData>(store, fileDataColumnModel);
		 grid.setView(view);
		 view.groupBy(cc2);
		 content.add(grid);
		 grid.addRowClickHandler(new RowClickHandler(){

			@Override
			public void onRowClick(RowClickEvent event)
			{
				//TODO add multi download
				int i = event.getRowIndex();
				FileData f = store.get(i);
				Window.open("http://webapp.epigenome.usc.edu/ECCPBinder/retrieve.jsp?resource=" + f.getDownloadLocation(), "downloading " + f.getName(), "enabled");
			}});
	}
	
	public void populateGrid(ArrayList<FileData> data)
	{
		store.replaceAll(data);
		Info.display("Notice", "data loaded");
	}
	
	public void setHeadingText(String title)
	{
		gridPanel.setHeadingText(title);
	}
	
	@UiHandler("organizeType")
	public void groupByType(SelectEvent event)
	{
		 view.groupBy(cc2);
	}
	
	@UiHandler("organizeLocation")
	public void groupByLocation(SelectEvent event)
	{
		 view.groupBy(cc3);
	}
}
