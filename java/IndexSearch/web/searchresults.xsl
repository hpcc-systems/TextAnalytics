<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

<!--	<xsl:param name="errors" select="//Dataset[@name='Matching_Records']/@errors" />
	<xsl:param name="errors2" select="//Error_Message[1]" />
	<xsl:param name="warnings"
		select="//Dataset[@name='Matching_Records']/@warnings" />
		-->
	<xsl:param name="groups"
		select="//Dataset[@name='Matching_Records']/Row[count(//Dataset/Row)]/group_id" />
	
	<xsl:output doctype-public="-//W3C//DTD HTML 4.0//EN" />

	<xsl:template match="/">
		<html>
			<head>				
        <link rel="stylesheet" href="/circuits/css/cdce.css" />
	
			</head>
			<body>
<br/>				<xsl:variable name="distinctrecords"
					select="//Dataset[@name='Matching_Records']/Row[not(./group_id=preceding-sibling::Row/group_id)]/group_id" />


<!--				<xsl:if test="$errors != '' ">
					<b>
						<i>Error</i>
						:
					</b>
					<xsl:value-of select="$errors" />
				</xsl:if>
				<xsl:if test="$errors2 != '' ">
					<xsl:value-of select="$errors2" />
				</xsl:if>
				<xsl:if test="$warnings != ''">
					<b>
						<i>Warning</i>
						:
					</b>
					<xsl:value-of select="$warnings" />
				</xsl:if>
-->
					<xsl:for-each select="$distinctrecords">
						<xsl:variable name="thisgroup" select="." />
						<xsl:variable name="records"
							select="//Dataset[@name='Matching_Records']/Row[group_id=$thisgroup]" />

            <xsl:variable name="rownum" select="."/>

            <xsl:variable name="rowclass">
              <xsl:choose>
                <xsl:when test="$rownum mod 2 = 1">searchresultsrowodd</xsl:when>
                <xsl:otherwise>searchresultsroweven</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            
            <table id="searchResultsTblAlt" border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-bottom:15px">
              <xsl:element name="tr">
                <xsl:attribute name="valign">top</xsl:attribute>
                <xsl:attribute name="class"><xsl:value-of select="$rowclass"/></xsl:attribute>
                <td width="5%" style="padding-top: 5px; padding-left: 2px; padding-right: 2px;">
                  <xsl:value-of select="$rownum" />
                </td>
                <td class="smallfont2" width="50%" style="padding-top: 5px;">
                  <table>
                    <xsl:for-each select="$records">
                      <xsl:variable name="ctype">
                        <xsl:choose>
                        <xsl:when test="field_label != ''"><xsl:value-of select="field_label"/></xsl:when>
                        <xsl:when test="entity_label='unformattedString'">
                          
                        </xsl:when>
                        <xsl:when test="entity_label=''">
                          
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="entity_label" />:
                        </xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>
   				 <xsl:variable name="unescapedov">
					<xsl:call-template name="unescapetext">
                		<xsl:with-param name="escapedtext" select="original_value"/>
           			 </xsl:call-template>
				</xsl:variable> 
            

 <xsl:variable name="unescapedsv">
				<xsl:call-template name="unescapetext">
                	<xsl:with-param name="escapedtext" select="searchable_value"/>
           		 </xsl:call-template>
				</xsl:variable> 

                      <tr>
                        <td width="110" class="smallfont1" valign="top">
                          <b>
                          <xsl:element name="a">
                          <xsl:attribute name="title">Field Type:<xsl:value-of select="entity_label"  disable-output-escaping="yes" />
                          </xsl:attribute>
                            <xsl:value-of select="$ctype" />
                            </xsl:element>
                          </b>
                        </td>
                          <td class="smallfont1" valign="top">                           
                            <xsl:value-of select="$unescapedov"  disable-output-escaping="yes"/>
                            <xsl:if test="original_value != searchable_value">
                              (Normalized: <xsl:value-of select="$unescapedsv"  disable-output-escaping="yes" /> )
                            </xsl:if>
                          </td>
                        </tr>
                    </xsl:for-each>
                  </table>
                </td>

                <td class="smallfont1" width="15%" align="left" rowspan="1" valign="top" nowrap="" style="padding-top: 5px;">
                </td>

                <td class="smallfont2" valign="top" width="15%"  nowrap="" style="padding-top: 5px; padding-right: 2px;padding-bottom: 

10px;">

                </td>

              </xsl:element>
            </table>

					</xsl:for-each>


					<xsl:for-each select="//Dataset/NoResults">
						<tr>
							<td colspan="5">
								<xsl:value-of select="." />
							</td>
						</tr>
					</xsl:for-each>

				

				<br />
			</body>
		</html>
	</xsl:template>

    <xsl:template name="unescapetext">
        <xsl:param name="escapedtext"/>
        <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text">
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text">
                        <xsl:call-template name="string-replace-all">
                            <xsl:with-param name="text" select="$escapedtext"/>
                            <xsl:with-param name="replace">&amp;gt;</xsl:with-param>
                            <xsl:with-param name="by">&gt;</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="replace">&amp;lt;</xsl:with-param>
                    <xsl:with-param name="by">&lt;</xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="replace">&amp;amp;</xsl:with-param>
            <xsl:with-param name="by">&amp;</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- replaces substrings in strings -->
    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- returns the substring after the last delimiter -->
    <xsl:template name="skipper-after">
        <xsl:param name="source"/>
        <xsl:param name="delimiter"/>
        <xsl:choose>
            <xsl:when test="contains($source,$delimiter)">
                <xsl:call-template name="skipper-after">
                    <xsl:with-param name="source" select="substring-after($source,$delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$source"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- returns the substring before the last delimiter -->
    <xsl:template name="skipper-before">
        <xsl:param name="source"/>
        <xsl:param name="delimiter"/>
        <xsl:param name="result"/>
        <xsl:choose>
            <xsl:when test="contains($source,$delimiter)">
                <xsl:call-template name="skipper-before">
                    <xsl:with-param name="source" select="substring-after($source,$delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                    <xsl:with-param name="result">
                        <xsl:if test="result!=''">
                            <xsl:value-of select="concat($result,$delimiter)"/>
                        </xsl:if>
                        <xsl:value-of select="substring-before($source,$delimiter)"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$result"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
  <xsl:template match="original_value">
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>