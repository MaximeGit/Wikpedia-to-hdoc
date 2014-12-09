<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns="http://www.utc.fr/ics/hdoc/xhtml">
    
    <xsl:output method="xhtml" indent="yes"/>
    
    <xsl:template match="*"/>
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="html">
        <!-- Schema link -->
        <xsl:processing-instruction name="oxygen">RNGSchema="http://scenari.utc.fr/hdoc/schemas/xhtml/hdoc1-xhtml.rng" type="xml"</xsl:processing-instruction>
        <xsl:text>&#10;</xsl:text>
        
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
    <xsl:template match="h1[1]" mode="introduction">
        <section data-hdoc-type="introduction">
            <header>
                <h1>Introduction</h1>
            </header>
            
            <!-- Introduction text before first h2 (first section) -->
            <xsl:if test="//p[count(preceding::h2)=0]">
                <div><xsl:apply-templates select="//p[count(preceding::h2)=0]" mode="textOnly"/></div>
            </xsl:if>
        </section>
    </xsl:template>

    <!-- Wikipedia sections and subsections -->
    <xsl:template match="h2|h3|h4|h5">
        <section>
            <!-- h3 sections are opale "grains" -->
            <xsl:if test="self::h3">
                <xsl:attribute name="data-hdoc-type">unit-of-content</xsl:attribute>
            </xsl:if>
            <header>
                <h1><xsl:apply-templates select="node()" mode="title"/></h1>
            </header>
            
            <!-- Storing current section to know when apply template has to be called in the next parts of the template -->
            <xsl:variable name="currentSectionTitle" select="." />

            <!-- If there is text right below the section name, copy it -->
            <xsl:if test="not(following-sibling::*[1] intersect following-sibling::h3) and not(following-sibling::*[1] intersect following-sibling::h4) and not(following-sibling::*[1] intersect following-sibling::h5) and not(following-sibling::*[1] intersect following-sibling::h6)">
                <div>
                    <xsl:for-each select="following-sibling::* intersect following-sibling::h2[1]/preceding-sibling::*">
                        <xsl:if test="not(preceding-sibling::h3 intersect $currentSectionTitle/following-sibling::h3) and not($currentSectionTitle/following-sibling::h4 intersect preceding-sibling::h4) and not($currentSectionTitle/following-sibling::h5 intersect preceding-sibling::h5) and not($currentSectionTitle/following-sibling::h6 intersect preceding-sibling::h6) and not(self::h3) and not(self::h4)  and not(self::h5)  and not(self::h6)">
                            <xsl:apply-templates select="." mode="textOnly"/>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </xsl:if>
            
            <!-- Applying template of subsections if any -->
            <xsl:choose>
                <xsl:when test="self::h2">
                    <!-- h2 can have h3 subsections -->
                    <xsl:apply-templates select="following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3"/>
                </xsl:when>
                <xsl:when test="self::h3">
                    <!-- Apply template to h4 subsections of h3. These h4 are below the current h3: previous h3 of these h4 is current h3. -->
                    <xsl:for-each select="following-sibling::h4 intersect following-sibling::h2[1]/preceding-sibling::h4">
                        <xsl:if test="(preceding-sibling::h3[1] intersect $currentSectionTitle)">
                            <xsl:apply-templates select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="self::h4">
                    <!-- Apply template aux h5 devant qui sont soit avant un h2, soit un h3, soit un h4 -->
                    <xsl:for-each select="following-sibling::h5 intersect following-sibling::h2[1]/preceding-sibling::h5">
                        <xsl:if test="(preceding-sibling::h3[1] intersect $currentSectionTitle/preceding-sibling::h3[1]) and (preceding-sibling::h4[1] intersect $currentSectionTitle)">
                            <xsl:apply-templates select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="self::h5">
                    <!-- Apply template aux h6 devant qui sont soit avant un h2, soit un h3, soit un h4 -->
                    <xsl:for-each select="following-sibling::h6 intersect following-sibling::h2[1]/preceding-sibling::h6">
                        <xsl:if test="(preceding-sibling::h3[1] intersect $currentSectionTitle/preceding-sibling::h3[1]) and (preceding-sibling::h4[1] intersect $currentSectionTitle/preceding-sibling::h4[1]) and (preceding-sibling::h5[1] intersect $currentSectionTitle)">
                            <xsl:apply-templates select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </section>
    </xsl:template>
    
    <!-- Wikipedia h6 is not a section in hdoc: div with h6 title -->
    <xsl:template match="h6">
        <div>
            <h6><xsl:apply-templates select="node()" mode="titleh6"/></h6>
            
            <xsl:variable name="currentSectionTitle" select="." />
            <!-- Text of h6 is contained between current h6 and next section title (next h3/h4/h5/h6) -->
            <xsl:for-each select="following-sibling::* intersect following-sibling::h2[1]/preceding-sibling::*">
                <xsl:if test="not(preceding-sibling::h3 intersect $currentSectionTitle/following-sibling::h3) and not($currentSectionTitle/following-sibling::h4 intersect preceding-sibling::h4) and not($currentSectionTitle/following-sibling::h5 intersect preceding-sibling::h5) and not($currentSectionTitle/following-sibling::h6 intersect preceding-sibling::h6) and not(self::h3) and not(self::h4)  and not(self::h5)  and not(self::h6)">
                    <xsl:apply-templates select="." mode="textOnly"/>
                </xsl:if>
            </xsl:for-each>
        </div>
    </xsl:template>

    <!-- Text elements not surrounded by div -->
    <xsl:template match="p|span|i|ul|ol" mode="textOnly">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <xsl:apply-templates select="node()" mode="textOnly"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Paragraph template -->
    <xsl:template match="p">
        <div>
            <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
                <xsl:apply-templates select="node()" mode="textOnly"/>
            </xsl:element>
        </div>
    </xsl:template>
    
    <!-- li -->
    <xsl:template match="li" mode="#all">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <p><xsl:apply-templates select="node()" mode="textOnly"/></p>
        </xsl:element>
    </xsl:template>
    
    <!-- text followed directly by ul not allowed in li -->
    <xsl:template match="li[descendant::ul]" mode="#all">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <p><xsl:apply-templates select="descendant::node() intersect descendant::ul[1]/preceding-sibling::node()" mode="textOnly"/></p>
            <xsl:apply-templates select="descendant::ul" mode="textOnly"/>
        </xsl:element>
    </xsl:template>
    
    <!-- dl/dt/dd in each in a div -->
    <xsl:template match="dl[descendant::dt]" mode="#all">
        <ul><xsl:apply-templates select="dt"/></ul>
    </xsl:template>
    
    <xsl:template match="dl[not(descendant::dt)]" mode="#all">
        <xsl:apply-templates select="dd"/>
    </xsl:template>
    
    <!-- dt contains the title -->
    <xsl:template match="dt">
        <li>
            <p><em><xsl:apply-templates select="node()" mode="titleh6"/></em></p>
            
            <!-- Some dt are followed by multiple dd before next dd: make sure to copy text of each dd before next dt -->
            <xsl:variable name="currentElement" select="."/>
            <xsl:apply-templates select="following-sibling::dd[preceding-sibling::dt[1] intersect $currentElement]"/>
            
            <!-- Some wikipedia articles don't use dd after dt... -->
            <xsl:if test="not(following-sibling::dd[1])">
                <xsl:apply-templates select="../following-sibling::p[1]" mode="textOnly"/>
            </xsl:if>
        </li>
    </xsl:template>
    
    <!-- dd contains the content -->
    <xsl:template match="dd">
        <p><xsl:apply-templates select="node()"/></p>
        <xsl:apply-templates select="ul|ol" mode="textOnly"/>
    </xsl:template>
    
    <!-- Rules for title elements (h1, h2...) -->
    <xsl:template match="*" mode="title">
        <xsl:apply-templates select="node()" mode="title"/>
    </xsl:template>
    
    <xsl:template match="*" mode="titleh6" priority="2">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="b" mode="textOnly">
        <!-- b is not allowed, however em is allowed: replacing all b by em -->
        <xsl:element name="em" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <xsl:apply-templates select="node()" mode="textOnly"/>
        </xsl:element>
    </xsl:template>
    
    <!-- b outside p, wrap it into a p (and convert it to em) -->
    <xsl:template match="b[not(ancestor::p) and not(ancestor::li) and not(ancestor::a)]" mode="textOnly">
        <p><em><xsl:apply-templates select="node()" mode="textOnly"/></em></p>
    </xsl:template>
    
    <!-- Link elements -->
    <!-- a in title not allowed, only keeping text -->
    <xsl:template match="h2/span/a | h3/span/a | h4/span/a | h5/span/a | h6/span/a" mode="#all">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="a" mode="#all">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <xsl:attribute name="href" select="concat('http://wikipedia.org', @href)"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <!-- Link elements without actual wikipedia page: keeping only their text -->
    <xsl:template match="a[contains(@class, 'new')]" mode="#all">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- ===== Ignored content ===== -->
    
    <!-- Only keeping a with information: we give up page references -->
    <xsl:template match="a[starts-with(@href, '#')]" mode="#all"/>
    
    <!-- Removing Wikipedia internal sup, they are not useful to us (sup are "cite source / reference" etc...) -->
    <xsl:template match="sup" mode="#all"/>
    
    <!-- Ignoring empty text elements only relevant to Wikipedia -->
    <xsl:template match="p[empty(node())]" mode="#all" priority="2"/>
    <xsl:template match="span[contains(@class, 'mw-edit')]" mode="#all" priority="2"/>
    
    <!-- Ignoring table of contents h2 -->
    <xsl:template match="div[@id='toctitle']/h2" priority="1"/>
    
    <!-- Ignoring end of file h2: see also, etc... -->
    <xsl:template match="h2[not(following-sibling::p intersect following-sibling::h2[1]/preceding-sibling::p)]"/>
    
    <!-- Ignoring tables -->
    <xsl:template match="table" mode="textOnly"/>
    
    <!-- Ignoring divs by default: they are not relevant to us -->
    <xsl:template match="div" mode="#all"/>
</xsl:stylesheet>