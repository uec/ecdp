package edu.usc.epigenome.eccp.client.events;

import com.google.gwt.event.shared.GwtEvent;
import com.google.gwt.user.client.ui.Widget;
import com.google.web.bindery.event.shared.EventBus;
import com.google.web.bindery.event.shared.HandlerRegistration;


public class ShowGlobalTabEvent extends GwtEvent<ShowGlobalTabEventHandler>
{

	private final Widget toShow;
	private final String tabTitle;
	
    public static Type<ShowGlobalTabEventHandler> TYPE = new Type<ShowGlobalTabEventHandler>();

	public static HandlerRegistration register(final EventBus eventBus, final ShowGlobalTabEventHandler zlimsMainMenuEventHandler)
	{
		return eventBus.addHandler(ShowGlobalTabEvent.TYPE, zlimsMainMenuEventHandler);
	}

	
	public ShowGlobalTabEvent()
	{
		this(null,null);
	}

	public ShowGlobalTabEvent(final Widget toShow,final String tabTitle)
	{
	
		this.toShow = toShow;
		this.tabTitle = tabTitle;
	}

	public Widget getWidgetToShow()
	{
		return this.toShow;
	}
	public String getTabTitle()
	{
		return this.tabTitle;
	}


	@Override
	public Type<ShowGlobalTabEventHandler> getAssociatedType()
	{
		return ShowGlobalTabEvent.TYPE;
	}

	@Override
	protected void dispatch(ShowGlobalTabEventHandler handler)
	{
		handler.onShowWidgetInTab(this);

	
	}
	
}
