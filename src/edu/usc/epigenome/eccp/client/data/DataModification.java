package edu.usc.epigenome.eccp.client.data;
import java.io.Serializable;

public class DataModification implements Serializable
{

	private static final long serialVersionUID = 1L;
	
	String experimentID;
	String sampleId;
	String analysisID;
	DataModificationMetric[] metrics;
	public String getExperimentID() {
		return experimentID;
	}
	public void setExperimentID(String experimentID) {
		this.experimentID = experimentID;
	}
	public String getSampleId() {
		return sampleId;
	}
	public void setSampleId(String sampleId) {
		this.sampleId = sampleId;
	}
	public String getAnalysisID() {
		return analysisID;
	}
	public void setAnalysisID(String analysisID) {
		this.analysisID = analysisID;
	}
	public DataModificationMetric[] getMetrics() {
		return metrics;
	}
	public void setMetrics(DataModificationMetric[] metrics) {
		this.metrics = metrics;
	}
}
