<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Project-specific XSLT for transforming TEI to
       HTML. Customisations here override those in the core
       to-html.xsl (which should not be changed). -->

  <xsl:import href="../../kiln/stylesheets/tei/to-html.xsl" />
  
  <xsl:template match="tei:bibl">
    <xsl:choose>
      <xsl:when test="descendant::tei:ptr[@target]">
        <a target="_blank" href="../concordance/bibliography/{descendant::tei:ptr/@target}.html">
        <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:title[ancestor::tei:div]|tei:foreign[ancestor::tei:div]">
    <i><xsl:apply-templates/></i>
  </xsl:template>
  
  <xsl:template match="tei:ref[@target][not(@type='inscription')]">
    <a href="{@target}" target="_blank"><xsl:apply-templates/></a>
  </xsl:template>
  
  <xsl:template match="tei:ref[@n][@type='inscription']">
    <a href="../inscriptions/{@n}.html" target="_blank"><xsl:apply-templates/></a>
  </xsl:template>
  
  <xsl:template match="tei:emph">
    <b><xsl:apply-templates/></b>
  </xsl:template>

</xsl:stylesheet>
