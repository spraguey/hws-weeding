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

<cfset session.verified = 'yes'>

<!--- notifications to faculty go out weekly on Monday --->
<cfif DayOfWeek(Now()) eq 2>
	<cfoutput>
    	<cftry>
			<cfset report_header=
                "<h2>Collection Review Notifications</h2><p><bib_count> titles were selected last week to be reviewed for retention in the collection areas you have subscribed to:</p>"
            >
            
            <cfset report_footer=
                "<p>You can manage these notifications through the Collection Review Manager at https://library.hws.edu/reports/collectionreview/index.cfm?deptid=0. Please contact your department liaison with any questions or concerns.</p>"
            >
        
            <cfinvoke
                component="#application.weeding.cfc#"
                method="get_subscriptions"
                returnvariable="subscriptions"
            />
            <cfquery name="faculty" dbtype="query">
                SELECT DISTINCT
                    faculty_ID
                FROM
                    subscriptions
            </cfquery>
            
            <cfloop query="faculty">
                <cfinvoke
                    component="#application.voyager.cfc#"
                    method="get_patron"
                    iid="#faculty.faculty_ID#"
                    returnvariable="patron"
                />
                <cfquery name="departments" dbtype="query">
                    SELECT DISTINCT
                        department_ID,
                        name
                    FROM
                        subscriptions
                    WHERE
                        faculty_ID = #faculty.faculty_ID#
                    ORDER BY
                        name
                </cfquery>
                <cfset report="">
                <cfset bib_count = 0>
                <cfloop query="departments">
                    <cfinvoke
                        component="#application.weeding.cfc#"
                        method="get_bibs"
                        department_ID="#departments.department_ID#"
                        review_start_after="#DateAdd('d', -7, Now())#"
                        returnvariable="bibs"
                    />
                    <cfset bib_count = bib_count + bibs.recordcount>
                    <cfset report = report & "<p><strong><a href='https://library.hws.edu/reports/collectionreview/index.cfm?deptid=#departments.department_ID#'>#departments.name#</a>:</strong> #bibs.recordcount#</p>">
                </cfloop>
                <cfif bib_count gt 0>
                    <cfset report = REReplace(report_header, '<bib_count>', '#bib_count#') & report & report_footer>
                    <cfmail
                        type="html"
                        to="#patron.email_address#"
                        bcc="#application.sysadmin#"
                        from="#application.library#"
                        subject="Library Collection Review Notifications: #DateFormat(Now(), 'mmm dd yyyy')#"
                    >
                        #report#
                    </cfmail>
                </cfif>
            </cfloop>
            <cfcatch>
                <cfmail 
                    to="#application.sysadmin#"
                    from="#application.library#"
                    subject="Library Collection Review Notifications: Error"
                    type="html"
                >
                    <cfdump var="#cfcatch#">
                </cfmail>
            </cfcatch>
        </cftry>
    </cfoutput>
</cfif> <!--- end of faculty notifications --->

<!--- daily notifications to liaisons for new comments --->
<cfoutput>
    <cftry>
        <cfset report_header=
            ""
        >
        
        <cfset report_footer=
            "<p><a href='https://library.hws.edu/staff/admin/weeding/manage.cfm?hascomments=yes'>See all comments</a></p>"
        >
    
        <cfinvoke
            component="#application.weeding.cfc#"
            method="get_bibs"
            has_comments="yes"
            comment_added_after="#DateAdd('d', -1, Now())#"
            returnvariable="bibs"
        />
        
        <cfif bibs.recordcount neq 0>
        	<cfset liaisons = {}>
            <cfloop query="bibs">
                <cfinvoke
                	component="#application.weeding.cfc#"
                    method="get_faculty_comments"
                    bib_ID="#bibs.bib_ID#"
                    returnvariable="comments"
                />

                <cfinvoke
                	component="#application.weeding.cfc#"
                    method="get_bib_departments"
                    bib_ID="#bibs.bib_ID#"
                    returnvariable="departments"
                />
                
                <cfset liaison_array = ArrayNew(1)>
                <cfset ArrayAppend(liaison_array, bibs.librarian_ID)>
                <cfif isdefined("application.hwsonly")>
                    <cfset ArrayAppend(liaison_array, 2)> <!--- always include VB --->
                </cfif>
                <cfloop query="comments">
                	<cfinvoke
                    	component="#application.voyager.cfc#"
                        method="get_department_by_iid"
                        iid="#comments.faculty_ID#"
                        returnvariable="faculty_department"
                    />
                    <cfinvoke
                    	component="#application.miscellaneous.cfc#"
                        method="get_liaisons_by_deptid"
                        deptID="#faculty_department#"
                        returnvariable="faculty_department_liaisons"
                    />
                    <cfloop query="faculty_department_liaisons">
                    	<cfset ArrayAppend(liaison_array, faculty_department_liaisons.ID)>
                    </cfloop>
                </cfloop>
                
                <cfloop query="departments">
                	<cfinvoke
                    	component="#application.miscellaneous.cfc#"
                        method="get_liaisons_by_deptid"
                        deptID="#departments.department_ID#"
                        returnvariable="bib_department_liaisons"
                    />
                    <cfloop query="bib_department_liaisons">
                    	<cfset ArrayAppend(liaison_array, bib_department_liaisons.ID)>
                    </cfloop>
                </cfloop>
                
                <cfloop from="1" to="#ArrayLen(liaison_array)#" index="i">
					<cfif not(StructKeyExists(liaisons, '#liaison_array[i]#'))>
                        <cfset liaisons['#liaison_array[i]#'] = {}>
                        <cfset liaisons['#liaison_array[i]#'].bibs = {}>
                    </cfif>
                    <cfif not(StructKeyExists(liaisons['#liaison_array[i]#'].bibs, '#bibs.bib_ID#'))>
                        <cfset liaisons['#liaison_array[i]#'].bibs['#bibs.bib_ID#'] = {}>
                        <cfset liaisons['#liaison_array[i]#'].bibs['#bibs.bib_ID#'].comments = comments>
                        <cfset liaisons['#liaison_array[i]#'].bibs['#bibs.bib_ID#'].author = bibs.author>
                        <cfset liaisons['#liaison_array[i]#'].bibs['#bibs.bib_ID#'].title = bibs.title>
                    </cfif>
                </cfloop>
            </cfloop>
            <cfloop collection="#liaisons#" item="liaison">
                <cfinvoke
                    component="#application.authorization.cfc#"
                    method="get_user"
                    userid="#liaison#"
                    returnvariable="liaison_info"
                />
                <cfset liaisons[liaison].email_address = liaison_info.email>
                <cfset report = "">
                <cfloop collection="#liaisons[liaison].bibs#" item="bib_ID">
                    <cfset report &= "<p><strong>Title:</strong> #liaisons[liaison].bibs[bib_ID].title#</p>">
                    <cfset report &= "<p><strong>Author:</strong> #liaisons[liaison].bibs[bib_ID].author#</p>">
                    <cfset report &= "<p><strong>Faculty comments:</strong></p>">
                    <cfset tmp="#liaisons[liaison].bibs[bib_ID].comments#">
                    <cfloop query="tmp">
                        <cfset report &= "<p>#tmp.name# (#DateFormat(tmp.date, 'mmm d, yyyy')#): #tmp.comment#</p>">
                    </cfloop>
                    <cfset report &= "<hr/>">
                </cfloop>
                
                <cfset report = report_header & report & report_footer>
    
                <cfmail
                    type="html"
                    to="#liaisons[liaison].email_address#"
                    bcc="#application.sysadmin#"
                    from="#application.library#"
                    subject="New Faculty Comments: #DateFormat(Now(), 'mmm dd yyyy')#"
                >
                    #report#
                </cfmail>
            </cfloop>
        </cfif>
		<cfcatch>
        	<cfmail 
            	to="#application.sysadmin#"
            	from="#application.library#"
                subject="New Faculty Comments: Error"
                type="html"
            >
            	<cfdump var="#cfcatch#">
            </cfmail>
        </cfcatch>
    </cftry>
</cfoutput>

<cfif isdefined("application.hwsonly")>
    <!--- send list of subscribers to VB --->
    <cfif DayOfWeek(Now()) eq 1>
        <cfoutput>
            <cftry>
                <cfinvoke
                    component="#application.weeding.cfc#"
                    method="get_subscriptions"
                    returnvariable="subscriptions"
                />
                <cfset report = "">
                <cfloop query="subscriptions">
                    <cfinvoke
                        component="#application.voyager.cfc#"
                        method="get_patron"
                        iid="#subscriptions.faculty_ID#"
                        returnvariable="patron"
                    />
                    <cfset report &=
                        "<p>#patron.firstname# #patron.lastname#: #subscriptions.name#</p>"
                    />
                </cfloop>
                <cfmail
                    to="#application.director#"
                    bcc="#application.sysadmin#"
                    from="#application.library#"
                    subject="Faculty Weeding Subscriptions: #DateFormat(Now(), 'mmm dd yyyy')#"
                    type="html"
                >
                    #report#
                </cfmail>
                <cfcatch>
                    <cfmail 
                        to="#application.sysadmin#"
                        from="#application.library#"
                        subject="Faculty Weeding Subscriptions: Error"
                        type="html"
                    >
                        <cfdump var="#cfcatch#">
                    </cfmail>
                </cfcatch>
            </cftry>
        </cfoutput>
    </cfif>
</cfif>