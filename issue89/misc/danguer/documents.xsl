<!-- documents.xsl -->
<xsl:stylesheet version="1.0"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/"> 
  <html> 
    <head>
      <title>My Documents</title>
    </head>
    
    <body>
	  <xsl:apply-templates select="//document"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="document">
  <xsl:variable name="doc_path">docs</xsl:variable>
  <xsl:variable name="doc_subpath"><xsl:value-of select="module"/></xsl:variable>
  <table width="100%">
     <!-- I will omit all the "fashion" of the tables :-) -->
      <tr>
	     <td>
		    <b>Title: <xsl:value-of select="title"/></b>
		 </td>
	 </tr>
	 <tr>
	     <td>
		    <b>Author: <xsl:value-of select="author"/></b>
		 </td>
	  </tr>
	 <tr>
	     <td>
		    <table width="100%">
			   <tr>
			      <td width="33%">
				     <xsl:if test="format/@pdf = 'yes'">
					   <a href="{$doc_path}/{$doc_subpath}/{$doc_subpath}.pdf">PDF</a>
					 </xsl:if>
					 <![CDATA[&nbsp;]]> <!-- blank space, so your browser could 
					                         format perfectly if the 'xsl:if' fails -->
				  </td>
			      <td width="33%">
				     <xsl:if test="format/@ps = 'yes'">
					   <a href="{$doc_path}/{$doc_subpath}/{$doc_subpath}.ps">PS</a>
					 </xsl:if>
					 <![CDATA[&nbsp;]]> <!-- blank space, so your browser could 
					                         format perfectly if the 'xsl:if' fails -->
				  </td>
			      <td width="33%">
				     <xsl:if test="format/@html = 'yes'">
					   <a href="{$doc_path}/{$doc_subpath}/{$doc_subpath}/">HTML (online)</a>
					 </xsl:if>
					 <![CDATA[&nbsp;]]> <!-- blank space, so your browser could 
					                         format perfectly if the 'xsl:if' fails -->
				  </td>
			   </tr>
			</table>
		 </td>
	  </tr>
  </table>
</xsl:template>

</xsl:stylesheet>
