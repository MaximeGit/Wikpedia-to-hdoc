<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns="http://www.utc.fr/ics/hdoc/xhtml">
    
    <xsl:output method="xhtml" indent="yes"/>
    
    <xsl:template match="html">
        
        <!-- Schema link -->
        <xsl:processing-instruction name="oxygen">
            RNGSchema="http://scenari.utc.fr/hdoc/schemas/xhtml/hdoc1-xhtml.rng" type="xml" 
        </xsl:processing-instruction>
        
        <!-- html content -->
        <html>
            <head>
                <xsl:apply-templates select="head"/>
            </head>
            <body>
                <xsl:apply-templates select="body"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- Head template -->
    <xsl:template match="head">
        <xsl:apply-templates select="title"/>
        <meta charset="utf-8" />
        <meta name="generator" content="HdocConverter/wikipedia"/>
        <meta name="author" content="Wikipedia"/>
    </xsl:template>
    
    <!-- Body template -->
    <xsl:template match="body">
        <!-- If there is h1 title with firstHeading class, this has to be the first section title -->
        <xsl:apply-templates select="//h1[1]" mode="introduction"/>
        
        <!-- Next are all parts of the document: h2 -->
        <xsl:apply-templates select="//h2"/>
    </xsl:template>
    
    <xsl:template match="title">
        <title><xsl:value-of select="."/></title>
    </xsl:template>
    
    <!-- Beginning of the wikipedia page: introduction paragraph -->
    <xsl:template match="//h1[1]" mode="introduction">
        <section>
            <header>
                <h1>Introduction</h1>
            </header>
            <xsl:apply-templates select="//p[count(preceding::h2)=0]"/>
        </section>
    </xsl:template>

    <!-- All major parts of the document: h2, except the table of contents one -->
    <xsl:template match="//h2[following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3]">
        <section>
            <header>
                <h1><xsl:apply-templates select="node()"/></h1>
            </header>
            
            <!-- If there is some text right under h2, copy it -->
            <xsl:apply-templates select="following-sibling::p intersect following-sibling::h2[1]/preceding-sibling::h3/preceding-sibling::p intersect following-sibling::h3[1]/preceding-sibling::p"/>
            
            <!-- if h3: sub-sections -->
            <xsl:apply-templates select="following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3"/>
        </section>
    </xsl:template>
    
    <!-- h2 with only text: no h3 under these h2 -->
    <xsl:template match="//h2[not(following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3)]">
        <section>
            <header>
                <h1><xsl:apply-templates select="node()"/></h1>
            </header>
            <xsl:apply-templates select="following-sibling::p intersect following-sibling::h2[1]/preceding-sibling::p"/>
        </section>
    </xsl:template>
    
    <!-- table of contents h2: ignored -->
    <xsl:template match="//div[@id='toctitle']/h2" priority="1"/>
    <!-- Ignoring end of file h2: see also, etc... -->
    <xsl:template match="//h2[not(following-sibling::p intersect following-sibling::h2[1]/preceding-sibling::p)]"/>
    
    <!-- h3: last sub-sections -->
    <xsl:template match="//h3">
        <section>
            <header>
                <h1><xsl:apply-templates select="node()"/></h1>
            </header>
            <!-- h3 div: text of the sub-section -->
            <xsl:apply-templates select="(following-sibling::p intersect following-sibling::h2[1]/preceding-sibling::p intersect following-sibling::h3[1]/preceding-sibling::p) | (following-sibling::ul intersect following-sibling::h2[1]/preceding-sibling::ul intersect following-sibling::h3[1]/preceding-sibling::ul)"/>
            
            <!-- last h3 before next h2 -->
            <xsl:if test="not(following-sibling::h3)">
                <!-- Last h3 of the document was in this section: copying all text before next h2 -->
                <xsl:apply-templates select="following-sibling::p intersect following-sibling::h2[1]/preceding-sibling::p"/>    
            </xsl:if>
        </section>
    </xsl:template>

    <!-- Paragraph template -->
    <xsl:template match="p">
        <div>
            <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
                <xsl:apply-templates select="node()" mode="textOnly"/>
            </xsl:element>
        </div>
    </xsl:template>
    
    
    
    <!-- ul/li template -->
    <xsl:template match="ul">
        <div>
             <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
                 <xsl:apply-templates select="node()" mode="textOnly"/>
             </xsl:element>
        </div>
    </xsl:template>
    
    <xsl:template match="li" mode="textOnly">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <p><xsl:apply-templates select="node()" mode="textOnly"/></p>
        </xsl:element>
    </xsl:template>
    
    <!-- Text elements -->
    <xsl:template match="p|span|i" mode="textOnly">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <xsl:apply-templates select="node()" mode="textOnly"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="b" mode="textOnly">
        <!-- b is not allowed, however em is allowed: replacing all b by em -->
        <xsl:element name="em" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <xsl:apply-templates select="node()" mode="textOnly"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Not keeping empty text elements used in Wikipedia -->
    <xsl:template match="span[empty(text())] | p[empty(node())]" mode="#all"/>
    
    <!-- Link elements -->
    <xsl:template match="a" mode="#all">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <xsl:attribute name="href" select="concat('http://wikipedia.org', @href)"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <!-- Only keeping a with information: we give up page references -->
    <xsl:template match="a[starts-with(@href, '#')]" mode="#all"/>
    
    <!-- Removing reference sup, they are not useful to us -->
    <xsl:template match="sup[contains(@class, 'reference')]" mode="#all"/>
</xsl:stylesheet>