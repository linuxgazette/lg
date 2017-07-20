<!-- variables.xsl -->

<xsl:stylesheet version="1.0"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:template match="/"> 
<!--  definition of the variable  -->
<xsl:variable name="path">http://somedomain/tmp/xslt</xsl:variable>   
    <html>
       <head>
         <title>Examples of Variables</title>
        </head>
       <body>
         <p>
           <a href="{$path}/photo.jpg">Photo of my latest travel</a>
        </p>
       </body>
    </html>
</xsl:template>

</xsl:stylesheet>
