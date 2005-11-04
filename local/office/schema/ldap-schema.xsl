<?xml version="1.0" encoding="utf-8" standalone="yes" ?>

<!-- ****************************************************************************************** -->
<!-- * Transformation of schema description into configuration instance format to XML		*** -->
<!-- ****************************************************************************************** -->
<xsl:transform  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"
				xmlns:schema="http://openoffice.org/2000/registry/schema/description"
				xmlns:default="http://openoffice.org/2000/registry/schema/default"
				xmlns:cfg="http://openoffice.org/2000/registry/instance">

<!-- Get the correct format -->
<xsl:output indent="no" method="text"/>
<xsl:param name = "attribID">
	<xsl:value-of select="/schema:component/@schema:ooOID"/><xsl:text>.</xsl:text><xsl:value-of select="/schema:component/schema:types/@schema:component-id"/><xsl:text>.1</xsl:text>
</xsl:param>

<xsl:param name = "classID">
	<xsl:value-of select="/schema:component/@schema:ooOID"/><xsl:text>.</xsl:text><xsl:value-of select="/schema:component/schema:types/@schema:component-id"/><xsl:text>.2</xsl:text>
</xsl:param>

<!-- Transformation into data and template files -->

<!-- ****************************** -->
<!-- * elements not transfomed	*** -->
<!-- ****************************** -->
    <xsl:template match="schema:documentation|schema:type-info|default:data|schema:schema|schema:templates"/>		

<!-- ****************************** -->
<!-- * schema:value				*** -->
<!-- ****************************** -->
	<xsl:template match="schema:value">
		<xsl:if test = " not(@schema:external) or (@schema:external = 'false')">
			<xsl:text>&#xA;attribute </xsl:text><xsl:value-of select="@cfg:name"/><xsl:text> </xsl:text><xsl:value-of select="$attribID"/>.<xsl:value-of select="/schema:component/schema:types/@schema:component-id"/><xsl:text>.</xsl:text><xsl:value-of select="@schema:type-id"/><xsl:text> </xsl:text>cis<xsl:if test =" not(@cfg:derivedBy = 'list')"><xsl:text> single</xsl:text></xsl:if><xsl:text/>
		</xsl:if>
	</xsl:template>	

<!-- ****************************** -->
<!-- * schema:class				*** -->
<!-- ****************************** -->
	<xsl:template match="schema:class">
		<xsl:if test = " not(@schema:external) or (@schema:external = 'false')">
			<xsl:text>&#xA;objectclass </xsl:text><xsl:value-of select="@cfg:name"/> 
			<xsl:text>    oid </xsl:text><xsl:value-of select="$classID"/><xsl:text>.</xsl:text><xsl:value-of select="/schema:component/schema:types/@schema:component-id"/><xsl:text>.</xsl:text><xsl:value-of select="@schema:type-id"/>		
			<xsl:text>&#xA;&#x9;superior </xsl:text><xsl:choose><xsl:when test = "schema:extension"><xsl:value-of select="schema:extension/@schema:base"/></xsl:when><xsl:otherwise>oocfgGroup</xsl:otherwise></xsl:choose>		
			<xsl:if test = "count(schema:member[@cfg:nullable='false']) > 0">
			<xsl:text>&#xA;&#x9;requires </xsl:text>         
			<xsl:for-each select="schema:member[@cfg:nullable='false']">
				<xsl:value-of select="@schema:ref"/><xsl:text>,</xsl:text>
			</xsl:for-each>
			</xsl:if>
			<xsl:if test = "count(schema:member[@cfg:nullable='true' or not (@cfg:nullable)]) > 0">
				<xsl:text>&#xA;&#x9;allows </xsl:text>
				<xsl:for-each select="schema:member[@cfg:nullable='true' or not (@cfg:nullable)]">
					<xsl:text>&#xa;&#x9;&#x9;</xsl:text><xsl:value-of select="@schema:ref"/><xsl:text>,</xsl:text>
				</xsl:for-each>		
			</xsl:if>		
		</xsl:if>		
	</xsl:template>	

</xsl:transform>

