package edu.usc.epigenome.eccp.client.pane.cacheManagement;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;

import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.pane.ECPane;

public class CacheManager extends ECPane
{
	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	final VerticalPanel vp = new VerticalPanel();
	public CacheManager()
	{
		initWidget(vp);	
	}
	@Override
	public Image getToolLogo()
	{	
		return new Image("images/globe_process.png");
	}

	@Override
	public Label getToolTitle()
	{
		return new Label("Rebuild Cache");
	}

	@Override
	public void showTool()
	{
		Button b = new Button("clear geneus and file cache");
		vp.add(b);
		b.addClickHandler(new ClickHandler(){

			public void onClick(ClickEvent event)
			{
				remoteService.clearCache(new AsyncCallback<String>(){

					public void onFailure(Throwable caught)
					{
						vp.add(new Label(caught.getMessage()));						
					}

					public void onSuccess(String result)
					{
						vp.add(new Label(result));
						
					}});
				
			}});
	}


}
