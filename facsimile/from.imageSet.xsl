<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="java:java.util.UUID" xmlns:saxon="http://saxon.sf.net/" xmlns="http://www.music-encoding.org/ns/mei" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 14, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> bwb</xd:p>
            <xd:p />
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" encoding="UTF-8" />
    <xd:doc scope="component">
        <xd:desc>graphics-uri.prefix will be prepended to the image name in the mei:graphic/@target attribute.</xd:desc>
    </xd:doc>
    <xsl:param name="graphics-uri.prefix" />
    <xd:doc scope="component">
        <xd:desc>The profile parameter has two allowed values, ›default‹ and ›vertaktoid‹. The difference is that when set to ›veratktoid‹ additional attributes @ulx, @uly, @lrx and @lry will be created on each mei:surface element.</xd:desc>
    </xd:doc>
    <xsl:param name="profile">default</xsl:param>
    <xsl:template match="/">
        <xsl:element name="facsimile" namespace="http://www.music-encoding.org/ns/mei">
            <xsl:for-each select="imageSet/image">
                <xsl:element name="surface" namespace="http://www.music-encoding.org/ns/mei">
                    <xsl:attribute name="xml:id" select="concat('edirom_surface_', @uuid)" />
                    <!-- with saxon PE or EE uuid:randomUUID() -->
                    <xsl:attribute name="n" select="position()" />
                    <xsl:if test="$profile = 'vertaktoid'">
                        <xsl:attribute name="ulx">0</xsl:attribute>
                        <xsl:attribute name="uly">0</xsl:attribute>
                        <xsl:attribute name="lrx" select="@width" />
                        <xsl:attribute name="lry" select="@height" />
                    </xsl:if>
                    <xsl:element name="graphic" namespace="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="target" select="concat($graphics-uri.prefix, @name)" />
                        <xsl:attribute name="xml:id" select="concat('edirom_graphic_', @uuid)" />
                        <!-- with saxon PE or EE uuid:randomUUID() -->
                        <xsl:attribute name="type">facsimile</xsl:attribute>
                        <xsl:attribute name="width" select="@width" />
                        <xsl:attribute name="height" select="@height" />
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
