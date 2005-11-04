<?xml version="1.0" encoding="utf-8" standalone="yes" ?>

<!-- ****************************************************************************************** -->
<!-- * Transformation of schema description into configuration instance format to XML		*** -->
<!-- ****************************************************************************************** -->
<xsl:transform  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance"
				xmlns:schema="http://openoffice.org/2000/registry/schema/description"
				xmlns:default="http://openoffice.org/2000/registry/schema/default"
				xmlns:cfg="http://openoffice.org/2000/registry/instance"
				xmlns:decoder="http://www.jclark.com/xt/java/org.openoffice.configuration.Decoder">

<!-- Get the correct format -->
<xsl:output method="xml"/>

<!-- parameter for controlling the generation of templates -->
<xsl:param name="templates">false</xsl:param>

<!-- parameter for controlling in which way sets are generated -->
<xsl:param name="useNewSets">true</xsl:param>

<!-- parameter which contains the URL pointing to the template directory -->
<xsl:param name="templateURL">.</xsl:param>

<xsl:variable name ="defaultLang">en-US</xsl:variable>

<!-- Transformation into data and template files -->

<!-- ****************************** -->
<!-- * schema:component			*** -->
<!-- ****************************** -->
	<xsl:template match="/schema:component">
        <!-- Deside what to generate -->
		<xsl:element name="{@cfg:name}">
			<xsl:attribute name="cfg:package" namespace="http://openoffice.org/2000/registry/instance"><xsl:value-of select="@cfg:package"/></xsl:attribute>
			<xsl:attribute name="xmlns:xsi" namespace="">http://www.w3.org/1999/XMLSchema-instance</xsl:attribute>			
			<xsl:choose>
                <xsl:when test="$templates = 'true' ">
	<!-- Templates -->
					<xsl:apply-templates select="schema:templates"/>
				</xsl:when>
	<!-- Data -->
				<xsl:otherwise>
					<xsl:apply-templates select="schema:schema"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:documentation		*** -->
<!-- ****************************** -->
    <xsl:template match="schema:documentation">
<!-- nothing to do, as we don't need any documentation in the instance xml -->        
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:type-info			*** -->
<!-- ****************************** -->
    <xsl:template match="schema:type-info">
<!-- nothing to do, as we don't need any type-info in the instance xml -->        
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:templates			*** -->
<!-- ****************************** -->
    <xsl:template match="schema:templates">
        <xsl:apply-templates/>
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:schema			*** -->
<!-- ****************************** -->
	<xsl:template match="schema:schema">
        <xsl:apply-templates/>
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:instance			*** -->
<!-- ****************************** -->
	<xsl:template match="schema:instance">
		<xsl:choose>
            <xsl:when test="child::default:set"><xsl:apply-templates select="default:set"/></xsl:when>
            <xsl:when test="child::default:group"><xsl:apply-templates select="default:group"/></xsl:when>
            <xsl:when test="child::default:value"><xsl:apply-templates select="default:value"/></xsl:when>
			<xsl:otherwise>
				<xsl:variable name ="instance" select="@cfg:instance-of"/>
				<xsl:choose>					
					<xsl:when test="@cfg:component">																		
						<xsl:variable name ="file"><xsl:value-of select="$templateURL"/>/<xsl:value-of select="translate(@cfg:component,'.','/')"/>.xml</xsl:variable>						
						<xsl:variable name ="componentName">
							<xsl:call-template name="getComponentName">					
								<xsl:with-param name="componentName"><xsl:value-of select="@cfg:component"/></xsl:with-param>					
							</xsl:call-template>
						</xsl:variable>
						<xsl:if	test="not( document($file)/*[local-name(.) = $componentName]/*[local-name(.) = $instance] )">
							<xsl:message terminate ="yes">**Error: template '<xsl:value-of select="$instance"/>' of component '<xsl:value-of select="@cfg:component"/>' not found.</xsl:message>							 
						</xsl:if>												
						<xsl:copy-of select="document($file)/*[local-name(.) = $componentName]/*[local-name(.) = $instance]"/>
					</xsl:when>
					<xsl:otherwise>												
						<xsl:if	test="not( /schema:component/schema:templates/schema:set[@cfg:name=$instance] or 
								 	       /schema:component/schema:templates/schema:group[@cfg:name=$instance] or
										   /schema:component/schema:templates/schema:value[@cfg:name=$instance] )">
							<xsl:message terminate ="yes">**Error: template '<xsl:value-of select="$instance"/>' of package '<xsl:value-of select="/schema:component/@cfg:name"/>' not found.</xsl:message>							 
						</xsl:if>

						<xsl:apply-templates select="/schema:component/schema:templates/schema:set[@cfg:name=$instance]">
							<xsl:with-param name="elementName"><xsl:value-of select="@cfg:name"/></xsl:with-param>
						</xsl:apply-templates>
						<xsl:apply-templates select="/schema:component/schema:templates/schema:group[@cfg:name=$instance]">
							<xsl:with-param name="elementName"><xsl:value-of select="@cfg:name"/></xsl:with-param>
						</xsl:apply-templates>
						<xsl:apply-templates select="/schema:component/schema:templates/schema:value[@cfg:name=$instance]">
							<xsl:with-param name="elementName"><xsl:value-of select="@cfg:name"/></xsl:with-param>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
        </xsl:choose>        
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:set				*** -->
<!-- ****************************** -->
    <xsl:template match="schema:set">
        <xsl:param name="elementName"><xsl:value-of select="@cfg:name"/></xsl:param>
		<xsl:element name="{$elementName}" >
			<xsl:call-template name="setContent"/>
		</xsl:element>
	</xsl:template>

    <xsl:template match="default:set">
		<xsl:choose>
			<!-- do we use the group in a set -->
            <xsl:when test="../@cfg:element-type and $useNewSets='true'">
				<!-- then use the element-type as template name -->
				<xsl:element name="{../@cfg:element-type}" >
				<!-- and add a cfg:name as attribute -->
					<xsl:attribute name="cfg:name" namespace=""><xsl:value-of select="@cfg:name"/></xsl:attribute>
					<xsl:call-template name="setContent"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="../@cfg:element-type">
				<xsl:variable name = "elementName"><xsl:value-of select="decoder:encode(string(@cfg:name))"/></xsl:variable>
				<xsl:element name="{$elementName}" >														
					<xsl:call-template name="setContent"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="../@cfg:instance-of">
				<xsl:element name="{../@cfg:name}" >
					<xsl:call-template name="setContent"/>
				</xsl:element>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:element name="{@cfg:name}" >
					<xsl:call-template name="setContent"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:group				*** -->
<!-- ****************************** -->
	<xsl:template match="schema:group">
        <xsl:param name="elementName"><xsl:value-of select="@cfg:name"/></xsl:param>
		<xsl:element name="{$elementName}">        
            <xsl:call-template name="commonAttributes"/>
            <xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

    <xsl:template match="default:group">
		<xsl:choose>
			<!-- do we use the group in a set -->
            <xsl:when test="../@cfg:element-type and $useNewSets='true'">
				<!-- then use the element-type as template name -->
				<xsl:element name="{../@cfg:element-type}" >
				<!-- and add a cfg:name as attribute -->					
					<xsl:attribute name="cfg:name" namespace=""><xsl:value-of select="@cfg:name"/></xsl:attribute>
					<xsl:call-template name="commonAttributes"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:when>			
			<xsl:when test="../@cfg:element-type">
				<!-- then use the element-type as template name -->
				<xsl:variable name = "elementName"><xsl:value-of select="decoder:encode(string(@cfg:name))"/></xsl:variable>
				<xsl:element name="{$elementName}" >									
					<xsl:call-template name="commonAttributes"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:when>			
			<xsl:when test="../@cfg:instance-of">
				<xsl:element name="{../@cfg:name}" >
					<xsl:call-template name="commonAttributes"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{@cfg:name}" >
					<xsl:call-template name="commonAttributes"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:value				*** -->
<!-- ****************************** -->
	<xsl:template match="schema:value">
		<xsl:param name="elementName"><xsl:value-of select="@cfg:name"/></xsl:param>
		<xsl:element name="{$elementName}">        
			<xsl:call-template name="valueContent"/>
		</xsl:element>
	</xsl:template>

<!-- ****************************** -->
<!-- * default:value			*** -->
<!-- ****************************** -->
    <xsl:template match="default:value">
		<xsl:choose>
			<!-- do we use the group in a set -->
            <xsl:when test="../@cfg:element-type and $useNewSets='true'">
				<!-- then use the element-type as template name -->
				<xsl:element name="{../@cfg:element-type}" >
				<!-- and add a cfg:name as attribute -->
					<xsl:attribute name="cfg:name" namespace=""><xsl:value-of select="@cfg:name"/></xsl:attribute>
					<xsl:call-template name="valueContent"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="../@cfg:element-type">				
				<xsl:variable name = "elementName"><xsl:value-of select="decoder:encode(string(@cfg:name))"/></xsl:variable>
				<xsl:element name="{$elementName}" >									
				<!-- and add a cfg:name as attribute -->					
					<xsl:call-template name="valueContent"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="../@cfg:instance-of">
				<xsl:element name="{../@cfg:name}" >
					<xsl:call-template name="valueContent"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{@cfg:name}" >
					<xsl:call-template name="valueContent"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- ****************************** -->
<!-- * setContent				*** -->
<!-- ****************************** -->
    <xsl:template name="setContent">
        <xsl:attribute name="cfg:type" namespace="">set</xsl:attribute>        
		<xsl:variable name = "instance" select="@cfg:element-type"/>
		<xsl:choose>
			<xsl:when test="$instance = 'any' or $instance = 'cfg:any'">
				<xsl:attribute name="cfg:element-type" namespace="">cfg:any</xsl:attribute>
			</xsl:when>
			<xsl:when test="@cfg:component">
				<xsl:attribute name="cfg:element-type" namespace=""><xsl:value-of select="$instance"/></xsl:attribute>
				<xsl:attribute name="cfg:component" namespace=""><xsl:value-of select="@cfg:component"/></xsl:attribute>
				
				<!-- check if template is available -->			
				<xsl:variable name ="file"><xsl:value-of select="$templateURL"/>/<xsl:value-of select="translate(@cfg:component,'.','/')"/>.xml</xsl:variable>						
				<xsl:variable name ="componentName">
					<xsl:call-template name="getComponentName">					
						<xsl:with-param name="componentName"><xsl:value-of select="@cfg:component"/></xsl:with-param>					
					</xsl:call-template>
				</xsl:variable>
				<xsl:if	test="not( document($file)/*[local-name(.) = $componentName]/*[local-name(.) = $instance] )">
					<xsl:message terminate ="yes">**Error: template '<xsl:value-of select="$instance"/>' of component '<xsl:value-of select="@cfg:component"/>' not found.</xsl:message>							 
				</xsl:if>												
			</xsl:when>
			<xsl:otherwise>				
				<xsl:attribute name="cfg:element-type" namespace=""><xsl:value-of select="$instance"/></xsl:attribute>
				<xsl:if test="not (/schema:component/schema:templates/*[@cfg:name = $instance])">
					<xsl:message terminate ="yes">**Error: illegal template type defined '<xsl:value-of select="$instance"/>'.</xsl:message>
				</xsl:if>
			</xsl:otherwise>												
		</xsl:choose>
		
        <xsl:call-template name="commonAttributes"/>
		        
        <xsl:apply-templates select="default:set"/>
        <xsl:apply-templates select="default:group"/>
        <xsl:apply-templates select="default:value"/>
	</xsl:template>

<!-- ****************************** -->
<!-- * valueContent				*** -->
<!-- ****************************** -->
	<xsl:template name="valueContent">
        <xsl:call-template name="typeResolution"/>
		<xsl:call-template name="commonAttributes"/>

		<!-- throw warning if empty element default:data, as this will be interpreted as list with one empty element -->
		<xsl:if test="(@cfg:separator)">
			<xsl:choose>
				<xsl:when test="count(child::default:data) > 0">
					<xsl:for-each select="child::default:data">
						<xsl:variable name = "content" select="."/>
						<xsl:if test = "not (@xsi:null = 'true') and string-length($content) = 0">
							<xsl:message terminate="no">Warning: Although empty element declared, a list with one element will be created for value '<xsl:value-of select="../@cfg:name"/>'</xsl:message>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@cfg:type='string'">
					<xsl:message terminate="no">Warning: Although empty element declared, a list with one element will be created for value '<xsl:value-of select="../@cfg:name"/>'</xsl:message>
				</xsl:when>
			</xsl:choose>
		</xsl:if>		

		<xsl:choose>
			<xsl:when test="(@cfg:localized and @cfg:localized='true')">
				<xsl:for-each select="child::default:data">
					<xsl:element name="cfg:value">
						<xsl:attribute name="xml:lang" namespace=""><xsl:value-of select="@xml:lang"/></xsl:attribute>
						<xsl:choose>
							<xsl:when test="not (@xsi:null) or (@xsi:null = 'false')">
								<xsl:value-of select="."/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="xsi:null" namespace="">true</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>								
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="not (default:data) and @cfg:type != 'string'">
				<xsl:attribute name="xsi:null" namespace="">true</xsl:attribute>
			</xsl:when>
			<xsl:when test="default:data[@xsi:null='true']">
				<xsl:attribute name="xsi:null" namespace="">true</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="default:data"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- ****************************** -->
<!-- * nullContent              *** -->
<!-- ****************************** -->
    <xsl:template name="nullContent">
        <xsl:element name="cfg:value">
            <xsl:attribute name="xsi:null" namespace="">true</xsl:attribute>            
		</xsl:element>
	</xsl:template>


<!-- ****************************** -->
<!-- * typeResolution			*** -->
<!-- ****************************** -->
    <xsl:template name="typeResolution">
        <!-- printing the type -->		
		<xsl:attribute name="cfg:type" namespace="">		
			<xsl:value-of select="@cfg:type"/>							
		</xsl:attribute>		

		<!-- localized ? -->
		<xsl:if test="@cfg:localized">			
			<xsl:attribute name="cfg:localized" namespace=""><xsl:value-of select="@cfg:localized"/></xsl:attribute>
		</xsl:if>

		<!-- separator ? -->
		<xsl:if test="@cfg:separator">			
			<xsl:attribute name="cfg:separator" namespace=""><xsl:value-of select="@cfg:separator"/></xsl:attribute>
		</xsl:if>
		
		<!-- do we have a list? -->
        <xsl:if test="@cfg:derivedBy='list'">
            <xsl:attribute name="cfg:derivedBy" namespace="">
                <xsl:value-of select="@cfg:derivedBy"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

<!-- ****************************** -->
<!-- * commonAttributes			*** -->
<!-- ****************************** -->
    <xsl:template name="commonAttributes">
        <xsl:if test="@cfg:writable = 'false'">
            <xsl:attribute name="cfg:finalized" namespace="">true</xsl:attribute>
        </xsl:if>
        <xsl:if test="@cfg:nullable = 'false'">
            <xsl:attribute name="cfg:nullable" namespace="">				
                <xsl:value-of select="@cfg:nullable"/>
            </xsl:attribute>
        </xsl:if>		
    </xsl:template>

<!-- ****************************** -->
<!-- * getComponentName			*** -->
<!-- ****************************** -->
    <xsl:template name="getComponentName">
		<!-- using the ' ' as default separator -->		
		<xsl:param name="componentName"/>		
		<xsl:choose>
			<!-- do we have more than one entry? -->		
			<xsl:when test="contains($componentName, '.')">
				<xsl:call-template name="getComponentName">					
					<xsl:with-param name="componentName"><xsl:value-of select="substring-after($componentName, '.')"/></xsl:with-param>					
				</xsl:call-template>			
			</xsl:when>
			<xsl:otherwise>				
				<xsl:value-of select="$componentName"/>				
			</xsl:otherwise>			
		</xsl:choose>
	</xsl:template>

</xsl:transform>

