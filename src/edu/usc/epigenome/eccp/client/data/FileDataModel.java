package edu.usc.epigenome.eccp.client.data;

import com.google.gwt.editor.client.Editor.Path;
import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.data.shared.ModelKeyProvider;
import com.sencha.gxt.data.shared.PropertyAccess;

public interface FileDataModel extends PropertyAccess<FileData>
{
	@Path("downloadLocation") ModelKeyProvider<FileData> key();
	 ValueProvider<FileData, String> name();
	 ValueProvider<FileData, String> fullPath();
	 ValueProvider<FileData, String> type();
	 ValueProvider<FileData, String> location();
	 ValueProvider<FileData, String> downloadLocation();
	 ValueProvider<FileData, String> category();
	 ValueProvider<FileData, String> source();
	 ValueProvider<FileData, String> lane();
	 ValueProvider<FileData, String> size();
}