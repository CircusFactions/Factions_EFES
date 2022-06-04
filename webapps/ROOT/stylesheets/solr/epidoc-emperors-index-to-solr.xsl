<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
  version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of emperors in those
       documents. -->
  
  <xsl:import href="epidoc-index-utils.xsl" />
  
  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  
  <xsl:template match="/">
    <!-- the following code handles multiple values inside @ref/@key -->
    <!-- <xsl:variable name="root" select="." />
      <xsl:variable name="id-values">
      <xsl:for-each select="//tei:persName[@type='emperor'][@ref]/@ref|//tei:persName[@type='emperor'][@key][not(@ref)]/@key">
        <xsl:value-of select="normalize-space(translate(., '#', ''))" />
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="ids" select="distinct-values(tokenize(normalize-space($id-values), '\s+'))" />-->
    
    <add>
      <!-- the following code handles multiple values inside @ref/@key -->
      <!-- <xsl:for-each select="$ids">
        <xsl:variable name="id" select="." />
        <xsl:variable name="idno" select="document('../../content/xml/authority/emperors.xml')//tei:person[@xml:id=$id]"/>
        <xsl:variable name="emperor" select="$root//tei:persName[@type='emperor'][contains(concat(' ', translate(@ref, '#', ''), ' '), concat(' ',$id,' ')) or contains(concat(' ', translate(@key, '#', ''), ' '), concat(' ',$id,' '))]" />
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="$idno">
                <xsl:value-of select="$idno/tei:persName" />
                <xsl:if test="$idno/tei:floruit"><xsl:text> (</xsl:text><xsl:value-of select="$idno/tei:floruit" /><xsl:text>)</xsl:text></xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_item_sort_name">
            <xsl:value-of select="$idno/@n" />
          </field>
          <field name="index_epithet">
            <xsl:for-each select="$emperor//tei:addName[@nymRef]">
              <xsl:value-of select="@nymRef" />
              <xsl:if test="position()!=last()">, </xsl:if>
            </xsl:for-each>
          </field>
          <field name="index_external_resource">
            <xsl:value-of select="$idno/tei:idno" />
          </field>
          <xsl:apply-templates select="$emperor" />
        </doc>
      </xsl:for-each> -->
      
      <!-- the following code handles single values inside @ref/@key and takes into account also epithets in @group-by -->
      <xsl:for-each-group select="//tei:persName[@type='emperor'][@ref or @key]" group-by="concat(translate(@ref, '#', ''), '-', translate(@key, '#', ''), '-', string-join(descendant::tei:addName/@nymRef, ' '))">
        <xsl:variable name="self" select="."/>
        <xsl:variable name="id">
          <xsl:choose>
            <xsl:when test="@ref">
              <xsl:value-of select="translate(normalize-unicode(@ref), '#', '')"/>
            </xsl:when>
            <xsl:when test="@key and not(@ref)">
              <xsl:value-of select="translate(normalize-unicode(@key), '#', '')"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="emperorsAL" select="'../../content/xml/authority/emperors.xml'"/>
        <xsl:variable name="idno" select="document($emperorsAL)//tei:person[@xml:id=$id]"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="doc-available($emperorsAL) = fn:true() and $idno">
                <xsl:value-of select="$idno/tei:persName" />
                <xsl:if test="$idno/tei:floruit"><xsl:text> (</xsl:text><xsl:value-of select="$idno/tei:floruit" /><xsl:text>)</xsl:text></xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
            <field name="index_item_sort_name">
              <xsl:if test="doc-available($emperorsAL) = fn:true() and $idno">
              <xsl:value-of select="$idno/@n" />
              </xsl:if>
            </field>
          <field name="index_epithet">
            <xsl:for-each select="descendant::tei:addName[@nymRef][not(ancestor::tei:persName[ancestor::tei:persName=$self])]">
              <xsl:value-of select="@nymRef" />
              <xsl:if test="position()!=last()">, </xsl:if>
            </xsl:for-each>
          </field>
            <field name="index_external_resource">
              <xsl:if test="doc-available($emperorsAL) = fn:true() and $idno">
                <xsl:for-each select="$idno/tei:idno">
                  <xsl:value-of select="."/>
                  <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
                </xsl:for-each>
              </xsl:if>
            </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>
  
  <xsl:template match="tei:persName[@type='emperor']">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>
  
</xsl:stylesheet>
