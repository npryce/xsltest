<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:test="http://www.natpryce.com/xsltest/1.0">
  
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:variable name="failures" 
		  select="count(//test:assert[@result='failed']) + count(//test:assert-transform[@result='failed'])"/>
    
    <xsl:if test="$failures != 0">
      <xsl:value-of select="error(test:failed, concat($failures, ' tests failed!'))"/>
    </xsl:if>
  </xsl:template>	
</xsl:stylesheet>
