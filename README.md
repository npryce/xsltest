XSLTest: a Tiny Testing Library for XSLT Transformations.
=========================================================

Requirements:
-------------

 * An XSLT 2 processor, such as Saxon.
 * A web browser to view the test reports.


Overview
--------

XSLTest lets you test XSLT transforms and functions using a mix of
XSLT code, XSLTest elements that define assertions and test suites and
embedded HTML documentation.

An XSLTest suite is an XSLT stylesheet with named templates that
generate HTML and also contain XSLTest elements.  

The XSLTest framework acts as a compiler: the `xsltest.xslt`
stylesheet translates a test suite into a stylesheet that performs the
assertions and generates results in XML format.  XSLTest's
`report.xslt` stylesheet translates the results into an HTML report.

XSLTest also provides a stylesheet, `test-abort-build.xslt`, that
fails if the results XML contain any test failures.  This is useful
for aborting the build when tests fail.


Test Suite Structure and XML Namespaces
---------------------------------------

XSLTest elements are defined in the namespace http://www.natpryce.com/xsltest/1.0.

The entry-point to a test suite is a named XSLT template.  For example:

    <xsl:stylesheet version="2.0"
                    xmlns="http://www.w3.org/1999/xhtml" 
                    xmlns:html="http://www.w3.org/1999/xhtml" 
                    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
                    xmlns:test="http://www.natpryce.com/xsltest/1.0">

      <xsl:import href="mycode.xslt"/>
      
      <xsl:template name="mycode-tests">
          <test:suite>
              <h1>Tests for My Code</h1>
              
              ... assertions and suites go here ...

          </test:suite>
      </xsl:template>
    </xsl:stylesheet>


Example Makefile Rules
----------------------

The following example Makefile rules implement the XSLTest processing pipeline.

They assume that:

 * The variable XSLTEST_HOME refers to the directory containing the
   XSLTest stylesheets.
 * The test suite files all have the suffix `-test.xslt` and are in the
   `src/` directory alongside the code under test.
 * Output is generated into a scratch directory named `build/testing`
 * There is a single root test suite, named `all-tests.xslt`, that
   imports all the other test suites in the test directory.


    build/testing/%.xslt: src/%-test.xslt
    	@mkdir -p $(dir $@)
    	saxon -xsl:$(XSLTEST_HOME)/xsltest.xslt -s:$< -o:$@
    
    build/testing/results.xml: $(XSLT_TESTS:tests/%.xslt=build/testing/%.xslt) $(XSLT)
    	saxon -xsl:build/testing/all-tests.xslt -it:all-tests -o:$@
    
    build/testing/report.html: build/testing/results.xml
    	saxon -xsl:$(XSLTEST_HOME)/report.xslt -s:$< -o:$@
    
    # Avoid saxon's slow startup if we can say for sure that no tests failed
    check: build/testing/report.html
    	@if grep -q -m 1 'result="failed"' build/testing/results.xml; then \
    	    saxon -xsl:$(XSLTEST_HOME)/test-abort-build.xslt -s:build/testing/results.xml; \
    	fi
