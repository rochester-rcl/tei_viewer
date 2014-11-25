<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei">

  <xsl:variable name="places" select="('superlinear', 'sublinear', 'intralinear')"/>

  <xsl:template match="tei:*" mode="superlinear">
    <xsl:call-template name="reorder">
      <xsl:with-param name="mode">superlinear</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:*" mode="sublinear">
    <xsl:call-template name="reorder">
      <xsl:with-param name="mode">sublinear</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:*" mode="linear">
    <xsl:call-template name="reorder">
      <xsl:with-param name="mode">intralinear</xsl:with-param>
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
