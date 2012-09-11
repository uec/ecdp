package edu.usc.epigenome.eccp.client.sencha;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.sencha.gxt.core.client.ValueProvider;
import com.sencha.gxt.data.shared.SortDir;
import com.sencha.gxt.data.shared.SortInfo;
import com.sencha.gxt.data.shared.SortInfoBean;
import com.sencha.gxt.data.shared.Store.StoreSortInfo;
import com.sencha.gxt.widget.core.client.grid.ColumnConfig;
import com.sencha.gxt.widget.core.client.grid.GridView;
import com.sencha.gxt.widget.core.client.grid.GroupingView;
import com.sencha.gxt.widget.core.client.grid.GroupingView.GroupingViewAppearance;

public class ResizeGroupingView<M> extends GroupingView<M>
{
	
	
	
	   private  StoreSortInfo<M> lastStoreSort;
	   private  SortInfo lastSort;
   
	
	  public void doResize()
	    {
		    this.layout();
		
	     }
	
	// I copied and pasted this method from Grouping view superclass because
	// it contains lastStoreSort and lastSort variables
	/* protected void afterRender() {
		    ColumnConfig<M, ?> column = groupingColumn;

		    // set groupingColumn to null to force regrouping only if grouping
		    // hasn't already occurred
		    if (lastStoreSort == null && lastSort == null && column != null) {
		      groupingColumn = null;
		    }
		    groupBy(column);
	      	super.afterRender();	            		    
		  }
*/
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
		//          System.out.println("Last store sort is set, grid != 0: "+lastStoreSort);
		          
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
		//    	  System.out.println(" No comparator. Sort Order Before: "+sortDir.toString());
		    	  sortDir=SortDir.toggle(sortDir);
		//    	  System.out.println("No comparator. Sort Order After: "+sortDir.toString());
		      }
		      
		      @SuppressWarnings({"unchecked", "rawtypes"})
		      ValueProvider<M, Comparable> vp = (ValueProvider) column.getValueProvider();
		      @SuppressWarnings("unchecked")
		      StoreSortInfo<M> s = new StoreSortInfo<M>(vp, sortDir);
		      return s;
		    } else {
		    	
		    if (column.getHeader().asString().equals("Date"))	{
	//	    	  System.out.println("Sort Order Before: "+sortDir.toString());
		    	  sortDir=SortDir.toggle(sortDir);
	//	    	  System.out.println("Sort Order After: "+sortDir.toString());
		    
		    }
		    	  return new StoreSortInfo<M>(column.getValueProvider(), column.getComparator(), sortDir);		    	  
		     
		    }
		  }
	// This method calls GroupingView superclass method. This may cause an 
	// exception
	 protected void doSort(int colIndex, SortDir sortDir) {
		    ColumnConfig<M, ?> column = cm.getColumn(colIndex);
		    if (groupingColumn != null) {
		      if (grid.getLoader() == null || !grid.getLoader().isRemoteSort()) {
		        // first sort is lastStoreSort
		        assert lastStoreSort != null;
		        ds.getSortInfo().clear();

		        StoreSortInfo<M> sortInfo = createStoreSortInfo(column, sortDir);

		        if (sortDir == null && storeSortInfo != null && storeSortInfo.getValueProvider() == column.getValueProvider()) {
		          sortInfo.setDirection(storeSortInfo.getDirection() == SortDir.ASC ? SortDir.DESC : SortDir.ASC);
		        } else if (sortDir == null) {
		          sortInfo.setDirection(SortDir.ASC);
		        }

		        ds.getSortInfo().add(0, lastStoreSort);
		        ds.getSortInfo().add(1, sortInfo);

		        if (GWT.isProdMode()) {
		          ds.applySort(false);
		        } else {
		          try {
		            // applySort will apply its sort when called, which might trigger an
		            // exception if the column passed in's data isn't Comparable
		            ds.applySort(false);
		          } catch (ClassCastException ex) {
		            GWT.log("Column can't be sorted " + column.getValueProvider().getPath() + " is not Comparable. ", ex);
		            throw ex;
		          }
		        }
		      } else {
		        assert lastSort != null;
		        ValueProvider<? super M, ?> vp = column.getValueProvider();
		        grid.getLoader().clearSortInfo();
		        grid.getLoader().addSortInfo(0, lastSort);
		        grid.getLoader().addSortInfo(1, new SortInfoBean(vp, sortDir));
		        grid.getLoader().load();
		      }

		    } else {
		    	
		     super.doSort(colIndex, sortDir);
   	
		    }
		  }
	 public StoreSortInfo<M> getLastStoreSort() {
			return lastStoreSort;
		}

		public void setLastStoreSort(StoreSortInfo<M> lastStoreSort) {
			this.lastStoreSort = lastStoreSort;
		}

		public SortInfo getLastSort() {
			return lastSort;
		}

		public void setLastSort(SortInfo lastSort) {
			this.lastSort = lastSort;
		}
		


}
