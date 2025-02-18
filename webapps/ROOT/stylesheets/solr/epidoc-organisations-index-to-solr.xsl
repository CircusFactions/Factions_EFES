<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of military units in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:rs[@type='military'][@ref]|//tei:orgName[ancestor::tei:div[@type='edition']][@ref]" group-by="translate(concat(@ref, '-', @nymRef, '-', string-join(descendant::tei:addName/@nymRef, '')), '#', '')">
        <xsl:variable name="self" select="."/>
        <xsl:variable name="id" select="translate(@ref, '#', '')"/>
        <xsl:variable name="idno" select="document('../../content/xml/authority/organisations.xml')//tei:org[@xml:id=$id]"/>
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
                <xsl:value-of select="$idno/tei:orgName[@xml:lang='en']" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_attested_form">
            <xsl:value-of select="translate(@nymRef, '#', '')"/>
          </field>
          <field name="index_epithet">
            <xsl:for-each select="descendant::tei:addName[@nymRef][not(ancestor::tei:orgName[ancestor::tei:orgName=$self])]">
              <xsl:value-of select="translate(@nymRef, '#', '')" />
              <xsl:if test="position()!=last()">, </xsl:if>
            </xsl:for-each>
          </field>
          <!--<field name="index_external_resource">
            <xsl:value-of select="$idno/tei:idno" />
          </field>-->
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:rs[@type='military']|tei:orgName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
