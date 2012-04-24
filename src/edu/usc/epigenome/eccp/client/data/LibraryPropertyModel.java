package edu.usc.epigenome.eccp.client.data;

import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.data.shared.ModelKeyProvider;

public interface LibraryPropertyModel
{
	 ModelKeyProvider<FileData> key();
	 ValueProvider<FileData, String> name();
	 ValueProvider<FileData, String> value();
	 ValueProvider<FileData, String> type();
	 ValueProvider<FileData, String> category();
	 ValueProvider<FileData, String> source();
	 ValueProvider<FileData, String> usage();
}
