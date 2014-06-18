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
<cfset title = "Weeding">
<cfinclude template = "config.cfm">
<html>
<head>
    <cfinclude template = "#application.weeding.home#/includes/header.cfm">
</head>
<body>

<div id="body">
	<div id="main">
		<div class="container_16">
			<div class="grid_12">
                <cfinvoke
                    component="#application.display.cfc#"
                    method="display_breadcrumbs"
                    breadcrumb="Weeding Home"
                    breadcrumb_url="#application.weeding.home#"
                />
                <cftry>
                    <cfoutput>
                        <h2>#title#</h2>
                        <cfif not(isdefined("session.verified"))>
                            <cfthrow
                                message="Please log in."
                            />
                        </cfif>
                        
                        <cfif session.authorization.authorized neq 'yes'>
                            <cfthrow 
                                type="Not authorized"
                                detail="You are not authorized to use this page.">
                        </cfif>
                        <p><a href="libstaff">Library staff portal</a></p>
                        <p><a href="faculty">Faculty portal</a></p>
                        <p><a href="admin">Admin portal</a></p>
                        
                     </cfoutput>
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
            <div class="grid_4">
                <div style="font-size:10px;">
                    <cfinclude template="#application.weeding.home#/includes/login.cfm">
                </div>
            </div>
            <div class="clear"></div>
        <!--- content end   --->
        </div>
    </div>
</div>
</body>
</html>