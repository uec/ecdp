package edu.usc.epigenome.eccp.client.sencha;

import java.util.List;

import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.data.shared.SortDir;
import com.sencha.gxt.data.shared.SortInfo;
import com.sencha.gxt.data.shared.SortInfoBean;
import com.sencha.gxt.data.shared.Store.StoreSortInfo;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.GroupingView;

public class ResizeGroupingView<M> extends GroupingView<M>
{
	  private StoreSortInfo<M> lastStoreSort;
	  private SortInfo lastSort;
	
	
	public void doResize()
	{
		this.layout();
	}
	// Overrides
	public void groupBy(ColumnConfig<M, ?> column) {

	//	System.out.println("HERE in overridden groupBy");
		    if (grid == null) {
		      // if still being configured, save the grouping column for later
		      groupingColumn = column;
		    }
		    if (column != groupingColumn) {
		      // remove the existing group, if any
		      if (groupingColumn != null) {
		        if (grid.getLoader() == null || !grid.getLoader().isRemoteSort()) {
		          assert lastStoreSort != null && ds.getSortInfo().contains(lastStoreSort);
		          // remove the lastStoreSort from the listStore
		          ds.getSortInfo().remove(lastStoreSort);
		        } else {
		          assert lastSort != null;
		          grid.getLoader().removeSortInfo(lastSort);
		        }
		      } else {// groupingColumn == null;
		        assert lastStoreSort == null && lastSort == null;
		      }

		      // set the new one
		      groupingColumn = column;
		      if (column != null) {
		        if (grid.getLoader() == null || !grid.getLoader().isRemoteSort()) {
		          lastStoreSort = createStoreSortInfo(column, SortDir.ASC);
		          ds.addSortInfo(0, lastStoreSort);// this triggers the sort
		        } else {
		          lastSort = new SortInfoBean(column.getValueProvider(), SortDir.ASC);
		          grid.getLoader().addSortInfo(0, lastSort);
		          grid.getLoader().load();
		        }
		      } else {// new column == null
		        lastStoreSort = null;
		        lastSort = null;
		        // full redraw without groups
		        refresh(false);
		      }
		    }
		  }
	 public <V> StoreSortInfo<M> createStoreSortInfo(ColumnConfig<M, V> column, SortDir sortDir) {
		    if (column.getComparator() == null) {
		      // These casts can fail, but in dev mode the exception will be caught by
		      // the try/catch in doSort, unless there are no items in the Store
		      if (column.getHeader().asString().equals("Date"))	{
		    	  System.out.println(" No comparator. Sort Order Before: "+sortDir.toString());
		    	  sortDir=SortDir.toggle(sortDir);
		    	  System.out.println("No comparator. Sort Order After: "+sortDir.toString());
		      }
		      
		      @SuppressWarnings({"unchecked", "rawtypes"})
		      ValueProvider<M, Comparable> vp = (ValueProvider) column.getValueProvider();
		      @SuppressWarnings("unchecked")
		      StoreSortInfo<M> s = new StoreSortInfo<M>(vp, sortDir);
		      return s;
		    } else {
		    	
		    if (column.getHeader().asString().equals("Date"))	{
		    	  System.out.println("Sort Order Before: "+sortDir.toString());
		    	  sortDir=SortDir.toggle(sortDir);
		    	  System.out.println("Sort Order After: "+sortDir.toString());
		    
		    }
		    	  return new StoreSortInfo<M>(column.getValueProvider(), column.getComparator(), sortDir);		    	  
		     
		    }
		  }


}
