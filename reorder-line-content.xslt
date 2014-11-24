<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei">

  <xsl:template match="tei:*[tei:*[exists(index-of(('superlinear', 'sublinear', 'intralinear'), @place))]]" mode="superlinear" priority='-1'>
    <xsl:apply-templates select="text() | tei:*[empty(index-of(('sublinear', 'intralinear'), @place))]" mode="#current"/>
    <xsl:apply-templates select="tei:*[exists(index-of(('sublinear', 'intralinear'), @place))]" mode="#current"/>
  </xsl:template>

  <xsl:template match="tei:*[tei:*[exists(index-of(('sublinear', 'superlinear', 'intralinear'), @place))]]" mode="sublinear" priority='-1'>
    <xsl:apply-templates select="text() | tei:*[empty(index-of(('superlinear', 'intralinear'), @place))]" mode="#current"/>
    <xsl:apply-templates select="tei:*[exists(index-of(('superlinear', 'intralinear'), @place))]" mode="#current"/>
  </xsl:template>

  <xsl:template match="tei:*[tei:*[exists(index-of(('sublinear', 'superlinear', 'intralinear'), @place))]]" mode="linear">
    <xsl:apply-templates select="text() | tei:*[empty(index-of(('superlinear', 'sublinear'), @place))]" mode="#current"/>
    <xsl:apply-templates select="tei:*[exists(index-of(('superlinear', 'sublinear'), @place))]" mode="#current"/>
  </xsl:template>
</xsl:stylesheet>
