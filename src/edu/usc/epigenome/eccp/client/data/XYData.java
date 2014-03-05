package edu.usc.epigenome.eccp.client.data;

import java.util.List;

import com.google.web.bindery.autobean.shared.AutoBean.PropertyName;

public interface XYData
{
	public String getType();
	public void setType(String type);
	public String getFormat();
	public void setFormat(String format);
	public String getTitle();
	public void setTitle(String title);
	public String getAutoscale();
	public void setAutoscale(String autoscale);
	public String getNormalize();
	public void setNormalize(String normalize);
	@PropertyName("xLabel")
	public String getXLabel();
	@PropertyName("xLabel")
	public void setXLabel(String xLabel);
	@PropertyName("yLabel")
	public String getYLabel();
	@PropertyName("yLabel")
	public void setYLabel(String yLabel);
	public List<Double> getX();
	public void setX(Double[] x);
	public List<Double> getY();
	public void setY(Double[] y);
}
