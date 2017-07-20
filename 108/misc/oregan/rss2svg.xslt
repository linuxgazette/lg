<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rss="http://purl.org/rss/1.0/" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:import href="line-split.xslt"/>
	<xsl:output method="xml" indent="yes"/>
	<!-- doctype-public="-//W3C//DTD SVG 1.0//EN" doctype-system="http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd"/ -->
	<xsl:template match="/">
		<svg width="100%" height="100%">
			<xsl:apply-templates/>
		</svg>
	</xsl:template>
	<xsl:template match="rss/channel | rdf:RDF">
		<xsl:for-each select="item | rss:item">
			<xsl:sort select="position()" order="descending"/>
			<xsl:call-template name="itemBox">
				<xsl:with-param name="itemPosition" select="position()"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="itemBox">
		<xsl:param name="itemPosition"/>
		<xsl:variable name="raw" select="description | rss:description"/>
		<xsl:variable name="itemCount" select="count(../item | ../rss:item)"/>
		<xsl:variable name="scaleFactor" select="2*$itemPosition div $itemCount "/>
		<g>
			<xsl:attribute name="transform">scale(<xsl:value-of select="$scaleFactor"/>)</xsl:attribute>
			<g>
				<xsl:attribute name="transform">translate(<xsl:value-of select="10*$itemPosition"/>,<xsl:value-of select="20*$itemPosition"/>)</xsl:attribute>
				<a xlink:href="{link|rss:link}">
					<rect width="280" height="70" fill="white" stroke="green" stroke-width="2"/>
					<g>
						<xsl:attribute name="transform">translate(10,0)</xsl:attribute>
						<xsl:call-template name="lineSplit">
							<xsl:with-param name="content" select="normalize-space($raw)"/>
							<xsl:with-param name="blockOffset" select="20"/>
							<xsl:with-param name="lineCount" select="0"/>
						</xsl:call-template>
						<text x="10" y="10" fill="red" font-size="8">
							<xsl:value-of select="title | rss:title"/>
						</text>
					</g>
				</a>
			</g>
		</g>
	</xsl:template>
	<xsl:template match="text()"/>
</xsl:stylesheet>
