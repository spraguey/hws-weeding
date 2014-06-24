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

	<cffunction name="add_user" returntype="any">
    	<cfargument name="firstname" type="string" required="yes">
        <cfargument name="lastname" type="string" required="yes">
        <cfargument name="cwid" type="string" required="yes">
        <cfargument name="role" type="string" required="yes">
        <cfargument name="library_department_ID" type="numeric" required="no" default="0">
        <cfargument name="directory_order" type="numeric" required="no" default="0">
        <cfargument name="title" type="string" required="no" default="">
        <cfargument name="email" type="string" required="yes">
        <cfargument name="alias" type="string" required="no">
        <cfargument name="phone" type="string" required="no" default="">
        <cftry>
        	<cfif not(isdefined("session.authorization.admin"))>
            	<cfreturn false>
            </cfif>
            
            <cfif isdefined("arguments.email")>
            	<cfset arguments.alias = 'hwsmicro\' & REReplaceNoCase(arguments.email, '@hws\.edu$', '')>
            </cfif>
            
            <cfquery name="addUser" datasource="#application.dsn.library_rw#">
                SET NOCOUNT ON
                INSERT INTO [user] (
                    firstname,
                    lastname,
                    cwid,
                    role,
                    library_department_ID,
                    directory_order,
                    title,
                    email,
                    alias,
                    phone
                ) VALUES (
                	<cfqueryparam value="#arguments.firstname#" cfsqltype="cf_sql_varchar">,
                	<cfqueryparam value="#arguments.lastname#" cfsqltype="cf_sql_varchar">,
                	<cfqueryparam value="#arguments.cwid#" cfsqltype="cf_sql_varchar">,
                	<cfqueryparam value="#arguments.role#" cfsqltype="cf_sql_varchar">,
                    <cfif arguments.library_department_ID neq 0>
	                	<cfqueryparam value="#arguments.library_department_ID#" cfsqltype="cf_sql_integer">,
                    <cfelse>
                    	NULL,
                    </cfif>
                    <cfif arguments.directory_order neq 0>
	                	<cfqueryparam value="#arguments.directory_order#" cfsqltype="cf_sql_integer">,
                    <cfelse>
                    	NULL,
                    </cfif>
                	<cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_varchar">,
                	<cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
                	<cfqueryparam value="#arguments.alias#" cfsqltype="cf_sql_varchar">,
                	<cfqueryparam value="#arguments.phone#" cfsqltype="cf_sql_varchar">
               	)
                SELECT @@Identity As user_ID
                SET NOCOUNT OFF
            </cfquery>
            
            <cfreturn addUser.user_ID>
            
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="add_permission" returntype="any">
        <cfargument name="description" type="string" required="yes">
        <cftry>
        	<cfif not(isdefined("session.authorization.admin"))>
            	<cfreturn 0>
            </cfif>
            
            <cfinvoke
                method="get_permissions"
                description="#arguments.description#"
                returnvariable="check"
            />
            
            <cfif not(isdefined("check.recordcount"))>
                <cfreturn check>
            <cfelseif check.recordcount neq 0>
                <cfreturn check.ID>
            </cfif>
            
            <cfquery name="addPermission" datasource="#application.dsn.library_rw#">
                SET NOCOUNT ON
                INSERT INTO permission (
                    description
                ) VALUES (
                	<cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar">
               	)
                SELECT @@Identity As permission_ID
                SET NOCOUNT OFF
            </cfquery>
            
            <cfreturn addPermission.permission_ID>

            <cfcatch>
                <cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
	<cffunction name="add_user_permission" returntype="any">
    	<cfargument name="user_ID" type="numeric" required="yes">
        <cfargument name="permission_ID" type="numeric" required="yes">
        <cftry>
        	<cfif not(isdefined("session.authorization.admin"))>
            	<cfreturn false>
            </cfif>
            
            <cfinvoke
            	method="delete_user_permission"
                user_ID="#arguments.user_ID#"
                permission_ID="#arguments.permission_ID#"
                returnvariable="delete_check"
            />
            
            <cfquery name="addPermission" datasource="#application.dsn.library_rw#">
            	INSERT INTO
                	user_permission (user_ID, permission_ID)
                VALUES (
                	<cfqueryparam value="#arguments.user_ID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.permission_ID#" cfsqltype="cf_sql_integer">
               	)
            </cfquery>
            
            <cfreturn true>
            
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

	<cffunction name="delete_user_permission" returntype="any">
    	<cfargument name="user_ID" type="numeric" required="yes">
        <cfargument name="permission_ID" type="numeric" required="yes">
        <cftry>
        	<cfif not(isdefined("session.authorization.admin"))>
            	<cfreturn false>
            </cfif>
            
            <cfquery name="deletePermission" datasource="#application.dsn.library_rw#">
            	DELETE FROM
                	user_permission
                WHERE
                	user_ID = <cfqueryparam value="#arguments.user_ID#" cfsqltype="cf_sql_integer">
                    AND permission_ID = <cfqueryparam value="#arguments.permission_ID#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfreturn true>
            
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="get_alerts_authorization" returntype="any">
        <cfargument name="userid" type="numeric" required="yes">
        
        <cftry>
        	<cfinvoke
            	method="get_authorization"
                librarian_ID="#arguments.userid#"
                returnvariable="auth"
            />

            <cfquery name="getAlertTypes" datasource="#application.dsn.library#">
                SELECT DISTINCT
                    alert_type
                FROM
                    librarian_alert
                <cfif not(isdefined("auth.admin"))>
                WHERE
                    librarian_ID = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
                </cfif>
                ORDER BY
                    alert_type
            </cfquery>
            <cfreturn getAlertTypes>
            
            <cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
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
    
    <cffunction name="get_permissions" access="public" returntype="any">
        <cfargument name="description" type="string" required="no">
        
    	<cfquery name="permissions" datasource="#application.dsn.library#">
        	SELECT
            	p.ID,
                p.description
            FROM
            	permission p
            <cfif isdefined("arguments.description")>
            WHERE
                p.description = <cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar">
            </cfif>
            ORDER BY
            	p.description
        </cfquery>
        <cfreturn permissions>
    </cffunction>
    
    <cffunction name="get_user" access="public" returntype="any">
    	<cfargument name="userid" type="numeric" required="no">
        <cfargument name="expired" type="string" default="no" required="no">
        <cftry>
            <cfquery name="user" datasource="#application.dsn.library#">
                SELECT
                    u.ID,
                    u.firstname,
                    u.lastname,
                    u.alias,
                    u.role,
                    u.image_url,
                    u.email,
                    u.phone,
                    u.library_department_ID,
                    ld.name "library_department",
                    u.title,
                    u.directory_order,
                    u.cwid,
                    u.nomail,
                    u.expired
                FROM
                    [user] u LEFT JOIN library_department ld ON u.library_department_ID = ld.ID
                WHERE
                    1=1
                    <cfif arguments.expired eq "no">
                        AND u.expired IS NULL
                    <cfelseif arguments.expired eq "yes">
                        AND u.expired = 'yes'
                    </cfif>
                    <cfif isdefined("arguments.userid")>
                        AND u.ID = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
                </cfif>
                ORDER BY
                    u.lastname,
                    u.firstname
            </cfquery>
            <cfreturn user>
            <cfcatch>
                <cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="get_user_permissions" access="public" returntype="query">
        <cfargument name="network_ID" type="string" required="no">
        <cfargument name="librarian_ID" type="numeric" required="no">
        <cftry>
			<cfif not(isdefined("arguments.network_ID") OR isdefined("arguments.librarian_ID"))>
                <cfthrow
                	type="ID not specified">
            </cfif>
            <cfquery name="permissions" datasource="#application.dsn.library#">
                SELECT
                    u.ID, 
                    up.permission_ID,
                    p.description "permission_name",
                    u.role, 
                    u.alias,
                    u.firstname,
                    u.lastname,
                    u.cwid,
                    u.expired
                FROM 
                    [user] u LEFT JOIN user_permission up ON u.ID = up.user_ID
                    LEFT JOIN permission p on up.permission_ID = p.ID
                WHERE
                	<cfif isdefined("arguments.network_ID")>
	                    u.alias = <cfqueryparam value="#arguments.network_ID#" cfsqltype="cf_sql_varchar">
                    <cfelse>
                    	u.ID = <cfqueryparam value="#arguments.librarian_ID#" cfsqltype="cf_sql_integer">
                    </cfif>
                ORDER BY
                	p.description
            </cfquery>
            <cfreturn permissions>
            <cfcatch>
            	<cfdump var="#cfcatch#">
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="get_users" access="public" returntype="any">
		<cfargument name="user_ID" type="numeric" required="no">
        <cfargument name="permission_name" type="string" required="no">
    	<cfargument name="role_name" type="string" required="no">
        <cfargument name="library_department_ID" type="numeric" required="no">
        
        <cftry>
            <cfquery name="users" datasource="#application.dsn.library#">
                SELECT DISTINCT
                    u.ID,
                    u.lastname,
                    u.firstname,
                    u.email,
                    u.role,
                    u.image_url,
                    u.phone,
                    u.title,
                    directory_order = case when u.directory_order is null then 999 else u.directory_order end,
                    u.nomail,
                    ld.name "department_name"
                FROM
                	[user] u LEFT JOIN library_department ld on u.library_department_ID = ld.ID
                    LEFT JOIN user_permission up ON u.ID = up.user_ID
                    LEFT JOIN permission p ON up.permission_ID = p.ID
                WHERE
                	u.expired IS NULL
                    <cfif isdefined("arguments.user_ID")>
                    	AND u.ID = <cfqueryparam value="#arguments.user_ID#" cfsqltype="cf_sql_integer">
                    </cfif>
                    <cfif isdefined("arguments.permission_name")>
                    	AND p.description = <cfqueryparam value="#arguments.permission_name#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.role_name")>
                    	AND u.role = <cfqueryparam value="#arguments.role_name#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.library_department_ID")>
                    	AND u.library_department_ID = <cfqueryparam value="#arguments.library_department_ID#" cfsqltype="cf_sql_integer">
                    </cfif>
                ORDER BY
                	case when u.directory_order is null then 999 else u.directory_order end,
                    u.lastname,
                    u.firstname
            </cfquery>
            
            <cfreturn users>

            <cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="set_authorization" access="public" returntype="any">
        <cfif structKeyExists(form,"verify")>
            <cfset user = {}>
            
            <cfif isdefined("application.adminpw") and form.username eq "admin" and form.password eq application.adminpw>
                <cfset session.verified = true>
                <cfset user.firstname = 'Admin'>
                <cfset user.lastname  = 'User'>
                <cfset user.email_address = ''>
                <cfset user.iid = 0>
                <cfset session.user = user>
                <cfset session.authorization = {}>
                <cfset session.authorization.authorized = 'yes'>
                <cfset session.authorization.admin = 'yes'>
                <cfset session.authorization.iid = 0>
                <cfset session.authorization.userid = 0>
            </cfif>
            
            <cfinvoke
                component="#application.login.cfc#" 
                method="ldap"
                returnVariable="verify"
            >
                <cfinvokeargument name="username" value="#form.username#">
                <cfinvokeargument name="password" value="#form.password#">
            </cfinvoke>
            
            <cfif variables.verify eq true>
                <!--- LDAP passed: retrieve patron info from Voyager --->
                <cfinvoke
                    component="#application.voyager.cfc#"
                    method="get_patron"
                    returnvariable="user"
                    expired="no"
                >
                    <cfinvokeargument name="username" value="#form.username#">
                </cfinvoke>

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
    </cffunction>

    <cffunction name="update_user" access="public" returntype="any">
    	<cfargument name="ID" type="numeric" default="#session.authorization.userid#" required="no">
		<cfargument name="firstname" type="string" required="no">
        <cfargument name="lastname" type="string" required="no">
        <cfargument name="alias" type="string" required="no">
        <cfargument name="role" type="string" required="no">
        <cfargument name="image_url" type="string" required="no">
        <cfargument name="email" type="string" required="no">
        <cfargument name="phone" type="string" required="no">
        <cfargument name="library_department_ID" type="numeric" required="no">
        <cfargument name="title" type="string" required="no">
        <cfargument name="directory_order" type="numeric" required="no">
        <cfargument name="cwid" type="string" required="no">
        <cfargument name="nomail" type="string" required="no">
        <cfargument name="expired" type="string" required="no">

		<cftry>
			<cfif isdefined("session.authorization.liaison")>
                <cfif arguments.ID neq session.authorization.userid>
                    <cfreturn false>
                </cfif>
            	<cfset valid_fields = "ID,phone,image_url">
            <cfelseif isdefined("session.authorization.admin")>
            	<cfset valid_fields = "ID,firstname,lastname,alias,role,image_url,email,phone,library_department_ID,title,directory_order,cwid,nomail,expired">
            <cfelse>
                <cfreturn false>
            </cfif>
            
            <cfif isdefined("arguments.email")>
            	<cfset arguments.alias = 'hwsmicro\' & REReplaceNoCase(arguments.email, '@hws\.edu$', '')>
            </cfif>
            
            <cfloop collection="#arguments#" item="key">
                <cfif not(listfindnocase(valid_fields, key))>
                    <cfset structdelete(arguments, key)>
                </cfif>
            </cfloop>

            <cfquery name="updateUser" datasource="#application.dsn.library_rw#">
                UPDATE
                    [user]
                SET
                    <cfloop collection="#arguments#" item="key">
                        <cfif key neq "ID" AND key neq "url" AND isdefined("arguments.#key#")>
							<cfif key eq "directory_order" or key eq "library_department_ID">
                            	<cfif StructFind(arguments, key) eq '' or StructFind(arguments, key) eq 0>
									#key# = NULL,
                                <cfelse>
									#key# = <cfqueryparam value="#StructFind(arguments, key)#" cfsqltype="cf_sql_integer">,
                                </cfif>
                            <cfelseif key eq "expired" and arguments.expired neq "yes">
                            	expired = NULL,
							<cfelse>
								#key# = <cfqueryparam value="#StructFind(arguments, key)#" cfsqltype="cf_sql_varchar">,
							</cfif>
						</cfif>
                    </cfloop>
                    last_updated = #Now()#
                WHERE
                    ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfreturn true>

            <cfcatch>
            	<cfset cfcatch.arguments = arguments>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>

    </cffunction>
    
</cfcomponent>