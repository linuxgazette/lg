<!-- cards.xml -->

<xsl:stylesheet version="1.0"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
	<html>
		<head>
		  <title>Person Information</title>
		</head>
		
		<body>
		  <p>
		    <center><h1>People who works in this company</h1></center>
		  </p>
		  <xsl:apply-templates select="//person">
		    <xsl:sort select="firstname" />
		  </xsl:apply-templates>
		</body>
	</html>
</xsl:template>


<xsl:template match="person">

  <table width="40%" border="0" align="center" bgcolor="#DEE7EC">
    <tr>
	  <td width="20%" bgcolor="#cccccc">
	    <div align="right"><b>name: </b></div>
	  </td>
	  <td width="80%">
	    <xsl:value-of select="firstname" /> <xsl:value-of select="lastname" /> 
	  </td>
    </tr>

    <tr>
	  <td width="20%" bgcolor="#eeeeee">
	    <div align="right"><b>address: </b></div>
	  </td>
	  <td width="80%">
	    <xsl:value-of select="address" />
	  </td>
    </tr>

    <tr>
	  <td width="20%" bgcolor="#cccccc">
	    <div align="right"><b>mail: </b></div>
	  </td>
	  <td width="80%">
	    <xsl:variable name="href_email"><xsl:value-of select="email" /></xsl:variable>
		<a href="mailto:{$href_email}"><xsl:value-of select="email" /></a>
	  </td>
    </tr>

    <tr>
	  <td width="20%" bgcolor="#eeeeee">
	    <div align="right"><b>homepage: </b></div>
	  </td>
	  <td width="80%">
	    <xsl:variable name="href_homepage"><xsl:value-of select="homepage" /></xsl:variable>
	    <a href="http://{$href_homepage}"><xsl:value-of select="homepage" /></a>
	  </td>
    </tr>
  </table>
<br/>
</xsl:template>

</xsl:stylesheet>