<!-- hello_style.xsl -->
<xsl:stylesheet version="1.0"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                  
<xsl:template match="/"> 
  <html> 
    <head>
      <title>Extracting <xsl:value-of select="//text"/> </title>
    </head>
    
    <body>
       <p>
           The <b>text</b> of the root element is: <b><xsl:value-of select="//text"/></b>
           and his <b>color</b> attribute is: <xsl:value-of select="//text/@color"/>
       </p>   
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>
