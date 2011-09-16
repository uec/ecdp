package edu.usc.epigenome.eccp.client.pane.methylation;

import java.util.ArrayList;
import java.util.Collections;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.uibinder.client.UiBinder;
import com.google.gwt.uibinder.client.UiField;
import com.google.gwt.uibinder.client.UiHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.Widget;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.Resources.UserPanelResources;
import edu.usc.epigenome.eccp.client.data.MethylationData;
import edu.usc.epigenome.eccp.client.pane.ECPane;

public class MethylationSanityCheck extends ECPane{

	private static MethylationSanityCheckUiBinder uiBinder = GWT
			.create(MethylationSanityCheckUiBinder.class);

	interface MethylationSanityCheckUiBinder extends
			UiBinder<Widget, MethylationSanityCheck> {
	}

	static {
	    UserPanelResources.INSTANCE.userPanel().ensureInjected();  
	}

	ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
	
	@UiField FlowPanel vp;
	@UiField TextArea ta;
	
	public MethylationSanityCheck() {
		initWidget(uiBinder.createAndBindUi(this));
	}

	
	public void showTool()
	{
		remoteService.getMethFromGeneus(new AsyncCallback<ArrayList<MethylationData>>()
		{
			public void onFailure(Throwable caught)
			{
				caught.getMessage();
			}

			public void onSuccess(ArrayList<MethylationData> result)
			{
				String errorString = "";
				ArrayList<String> errors = result.get(0).validateIntegrity(result);
				Collections.sort(errors);
				for(String e : errors)
				{
					errorString += e + "\n";
				}
				ta.setText(errorString);
				
			}
		});
	}


	@Override
	public Image getToolLogo() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Label getToolTitle() {
		// TODO Auto-generated method stub
		return null;
	}


}
