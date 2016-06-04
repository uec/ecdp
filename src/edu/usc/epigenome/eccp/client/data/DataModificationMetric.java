package edu.usc.epigenome.eccp.client.data;

import java.io.Serializable;

public class DataModificationMetric implements Serializable
{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	String metricName;
	String metricValue;
	String metricFileName;
	long metricFileSize;
	public String getMetricName() {
		return metricName;
	}
	public void setMetricName(String metricName) {
		this.metricName = metricName;
	}
	public String getMetricValue() {
		return metricValue;
	}
	public void setMetricValue(String metricValue) {
		this.metricValue = metricValue;
	}
	public String getMetricFileName() {
		return metricFileName;
	}
	public void setMetricFileName(String metricFileName) {
		this.metricFileName = metricFileName;
	}
	public long getMetricFileSize() {
		return metricFileSize;
	}
	public void setMetricFileSize(long metricFileSize) {
		this.metricFileSize = metricFileSize;
	}
}
