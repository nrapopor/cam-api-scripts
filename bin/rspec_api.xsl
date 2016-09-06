<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
	<xsl:output encoding="UTF-8" indent="yes" method="xml" standalone="no" omit-xml-declaration="no"/>
	<xsl:template match="testcase">
                  <test><xsl:attribute name="name"><xsl:value-of select="./@name"/></xsl:attribute>
			<xsl:attribute name="time"><xsl:value-of select="./@time"/></xsl:attribute>
<xsl:choose>
	<xsl:when test="./failure">
		<xsl:attribute name="status">INCOMPLETE</xsl:attribute>
		<xsl:attribute name="type"><xsl:value-of select="./failure/@type"/></xsl:attribute>
		<message>
                	<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
			<xsl:value-of select="./failure/@message" />
			<xsl:value-of select="./failure/text()" />
                        <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
		</message>
	</xsl:when>
	<xsl:otherwise>
	        <xsl:attribute name="status">PASSED</xsl:attribute>
		<xsl:attribute name="type">SUCCESS</xsl:attribute>
	</xsl:otherwise>
</xsl:choose></test>
	</xsl:template>
	<xsl:template match="/">
                <tests><xsl:apply-templates/></tests>
	</xsl:template>
</xsl:stylesheet>
