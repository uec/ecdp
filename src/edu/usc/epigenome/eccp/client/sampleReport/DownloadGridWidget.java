package edu.usc.epigenome.eccp.client.sampleReport;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.google.gwt.cell.client.AbstractCell;

import com.google.gwt.core.client.GWT;
import com.google.gwt.safehtml.shared.SafeHtml;
import com.google.gwt.safehtml.shared.SafeHtmlBuilder;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.text.shared.AbstractSafeHtmlRenderer;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasVerticalAlignment;
import com.google.gwt.user.client.ui.HorizontalPanel;

import com.google.gwt.user.client.ui.Widget;
import com.sencha.gxt.cell.core.client.SimpleSafeHtmlCell;
import com.sencha.gxt.core.client.IdentityValueProvider;
import com.sencha.gxt.core.client.Style.SelectionMode;
import com.sencha.gxt.core.client.XTemplates;

import com.sencha.gxt.data.shared.ListStore;
import com.sencha.gxt.data.shared.Store;

import com.sencha.gxt.widget.core.client.ContentPanel;
import com.sencha.gxt.widget.core.client.Dialog;

import com.sencha.gxt.widget.core.client.Dialog.PredefinedButton;
import com.sencha.gxt.widget.core.client.button.TextButton;
import com.sencha.gxt.widget.core.client.container.HasLayout;
import com.sencha.gxt.widget.core.client.container.HtmlLayoutContainer;

import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer;

import com.sencha.gxt.widget.core.client.container.VerticalLayoutContainer.VerticalLayoutData;
import com.sencha.gxt.widget.core.client.event.SelectEvent;
import com.sencha.gxt.widget.core.client.form.StoreFilterField;
import com.sencha.gxt.widget.core.client.form.TextArea;
import com.sencha.gxt.widget.core.client.grid.CheckBoxSelectionModel;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.ColumnModel;
import com.sencha.gxt.widget.core.client.grid.Grid;

import com.sencha.gxt.widget.core.client.grid.GroupingView.GroupingData;

import com.sencha.gxt.widget.core.client.info.Info;
import com.sencha.gxt.widget.core.client.tips.QuickTip;
import com.sencha.gxt.widget.core.client.toolbar.ToolBar;
import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.FileData;
import edu.usc.epigenome.eccp.client.data.FileDataModel;

import edu.usc.epigenome.eccp.client.sencha.ResizeGroupingView;

import com.sencha.gxt.widget.core.client.container.AbstractHtmlLayoutContainer.HtmlData;
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
	@UiField TextButton help;
	 StoreFilterField<FileData> filter = new StoreFilterField<FileData>() {
			@Override
			protected boolean doSelect(Store<FileData> store, FileData parent, 	FileData item, String filter) 
			{
				return item.getFullPath().toLowerCase().contains(filter.toLowerCase());					
			}
		};
	HTML video = new HTML("&nbsp&nbspWatch:&nbsp<a target=\"new\" href=\"http://www.youtube.com/watch?v=jPH3YPVc4x4\">\"Downloading a file on hpcc\"</a>",true);
	String mode = "user";
	ColumnModel<FileData> fileDataColumnModel;
	ColumnConfig<FileData, String> cc1,cc2,cc3,cc4,cc5;
	ListStore<FileData> store;
	Grid<FileData> grid;
	List<FileData> fileData;
//	HashMap<String,String> tooltips= new HashMap<String,String> ();
	HashMap<String,FileData> tooltips = new HashMap<String,FileData>();
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
		// This if-else hides "Unknown" group and "Internal pipeline files" group from a regular user
		if(Window.Location.getQueryString().length() > 0 || Window.Location.getHref().contains("ecdp-demo") )
		      fileData=filterFileData(data);
		else fileData=data;
		this.setLayoutData(new VerticalLayoutData(-1,-1));
		vlc.setLayoutData(new VerticalLayoutData(-1,-1));
		//ZR I hate this dirty hack for making the toolbar appear.
		buttonsHP.setVerticalAlignment(HasVerticalAlignment.ALIGN_TOP);
		createFileDownloadGrid();
		sm.setSelectionMode(SelectionMode.MULTI);
		buttonsHP.add(filter);
	//	buttonsHP.add(video);		
	//	help.setVisible(false);
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
					
					FileData d =  tooltips.get(value);
				//	System.out.println("Name: "+d.getName()+ " Value: "+value);
				    String description = d.getDescription().replaceAll("\"","'");				        				    
					sb.appendHtmlConstant( "<span qtip=\""+
						//	               "<b>Description: </b> "+
						//	                description+"\"> <img src=\"/Users/natalia/Desktop/pics_2.png\"/>"+
		                                    description+"\"> "+
						                    value +"</span>");							                   			
				}	 
			 } 
			 );
		
		 cc2 = new ColumnConfig<FileData, String>(properties.type(), 220, "File Type");
		 cc3 = new ColumnConfig<FileData, String>(properties.location(), 200, "File Location");
		 cc4 = new ColumnConfig<FileData, String>(properties.downloadLocation(), 100, "Download");
		 cc4.setCell(new SimpleSafeHtmlCell<String>(new AbstractSafeHtmlRenderer<String>() 
		{
		      public SafeHtml render(String object) 
		      {  
		    	if (Window.Location.getHref().contains("ecdp-demo") ) return SafeHtmlUtils.fromTrustedString("<a href=\"#donothing\">download</a>");
		    	else return SafeHtmlUtils.fromTrustedString("<a target=\"new\" href=\"retrieve.jsp?resource=" + object + " \">download</a>");
		      }
		}));
		 cc5 = new ColumnConfig<FileData, String>(properties.size(), 50, "Size");
		 
		 //columnDefs.add(sm.getColumn());
		 columnDefs.add(cc1);
		 columnDefs.add(cc2);		
		 columnDefs.add(cc3);
		 columnDefs.add(cc5);
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
		 grid.setAllowTextSelection(true);
		 grid.setView(view);
		 view.groupBy(cc2);
		 content.add(grid);
		 sm.bindGrid(grid);		
		 QuickTip q =new QuickTip(grid);
		 q.getToolTipConfig().setTrackMouse(true);
		 q.getToolTipConfig().setDismissDelay(2000000000);
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
		gridPanel.setHeading(title);
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
		 simple.setHeading("Paste these secure links into your favorite download tool (Ex: wget, DownloadThemAll etc)");
		 simple.setPredefinedButtons(PredefinedButton.OK);
		 simple.setBodyStyleName("pad-text");
		 simple.add(text);
		 simple.setHideOnButtonClick(true);
		 simple.setWidth(600);
		 simple.setHeight(400);
		 simple.show();
	}
	@UiHandler("downloadSelected")
	public void helpMenu(SelectEvent event) {
		
	}
	public List<FileData> filterFileData(List <FileData> datalist) {
		
		List<FileData> filteredData = new ArrayList<FileData>();
		for (int i=0; i < datalist.size(); i++) {
			FileData d = datalist.get(i);
			if (!d.getType().matches(".*[Ii]nternal.+[Pp]ipeline.+[Ff]iles.*|Unknown.*"))
				filteredData.add(d);
		}
		return filteredData;
	}
	public void setLastGroupCollapsed() {
		 // I used getGroups() source code from GroupingView class as an example
		 GroupingData<FileData> curGroup = null;
		 List<GroupingData<FileData>> groups = new ArrayList<GroupingData<FileData>>();
         for (int i = 0, len = store.size(); i < len; i++) {
            FileData m = store.get(i);
            String gvalue = cc2.getValueProvider().getValue(m);
            System.out.println("Group gvalue: "+gvalue+" "+ m.getName());
            String s="";
            if (curGroup==null)
            	s="Null";
            else s=curGroup.getValue().toString();
            if (curGroup == null || !gvalue.equals(curGroup.getValue().toString())) {           
                System.out.println("In if case Group="+s+" Condition="+!gvalue.equals(s));
            	//creates a new group with name = gvalue
                curGroup = new GroupingData<FileData>(gvalue, i);
                //adds store record to the group
                curGroup.getItems().add(m);
                if (groups.contains(curGroup))
            	  System.out.println("This group is not added: "+curGroup.getValue().toString());
                //assert !groups.contains(curGroup) <--probably this makes sure that the data in the store are sorted by group column;
                else { 
            	  System.out.println("This group is just added: "+curGroup.getValue().toString());
        	      groups.add(curGroup);
                }
                  //System.out.println("Current Group: "+ curGroup.getValue().toString()+ " Collapsed? " + curGroup.isCollapsed());
             }
            else {
            	// curGroup.getItems().add(m);
            	System.out.println("In else case Group="+s+" Condition="+!gvalue.equals(s));
             }      
        }
        System.out.println("Size of groups: "+groups.size());
        GroupingData<FileData> lastGroup = groups.get(0); // ? I am not sure index 0 corresponds to the last group
        lastGroup.setCollapsed(true);       
	}
	
	@UiHandler("organizeLocation")
	public void groupByLocation(SelectEvent event)
	{
		 view.groupBy(cc3);
	}
	public void makeToolTips() {
		for (FileData d: fileData) {
			tooltips.put(d.getName(), d);
		}
	}
	public interface HtmlLayoutContainerTemplate extends XTemplates {
	    @XTemplate("<div><div class='cell1'></div><div class='cell2'></div><div class='cell3'></div></div>")
	    SafeHtml getTemplate();
	  }
	@UiHandler ("help")
	public void showHelp(SelectEvent event) {

		 String html = "<h3>YouTube videos</h3>"+
				   //     "<ul style=\"list-style: disc; margin: 5px 0px 5px 15px\">" +
				        "<ul>" +
		 		        "<li>\"How to download a file on hpcc using lynx browser\"<a target=\"new\" href=\"http://www.youtube.com/watch?v=jPH3YPVc4x4\"> Click here </a></li>"+
				        "<li>\"Download multiple files from the USC Epigenome Center data portal all at once\"<a target=\"new\" href=\"http://www.youtube.com/watch?v=Qb3qH8lN0P4\"> Click here </a></li>"+
		 		   //     "<li>ECDP User Manual (pdf)<a target=\"new\" href=\"https://docs.google.com/viewer?a=v&pid=sites&srcid=ZGVmYXVsdGRvbWFpbnx1c2NlY3dpa2l8Z3g6MWZlNDBhN2JkNzczNTYxNg\">Click here</a></li>"+
		          //      "<a target=\"new\" " +
		 		   //     "href=\"http://www.youtube.com/watch?v=jPH3YPVc4x4\">" +
		 		  //      "\"Downloading a file on hpcc\"</a></li>" +
		 		        "</ul>"+
		 		       "<h3>ECDP User Manual</h3>"+
		 		        "<ul>"+
		 		       "<li>PDF (August 2012) <a target=\"new\" href=\"https://docs.google.com/viewer?a=v&pid=sites&srcid=ZGVmYXVsdGRvbWFpbnx1c2NlY3dpa2l8Z3g6MWZlNDBhN2JkNzczNTYxNg\">Click here</a></li>"+
				       "</ul>";
		 SafeHtml shtml = SafeHtmlUtils.fromTrustedString(html);
		 
		// TextArea text = new TextArea();
		 Anchor a = new Anchor();
		 a.setHTML(shtml);
		 final Dialog simple = new Dialog();
		 simple.setHeading("TUTORIALS");
		 simple.setPredefinedButtons(PredefinedButton.OK);
		 simple.setBodyStyleName("pad-text");
	//	 text.setText("test");
	//	 SimpleContainer v = new SimpleContainer();
		 ContentPanel v = new ContentPanel();
		 v.setHeaderVisible(false);
		 simple.setHideOnButtonClick(true);
		 simple.setWidth(600);
		 simple.setHeight(400);
		 HtmlLayoutContainerTemplate templates = GWT.create(HtmlLayoutContainerTemplate.class);
		 HtmlLayoutContainer c = new HtmlLayoutContainer(templates.getTemplate());
		 c.add(new HTML(html,true), new HtmlData(".cell1"));
	//	 c.add(new HTML(html,true), new HtmlData(".cell2"));
         v.setWidget(c);
         simple.add(v);
		 simple.show();		 
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
