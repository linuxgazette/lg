<!-- hello_style.xsl -->
<xsl:stylesheet version="1.0"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                  
<xsl:template match="/"> 
  <xsl:variable name="color"><xsl:value-of select="//text/@color"/></xsl:variable>
  <html> 
    <head>
      <title>Extracting <xsl:value-of select="//text"/> </title>
    </head>
    
    <body>
       <p>
           The <b>text</b> of the root element is: <font color="{$color}"><xsl:value-of select="//text"/></font>
       </p>   
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>
