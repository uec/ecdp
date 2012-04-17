package edu.usc.epigenome.eccp.client.data;

import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.data.shared.ModelKeyProvider;
import com.sencha.gxt.data.shared.PropertyAccess;

public interface NameValueModel extends PropertyAccess<NameValue>
{
	 ModelKeyProvider<NameValue> key();
	 ValueProvider<NameValue, String> name();
	 ValueProvider<NameValue, String> type();
	 ValueProvider<NameValue, String> value();
}
