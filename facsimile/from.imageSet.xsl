<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:uuid="java:java.util.UUID"
    xmlns="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 14, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> bwb</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" encoding="UTF-8"/>
    
    
    <xsl:template match="/">
        <xsl:element name="facsimile" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:for-each select="imageSet/image">
                <xsl:element name="surface" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:id" select="concat('edirom_surface_',uuid:randomUUID())"/>
                    <xsl:attribute name="n" select="position()"/>
                    <xsl:element name="graphic" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="xml:id" select="concat('edirom_graphic_',uuid:randomUUID())"/>
                        <xsl:attribute name="target" select="concat($graphics-uri.prefix,@name)"/>
                        <xsl:attribute name="type">facsimile</xsl:attribute>
                        <xsl:attribute name="width" select="@width"/>
                        <xsl:attribute name="height" select="@height"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>