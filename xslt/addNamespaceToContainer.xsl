<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns="urn:utc.fr:ics:hdoc:container">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Identity transformation -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>       
    </xsl:template>   
    
    <!-- Namespace substitution for hdoc elements -->           
    <xsl:template match="*" priority="1">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="container" priority="1">
        <xsl:processing-instruction name="oxygen">RNGSchema="http://scenari.utc.fr/hdoc/schemas/container/hdoc1-container.rng" type="xml"</xsl:processing-instruction>
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Suppress processing-instructions -->    
    <xsl:template match="processing-instruction()" priority="1"/>
    
</xsl:stylesheet>