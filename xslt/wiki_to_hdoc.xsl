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
    <xsl:template match="h1[1]" mode="introduction">
        <section data-hdoc-type="introduction">
            <header>
                <h1>Introduction</h1>
            </header>
            <xsl:apply-templates select="//p[count(preceding::h2)=0]"/>
        </section>
    </xsl:template>

    <!-- All major parts of the document: h2, except the table of contents one -->
    <xsl:template match="h2[following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3]">
        <section data-hdoc-type="opale-expUc">
            <header>
                <h1><xsl:apply-templates select="node()" mode="title"/></h1>
            </header>
            
            <!-- If there is some text right under h2, copy it -->
            <xsl:apply-templates select="following-sibling::* intersect following-sibling::h2[1]/preceding-sibling::h3/preceding-sibling::* intersect following-sibling::h3[1]/preceding-sibling::*"/>
            
            <!-- if h3: sub-sections -->
            <xsl:apply-templates select="following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3"/>
        </section>
    </xsl:template>
    
    <!-- h2 with only text: no h3 under these h2 -->
    <xsl:template match="h2[not(following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3)]">
        <section>
            <header>
                <h1><xsl:apply-templates select="node()" mode="title"/></h1>
            </header>
            <xsl:apply-templates select="following-sibling::* intersect following-sibling::h2[1]/preceding-sibling::*"/>
        </section>
    </xsl:template>
    
    <!-- table of contents h2: ignored -->
    <xsl:template match="div[@id='toctitle']/h2" priority="1"/>
    <!-- Ignoring end of file h2: see also, etc... -->
    <xsl:template match="h2[not(following-sibling::p intersect following-sibling::h2[1]/preceding-sibling::p)]"/>
    
    <!-- Matching h3 without h4 under them, followed by other h3 (h3 > h3)-->
    <xsl:template match="h3[not(following-sibling::h4[1] intersect following-sibling::h3[1]/preceding-sibling::h4) and (following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3)]">
        <section>
            <header>
                <h1><xsl:apply-templates select="node()" mode="title"/></h1>
            </header>
            <!-- h3 div: text of the sub-section -->
            <xsl:apply-templates select="following-sibling::* intersect following-sibling::h2[1]/preceding-sibling::* intersect following-sibling::h3[1]/preceding-sibling::*"/>
        </section>
    </xsl:template>
    
    <!-- Matching h3 without h4 under them, followed by h2 (h3 > h2) -->
    <xsl:template match="h3[not(following-sibling::h4[1] intersect following-sibling::h2[1]/preceding-sibling::h4) and not(following-sibling::h3 intersect following-sibling::h2[1]/preceding-sibling::h3)]">
        <section>
            <header>
                <h1><xsl:apply-templates select="node()" mode="title"/></h1>
            </header>
            <!-- h3 div: text of the sub-section -->
            <xsl:apply-templates select="following-sibling::* intersect following-sibling::h2[1]/preceding-sibling::*"/>
        </section>
    </xsl:template>
    
    <!-- Other h3: have h4 under them (h3 > h4) -->
    <xsl:template match="h3">
        <section>
            <header>
                <h1><xsl:apply-templates select="node()" mode="title"/></h1>
            </header>
            
            <!-- If there is some text right under h3 before h4, copy it -->
            <xsl:apply-templates select="following-sibling::* intersect following-sibling::h4[1]/preceding-sibling::*"/>
            
            <!-- Applying template to next h4 -->
            <xsl:if test="following-sibling::h3[1] intersect following-sibling::h2[1]/preceding-sibling::h3">
                <xsl:apply-templates select="(following-sibling::h4 intersect following-sibling::h3[1]/preceding-sibling::h4) | (following-sibling::h5 intersect following-sibling::h3[1]/preceding-sibling::h5) | (following-sibling::h6 intersect following-sibling::h3[1]/preceding-sibling::h6)"/>
            </xsl:if>
            <xsl:if test="not(following-sibling::h3[1] intersect following-sibling::h2[1]/preceding-sibling::h3)">
                <xsl:apply-templates select="(following-sibling::h4 intersect following-sibling::h2[1]/preceding-sibling::h4) | (following-sibling::h5 intersect following-sibling::h2[1]/preceding-sibling::h5) | (following-sibling::h6 intersect following-sibling::h2[1]/preceding-sibling::h6)"/>
            </xsl:if>
        </section>
    </xsl:template>
 
    <xsl:template match="h4|h5|h6">
        <div>
            <h6><xsl:apply-templates select="node()" mode="titleh6"/></h6>
            
            <!-- Manage case where no text below h4/h5 and when there is directly next h-->
            <xsl:if test="following-sibling::*[1] intersect following-sibling::h5 or following-sibling::*[1] intersect following-sibling::h6">
                <xsl:apply-templates select="following-sibling::*[1]"></xsl:apply-templates>
            </xsl:if>
            
            <xsl:if test="not(following-sibling::*[1] intersect following-sibling::h5 or following-sibling::*[1] intersect following-sibling::h6)">
                <!-- Last h4/h5/h6 in the document except h2 before next h2 -->
                <xsl:if test="not(following-sibling::h3 | following-sibling::h4 | following-sibling::h5 | following-sibling::h6)">
                    <xsl:apply-templates select="following-sibling::* intersect following-sibling::h2[1]/preceding-sibling::*"/>
                </xsl:if>
                <xsl:variable name="currentSectionTitle" select="." />
                
                <xsl:for-each select="following-sibling::* intersect following-sibling::h2[1]/preceding-sibling::*">
                    <!-- <xsl:if test="not(preceding-sibling::h3[1]/following-sibling::h4 intersect preceding-sibling::h4) and not(preceding-sibling::h4[1]/following-sibling::h4 intersect preceding-sibling::h4 intersect .) and not(preceding-sibling::h4[1]/following-sibling::h5 intersect preceding-sibling::h5) and not(preceding-sibling::h4[1]/following-sibling::h3 intersect preceding-sibling::h3) and not(preceding-sibling::h4[1]/following-sibling::h5 intersect preceding-sibling::h5) and not(preceding-sibling::h4[1]/following-sibling::h6 intersect preceding-sibling::h6) and not(preceding-sibling::h4[1]/following-sibling::h6 intersect preceding-sibling::h6)">
                    <xsl:apply-templates select="."/>
                </xsl:if> -->
                    <xsl:if test="not(preceding-sibling::h4 intersect $currentSectionTitle/following-sibling::h4) and not(self::h3) and not(self::h4)  and not(self::h5)  and not(self::h6) and not($currentSectionTitle/following-sibling::h5 intersect preceding-sibling::h5) and not($currentSectionTitle/following-sibling::h6 intersect preceding-sibling::h6) and not($currentSectionTitle/following-sibling::h3 intersect preceding-sibling::h3)">
                        <xsl:apply-templates select="." mode="textOnly"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </div>
    </xsl:template>

    

    <xsl:template match="div" mode="#all"/>

    <!-- Paragraph template -->
    <xsl:template match="p">
        <div>
            <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
                <xsl:apply-templates select="node()" mode="textOnly"/>
            </xsl:element>
        </div>
    </xsl:template>
    
    <!-- ul/li template -->
    <xsl:template match="ul|ol">
        <div>
             <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
                 <xsl:apply-templates select="node()"/>
             </xsl:element>
        </div>
    </xsl:template>
    
    <!-- ul/li template -->
    <xsl:template match="ul|ol" mode="textOnly">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <!-- dl/dt/dd in each in a div -->
    <xsl:template match="dl">
        <xsl:apply-templates select="dt"/>
    </xsl:template>
    
    <!-- dt contains the title -->
    <xsl:template match="dt">
        <div>
            <h6><xsl:apply-templates select="node()" mode="titleh6"/></h6>
            <xsl:apply-templates select="following-sibling::dd[1]"/>
            
            <!-- Some wikipedia articles don't use dd after dt... -->
            <xsl:if test="not(following-sibling::dd[1])">
                <xsl:apply-templates select="../following-sibling::p[1]" mode="textOnly"/>
            </xsl:if>
        </div>
    </xsl:template>
    
    <!-- dd contains the content -->
    <xsl:template match="dd">
        <p><xsl:apply-templates select="node()"/></p>
    </xsl:template>
    
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
    
    <!-- Text elements -->
    <xsl:template match="p|span|i|ul" mode="textOnly">
        <xsl:element name="{local-name()}" namespace="http://www.utc.fr/ics/hdoc/xhtml">
            <xsl:apply-templates select="node()" mode="textOnly"/>
        </xsl:element>
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

    <!-- h4, h5 and h6 are small in Wikipedia, so we will only put these titles in em -->
    <!-- Attention : Les titres et le contenu sont dans 2 divs en faisant cela : à peut-être changer 
    <xsl:template match="h4|h5|h6" mode="#all">
        <div><p><em><xsl:apply-templates select="node()" mode="textOnly"/></em></p></div>
    </xsl:template>
-->
    <!-- Not keeping empty text elements used in Wikipedia -->
    <xsl:template match="p[empty(node())]" mode="#all" priority="2"/>
    <xsl:template match="span[contains(@class, 'mw-edit')]" mode="#all" priority="2"/>
    
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