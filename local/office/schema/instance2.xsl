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

<!-- parameter which contains the URL pointing to the template directory -->
<xsl:param name="path">.</xsl:param>
<xsl:param name="pathSeparator">;</xsl:param>

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
<!-- * setContent				*** -->
<!-- ****************************** -->
    <xsl:template name="setContent">
        <xsl:attribute name="cfg:type" namespace="">set</xsl:attribute>
		<xsl:variable name = "instance" select="@cfg:template-ref"/>
		<xsl:choose>
			<xsl:when test="$instance = 'any' or $instance = 'cfg:any'">
				<xsl:attribute name="cfg:element-type" namespace="">cfg:any</xsl:attribute>
			</xsl:when>
			<xsl:when test="@cfg:component">
				<xsl:attribute name="cfg:element-type" namespace=""><xsl:value-of select="$instance"/></xsl:attribute>
				<xsl:attribute name="cfg:component" namespace=""><xsl:value-of select="@cfg:component"/></xsl:attribute>
				<xsl:variable name ="file">
					<xsl:call-template name="locateFile"><xsl:with-param name="componentName" select="@cfg:component"/></xsl:call-template>
				</xsl:variable>
				<xsl:if	test="not( document($file)/schema:component/schema:templates/*[@cfg:name=$instance] )">
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
        <xsl:apply-templates select="default:item"/>
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
            <xsl:when test="../@cfg:template-ref and $useNewSets='true'">
				<!-- then use the template-ref as template name -->
				<xsl:element name="{../@cfg:template-ref}" >
				<!-- and add a cfg:name as attribute -->
					<xsl:attribute name="cfg:name" namespace=""><xsl:value-of select="@cfg:name"/></xsl:attribute>
					<xsl:call-template name="setContent"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="../@cfg:template-ref">
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
<!-- * classResolution			*** -->
<!-- ****************************** -->
	<xsl:template name="classResolution">
		<xsl:param name="groupNode"/>
		<xsl:param name="classNode"/>						
		<!-- do we have a class extension? -->
		<xsl:if	test="$classNode/schema:extension">
			<!-- resolve the inheritance and use the base class first -->
			<xsl:message terminate ="no">base class found.</xsl:message>
			<xsl:call-template name="classSelection">
				<xsl:with-param name="groupNode" select="$groupNode"/>
				<xsl:with-param name="className"><xsl:value-of select="$classNode/schema:extension/@schema:base"/></xsl:with-param>
				<xsl:with-param name="componentName"><xsl:value-of select="$classNode/schema:extension/@cfg:component"/></xsl:with-param>
			</xsl:call-template>			
		</xsl:if>																										
		<xsl:for-each select="$classNode/schema:member">
			<xsl:variable name="value"><xsl:value-of select="@schema:ref"/></xsl:variable>
			<xsl:element name="{$value}">        
				<xsl:choose>
					<!-- value defined in different component -->
					<xsl:when test="@cfg:component">
						<xsl:variable name ="file">
							<xsl:call-template name="locateFile"><xsl:with-param name="componentName" select="@cfg:component"/></xsl:call-template>
						</xsl:variable>
						<xsl:if	test="not( document($file)/schema:component/schema:types/schema:value[@cfg:name=$value] )">
							<xsl:message terminate ="yes">**Error: type definition '<xsl:value-of select="$value"/>' of component '<xsl:value-of select="@cfg:component"/>' not found.</xsl:message>
						</xsl:if>																					
						<xsl:apply-templates select="document($file)/schema:component/schema:types/schema:value[@cfg:name=$value]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if	test="not( /schema:component/schema:types/schema:value[@cfg:name=$value] )">
							<xsl:message terminate ="yes">**Error: type definition '<xsl:value-of select="$value"/>' not found.</xsl:message>							 
						</xsl:if>																					
						<xsl:apply-templates select="/schema:component/schema:types/schema:value[@cfg:name=$value]"/>
					</xsl:otherwise>
				</xsl:choose>
				<!-- set the defaults if there are any present -->
				<xsl:apply-templates select="$groupNode/default:value[@schema:ref=$value]"/>
			</xsl:element>												
		</xsl:for-each>		
	</xsl:template>


<!-- ****************************** -->
<!-- * classSelection			*** -->
<!-- ****************************** -->
	<xsl:template name="classSelection">
		<xsl:param name="groupNode"/>
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
					<xsl:with-param name="groupNode" select="$groupNode"/>
					<xsl:with-param name="classNode" select="document($file)/schema:component/schema:types/schema:class[@cfg:name=$className]"/>
				</xsl:call-template>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="classResolution">					
					<xsl:with-param name="groupNode" select="$groupNode"/>
					<xsl:with-param name="classNode" select="/schema:component/schema:types/schema:class[@cfg:name=$className]"/>
				</xsl:call-template>			
			</xsl:otherwise>
		</xsl:choose>					
	</xsl:template>

<!-- ****************************** -->
<!-- * groupContent				*** -->
<!-- ****************************** -->
	<xsl:template name="groupContent">				
		<xsl:variable name="className"><xsl:call-template name="getClassName"/></xsl:variable>
		<xsl:variable name="componentName"><xsl:call-template name="getClassComponentName"/></xsl:variable>
		<xsl:call-template name="commonAttributes"/>
		<xsl:choose>
			<!-- group with class reference -->
			<xsl:when test="string-length($className) != 0">				
				<xsl:call-template name="classSelection">
					<xsl:with-param name="groupNode" select="current()"/>
					<xsl:with-param name="className" select="$className"/>
					<xsl:with-param name="componentName" select="$componentName"/>
				</xsl:call-template>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:if test="child::default:value">
					<xsl:message terminate ="yes">**Error: default values are not allowed without setting of a 'schema:ref' attribute.</xsl:message>
				</xsl:if>
				<xsl:if test="count(current()/*) = 0">
					<xsl:message terminate ="yes">**Error: group without child elements declared.</xsl:message>
				</xsl:if>
			</xsl:otherwise>			
		</xsl:choose>		
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:group				*** -->
<!-- ****************************** -->
	<xsl:template match="schema:group">		
		<xsl:element name="{@cfg:name}">        
			<xsl:call-template name="groupContent"/>
			
			<!-- look for further groups and sets -->	
			<xsl:apply-templates select="schema:group"/>
			<xsl:apply-templates select="schema:set"/>			
		</xsl:element>
	</xsl:template>

<!-- ****************************** -->
<!-- * default:group			*** -->
<!-- ****************************** -->
    <xsl:template match="default:group">		
		<xsl:choose>
			<!-- do we use the group in a set -->
            <xsl:when test="../@cfg:template-ref and $useNewSets='true'">
				<!-- then use the template-ref as template name -->
				<xsl:element name="{../@cfg:template-ref}" >
				<!-- and add a cfg:name as attribute -->
					<xsl:attribute name="cfg:name" namespace=""><xsl:value-of select="@cfg:name"/></xsl:attribute>
					
					<xsl:call-template name="groupContent"/>
					<!-- look for further groups and sets -->	
					<xsl:apply-templates select="default:group"/>
					<xsl:apply-templates select="default:set"/>			
				</xsl:element>
			</xsl:when>
			<xsl:when test="../@cfg:template-ref">
				<!-- then use the element-type as template name -->
				<xsl:variable name = "elementName"><xsl:value-of select="decoder:encode(string(@cfg:name))"/></xsl:variable>
				<xsl:element name="{$elementName}" >									
					<xsl:call-template name="groupContent"/>
					<!-- look for further groups and sets -->	
					<xsl:apply-templates select="default:group"/>
					<xsl:apply-templates select="default:set"/>			
				</xsl:element>
			</xsl:when>									
			<xsl:otherwise>
				<xsl:element name="{@cfg:name}" >
					<xsl:call-template name="groupContent"/>
					<!-- look for further groups and sets -->	
					<xsl:apply-templates select="default:group"/>
					<xsl:apply-templates select="default:set"/>			
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- ****************************** -->
<!-- * schema:value				*** -->
<!-- ****************************** -->
	<xsl:template match="schema:value">		
		<xsl:call-template name="typeResolution"/>
	</xsl:template>

<!-- ****************************** -->
<!-- * default:value			*** -->
<!-- ****************************** -->
    <xsl:template match="default:value">
		<!-- test if schema:ref is available -->
		<xsl:variable name ="name" select="@schema:ref"/>
		<xsl:choose>
			<xsl:when test="@cfg:component">						
				<xsl:variable name ="file">
					<xsl:call-template name="locateFile">					
						<xsl:with-param name="componentName"><xsl:value-of select="@cfg:component"/></xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if	test="not( document($file)/schema:component/schema:types/schema:value[@cfg:name=$name] )">
					<xsl:message terminate ="yes">**Error: type definition '<xsl:value-of select="$name"/>' of component '<xsl:value-of select="@cfg:component"/>' not found.</xsl:message>
				</xsl:if>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:if	test="not( /schema:component/schema:types/schema:value[@cfg:name=$name] )">
					<xsl:message terminate ="yes">**Error: type definition '<xsl:value-of select="$name"/>' not found.</xsl:message>
				</xsl:if>							
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="valueContent"/>
	</xsl:template>

<!-- ****************************** -->
<!-- * default:item				*** -->
<!-- ****************************** -->
    <xsl:template match="default:item">
		<xsl:choose>
			<xsl:when test="$useNewSets='true'">
				<xsl:element name="cfg:{@cfg:type}">				
					<xsl:attribute name="cfg:name" namespace=""><xsl:value-of select="@cfg:name"/></xsl:attribute>
					<xsl:call-template name="typeResolution"/>
					<xsl:call-template name="valueContent"/>		
				</xsl:element>
			</xsl:when>			
			<xsl:otherwise>
				<xsl:variable name = "elementName"><xsl:value-of select="decoder:encode(string(@cfg:name))"/></xsl:variable>
				<xsl:element name="{$elementName}" >
					<xsl:call-template name="typeResolution"/>
					<xsl:call-template name="valueContent"/>		
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>

<!-- ****************************** -->
<!-- * valueContent				*** -->
<!-- ****************************** -->
	<xsl:template name="valueContent">        
        <xsl:call-template name="commonAttributes"/>        
		
		<!-- throw warning if empty element default:data, as this will be interpreted as list with one empty element -->
		<xsl:if test="(@cfg:separator)">
			<xsl:choose>
				<xsl:when test="count(child::default:data) > 0">
					<xsl:for-each select="child::default:data">
						<xsl:variable name = "content" select="."/>
						<xsl:if test = "not (@xsi:null = 'true') and string-length($content) = 0">
							<xsl:message terminate="no">Warning: Although empty element declared, a list with one element will be created for value '<xsl:value-of select="../@schema:ref"/>'</xsl:message>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@cfg:type='string'">
					<xsl:message terminate="no">Warning: Although empty element declared, a list with one element will be created for value '<xsl:value-of select="../@schema:ref"/>'</xsl:message>
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
        <xsl:if test="@cfg:finalized = 'true'">
            <xsl:attribute name="cfg:finalized" namespace="">
                <xsl:value-of select="@cfg:finalized"/>
			</xsl:attribute>                
        </xsl:if>		
        <xsl:if test="@cfg:nullable = 'false'">
            <xsl:attribute name="cfg:nullable" namespace="">				
                <xsl:value-of select="@cfg:nullable"/>
            </xsl:attribute>
        </xsl:if>		
    </xsl:template>

<!-- ****************************** -->
<!-- * getPackageRoot			*** -->
<!-- ****************************** -->    
	<xsl:template name="getPackageRoot">
		<!-- using the ' ' as default separator -->		
		<xsl:param name="packageName"/>		
		<xsl:param name="path"/>		
		<xsl:choose>
			<!-- do we have more than one entry? -->		
			<xsl:when test="contains($packageName, '.')">
				<xsl:call-template name="getPackageRoot">					
					<xsl:with-param name="packageName"><xsl:value-of select="substring-after($packageName, '.')"/></xsl:with-param>	
					<xsl:with-param name="path"><xsl:value-of select="$path"/>../</xsl:with-param>	
				</xsl:call-template>			
			</xsl:when>
			<xsl:when test="string-length($packageName)"><xsl:value-of select="$path"/>../</xsl:when>				
			<xsl:otherwise>./</xsl:otherwise>				
		</xsl:choose>
	</xsl:template>

<!-- ****************************** -->
<!-- * getComponentName			*** -->
<!-- ****************************** -->
    <!-- locating the last part of the component name -->
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



</xsl:transform>

