package edu.usc.epigenome.eccp.client.data;

import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.data.shared.ModelKeyProvider;
import com.sencha.gxt.data.shared.PropertyAccess;

public interface LibraryPropertyModel  extends PropertyAccess<LibraryProperty>
{
	 ModelKeyProvider<LibraryProperty> key();
	 ValueProvider<LibraryProperty, String> name();
	 ValueProvider<LibraryProperty, String> value();
	 ValueProvider<LibraryProperty, String> type();
	 ValueProvider<LibraryProperty, String> category();
	 ValueProvider<LibraryProperty, String> source();
	 ValueProvider<LibraryProperty, String> usage();
	 ValueProvider<LibraryProperty, String> prettyName();
	 ValueProvider<LibraryProperty, String> sortOrder();
	 ValueProvider<LibraryProperty, String> description();
}
