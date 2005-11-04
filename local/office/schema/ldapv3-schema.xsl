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

<xsl:preserve-space elements="schema:description"/> 

<!-- Transformation into data and template files -->

<!-- ****************************** -->
<!-- * elements not transfomed	*** -->
<!-- ****************************** -->
    <xsl:template match="schema:description|schema:type-info|default:data|schema:schema|schema:templates|schema:import|schema:uses"/>		

<!-- ****************************** -->
<!-- * schema:value				*** -->
<!-- ****************************** -->
	<xsl:template match="schema:value">
		<xsl:if test = " not(@schema:external) or (@schema:external = 'false')">
			<xsl:text>&#xA;dn: cn=schema</xsl:text>
			<xsl:text>&#xA;attributetypes: (</xsl:text><xsl:value-of select="$attribID"/>.<xsl:value-of select="/schema:component/schema:types/@schema:component-id"/><xsl:text>.</xsl:text><xsl:value-of select="@schema:type-id"/><xsl:text> NAME '</xsl:text><xsl:value-of select="@cfg:name"/><xsl:text>' </xsl:text>			
			<xsl:text>DESC '</xsl:text><xsl:value-of select="schema:documentation/schema:description"/><xsl:text>' </xsl:text>
			<!-- type selection -->
			<xsl:text> SYNTAX </xsl:text>
			<xsl:choose>
				<!-- integer syntax -->
				<xsl:when test="@cfg:type='int' or @cfg:type='short'"><xsl:text>1.3.6.1.4.1.1466.115.121.1.27</xsl:text></xsl:when>
				<!-- boolean syntax -->
				<xsl:when test="@cfg:type='boolean'"><xsl:text>1.3.6.1.4.1.1466.115.121.1.7</xsl:text></xsl:when>
				<!-- numeric string syntax not support for all servers -->
				<!-- <xsl:when test="@cfg:type='double' or @cfg:type='long'"><xsl:text>1.3.6.1.4.1.1466.115.121.1.36</xsl:text></xsl:when> -->
				<!-- otherwise case ignore string syntax -->
				<xsl:otherwise><xsl:text>1.3.6.1.4.1.1466.115.121.1.15</xsl:text></xsl:otherwise>
			</xsl:choose>			
			<xsl:if test =" not(@cfg:derivedBy = 'list')"><xsl:text> SINGLE-VALUE </xsl:text></xsl:if>
			<xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>	

<!-- ****************************** -->
<!-- * schema:class				*** -->
<!-- ****************************** -->
	<xsl:template match="schema:class">
		<xsl:if test = " not(@schema:external) or (@schema:external = 'false')">
			<xsl:text>&#xA;dn: cn=schema</xsl:text>
			<xsl:text>&#xA;objectclasses: (</xsl:text><xsl:value-of select="$classID"/><xsl:text>.</xsl:text><xsl:value-of select="/schema:component/schema:types/@schema:component-id"/><xsl:text>.</xsl:text><xsl:value-of select="@schema:type-id"/>
			<xsl:text> NAME '</xsl:text><xsl:value-of select="@cfg:name"/><xsl:text>' </xsl:text>
			<xsl:text> DESC '</xsl:text><xsl:value-of select="schema:documentation/schema:description"/><xsl:text>' </xsl:text>
			<xsl:text> SUP '</xsl:text><xsl:choose><xsl:when test = "schema:extension"><xsl:value-of select="schema:extension/@schema:base"/></xsl:when><xsl:otherwise>oocfgGroup</xsl:otherwise></xsl:choose><xsl:text>'</xsl:text>
			<xsl:if test = "count(schema:member[@cfg:nullable='false']) > 0">
				<xsl:text> MUST (</xsl:text>         
				<xsl:for-each select="schema:member[@cfg:nullable='false']">
					<xsl:value-of select="@schema:ref"/><xsl:text> $ </xsl:text>
				</xsl:for-each>
				<xsl:text>)</xsl:text>         
			</xsl:if>
			<xsl:if test = "count(schema:member[@cfg:nullable='true' or not (@cfg:nullable)]) > 0">
				<xsl:text> MAY (</xsl:text>
				<xsl:for-each select="schema:member[@cfg:nullable='true' or not (@cfg:nullable)]">
					<xsl:value-of select="@schema:ref"/><xsl:text> $ </xsl:text>
				</xsl:for-each>		
				<xsl:text>)</xsl:text>         
			</xsl:if>		
			<xsl:text>)</xsl:text>
		</xsl:if>		
	</xsl:template>	

</xsl:transform>

