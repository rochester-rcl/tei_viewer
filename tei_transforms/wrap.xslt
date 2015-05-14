<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wrap="http://islandora.ca/ontology/tei-text-wrapper">
  <xsl:output method="xml" indent="no"/>

  <!-- Wrap all text nodes in a document, to facilitate flagging for removal. -->

  <xsl:template match="tei:TEI">
    <tei:TEI
      xmlns:tei="http://www.tei-c.org/ns/1.0"
      xmlns:wrap="http://islandora.ca/ontology/tei-text-wrapper">
      <xsl:apply-templates/>
    </tei:TEI>
  </xsl:template>

  <xsl:template match="*">
    <xsl:param name="count" select="1"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="count" select="$count"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:del">
    <xsl:param name="count" select="1"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates>
        <xsl:with-param name="count" select="$count * -1"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:param name="count" select="1"/>
    <wrap:per>
      <xsl:attribute name="refcount">
        <xsl:value-of select="$count"/>
      </xsl:attribute>
      <xsl:copy/>
    </wrap:per>
  </xsl:template>

</xsl:stylesheet>
