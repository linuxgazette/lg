<?xml version="1.0"?>

<!-- Written by Eoin Lane "eoinlane@esatclear.ie" -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/XSL/Transform/1.0">

  <xsl:template match="page">
   <xsl:processing-instruction name="cocoon-format">type="text/html"</xsl:processing-instruction>
   <html>
    <head>
     <title>
      <xsl:value-of select="title"/>
     </title>
    </head>
    <body bgcolor="#ffffff">
     <xsl:apply-templates/>
    </body>
   </html>
  </xsl:template>

  <xsl:template match="title">
   <h1 align="center">
    <xsl:apply-templates/>
   </h1>
  </xsl:template>

  <xsl:template match="author">
    <h2 align="center">
     by <xsl:apply-templates/>
   </h2>
  </xsl:template>

  <xsl:template match="abstract">
   <p align="justify">
     <b>Abstract: </b> 
     <i>
     <xsl:apply-templates/>
     </i>
   </p>
  </xsl:template>

  <xsl:template match="update">
   <p align="justify">
     <xsl:apply-templates/>
   </p>
  </xsl:template>


  <xsl:template match="sectionTitle">
   <h2 align="left">
    <xsl:apply-templates/>
   </h2>
  </xsl:template>

  <xsl:template match="subsectionTitle">
   <h3 align="left">
    <xsl:apply-templates/>
   </h3>
  </xsl:template>

  <xsl:template match="para">
   <p align="justify">
     <xsl:apply-templates/>
   </p>
  </xsl:template>

  <xsl:template match="list">
       <ul>
         <xsl:apply-templates/>
       </ul>
  </xsl:template>

  <xsl:template match="list/item">
       <li> 
       <xsl:apply-templates/> 
       </li>
  </xsl:template>


  <xsl:template match="dir">
     <font face="serif" color="black" size="4">
       <xsl:apply-templates/>
     </font>
  </xsl:template>

  <xsl:template match="file">
     <font face="serif" color="black" size="4">
        <xsl:apply-templates/>
     </font>
  </xsl:template>

  <xsl:template match="link">
    <A HREF="{url}">
      <xsl:value-of select="text"/>
    </A>
  </xsl:template>

  <xsl:template match="instruction">
     <font face="serif" color="red" size="3">
       <p>
        <xsl:apply-templates/>
       </p>
     </font>
  </xsl:template>

  <xsl:template match="emphasis">
   <i>
    <xsl:apply-templates/>
   </i>
  </xsl:template>

  <xsl:template match="fileText">
       <p>
        <xsl:apply-templates/>
       </p>
  </xsl:template>

  <xsl:template match="fileText/text">
     <font face="serif" color="blue" size="3">
       <i> 
         <xsl:apply-templates/> 
        <br></br>
       </i>
     </font>
  </xsl:template>

  <xsl:template match="statement">
       <p align="center">
        <b>
        <xsl:apply-templates/>
        </b>
       </p>
  </xsl:template>



  <xsl:template match="msg">
       <p align="left"> 
         <xsl:apply-templates/>
       </p>
  </xsl:template>

  <xsl:template match="msg/line">
     <font face="serif" color="brown" size="3">
       <i> 
        <xsl:apply-templates/> 
	<br></br>
       </i>
       </font>
  </xsl:template>

</xsl:stylesheet>

