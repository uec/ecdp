package edu.usc.epigenome.eccp.client.data;
import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.data.shared.ModelKeyProvider;


public class LibraryDataModelFactory
{
	static public ValueProvider<LibraryData,String> getValueProvider(final String name)
	{
		 ValueProvider<LibraryData,String> c1 =new ValueProvider<LibraryData,String>()
		 {

			@Override
			public String getValue(LibraryData object)
			{
				if(object.containsKey(name))
						return object.get(name).getValue();;
				return "";
			}

			@Override
			public void setValue(LibraryData object, String value)
			{
				if(object.containsKey(name))
					object.get(name).setValue(value);
						
			}

			@Override
			public String getPath()
			{
				return name;
			} 
		 };
		 return c1;
	}
	

	
	static public ModelKeyProvider<LibraryData> getModelKeyProvider()
	{
		ModelKeyProvider<LibraryData> key = new ModelKeyProvider<LibraryData>(){
			@Override
			public String getKey(LibraryData item)
			{
				return item.get("id_run_sample").getValue();
			}};
		return key;
	}
}
