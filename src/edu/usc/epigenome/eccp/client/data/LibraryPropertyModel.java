package edu.usc.epigenome.eccp.client.data;

import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.data.shared.ModelKeyProvider;

public interface LibraryPropertyModel
{
	 ModelKeyProvider<LibraryProperty> key();
	 ValueProvider<LibraryProperty, String> name();
	 ValueProvider<LibraryProperty, String> value();
	 ValueProvider<LibraryProperty, String> type();
	 ValueProvider<LibraryProperty, String> category();
	 ValueProvider<LibraryProperty, String> source();
	 ValueProvider<LibraryProperty, String> usage();
}
