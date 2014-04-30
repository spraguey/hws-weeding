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
<cfsetting requesttimeout="3000">
<cfparam name="url.view" default="">
<cfsilent>
	<cfset title = "Weeding Manager">
    <cfinclude template = "config.cfm">
</cfsilent>
<cfinvoke
	component="#application.display.cfc#"
    method="display_header"
    title="#title#"
    jqueryui="yes"
    nofollow="yes"
    custom_css=".newItem {width: 500px; border: 1px solid black;}"
/>
<body>
<cfinclude template="/includes/header.cfm">

<div id="body">
	<div id="main">
		<div class="container_16">
            <div class="grid_16">
            	<cfinvoke
                	component="#application.display.cfc#"
                    method="display_breadcrumbs"
                    breadcrumb="Staff Tools,#title#"
                    breadcrumb_url="/staff/,#cgi.SCRIPT_NAME#"
                />
            </div>
			<div class="grid_12">
                <cftry>
                	<cfif ListContains('manage,upload', url.view) neq 0>
						<cfinclude template="#url.view#.cfm">
                    <cfelse>
						<cfinclude template="dashboard.cfm">
                    </cfif>
                    <cfcatch>
                        <cfoutput>
                            <cfif cfcatch.type neq 'Application'>
                                <p>
                                    <strong>#cfcatch.type#</strong>
                                    <cfif isdefined("url.errordetail")>
                                        at line #cfcatch.tagcontext[1].line#
                                    </cfif>
                                </p>
                            </cfif>
                            <p>#cfcatch.message#</p>
                            <p>#cfcatch.detail#</p>
                        </cfoutput>
                    </cfcatch>
                </cftry>
            </div>
			<cfinvoke
            	component="#application.display.cfc#"
                method="display_column2"
                    services="no"
                    nav="no"
            />
            <div class="clear"></div>
		<!--- content end   --->
		</div>
    <cfinvoke
        component="#application.display.cfc#"
        method="display_footer"
    />
</body>
</html>