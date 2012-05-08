package edu.usc.epigenome.eccp.client.data;

import com.sencha.gxt.core.client.ValueProvider;

public class MultipleLibraryPropertyModelFactory
{
	static public ValueProvider<MultipleLibraryProperty,String> getValueProvider(final int index)
	{
		 ValueProvider<MultipleLibraryProperty,String> c1 =new ValueProvider<MultipleLibraryProperty,String>()
		 {
			@Override
			public String getValue(MultipleLibraryProperty object)
			{
				return object.getValue(index);
			}

			@Override
			public void setValue(MultipleLibraryProperty object, String value)
			{
				object.setValue(value, index);
			}

			@Override
			public String getPath()
			{
				return String.valueOf(index);
			} 
		 };
		 return c1;
	}
}
