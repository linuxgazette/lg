<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:variable name="fontSize">6</xsl:variable>
	<xsl:variable name="lineSpace">6</xsl:variable>
	<xsl:variable name="minLength">80</xsl:variable>
	<xsl:variable name="maxLength">100</xsl:variable>
	<xsl:variable name="sliceLength">20</xsl:variable>
	<xsl:template name="lineSplit">
		<xsl:param name="content"/>
		<xsl:param name="blockOffset"/>
		<xsl:param name="lineCount"/>
		<xsl:variable name="contentLength" select="string-length($content)"/>
		<xsl:variable name="start" select="substring($content,1, $minLength)"/>
		<xsl:variable name="slice" select="substring($content,$minLength+1, $sliceLength)"/>
		<xsl:variable name="end" select="substring($content,$maxLength+1)"/>
		<xsl:variable name="preSpace" select="substring-before($slice,' ')"/>
		<xsl:variable name="postSpace" select="substring-after($slice,' ')"/>
		<text y="{$blockOffset+$lineSpace*$lineCount}" font-size="{$fontSize}">
			<xsl:choose>
				<xsl:when test="contains($slice, ' ')">
					<xsl:value-of select="concat($start, $preSpace)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($start, $slice)"/>
				</xsl:otherwise>
			</xsl:choose>
		</text>
		<xsl:variable name="remainder" select="concat($postSpace,$end)"/>
		<xsl:choose>
			<xsl:when test="string-length($remainder)>$maxLength+1">
				<xsl:call-template name="lineSplit">
					<xsl:with-param name="content" select="$remainder"/>
					<xsl:with-param name="lineCount" select="$lineCount+1"/>
					<xsl:with-param name="blockOffset" select="$blockOffset"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<text y="{$blockOffset+$lineSpace*$lineCount+$lineSpace}" font-size="{$fontSize}">
					<xsl:value-of select="$remainder"/>
				</text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
