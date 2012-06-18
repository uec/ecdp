package edu.usc.epigenome.eccp.client.data;

import java.util.List;

public interface XYData
{
	public String getType();
	public void setType(String type);
	public String getFormat();
	public void setFormat(String format);
	public String getTitle();
	public void setTitle(String title);
	public String getXLabel();
	public void setXLabel(String xLabel);
	public String getYLabel();
	public void setYLabel(String yLabel);
	public List<Double> getX();
	public void setX(Double[] x);
	public List<Double> getY();
	public void setY(Double[] y);
}
