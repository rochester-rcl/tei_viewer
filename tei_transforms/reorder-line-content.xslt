<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei">

  <xsl:variable name="places" select="('above', 'below', 'inline')"/>

  <xsl:template match="tei:*" mode="above">
    <xsl:call-template name="reorder">
      <xsl:with-param name="mode">above</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:*" mode="below">
    <xsl:call-template name="reorder">
      <xsl:with-param name="mode">below</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:*" mode="inline">
    <xsl:call-template name="reorder">
      <xsl:with-param name="mode">inline</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="reorder">
    <xsl:param name="mode"/>

    <xsl:choose>
      <xsl:when test="descendant::tei:*[@place and exists(index-of($places, @place))]">
        <xsl:variable name="current" select="index-of($places, $mode)"/>
        <xsl:variable name="these" select="remove($places, $current[1])"/>

        <xsl:apply-templates select="text() | tei:*[not(@place) or empty(index-of($these, @place))]" mode="#current"/>
        <xsl:apply-templates select="descendant::tei:*[@place and exists(index-of($these, @place))]" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
