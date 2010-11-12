package edu.usc.epigenome.eccp.client.pane.methylation;
import java.util.ArrayList;
import java.util.Collections;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.VerticalPanel;

import edu.usc.epigenome.eccp.client.ECService;
import edu.usc.epigenome.eccp.client.ECServiceAsync;
import edu.usc.epigenome.eccp.client.data.MethylationData;
import edu.usc.epigenome.eccp.client.pane.ECPane;

public class MethylationSanityCheck extends ECPane
{
		ECServiceAsync remoteService = (ECServiceAsync) GWT.create(ECService.class);
		final VerticalPanel vp = new VerticalPanel();
		public MethylationSanityCheck()
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
			return new Label("Methylation Sanity Check");
		}

		@Override
		public void showTool()
		{
			final TextArea ta = new TextArea();
			ta.setWidth("800px");
			ta.setHeight("600px");
			remoteService.getMethFromGeneus(new AsyncCallback<ArrayList<MethylationData>>()
			{
				public void onFailure(Throwable caught)
				{
					// TODO Auto-generated method stub
					
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
			vp.add(ta);		
		}


}

