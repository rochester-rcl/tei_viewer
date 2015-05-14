<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wrap="http://islandora.ca/ontology/tei-text-wrapper">
  <xsl:output method="xml" indent="no"/>
  <xsl:param name="type">reading</xsl:param>

  <!-- Remove the wrapper elements which have been flagged for deletion. -->

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:del">
    <tei:seg>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </tei:seg>
  </xsl:template>
  <xsl:template match="wrap:per[@refcount &lt; 0]">
    <xsl:if test="$type = 'diplomatic'">
      <tei:del>
        <xsl:apply-templates/>
      </tei:del>
    </xsl:if>
  </xsl:template>
  <xsl:template match="wrap:per[@refcount &gt; 0]">
    <xsl:choose>
      <xsl:when test="ancestor::tei:del or contains(preceding::tei:delSpan/@spanTo, concat('#', following::tei:anchor/@xml:id))">
        <tei:seg rend="undone">
          <xsl:apply-templates/>
        </tei:seg>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
