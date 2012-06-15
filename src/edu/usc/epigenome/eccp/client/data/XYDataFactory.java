package edu.usc.epigenome.eccp.client.data;

import com.google.web.bindery.autobean.shared.AutoBean;
import com.google.web.bindery.autobean.shared.AutoBeanFactory;

public interface XYDataFactory extends AutoBeanFactory
{
	AutoBean<XYData> xyData();
}
