<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
	<flowcells>
 	<xsl:for-each select="containers/container">
 	<xsl:sort select="name" order="descending"/>
		<flowcell>
				<xsl:attribute name="serial"><xsl:value-of select="name"/></xsl:attribute>
				<xsl:attribute name="limsID"><xsl:value-of select="@limsid"/></xsl:attribute>
				<xsl:attribute name="control"><xsl:value-of select="field[@name='Control lane']"/></xsl:attribute>
				<xsl:for-each select="artifact">
				<xsl:sort select="location/value" order="ascending"/>
											
						<sample>
							<xsl:attribute name="lane"><xsl:value-of select="location/value"/></xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="sex"><xsl:value-of select="sample/field[@name='Sex']"/></xsl:attribute>
							<xsl:attribute name="tissue"><xsl:value-of select="sample/field[@name='Tissue Source']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
							<xsl:attribute name="date"><xsl:value-of select="sample/date-received"/><xsl:text>&#xa0;</xsl:text><xsl:value-of select="sample/date-completed"/></xsl:attribute>
						</sample>
				</xsl:for-each>					
		</flowcell>
  	</xsl:for-each>	  
</flowcells>
</xsl:template>
</xsl:stylesheet> 
