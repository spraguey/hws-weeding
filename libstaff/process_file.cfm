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
<cfsilent>
	<cfset title = "Process Barcodes">
    <cfinclude template = "../config.cfm">
</cfsilent>
<cfinvoke
	component="#application.display.cfc#"
    method="display_header"
    title="#title#"
    jquery="yes"
    nofollow="yes"
/>
<body>
    <cfinclude template="../includes/header.cfm">
    <div id="body">
        <div id="main">
    
    <!-- =========================== column one =========================== --> 
    
            <div id="column_full">
            	<cfinvoke
                	component="#application.display.cfc#"
                    method="display_breadcrumbs"
                    breadcrumb="Staff Tools,Weeding Manager,#title#"
                    breadcrumb_url="/staff/,/staff/weeding/,#cgi.SCRIPT_NAME#"
                />
                
                <div style="width:300px; font-size:10px; float:right;">
                    <cfinclude template="../includes/login.cfm">
                </div>


                <cftry>
					<cfoutput>
                        <h3>#title#</h3>
                        <cfif isLoggedIn() neq 'yes'>
                            <cfthrow message="Please log in.">
                        </cfif>

                        <cfif isAuthorized('liaison') neq 'yes'>
                            <cfthrow
                                message="You are not authorized to use this page.">
                        </cfif>


		<cfif not(isdefined("form.barcodefile"))>
            <cfthrow type="File required" message="Did you actually give me a file?  Because I didn't see one."/>
        </cfif>
    
        <cfset barcodes_added = QueryNew("item_barcode")/>
        <cfset barcodes_rejected = QueryNew("item_barcode")/>
        <cfset barcodes_error = QueryNew("item_barcode")/>
        <cfloop file="#form.barcodefile#" index="current_barcode">
            <cfif len(current_barcode) eq 14 AND IsNumeric(current_barcode)>
                <cfinvoke
                    component="cfc.weeding"
                    method="add_item"
                    returnvariable="add_item_check"
                >
                    <cfinvokeargument name="item_barcode" value="#current_barcode#">
                    <cfinvokeargument name="comment" value="#form.comment#">
                    <cfif form.department_ID neq ''>
                        <cfinvokeargument name="department_ID" value="#form.department_ID#">
                    </cfif>
                </cfinvoke>
                <cfif add_item_check neq "Item added.">
                    <cfscript>
                        newrow = QueryAddRow(barcodes_error);
                        QuerySetCell(barcodes_error, "item_barcode", "#current_barcode#");
                    </cfscript>
                <cfelse>
                    <cfscript>
                        newrow = QueryAddRow(barcodes_added);
                        QuerySetCell(barcodes_added, "item_barcode", "#current_barcode#");
                    </cfscript>
                </cfif>
            <cfelseif len(current_barcode) neq 0>
                <cfscript>
                    newrow = QueryAddRow(barcodes_rejected);
                    QuerySetCell(barcodes_rejected, "item_barcode", "#current_barcode#");
                </cfscript>
            </cfif>
        </cfloop>
		
		<h3>Upload complete</h3>
		<p>Items added: #barcodes_added.recordcount#</p>
		<p>Items rejected: #barcodes_rejected.recordcount#</p>
		<cfif barcodes_rejected.recordcount neq 0>
			<cfdump var="#barcodes_rejected#">
		</cfif>
        <p>Errors: #barcodes_error.recordcount#</p>
		<cfif barcodes_error.recordcount neq 0>
			<cfdump var="#barcodes_error#">
		</cfif>
		<cfif barcodes_added.recordcount neq 0>
			<cfquery name="tagged_items" datasource="#application.dsn.library#">
				SELECT DISTINCT
					wi.item_barcode
				FROM
					weeding_item wi inner join join weeding_bib_department wbd on wi.bib_ID = wbd.bib_ID
				WHERE
					wi.item_barcode IN (#ValueList(barcodes_added.item_barcode)#)
			</cfquery>
			<p>Items with at least one department match in conspectus: #tagged_items.recordcount#</p>
		</cfif>
		<p><a href="./">Return to Weeding Manager</a></p>
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

<!-- =========================== end column one =========================== --> 

</div>

        <cfinvoke
            component="#application.display.cfc#"
            method="display_footer"
        />

    </body>
</html>
