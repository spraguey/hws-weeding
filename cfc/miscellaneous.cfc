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

<cfcomponent name="miscellaneous">
    <cffunction name="get_department_ID" access="public" returntype="numeric">
        <cfargument name="dept" type="string" required="yes">
        <cfquery name="getDepartmentRecord" datasource="#application.dsn.library#">
            SELECT
                ID,
                see
            FROM
                department
            WHERE
                name = <cfqueryparam value="#arguments.dept#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfif getDepartmentRecord.recordcount neq 1>
            <cfreturn 0>
        <cfelse>
            <cfif getDepartmentRecord.see eq ''>
                <cfreturn getDepartmentRecord.ID>
            <cfelse>
                <cfreturn getDepartmentRecord.see>
            </cfif>
        </cfif>
    </cffunction>
    
    <cffunction name="get_department_list" access="public" returntype="query">
        <cfquery name="dept_list" datasource="#application.dsn.library#">
            SELECT
                name "dept",
                ID
            FROM
                department
            WHERE
                see is null
            ORDER BY
                name
        </cfquery>
        <cfreturn dept_list>
    </cffunction>
    
    <cffunction name="get_department_name" access="public" returntype="string">
        <cfargument name="dept_id" type="numeric" required="yes">
        <cfquery name="lookupDepartment" datasource="#application.dsn.library#">
            SELECT
                name
            FROM
                department
            WHERE
                ID = <cfqueryparam value="#arguments.dept_id#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif lookupDepartment.recordcount eq 1>
            <cfreturn lookupDepartment.name>
        <cfelse>
            <cfreturn "Unknown department">
        </cfif>
    </cffunction>
    
    <cffunction name="get_departments" access="public" returntype="query">
    	<cfargument name="liaison_ID" type="numeric" required="no">
        <cfargument name="exclude_suppressed" type="string" required="no">
        <cfquery name="departments" datasource="#application.dsn.library#">
            SELECT DISTINCT
                department.name,
                department.ID
            FROM
				<cfif isdefined("arguments.liaison_ID")>
                	subject, 
                    librarian_subject,
                </cfif>
                department
            WHERE
                department.see is null
                <cfif isdefined("arguments.liaison_ID")>
                    AND 
                    	department.name = 'Interdisciplinary' OR
                    	(
                    	department.ID = subject.department_ID
	                    AND subject.ID = librarian_subject.subject_ID
	                    AND librarian_subject.librarian_ID = <cfqueryparam value="#arguments.liaison_ID#" cfsqltype="cf_sql_integer">
                        )
                </cfif>
                <cfif isdefined("arguments.exclude_suppressed") and arguments.exclude_suppressed eq 'yes'>
                	AND department.suppress_approval is null
                </cfif>
            ORDER BY
                department.name
        </cfquery>
        <cfreturn departments>
    </cffunction>
    
    <cffunction name="get_distribution_list" access="public" returntype="any">
    	<cfargument name="list_name" type="string" required="yes">
	    <cffile file="#ExpandPath('/cfg/distribution.cfg')#" action="read" variable="distribfile">

		<cfset distribarray = ArrayNew(1)>
        <cfset working_file = ListToArray(distribfile, chr(10))>

		<cfloop from="1" to="#ArrayLen(working_file)#" index="i">
        	<cfset line = working_file[i]>
            <cfif Left(line, 1) neq '##' and len(line) gt 0>
            	<cfset name = REReplace(line, '^\S*\s*(\S.*)$', '\1')>
                <cfif name eq arguments.list_name>
                	<cfset address = REReplace(line, '^(\S*)\s.*$', '\1')>
                    <cfset ArrayAppend(distribarray, address)>
                </cfif>
            </cfif>
        </cfloop>
        
        <cfset distribution_list = ArrayToList(distribarray, "; ")>
        <cfreturn distribution_list>
    </cffunction>
    
    <cffunction name="get_hours" returntype="any">
    	<cfargument name="entries" type="numeric" default="5" required="no">

        <cftry>
            <cfset hours = ArrayNew(1)>

        	<cfset today = DateFormat(Now(), 'yyyy-mm-dd')>
            <cffile file="#ExpandPath('/cfg/calendar.cfg')#" action="read" variable="calendar">
            <cfset days = ListToArray(calendar, chr(10))>

			<cfloop from="1" to="#ArrayLen(days)#" index="i">
            	<cfset thisday = days[i]>
                <cfif REReplace(thisday, '^(\S*)\s.*', '\1') eq today>
                	<cfset todayindex = i>
                    <cfbreak>
                </cfif>
            </cfloop>
            
            <cfloop from="#todayindex#" to="#todayindex + arguments.entries - 1#" index="i">
            	<cfif i gt ArrayLen(days)>
                	<cfbreak>
                </cfif>
                <cfset dateentry = {}>
				<cfset dateentry.date = REReplace(days[#i#], '^(\S*)\s.*', '\1')>
                <cfset dateentry.date = DateFormat(dateentry.date, 'mmm d (ddd)')>
                <cfset dateentry.hours = REReplace(days[#i#], '^\S*\s*(\S.*)$', '\1')>
            	<cfset ArrayAppend(hours, dateentry)>
            </cfloop>
            
            <cfreturn hours>

            <cfcatch>
				<cfset hours = ArrayNew(1)>
                <cfset dateentry = {}>
                <cfset dateentry.date = DateFormat(Now(), 'mmm d (ddd)')>
                <cfset dateentry.hours = 'Error retrieving hours'>
            	<cfset ArrayAppend(hours, dateentry)>
                <cfreturn hours>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="get_liaisons_by_subjectid" access="public" returntype="query">
        <cfargument name="subjectId" type="numeric" required="yes">
        <cfquery name="liaisons" datasource="#application.dsn.library#">
            SELECT
                ID,
                firstname,
                lastname,
                alias,
                cwid
            FROM
                librarians,
                librarian_subject
            WHERE
                librarians.ID = librarian_subject.librarian_ID
                AND librarian_subject.subject_ID = <cfqueryparam value="#arguments.subjectId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn liaisons>
    </cffunction>
    
    <cffunction name="get_liaisons_by_dept" access="public" returntype="query">
        <cfargument name="dept" type="string" required="yes">
        <cfset liaisons = get_liaisons_by_deptid(get_department_id(arguments.dept))>
        <cfreturn liaisons>
    </cffunction>
    
    <cffunction name="get_liaisons_by_deptid" access="public" returntype="query">
        <cfargument name="deptId" type="numeric" required="yes">
        <cfquery name="getLiaisons" datasource="#application.dsn.library#">
            SELECT DISTINCT
                librarians.ID,
                librarians.firstname,
                librarians.lastname,
                librarians.email,
                librarians.phone,
                librarians.url,
                librarians.image_url,
                librarians.nomail
            FROM
                subject,
                librarian_subject,
                librarians
            WHERE
                subject.ID = librarian_subject.subject_ID
                AND librarians.ID = librarian_subject.librarian_ID
                AND department_ID = <cfqueryparam value="#arguments.deptId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn getLiaisons>
    </cffunction>
    
    <cffunction name="get_subjects" access="public" returntype="query">
    	<cfquery name="getSubjects" datasource="#application.dsn.library#">
        	SELECT
            	ID,
                subject
            FROM
            	subject
            ORDER BY
            	subject
        </cfquery>
        <cfreturn getSubjects>
    </cffunction>
    
    <cffunction name="get_subjects_by_dept" access="public" returntype="query">
        <cfargument name="dept" type="string" required="yes">
        <cfset deptId = get_department_id(arguments.dept)>
        <cfquery name="getSubjects" datasource="#application.dsn.library#">
            SELECT
                ID,
                subject
            FROM
                subject
            WHERE
                department_ID = <cfqueryparam value="#deptId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfreturn getSubjects>
    </cffunction>
    
    <cffunction name="get_subjects_by_liaisonid" access="public" returntype="query">
        <cfargument name="liaisonId" required="yes">
        <cfquery name="getSubjects" datasource="#application.dsn.library#">
            SELECT DISTINCT
                ID,
                subject
            FROM
                subject,
                librarian_subject
            WHERE
                subject.ID = librarian_subject.subject_ID
                <cfif IsNumeric(arguments.liaisonId)>
                    AND librarian_subject.librarian_ID = <cfqueryparam value="#arguments.liaisonId#" cfsqltype="cf_sql_integer">
                <cfelseif arguments.liaisonId neq 'all'>
                    AND 1=0
                </cfif>
            ORDER BY
                subject
        </cfquery>
        <cfreturn getSubjects>
    </cffunction>
    
    <cffunction name="isbn_convert" returntype="struct">
    	<cfargument name="isbn" required="yes" type="string">
		<cfset isbntmp = REReplace(arguments.isbn, "[^0-9Xx]", "", "all")>
        <cfset isbn = StructNew()>
        <cfif len(isbntmp) eq 13>
            <cfset isbn.isbn13 = isbntmp>
            <cfset isbn.isbn10 = #mid(isbn.isbn13, 4, 9)#>
            <cfset checksum = 0>
            <cfset weight = 10>
            <cfloop index="i" from="1" to="#len(isbn.isbn10)#" step="1">
                <cfset char = Mid(isbn.isbn10, i, 1)>
                <cfset checksum = checksum + (char * weight)>
                <cfset weight = weight - 1>
            </cfloop>
            <cfset checksum = 11 - (checksum % 11)>
            <cfif checksum eq 10>
                <cfset isbn.isbn10 = isbn.isbn10 & "X">
            <cfelseif checksum eq 11>
                <cfset isbn.isbn10 = isbn.isbn10 & "0">
            <cfelse>
                <cfset isbn.isbn10 = isbn.isbn10 & checksum>
            </cfif>
        <cfelse>
            <cfset isbn.isbn13 = "">
            <cfset isbn.isbn10 = isbntmp>
        </cfif>
        <cfreturn isbn>
    </cffunction>
    
    <cffunction name="load_cfg" access="public" returntype="any">
        <cfargument name="filename" type="string" required="yes">
        
        <cftry>
        	<cfif not(isdefined("session.authorization.system"))>
            	<cfthrow type="not-authorized">
            </cfif>
            <cffile file="#ExpandPath(arguments.filename)#" action="read" variable="paramfile">

            <cfset working_file = ListToArray(paramfile, chr(10))>

            <cfloop from="1" to="#ArrayLen(working_file)#" index="i">
                <cfset line = working_file[i]>
                <cfif Left(line, 1) neq '##' and len(line) gt 0>
                    <cfset param = REReplace(line, '^(\S*)\s.*$', '\1')>
                    <cfset value = REReplace(line, '^\S*\s*(\S.*?)\s*$', '\1')>
                    <cfset parent = application>
                    <cfloop condition="REFind('\.', param)">
                        <cfset child = REReplace(param, '^([^.]*)\..*$', '\1')>
                        <cfif not(StructKeyExists(parent, child))>
                            <cfset parent[child] = {}>
                        </cfif>
                        <cfset parent = parent[child]>
                        <cfset param = REReplace(param, '^[^.]*\.', '')>
                    </cfloop>
                    <cfset parent[param] = value>
                </cfif>
            </cfloop>
            <cfcatch>
                <cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="error_notification" access="public" returntype="void">
    	<cfargument name="detail" required="yes">
        
        <cfmail
        	from="#application.library#"
            to="#application.sysadmin#"
            subject="Web error report: #getPageContext().getRequest().getRequestURI()#"
            type="html"
        >
        	<cfoutput>
	        	URL: #cgi.SERVER_NAME & getPageContext().getRequest().getRequestURI()#<br/>
				<cfif isdefined("session.user")>
                <p><strong>User</strong></p>
                    <cfloop collection="#session.user#" item="key">
                    	<cfif lcase(key) neq 'password'>
                            #key#: #StructFind(session.user, key)#<br/>
                        </cfif>
                    </cfloop>
                </cfif>
                <cfif isdefined("form") and not(structisempty(form))>
                <p><strong>Form variables:</strong></p>
                    <cfloop collection="#form#" item="key">
                    	<cfif lcase(key) neq 'password'>
                            #key#: #StructFind(form, key)#<br/>
                        </cfif>
                    </cfloop>
                </cfif>
                <cfif isdefined("url") and not(structisempty(url))>
                Query string:
                	<cfdump var="#url#">
                </cfif>
                Detail:
                <cfdump var="#arguments.detail#">
            </cfoutput>
        </cfmail>
    </cffunction>
</cfcomponent>