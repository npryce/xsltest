<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:test="http://www.natpryce.com/testxslt/1.0"
		exclude-result-prefixes="test">
  
  <xsl:import href="xmlverbatim.xslt"/>
  
  <xsl:output method="xhtml"
	      indent="yes"
	      encoding="utf-8"
	      />
  
  <xsl:param name="title">Test Results</xsl:param>
  <xsl:param name="css" select="resolve-uri('report.css')"/>
  
  <xsl:template match="/">
    <html>
      <head>
	<title><xsl:copy-of select="$title"/></title>
	<link rel="stylesheet" type="text/css" href="{$css}"/>
      </head>
      <body>
	<h1><xsl:copy-of select="$title"/></h1>
	
	<xsl:variable name="passed" select="count(//test:assert[@result='passed'])"/>
	<xsl:variable name="failed" select="count(//test:assert[@result='failed'])"/>
	
	<p>
	  <xsl:attribute name="class">
	    <xsl:choose>
	      <xsl:when test="$failed = 0">summary passed</xsl:when>
	      <xsl:otherwise>summary failed</xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	  <xsl:value-of select="count(//test:assert)"/> assertions:
	  <xsl:value-of select="$passed"/> passed,
	  <xsl:value-of select="$failed"/> failed.
	</p>
	
	<xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="test:suite">
    <div>
      <xsl:attribute name="class">
	<xsl:choose>
	  <xsl:when test=".//*[@result = 'failed']">suite failed</xsl:when>
	  <xsl:otherwise>suite passed</xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="test:assert[@that]">
    <xsl:if test="@result = 'failed'">
      <p class="failed">Failed: <xsl:value-of select="@that"/></p>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="test:assert[test:actual and test:expected]">
    <xsl:if test="@result = 'failed'">
      <div class="diagnostics">
	<table>
	  <tr><th>Expression</th><td><xsl:apply-templates select="test:expr"/></td></tr>
	  <tr><th>Expected</th><td><xsl:apply-templates select="test:expected"/></td></tr>
	  <tr><th>Actual</th><td><xsl:apply-templates select="test:actual"/></td></tr>
	</table>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="test:assert[test:original and test:expected and test:transformed]">
    <xsl:if test="@result = 'failed'">
      <div class="diagnostics">
	<p>Transform failed:</p>
	<table>
	  <tr><th>Original</th><td><xsl:apply-templates select="test:original"/></td></tr>
	  <tr><th>Expected</th><td><xsl:apply-templates select="test:expected"/></td></tr>
	  <tr><th>Actual</th><td><xsl:apply-templates select="test:transformed"/></td></tr>
	</table>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="test:original|test:expected|test:transformed|test:actual|test:expr|test:show-working">
    <div class="xmlverb-default">
      <xsl:apply-templates mode="xmlverb">
        <xsl:with-param name="indent-elements" select="true()"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xsl:template match="test:*"/>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
