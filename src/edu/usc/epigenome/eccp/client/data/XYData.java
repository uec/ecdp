package edu.usc.epigenome.eccp.client.data;

public interface XYData
{
	public String getType();
	public void setType(String type);
	public String getFormat();
	public void setFormat(String format);
	public String getTitle();
	public void setTitle(String title);
	public String getxLabel();
	public void setxLabel(String xLabel);
	public String getyLabel();
	public void setyLabel(String yLabel);
	public Double[] getX();
	public void setX(Double[] x);
	public Double[] getY();
	public void setY(Double[] y);
}
