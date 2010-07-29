package edu.usc.epigenome.eccp.client.pane.flowcellReport;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;

import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.MenuBar;
import com.google.gwt.user.client.ui.VerticalPanel;

public class TileViewer extends Composite
{
	VerticalPanel vp = new VerticalPanel();
	VerticalPanel filePanel = new VerticalPanel();
	
	
	public TileViewer(String flowcellID)
	{
		FlexTable lanesTable = new FlexTable();
		for(int j = 0; j < 60; j++)
		{
			lanesTable.setText(j, 0, "" + (j+1));// + (i+1) + "_" + (j+1) + "_ACTG");
			lanesTable.setText(j, 24, "" + (120-j));// + (i+1) + "_" + (j+1) + "_ACTG");
		}
		for(int i = 0; i < 8; i++)
			for(int j = 0; j < 60; j++)
			{
				lanesTable.setText(j, 3 * i + 1, "ACGT");// + (i+1) + "_" + (j+1) + "_ACTG");
				lanesTable.setText(j,3 * i + 2, "ACGT");// + (i+1) + "_" + (120-j) + "_ACTG");
			}
		vp.add(lanesTable);		
		initWidget(vp);
		
	}
		
}