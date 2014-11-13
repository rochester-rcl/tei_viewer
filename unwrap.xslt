<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wrap="http://islandora.ca/ontology/tei-text-wrapper">
  <xsl:output method="xml" indent="no"/>

  <!-- Remove the wrapper elements which have been flagged for deletion. -->

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="wrap:per[@refcount &lt; 0]"/>
  <xsl:template match="wrap:per[@refcount &gt; 0]">
    <xsl:apply-templates/>
  </xsl:template>
</xsl:stylesheet>
