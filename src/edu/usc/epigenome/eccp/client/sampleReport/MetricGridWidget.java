package edu.usc.epigenome.eccp.client.sampleReport;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.google.gwt.cell.client.AbstractCell;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.safehtml.shared.SafeHtmlBuilder;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.core.client.util.Margins;
import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.SortDir;
import com.sencha.gxt.data.shared.Store;
import com.sencha.gxt.data.shared.Store.StoreSortInfo;
import com.sencha.gxt.data.shared.event.StoreFilterEvent;
import com.sencha.gxt.data.shared.event.StoreFilterEvent.StoreFilterHandler;
import com.sencha.gxt.dnd.core.client.DND.Operation;
import com.sencha.gxt.dnd.core.client.DndDropEvent;
import com.sencha.gxt.dnd.core.client.DropTarget;
import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.Dialog;
import com.sencha.gxt.widget.core.client.Dialog.PredefinedButton;
import com.sencha.gxt.widget.core.client.button.TextButton;
import com.sencha.gxt.widget.core.client.button.ToggleButton;
import com.sencha.gxt.widget.core.client.container.BorderLayoutContainer;
import com.sencha.gxt.widget.core.client.container.BorderLayoutContainer.BorderLayoutData;
import com.sencha.gxt.widget.core.client.container.HasLayout;
import com.sencha.gxt.widget.core.client.container.HorizontalLayoutContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;
import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer.VerticalLayoutData;
import com.sencha.gxt.widget.core.client.container.Viewport;
import com.sencha.gxt.widget.core.client.event.RowClickEvent;
import com.sencha.gxt.widget.core.client.event.RowClickEvent.RowClickHandler;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.form.StoreFilterField;
import com.sencha.gxt.widget.core.client.form.TextArea;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.ColumnModel;
import com.sencha.gxt.widget.core.client.grid.Grid;
import com.sencha.gxt.widget.core.client.info.Info;
import com.sencha.gxt.widget.core.client.menu.Item;
import com.sencha.gxt.widget.core.client.menu.Menu;
import com.sencha.gxt.widget.core.client.menu.MenuItem;
import com.sencha.gxt.widget.core.client.toolbar.ToolBar;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FileData;
import edu.usc.epigenome.eccp.client.data.LibraryData;
import edu.usc.epigenome.eccp.client.data.LibraryDataQuery;
import edu.usc.epigenome.eccp.client.data.LibraryProperty;
import edu.usc.epigenome.eccp.client.data.LibraryPropertyModel;
import edu.usc.epigenome.eccp.client.data.MultipleLibraryProperty;
import edu.usc.epigenome.eccp.client.data.MultipleLibraryPropertyModelFactory;
import edu.usc.epigenome.eccp.client.events.ECCPEventBus;
import edu.usc.epigenome.eccp.client.events.ShowGlobalTabEvent;
import edu.usc.epigenome.eccp.client.sampleReport.charts.BarChartWidget;
import edu.usc.epigenome.eccp.client.sampleReport.charts.MotionChartWidget;
import edu.usc.epigenome.eccp.client.sampleReport.charts.ScatterChartWidget;
import edu.usc.epigenome.eccp.client.sencha.ResizeGroupingView;

import com.sencha.gxt.widget.core.client.tips.QuickTip;

public class MetricGridWidget extends Composite implements HasLayout{

	private static MetricGridUiBinder uiBinder = GWT.create(MetricGridUiBinder.class);

	interface MetricGridUiBinder extends UiBinder<Widget, MetricGridWidget> {
	}
	ECServiceAsync myServer = (ECServiceAsync) GWT.create(ECService.class);
	HashMap<String,MultipleLibraryProperty> mergedLibraryData;
	HashMap<String,MultipleLibraryProperty> currentLibraryData;
	HashMap<String,LibraryProperty> tooltips= new HashMap<String,LibraryProperty>();
	List<LibraryData> libraries;
	@UiField ContentPanel gridPanel;
	@UiField VerticalLayoutContainer content;
	
	@UiField ToolBar buttons;
	@UiField HorizontalPanel buttonsHP;
	@UiField VerticalLayoutContainer vlc;
	@UiField TextButton mergeLibs;
	//@UiField TextButton viewButton;
	@UiField ToggleButton unused;
	String usageMode = "admin";
	List<LibraryData> data;
	ResizeGroupingView<MultipleLibraryProperty> viewPointer;
	Grid<MultipleLibraryProperty> gridPointer;
	ListStore<MultipleLibraryProperty> store=new ListStore<MultipleLibraryProperty>(properties.key());
    
	
	//handle live filtering of metrics, match multiple properties against filter txt
	StoreFilterField<MultipleLibraryProperty> filter = new StoreFilterField<MultipleLibraryProperty>() 
	{
		@Override
		protected boolean doSelect(Store<MultipleLibraryProperty> store, MultipleLibraryProperty parent,MultipleLibraryProperty item, String filter) 
		{
			boolean match = false;
			boolean prettyMatch = false;
			
			
			
				for(String token : filter.split("\\s"))
				{
					if(item.getPrettyName() != null)
						prettyMatch = item.getPrettyName().toLowerCase().contains(token.toLowerCase());
					
					match = match || prettyMatch ||	item.getName().toLowerCase().contains(token.toLowerCase());
				   
				}
				return match;	
		}
	
	    };

	private static final LibraryPropertyModel properties = GWT.create(LibraryPropertyModel.class);

	public MetricGridWidget() {
		initWidget(uiBinder.createAndBindUi(this));
		//	createGridColumns();
		buttons.add(filter);
		
	}
	
	public MetricGridWidget(List<LibraryData> data) 
	{
		initWidget(uiBinder.createAndBindUi(this));
		this.data=data;
		this.setLayoutData(new VerticalLayoutData(-1,-1));
		vlc.setLayoutData(new VerticalLayoutData(-1,-1));
		filter.setEmptyText("Search...");
		buttonsHP.add(filter);		
		libraries = data;
		if(libraries.size() < 2)
			mergeLibs.disable();
		//createMenu();
	    if(Window.Location.getQueryString().length() > 0 || Window.Location.getHref().contains("ecdp-demo"))
		   buttonsHP.remove(unused);
	//	System.out.println(Window.Location.getHref());
	//    	viewButton.getMenu().getWidget(2).setVisible(false);
		
	    makeToolTips();
		mergeData();
		filter.bind(store);
		/*store.addStoreFilterHandler(new StoreFilterHandler<MultipleLibraryProperty>() {

			@Override
			public void onFilter(StoreFilterEvent<MultipleLibraryProperty> event) {
				// TODO Auto-generated method stub
			//	System.out.println("Here in filter handler");
				 if (store.size() == 0) {
					 if (usageMode.equals("user")) {
					     setUsageMode("admin");
					     setHeadingText("Metrics - Advanced View");
					 }
			     
			}	
				 logToServer("Search:" +filter.getText());	
			}});*/
		
		currentLibraryData=getUsageModeData(); 
		drawTable();
	}
	
	//merge all selected/added libraries into a single object for display purposes
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
				m.setPrettyName(p.getPrettyName());
				m.setValidation(p.getValidation());
				while(m.getValueSize() < i)
					m.addValue("");
				m.addValue(p.getValue());
			}
		}
		mergedLibraryData = libdata;	
	}
	
	
	
	//creates the table based upon the currently selected libraries. when new libraries are drag-n-dropped into the table, add them and redraw
	public void drawTable() 
	{
	//	 filter.clear();
		// store.clear();
		//SET UP COLUMNS
		 List<ColumnConfig<MultipleLibraryProperty, ?>> columnDefs = new ArrayList<ColumnConfig<MultipleLibraryProperty, ?>>();
		 ColumnConfig<MultipleLibraryProperty, String> cc1 = new ColumnConfig<MultipleLibraryProperty, String>(properties.prettyName(), 250, "Metric");
		 ColumnConfig<MultipleLibraryProperty, String> cc2 = new ColumnConfig<MultipleLibraryProperty, String>(properties.category(), 220, "Category");
		 columnDefs.add(cc1);
		 columnDefs.add(cc2);
		 cc1.setCell(new AbstractCell<String>() {
			@Override
			public void render(Context context,String value, SafeHtmlBuilder sb) {
				
			    LibraryProperty temp = tooltips.get(value);
			    String description =(temp.getDescription()).replaceAll("\"","'");
			    String displayName="";
			    displayName = value;
		//		if (temp.getPrettyName() == null) displayName=temp.getName();			 					 
		//		else displayName=temp.getPrettyName();		
				sb.appendHtmlConstant(
									   "<span qtip=\""+
					//	               "<b>Description: </b> "+
						                description+
					//	                " <hr/>"+
						               " <br/><b>Generated by:</b> " +
						                temp.getSource() +
						               " <br/><b>Other name:</b></br>" + temp.getName()+
						               "\">" +						           
						                displayName+
						                "</span>");
				   
			}	 
		 });
	 
		 for(int i = 0 ; i < mergedLibraryData.get("flowcell_serial").getValueSize(); i++)
		 {
			 ColumnConfig<MultipleLibraryProperty, String> cc = new ColumnConfig<MultipleLibraryProperty, String>(MultipleLibraryPropertyModelFactory.getValueProvider(i), 220, mergedLibraryData.get("sample_name").getValue(i));
			 cc.setCell(new AbstractCell<String>() {
					@Override
					public void render(Context context,String value, SafeHtmlBuilder sb) 
					{
						if(value == null)
							sb.appendHtmlConstant("N/A");
						else if(value.equals("0"))
							sb.appendHtmlConstant("N/A");
						else if(value.length() > 100 && value.substring(1, 99 ).contains("JSON"))
							sb.appendHtmlConstant("Multi-dimensional data, click for chart");
						else
							sb.appendHtmlConstant(value);
						    	  

						 MultipleLibraryProperty m = store.get(context.getIndex()); 
						 String formula = m.getValidation();
						  if(formula != null && formula.length() > 3)
						  {
				    		  formula = formula.replace("x",value.replace(",","")); 
				    		  String eval = evalQC(formula + " ? 'Pass' : 'Fail' "); 
				    		  if(eval.contains("Fail"))
				    			  sb.appendHtmlConstant("<span style=\"color:red\" qtip=\"qc warning: value is not in expected range: " + formula.replace("&&", "AND").replace("||", "OR" ).replace("&", "AND").replace("|", "OR" ) + " is not true.\"><img align=\"bottom\" src=\"images/warning-small.gif\"></span>");
						  }
						
					}
			});
			columnDefs.add(cc);			 
		 }		 
		 
		 ColumnModel<MultipleLibraryProperty> colModel = new ColumnModel<MultipleLibraryProperty>(columnDefs);
		 ResizeGroupingView<MultipleLibraryProperty> view = new ResizeGroupingView<MultipleLibraryProperty>();
		//relpaced with our own grouping view that better does resizing of windows
		// GroupingView<MultipleLibraryProperty> view = new GroupingView<MultipleLibraryProperty>();
		 view.setShowGroupedColumn(false);
		 view.setStripeRows(true);
		 for(int i=2; i < columnDefs.size(); i++)
		 {
			 view.setAutoExpandColumn(columnDefs.get(i));
		 }
		 view.setAutoExpandMin(100);
		 view.setAutoExpandMax(2000);
		 view.collapseAllGroups();
		 view.groupBy(cc2);
		 viewPointer=view;
		 final	Grid<MultipleLibraryProperty> grid = new Grid<MultipleLibraryProperty>(store, colModel);
		 grid.setHeight(Window.getClientHeight() - 110);
		 gridPointer = grid;		 
	//	 grid.setWidth(Window.getClientWidth() - 600);
		 gridPointer.setView(viewPointer);
		 gridPointer.setAllowTextSelection(true);
		 content.add(gridPointer);				
		 QuickTip q =new QuickTip(gridPointer); // Add ToolTips to the grid cells in column cc1
		 q.getToolTipConfig().setTrackMouse(true);
		 q.getToolTipConfig().setDismissDelay(2000000000);
		 
		// ToolTipConfig ttc= new ToolTipConfig();
		// q.setToolTipConfig(ttc);
		// q.getElement().getStyle().setBackgroundColor("background-color: red");
		 store.replaceAll(new ArrayList<MultipleLibraryProperty>(currentLibraryData.values()));
		 //Handle Drag and drop of libraries from the samplelist to the main metric table
		 DropTarget target = new DropTarget(gridPointer)
		 {
		      @Override
		      protected void onDragDrop(DndDropEvent event) 
		      {
		        super.onDragDrop(event);
		        @SuppressWarnings("unchecked")
				ArrayList<LibraryData> droppedSummarizedLibs = (ArrayList<LibraryData>) event.getData();
		        for(LibraryData summarizedLibrary : droppedSummarizedLibs)
		        {
		        	logToServer("Libraries Dragged and Dropped to Metrics: " +  summarizedLibrary.get("flowcell_serial").getValue() + ":" + summarizedLibrary.get("geneusID_sample").getValue());
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
							    Boolean contains = false;
								for (LibraryData lib: libraries) {
								       for (LibraryData l : result) {
							    	        if (l.get("id_run_sample").getValue().equals(lib.get("id_run_sample").getValue()))
							    	        	contains=true;
							            }
								}
								if (!contains) 
								{
									libraries.addAll(result);
									if(libraries.size() < 2 || Window.Location.getHref().contains("gareports"))
										mergeLibs.disable();
									else
										mergeLibs.enable();
								//	Info.display("Notice","added to table:" + result.get(0).get("sample_name").getValue());
								}
							   
							    content.remove(0);
						        mergeData();
						        currentLibraryData=getUsageModeData();
								drawTable();
								forceLayout();
				        	
							}
					});
		        }
		      }
		 };
		 target.setOperation(Operation.COPY);
		 
		 //Plot the current row
		 gridPointer.addRowClickHandler(new RowClickHandler()
		 {
			@Override
			public void onRowClick(RowClickEvent event)
			{
				MultipleLibraryProperty clickedItem = store.get(event.getRowIndex());
				plot(clickedItem);
			}
		});
         StoreSortInfo<MultipleLibraryProperty> sortByPrettyName = new StoreSortInfo<MultipleLibraryProperty>(cc1.getValueProvider(), SortDir.ASC);
         gridPointer.getStore().addSortInfo(sortByPrettyName);
	     
	}
	
	//set the title in the top bar
	public void setHeadingText(String title)
	{
		gridPanel.setHeadingText(title);
	}

	//display the download-files widget for these libraries
	@UiHandler("download")
	public void downloadFile(SelectEvent event)
	{
		List<FileData> files = new ArrayList<FileData>();
		for(LibraryData lib : libraries)
		{
			files.addAll(lib.getFiles());
		}
		DownloadGridWidget download = new DownloadGridWidget(files);
		ECCPEventBus.EVENT_BUS.fireEvent(new ShowGlobalTabEvent(download,"files: " +  libraries.get(0).get("sample_name").getValue() + (libraries.size() > 1 ? (" + " + (libraries.size() -1)) + " other libs" : "")));
		logToServer("DownloadFile");
	}
	
	//display the current table as a tab-delim textbox for pasting in excel
	@UiHandler("toSpreadSheet")
	public void showCSV(SelectEvent event)
	{

		List<ColumnConfig<MultipleLibraryProperty, ?>> configs = gridPointer.getColumnModel().getColumns();
		String header = "Metric Name in Database";
		ArrayList <String> rows= new ArrayList<String>();		
		rows.add("Metric Name in Database");

		for (ColumnConfig<MultipleLibraryProperty, ?> col: configs) {
			header = col.getHeader().asString();
			rows.add(header);
			
		}
	
			for(MultipleLibraryProperty metric : gridPointer.getStore().getAll()) {
				
				ArrayList <String> lines= new ArrayList<String>();
	
				// Metric name in db (pretty name) is always the first row in lines.
				lines.add(metric.getPrettyName());
				
				// The order in which  metrics are added to lines should correspond to the order in columndefs list
				lines.add(metric.getName());
				lines.add(metric.getCategory());

				for (int i = 0; i < metric.getValueSize(); i++) {
				  if (metric.getValue(i) !=null && !metric.getValue(i).equals("0")) {
					
					  if (metric.getValue(i).contains("JSON")) {
				  //		System.out.println("Found JSON");
						    lines.add("Multi-Dimensional Data");
					  }
					 else lines.add(metric.getValue(i).replaceAll("\\r|\\n", ""));
					  
				  }
				  else lines.add("N/A");
				    
				}
				for (int i=0; i < rows.size(); i++ ) {
					
					String t = rows.get(i);
					rows.set(i, t+"\t"+lines.get(i));
				}
		    
		}
			String csv="";
			for (String r : rows) {
				csv= csv + r +"\n"; 
			}

		 TextArea text = new TextArea();
		 text.setText(csv);
		 final Dialog simple = new Dialog();
		 simple.setHeadingText("Tab-separated metrics (Paste into Excel)");
		 simple.setPredefinedButtons(PredefinedButton.OK);
		 simple.setBodyStyleName("pad-text");
		 simple.add(text);
		 simple.setHideOnButtonClick(true);
		 simple.setWidth(700);
		 simple.setHeight(500);
		 simple.show();
		 logToServer("toSpreadSheet");
	}	

	@UiHandler("mergeLibs")
	public void createMerge(SelectEvent event)
	{
		logToServer("Merging Workflow");
		myServer.createMergeWorkflow(libraries, new AsyncCallback<String>(){

			@Override
			public void onFailure(Throwable caught)
			{
				Info.display("ERROR","could not create merging workflow");				
			}

			@Override
			public void onSuccess(String result)
			{
				 TextArea text = new TextArea();
				 text.setText(result);
				 final Dialog simple = new Dialog();
				 simple.setHeadingText("merging workflow (Pastable at hpcc)");
				 simple.setPredefinedButtons(PredefinedButton.OK);
				 simple.setBodyStyleName("pad-text");
				 simple.add(text);
				 simple.setHideOnButtonClick(true);
				 simple.setWidth(700);
				 simple.setHeight(500);
				 simple.show();				
			}});
	}
	
	public HashMap<String,MultipleLibraryProperty> getUsageModeData() {
     //   System.out.println("Usage mode: "+usageMode);
		HashMap<String,MultipleLibraryProperty> templibdata = new HashMap<String,MultipleLibraryProperty>();
		if (usageMode.equals("user")) {
		//	Info.display("Notice", "User view");
			for (String m: mergedLibraryData.keySet() ) {
				MultipleLibraryProperty multiProperty = mergedLibraryData.get(m);
				if (multiProperty.getUsage().equals("4")) templibdata.put(m, multiProperty);				
			}
		}
		if (usageMode.equals("admin")) {
		//	Info.display("Notice", "Admin view");
			for (String m: mergedLibraryData.keySet() ) {
				MultipleLibraryProperty multiProperty = mergedLibraryData.get(m);
			//	System.out.println("Admin view: "+multiProperty.getUsage());
				if (multiProperty.getUsage().matches("1|4")) templibdata.put(m, multiProperty);				
			}
		}
		if (usageMode.equals("other")) {
			for (String m: mergedLibraryData.keySet() ) {
				MultipleLibraryProperty multiProperty = mergedLibraryData.get(m);
			//	System.out.println("Unused view: "+multiProperty.getUsage()+"\tName:"+multiProperty.getName());
				if (multiProperty.getUsage().matches("0")) templibdata.put(m, multiProperty);								
			}
			if (templibdata.isEmpty()) {
				System.out.println("Empty templibdata");
				return currentLibraryData;
			}			
		}		
		return templibdata;
	}
	
	//create a plot of a clicked library metric
	public void plot(final MultipleLibraryProperty metric)
	{
		logToServer("Plotting Chart of  " + metric.getName());
		if(metric.getAllValues().contains("JSON") && metric.getAllValues().contains("Scatter Plot"))
		{
			ScatterChartWidget s = new ScatterChartWidget(metric,libraries);
			s.show();
		}
		else if(metric.getAllValues().contains("JSON") && metric.getAllValues().contains("Motion Plot"))
		{
			MotionChartWidget w = new MotionChartWidget(metric.getValue(0).replace("JSON Motion Plot ", ""));
			w.show();
		}
		else
		{
			BarChartWidget b = new BarChartWidget(metric,libraries);
			b.show();
		}
	}

	public void makeToolTips () 
	{
		for(int i = 0; i < libraries.size() ; i ++){
			for(String key : libraries.get(i).keySet()) {
			       LibraryProperty p = libraries.get(i).get(key);
		    	   tooltips.put(p.getPrettyName(), p);			       
		    }		
		}
	}
	/*public void createMenu() {
		Menu viewMenu = new Menu();
		MenuItem item1 = new MenuItem();
		item1.setText("Summary Metrics");		
		MenuItem item2 = new MenuItem();
		item2.setText("Advanced Metrics");
		MenuItem item3 = new MenuItem();
		item3.setText("Unused Metrics");
		viewMenu.add(item1);
		viewMenu.add(item2);
		viewMenu.add(item3);
		viewButton.setMenu(viewMenu);
		viewMenu.addSelectionHandler(new SelectionHandler<Item>(){
			@Override
			public void onSelection(SelectionEvent<Item> event) {						
				 MenuItem item = (MenuItem) event.getSelectedItem();
				     filter.setText("");
				 if (item.getText().equals("Summary Metrics")) {
					 usageMode="user";
					 setHeadingText("Metrics - Summary View");
				 }
				 else if(item.getText().equals("Advanced Metrics")) {
					 usageMode="admin"; 
					 setHeadingText("Metrics - Advanced View");
					 logToServer("AdvancedView");
				 }
				 else if(item.getText().equals("Unused Metrics")) {
					 usageMode="other";
					 setHeadingText("Metrics - Unused Metrics View");
					 logToServer("UnusedView");
				 }
				 currentLibraryData=getUsageModeData(); 
				 content.remove(0);
			     drawTable();
				 }										 					
		});
	}*/
	@UiHandler("unused")
	public void toggle(ValueChangeEvent<Boolean> event)
	{
		if (event.getValue() == true) {
		//	Info.display("Info", "button pressed");
			 usageMode="other";
			 setHeadingText("Metrics - Unused Metrics View");
			 //unused.setText("Normal");
			 logToServer("UnusedView");
			 			
		}
		else {
			 usageMode="admin"; 
			 setHeadingText("Metrics");
			// unused.setText("Unused");
			 logToServer("AdvancedView");
		}
		 currentLibraryData=getUsageModeData(); 
		 content.remove(0);
	     drawTable();
	}
	@Override
	public void forceLayout() {
		// TODO Auto-generated method stub
		viewPointer.doResize();
		vlc.forceLayout();
		content.forceLayout();
    	gridPointer.setHeight(Window.getClientHeight()-110);
		
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
	public void setUsageMode(String mode) {
		usageMode=mode;
    	currentLibraryData=getUsageModeData(); 	
		ListStore<MultipleLibraryProperty> store = gridPointer.getStore();
		store.replaceAll(new ArrayList<MultipleLibraryProperty>(currentLibraryData.values()));
		
	}
    public void logToServer(String text) 
    {
    	 myServer.logWriter("MetricGrid: " + text, new AsyncCallback<String>(){
			@Override
			public void onFailure(Throwable caught) { }

			@Override
			public void onSuccess(String result) {
				//do nothing
			}
		 });
    }
    
	public static native String evalQC(String arg) /*-{
    eval("var myVar = " + arg + ";");
    return myVar;
}-*/;
	
}
	

