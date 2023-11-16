<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
   </xsl:template>

  <xsl:template match="/domain/devices">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>

        <xsl:element name="input">
            <xsl:attribute name="type">tablet</xsl:attribute>
            <xsl:attribute name="bus">virtio</xsl:attribute>
              <address type="pci" domain="0x0000" bus="0x00" slot="0x08" function="0x0"/>
        </xsl:element>

        <xsl:element name="sound">
            <xsl:attribute name="model">ich9</xsl:attribute>
               <address type="pci" domain="0x0000" bus="0x00" slot="0x1b" function="0x0"/>
        </xsl:element>

    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
