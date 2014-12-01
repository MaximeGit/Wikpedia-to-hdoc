<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Scripts are not useful to us -->
    <xsl:template match="script"/>

    <!-- Ignoring divs that are not useful and that might interfere with the true xslt transformation -->
    <xsl:template match="/html/body/div/div/div/div"/>
</xsl:stylesheet>