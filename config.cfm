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

<!--- After creating a regular user with admin privileges, comment this out to disable --->
<cfset application.adminpw = 'vA/echuZU7hE$'>

<cfset application.weeding.home = "/hws-weeding">

<cfif not(isdefined("application.authorization.cfc"))>
    <cfset application.authorization.cfc = "hws-weeding.cfc.authorization">
</cfif>
<cfif not(isdefined("application.conspectus.cfc"))>
    <cfset application.conspectus.cfc = "hws-weeding.cfc.conspectus">
</cfif>
<cfif not(isdefined("application.display.cfc"))>
    <cfset application.display.cfc = "hws-weeding.cfc.display">
</cfif>
<cfif not(isdefined("application.login.cfc"))>
    <cfset application.login.cfc = "hws-weeding.cfc.login">
</cfif>
<cfif not(isdefined("application.miscellaneous.cfc"))>
    <cfset application.miscellaneous.cfc = "hws-weeding.cfc.miscellaneous">
</cfif>
<cfif not(isdefined("application.voyager.cfc"))>
    <cfset application.voyager.cfc = "hws-weeding.cfc.voyager">
</cfif>
<cfif not(isdefined("application.weeding.cfc"))>
    <cfset application.weeding.cfc = "hws-weeding.cfc.weeding">
</cfif>
<cfif not(isdefined("application.opac"))>
    <cfset application.opac = "voyager.hws.edu">
</cfif>
<cfif not(isdefined("application.dsn.library"))>
    <cfset application.dsn.library = "library">
</cfif>
<cfif not(isdefined("application.dsn.library_rw"))>
    <cfset application.dsn.library_rw = "library_rw">
</cfif>
<cfif not(isdefined("application.dsn.voyager"))>
    <cfset application.dsn.voyager = "voyager">
</cfif>
<cfif not(isdefined("application.barcodelength"))>
    <cfset application.barcodelength = "14">
</cfif>

 <cffunction name="isLoggedIn">
    <!--- DEBUG: bypass login --->
    <cfreturn 'yes'>

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
