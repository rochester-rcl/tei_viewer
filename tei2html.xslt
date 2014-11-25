<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei">
  <xsl:import href="./reorder-line-content.xslt"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:param name="type">reading</xsl:param>
  <xsl:variable name="footnotes" select="//tei:note[@place='footnote']"/>

  <xsl:template match="/">
    <div class="tei">
      <xsl:attribute name="class">
        <xsl:text>tei</xsl:text>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$type"/>
      </xsl:attribute>

      <div>
        <div class="super-magic">
          <xsl:apply-templates select="tei:TEI/tei:text" mode="superlinear"/>
        </div>
        <div class="sub-magic">
          <xsl:apply-templates select="tei:TEI/tei:text" mode="sublinear"/>
        </div>
        <div class="line-magic">
          <xsl:apply-templates select="tei:TEI/tei:text" mode="linear"/>
        </div>
      </div>

      <xsl:variable name="footnote_items">
        <xsl:apply-templates select="$footnotes" mode="footnotes"/>
      </xsl:variable>
      <xsl:if test="normalize-space($footnote_items)">
        <footer>
          <dl>
            <xsl:copy-of select="$footnote_items"/>
          </dl>
        </footer>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="*" mode="#all">
    <span>
      <xsl:call-template name="element_attributes"/>
      <xsl:apply-templates mode="#current"/>
    </span>
  </xsl:template>

  <!-- Delete things which are not from TEI. -->
  <xsl:template match="*[not(self::tei:*)]" mode="#all"/>

  <xsl:template match="tei:lb | tei:pb" mode="#all">
    <br/>
  </xsl:template>

  <xsl:template match="tei:list[@type='ordered']" mode="#all">
    <ol>
      <xsl:call-template name="element_attributes"/>
      <xsl:apply-templates mode="#current"/>
    </ol>
  </xsl:template>

  <xsl:template match="tei:lg | tei:list | tei:listBibl" mode="#all">
    <ul>
      <xsl:call-template name="element_attributes"/>
      <xsl:apply-templates mode="#current"/>
    </ul>
  </xsl:template>

  <xsl:template match="tei:*[parent::tei:lg | parent::tei:list | parent::tei:listBibl]" mode="#all">
    <li>
      <xsl:call-template name="element_attributes"/>
      <xsl:apply-imports/>
    </li>
  </xsl:template>

  <xsl:template match="tei:note[@place='footnote']" mode="linear">
    <a>
      <xsl:call-template name="element_attributes"/>
      <xsl:variable name="type">
        <xsl:choose>
          <xsl:when test="@n">original</xsl:when>
          <xsl:otherwise>position</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="number">
        <xsl:choose>
          <xsl:when test="@n">
            <xsl:value-of select="@n"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="index-of($footnotes, current())[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="href">
        <xsl:value-of select="@place"/>
        <xsl:text>--</xsl:text>
        <xsl:value-of select="$type"/>
        <xsl:text>--</xsl:text>
        <xsl:value-of select="$number"/>
      </xsl:variable>

      <xsl:attribute name="href">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$href"/>
      </xsl:attribute>
      <xsl:attribute name="id">
        <xsl:value-of select="$href"/>
        <xsl:text>--back</xsl:text>
      </xsl:attribute>
      <xsl:if test="$type = 'position'">
        <xsl:attribute name="title">Autonumbered</xsl:attribute>
      </xsl:if>

      <xsl:value-of select="$number"/>
    </a>
  </xsl:template>

  <xsl:template match="tei:note[@place='footnote']" mode="footnotes">
    <dt>
      <a>
        <xsl:call-template name="element_attributes"/>
        <xsl:variable name="type">
          <xsl:choose>
            <xsl:when test="@n">original</xsl:when>
            <xsl:otherwise>position</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="number">
          <xsl:choose>
            <xsl:when test="@n">
              <xsl:value-of select="@n"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="index-of($footnotes, current())[1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="href">
          <xsl:value-of select="@place"/>
          <xsl:text>--</xsl:text>
          <xsl:value-of select="$type"/>
          <xsl:text>--</xsl:text>
          <xsl:value-of select="$number"/>
        </xsl:variable>

        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="$href"/>
          <xsl:text>--back</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="$href"/>
        </xsl:attribute>
        <xsl:if test="$type = 'position'">
          <xsl:attribute name="title">Autonumbered</xsl:attribute>
        </xsl:if>

        <xsl:value-of select="$number"/>
      </a>
    </dt>
    <dd>
      <xsl:apply-imports/>
    </dd>
  </xsl:template>

  <xsl:template match="tei:p | tei:note[not(@place='footnote')] | tei:epigraph | tei:label" mode="#all">
    <p>
      <xsl:call-template name="element_attributes"/>
      <xsl:apply-imports/>
    </p>
  </xsl:template>

  <xsl:template match="tei:zone" mode="#all">
    <div>
      <xsl:call-template name="element_attributes"/>
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:q" mode="#all">
    <q>
      <xsl:call-template name="element_attributes"/>
      <xsl:apply-templates mode="#current"/>
    </q>
  </xsl:template>

  <xsl:template match="tei:choice" mode="#all">
    <xsl:choose>
      <xsl:when test="$type = 'reading'">
        <xsl:choose>
          <xsl:when test="tei:reg | tei:expan | tei:corr">
            <xsl:apply-templates select="(tei:reg | tei:expan | tei:corr)[1]" mode="#current"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="tei:*[1]" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$type = 'diplomatic'">
        <xsl:choose>
          <xsl:when test="tei:orig | tei:abbr | tei:sic">
            <xsl:apply-templates select="(tei:orig | tei:abbr | tei:sic)[1]" mode="#current"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="tei:*[1]" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <xsl:call-template name="element_attributes"/>
          <xsl:apply-templates mode="#current"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="element_attributes">
    <xsl:param name="node" select="current()"/>

    <xsl:attribute name="class">
      <xsl:value-of select="local-name($node)"/>
      <xsl:for-each select="$node/@type | $node/@rend | $node/@place | $node/@style | $node/@reason">
        <xsl:text> </xsl:text>
        <xsl:value-of select="concat('class--', local-name(.), '--', translate(normalize-space(.), ' ', '-'))"/>
      </xsl:for-each>
      <xsl:if test="$node/@spanTo">
        <xsl:text> spans spanTo--</xsl:text>
        <xsl:value-of select="generate-id(//tei:*[@xml:id = substring($node/@spanTo, 2)])"/>
      </xsl:if>
      <xsl:if test="$node/@target">
        <xsl:text> targets</xsl:text>
        <xsl:for-each select="//tei:*[@xml:id and contains($node/@target, concat('#', @xml:id))]">
          <xsl:text> target--</xsl:text>
          <xsl:value-of select="generate-id()"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:attribute>
    <xsl:if test="$node/@xml:id">
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id($node)"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
