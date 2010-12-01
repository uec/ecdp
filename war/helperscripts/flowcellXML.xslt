<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
	<flowcells>
 	<xsl:for-each select="processes/process">
 	<xsl:sort select="date-run" order="descending"/>
		<flowcell>
				<xsl:attribute name="serial"><xsl:value-of select="field[@name='Flowcell S/N']"/></xsl:attribute>
				<xsl:attribute name="limsID"><xsl:value-of select="@limsid"/></xsl:attribute>
				<xsl:attribute name="protocol"><xsl:value-of select="field[@name='Sequencing Protocol']"/></xsl:attribute>
				<xsl:attribute name="date"><xsl:value-of select="date-run"/></xsl:attribute>
				<xsl:attribute name="technician"><xsl:value-of select="technician/first-name"/><xsl:text>&#xa0;</xsl:text><xsl:value-of select="technician/last-name"/></xsl:attribute>
				
				<xsl:attribute name="control"><xsl:value-of select="field[@name='Control lane']"/></xsl:attribute>
				
				<xsl:for-each select="input-output-map/artifact">
				<xsl:sort select="location/value" order="ascending"/>
						<sample>
							<xsl:attribute name="lane"><xsl:value-of select="substring-after(location/value,':')"/></xsl:attribute>
							<xsl:attribute name="organism">
								<xsl:for-each select="sample/field[@name='Species']">
									<xsl:value-of select="current()"/>
									<xsl:if test="not(position() = last())">+</xsl:if>
								</xsl:for-each>	
							</xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L1 Processing']"/></xsl:attribute>
							<xsl:attribute name="name">
								<xsl:for-each select="sample">
									<xsl:value-of select="name"/>
									<xsl:if test="not(position() = last())">+</xsl:if>
								</xsl:for-each>
							</xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
				</xsl:for-each>
		</flowcell>
  	</xsl:for-each>	  
</flowcells>
</xsl:template>
</xsl:stylesheet> 
