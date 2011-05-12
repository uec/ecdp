<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
	<mappings>
 	<xsl:for-each select="processes/process/process/input-output-map">
 	    <xsl:sort select="../date-run" order="descending"/>
		<mapping>
				<xsl:attribute name="date-run"><xsl:value-of select="../date-run"/></xsl:attribute>
				<xsl:attribute name="beadchipserial"><xsl:value-of select="output/artifact/location/container/container/name"/></xsl:attribute>
				<xsl:attribute name="beadchipLIMSID"><xsl:value-of select="output/artifact/location/container/container/@limsid"/></xsl:attribute>
				<xsl:attribute name="beadchipposition"><xsl:value-of select="output/artifact/location/value"/></xsl:attribute>
				<xsl:attribute name="plateserial"><xsl:value-of select="input/artifact/location/container/container/name"/></xsl:attribute>
				<xsl:attribute name="plateLIMSID"><xsl:value-of select="input/artifact/location/container/container/@limsid"/></xsl:attribute>
				<xsl:attribute name="plateposition"><xsl:value-of select="input/artifact/location/value"/></xsl:attribute>
<!--				<xsl:attribute name="control"><xsl:value-of select="field[@name='Control lane']"/></xsl:attribute>-->
				<xsl:for-each select="output/artifact/sample">
				<xsl:sort select="location/value" order="ascending"/>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="sex"><xsl:value-of select="sample/field[@name='Sex']"/></xsl:attribute>
							<xsl:attribute name="tissue"><xsl:value-of select="sample/field[@name='Tissue Source']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/project/name"/></xsl:attribute>
							<xsl:attribute name="batch"><xsl:value-of select="sample/type/field[@name='Batch ID']"/></xsl:attribute>
							<xsl:attribute name="histology"><xsl:value-of select="sample/type/field[@name='Histology']"/></xsl:attribute>
							<xsl:attribute name="diseaseabr"><xsl:value-of select="sample/type/field[@name='Disease Abbreviation']"/></xsl:attribute>
							<xsl:attribute name="date-received"><xsl:value-of select="sample/date-received"/><xsl:text>&#xa0;</xsl:text><xsl:value-of select="sample/date-completed"/></xsl:attribute>
				</xsl:for-each>							
		</mapping>
  	</xsl:for-each>	  
</mappings>
</xsl:template>
</xsl:stylesheet> 
