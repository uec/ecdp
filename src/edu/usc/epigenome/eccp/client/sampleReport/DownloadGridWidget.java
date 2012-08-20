package edu.usc.epigenome.eccp.client.sampleReport;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.google.gwt.cell.client.AbstractCell;
import com.google.gwt.cell.client.Cell.Context;
import com.google.gwt.core.client.GWT;
import com.google.gwt.safehtml.shared.SafeHtml;
import com.google.gwt.safehtml.shared.SafeHtmlBuilder;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.text.shared.AbstractSafeHtmlRenderer;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
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
import com.sencha.gxt.widget.core.client.container.HasLayout;
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
import com.sencha.gxt.widget.core.client.tips.QuickTip;
import com.sencha.gxt.widget.core.client.toolbar.ToolBar;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FileData;
import edu.usc.epigenome.eccp.client.data.FileDataModel;
import edu.usc.epigenome.eccp.client.data.LibraryProperty;
import edu.usc.epigenome.eccp.client.sencha.ResizeGroupingView;


public class DownloadGridWidget extends Composite implements HasLayout
{
	private static DownloadGridWidgetUiBinder uiBinder = GWT.create(DownloadGridWidgetUiBinder.class);
	interface DownloadGridWidgetUiBinder extends UiBinder<Widget, DownloadGridWidget> 	{}
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);
	ResizeGroupingView<FileData> view = new ResizeGroupingView<FileData>();
	
	@UiField ToolBar buttons;
	@UiField HorizontalPanel buttonsHP;
	@UiField VerticalLayoutContainer vlc;
	@UiField VerticalLayoutContainer content;
	@UiField ContentPanel gridPanel;
	
	 StoreFilterField<FileData> filter = new StoreFilterField<FileData>() {
			@Override
			protected boolean doSelect(Store<FileData> store, FileData parent, 	FileData item, String filter) 
			{
				return item.getFullPath().toLowerCase().contains(filter.toLowerCase());					
			}
		};
		
	String mode = "user";
	ColumnModel<FileData> fileDataColumnModel;
	ColumnConfig<FileData, String> cc1,cc2,cc3,cc4;
	ListStore<FileData> store;
	Grid<FileData> grid;
	List<FileData> fileData;
	HashMap<String,String> tooltips= new HashMap<String,String> ();
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
		fileData=data;
		this.setLayoutData(new VerticalLayoutData(-1,-1));
		vlc.setLayoutData(new VerticalLayoutData(-1,-1));
		//ZR I hate this dirty hack for making the toolbar appear.
		buttonsHP.setVerticalAlignment(HasVerticalAlignment.ALIGN_TOP);
		createFileDownloadGrid();
		sm.setSelectionMode(SelectionMode.MULTI);
		buttonsHP.add(filter);
		populateGrid(fileData);	
		makeToolTips();
		Widget w = vlc.getWidget(0);
		vlc.remove(0);
		vlc.insert(w, 0,new VerticalLayoutData(-1,-1));
	}

	public void createFileDownloadGrid() {
		//SET UP COLUMNS
	     List<ColumnConfig<FileData, ?>> columnDefs = new ArrayList<ColumnConfig<FileData, ?>>();
		 cc1 = new ColumnConfig<FileData, String>(properties.name(), 300, "File Name");
		 cc1.setCell(new AbstractCell<String>() {
				@Override
				public void render(Context context,String value, SafeHtmlBuilder sb) {
					
				    String description = tooltips.get(value).replaceAll("\"","'");	
					sb.appendHtmlConstant( "<span qtip=\""+
						//	               "<b>Description: </b> "+
							                description+"\"> <img src=\"/Users/natalia/Desktop/pics_2.png\"/>"+
						                    value +"</span>");			              					   
				}	 
			 });
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
		 
		 
		 view = new ResizeGroupingView<FileData>();
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 view.setForceFit(true);
		 grid = new Grid<FileData>(store, fileDataColumnModel);
		 grid.setHeight(Window.getClientHeight() - 130);
		 sm.setSelectionMode(SelectionMode.SIMPLE);
		 grid.setView(view);
		 view.groupBy(cc2);
		 content.add(grid);
		 sm.bindGrid(grid);
		 QuickTip q =new QuickTip(grid);
	}

	List<FileData>  filterLameFiles(List<FileData> data)
	{
		ArrayList<FileData> ret = new ArrayList<FileData>();
		for(FileData f : data)
		{
			if(f.getName().contains("ContamCheck")) continue;
			if(f.getName().contains("BinDepths")) continue;
			if(f.getName().contains("DownsampleDups")) continue;
			if(f.getName().contains("flagstat")) continue;
			
			ret.add(f);
		}
		return ret;
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
			 fileList += "https://webapp.epigenome.usc.edu/gareports/retrieve.jsp?resource=" + f.getDownloadLocation() + "\n";
		 }
		 
		 TextArea text = new TextArea();
		 text.setText(fileList);
		 final Dialog simple = new Dialog();
		 simple.setHeadingText("Paste these secure links into your favorite download tool (Ex: wget, DownloadThemAll etc)");
		 simple.setPredefinedButtons(PredefinedButton.OK);
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
	public void makeToolTips() {
		for (FileData d: fileData) {
			tooltips.put(d.getName(), d.getDescription());
		}
	}

	@Override
	public void forceLayout() {
		// TODO Auto-generated method stub
		view.doResize();
		vlc.forceLayout();
		content.forceLayout();
		grid.setHeight(Window.getClientHeight()-110);
		
	}

	@Override
	public boolean isLayoutRunning() {
		// TODO Auto-generated method stub
		return false;
	}

	
	
	@Override
	public boolean isOrWasLayoutRunning() {
		// TODO Auto-generated method stub
		return false;
	}
}
