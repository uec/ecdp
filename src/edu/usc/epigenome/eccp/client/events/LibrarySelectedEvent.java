package edu.usc.epigenome.eccp.client.events;

import com.google.gwt.event.shared.GwtEvent;
import com.google.web.bindery.event.shared.EventBus;
import com.google.web.bindery.event.shared.HandlerRegistration;


import edu.usc.epigenome.eccp.client.data.LibraryData;


public class LibrarySelectedEvent extends GwtEvent<LibrarySelectedEventHandler>
{

	private final LibraryData lib;
	
    public static Type<LibrarySelectedEventHandler> TYPE = new Type<LibrarySelectedEventHandler>();

	public static HandlerRegistration register(final EventBus eventBus, final LibrarySelectedEventHandler zlimsMainMenuEventHandler)
	{
		return eventBus.addHandler(LibrarySelectedEvent.TYPE, zlimsMainMenuEventHandler);
	}

	
	public LibrarySelectedEvent()
	{
		this(null);
	}

	public LibrarySelectedEvent(final LibraryData library)
	{
	
		this.lib = library;
	}

	public LibraryData getLibrary()
	{
		return this.lib;
	}


	@Override
	public Type<LibrarySelectedEventHandler> getAssociatedType()
	{
		return LibrarySelectedEvent.TYPE;
	}

	@Override
	protected void dispatch(LibrarySelectedEventHandler handler)
	{
		handler.onLibrarySelected(this);		
	}
	
}
