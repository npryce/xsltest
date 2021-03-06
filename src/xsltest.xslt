<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:test="http://www.natpryce.com/xsltest/1.0"
		xmlns:xslo="http://www.natpryce.com/xsltest/1.0/xsltoutput">
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:namespace-alias stylesheet-prefix="xslo" result-prefix="xsl"/>
  
  <xsl:template match="xsl:import">
    <xslo:import href="{resolve-uri(@href, base-uri())}"/>
  </xsl:template>
  
  <xsl:template match="test:import">
    <xslo:import href="{@href}"/>
  </xsl:template>
  
  <xsl:template match="test:assert">
    <test:assert>
      <xsl:apply-templates select="@*"/>
      
      <xslo:attribute name="result" select="if ({@that}) then 'passed' else 'failed'"/>
      
      <xsl:apply-templates/>
    </test:assert>
  </xsl:template>
  
  <xsl:template match="test:assert-equal|test:assert-equals">
    <test:assert>
      <xslo:variable name="expected">
        <xsl:choose>
          <xsl:when test="@expected"><xsl:attribute name="select" select="@expected"/></xsl:when>
          <xsl:otherwise><xsl:copy-of select="*"/></xsl:otherwise>
        </xsl:choose>
      </xslo:variable>
      <xslo:attribute name="result" 
		      select="if (deep-equal({@actual}, $expected)) then 'passed' else 'failed'"/>
      
      <test:expr><xsl:value-of select="@actual"/></test:expr>
      <test:actual><xslo:copy-of select="{@actual}"/></test:actual>
      <test:expected><xslo:copy-of select="$expected"/></test:expected>
    </test:assert>
  </xsl:template>
  
  <xsl:template match="test:assert-transform">
    <test:assert>
      <xslo:variable name="original">
	<xsl:copy-of select="test:original/*"/>
      </xslo:variable>
      <xslo:variable name="transformed">
	<xslo:apply-templates select="$original">
	  <xsl:copy-of select="xsl:with-param"/>
	</xslo:apply-templates>
      </xslo:variable>
      <xslo:variable name="expected">
	<xsl:copy-of select="test:expected/*"/>
      </xslo:variable>
      
      <xslo:attribute name="result" 
		      select="if (deep-equal($transformed, $expected)) then 'passed' else 'failed'"/>
      
      <xsl:apply-templates select="*[namespace-uri() != 'http://www.w3.org/1999/XSL/Transform']"/>
      
      <test:transformed>
	<xslo:copy-of select="$transformed"/>
      </test:transformed>
    </test:assert>
  </xsl:template>
  
  <xsl:template match="test:diagnostic">
    <test:diagnostic>
      <xslo:copy-of select="{@select}"/>
    </test:diagnostic>
  </xsl:template>
  
  <xsl:template match="test:suite|test:original|test:expected|test:transformed">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="test:*">
      <xsl:value-of select="error(test:unknown-element, concat('Unknown test element ',name()))"/>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
