<?xml version="1.0"?>
<!--
	feed-normaliser 0.1 - XSLT for cleaning link feeds.
	
	This XSLT fixes various generic feed types to make sure item and channel URIs
	are globally unique and meaningful, (currently) with support for the
	following:
	* del.icio.us, e.g. http://del.icio.us/rss/mortenf

	Copyright (c) 2003-2004 Morten Frederiksen
	License: http://www.gnu.org/licenses/gpl
-->
<!DOCTYPE rdf:RDF [
	<!ENTITY rdf 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'>
	<!ENTITY rss 'http://purl.org/rss/1.0/'>
	<!ENTITY dc 'http://purl.org/dc/elements/1.1/'>
	<!ENTITY dcterms 'http://purl.org/dc/terms/'>
	<!ENTITY foaf 'http://xmlns.com/foaf/0.1/'>
	<!ENTITY taxo 'http://purl.org/rss/1.0/modules/taxonomy/'>
]>
<xsl:transform
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="&rdf;"
	xmlns="&rss;"
	xmlns:rss="&rss;"
	xmlns:dc="&dc;"
	xmlns:dcterms="&dcterms;"
	xmlns:foaf="&foaf;"
	xmlns:taxo="&taxo;"
	version="1.0">
<xsl:output
	method="xml"
	indent="yes"
	omit-xml-declaration="no"
	encoding="utf-8"/>

<xsl:param name="uri" select="''"/>

<!-- Root element... -->
<xsl:template match="/">
	<xsl:apply-templates select="rdf:RDF"/>
</xsl:template>
<xsl:template match="/rdf:RDF">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates mode="subject" select="*"/>
	</xsl:copy>
</xsl:template>

<!--
	del.icio.us templates...
-->

<!-- Handle item list property nodes. -->
<xsl:template mode="property" priority="0.2" match="rdf:li[starts-with(../../../@rdf:about,'http://del.icio.us/')]">
	<xsl:variable name="this" select="@rdf:resource"/>
	<rdf:li>
		<xsl:attribute name="rdf:resource">
			<xsl:text>http://del.icio.us/</xsl:text>
			<xsl:value-of select="/*/rss:item[@rdf:about=$this]/dc:creator"/>
			<xsl:text>?url=</xsl:text>
			<xsl:call-template name="uri-escape">
				<xsl:with-param name="uri" select="@rdf:resource"/>
			</xsl:call-template>
		</xsl:attribute>
	</rdf:li>
</xsl:template>

<!-- Handle item subject nodes. -->
<xsl:template mode="subject" priority="0.2" match="rss:item[starts-with(../rss:channel/@rdf:about,'http://del.icio.us/')]">
	<item>
		<xsl:attribute name="rdf:about">
			<xsl:text>http://del.icio.us/</xsl:text>
			<xsl:value-of select="dc:creator"/>
			<xsl:text>?url=</xsl:text>
			<xsl:call-template name="uri-escape">
				<xsl:with-param name="uri" select="@rdf:about"/>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:apply-templates mode="properties" select="."/>
		<dcterms:references rdf:resource="{normalize-space(rss:link)}"/>
	</item>
</xsl:template>

<!-- Extend dc:creator to foaf:maker. -->
<xsl:template mode="property" priority="0.2" match="dc:creator[starts-with(../../rss:channel/@rdf:about,'http://del.icio.us/')]">
	<xsl:copy-of select="."/>
	<foaf:maker>
		<foaf:Person>
			<foaf:holdsAccount>
				<foaf:OnlineAccount>
					<foaf:name>
						<xsl:text>del.icio.us/</xsl:text>
						<xsl:value-of select="."/>
					</foaf:name>
					<foaf:accountServiceHomepage rdf:resource="http://del.icio.us/"/>
					<foaf:accountName>
						<xsl:value-of select="."/>
					</foaf:accountName>
				</foaf:OnlineAccount>
			</foaf:holdsAccount>
		</foaf:Person>
	</foaf:maker>
</xsl:template>

<!-- Copy rss:title to empty rss:description. -->
<xsl:template mode="property" priority="0.2" match="rss:description[.='' and starts-with(../../rss:channel/@rdf:about,'http://del.icio.us/')]">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:value-of select="../rss:title"/>
	</xsl:copy>
</xsl:template>

<!-- Split dc:subject keywords into dc:subject concepts for SKOS mappings. -->
<xsl:template mode="property" priority="0.2" match="dc:subject[starts-with(../../rss:channel/@rdf:about,'http://del.icio.us/')]">
	<xsl:call-template name="del.icio.us-subject">
		<xsl:with-param name="keywords" select="normalize-space(.)"/>
	</xsl:call-template>
</xsl:template>
<xsl:template name="del.icio.us-subject">
	<xsl:param name="keywords" select="''"/>
	<xsl:choose>
		<xsl:when test="contains($keywords,' ')">
			<xsl:call-template name="del.icio.us-subject">
				<xsl:with-param name="keywords" select="substring-before($keywords,' ')"/>
			</xsl:call-template>
			<xsl:call-template name="del.icio.us-subject">
				<xsl:with-param name="keywords" select="substring-after($keywords,' ')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<dc:subject>
				<xsl:attribute name="rdf:resource">
					<xsl:text>http://del.icio.us/</xsl:text>
					<xsl:value-of select="../dc:creator"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="$keywords"/>
					<xsl:text>#concept</xsl:text>
				</xsl:attribute>
			</dc:subject>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Fix invalid taxo:topics list items. -->
<xsl:template mode="property" priority="0.2" match="taxo:topics[starts-with(../../rss:channel/@rdf:about,'http://del.icio.us/')]/rdf:Bag/rdf:li">
	<rdf:li rdf:resource="{@*[local-name()='resource']}"/>
</xsl:template>

<!--
	End of del.icio.us templates...
-->

<!--
	The following default templates should not be changed.
-->

<!-- Default rss:channel node template. -->
<xsl:template mode="subject" priority="0.2" match="rss:channel">
	<channel>
		<xsl:attribute name="rdf:about">
			<xsl:value-of select="$uri"/>
		</xsl:attribute>
		<xsl:copy-of select="@*[namespace-uri()!='&rdf;' or local-name()!='about']"/>
		<xsl:apply-templates mode="properties" select="."/>
	</channel>
</xsl:template>

<!-- Default subject node template. -->
<xsl:template mode="subject" priority="0.1" match="*">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates mode="properties" select="."/>
	</xsl:copy>
</xsl:template>

<!-- Properties for a node element. -->
<xsl:template mode="properties" priority="0.1" match="*">
	<xsl:apply-templates mode="property" select="*[not(@rdf:parseType='Resource')]"/>
	<xsl:for-each select="*[@rdf:parseType='Resource']">
		<xsl:copy>
			<rdf:Description>
				<xsl:copy-of select="@*[namespace-uri()!='&rdf;' or local-name()!='parseType']"/>
				<xsl:apply-templates mode="properties" select="."/>
			</rdf:Description>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>

<!-- Default property node template. -->
<xsl:template mode="property" priority="0.1" match="*">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:choose>
			<xsl:when test="*">
				<xsl:apply-templates mode="subject" select="*"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="subject" select="text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:copy>
</xsl:template>

<!--
	Templates for URI escaping.
-->

<xsl:template name="uri-escape">
	<xsl:param name="uri" select="''"/>
	<xsl:call-template name="ampify">
		<xsl:with-param name="text">
			<xsl:call-template name="hashify">
				<xsl:with-param name="text">
					<xsl:call-template name="plusify">
						<xsl:with-param name="text">
							<xsl:value-of select="$uri"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="ampify">
	<xsl:param name="text" select="''"/>
	<xsl:choose>
		<xsl:when test="contains($text,'&amp;')">
			<xsl:value-of select="substring-before($text,'&amp;')"/>
			<xsl:value-of select="'%26'"/>
			<xsl:call-template name="ampify">
				<xsl:with-param name="text" select="substring-after($text,'&amp;')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$text"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="hashify">
	<xsl:param name="text" select="''"/>
	<xsl:choose>
		<xsl:when test="contains($text,'#')">
			<xsl:value-of select="substring-before($text,'#')"/>
			<xsl:value-of select="'%23'"/>
			<xsl:call-template name="hashify">
				<xsl:with-param name="text" select="substring-after($text,'#')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$text"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="plusify">
	<xsl:param name="text" select="''"/>
	<xsl:choose>
		<xsl:when test="contains($text,'+')">
			<xsl:value-of select="substring-before($text,'+')"/>
			<xsl:value-of select="'%2B'"/>
			<xsl:call-template name="plusify">
				<xsl:with-param name="text" select="substring-after($text,'+')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$text"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:transform>
