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

<cffunction access="public" name="loginform">
	<!--- Login Form --->
    <cfset formaction = cgi.script_name>
    <cfif cgi.query_string neq ''>
        <cfset formaction &= '?#cgi.query_string#'>
    </cfif>
    <cfform name="security" method="post" action="#formaction#">
    	<table class="table_none">
        	<tr>
            	<td style="vertical-align:middle; text-align:right;"><strong>Username:</strong></td>
                <td><cfinput name="username" type="Text"></td>
            </tr>
            <tr>
            	<td style="vertical-align:middle; text-align:right;"><strong>Password:</strong></td>
                <td><cfinput name="password" type="password"></td>
            </tr>
            <tr>
            	<td>&nbsp;</td>
                <td><cfinput type="Submit" name="verify" value="Login"></td>
            </tr>
        </table>
    </cfform>
</cffunction>

<!--- If login was successful tell user that the username and password were verified successfully. If not, tell the user their username and/or password was wrong --->
<cfif isDefined("session.verified") and session.verified is true>
	<cfoutput>
        <p id="isloggedin"><strong>Welcome back, #session.user.firstname#!</strong> 
        <cfif isdefined("session.authorization.admin") and isdefined("application.testserver") and cgi.server_name eq application.testserver>
        (<a class="link" onclick="document.getElementById('changeuser').style.display='block';">Change</a>)
        </cfif>
        (<a href="#application.weeding.home#/includes/logout.cfm?redirect=#cgi.script_name#">Logout</a>)
        </p>
        <cfif isdefined("session.authorization.admin") and isdefined("application.testserver") and cgi.server_name eq application.testserver>
        <div id="changeuser" style="display:none;">
        	<cfform name="changeuser_form" method="post" action="">
            	<p>
                	<strong>Change user:</strong> <cfinput name="username" type="Text">
                    <cfinput type="Submit" name="verify" value="Login">
					<input type="button" onclick="document.getElementById('changeuser').style.display='none';" value="Cancel">
                </p>
            </cfform>
        </div>
        </cfif>
    </cfoutput>
<cfelseif isDefined("session.verified") and session.verified is false>
	<cfif isdefined("session.expired")>
        <cfinvoke method="loginform"/>
        <p><strong>Your library account has expired.</strong></p>
        <cfinvoke
        	component="cfc.login"
            method="logout"
        />
    <cfelse>
        <cfinvoke method="loginform"/>
        <p><strong>There was a problem matching your library account with your network account.</strong></p>
        <cfinvoke
        	component="cfc.login"
            method="logout"
        />
    </cfif>
<cfelse>
	<cfif isDefined("session.badpass")>
		<cfinvoke method="loginform">
        <p style="text-align:center;"><span style="font-weight:bold;color:red;">Login incorrect.</span></p>
        <cfset structdelete(session, "badpass")>
    <cfelse>
		<cfinvoke method="loginform">
    </cfif>
</cfif>