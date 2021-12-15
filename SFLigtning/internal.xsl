<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<!-- Modified: 4/2011 by Zakiya Vallier (Product Managment)   -->
	<!-- See Quickstart 11.04 How-to for changes since last version -->
	<xsl:output method="html"/>
	<xsl:strip-space elements="*"/>
	<!-- ============				OPTIONAL  Simple Customization  (default settings are usually fine for everyone)		================================   -->
	<!-- optional:  change the href to link to hpcore_engine.xsl file (by default, should be in the xsl).  -->
	<!--xsl:include href="http://localhost/xsl/hpcore_engine.xsl"/-->
	<!-- OPTIONAL: settingsReturnToQuoteLabel: the label for the return to quote link -->
	<xsl:variable name="settingsReturnToQuoteLabel" select="'Return To Quote'"/>
	<!-- OPTIONAL: pageTitle: assigns a title to the home page -->
	<xsl:variable name="pageTitle" select="'Product List'"/>
	<!-- OPTIONAL: alwaysShowHomePage: if false, jumps to the parts search page if no pf's exist, set to true to always land on the home page -->
	<xsl:variable name="alwaysShowHomePage" select="'false'"/>
	<!-- OPTIONAL: pLineDescriptionLocation: determines where product line description shows up, options, top, bottom, hidden -->
	<xsl:variable name="pLineDescriptionLocation" select="'top'"/>
	<!-- OPTIONAL: enableMultiplePartsBuy, shows multiple parts buy link in parts search dropdown, true or false -->
	<xsl:variable name="enableMultiplePartsBuy" select="'true'"/>
	<!-- OPTIONAL: serialNumSearchEnabled, determines whether to dislplay serial number search or not -->
	<xsl:variable name="serialNumSearchEnabled" select="'true'"/>
	<!-- OPTIONAL: serialNumSearchEnabled, Label that display for Serial Number Attribute Search -->
	<xsl:variable name="serialNumSearchLabel" select="'Serial Number Search'"/>

	<!-- OPTIONAL: HTML code to display to non-logged in users. -->
	<!--xsl:variable name="settingsNotLoggedInHTML"><![CDATA[]]></xsl:variable-->
	<!-- ############  		ADVANCED CUSTOMIZATION 		 #######################  -->
	<!-- default price book value/id -->
	<!-- ############   REAL STUFF  STARTS HERE   (Don't modify unless you are sure you know what you are doing ######################  -->
	<!-- flag for whether the user is logged in or not -->
	<xsl:variable name="isLoggedIn">
		<xsl:choose>
			<xsl:when test="/home_page/page_data/user_name = 'guest1' or /home_page/page_data/company = 'GuestCompany'">
				<xsl:value-of select="'false'"/>
			</xsl:when>
			<xsl:when test="string-length(normalize-space(/home_page/page_data/user_name)) != 0">
				<xsl:value-of select="'true'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="productCount">
		<xsl:value-of select="count(/home_page/product_families/product_family)"/>
	</xsl:variable>
	<!-- flag for whether pricebook functionality is enabled -->
	<xsl:variable name="priceBookEnabled">
		<xsl:choose>
			<xsl:when test="string-length(/home_page/parts_search_templates/group/form[@id='price_book_form']) &gt; 0">
				<xsl:value-of select="'true'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- flag for whether part search should be enabled -->
	<xsl:variable name="partSearchEnabled">
		<xsl:choose>
			<xsl:when test="count(/home_page/parts_search_templates/group) &gt; 0">
				<xsl:value-of select="'true'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- en  -->
	<xsl:variable name="userLanguageCode" select="/home_page/page_data/language_preference_code"/>
	<xsl:variable name="userType" select="/home_page/page_data/user_type"/>
	<!-- main template starts here -->
	<xsl:template match="/">
		<!-- Site Title (html title is undefined for custom homepages for some reason - bug?) -->
		<title>
			<xsl:value-of select="$pageTitle"/>
		</title>
		<!-- Non-logged-in message -->
		<!--xsl:if test="$productCount &gt;  0">
				<xsl:value-of select="$settingsNotLoggedInHTML"/>
			</xsl:if-->

		<xsl:choose>
			<xsl:when test="$productCount &gt; 0 or ($alwaysShowHomePage = 'true' and $isLoggedIn = 'true')">
				<!-- *******************    start main homepage UI   *********************	-->
				<div id="wrapper">
					<div id="wrapper-inner" class="clearfix">
						<xsl:call-template name="printSimpleSearch"/>
						<ul id="family-nav" class="clearfix dropdown" aria-orientation="horizontal" role="tablist">
							<xsl:for-each select="/home_page/product_families/product_family">
								<xsl:sort select="normalize-space(order_number)" data-type="number"/>
								<xsl:variable name="pf_var_name" select="variable_name"/>
								<xsl:variable name="pf_doc" select="."/>
								<li class="levelOne">
									<a href="#" id="{$pf_var_name}" role="tab"
										aria-selected="false" aria-controls="content-{$pf_var_name}" tabindex="-1">
										<xsl:call-template name="getTranslation">
											<xsl:with-param name="list_of_translations" select="./label"/>
										</xsl:call-template>
									</a>
								</li>
							</xsl:for-each>
						</ul>
						<!-- Print out descriptions -->
						<div id="content">
							<xsl:for-each select="/home_page/product_families/product_family">
								<xsl:sort select="normalize-space(order_number)" data-type="number"/>
								<xsl:variable name="pf_var_name" select="variable_name"/>
								<div id="content-{$pf_var_name}" class="product-family-content" role="tabpanel">
								<xsl:for-each select="./product_lines/product_line">
									<xsl:sort select="normalize-space(order_number)" data-type="number"/>
									<xsl:variable name="pline_doc" select="."/>
									<xsl:variable name="pl_var_name" select="_bm_pline_variable_name"/>
									<h2 id="hdr-{$pf_var_name}-{$pl_var_name}" class="pl-expando-hdr">
										<a href="#" class="pl-expando expanded" aria-labelledby="hdr-{$pf_var_name}-{$pl_var_name}"
											role="button" aria-controls="content-{$pf_var_name}-{$pl_var_name}" aria-expanded="true"></a>
										<xsl:call-template name="getTranslation">
												<xsl:with-param name="list_of_translations" select="_bm_pline_name"/>
											</xsl:call-template>
									</h2>
									<div id="content-{$pf_var_name}-{$pl_var_name}" class="product-content">
										<xsl:if test="$pLineDescriptionLocation='top'">
										<div class="product-line-description clearfix">
											<xsl:call-template name="getTranslation">
												<xsl:with-param name="list_of_translations" select="_bm_pline_description"/>
											</xsl:call-template>
										</div>
										<!-- Get All Associated files for PL -->
										<xsl:if test="count($pline_doc/associated_files/associated_file) &gt; 0">
											<ul class="associated-files">
												<xsl:for-each select="$pline_doc/associated_files/associated_file">
													<xsl:variable name="link_value" select="link"/>
													<li>
														<a href="{$link_value}" target="_blank">
															<xsl:value-of select="readable_name"/>
														</a>
													</li>
												</xsl:for-each>
											</ul>
										</xsl:if>
										</xsl:if>
										<!-- this is for the models -->
										<xsl:apply-templates select="$pline_doc" mode="HP_GetModelConfigLinks2"/>
										<xsl:if test="$pLineDescriptionLocation='bottom'">
										<div class="product-line-description clearfix">
											<xsl:call-template name="getTranslation">
												<xsl:with-param name="list_of_translations" select="_bm_pline_description"/>
											</xsl:call-template>
										</div>
										</xsl:if>
									</div>
								</xsl:for-each>
								</div>
							</xsl:for-each>
						</div>
						<!-- /#content -->
						<span id="logo-wrapper"/>
					</div>
					<!-- /#wrapper-inner -->
				</div>
				<!-- /#wrapper -->
				<div id="footer">
					<div id="footer-inner">
						</div>
					<!-- /#footer-inner -->
				</div>
				<!-- #/footer -->
			</xsl:when>
			<!-- homepage only displays when products are present-->
			<xsl:when test="$partSearchEnabled = 'true' and $isLoggedIn='true'">
				<!-- homepage only displays when only parts are present -->
				<div id="parts-only">
					<xsl:call-template name="printSimpleSearch"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<!-- user isn't logged in and products aren't visible -->
				<span id="login-logo-wrapper">
					<span id="login-logo"/>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="getTranslation">
		<xsl:param name="list_of_translations"/>
		<!--xsl:value-of select="$list_of_translations"/-->
		<xsl:choose>
			<xsl:when test="string-length(normalize-space($list_of_translations[@isTranslated='Yes']/*[name()=$userLanguageCode])) &gt; 0">
				<xsl:value-of select="$list_of_translations[@isTranslated='Yes']/*[name()=$userLanguageCode]" disable-output-escaping="yes"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$list_of_translations" disable-output-escaping="yes"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="product_line" mode="HP_GetModelConfigLinks2">
		<!-- ***   Start model configs punch-in listing. loop through all models to get punch-ins & information  ***  -->
		<xsl:for-each select="models/model">
			<xsl:sort select="normalize-space(./punchin_urls/config/params/@order_number)" data-type="number"/>
			<xsl:variable name="modelDoc" select="."/>
			<xsl:variable name="model_var_name" select="_bm_model_variable_name"/>
			<xsl:variable name="model_name" select="_bm_model_name"/>
			<xsl:variable name="model_img" select="_bm_model_image/link"/>
			<xsl:variable name="model_description" select="_bm_model_description"/>
			<xsl:variable name="config_url" select="punchin_urls/config/@url"/>
			<!-- loop through params to build punch-in. each params set is a punch-in -->
			<!-- REMOVING ROW WRAPPER DIV -->
			<!-- places a div around 3 models 
			<xsl:if test="position()=1 or ((position()-1) mod 4 = 0)">
				<xsl:variable name="startDiv"><![CDATA[<div class="row clearfix">]]></xsl:variable>
				<xsl:value-of select="$startDiv" disable-output-escaping="yes"/>
			</xsl:if>
			-->
			<!-- gets the main punchin for the model which ever with order number = 1-->
			<xsl:variable name="punchinUrlMain">
				<xsl:for-each select="punchin_urls/config/params[position()=1]">
					<xsl:sort order="ascending" data-type="number" select="@order_number"/>
					<xsl:apply-templates select="." mode="HP_GetFinalModelPunchin2">
						<xsl:with-param name="config_url" select="$config_url"/>
					</xsl:apply-templates>
				</xsl:for-each>
			</xsl:variable>
			<div class="model" id="model-{$model_var_name}">
				<xsl:if test="string-length($model_img) &gt; 0">
					<a href="{$punchinUrlMain}" class="img-wrapper">
						<img src="{$model_img}" alt="{$model_name}"/>
					</a>
				</xsl:if>
				<div class="model-summary-wrapper">
					<h3>
						<a href="{$punchinUrlMain}">
							<!-- gets the correct name for the list -->
							<xsl:for-each select="punchin_urls/config/params[position()=1]">
								<xsl:sort order="ascending" data-type="number" select="@order_number"/>
								<xsl:call-template name="getTranslation">
									<xsl:with-param name="list_of_translations" select="./name"/>
								</xsl:call-template>
							</xsl:for-each>
						</a>
					</h3>
					<!-- shows a list of additional config punchins -->
					<xsl:if test="count(punchin_urls/config/params[position()!=1]) != 0">
						<ul class="additional-models">
							<xsl:for-each select="punchin_urls/config/params[position()!=1]">
								<xsl:sort order="ascending" data-type="number" select="@order_number"/>
								<xsl:variable name="tempLink">
									<xsl:apply-templates select="." mode="HP_GetFinalModelPunchin2">
										<xsl:with-param name="config_url" select="$config_url"/>
									</xsl:apply-templates>
								</xsl:variable>
								<li>
									<a href="{$tempLink}">
										<xsl:call-template name="getTranslation">
											<xsl:with-param name="list_of_translations" select="name"/>
										</xsl:call-template>
									</a>
								</li>
							</xsl:for-each>
						</ul>
					</xsl:if>
					<div class="model-summary">
						<!--xsl:value-of disable-output-escaping="yes" select="$model_description"/-->
						<xsl:call-template name="getTranslation">
							<xsl:with-param name="list_of_translations" select="_bm_model_description"/>
						</xsl:call-template>
					</div>
					<!-- Get All Associated files first -->
					<xsl:if test="count($modelDoc/associated_files/associated_file) &gt; 0">
						<ul class="associated-files">
							<xsl:for-each select="$modelDoc/associated_files/associated_file">
								<xsl:variable name="link_value" select="link"/>
								<li>
									<a href="{$link_value}" target="_blank">
										<xsl:value-of select="readable_name"/>
									</a>
								</li>
							</xsl:for-each>
						</ul>
					</xsl:if>
				</div>
			</div>
			<!-- REMOVING ROW WRAPPER DIV
			<xsl:if test="position()=last() or (position() mod 4 = 0)">
				<xsl:variable name="endDiv"><![CDATA[</div>]]></xsl:variable>
				<xsl:value-of select="$endDiv" disable-output-escaping="yes"/>
			</xsl:if>
			-->
		</xsl:for-each>
		<!-- ******		END MODEL PUNCH-IN LISTING.  WOOT! ******		-->
	</xsl:template>
	<xsl:template match="params" mode="HP_GetFinalModelPunchin2">
		<xsl:param name="config_url"/>
		<xsl:variable name="final_config_url">
			<xsl:if test="fixed/product_family_var_name">
				<xsl:value-of select="concat($config_url,'?','segment=',fixed/product_family_var_name,'&amp;')"/>
			</xsl:if>
			<xsl:if test="fixed/pline_var_name">
				<xsl:value-of select="concat('product_line=',fixed/pline_var_name,'&amp;')"/>
			</xsl:if>
			<xsl:if test="fixed/model_var_name">
				<xsl:value-of select="concat('model=',fixed/model_var_name)"/>
			</xsl:if>
			<xsl:if test="string-length(user_defined/_bm_search_flow_config_atts) &gt; 0">
				<xsl:value-of select="'&amp;_bm_search_flow_config_atts='"/>
				<xsl:for-each select="user_defined/_bm_search_flow_config_atts/attribute">
					<xsl:value-of select="concat(@variable_name,'%2B',.)"/>
					<xsl:if test="position() != last()">%2B</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="string-length(user_defined/_bm_search_result) &gt; 0">
				<xsl:value-of select="'&amp;bm_search_result='"/>
				<xsl:for-each select="user_defined/_bm_search_result/attribute">
					<xsl:value-of select="concat(@variable_name,'@',.)"/>
					<xsl:if test="position() != last()">@</xsl:if>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="user_defined/attribute">
				<xsl:value-of select="'&amp;'"/>
				<xsl:for-each select="user_defined/attribute">
					<xsl:value-of select="concat(@variable_name,'=',.)"/>
					<xsl:if test="position() != last()">&amp;</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="$final_config_url"/>
	</xsl:template>
	<xsl:template name="printSimpleSearch">
		<xsl:variable name="partsSearchLabel" select="//parts_search_templates/top_bar/@label"/>
		<xsl:variable name="searchResultsUrl" select="'/commerce/parts/part_search_results.jsp'"/>
		<!-- div that holds return to quote, login, parts search and serial  number search -->
		<xsl:element name="div">
			<xsl:attribute name="id">search-login-toggle-wrapper</xsl:attribute>
			<xsl:if test="$isLoggedIn = 'true' and $partSearchEnabled = 'false'">
				<xsl:attribute name="class">return-to-quote-wrapper</xsl:attribute>
			</xsl:if>
			<a href="#" class="return-to-quote">
				<xsl:value-of select="$settingsReturnToQuoteLabel"/>
			</a>
			<xsl:if test="$partSearchEnabled = 'true'">
				<span class="pipe return-to-quote-pipe">|</span>
				<a href="#" class="parts-search-toggle" role="button">
					<xsl:value-of select="$partsSearchLabel"/>
				</a>
			</xsl:if>
			<xsl:if test="$serialNumSearchEnabled = 'true'">
				<span class="pipe">|</span>
				<a href="#" class="serial-num-search-toggle" role="button">
					<xsl:value-of select="$serialNumSearchLabel"/>
				</a>
			</xsl:if>
			<xsl:if test="$isLoggedIn = 'false'">
				<xsl:if test="$partSearchEnabled = 'true' and $isLoggedIn = 'false'">
					<span class="pipe">|</span>
				</xsl:if>
				<a href="#" class="login-toggle">Login</a>
			</xsl:if>
		</xsl:element>
		<!-- div that holds parts search data -->
		<div id="search-outer-wrapper">
			<div id="search-wrapper">
				<xsl:element name="form">
					<xsl:attribute name="name">parts_simple</xsl:attribute>
					<xsl:attribute name="action"><xsl:value-of select="$searchResultsUrl"/></xsl:attribute>
					<xsl:attribute name="method">post</xsl:attribute>
					<div id="search-top-wrapper" class="clearfix">
						<h3>
							<xsl:value-of select="$partsSearchLabel"/>
						</h3>
						<div class="parts-search-toggle" role="button" tabindex="0">
							<span class="visually-hidden">Hide Search Box</span>
						</div>
					</div>
					<div id="search-bottom-wrapper" class="clearfix">
						<xsl:if test="$priceBookEnabled = 'true'">
							<xsl:call-template name="printPriceBook"/>
						</xsl:if>
						<div class="search-element-wrapper">
							<div class="search-input-wrapper">
								<input type="text" name="q" id="simple-search" value="" aria-label="{$partsSearchLabel}"/>
							</div>
							<div class="search-button-wrapper" id="search-button-simple">
								<input type="submit" class="button" value="" name="submitButton" aria-labelledby="simple-search"/>
							</div>
						</div>
					</div>
					<a class="advanced-search" href="{concat($searchResultsUrl, '?mode=advanced')}">
						<xsl:value-of select="//group[@id='parts_advanced_search_group']/@label"/>
					</a>
					<xsl:if test="$enableMultiplePartsBuy = 'true'">
						<a class="multiple-search" href="/commerce/parts/multi_part_search.jsp"><xsl:value-of select="//group[@id='multi_parts_group']//buttons/@label"/></a>
					</xsl:if>
					<input type="hidden" name="companies" value="{//page_data/host_company_id}"/>
					<input type="hidden" name="formaction" value=""/>
					<input type="hidden" name="jump_to_part_detail_if_only_one" value="0"/>
					<input type="hidden" name="_price_book_id" value=""/>
					<input type="hidden" name="targetTab" id="targetTab" value="simple"/>
				</xsl:element>
			</div>

		</div>
		<div id="serial-search-outer-wrapper">
			<div id="serial-search-wrapper">
				<xsl:element name="form">
					<xsl:attribute name="name">serial_number</xsl:attribute>
					<xsl:attribute name="action"><xsl:value-of select="'/commerce/parts/serial_number_search_results.jsp'"/></xsl:attribute>
					<xsl:attribute name="method">post</xsl:attribute>
					<div id="serial-search-top-wrapper" class="clearfix">
						<h3>
							<xsl:value-of select="$serialNumSearchLabel"/>
						</h3>
						<div class="serial-num-search-toggle" role="button" tabindex="0">
							<span class="visually-hidden">Hide Search Box</span>
						</div>
					</div>
					<div id="serial-search-bottom-wrapper" class="clearfix">
						<xsl:if test="$priceBookEnabled = 'true'">
							<xsl:call-template name="printPriceBook"/>
						</xsl:if>
						<div class="search-element-wrapper">
							<div class="search-input-wrapper">
								<input type="text" name="serial_number" value="" id="serial-number" aria-label="{$serialNumSearchLabel}"/>
							</div>
							<div class="search-button-wrapper">
								<input type="submit" class="button" value="" name="serialSubmitButton" aria-labelledby="serial-number"/>
							</div>
						</div>
					</div>
					<input type="hidden" name="companies" value="{//page_data/host_company_id}"/>
				</xsl:element>
			</div>
		</div>
	</xsl:template>
	<!-- ============================= -->
	<!-- Template for Price Book Form  -->
	<!-- ============================= -->
	<xsl:template name="printPriceBook">
		<xsl:variable name="form_node" select="//parts_search_templates/group/form[@id='price_book_form']"/>
		<div id="price-book">
			<!-- if there's only 1 price book available hides the field-->
			<xsl:choose>
				<xsl:when test="count($form_node/attribute/select/option) = 1">
					<!--label for="{$form_node/attribute/select/@name}" class="form-label">
						<xsl:value-of select="$form_node/attribute/@label"/>:</label-->
					<input type="hidden" name="{$form_node/attribute/select/@name}" value="{$form_node/attribute/select/option/@value}"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$form_node/attribute/*"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	<xsl:template match="product_line" mode="HP_GetProductLineSelectorLinks2">
		<xsl:param name="selectorVarName" select="'ignore'"/>
		<xsl:for-each select="punchin_urls/selector/node()/params[@variable_name=$selectorVarName or $selectorVarName='ignore']">
			<xsl:sort order="ascending" data-type="number" select="@order_number"/>
			<xsl:variable name="i" select="@order_number"/>
			<xsl:variable name="pl_search_url" select="../@url"/>
			<xsl:choose>
				<xsl:when test="$userType='FullAccess'">
					<xsl:variable name="final_search_url">
						<xsl:if test="fixed/segment_id">
							<xsl:value-of select="concat($pl_search_url,'?segment_id=',fixed/segment_id,'&amp;')"/>
						</xsl:if>
						<xsl:if test="fixed/pline_id">
							<xsl:value-of select="concat('pline_id=',fixed/pline_id,'&amp;')"/>
						</xsl:if>
						<xsl:if test="user_defined">
							<xsl:value-of select="concat('selector_group=',user_defined/search_group)"/>
						</xsl:if>
						<xsl:if test="string-length(user_defined/_bm_search_flow_config_atts) &gt; 0">
							<xsl:value-of select="'&amp;_bm_search_flow_config_atts='"/>
							<xsl:for-each select="user_defined/_bm_search_flow_config_atts/attribute">
								<xsl:value-of select="concat(@variable_name,'%2B',.)"/>
								<xsl:if test="position() != last()">%2B</xsl:if>
							</xsl:for-each>
						</xsl:if>
						<xsl:if test="user_defined/attribute">
							<xsl:value-of select="'&amp;'"/>
							<xsl:for-each select="user_defined/attribute">
								<xsl:value-of select="concat(@variable_name,'=',.)"/>
								<xsl:if test="position() != last()">&amp;</xsl:if>
							</xsl:for-each>
						</xsl:if>
					</xsl:variable>
					<li class="selector-link">
						<!-- class="hpurl selector" removed this class from the li -->
						<a href="{$final_search_url}">
							<xsl:choose>
								<xsl:when test="name[@isTranslated='Yes']/*[name()=$userLanguageCode]">
									<xsl:value-of select="name/*[name()=$userLanguageCode]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="name"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</li>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="@status!='Internal'">
						<xsl:variable name="final_search_url">
							<xsl:if test="fixed/segment_id">
								<xsl:value-of select="concat($pl_search_url,'?segment_id=',fixed/segment_id,'&amp;')"/>
							</xsl:if>
							<xsl:if test="fixed/pline_id">
								<xsl:value-of select="concat('pline_id=',fixed/pline_id,'&amp;')"/>
							</xsl:if>
							<xsl:if test="user_defined">
								<xsl:value-of select="concat('selector_group=',user_defined/search_group)"/>
							</xsl:if>
							<xsl:if test="string-length(user_defined/_bm_search_flow_config_atts) &gt; 0">
								<xsl:value-of select="'&amp;_bm_search_flow_config_atts='"/>
								<xsl:for-each select="user_defined/_bm_search_flow_config_atts/attribute">
									<xsl:value-of select="concat(@variable_name,'%2B',.)"/>
									<xsl:if test="position() != last()">%2B</xsl:if>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="user_defined/attribute">
								<xsl:value-of select="'&amp;'"/>
								<xsl:for-each select="user_defined/attribute">
									<xsl:value-of select="concat(@variable_name,'=',.)"/>
									<xsl:if test="position() != last()">&amp;</xsl:if>
								</xsl:for-each>
							</xsl:if>
						</xsl:variable>
						<li class="selector-link">
							<a href="{$final_search_url}">
								<xsl:choose>
									<xsl:when test="name[@isTranslated='Yes']/*[name()=$userLanguageCode]">
										<xsl:value-of select="name/*[name()=$userLanguageCode]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="name"/>
									</xsl:otherwise>
								</xsl:choose>
							</a>
						</li>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="product_line" mode="HP_GetAllAssocFiles">
		<xsl:for-each select="//associated_files/associated_file">
			<xsl:variable name="link_value" select="link"/>
			<li class="doc">
				<a href="{$link_value}" target="_blank">
					<xsl:value-of select="readable_name"/>
				</a>
			</li>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
