<!-- sort.xsl -->

<xsl:stylesheet version="1.0"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="/"> 
    <html>
       <head>
         <title>Examples of Variables</title>
        </head>
       <body>
           <xsl:apply-templates select="//photo">
               <xsl:sort select="file" order="descending"/>
           </xsl:apply-templates>
       </body>
    </html>
</xsl:template>

<xsl:template match="photo"> 
    <!--  definition of the variables  -->
    <xsl:variable name="path">http://somedomain/tmp/xslt</xsl:variable>  
    <xsl:variable name="photo" select="file"/> 
     <p> 
       <a href="{$path}/{$photo}"><xsl:value-of select="description"/></a>
     </p>       
</xsl:template>

</xsl:stylesheet>
