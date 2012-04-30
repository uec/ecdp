package edu.usc.epigenome.eccp.client.pane.sampleReport;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.safehtml.shared.SafeHtml;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.text.shared.AbstractSafeHtmlRenderer;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HasVerticalAlignment.VerticalAlignmentConstant;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.cell.core.client.SimpleSafeHtmlCell;
import com.sencha.gxt.core.client.IdentityValueProvider;
import com.sencha.gxt.core.client.Style.SelectionMode;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.Dialog;
import com.sencha.gxt.widget.core.client.Dialog.PredefinedButton;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer.VerticalLayoutData;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.form.StoreFilterField;
import com.sencha.gxt.widget.core.client.form.TextArea;
import com.sencha.gxt.widget.core.client.grid.CheckBoxSelectionModel;
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
	
	@UiField ToolBar buttons;
	@UiField HorizontalPanel buttonsHP;
	@UiField VerticalLayoutContainer vlc;
	@UiField VerticalLayoutContainer content;
	@UiField ContentPanel gridPanel;
	
	 StoreFilterField<FileData> filter = new StoreFilterField<FileData>() {
			@Override
			protected boolean doSelect(Store<FileData> store, FileData parent, 	FileData item, String filter) 
			{
				if(item.getFullPath().contains(filter))
					return true;
				else
					return false;
			}
		};
		
	String mode = "user";
	ColumnModel<FileData> fileDataColumnModel;
	ColumnConfig<FileData, String> cc1,cc2,cc3,cc4;
	ListStore<FileData> store;
	Grid<FileData> grid;
	IdentityValueProvider<FileData> identity = new IdentityValueProvider<FileData>();
	CheckBoxSelectionModel<FileData> sm  = new CheckBoxSelectionModel<FileData>(identity);
	
	
	private static final FileDataModel properties = GWT.create(FileDataModel.class);

	public DownloadGridWidget() 
	{
		initWidget(uiBinder.createAndBindUi(this));
		createFileDownloadGrid();
		sm.setSelectionMode(SelectionMode.MULTI);
	}
	
	public DownloadGridWidget(List<FileData> data) 
	{
		initWidget(uiBinder.createAndBindUi(this));
		//ZR I hate this dirty hack for making the toolbar appear.
		buttonsHP.setVerticalAlignment(HasVerticalAlignment.ALIGN_TOP);
		createFileDownloadGrid();
		sm.setSelectionMode(SelectionMode.MULTI);
		buttonsHP.add(filter);
		populateGrid(data);	
		Widget w = vlc.getWidget(0);
		vlc.remove(0);
		vlc.insert(w, 0,new VerticalLayoutData(1400,50));
	}

	public void createFileDownloadGrid() {
		//SET UP COLUMNS
	     List<ColumnConfig<FileData, ?>> columnDefs = new ArrayList<ColumnConfig<FileData, ?>>();
		 cc1 = new ColumnConfig<FileData, String>(properties.name(), 300, "File Name");
		 cc2 = new ColumnConfig<FileData, String>(properties.type(), 220, "File Type");
		 cc3 = new ColumnConfig<FileData, String>(properties.location(), 200, "File Location");
		 cc4 = new ColumnConfig<FileData, String>(properties.downloadLocation(), 100, "Download");
		 cc4.setCell(new SimpleSafeHtmlCell<String>(new AbstractSafeHtmlRenderer<String>() 
		{
		      public SafeHtml render(String object) 
		      {  
		        return SafeHtmlUtils.fromTrustedString("<a target=\"new\" href=\"http://webapp.epigenome.usc.edu/ECCPBinder/retrieve.jsp?resource=" + object + " \">download</a>");		        
		      }
		}));
		 //columnDefs.add(sm.getColumn());
		 columnDefs.add(cc1);
		 columnDefs.add(cc2);		
		 columnDefs.add(cc3);
		 columnDefs.add(cc4);
         fileDataColumnModel = new ColumnModel<FileData>(columnDefs);
		 store = new ListStore<FileData>(properties.key());
		
		
		filter.bind(store);
		filter.setEmptyText("Search...");
		buttons.add(filter);
		 
		 
		 view = new GroupingView<FileData>();
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 view.setForceFit(true);
		 grid = new Grid<FileData>(store, fileDataColumnModel);
		 grid.setHeight(Window.getClientHeight() - 100);
		 sm.setSelectionMode(SelectionMode.SIMPLE);
		 grid.setView(view);
		 view.groupBy(cc2);
		 content.add(grid);
		 sm.bindGrid(grid);
	}

			
	
	public void populateGrid(List<FileData> data)
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
	
	@UiHandler("downloadSelected")
	public void showSelected(SelectEvent event)
	{
		String fileList = "";
		
		 for(FileData f : sm.getSelectedItems())
		 {
			 fileList += "http://webapp.epigenome.usc.edu/ECCPBinder/retrieve.jsp?resource=" + f.getDownloadLocation() + "\n";
		 }
		 
		 TextArea text = new TextArea();
		 text.setText(fileList);
		 final Dialog simple = new Dialog();
		 simple.setHeadingText("Paste these links into your favorite download tool (Ex: wget, DownloadThemAll etc)");
		 simple.setPredefinedButtons(PredefinedButton.YES, PredefinedButton.NO);
		 simple.setBodyStyleName("pad-text");
		 simple.add(text);
		 simple.setHideOnButtonClick(true);
		 simple.setWidth(600);
		 simple.setHeight(400);
		 simple.show();
	}
	
	@UiHandler("organizeLocation")
	public void groupByLocation(SelectEvent event)
	{
		 view.groupBy(cc3);
	}
}
