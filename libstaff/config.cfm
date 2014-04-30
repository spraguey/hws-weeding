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

<cfif not(isdefined("application.authorization.cfc"))>
    <cfset application.authorization.cfc = "cfc.authorization">
</cfif>
<cfif not(isdefined("application.conspectus.cfc"))>
    <cfset application.conspectus.cfc = "/conspectus">
</cfif>
<cfif not(isdefined("application.display.cfc"))>
    <cfset application.display.cfc = "cfc.display">
</cfif>
<cfif not(isdefined("application.miscellaneous.cfc"))>
    <cfset application.miscellaneous.cfc = "cfc.miscellaneous">
</cfif>
<cfif not(isdefined("application.voyager.cfc"))>
    <cfset application.voyager.cfc = "cfc.voyager">
</cfif>
<cfif not(isdefined("application.weeding.cfc"))>
    <cfset application.weeding.cfc = "cfc.weeding">
</cfif>
<cfif not(isdefined("application.opac"))>
    <cfset application.opac = "voyager.hws.edu">
</cfif>

 <cffunction name="isLoggedIn">
	<cfif isdefined("session.verified")>
        <cfreturn 'yes'>
    <cfelse>
        <cfreturn 'no'>
    </cfif>
 </cffunction>
 
 <cffunction name="isAuthorized">
    <cfargument name="authtype" type="string" required="no">

    <!--- admin is always authorized --->
    <cfif isdefined("session.authorization.admin")>
        <cfreturn 'yes'>
    </cfif>

    <!--- liaison, cataloging, or archives is required otherwise --->
 	<cfif not(isdefined("session.authorization.liaison") or isdefined("session.authorization.cataloging") or isdefined("session.authorization.archives"))>
        <cfreturn 'no'>
    </cfif>
    
    <cfif isdefined("arguments.authtype")>
        <!--- specific authtype; non-admin must check for specific permission --->
        <cfif arguments.authtype eq 'archives'>
            <cfif isdefined("session.authorization.archives")>
                <cfreturn 'yes'>
            <cfelse>
                <cfreturn 'no'>
            </cfif>
        </cfif>
        <cfif arguments.authtype eq 'cataloging'>
            <cfif isdefined("session.authorization.cataloging")>
                <cfreturn 'yes'>
            <cfelse>
                <cfreturn 'no'>
            </cfif>
        </cfif>
        <cfif arguments.authtype eq 'liaison'>
            <cfif isdefined("session.authorization.liaison")>
                <cfreturn 'yes'>
            <cfelse>
                <cfreturn 'no'>
            </cfif>
        </cfif>
        <cfif arguments.authtype eq 'admin'>
            <!--- admin will have already returned 'yes'; this allows us to get a negative result for non-admin if needed --->
            <cfreturn 'no'>
        </cfif>
    <cfelse>
        <!--- liaison or cataloging; not asking for specific permission --->
        <cfreturn 'yes'>
    </cfif>
</cffunction>