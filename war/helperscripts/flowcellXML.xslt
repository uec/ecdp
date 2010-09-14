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
					<xsl:if test="location/value = 'A:1'">						
						<sample>
							<xsl:attribute name="lane">1</xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L1 Processing']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
					</xsl:if>
				</xsl:for-each>
			
				<xsl:for-each select="input-output-map/artifact">
					<xsl:if test="location/value = 'A:2'">						
						<sample>
							<xsl:attribute name="lane">2</xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L2 Processing']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:for-each select="input-output-map/artifact">
					<xsl:if test="location/value = 'A:3'">						
						<sample>
							<xsl:attribute name="lane">3</xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L3 Processing']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:for-each select="input-output-map/artifact">
					<xsl:if test="location/value = 'A:4'">						
						<sample>
							<xsl:attribute name="lane">4</xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L4 Processing']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:for-each select="input-output-map/artifact">
					<xsl:if test="location/value = 'A:5'">						
						<sample>
							<xsl:attribute name="lane">5</xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L5 Processing']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:for-each select="input-output-map/artifact">
					<xsl:if test="location/value = 'A:6'">						
						<sample>
							<xsl:attribute name="lane">6</xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L6 Processing']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:for-each select="input-output-map/artifact">
					<xsl:if test="location/value = 'A:7'">						
						<sample>
							<xsl:attribute name="lane">7</xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L7 Processing']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
					</xsl:if>
				</xsl:for-each>

				<xsl:for-each select="input-output-map/artifact">
					<xsl:if test="location/value = 'A:8'">						
						<sample>
							<xsl:attribute name="lane">8</xsl:attribute>
							<xsl:attribute name="organism"><xsl:value-of select="sample/field[@name='Species']"/></xsl:attribute>
							<xsl:attribute name="processing"><xsl:value-of select="../../field[@name='L8 Processing']"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="sample/name"/></xsl:attribute>
							<xsl:attribute name="project"><xsl:value-of select="sample/project/name"/></xsl:attribute>
						</sample>
					</xsl:if>
				</xsl:for-each>
				
		</flowcell>
  	</xsl:for-each>	  
</flowcells>
</xsl:template>
</xsl:stylesheet> 
