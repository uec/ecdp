package edu.usc.epigenome.eccp.client.Resources;

import com.google.gwt.core.client.GWT;
import com.google.gwt.resources.client.ClientBundle;
import com.google.gwt.resources.client.ImageResource;

public interface MyImages extends ClientBundle {
	
	public static final MyImages INSTANCE = GWT.create(MyImages.class);

	@Source("report.jpg")
	ImageResource report();
	
	@Source("downArrow.png")
	ImageResource downArrow();
	
	@Source("rightArrow.png")
	ImageResource rightArrow();

}
