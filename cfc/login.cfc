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

<cfcomponent name="LoginCFC">
    <cffunction name="ldap" access="public">
    	<cfargument name="username" required="yes" type="string">
        <cfargument name="password" required="yes" type="string">
        
		<cfset baseDomain = '@hws.edu'> 
        <cfset domainController = 'dc4.hws.edu'>

        <cftry>
            <cfldap action="Query"
                name="ADResult"
                attributes="cn,mail,displayname,dn,memberof,extensionAttribute1,employeeID,
                sAMAccountName"
                start="cn=users,dc=hws,dc=edu"
                filter="(&(objectclass=user)(samaccountname=#arguments.username#))"
                server="#domainController#"
                scope = "subtree"
                username="#arguments.username & baseDomain#"
                password="#arguments.password#"
            >
            <cfreturn true>
        
            <cfcatch>
            	<cfreturn false>
            </cfcatch>
        </cftry>
    </cffunction>

	<cffunction access="public" name="logout" returntype="void">
        <cfloop collection="#session#" item="var">
            <cfif var neq "sessionid" and var neq "urltoken">
                <cfset structdelete(session,var)>
            </cfif>
        </cfloop>
    </cffunction>

    <cffunction access="public" name="verifyUser">
        <!--- make sure username and password are required --->
        <cfargument name="getID" type="string" required="yes">
        <cfargument name="getEmail" type="string" required="yes">
        <cfargument name="IDtype" type="string" required="yes">
        
        <cfif IDtype eq "cwid">
			<!--- query the database for the username and password that were passed --->
            <cfquery name="verifyusername" datasource="#application.dsn.voyager#">
                SELECT
                    PATRON.INSTITUTION_ID,
                    PATRON.FIRST_NAME,
                    PATRON.LAST_NAME,
                    PATRON_ADDRESS.ADDRESS_LINE1,
                    PATRON_GROUP.PATRON_GROUP_NAME
                FROM
                    PATRON,
                    PATRON_ADDRESS,
                    PATRON_BARCODE,
                    PATRON_GROUP
                WHERE
                    PATRON.PATRON_ID = PATRON_ADDRESS.PATRON_ID
                    AND PATRON.PATRON_ID = PATRON_BARCODE.PATRON_ID
                    AND PATRON_BARCODE.PATRON_GROUP_ID = PATRON_GROUP.PATRON_GROUP_ID
                    AND PATRON_BARCODE.BARCODE_STATUS = '1'
                    AND PATRON_ADDRESS.ADDRESS_TYPE = '3'
                    AND PATRON.INSTITUTION_ID = <cfqueryparam value="#arguments.getID#" cfsqltype="cf_sql_varchar">
                    AND lower(PATRON_ADDRESS.ADDRESS_LINE1) = lower(<cfqueryparam value="#arguments.getEmail#" cfsqltype="cf_sql_varchar"> || '@hws.edu')
            </cfquery>
        <cfelseif IDtype eq "barcode">
            <cfquery name="verifyusername" datasource="#application.dsn.voyager#">
                SELECT
                    PATRON.INSTITUTION_ID,
                    PATRON.FIRST_NAME,
                    PATRON.LAST_NAME,
                    PATRON_ADDRESS.ADDRESS_LINE1,
                    PATRON_GROUP.PATRON_GROUP_NAME
                FROM
                    PATRON,
                    PATRON_ADDRESS,
                    PATRON_BARCODE,
                    PATRON_GROUP
                WHERE
                    PATRON.PATRON_ID = PATRON_ADDRESS.PATRON_ID
                    AND PATRON.PATRON_ID = PATRON_BARCODE.PATRON_ID
                    AND PATRON_BARCODE.PATRON_GROUP_ID = PATRON_GROUP.PATRON_GROUP_ID
                    AND PATRON_BARCODE.BARCODE_STATUS = '1'
                    AND PATRON_ADDRESS.ADDRESS_TYPE = '3'
                    AND PATRON_BARCODE.PATRON_BARCODE = <cfqueryparam value="#arguments.getID#" cfsqltype="cf_sql_varchar">
                    AND lower(PATRON_ADDRESS.ADDRESS_LINE1) = lower(<cfqueryparam value="#arguments.getEmail#" cfsqltype="cf_sql_varchar"> || '@hws.edu')
            </cfquery>
        </cfif>

        <!--- return the result --->
        <cfif verifyusername.recordCount>
			<!--- determine staff permission level, if any --->
            <cfset alias = "hwsmicro\" & REReplace(lcase(verifyusername.ADDRESS_LINE1), "@hws.edu", "", "all")>
            <cfquery name="authorization" datasource="#application.dsn.library#">
                SELECT
                    u.ID,
                    up.permission_ID,
                    p.description,
                    u.role,
                    u.alias
                FROM user LEFT JOIN user_permission
                ON user.ID = user_permission.user_ID
                WHERE alias = <cfqueryparam value="#alias#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <cfif authorization.recordcount neq 0>
                <cfloop query="authorization">
                    <cfif #role# eq "admin">
                        <cfset session.admin = "yes">
                    <cfelseif #permission_ID# eq 1>
                        <cfset session.acquisitions = "yes">
                    <cfelseif #permission_ID# eq 2>
                        <cfset session.circulation = "yes">
                    <cfelseif #permission_ID# eq 3>
                        <cfset session.liaison = "yes">
                    <cfelseif #permission_ID# eq 4>
                        <cfset session.cataloging = "yes">
                    <cfelseif #permission_ID# eq 5>
                        <cfset session.journals = "yes">
                    <cfelseif #permission_ID# eq 6>
                        <cfset session.reserves = "yes">
                    </cfif>
                </cfloop>
            </cfif>
            
			<cfset session.verified=True>
            <cfset session.patron_id=verifyusername.INSTITUTION_ID>
            <cfset session.firstname=verifyusername.FIRST_NAME>
            <cfset session.lastname=verifyusername.LAST_NAME>
            <cfset session.email=verifyusername.ADDRESS_LINE1>
            <cfset session.patrongroup=verifyusername.PATRON_GROUP_NAME>
			<!--- adjust patrongroup to faculty if such exists --->
            <cfloop query="verifyusername">
            	<cfif PATRON_GROUP_NAME eq "Faculty">
					<cfset session.patrongroup=verifyusername.PATRON_GROUP_NAME>
                </cfif>
            </cfloop>
    
            <cfreturn True>
        <cfelse>
            <cfreturn False>
        </cfif>
    </cffunction>

</cfcomponent>