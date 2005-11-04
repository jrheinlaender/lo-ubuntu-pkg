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
<xsl:output method="text" indent="false" omit-xml-declaration="yes" encoding="utf-8"/>

<!-- Root for the LDAP Tree -->
<xsl:param name="OfficeRoot">dc=Sun.COM</xsl:param>
<xsl:param name="System">ou=Instance,<xsl:value-of select="$OfficeRoot"/></xsl:param>
<xsl:param name="Template">ou=Template,<xsl:value-of select="$OfficeRoot"/></xsl:param>
<xsl:param name="path">.</xsl:param>
<xsl:param name="pathSeparator">;</xsl:param>

<!-- ****************************** -->
<!-- * elements not transfomed	*** -->
<!-- ****************************** -->
    <xsl:template match="schema:documentation|schema:type-info|default:data"/>

<!-- ****************************** -->
<!-- * createLDAPComponentName	*** -->
<!-- ****************************** -->
    <xsl:template name="createLDAPComponentName">		
		<xsl:param name="componentName"/>
		<xsl:choose>
			<xsl:when test="contains($componentName, 'org.openoffice')">
				<xsl:text>oo</xsl:text><xsl:value-of select="substring-after($componentName, 'org.openoffice')"/>					
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$componentName"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

<!-- ****************************** -->
<!-- * createComponent			*** -->
<!-- ****************************** -->
    <xsl:template name="createComponent">
		<xsl:param name="Root"/>
		<xsl:param name="ldapName"/>		
		<xsl:text>&#xA;dn: cn=</xsl:text><xsl:value-of select="$ldapName"/>,<xsl:value-of select="$Root"/>
		<xsl:text>&#xA;cn: </xsl:text><xsl:value-of select="$ldapName"/>
		<xsl:text>&#xA;objectclass: top</xsl:text>
		<xsl:text>&#xA;objectclass: oocfgGroup</xsl:text>
	</xsl:template>

<!-- ****************************** -->
<!-- * createGroup				*** -->
<!-- ****************************** -->
    <xsl:template name="createGroup">
		<xsl:param name="Root"/>	
		<xsl:param name="elementName"/>
		<xsl:variable name="className"><xsl:call-template name="getClassName"/></xsl:variable>
		<xsl:variable name="componentName"><xsl:call-template name="getClassComponentName"/></xsl:variable>
		
		<xsl:text>&#xA;dn: cn=</xsl:text><xsl:value-of select="$elementName"/><xsl:text>,</xsl:text><xsl:value-of select="$Root"/>
		<xsl:text>&#xA;cn: </xsl:text><xsl:value-of select="$elementName"/>
		<xsl:text>&#xA;objectclass: top</xsl:text>
		<xsl:text>&#xA;objectclass: oocfgGroup</xsl:text>		
		<xsl:if test="string-length($className)">
			<xsl:call-template name="classSelection">
				<xsl:with-param name="componentName" select="$componentName"/>
				<xsl:with-param name="className" select="$className"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="attributeResolution"/>

		<!-- Print out the default attributes -->
		<xsl:for-each select="default:value/default:data">
			<xsl:variable name="isList">
				<xsl:call-template name="isListValue"/>
			</xsl:variable>
			<xsl:call-template name="valueResolution">
				<xsl:with-param name="isList" select="$isList"/>
			</xsl:call-template>
		</xsl:for-each>	
		<!-- Print out the default attributes -->
	</xsl:template>

<!-- ****************************** -->
<!-- * createSet				*** -->
<!-- ****************************** -->
    <xsl:template name="createSet">
		<xsl:param name="Root"/>
		<xsl:param name="elementName"/>
		<xsl:variable name="ldapName">			
			<xsl:choose>
				<xsl:when test="@cfg:component">
					<xsl:call-template name="createLDAPComponentName">				
						<xsl:with-param name="componentName"><xsl:value-of select="@cfg:component"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when> 
				<xsl:otherwise>
					<xsl:call-template name="createLDAPComponentName">				
						<xsl:with-param name="componentName"><xsl:value-of select="/schema:component/@cfg:package"/>.<xsl:value-of select="/schema:component/@cfg:name"/></xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose> 			
		</xsl:variable>						
		<xsl:text>&#xA;dn: cn=</xsl:text><xsl:value-of select="$elementName"/>,<xsl:value-of select="$Root"/>
		<xsl:text>&#xA;cn: </xsl:text><xsl:value-of select="$elementName"/>
		<xsl:text>&#xA;objectclass: top</xsl:text>
		<xsl:choose>
			<xsl:when test="@cfg:template-ref = 'any'">
				<xsl:text>&#xA;objectclass: oocfgItemSet</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#xA;objectclass: oocfgSet</xsl:text>
				<xsl:text>&#xA;oocfgTemplate: </xsl:text><xsl:value-of select="@cfg:template-ref"/>
				<xsl:text>&#xA;oocfgTemplateDn: cn=</xsl:text><xsl:value-of select="$ldapName"/>,<xsl:value-of select="$Template"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="attributeResolution"/>
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:component			*** -->
<!-- ****************************** -->
	<xsl:template match="/schema:component">
		<xsl:apply-templates select="schema:templates"/>
		<xsl:apply-templates select="schema:schema"/>
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:schema			*** -->
<!-- ****************************** -->
	<xsl:template match="schema:schema">
        <xsl:variable name="ldapName">			
			<xsl:call-template name="createLDAPComponentName">									
				<xsl:with-param name="componentName"><xsl:value-of select="../@cfg:package"/>.<xsl:value-of select="../@cfg:name"/></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>			

<!-- ****************************** -->		
		<xsl:text>&#xA;dn: ou=Instance,</xsl:text><xsl:value-of select="$OfficeRoot"/>
		<xsl:text>&#xA;ou: Instance</xsl:text>
		<xsl:text>&#xA;objectclass: top</xsl:text>
		<xsl:text>&#xA;objectclass: organizationalUnit&#xA;</xsl:text>
<!-- ****************************** -->		
					
		<xsl:call-template name="createComponent">
			<xsl:with-param name="Root"><xsl:value-of select="$System"/></xsl:with-param>
			<xsl:with-param name="ldapName"><xsl:value-of select="$ldapName"/></xsl:with-param>
		</xsl:call-template>										
		<xsl:apply-templates>
			<xsl:with-param name="Root"><xsl:text>cn=</xsl:text><xsl:value-of select="$ldapName"/><xsl:text>,</xsl:text><xsl:value-of select="$System"/></xsl:with-param>
		</xsl:apply-templates>		
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:templates			*** -->
<!-- ****************************** -->
	<xsl:template match="schema:templates">
        <xsl:variable name="ldapName">			
			<xsl:call-template name="createLDAPComponentName">									
				<xsl:with-param name="componentName"><xsl:value-of select="../@cfg:package"/>.<xsl:value-of select="../@cfg:name"/></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>						
<!-- ****************************** -->		
		<xsl:text>&#xA;dn: ou=Template,</xsl:text><xsl:value-of select="$OfficeRoot"/>
		<xsl:text>&#xA;ou: Template</xsl:text>
		<xsl:text>&#xA;objectclass: top</xsl:text>
		<xsl:text>&#xA;objectclass: organizationalUnit&#xA;</xsl:text>
<!-- ****************************** -->		
		<xsl:call-template name="createComponent">
			<xsl:with-param name="Root"><xsl:value-of select="$Template"/></xsl:with-param>
			<xsl:with-param name="ldapName"><xsl:value-of select="$ldapName"/></xsl:with-param>
		</xsl:call-template>										
		<xsl:apply-templates>
			<xsl:with-param name="Root"><xsl:text>cn=</xsl:text><xsl:value-of select="$ldapName"/><xsl:text>,</xsl:text><xsl:value-of select="$Template"/></xsl:with-param>
		</xsl:apply-templates>		
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:set|default:set	*** -->
<!-- ****************************** -->
	<xsl:template match="schema:set|default:set">
        <xsl:param name="Root"/>
		<xsl:call-template name="createSet">
			<xsl:with-param name="Root"><xsl:value-of select="$Root"/></xsl:with-param>
			<xsl:with-param name="elementName"><xsl:value-of select="@cfg:name"/></xsl:with-param>
		</xsl:call-template>						
        <xsl:apply-templates>
			<xsl:with-param name="Root">cn=<xsl:value-of select="@cfg:name"/>,<xsl:value-of select="$Root"/></xsl:with-param>			
		</xsl:apply-templates>		
	</xsl:template>	

<!-- ****************************** -->
<!-- *schema:group|default:group*** -->
<!-- ****************************** -->
	<xsl:template match="schema:group|default:group">
        <xsl:param name="Root"/>
		<xsl:call-template name="createGroup">
			<xsl:with-param name="Root"><xsl:value-of select="$Root"/></xsl:with-param>	
			<xsl:with-param name="elementName" select="@cfg:name"/>
		</xsl:call-template>						
        <xsl:apply-templates>
			<xsl:with-param name="Root"><xsl:text>cn=</xsl:text><xsl:value-of select="@cfg:name"/>,<xsl:value-of select="$Root"/></xsl:with-param>
		</xsl:apply-templates>		
	</xsl:template>

<!-- ****************************** -->
<!-- * default:item				*** -->
<!-- ****************************** -->
	<xsl:template match="default:item">
        <xsl:param name="Root"/>
		<xsl:variable name="isList" select="@cfg:derivedBy"/>

		<xsl:text>&#xA;dn: cn=</xsl:text><xsl:value-of select="@cfg:name"/><xsl:text>,</xsl:text><xsl:value-of select="$Root"/>
		<xsl:text>&#xA;cn: </xsl:text><xsl:value-of select="@cfg:name"/>
		<xsl:text>&#xA;objectclass: top</xsl:text>		
		<xsl:text>&#xA;objectclass: oocfgItem</xsl:text>				
		
		<xsl:call-template name="attributeResolution"/>
		
		<xsl:if	test="@cfg:type">
			<xsl:text>&#xA;oocfgItemType: </xsl:text><xsl:value-of select="@cfg:type"/>
		</xsl:if>        
		<xsl:if	test="$isList = 'list'">
			<xsl:text>&#xA;oocfgItemList: true</xsl:text>
		</xsl:if>

		<!-- Print out the default attributes -->
		<xsl:for-each select="default:data">
			<xsl:call-template name="valueResolution">
				<xsl:with-param name="name">oocfgItemValue</xsl:with-param>
				<xsl:with-param name="isList" select="$isList"/>
			</xsl:call-template>
		</xsl:for-each>	
	</xsl:template>

<!-- ****************************** -->
<!-- * valueResolution			*** -->
<!-- ****************************** -->
	<xsl:template name="valueResolution">		
		<xsl:param name="name" select="../@schema:ref"/>
		<xsl:param name="isList"/>
		<xsl:choose>					
			<xsl:when test="$isList='list'">
				<xsl:variable name="defaultSeparator" xml:space="preserve"> </xsl:variable>			
				<xsl:call-template name="stripListElements">
					<xsl:with-param name="separator">
						<xsl:choose>
							<xsl:when test="../@cfg:separator">
								<xsl:value-of select="../@cfg:separator"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$defaultSeparator"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="list"><xsl:value-of select="."/></xsl:with-param>
					<xsl:with-param name="name"><xsl:value-of select="$name"/></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="printValue">
					<xsl:with-param name="name"><xsl:value-of select="$name"/></xsl:with-param>
					<xsl:with-param name="value" select="."/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>			
	</xsl:template>

<!-- ****************************** -->
<!-- * stripListElements		*** -->
<!-- ****************************** -->
<xsl:template name="stripListElements">
	<!-- using the ' ' as default separator -->		
	<xsl:param name="separator"/>
	<xsl:param name="list"/>
	<xsl:param name="name" select="../@schema:ref"/>
	<xsl:choose>
		<!-- do we have more than one entry? -->		
		<xsl:when test="contains($list, $separator)">
			<xsl:variable name ="listEntry" select="substring-before($list, $separator)"/>
			<xsl:call-template name="printValue">
				<xsl:with-param name="value" select="$listEntry"/>
				<xsl:with-param name="name" select="$name"/>
			</xsl:call-template>
			<xsl:call-template name="stripListElements">					
				<xsl:with-param name="separator"><xsl:value-of select="$separator"/></xsl:with-param>
				<xsl:with-param name="list"><xsl:value-of select="substring-after($list, $separator)"/></xsl:with-param>					
				<xsl:with-param name="name" select="$name"/>
			</xsl:call-template>			
		</xsl:when>
		<xsl:otherwise>
			<!-- does the list contain one entry? -->		
			<xsl:if test="string-length($list) != 0">
				<xsl:call-template name="printValue">
					<xsl:with-param name="value" select="$list"/>
					<xsl:with-param name="name" select="$name"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:otherwise>			
	</xsl:choose>
</xsl:template>


<!-- ****************************** -->
<!-- * printValue				*** -->
<!-- ****************************** -->
	<xsl:template name="printValue">
	<!-- using the ' ' as default separator -->		
		<xsl:param name="value"/>
		<xsl:param name="name" select="../@schema:ref"/>
		<xsl:text>&#xA;</xsl:text><xsl:value-of select="$name"/><xsl:if test="@xml:lang"><xsl:text>;</xsl:text><xsl:value-of select="@xml:lang"/></xsl:if><xsl:text>: </xsl:text><xsl:value-of select="$value"/>
	</xsl:template>

<!-- ****************************** -->
<!-- * isListValue				*** -->
<!-- ****************************** -->
	<xsl:template name="isListValue">		
		<xsl:param name="name" select="../@schema:ref"/>		
		<xsl:choose>			
			<xsl:when test="../@cfg:component">				
				<xsl:variable name ="file">
					<xsl:call-template name="locateFile">
						<xsl:with-param name="componentName" select="../@cfg:component"/>						
					</xsl:call-template>
				</xsl:variable>				
				<xsl:if	test="not( document($file)/schema:component/schema:types/schema:value[@cfg:name=$name] )">
					<xsl:message terminate ="yes">**Error: type definition '<xsl:value-of select="$name"/>' of component '<xsl:value-of select="@cfg:component"/>' not found.</xsl:message>
				</xsl:if>
				<xsl:value-of select="document($file)/schema:component/schema:types/schema:value[@cfg:name=$name]/@cfg:derivedBy"/>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:if	test="not(/schema:component/schema:types/schema:value[@cfg:name=$name] )">
					<xsl:message terminate ="yes">**Error: type definition '<xsl:value-of select="$name"/>' not found.</xsl:message>
				</xsl:if>
				<xsl:value-of select="/schema:component/schema:types/schema:value[@cfg:name=$name]/@cfg:derivedBy"/>								
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- ****************************** -->
<!-- * classResolution			*** -->
<!-- ****************************** -->
	<xsl:template name="classResolution">		
		<xsl:param name="classNode"/>						
		<!-- do we have a class extension? -->
		<xsl:if	test="$classNode/schema:extension">
			<!-- resolve the inheritance and use the base class first -->			
			<xsl:call-template name="classSelection">				
				<xsl:with-param name="className"><xsl:value-of select="$classNode/schema:extension/@schema:base"/></xsl:with-param>
				<xsl:with-param name="componentName"><xsl:value-of select="$classNode/schema:extension/@cfg:component"/></xsl:with-param>
			</xsl:call-template>			
		</xsl:if>
		<xsl:text>&#xA;objectclass: </xsl:text><xsl:value-of select="$classNode/@cfg:name"/>
	</xsl:template>

<!-- ****************************** -->
<!-- * attributeResolution		*** -->
<!-- ****************************** -->
	<xsl:template name="attributeResolution">				
		<xsl:if	test="@cfg:finalized='true'">
			<xsl:text>&#xA;oocfgFinalized: true</xsl:text>
		</xsl:if>
	</xsl:template>

<!-- ****************************** -->
<!-- * classSelection			*** -->
<!-- ****************************** -->
	<xsl:template name="classSelection">		
		<xsl:param name="className"><xsl:value-of select="@schema:ref"/></xsl:param>
		<xsl:param name="componentName"><xsl:value-of select="@cfg:component"/></xsl:param>
		<!-- group with class reference -->		
		<xsl:choose>
			<xsl:when test="string-length($componentName) != 0">
				<xsl:variable name ="file">
					<xsl:call-template name="locateFile"><xsl:with-param name="componentName" select="$componentName"/></xsl:call-template>
				</xsl:variable>
				<xsl:if	test="not( document($file)/schema:component/schema:types/schema:class[@cfg:name=$className] )">
					<xsl:message terminate ="yes">**Error: type definition '<xsl:value-of select="$className"/>' of component '<xsl:value-of select="@cfg:component"/>' not found.</xsl:message>							 
				</xsl:if>
				<xsl:call-template name="classResolution">
					<xsl:with-param name="classNode" select="document($file)/schema:component/schema:types/schema:class[@cfg:name=$className]"/>
				</xsl:call-template>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="classResolution">										
					<xsl:with-param name="classNode" select="/schema:component/schema:types/schema:class[@cfg:name=$className]"/>
				</xsl:call-template>			
			</xsl:otherwise>
		</xsl:choose>					
	</xsl:template>

<!-- ****************************** -->
<!-- * getClassName				*** -->
<!-- ****************************** -->
	<xsl:template name="getClassName">				
		<xsl:choose>
			<xsl:when test="@schema:ref">
				<xsl:value-of select="@schema:ref"/>
			</xsl:when>				
			<xsl:when test="../@cfg:template-ref">					
				<!-- the group is element of a set, so we can extract the class name from the template -->
				<xsl:variable name ="templateName"><xsl:value-of select="../@cfg:template-ref"/></xsl:variable>				
				<xsl:choose>						
					<xsl:when test="../@cfg:component">						
						<xsl:variable name ="file">
							<xsl:call-template name="locateFile">					
								<xsl:with-param name="componentName"><xsl:value-of select="../@cfg:component"/></xsl:with-param>								
							</xsl:call-template>
						</xsl:variable>
						<xsl:if	test="not( document($file)/schema:component/schema:templates/schema:group[@cfg:name=$templateName] )">
							<xsl:message terminate ="yes">**Error: template definition '<xsl:value-of select="$templateName"/>' of component '<xsl:value-of select="@cfg:component"/>' not found.</xsl:message>
						</xsl:if>
						<xsl:value-of select="document($file)/schema:component/schema:templates/schema:group[@cfg:name=$templateName]/@schema:ref"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if	test="not( /schema:component/schema:templates/schema:group[@cfg:name=$templateName] )">
							<xsl:message terminate ="yes">**Error: template definition '<xsl:value-of select="$templateName"/>' not found.</xsl:message>							 
						</xsl:if>
						<xsl:value-of select="/schema:component/schema:templates/schema:group[@cfg:name=$templateName]/@schema:ref"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>			
		</xsl:choose>			
	</xsl:template>

<!-- ****************************** -->
<!-- * getClassComponentName	*** -->
<!-- ****************************** -->
	<xsl:template name="getClassComponentName">				
		<xsl:choose>
			<xsl:when test="@cfg:component">
				<xsl:value-of select="@cfg:component"/>
			</xsl:when>				
			<xsl:when test="../@cfg:template-ref">					
				<!-- the group is element of a set, so we can extract the class name from the template -->
				<xsl:variable name ="templateName"><xsl:value-of select="../@cfg:template-ref"/></xsl:variable>				
				<xsl:choose>						
					<xsl:when test="../@cfg:component">						
						<xsl:variable name ="file">
							<xsl:call-template name="locateFile">					
								<xsl:with-param name="componentName"><xsl:value-of select="../@cfg:component"/></xsl:with-param>								
							</xsl:call-template>
						</xsl:variable>
						<xsl:if	test="not( document($file)/schema:component/schema:templates/schema:group[@cfg:name=$templateName] )">
							<xsl:message terminate ="yes">**Error: template definition '<xsl:value-of select="$templateName"/>' of component '<xsl:value-of select="@cfg:component"/>' not found.</xsl:message>
						</xsl:if>
						<xsl:value-of select="document($file)/schema:component/schema:templates/schema:group[@cfg:name=$templateName]/@cfg:component"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if	test="not( /schema:component/schema:templates/schema:group[@cfg:name=$templateName] )">
							<xsl:message terminate ="yes">**Error: template definition '<xsl:value-of select="$templateName"/>' not found.</xsl:message>							 
						</xsl:if>
						<xsl:value-of select="/schema:component/schema:templates/schema:group[@cfg:name=$templateName]/@cfg:component"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>			
		</xsl:choose>			
	</xsl:template>



<!-- ****************************** -->
<!-- * locateFile				*** -->
<!-- ****************************** -->
	<xsl:template name="locateFile">
		<xsl:param name="componentName"/>
		<xsl:param name="path" select="$path"/>
		<xsl:variable name ="file"><xsl:value-of select="$path"/>/<xsl:value-of select="translate($componentName,'.','/')"/>.xcd</xsl:variable>
		<xsl:if	test="not( document($file) )">
			<xsl:message terminate ="yes">**Error: unable to locate document '<xsl:value-of select="translate($componentName,'.','/')"/>.xcd'</xsl:message>
		</xsl:if>
		<xsl:value-of select="$file"/>		
	</xsl:template>

</xsl:transform>