<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding = "UTF-8" indent="yes"/>
	
		<xsl:template match="node()|@*">
			<xsl:copy>
				<xsl:apply-templates select="node()|@*"/>
			</xsl:copy>
		</xsl:template>
	
	<!-- ID-prefix clean up für edirom -->
	<xsl:template match="@facs[contains(.,'#zone') and not(contains(.,'#edirom'))]">
		<xsl:attribute name="facs"><xsl:value-of select="concat('#rwa_',substring-after(.,'#'))"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@xml:id[contains(.,'zone_') and not(contains(.,'edirom_'))]">
		<xsl:attribute name="xml:id"><xsl:value-of select="concat('edirom_',.)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@xml:id[contains(.,'graphic_') and not(contains(.,'edirom_'))]">
		<xsl:attribute name="xml:id"><xsl:value-of select="concat('edirom_',.)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@xml:id[contains(.,'surface_') and not(contains(.,'edirom_'))]">
		<xsl:attribute name="xml:id"><xsl:value-of select="concat('rwa_',.)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@xml:id[contains(.,'measure_') and not(contains(.,'edirom_'))]">
		<xsl:attribute name="xml:id"><xsl:value-of select="concat('rwa_',.)"/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@xml:id[contains(.,'page_')]">
		<xsl:attribute name="xml:id"><xsl:value-of select="concat('edirom_mdiv_',substring-after(.,'page_'))"/></xsl:attribute>
	</xsl:template>
	
</xsl:stylesheet>