<!---
Copyright 2014 Hobart & William Smith Colleges

This file is part of the HWS Weeding Manager.

    HWS Weeding Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

--->
<cfcomponent name="display">

    <cffunction name="display_breadcrumbs" access="public" returntype="any">
        <cfargument name="breadcrumb" required="yes" type="string">
        <cfargument name="breadcrumb_url" required="yes" type="string">

    	<cfoutput>
            <ul id="breadcrumbs_library">
                <li><a href="/">Library Home &gt;</a></li>
                <cfif arguments.breadcrumb neq ''>
					<cfset arguments.breadcrumb = ListToArray(arguments.breadcrumb)>
                    <cfset arguments.breadcrumb_url = ListToArray(arguments.breadcrumb_url)>
                    <cfloop
                        from="1"
                        to="#ArrayLen(arguments.breadcrumb)#"
                        index="i"
                    >
                        <li><a href="#arguments.breadcrumb_url[i]#">#arguments.breadcrumb[i]# &gt;</a></li>
                    </cfloop>
                </cfif>
            </ul>
        </cfoutput>
    </cffunction>

	<cffunction name="display_column2" access="public" returntype="any">
    	<cfargument name="myaccount" type="string" default="yes">
        <cfargument name="nav" type="string" default="yes">
        <cfargument name="services" type="string" default="yes">
        <cfargument name="systems" type="string" default="no">
        <cfargument name="refnotes" type="string" default="no">
		<cfargument name="hours" type="string" default="no">
        <cfargument name="subject_ID" type="numeric" required="no">
        <cfargument name="department_ID" type="numeric" required="no">
        
        <cfoutput>
            <div class="grid_4">
            	<div class="outline">
					<!--- My Account start --->
                    <div id="myaccount">
                        <h3>
                            <cfif isdefined("session.verified") and session.verified is true>
                                <div class="unlocked">
                            <cfelse>
                                <div class="locked">
                            </cfif>
                        My Account</div></h3>
                        <div style="font-size:10px;">
    <!---                    	<p>Renew, Recall, Interlibrary Loan</p> --->
                            <cfinclude template="/includes/login.cfm">
                        </div>
                        <cfif arguments.myaccount eq 'yes'>
                            <cfinclude template="/includes/myaccount.cfm">
                        </cfif>
                    </div>
                    <!--- My Account end --->
                    <!--- Nav start --->
                    <cfif arguments.nav eq 'yes'>
                        <div class="icons">
                            <div class="icon">
                                <a href="/about?search_collections"><img src="/images/search_icon.png"><br/>
                                Search</a>
                            </div>
                            <div class="icon">
                                <a href="/about?research_help"><img src="/images/research_icon.png"><br/>
                                Research</a>
                            </div>
                            <div class="icon">
                                <a href="/services/"><img src="/images/services_icon.png"><br/>
                                Services</a>
                            </div>
        
                            <div class="clear"></div>
        
                            <div class="icon">
                                <a href="/archives/"><img src="/images/archives_icon.png"><br/>
                                Archives</a>
                            </div>
                            <div class="icon">
                                <a href="/about?contact_us"><img src="/images/contact_icon.png"><br/>
                                Contact</a>
                            </div>
                            <div class="icon">
                                <a href="/about?hours"><img src="/images/hours_icon.png"><br/>
                                Hours</a>
                            </div>
<!---
                            <div class="icon">
                                <a href="/"><img src="/images/home_icon.png"><br/>
                                Home</a>
                            </div>
--->
                            
                            <div class="clear"></div>
                        </div>
                        <div id="lib_quicklinks">
                            <select onchange="window.location.href=this.value;">
                                <option value="">Quicklinks</option>
                                <option value="/">Library Home Page</option>
                                <option value="http://hws.summon.serialssolutions.com">Search Almost Everything</option>
                                <option value="/ill/">Interlibrary Loan</option>
                                <option value="http://voyager.hws.edu/vwebv/enterCourseReserve.do">Course Reserves</option>
                                <option value="http://voyager.hws.edu">Library Catalog</option>
                                <option value="http://hws.worldcat.org">WorldCat</option>
                                <option value="/about/?room_reservations">Reserve a Study Room</option>
                                <option value="/about/">About Us</option>
                                <option value="/forms/contact.cfm">Contact Us</option>
                            </select>
                        </div>
                        
                    </cfif>
                    <!--- Nav end --->
                    <div class="clear"></div>
                </div>
                <cfif arguments.services eq 'yes'>
                    <div id="research_services" class="outline">
						<cfif left(cgi.SCRIPT_NAME, 9) eq '/archives'>
                            <h3>Archives Services</h3>
                        <cfelse>
                            <h3>Research Services</h3>
                        </cfif>
                        <div>
                            <cfinclude template="/includes/chat.cfm">
                        </div>
                    </div>
                </cfif>
                
                <cfif arguments.refnotes eq 'yes'>
                	<div id="reference_notes" class="outline">
	                    <cfinclude template="/staff/admin/reference/recent_notes.cfm">
                    </div>
                </cfif>

				<!--- Hours start --->
                <cfif arguments.hours eq 'yes'>
                    <div id="hours" class="main_box withicon">
                        <h2><a href="/about?hours">Hours</a></h2>
                        <div class="header_icon"><a href="/about?hours"><img src="/images/hours_icon.png"></a></div>
                        <div class="clear"></div>
                        <cfinvoke
                            component="#application.miscellaneous.cfc#"
                            method="get_hours"
                            entries="1"
                            returnvariable="hours"
                        />
                        <cfset refhours = application.ref.hours['#DayOfWeek(Now())-1#']>
                        <cfset archhours = application.archives.hours['#DayOfWeek(Now())-1#']>
						<cfif left(cgi.SCRIPT_NAME, 9) eq '/archives'>
                            <cfif hours[1].hours neq 'Library closed'>
                                <p><strong>Archives:</strong> #archhours#</p>
                                <p><strong>Library:</strong> #hours[1].hours#</p>
                                <p><strong>Research desk:</strong> #refhours#</p>
                            <cfelse>
                                <p><strong>Archives:</strong> Closed</p>
                                <p><strong>Library:</strong> #hours[1].hours#</p>
                                <p><strong>Research desk:</strong> Closed</p>
                            </cfif>
                            <p><a href="/about?hours">More hours</a></p>
                        <cfelse>
                            <p><strong>Library:</strong> #hours[1].hours#</p>
                            <cfif hours[1].hours neq 'Library closed'>
                                <p><strong>Research desk:</strong> #refhours#</p>
                                <p><strong>Archives:</strong> #archhours#</p>
                            <cfelse>
                                <p><strong>Research desk:</strong> Closed</p>
                                <p><strong>Archives:</strong> Closed</p>
                            </cfif>
                            <p><a href="/about?hours">More hours</a></p>
                        </cfif>

                        <cfinclude template="/archives/includes/alerts.cfm">
                    </div>
                </cfif>
                <!--- Hours end --->
                
                <!--- Systems chat widget start --->
                <cfif isdefined("arguments.systems") and arguments.systems eq 'yes'>
                    <div jid='hws-systems@chat.libraryh3lp.com' class='libraryh3lp'><iframe src='https://libraryh3lp.com/chat/hws-systems@chat.libraryh3lp.com?skin=21974&amp;identity=librarian' frameborder='1' style='width: 216px; height: 320px; border: 2px inset black;'></iframe></div>
                </cfif>
                <!--- Systems chat widget end   --->
                
                <!--- Liaison start --->
                <cfif isdefined("arguments.subject_ID")>
                    <cfinvoke
                        component="#application.databases.cfc#"
                        method="get_liaisons"
                        subject_ID="#arguments.subject_ID#"
                        returnvariable="liaisons"
                    />
                <cfelseif isdefined("arguments.department_ID")>
                    <cfinvoke
                        component="#application.miscellaneous.cfc#"
                        method="get_liaisons_by_deptid"
                        deptid="#arguments.department_ID#"
                        returnvariable="liaisons"
                    />
                    <cfinvoke
                    	component="#application.miscellaneous.cfc#"
                        method="get_department_name"
                        dept_ID="#arguments.department_ID#"
                        returnvariable="department_name"
                    />
                </cfif>
                
    			<cfif isdefined("liaisons") and isdefined("liaisons.recordcount") and liaisons.recordcount gt 0>
                    <div id="liaisons" class="main_box">
                    	<cfif isdefined("department_name") and department_name neq 'Unknown department'>
                        	<cfif len(department_name) gt 15>
		                        <h2 class="twolines">#department_name# Liaison</h2>
                            <cfelse>
		                        <h2>#department_name# Liaison</h2>
                            </cfif>
                        <cfelse>
	                        <h2>Liaison</h2>
                        </cfif>
                        <div class="clear"></div>
        
                        <table class="table_none">
                            <cfloop query="liaisons">
                                <tr>
                                    <td>
                                        <p><strong>#liaisons.firstname# #liaisons.lastname#</strong></p>
                                        <cfif liaisons.email neq ''>
                                            <p><a href="/forms/contact.cfm?who=#liaisons.ID#">E-mail</a></p>
                                        </cfif>
                                        <cfif liaisons.phone neq ''>
                                            <p><strong>Ph:</strong> #liaisons.phone#</p>
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif liaisons.image_url neq ''>
                                            <img src="#liaisons.image_url#" width="100" style="border:0 20px 0 20px;"/>
                                        </cfif>
                                    </td>
                                </tr>
                            </cfloop>
                        </table>
                    </div>
                </cfif>
                <!--- Liaison end --->
            </div>
        </cfoutput>
    </cffunction>

    <cffunction name="display_footer" access="public" returntype="any">
    	<cfargument name="analytics" type="string">
        
        <cfif not(isdefined("arguments.analytics"))>
        	<cfif
				left(cgi.SCRIPT_NAME, 6) eq '/staff'
				OR left(cgi.SCRIPT_NAME, 6) eq '/forms'
				OR left(cgi.SCRIPT_NAME, 8) eq '/reports'
			>
            	<cfset arguments.analytics = 'no'>
            <cfelse>
            	<cfset arguments.analytics = 'yes'>
            </cfif>
        </cfif>
        
        <cfoutput>
        <div id="clearone">&nbsp;</div>
	</div> <!-- closing tag for main_one -->
	<div id="footer">
        <div id="footertop">
            <ul>
    
            <li><a href="http://www.hws.edu/">Home</a></li>
            <li><a href="http://www.hws.edu/search.aspx">Search</a></li>
            <!-- <li><a href="">Ask HWS</a></li> -->
            <li><a href="http://www.hws.edu/offices/">Offices and Resources</a></li>
            <li><a href="http://www.hws.edu/sitemap.aspx">Site Map A-Z</a></li>
            <li><a href="http://www.hws.edu/offices/email.aspx">Campus Directory</a></li>
    
            <li><a href="http://webmail.hws.edu/">Webmail</a></li>
            <li><a href="http://www.hws.edu/contact.aspx">Contact the Colleges</a></li>
            </ul>
        </div>
        <div id="footerbottom">
            <ul>
            <li>&copy; 2007-2014 Hobart and William Smith Colleges, Geneva, NY 14456 (315) 781-3000</li>
    
            <li><a href="http://www.hws.edu/about/campus_maps.aspx">Map/Directions</a></li>
            <li><a href="http://www.hws.edu/about/diversity.aspx">Diversity Statement</a></li>
            <li><a href="http://www.hws.edu/ada.aspx">ADA Compliance</a></li>
            <li><a href="http://www.hws.edu/privacy.aspx">Privacy Policy applicable to this site.</a></li>
            </ul>
        </div>

	    <div id="tagline">
			<em>Worlds of Experience, Lives of Consequence</em>
		</div>
	</div>
</div> <!-- closing tag for div id="body" -->
<cfif arguments.analytics eq "yes">
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-3248096-4");
pageTracker._trackPageview();
} catch(err) {}</script>
</cfif>
		</cfoutput>
    </cffunction>
    
    <cffunction name="display_header" access="remote" returntype="any">
    	<cfargument name="title" required="yes" type="string">
        <cfargument name="jquery" required="no" default="yes" type="string">
        <cfargument name="jqueryui" required="no" default="" type="string">
        <cfargument name="sorttable" required="no" default="" type="string">
        <cfargument name="tabber" required="no" default="" type="string">
        <cfargument name="nofollow" required="no" default="" type="string">
        <cfargument name="print_css" required="no" default="" type="string">
        <cfargument name="custom_css" required="no" default="" type="string">
        <cfargument name="css_url" required="no" default="" type="string">
        <cfargument name="charset" required="no" default="iso-8859-1" type="string">
        
		<cfif isdefined("session.verified")>
            <cfset verified=session.verified>
        </cfif>
        <cfif isdefined("session.user")>
            <cfset user=session.user>
        </cfif>
        <cfif isdefined("session.authorization")>
            <cfset authorization=session.authorization>
        </cfif>
        
        <cfif structKeyExists(form,"verify")>
            <cfset user = {}>
            
            <cfif isdefined("session.authorization.admin") and cgi.server_name eq application.testserver and not(isdefined("form.password"))>
                <cfinvoke
                    component="#application.login.cfc#"
                    method="logout"
                />
                <cfset variables.verify = true>
            <cfelse>
                <cfinvoke
                    component="#application.login.cfc#" 
                    method="ldap"
                    returnVariable="verify"
                >
                    <cfinvokeargument name="username" value="#form.username#">
                    <cfinvokeargument name="password" value="#form.password#">
                </cfinvoke>
            </cfif>
            
            <cfif variables.verify eq true>
                <cfif lcase(form.username) eq 'lrguest'>
                    <cfset user.firstname = 'Guest'>
                    <cfset user.lastname  = ''>
                    <cfset user.email_address = 'library@hws.edu'>
                    <cfset user.iid = 0>
                <cfelse>
                    <!--- LDAP passed: retrieve patron info from Voyager --->
                    <cfinvoke
                        component="#application.voyager.cfc#"
                        method="get_patron"
                        returnvariable="user"
                        expired="no"
                    >
                        <cfinvokeargument name="username" value="#form.username#">
                    </cfinvoke>
                </cfif>
                <cfif not(isdefined("nocookie"))>
                    <cfset session.user = user>
                </cfif>
                
                <cfif isdefined("user.expired") or not(isdefined("user.iid"))>
					<cfset verified = false>
                    <cfinvoke
                        component="#application.voyager.cfc#"
                        method="get_patron"
                        returnvariable="user"
                        expired="yes"
                    >
                        <cfinvokeargument name="username" value="#form.username#">
                    </cfinvoke>
                    <cfif isdefined("user.expired")>
                        <cfset session.expired = true>
                        <cfset structdelete(session,"user")>
                    </cfif>
                <cfelseif isdefined("user.iid")>
                    <cfset verified = true>
					<cfset session.user.username = form.username>
                    <cfif isdefined("form.password")>
                        <cfset session.user.password = form.password>
                    </cfif>
                    
                    <!--- determine staff permission level, if any --->
                    <cfset alias = "hwsmicro\" & REReplace(lcase(user.email_address), "@hws.edu", "", "all")>
                    <cfinvoke
                        component="#application.authorization.cfc#"
                        method="get_authorization"
                        network_ID="#alias#"
                        returnvariable="authorization"
                    />
                    <cfif not(isdefined("nocookie"))>
                        <cfset session.authorization = authorization>
                    </cfif>
                <cfelse>
                    <cfset verified = false>
                </cfif>
        
                <cfif not(isdefined("nocookie"))>
                    <cfset session.verified = verified>
                </cfif>
            <cfelse>
            	<cfset session.badpass = true>
            </cfif>
        </cfif>

        <cfoutput>
<cfcontent reset="yes"><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=#arguments.charset#" />
    <meta name="verify-v1" content="lw1uEQjBMAUWdY0KZIowKYtP62uSlPTPyuhLn6ZMF1Q=" />
    <cfif arguments.nofollow eq 'yes'>
	    <META NAME="ROBOTS" CONTENT="NOINDEX, NOFOLLOW"/>
    </cfif>
    <link rel="alternate" type="application/atom+xml" title="HWS Library Updates - Atom" href="http://hwslibrary.blogspot.com/feeds/posts/default" />
    <link rel="service.post" type="application/atom+xml" title="HWS Library Updates - Atom" href="http://www.blogger.com/feeds/6569047220556642304/posts/default" />
    <link rel="shortcut icon" href="http://library.hws.edu/favicon.ico"/>
    <cfif arguments.title eq ''>
	    <title>Warren Hunting Smith Library</title>
    <cfelse>
	    <title>#arguments.title# -- Warren Hunting Smith Library</title>
    </cfif>
    
    <link href="https://www.hws.edu/main.css" rel="stylesheet" type="text/css" />
    <link href="/css/library.css?ver=20130827" rel="stylesheet" type="text/css"/>
    <link href="/css/960.css" rel="stylesheet" type="text/css"/>
    <cfif arguments.jqueryui eq 'yes'>
        <link href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
    </cfif>
    <cfif arguments.custom_css neq ''>
    	<style type="text/css">
			#arguments.custom_css#
		</style>
    </cfif>
    <cfif arguments.css_url neq ''>
    	<cfloop index="this_url" list="#arguments.css_url#" delimiters=",">
        	<link href="#this_url#" rel="stylesheet" type="text/css"/>
        </cfloop>
    </cfif>
    <cfif arguments.print_css eq 'yes'>
		<style type="text/css" media="print">
            body {
                background: white;
                font-size: 12pt;
                font-family: Georgia, 'Times New Roman', Times, serif;
            }
            a:link, a:visited {
                text-decoration: none;
            }
            table {
                border-spacing: 0;
                page-break-inside: avoid;
            }
            td {
                padding: 5px 0 5px 10px;
                margin: 0;
                border: 1px solid black;
            }
            .print_suppress {
                display:none;
            }
            .print_title {
                margin-left:auto;
                margin-right:auto;
            }
            .print_title h2 {
                color:black;
                font-size: 20px;
                text-transform:none;
            }
            h3 {
                color:black;
                font-size: 18px;
            }
            ##breadcrumbs_library li, ##breadcrumbs_library li a {
                font-size: 11px;
            }
        </style>
    </cfif>
    
	<script type="text/javascript" src="https://www.hws.edu/LMScript.js"></script> <!--- required for quicklinks --->
    <script type="text/javascript" src="/scripts/common.js?version=20130722"></script>
    <cfif arguments.tabber eq 'yes'>
		<script type="text/javascript" src="/scripts/tabber.js"></script>
		<script type="text/javascript"><!--//--><![CDATA[//><!--
 
/* Optional: Temporarily hide the "tabber" class so it does not "flash"
   on the page as plain HTML. After tabber runs, the class is changed
   to "tabberlive" and it will appear. */

str = "<style type='text/css'>.tabber{display:none;}</style>";
document.write(str);
//--><!]]></script> 
    </cfif>
    <cfif arguments.sorttable eq 'yes'>
		<script type="text/javascript" src="/scripts/sorttable.js"></script>
    </cfif>
    <cfif arguments.jquery eq 'yes'>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.js"></script>
    </cfif>
    <cfif arguments.jqueryui eq 'yes'>
        <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/jquery-ui.min.js"></script>
    </cfif>
</head>

        </cfoutput>
    </cffunction>
    
	<cffunction name="display_pager" returntype="any">
    	<cfargument name="records" type="numeric" required="yes">
        <cfargument name="offset" type="numeric" required="no" default="0">
        <cfargument name="page_size" type="numeric" required="no" default="25">
        
		<cfset page_count = ceiling(arguments.records/arguments.page_size)>

        <cfoutput>
            <p>
            	<cfif arguments.records gt arguments.page_size>
                    <strong>Go to page:</strong>
                    <cfloop from="1" to="#page_count#" index="i">
                        <cfset this_offset = (i-1) * arguments.page_size>
                        <cfif arguments.offset eq this_offset>
                            <strong>#i#</strong>
                            <cfset dots = false>
                        <cfelseif
                            abs(arguments.offset - this_offset) lte page_size*3
                            or i eq 1
                            or i eq page_count
                        >
                            <a href="?#REReplace(cgi.query_string,"&?offset=[0-9]*", "")#&offset=#this_offset#">#i#</a>
                            <cfset dots = false>
                        <cfelse>
                            <cfif isdefined("dots") and dots neq true>
                                ...
                                <cfset dots = true>
                            </cfif>
                        </cfif>
                    </cfloop>
                (results per page: <select onchange="window.location.href='?#REReplace(cgi.query_string,"&?page_size=[0-9]*", "")#&page_size='+this.value;">
                    <cfloop list="10,25,50,100" index="i">
                        <cfif i eq arguments.page_size>
                            <option value="#i#" selected="selected">#i#</option>
                        <cfelse>
                            <option value="#i#">#i#</option>
                        </cfif>
                    </cfloop>
                </select>)
				<cfelse>
                    Results per page: <select onchange="window.location.href='?#REReplace(cgi.query_string,"&?page_size=[0-9]*", "")#&page_size='+this.value;">
                        <cfloop list="10,25,50,100" index="i">
                            <cfif i eq arguments.page_size>
                                <option value="#i#" selected="selected">#i#</option>
                            <cfelse>
                                <option value="#i#">#i#</option>
                            </cfif>
                        </cfloop>
                    </select>
                </cfif>
            </p>
        </cfoutput>
    </cffunction>

</cfcomponent>