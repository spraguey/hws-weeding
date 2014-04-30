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

<cfcomponent name="authorization">
    <cffunction name="get_authorization" access="public" returntype="struct">
        <cfargument name="network_ID" type="string" required="no">
        <cfargument name="librarian_ID" type="numeric" required="no">
        <cftry>
			<cfif not(isdefined("arguments.network_ID") OR isdefined("arguments.librarian_ID"))>
                <cfthrow
                	type="ID not specified">
            </cfif>
            
            <cfinvoke
            	method="get_user_permissions"
                returnvariable="permissions"
            >
				<cfif isdefined("arguments.network_ID")>
                    <cfinvokeargument name="network_ID" value="#arguments.network_ID#">
                <cfelse>
                    <cfinvokeargument name="librarian_ID" value="#arguments.librarian_ID#">
                </cfif>
            </cfinvoke>

            <cfset newAuthorization = {}>
            <cfif permissions.recordcount eq 0>
            	<cfthrow
                	type="Not found">
            <cfelse>
                <cfif permissions.expired eq 'yes'>
                    <cfset newAuthorization.expired = "yes">
                    <cfset newAuthorization.authorized = "no">
                <cfelse>
                    <cfset newAuthorization.authorized = "yes">
                </cfif>
                <cfset newAuthorization.userid = permissions.ID>
                <cfset newAuthorization.lastname = permissions.lastname>
                <cfset newAuthorization.firstname = permissions.firstname>
                <cfset newAuthorization.iid = permissions.cwid>
                <cfif newAuthorization.authorized eq "no">
                	<cfreturn newAuthorization>
                </cfif>
                <cfif permissions.role eq "admin">
                    <cfset newAuthorization.admin = "yes">
                <cfelse>
                    <cfloop query="permissions">
                        <cfif permissions.permission_name neq ''>
								<cfset newAuthorization[permissions.permission_name] = 'yes'>
                        </cfif>
                    </cfloop>
                </cfif>
            </cfif>
            <cfreturn newAuthorization>
            <cfcatch>
            	<cfset tmp = {}>
            	<cfset tmp.authorized = "no">
                <cfset tmp.reason = cfcatch.type>
                <cfset tmp.cfcatch = cfcatch>
                <cfreturn tmp>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="get_user" access="public" returntype="any">
    	<cfargument name="userid" type="numeric" required="no">
        <cfargument name="expired" type="string" default="no" required="no">
		<cfquery name="user" datasource="library">
        	SELECT
            	l.ID,
                l.firstname,
                l.lastname,
                l.alias,
                l.role,
                l.image_url,
                l.email,
                l.phone,
                l.library_department_ID,
                ld.name "library_department",
                l.title,
                l.directory_order,
                l.cwid,
                l.nomail,
                l.expired
            FROM
            	librarians l LEFT JOIN library_department ld ON l.library_department_ID = ld.ID
            WHERE
            	1=1
                <cfif arguments.expired eq "no">
                	AND l.expired IS NULL
                <cfelseif arguments.expired eq "yes">
                	AND l.expired = 'yes'
                </cfif>
				<cfif isdefined("arguments.userid")>
                    AND l.ID = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
            </cfif>
            ORDER BY
            	l.lastname,
                l.firstname
        </cfquery>
        <cfreturn user>
    </cffunction>
</cfcomponent>