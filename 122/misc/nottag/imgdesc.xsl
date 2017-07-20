<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:image="http://jibbering.com/vocabs/image/#"
  xmlns:img="http://www.w3.org/2004/02/image-regions#"
  xmlns:an="http://www.w3.org/2000/10/annotation-ns#"
  exclude-result-prefixes="rdf foaf dc image img an"
>

 <xsl:output method="html" indent="yes"/>

 <xsl:template name="notice">
 <!-- an explanatory message-->
  <div class="lead" style="margin-left:3em;margin-right:2em">
   <h2>Welcome and enjoy</h2>
   <p>This stylesheet is designed to convert image area annotation RDF to visible XHTML with corresponding description on the image. Uses both JibberJim's image vocabulary and W3Photo imaage region vocabulary.</p>
  <rdf:RDF xmlns:cc="http://web.resource.org/cc/" xmlns:dcterms="http://purl.org/dc/terms/">
   <rdf:Description rdf:about="">
    <dc:description>This stylesheet is copyright (c) 2003-2005 by Masahide Kanzaki.
   You can redistribute it and/or modify it under the terms of 
   the GPL (GNU General Public License) .</dc:description>
    <dcterms:modified>2005-05-09</dcterms:modified>
    <foaf:maker>
     <foaf:Person rdf:about="urn:pin:MK705" foaf:name="Masahide Kanzaki">
      <foaf:mbox rdf:resource="mailto:webmaster@kanzaki.com"/>
     </foaf:Person>
    </foaf:maker>
    <dc:rights>(c) 2003-2005 by the author, copyleft under GPL</dc:rights>
    <cc:license rdf:resource="http://creativecommons.org/licenses/GPL/2.0/"/>
   </rdf:Description>
  </rdf:RDF>
  </div>
 </xsl:template>

 <xsl:variable name="dmax">
  <xsl:choose>
   <xsl:when test="rdf:RDF/@xml:lang = 'ja'">80</xsl:when>
   <xsl:otherwise>160</xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="dmaxl" select="$dmax + 4 "/>
 <xsl:variable name="imgw"><xsl:value-of select="rdf:RDF/foaf:Image/image:width"/></xsl:variable>
 <xsl:variable name="imgh"><xsl:value-of select="rdf:RDF/foaf:Image/image:height"/></xsl:variable>
 
 <xsl:variable name="maxw" select="550"/>
 <xsl:variable name="imgfactor">
  <xsl:choose>
   <xsl:when test="$imgw &gt; $maxw"><xsl:value-of select="$maxw div $imgw"/></xsl:when>
   <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="dispw">
  <xsl:choose>
   <xsl:when test="$imgw &gt; $maxw"><xsl:value-of select="$maxw"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$imgw"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>


 <xsl:template match="/">
  <xsl:apply-templates select="rdf:RDF/foaf:Image"/>
 </xsl:template>

 <!-- main data handling -->
 <xsl:template match="rdf:RDF/foaf:Image">
  <html>
   <head>
    <title><xsl:value-of select="dc:title"/> - image annotation XSLT presentation</title>
    <xsl:call-template name="htmlhead"/>
   </head>
   <body>
    <xsl:call-template name="banner"/>
    <h1>
     <xsl:choose>
      <xsl:when test="dc:title"><xsl:value-of select="dc:title"/></xsl:when>
      <xsl:otherwise>Image Annotation</xsl:otherwise>
     </xsl:choose>
    </h1>
    <div id="absarea">
     <img src="{@rdf:about}" alt="" width="{$dispw}" />
     <xsl:if test="$imgw &gt; $maxw">
      <p class="misc">*This image is displayed as <xsl:value-of select="round($imgfactor * 100)"/>% of the <a href="{@rdf:about}">original</a> size (width reduced from <xsl:value-of select="$imgw"/>px to <xsl:value-of select="$maxw"/>px).</p><!-- format-number doesn't work with sablotron -->
     </xsl:if>
     <xsl:apply-templates select="dc:description"/>
     <div><button onclick="showHide(this)">Hide Annotation</button></div>
     <div id="imgdesc">
      <ul><xsl:for-each select="image:hasPart/image:*/image:points|img:hasRegion/img:*/img:coords"><xsl:call-template name="imgpoints"/></xsl:for-each></ul>
      <h2>Image description</h2>
      <xsl:call-template name="imgdesc"/>
      <h2>Image parts annotation</h2>
      <xsl:apply-templates select="image:hasPart/*|img:hasRegion/*"/>
      <xsl:apply-templates select="../rdf:Description"/>
     </div>
     <p>See <a href="http://www.kanzaki.com/docs/sw/img-annotator.html">Image annotator</a> to describe your own image.</p>
     <xsl:call-template name="footer">
      <xsl:with-param name="cy">2003-2005</xsl:with-param>
      <xsl:with-param name="status">Status: XSLT created 2003-12-11; modified 2005-05-10. Some of presentation style is attributed to Greg Elin's <a href="http:/fotonotes.net/">Fotonotes</a>. Stylesheet copyleft under GPL.</xsl:with-param>
     </xsl:call-template>
    </div>
   </body>
  </html>
 </xsl:template>

 <!-- annotate points -->
 <xsl:template name="imgpoints">
  <xsl:choose>
   <xsl:when test="../../image:Rectangle|../../img:Rectangle">
    <xsl:variable name="tl"><xsl:value-of select="substring-before(.,' ')"/></xsl:variable>
    <xsl:variable name="br"><xsl:value-of select="substring-after(.,' ')"/></xsl:variable>
    <xsl:variable name="x0"><xsl:value-of select="substring-before($tl,',') * $imgfactor"/></xsl:variable>
    <xsl:variable name="y0"><xsl:value-of select="substring-after($tl,',') * $imgfactor"/></xsl:variable>
    <xsl:call-template name="genBox">
     <xsl:with-param name="x0" select="$x0"/>
     <xsl:with-param name="y0" select="$y0"/>
     <xsl:with-param name="w"><xsl:value-of select="substring-before($br,',') * $imgfactor - $x0"/></xsl:with-param>
     <xsl:with-param name="h"><xsl:value-of select="substring-after($br,',') * $imgfactor - $y0"/></xsl:with-param>
     <xsl:with-param name="type" select="'rect'"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:call-template name="minMax">
     <xsl:with-param name="pathstr" select="."/>
     <xsl:with-param name="loopcount" select="1"/>
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!-- polygon support 2004-01-21 -->
 <xsl:template name="minMax">
  <xsl:param name="pathstr"/>
  <xsl:param name="loopcount"/>
  <xsl:param name="xmin"/>
  <xsl:param name="ymin"/>
  <xsl:param name="xmax"/>
  <xsl:param name="ymax"/>
  <xsl:variable name="tl">
   <xsl:choose>
    <xsl:when test="contains($pathstr,' ')">
     <xsl:value-of select="substring-before($pathstr,' ')"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$pathstr"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="br"><xsl:value-of select="substring-after($pathstr,' ')"/></xsl:variable>
  <xsl:variable name="x"><xsl:value-of select="substring-before($tl,',')"/></xsl:variable>
  <xsl:variable name="y"><xsl:value-of select="substring-after($tl,',')"/></xsl:variable>

  <xsl:variable name="thisXmin">
   <xsl:choose>
    <xsl:when test="not($xmin)"><xsl:value-of select="$x"/></xsl:when>
    <xsl:when test="number($x) &lt; number($xmin)"><xsl:value-of select="$x"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$xmin"/></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="thisYmin">
   <xsl:choose>
    <xsl:when test="not($ymin)"><xsl:value-of select="$y"/></xsl:when>
    <xsl:when test="number($y) &lt; number($ymin)"><xsl:value-of select="$y"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$ymin"/></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="thisXmax">
   <xsl:choose>
    <xsl:when test="not($xmax)"><xsl:value-of select="$x"/></xsl:when>
    <xsl:when test="number($x) &gt; number($xmax)"><xsl:value-of select="$x"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$xmax"/></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="thisYmax">
   <xsl:choose>
    <xsl:when test="not($ymax)"><xsl:value-of select="$y"/></xsl:when>
    <xsl:when test="number($y) &gt; number($ymax)"><xsl:value-of select="$y"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$ymax"/></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
<!--
  <xsl:value-of select="concat($loopcount,'-',$thisXmin,',',$thisYmin,',',$thisXmax,',',$thisYmax,'; ')"/>
-->
  <xsl:choose>
   <xsl:when test="$loopcount &gt; 100">
   (more than 100 points ?)
   </xsl:when>
   <xsl:when test="contains($pathstr,' ')">
    <xsl:call-template name="minMax">
     <xsl:with-param name="pathstr" select="$br"/>
     <xsl:with-param name="loopcount" select="$loopcount + 1"/>
     <xsl:with-param name="xmin" select="$thisXmin"/>
     <xsl:with-param name="ymin" select="$thisYmin"/>
     <xsl:with-param name="xmax" select="$thisXmax"/>
     <xsl:with-param name="ymax" select="$thisYmax"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:variable name="x0" select="$thisXmin * $imgfactor"/>
    <xsl:variable name="y0" select="$thisYmin * $imgfactor"/>
    <xsl:call-template name="genBox">
     <xsl:with-param name="x0" select="$x0"/>
     <xsl:with-param name="y0" select="$y0"/>
     <xsl:with-param name="w"><xsl:value-of select="$thisXmax * $imgfactor - $x0"/></xsl:with-param>
     <xsl:with-param name="h"><xsl:value-of select="$thisYmax * $imgfactor - $y0"/></xsl:with-param>
     <xsl:with-param name="type" select="'norect'"/>
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="genBox">
  <xsl:param name="x0"/>
  <xsl:param name="y0"/>
  <xsl:param name="w"/>
  <xsl:param name="h"/>
  <xsl:param name="type"/>
  <xsl:variable name="xy1"><xsl:value-of select="concat('left:',$x0,'px;top:',$y0,'px;width:',$w,'px;height:',$h,'px')"/></xsl:variable>
  <xsl:variable name="xy2"><xsl:value-of select="concat('left:',($w div 2) - 7,'px;top:',($h div 2) - 7,'px')"/></xsl:variable>
  <xsl:variable name="xy3"><xsl:value-of select="concat('left:0;top:',$h+2,'px')"/></xsl:variable>
  <xsl:variable name="desc">
   <xsl:variable name="ds">
    <xsl:call-template name="concatelt">
     <xsl:with-param name="d" select="../dc:description"/>
     <xsl:with-param name="d2" select="../*//dc:description"/>
    </xsl:call-template>
   </xsl:variable>
   <xsl:choose>
    <xsl:when test="string-length($ds) &gt; $dmaxl">
     <xsl:value-of select="concat(substring($ds,1,$dmax),' ...')"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$ds"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="refid">
   <xsl:call-template name="getRefId">
    <xsl:with-param name="rdfid" select="../@rdf:ID"/>
   </xsl:call-template>
  </xsl:variable>
  <li><a href="#{$refid}" title="" class="box {$type}">
   <!-- style="{$xy}" dosen't work in Moz 1.2.1 -->
   <xsl:attribute name="style"><xsl:value-of select="$xy1"/></xsl:attribute>
   <span class="areanum"><xsl:attribute name="style"><xsl:value-of select="$xy2"/></xsl:attribute><xsl:value-of select="position()"/></span>
   <span class="descr"><xsl:attribute name="style"><xsl:value-of select="$xy3"/></xsl:attribute><xsl:value-of select="../dc:title"/>: <xsl:value-of select="$desc"/></span>
   <!-- dummy content for IE -->
   <img src="http://www.kanzaki.com/parts/tp.gif" alt="" style="width:{$w}px;height:{$h}px"/>
  </a></li>
 </xsl:template>


 <!-- if rdf:ID for the region presents, assign it as xhtml id  -->
 <xsl:template name="getRefId">
  <xsl:param name="rdfid"/>
  <xsl:choose>
   <xsl:when test="$rdfid != ''"><xsl:value-of select="$rdfid"/></xsl:when>
   <xsl:otherwise>_p<xsl:value-of select="position()"/></xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <!-- RSS items -->
 <xsl:template match="image:hasPart/*|img:hasRegion/*">
  <xsl:variable name="refid">
   <xsl:call-template name="getRefId">
    <xsl:with-param name="rdfid" select="@rdf:ID"/>
   </xsl:call-template>
  </xsl:variable>
  <h3 id="{$refid}">
   <xsl:choose>
    <xsl:when test="not(dc:title)">
     Region <xsl:value-of select="position()"/>
    </xsl:when>
    <xsl:when test="string-length(dc:title) &gt; 40">
     <xsl:value-of select="concat(substring(dc:title,1,40),' ...')"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="dc:title"/>
    </xsl:otherwise>
   </xsl:choose>
  </h3>
  <xsl:call-template name="genclip">
   <xsl:with-param name="coord" select="image:points|img:coords"/>
   <xsl:with-param name="src" select="../../@rdf:about"/>
  </xsl:call-template>
  <table border="1" cellspacing="0" cellpadding="5">
   <thead><tr><th class="property">Property</th><th class="value">Value</th></tr></thead>
   <tbody>
    <xsl:apply-templates select="*"/>
   </tbody>
  </table>
 </xsl:template>

 <xsl:template name="genclip">
  <xsl:param name="coord"/>
  <xsl:param name="src"/>
  <xsl:variable name="tl"><xsl:value-of select="substring-before($coord,' ')"/></xsl:variable>
  <xsl:variable name="br"><xsl:value-of select="substring-after($coord,' ')"/></xsl:variable>
  <xsl:variable name="x"><xsl:value-of select="substring-before($tl,',')"/></xsl:variable>
  <xsl:variable name="y"><xsl:value-of select="substring-after($tl,',')"/></xsl:variable>
  <xsl:variable name="x2"><xsl:value-of select="substring-before($br,',')"/></xsl:variable>
  <xsl:variable name="y2"><xsl:value-of select="substring-after($br,',')"/></xsl:variable>
  <xsl:variable name="h"><xsl:value-of select="$y2 - $y"/></xsl:variable>
  <xsl:variable name="w"><xsl:value-of select="$x2 - $x"/></xsl:variable>

  <div><xsl:attribute name="style"><xsl:value-of select="concat('height:',$h,'px;width:',$w,'px;overflow:hidden;margin-bottom:10px')"/></xsl:attribute>
   <img src="{$src}" alt=""><xsl:attribute name="style"><xsl:value-of select="concat('clip:rect(', $y, 'px, ', $x2, 'px, ', $y2, 'px, ', $x, 'px); ', 'margin-top:-', $y, 'px; margin-left:-', $x, 'px; ', 'position:absolute;')"/></xsl:attribute></img>
  </div>
 </xsl:template>

 <xsl:template name="imgdesc">
  <table id="i{position()}" border="1" cellspacing="0" cellpadding="5">
   <thead><tr><th class="property">Property</th><th class="value">Value</th></tr></thead>
   <tbody>
    <xsl:apply-templates select="*[(local-name() != 'hasPart' and local-name() != 'hasRegion' and name() != 'dc:description')]"/>
   </tbody>
  </table>
  <table border="1" cellspacing="0" cellpadding="5">
   <tbody><tr><td class="label">Exif analysis</td><td><a href="http://www.kanzaki.com/test/exif2rdf?xsl=on&amp;u={/rdf:RDF/foaf:Image/@rdf:about}">The Web KANZAKI Exif to RDF</a></td></tr></tbody>
  </table>
 </xsl:template>

 <xsl:template match="image:hasPart/*/*|img:hasRegion/*/*|foaf:Image/*[local-name() != 'hasPart' and local-name() != 'hasRegion' and name() != 'dc:description']|rdf:Description/*">
  <tr>
   <th><xsl:value-of select="name()"/></th>
   <td><xsl:call-template name="valOrRsrource"/></td>
  </tr>
 </xsl:template>

 <xsl:template match="image:hasPart/*/dc:*|image:hasPart/*/image:*|img:hasRegion/*/dc:*|img:hasRegion/*/img:*">
  <tr>
   <th><xsl:value-of select="local-name()"/></th>
   <td><xsl:call-template name="valOrRsrource"/></td>
  </tr>
 </xsl:template>

 <xsl:template match="*|@*">
  <dfn><xsl:value-of select="name()"/></dfn>: 
  <xsl:call-template name="propval"/>
 </xsl:template>

 <xsl:template match="rdf:*|dc:*|image:*|img:*|@rdf:*|@dc:*|@image:*|@img:*">
  <dfn><xsl:value-of select="local-name()"/></dfn>: 
  <xsl:call-template name="propval"/>
 </xsl:template>

<!--============  common set 1 for table =================-->
 <xsl:template match="@rdf:resource">
  <xsl:choose>
   <xsl:when test="starts-with(.,'#')">
    <xsl:variable name="ab" select="substring(.,2)"/>
    <xsl:for-each select="//*[@rdf:ID=$ab]">
     <xsl:call-template name="valOrRsrource"/>; 
    </xsl:for-each>
   </xsl:when>
   <xsl:otherwise>
    <xsl:call-template name="respoint"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="respoint">
  <xsl:variable name="ab" select="."/>
  <xsl:variable name="elt" select="name(../.)"/>
  <xsl:variable name="anode" select="//*[@rdf:about=$ab]"/>
  <xsl:choose>
   <xsl:when test="$elt='an:annotates'">
    <a href="{.}"><xsl:value-of select="."/></a>
   </xsl:when>
   <xsl:when test="$anode">
    <xsl:for-each select="$anode">
     <xsl:choose>
     <!-- test reffering to the same image -->
      <xsl:when test="local-name() = 'Image'"><a href="{@rdf:about}">image</a></xsl:when>
      <xsl:otherwise><xsl:call-template name="valOrRsrource"/>; </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
   </xsl:when>
   <xsl:otherwise>
    <a href="{.}">
     <xsl:choose>
      <xsl:when test="string-length(.) &gt; 60"><xsl:value-of select="substring(.,1,48)"/>...</xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
     </xsl:choose>
    </a>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="valOrRsrource">
  <xsl:choose>
   <xsl:when test="*">
    <xsl:apply-templates select="*"/>
   </xsl:when>
   <xsl:when test="@rdf:resource">
    <xsl:apply-templates select="@rdf:resource"/>
   </xsl:when>
   <xsl:when test="@rdf:nodeID[ancestor::image:hasPart]|@rdf:nodeID[ancestor::img:hasRegion]">
    <xsl:call-template name="collectnodeelts">
     <xsl:with-param name="nid"><xsl:value-of select="@rdf:nodeID"/></xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="."/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="propval">
  <xsl:choose>
   <xsl:when test="@rdf:nodeID[ancestor::image:hasPart]|@rdf:nodeID[ancestor::img:hasRegion]">
    <span class="f">(<xsl:call-template name="collectnodes">
     <xsl:with-param name="nid"><xsl:value-of select="@rdf:nodeID"/></xsl:with-param>
    </xsl:call-template>)</span>
   </xsl:when>
   <xsl:when test="@rdf:about[ancestor::image:hasPart]|@rdf:about[ancestor::img:hasRegion]">
    <span class="f">(<xsl:call-template name="collectresourse">
     <xsl:with-param name="ab"><xsl:value-of select="@rdf:about"/></xsl:with-param>
    </xsl:call-template>)</span>
   </xsl:when>
   <xsl:when test="@*|*">
    <span class="f">(<xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="*"/>); </span>
   </xsl:when>
   <xsl:otherwise>
    <xsl:call-template name="valOrRsrource"/>; 
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="collectnodes">
  <xsl:param name="nid"/>
  <!--<dfn>nodeID</dfn>:<xsl:value-of select="$nid"/>; -->
  <xsl:for-each select="//*[@rdf:nodeID=$nid]">
   <xsl:call-template name="valOrRsrource"/>; 
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="collectnodeelts">
  <xsl:param name="nid"/>
  <!--<dfn>nodeID</dfn>:<xsl:value-of select="$nid"/>; -->
  <xsl:for-each select="//*[@rdf:nodeID=$nid]">
   <xsl:if test="*">
    <xsl:call-template name="propval"/>; 
   </xsl:if>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="collectresourse">
  <xsl:param name="ab"/>
  <!--<dfn>about</dfn>:<xsl:value-of select="$ab"/>; -->
  <xsl:variable name="anode" select="//*[@rdf:about=$ab]"/>
  <xsl:choose>
   <xsl:when test="count($anode) &gt; 1">
    <xsl:for-each select="$anode">
     <xsl:call-template name="valOrRsrource"/>; 
    </xsl:for-each>
   </xsl:when>
   <xsl:when test="starts-with($ab,'http:')">
    about: <a href="{$ab}"><xsl:value-of select="$ab"/></a>; 
   </xsl:when>
   <xsl:otherwise>
    <dfn>about</dfn>: <xsl:value-of select="$ab"/>; 
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="concatelt">
  <xsl:param name="d"/>
  <xsl:param name="d2"/>
  <xsl:for-each select="$d">
<xsl:value-of select="."/><!--<xsl:text> </xsl:text>-->
  </xsl:for-each>
  <xsl:for-each select="$d2">
   (<!--<xsl:if test="not(../@rdf:parseType)"><xsl:value-of select="local-name(..)"/>: </xsl:if>--><xsl:value-of select="."/>)<!--<xsl:text> </xsl:text>-->
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="foaf:mbox_sha1sum">
  <dfn><xsl:value-of select="local-name()"/></dfn>: 
  <acronym title="{.}"><xsl:value-of select="substring(.,1,6)"/>...</acronym> ; 
 </xsl:template>

 <xsl:template match="@rdf:nodeID">
 </xsl:template>

 <xsl:template match="@rdf:parseType">
 </xsl:template>


<!--============ end of common set 1 ============-->


 <xsl:template match="foaf:Image/dc:description">
  <p id="intro"><xsl:value-of select="."/></p>
 </xsl:template>

 <xsl:template match="rdf:RDF/rdf:Description">
  <h2>About this annotation</h2>
  <table id="annot" border="1" cellspacing="0" cellpadding="5">
   <thead><tr><th class="property">Property</th><th class="value">Value</th></tr></thead>
   <tbody>
    <xsl:apply-templates select="*"/>
   </tbody>
  </table>
 </xsl:template>

 <!-- XHTML head elements -->
 <xsl:template name="htmlhead">
  <link rel="stylesheet" href="kan01.css" type="text/css" />
  <link rel="stylesheet" href="imgdesc.css" type="text/css" />
  <style type="text/css">.f .f .f{font-size:small}</style>
<script type="text/javascript" src="imgdesc.js">//</script>
 </xsl:template>

 <xsl:include href="./banner-footer.xsl"/>

</xsl:stylesheet>
