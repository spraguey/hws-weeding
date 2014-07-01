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
<cfcomponent output="false">

    <cfset expire_interval = "180">
    <cfset live_date='2012-07-30'>
    <cfset print_expire_interval = "14">

    <cffunction name="acknowledge" access="public" returntype="any">
        <cfargument name="bib_ID" required="yes" type="numeric">
        <cfargument name="faculty_ID" required="yes" type="numeric">
        <cftry>
            <cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison") or isdefined("session.authorization.archives"))>
                <cfthrow type="Not authorized">
            </cfif>

            <cfquery name="acknowledgeComment" datasource="#application.dsn.library_rw#">
                UPDATE weeding_bib_comment
                SET
                    acknowledged = 'yes'
                WHERE  
                    bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">
                    AND faculty_ID = <cfqueryparam value="#arguments.faculty_ID#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfreturn 1>

            <cfcatch>
                <cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

	<cffunction name="add_all" access="public" returntype="any">
        <cfargument name="bib_ID" required="yes" type="numeric">

        <cftry>
            <cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison") or isdefined("session.authorization.archives"))>
                <cfthrow type="Not authorized">
            </cfif>

            <cfinvoke
                component="#application.voyager.cfc#"
                method="get_items"
                bib_ID="#arguments.bib_ID#"
                returnvariable="item"
            />
            <cfloop query="item">
                <cfinvoke
                    method="add_item"
                    item_barcode="#item.item_barcode#"
                />
            </cfloop>

            <cfreturn 1>
            <cfcatch>
                <cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

	<cffunction name="add_bib" access="public" returntype="any">
    	<cfargument name="bib_ID" required="yes" type="numeric">
        <cfargument name="special_collections" required="no" type="string">
        <cfargument name="needs_review" required="no" type="string">
        <cfargument name="no_weed" required="no" type="string">
        <cfargument name="special_collections_decision" required="no" type="string">
        <cfargument name="comment" required="no" type="string">
        <cfargument name="department_ID" required="no" type="string">
        <cfargument name="delay" required="no" default="7" type="numeric">

		<cftry>
        	<cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison") or isdefined("session.authorization.archives"))>
            	<cfthrow type="Not authorized">
            </cfif>
            
            <cfinvoke
                component="#application.voyager.cfc#"
                method="get_bibs"
                bib_ID="#arguments.bib_ID#"
                marc_fields="590"
                returnvariable="voyager_bib"
            />
            
            <cfquery name="addBib" datasource="#application.dsn.library_rw#">
            	DELETE FROM
                	weeding_bib
                WHERE
                	bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_bigint">
                    
                INSERT INTO
                	weeding_bib (
                    	bib_ID,
                        librarian_ID,
                        comment,
                        special_collections,
                        needs_review,
                        special_collections_decision,
                        no_weed,
                        author,
                        title,
                        imprint,
                        local_note,
                        pub_dates_combined,
                        date_added,
                        review_start
                    )
                VALUES (
                	<cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_bigint">,
                    <cfqueryparam value="#session.authorization.userid#" cfsqltype="cf_sql_integer">,
                    <cfif isdefined("arguments.comment")>                    
	                    <cfqueryparam value="#arguments.comment#" cfsqltype="cf_sql_varchar">,
                    <cfelse>
                    	NULL,
                    </cfif>
                    <cfif isdefined("arguments.special_collections")>                    
	                    <cfqueryparam value="#arguments.special_collections#" cfsqltype="cf_sql_varchar">,
                    <cfelse>
                    	NULL,
                    </cfif>
                    <cfif isdefined("arguments.needs_review")>                    
	                    <cfqueryparam value="#arguments.needs_review#" cfsqltype="cf_sql_varchar">,
                    <cfelse>
                    	NULL,
                    </cfif>
                    <cfif isdefined("arguments.special_collections_decision")>                    
	                    <cfqueryparam value="#arguments.special_collections_decision#" cfsqltype="cf_sql_varchar">,
                    <cfelse>
                    	NULL,
                    </cfif>
                    <cfif isdefined("arguments.no_weed")>                    
	                    <cfqueryparam value="#arguments.no_weed#" cfsqltype="cf_sql_varchar">,
                    <cfelse>
                    	NULL,
                    </cfif>
                    <cfqueryparam value="#voyager_bib.author#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_bib.title#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_bib.imprint#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_bib.field_590#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_bib.pub_dates_combined#" cfsqltype="cf_sql_varchar">,
                    #Now()#,
                    <cfif (isdefined("arguments.needs_review") and arguments.needs_review eq 'yes')
                        OR (isdefined("arguments.no_weed") and arguments.no_weed eq 'yes')
                        OR (
                            (isdefined("arguments.special_collections") and arguments.special_collections eq 'yes')
                            AND (
								not(isdefined("arguments.special_collections_decision"))
								OR arguments.special_collections_decision eq 'yes'
							)
                        )
                    >
                    	NULL
                    <cfelse>
                    	<cfqueryparam value="#DateFormat(max(DateAdd('d', 7, Now()),live_date), 'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
                    </cfif>
					)
            </cfquery>

            <!--- add default departments from conspectus match --->
            <cfinvoke
                method="add_bib_department"
                bib_ID="#arguments.bib_ID#"
            />
            
            <cfif isdefined("arguments.department_ID")>
                <cfinvoke
                    method="add_bib_department"
                    bib_ID="#arguments.bib_ID#"
                    department_ID="#arguments.department_ID#"
                />
            </cfif>

			<cfreturn 1>
			<cfcatch>
				<cfreturn cfcatch>
			</cfcatch>
		</cftry>
    </cffunction>
    
	<cffunction name="add_bib_department" access="public" returntype="any">
		<cfargument name="bib_ID" required="yes" type="numeric">
		<cfargument name="department_ID" required="no" type="numeric">
		<!--- if department_ID is not supplied, default is to add all departments matching conspectus --->
		<cftry>
        	<cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison") or isdefined("session.authorization.archives"))>
            	<cfthrow type="Not authorized">
            </cfif>

            <cfif isdefined("arguments.department_ID") and arguments.department_ID neq ''>
            	<!--- delete item_department first in order to avoid dups --->
            	<cfinvoke
                    method="delete_bib_department"
                    bib_ID="#arguments.bib_ID#"
                    department_ID="#arguments.department_ID#"
                />
                <cfquery name="addBibDepartment" datasource="#application.dsn.library_rw#">
                    INSERT INTO
                        weeding_bib_department
                            (bib_ID, department_ID)
                    VALUES (
                        <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.department_ID#" cfsqltype="cf_sql_integer">
                        )
                </cfquery>
            <cfelse>
            	<!--- no department_ID supplied --->
                <cfquery name="item" datasource="#application.dsn.library#">
                	SELECT DISTINCT
                    	wi.normalized_call_no
                    FROM
                    	weeding_item wi
                    WHERE
                    	wi.bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_bigint">
                </cfquery>
                <cfif item.recordcount eq 0>
                	<cfreturn 0>
                </cfif>
                
                <cfloop query="item">
                    <cfinvoke
                        component="#application.conspectus.cfc#"
                        method="conspectus_match_departments"
                        returnvariable="matched_departments"
                        normalized_lcclass="#item.normalized_call_no#"
                    />
                    <cfif matched_departments.recordcount neq 0>
                        <cfloop query="matched_departments">
							<!--- delete item_department first in order to avoid dups --->
                            <cfinvoke
                                method="delete_bib_department"
                                bib_ID="#arguments.bib_ID#"
                                department_ID="#matched_departments.department_ID#"
                            />
                            <cfquery name="addBibDepartment" datasource="#application.dsn.library_rw#">
                                INSERT INTO
                                    weeding_bib_department
                                        (bib_ID, department_ID)
                                VALUES (
                                    <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">,
                                    <cfqueryparam value="#matched_departments.department_ID#" cfsqltype="cf_sql_integer">
                                    )
                            </cfquery>
                        </cfloop>
                    </cfif>
                </cfloop>
            </cfif>
			<cfreturn 1>
			<cfcatch>
				<cfreturn cfcatch>
			</cfcatch>
		</cftry>
	</cffunction>
	
    <cffunction name="add_dept_subscription" returntype="any">
<!---
		faculty_ID is now pulled from session.user
    	<cfargument name="faculty_ID" type="numeric" required="yes">
--->
        <cfargument name="department_ID" type="numeric" required="yes">
        <cftry>
        	<cfif not(isdefined("session.user.iid"))>
            	<cfthrow type="Not logged in">
            </cfif>
            <cfinvoke
                method="delete_dept_subscription"
                faculty_ID="#session.user.IID#"
                department_ID="#arguments.department_ID#"
            />
            <cfquery name="addDeptSubscription" datasource="#application.dsn.library_rw#">
                INSERT INTO weeding_department_subscription (
                    faculty_ID,
                    department_ID
                ) VALUES (
                    <cfqueryparam value="#session.user.IID#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.department_ID#" cfsqltype="cf_sql_integer">
                )
            </cfquery>
            <cfreturn 1>
            <cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

	<cffunction name="add_item" access="remote" returntype="any">
		<cfargument name="item_barcode" required="yes" type="string">
        <cfargument name="comment" required="no" type="string">
        <cfargument name="department_ID" required="no" type="numeric">
        <cfargument name="special_collections" required="no" type="string">
        <cfargument name="needs_review" required="no" type="string">
        <cfargument name="no_weed" required="no" type="string">
        <cfargument name="special_collections_decision" required="no" type="string">
        
		<cftry>
        	<cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison") or isdefined("session.authorization.archives"))>
            	<cfthrow type="Not authorized">
            </cfif>
        	<cfset arguments.item_barcode = REReplace(arguments.item_barcode, '[^0-9]', '', 'ALL')>
        	<cfif len(arguments.item_barcode) neq application.barcodelength>
            	<cfthrow message="Invalid barcode">
            </cfif>
            
            <cfinvoke
            	component="#application.voyager.cfc#"
                method="get_items"
                item_barcode="#arguments.item_barcode#"
                returnvariable="voyager_item"
            />
            
            <cfif not(isdefined("voyager_item.recordcount"))> 
			<!--- recordcount will be gt 1 for bound-withs. just take the first one --->
            	<cfthrow message="Unable to retrieve bib record">
            </cfif>
            
			<cfquery name="addItem" datasource="#application.dsn.library_rw#">
            	DELETE FROM
                	weeding_item
                WHERE
                	item_barcode = <cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">
            
				INSERT INTO
					weeding_item (
                    	item_barcode,
                        librarian_ID,
                        date_added,
                        bib_ID,
                        display_call_no,
                        item_enum,
                        chron,
                        item_year,
                        normalized_call_no,
                        copy_number,
                        location_code,
                        last_updated
                    )
				VALUES (
					<cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#session.authorization.userid#" cfsqltype="cf_sql_integer">,
					#Now()#,
                    <cfqueryparam value="#voyager_item.bib_ID#" cfsqltype="cf_sql_bigint">,
                    <cfqueryparam value="#voyager_item.display_call_no#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_item.item_enum#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_item.chron#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_item.year#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_item.normalized_call_no#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#voyager_item.copy_number#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#voyager_item.location_code#" cfsqltype="cf_sql_varchar">,
                    #Now()#
					)
			</cfquery>
            
            <!--- check to see if bib exists --->
            <cfinvoke
                method="get_bibs"
                bib_ID="#voyager_item.bib_ID#"
                returnvariable="bib_check"
            />
            
            <cfset bib_method = ''>
            <cfif bib_check.recordcount eq 0>
            	<cfset bib_method="add_bib">
            <cfelseif
            	isdefined("arguments.special_collections")
				OR isdefined("arguments.needs_review")
				OR isdefined("arguments.no_weed")
				OR isdefined("arguments.special_collections_decision")
				OR isdefined("arguments.comment")
				OR isdefined("arguments.department_ID")
			>
            	<cfset bib_method="edit_bib">
            </cfif>
            
            <cfif bib_method eq ''>
                <cfreturn 'Item added.'>
            </cfif>

            <cfinvoke
                method="#bib_method#"
                bib_ID="#voyager_item.bib_ID#"
                returnvariable="bib"
            >
                <cfif isdefined("arguments.special_collections")>
                    <cfinvokeargument name="special_collections" value="#arguments.special_collections#">
                </cfif>
                <cfif isdefined("arguments.needs_review")>
                    <cfinvokeargument name="needs_review" value="#arguments.needs_review#">
                </cfif>
                <cfif isdefined("arguments.no_weed")>
                    <cfinvokeargument name="no_weed" value="#arguments.no_weed#">
                </cfif>
                <cfif isdefined("arguments.special_collections_decision")>
                    <cfinvokeargument name="special_collections_decision" value="#arguments.special_collections_decision#">
                </cfif>
                <cfif isdefined("arguments.comment")>
                    <cfinvokeargument name="comment" value="#arguments.comment#">
                </cfif>
				<cfif isdefined("arguments.department_ID")>
                    <cfinvokeargument name="department_ID" value="#arguments.department_ID#">
                </cfif>
            </cfinvoke>
            
            <cfreturn 'Item added.'>
			<cfcatch>
                <cfreturn cfcatch>
			</cfcatch>
		</cftry>
	</cffunction>
	
    <!--- add faculty comment --->
	<cffunction name="add_item_comment" access="public" returntype="any">
		<cfargument name="bib_ID" required="yes" type="numeric">
		<cfargument name="comment" required="yes" type="string">
		<cftry>
        	<cfif not(isdefined("session.user.iid"))>
            	<cfthrow type="Not logged in">
            </cfif>

            <cfquery name="addComment" datasource="#application.dsn.library_rw#">
            	DELETE FROM
                	weeding_bib_comment
                WHERE
                	bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_varchar">
                    AND faculty_ID = <cfqueryparam value="#session.user.IID#" cfsqltype="cf_sql_integer">

	            <cfif len(arguments.comment) gt 0>
                    INSERT INTO
                        weeding_bib_comment
                            (bib_ID, faculty_ID, comment, date)
                    VALUES (
                        <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#session.user.IID#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#arguments.comment#" cfsqltype="cf_sql_varchar">,
                        #Now()#
                        )
                </cfif>
            </cfquery>

			<cfreturn 1>
			<cfcatch>
				<cfreturn cfcatch>
			</cfcatch>
		</cftry>
	</cffunction>
    
	<cffunction name="delete_bib" access="public" returntype="any">
    	<cfargument name="bib_ID" required="yes" type="numeric">
		<cftry>
            <cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison") or isdefined("session.authorization.archives"))>
                <cfthrow type="Not authorized">
            </cfif>
            
			<cfquery name="deleteBibItems" datasource="#application.dsn.library_rw#">
            	DELETE
                FROM
                	weeding_item
                WHERE
                	bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfquery name="deleteBibDepartments" datasource="#application.dsn.library_rw#">
            	DELETE
                FROM
                	weeding_bib_department
                WHERE
                	bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">
            </cfquery>
            
            <cfquery name="deleteBib" datasource="#application.dsn.library_rw#">
            	DELETE
                FROM
                	weeding_bib
                WHERE
                	bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">
            </cfquery>

			<cfreturn items.recordcount>
            <cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="delete_bib_department" access="remote" returntype="any">
    	<cfargument name="bib_ID" required="yes" type="numeric">
        <cfargument name="department_ID" required="yes" type="numeric">
		<cftry>
            <cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison") or isdefined("session.authorization.archives"))>
                <cfthrow type="Not authorized">
            </cfif>

            <cfquery name="deleteBibDepartment" datasource="#application.dsn.library_rw#">
                DELETE
                FROM
                    weeding_bib_department
                WHERE
                    bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">
                    AND department_ID = <cfqueryparam value="#arguments.department_ID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="delete_dept_subscription" returntype="string">
<!---
		faculty_ID is now pulled from session.user
    	<cfargument name="faculty_ID" type="numeric" required="yes">
--->
        <cfargument name="department_ID" type="numeric" required="yes">
        <cftry>
        	<cfif not(isdefined("session.user.iid"))>
            	<cfthrow type="Not logged in">
            </cfif>

            <cfquery name="deleteDeptSubscription" datasource="#application.dsn.library_rw#">
            	DELETE
                FROM weeding_department_subscription
                WHERE
                    faculty_ID = <cfqueryparam value="#session.user.IID#" cfsqltype="cf_sql_integer">
                    AND department_ID = <cfqueryparam value="#arguments.department_ID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfreturn 1>
            <cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

	<cffunction name="delete_item" access="remote" returntype="any">
		<cfargument name="item_barcode" required="yes">
		<cfargument name="librarian_ID" required="no" type="numeric">
		<cftry>
			<cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison") or isdefined("session.authorization.archives"))>
                <cfthrow type="Not authorized">
            </cfif>
			<cfset arguments.item_barcode=REReplace(arguments.item_barcode, '_', '')>
            
            <cfinvoke
                method="get_items"
                item_barcode="#arguments.item_barcode#"
                returnvariable="item"
            />

			<cfquery name="deleteItem" datasource="#application.dsn.library_rw#">
				DELETE FROM
					weeding_item
				WHERE
					item_barcode = <cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">
					<cfif isdefined("arguments.librarian_ID")>
						AND librarian_ID = <cfqueryparam value="#arguments.librarian_ID#" cfsqltype="cf_sql_integer">
                    </cfif>
			</cfquery>
			<!--- check to see if entries for bib_ID still exist; if not, delete bib as well --->
            <cfinvoke
                method="get_items"
                bib_ID="#item.bib_ID#"
                returnvariable="remaining_items"
            />
            <cfif remaining_items.recordcount eq 0>
            	<cfinvoke
                    method="delete_bib"
                    bib_ID="#item.bib_ID#"
                />
            </cfif>
            
            <cfreturn 'Item deleted.'>
			<cfcatch>
				<cfreturn cfcatch.type>
			</cfcatch>
		</cftry>
	</cffunction>
	
    <cffunction name="display_bib" access="public" returntype="any">
    	<cfargument name="bib_ID" required="yes" type="numeric">
        <cftry>
			<cfoutput>
                <cfinvoke
                    method="get_bibs"
                    bib_ID="#arguments.bib_ID#"
                    returnvariable="bib"
                />
                <cfinvoke
                    component="#application.voyager.cfc#"
                    method="get_items"
                    bib_ID="#arguments.bib_ID#"
                    returnvariable="bib_items"
                />
                <cfinvoke
                    method="get_items"
                    bib_ID="#arguments.bib_ID#"
                    returnvariable="weeding_items"
                />
                <!--- set bib location/callno to first weeded item location --->
                <cfset bib_location = weeding_items.location_code>
                <cfset bib_callno = weeding_items.display_call_no>

                <cfset weed_barcodes = REReplace(QuotedValueList(weeding_items.item_barcode, ","), "_", "", "ALL")>
                <cfquery name="to_retain" dbtype="query">
                    SELECT
                        *
                    FROM
                        bib_items
                    WHERE
                        bib_items.item_barcode NOT IN (#PreserveSingleQuotes(weed_barcodes)#)
                </cfquery>
                
                <cfif isdefined("session.authorization.cataloging") or (isdefined("session.weeding.mode") and session.weeding.mode eq 'cataloging')>
                <!--- cataloging view --->
                    <div 
                    	class="manage_weeding_item" 
                        id="bib_#arguments.bib_ID#" 
                        style="
                        	width:900px;
                            padding-bottom: 0;
                            border-bottom: 1px solid black;
							<!--- non-expired items need to be visually distinct --->
                            <cfif NOT(
                                bib.review_start neq ''
                                AND DateAdd('d', expire_interval, bib.review_start) lt Now()
                                OR (
                                    isdefined("session.weeding.specialcollections") AND session.weeding.specialcollections eq 'yes'
                                    AND isdefined("session.weeding.specialcollectionsdecision") AND session.weeding.specialcollectionsdecision eq 'yes'
                                )
                            )>
                                font-style: italic;
                                font-weight: bold;
                            </cfif>
                    ">
                        <div style="float:left; width:350px; padding: 0 5px 0 5px;">
                            #bib.title#
                        </div>
                        <div style="float:left; width:250px;">
                            <cfloop query="weeding_items">
                                <div 
                                	<cfif currentrow neq weeding_items.recordcount>
	                                	style="border-bottom: 1px solid black;"
                                    </cfif>
                                >
                                    <div style="float:left; width: 96px; padding-right: 5px;">
                                        <cfif weeding_items.location_code neq 'MAIN'>#weeding_items.location_code#<br/></cfif>
                                        #weeding_items.display_call_no#
                                        #weeding_items.item_enum#
                                        #weeding_items.chron#
                                        <br/>copy #weeding_items.copy_number#
                                    </div>
                                    <div style="float:left; width: 116px; text-align: center;">
                                        #REReplace(weeding_items.item_barcode, '_', '')#
                                    </div>
                                    <div style="height: 0; clear:both;">&nbsp;</div>
                                </div>
	                        </cfloop>
                        </div>
                        <cfif to_retain.recordcount gt 0>
                            <div style="float:left; width:250px;">
                            	<cfloop query="to_retain">
                                    <div 
                                        <cfif currentrow neq to_retain.recordcount>
                                            style="border-bottom: 1px solid black;"
                                        </cfif>
                                    >
                                        <div style="float:left; width: 96px; padding-right: 5px;">
											<cfif to_retain.location_code neq 'MAIN'>#to_retain.location_code#<br/></cfif>
                                            #to_retain.display_call_no#
                                            #to_retain.item_enum#
                                            #to_retain.chron#
                                            <br/>copy #to_retain.copy_number#
                                        </div>
                                        <div style="float:left; width: 116px; text-align: center;">
                                            #REReplace(to_retain.item_barcode, '_', '')#
                                        </div>
                                        <div style="height: 0; clear:both;">&nbsp;</div>
                                    </div>
                                </cfloop>
                            </div>
                        </cfif>
                    </div>
                    <div style="height: 1px; clear:both;">&nbsp;</div>
                <!--- end cataloging view --->
                    <cfreturn>
                </cfif>

                <div id="bib_#arguments.bib_ID#_wrapper">
                        <div 
                        	class="manage_weeding_item" 
                            id="bib_#arguments.bib_ID#"
							<cfif not(isdefined("url.view") and url.view neq 'manage')>
                                style="width:900px;"
                            </cfif>
                        >
                            <strong>Title:</strong> #bib.title#
                            (<a href="http://#application.opac#" target="_blank">More info</a>)
                            <br/>
                            <cfif bib.author neq ''>
                                <strong>Author:</strong> #bib.author#<br/>
                            </cfif>
                            <strong>Published:</strong> #bib.imprint#<br/>
							<cfif isdefined("url.view") and url.view eq 'manage'>
                                <strong>Location:</strong> #bib_location#<br/>
                                <strong>Call number:</strong> #bib_callno#<br/>
                                <cfinvoke
                                    component="#application.authorization.cfc#"
                                    method="get_user"
                                    userId="#bib.librarian_ID#"
                                    returnvariable="librarian"
                                />
                                <cfif isdefined("url.view") and url.view eq 'manage'>
	                                <strong>Added:</strong> #DateFormat(bib.date_added, 'mmm d, yyyy')# by #librarian.firstname# #librarian.lastname#<br/>
									<cfif bib.review_start neq ''>
                                        <strong>Review period:</strong> #DateFormat(bib.review_start, 'mmm d, yyyy')# - #DateFormat(DateAdd('d', expire_interval, bib.review_start), 'mmm d, yyyy')#<br/>
                                    </cfif>
                                </cfif>
                            </cfif>
                            
                            <br/>
                            
                            <div 
                            	id="withdraw_#arguments.bib_ID#_wrapper"
                                style="float:left; width:425px; border: 1px solid ##bbb; padding: 5px;"
                            >
                        
                                <strong>Withdraw:</strong><br/>
                                <table id="bib_#arguments.bib_ID#_withdraw" class="manage_itemstats">
                                    <tr>
                                        <th>Item</th>
                                        <th>Charges</th>
                                        <th>Browses</th>
                                        <th>Last circ</th>
                                    </tr>
                                    <cfloop query="weeding_items">
                                        <cfinvoke
                                            method="get_item_stats"
                                            item_barcode="#weeding_items.item_barcode#"
                                            returnvariable="item_stats"
                                        />
                                        <tr id="item_#weeding_items.item_barcode#" class="bib_#arguments.bib_ID#_item">
                                            <td>
                                                <cfif weeding_items.location_code neq bib_location>
                                                    [#weeding_items.location_code#]
                                                </cfif>
                                                <cfif weeding_items.display_call_no neq bib_callno>
                                                    #weeding_items.display_call_no#
                                                </cfif>
                                                #item_enum#
                                                #chron#
                                                copy #copy_number#
                                            </td>
                                            <td>#item_stats.historical_charges#</td>
                                            <td>#item_stats.historical_browses#</td>
                                            <td>#item_stats.latest_circ#</td>
                                            <td>
                                                <input type="button" value="Retain" id="delete_item_#weeding_items.item_barcode#"  class="bib_#arguments.bib_ID#_item_delete" onClick="delete_item('#weeding_items.item_barcode#', #arguments.bib_ID#);" />
                                                <input type="button" value="Withdraw" id="add_item_#weeding_items.item_barcode#"  class="bib_#arguments.bib_ID#_item_add" style="display:none;" onClick="add_item('#weeding_items.item_barcode#', #arguments.bib_ID#);" />
                                            </td>
                                        </tr>
                                    </cfloop>
                                </table>
        					</div>
                            
                            <cfif to_retain.recordcount gt 0 or (isdefined("session.authorization.admin") or isdefined("session.authorization.liaison"))>
                                <div
                                	id="retain_#arguments.bib_ID#_wrapper"
                                    style="float:left; width:425px; border: 1px solid ##bbb; margin-left: 10px; padding: 5px;"
                                >
                                    <strong>Retain:</strong><br/>
                                    <table id="bib_#arguments.bib_ID#_retain" class="manage_itemstats">
                                        <tr>
                                            <th>Item</th>
                                            <cfif isdefined("session.authorization.cataloging")>
                                                <th>Barcode</th>
                                            <cfelse>
                                                <th>Charges</th>
                                                <th>Browses</th>
                                                <th>Last circ</th>
                                                <th>
                                                    <input type="button" value="Withdraw all" id="add_all_#arguments.bib_ID#" onClick="add_all(#arguments.bib_ID#);" />
                                                </th>
                                            </cfif>
                                        </tr>
                                        <cfloop query="to_retain">
                                            <cfinvoke
                                                method="get_item_stats"
                                                item_barcode="#to_retain.item_barcode#"
                                                returnvariable="item_stats"
                                            />
                                            <tr id="item_#to_retain.item_barcode#" class="bib_#arguments.bib_ID#_item">
                                                <td>
                                                    <cfif to_retain.location_code neq bib_location>
                                                        [#to_retain.location_code#]
                                                    </cfif>
                                                    <cfif to_retain.display_call_no neq bib_callno>
                                                        #to_retain.display_call_no#
                                                    </cfif>
                                                    #item_enum#
                                                    #chron#
                                                    copy #copy_number#
                                                </td>
                                                <cfif isdefined("session.authorization.cataloging")>
                                                    <td>#REReplace(to_retain.item_barcode, '_', '', 'ALL')#</td>
                                                <cfelse>
                                                    <td>#item_stats.historical_charges#</td>
                                                    <td>#item_stats.historical_browses#</td>
                                                    <td>#item_stats.latest_circ#</td>
                                                    <td>
                                                        <input type="button" value="Withdraw" id="add_item_#to_retain.item_barcode#"  class="bib_#arguments.bib_ID#_item_add" onClick="add_item('#to_retain.item_barcode#', #arguments.bib_ID#);" />
                                                        <input type="button" value="Retain" id="delete_item_#to_retain.item_barcode#"  class="bib_#arguments.bib_ID#_item_delete" style="display:none;" onClick="delete_item('#to_retain.item_barcode#', #arguments.bib_ID#);" />
                                                    </td>
                                                </cfif>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </div>
                        	</cfif>
        
                            <div class="clear"></div>
                            <br/>

        					<cfif isdefined("session.authorization.admin") or isdefined("session.authorization.liaison")>
                                <cfinvoke
                                    method="get_bib_departments"
                                    bib_ID="#arguments.bib_ID#"
                                    returnvariable="bib_departments"
                                />
                                <strong>Departments:</strong>
                                <span id="bib_#arguments.bib_ID#_departments">
                                    <cfif bib_departments.recordcount neq 0>
                                        <cfloop query="bib_departments">
                                            <span id="bib_#arguments.bib_ID#_department_#bib_departments.department_ID#">#bib_departments.name# [<a class="link" onClick="delete_department('#arguments.bib_ID#', '#bib_departments.department_ID#');">x</a>]<cfif currentrow neq bib_departments.recordcount>, </cfif></span>
                                        </cfloop>
                                    </cfif>
                                </span>
                                <br/>
                                <strong>Add department:</strong>
                                <input id="add_department_#arguments.bib_ID#" class="add_department" style="width:200px;"/>
                                <input type="button" value="Add" onClick="addDept('#arguments.bib_ID#');" />
                                <br/>
                            
                                <cfif bib.needs_review eq 'yes'>
                                    <input type="checkbox" id="needs_review_#arguments.bib_ID#" onClick="update('#arguments.bib_ID#');" value="yes" checked="checked"/> Needs review
                                <cfelse>
                                    <input type="checkbox" id="needs_review_#arguments.bib_ID#" onClick="update('#arguments.bib_ID#');" value="yes"/> Needs review
                                </cfif>
                                |
                                <cfif bib.special_collections eq 'yes'>
                                    <input type="checkbox" id="special_collections_#arguments.bib_ID#" onClick="update('#arguments.bib_ID#'); toggleNoWeed('#arguments.bib_ID#');" value="yes" checked="checked"> Special Collections review 
                                    <span id="no_weed_span_#arguments.bib_ID#">
                                        | 
                                        <cfif bib.no_weed eq 'yes'>
                                            <input type="checkbox" id="no_weed_#arguments.bib_ID#" onClick="update('#arguments.bib_ID#');" value='yes' checked="checked"/> Don't weed
                                        <cfelse>
                                            <input type="checkbox" id="no_weed_#arguments.bib_ID#" onClick="update('#arguments.bib_ID#');" value='yes'/> Don't weed
                                        </cfif>
                                    </span>
                                    <cfif 
                                        isdefined("session.authorization.archives") 
                                        or isdefined("session.authorization.admin")
                                    >
                                        <br/>
                                        <strong>Special collections decision:</strong> 
                                        <select id="special_collections_decision_#arguments.bib_ID#" onChange="update('#arguments.bib_ID#');">
                                            <option value="">------</option>
                                            <cfloop list="Yes,No" index="decision">
                                                <cfif bib.special_collections_decision eq LCase(decision)>
                                                    <option value="#LCase(decision)#" selected="selected">#decision#</option>
                                                <cfelse>
                                                    <option value="#LCase(decision)#">#decision#</option>
                                                </cfif>
                                            </cfloop>
                                        </select>
                                        <br/>
                                    <cfelseif bib.special_collections_decision neq ''>
                                        <br/>
                                        <strong>Special collections decision:</strong> 
                                        #bib.special_collections_decision#
                                        <input type="hidden" id="special_collections_decision_#arguments.bib_ID#" value="#bib.special_collections_decision#"/>
                                    </cfif>
                                <cfelse>
                                    <input type="checkbox" id="special_collections_#arguments.bib_ID#" onClick="update('#arguments.bib_ID#'); toggleNoWeed('#arguments.bib_ID#');" value="yes"/> Special Collections review 
                                    <span id="no_weed_span_#arguments.bib_ID#" style="display:none;">
                                        | 
                                        <cfif bib.no_weed eq 'yes'>
                                            <input type="checkbox" id="no_weed_#arguments.bib_ID#" onClick="update('#arguments.bib_ID#');" value='yes' checked="checked"/> Don't weed
                                        <cfelse>
                                            <input type="checkbox" id="no_weed_#arguments.bib_ID#" onClick="update('#arguments.bib_ID#');" value='yes'/> Don't weed
                                        </cfif>
                                    </span>
                                </cfif>
                                <br/>
                                <br/>

                                <div style="float:left; width:544px;">
                                    <strong>Librarian comment:</strong>
                                    <select id="preset_comment_#arguments.bib_ID#" onChange="$('##bib_#arguments.bib_ID#_comment').val(this.value); update('#arguments.bib_ID#');">
                                        <cfloop list=" ,Multiple copies; one will remain in the collection,Have newer edition,Superseded content,Out of scope,Discontinued series,Textbook,Content available online" index="reason">
                                            <cfif reason eq ' '>
                                                <option value="">---------------------</option>
                                            <cfelse>
                                                <cfif bib.librarian_comment eq reason>
                                                    <option value="#reason#" selected="selected">#reason#</option>
                                                <cfelse>
                                                    <option value="#reason#">#reason#</option>
                                                </cfif>
                                            </cfif>
                                        </cfloop>
                                    </select>
                                    <textarea id="bib_#arguments.bib_ID#_comment" rows="5" cols="53">#bib.librarian_comment#</textarea><br/>
                                    <input type="button" onClick="update('#arguments.bib_ID#');" value="Update comment" />
                                    <span id="status_#arguments.bib_ID#"></span><br/><br/>
                                </div>

                                <div style="float:left; width:340px;">
                                    <cfif isdefined("url.view") and url.view eq 'manage' and (isdefined("session.authorization.admin") or isdefined("session.authorization.liaison"))>
                                        <cfinvoke
                                            method="get_faculty_comments"
                                            bib_ID="#arguments.bib_ID#"
                                            returnvariable="faculty_comments"
                                        />
                                        <cfset has_comment="no">
                                        <cfif faculty_comments.recordcount neq 0>
                                            <div class="manage_facultycomments">
                                                <strong>Faculty comments:</strong><br/>
                                                <cfloop query="faculty_comments">
                                                    <p>#faculty_comments.name# (#Dateformat(faculty_comments.date, 'mmm d, yyyy')#): 
                                                    <cfif faculty_comments.faculty_ID eq session.authorization.iid>
                                                            <textarea id="bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#_textarea" rows="5" cols="30">#faculty_comments.comment#</textarea>
                                                            <span id="bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#_acknowledged" style="color:green; font-weight:bold; <cfif faculty_comments.acknowledged neq 'yes'>display:none;</cfif>">Acknowledged |
                                                            </span>
                                                            <span id="bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#_acknowledge" <cfif faculty_comments.acknowledged eq 'yes'>style="display:none;"</cfif>>
                                                                <a class="link" onclick="acknowledge('#arguments.bib_ID#', '#faculty_comments.faculty_ID#');">Acknowledge</a> |
                                                            </span>
                                                            <a class="link" onclick="addComment(#arguments.bib_ID#);">Update</a> |
                                                            <a class="link" onclick="$('##bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#_textarea').val(''); addComment(#arguments.bib_ID#);">Remove</a>
                                                            
                                                            <span id="bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#_status">&nbsp;</span>

                                                            <cfset has_comment="yes">
                                                    <cfelse>
                                                            <cfif faculty_comments.acknowledged eq 'yes'>
                                                                <span id="bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#" style="color:green;">#faculty_comments.comment#</span>
                                                            <cfelse>
                                                                <span id="bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#" style="color:red; font-weight:bold;">#faculty_comments.comment#</span><br/>
                                                                <span id="bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#_acknowledge"><a class="link" onclick="acknowledge('#arguments.bib_ID#', '#faculty_comments.faculty_ID#');">Acknowledge</a></span>
                                                                <span id="bib_#arguments.bib_ID#_comment_#faculty_comments.faculty_ID#_status">&nbsp;</span>
                                                            </cfif>
                                                    </cfif>
                                                    </p>
                                                    <cfif currentrow neq faculty_comments.recordcount>
                                                        <hr/>
                                                    </cfif>
                                                </cfloop>
                                            </div>
                                        </cfif>
                                        <cfif has_comment eq "no" and (isdefined("session.authorization.admin") or isdefined("session.authorization.liaison"))>
                                            <p id="s_add_faculty_comment_#arguments.bib_ID#" style="float:left; width:300px;">
                                                <a class="link" onclick="$('##s_add_faculty_comment_#arguments.bib_ID#').hide();$('##l_add_faculty_comment_#arguments.bib_ID#').show();">Add internal comment</a>
                                            </p>
                                            <p id="l_add_faculty_comment_#arguments.bib_ID#" style="float:left; width:300px; display:none;">
                                                <textarea id="bib_#arguments.bib_ID#_comment_#session.authorization.IID#_textarea" rows="5" cols="35"></textarea>
                                                <a class="link" onclick="addComment(#arguments.bib_ID#);">Add</a> |
                                                <a class="link" onclick="$('##s_add_faculty_comment_#arguments.bib_ID#').show();$('##l_add_faculty_comment_#arguments.bib_ID#').hide();">Cancel</a>
                                                <span id="bib_#arguments.bib_ID#_comment_#session.authorization.IID#_status">&nbsp;</span>
                                            </p>
                                        </cfif>
                                    </cfif>
                                </div>
                                <div class="clear"></div>

                                <input type="button" value="Remove all items" id="bib_#arguments.bib_ID#_delete" disabled="disabled" onClick="delete_bib('#arguments.bib_ID#');" />
                                <input type="checkbox" id="bib_#arguments.bib_ID#_confirm" onClick="enable_delete('#arguments.bib_ID#');" /> (unlock)
                                
                            </cfif>
                        </div>
                        
                         <div class="manage_weeding_item_divider">&nbsp;</div>
                    </div>
            </cfoutput>
            <cfcatch>
            	<cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
    </cffunction>
    
	<cffunction name="edit_bib" access="remote" returntype="any">
        <cfargument name="bib_ID" required="yes" type="numeric">
        <cfargument name="comment" required="no" type="string">
        <cfargument name="special_collections" required="no" type="string">
        <cfargument name="needs_review" required="no" type="string">
        <cfargument name="special_collections_decision" required="no" type="string">
        <cfargument name="no_weed" required="no" type="string">
        <cfargument name="printed" required="no" type="string">
        
        <cfif not(
				isdefined("session.authorization.admin") 
				or isdefined("session.authorization.liaison") 
				or isdefined("session.authorization.archives")
				or (isdefined("session.authorization.cataloging") and isdefined("arguments.printed"))
			)
		>
        	<cfthrow type="Not authorized">
        </cfif>
        
		<cftry>
        	<cfif isdefined("session.authorization.cataloging")>
                <cfquery name="editBib" datasource="#application.dsn.library_rw#">
                    UPDATE
                        weeding_bib
                    SET
						<cfif arguments.printed eq 'yes'>
                        	printed = 'yes',
                        <cfelse>
                        	printed = NULL,
                        </cfif>
                        last_updated = #Now()#,
                        last_updated_ID = <cfqueryparam value="#session.authorization.userid#" cfsqltype="cf_sql_integer">
                    WHERE
                        bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_varchar">
                </cfquery>
                <cfreturn 1>
            </cfif>
            <cfinvoke
                method="get_bibs"
                bib_ID="#arguments.bib_ID#"
                returnvariable="bib"
            />
            <cfif (
            	isdefined("arguments.special_collections_decision") 
				and arguments.special_collections_decision eq 'no'
				and isdefined("bib.no_weed") 
				and bib.no_weed eq ''
				) OR (
				isdefined("arguments.needs_review") 
				and arguments.needs_review neq 'yes' 
				and isdefined("bib.needs_review") 
				and bib.needs_review eq 'yes'
				) OR (
				isdefined("arguments.special_collections") 
				and arguments.special_collections neq 'yes' 
				and isdefined("bib.special_collections") 
				and bib.special_collections eq 'yes'
				)
			>
				<!--- declining a non-noweed special collections item or removing item from a queue resets date added --->
                <cfset review_start = DateFormat(max(DateAdd('d', 7, Now()),live_date), 'yyyy-mm-dd')>
            </cfif>

            <cfquery name="editBib" datasource="#application.dsn.library_rw#">
                UPDATE
                    weeding_bib
                SET
                	<cfif isdefined("arguments.comment")>
                    	comment = <cfqueryparam value="#arguments.comment#" cfsqltype="cf_sql_varchar">,
                    </cfif>
                    <cfif isdefined("arguments.special_collections")>
                    	<cfif arguments.special_collections eq 'yes'>
                    		special_collections = 'yes',
                        <cfelse>
	                    	special_collections = NULL,
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.needs_review")>
                    	<cfif arguments.needs_review eq 'yes'>
                    		needs_review = 'yes',
                        <cfelse>
	                    	needs_review = NULL,
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.special_collections_decision")>
                    	<cfif arguments.special_collections_decision eq 'yes' or arguments.special_collections_decision eq 'no'>
                        	special_collections_decision = <cfqueryparam value="#arguments.special_collections_decision#" cfsqltype="cf_sql_varchar">,
                        <cfelse>
                        	special_collections_decision = NULL,
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.no_weed")>
                    	<cfif arguments.no_weed eq 'yes'>
                        	no_weed = 'yes',
                        <cfelse>
                        	no_weed = NULL,
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.printed")>
                    	<cfif arguments.printed eq 'yes'>
                        	printed = 'yes',
                        <cfelse>
                        	printed = NULL,
                        </cfif>
                    </cfif>
                    <cfif isdefined("review_start")>
	                    review_start = <cfqueryparam value="#review_start#" cfsqltype="cf_sql_date">,
                    <cfelseif 
						(isdefined("arguments.special_collections") and arguments.special_collections eq 'yes')
						OR (isdefined("arguments.needs_review") and arguments.needs_review eq 'yes')
					> <!--- if either of these is getting flagged, then clear the review period --->
                    	review_start = NULL,
                    </cfif>
                	last_updated = #Now()#,
                    last_updated_ID = <cfqueryparam value="#session.authorization.userid#" cfsqltype="cf_sql_integer">
                WHERE
                    bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfreturn 1>
	        <cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
	</cffunction>

    <cffunction name="get_bib_departments" access="remote" returntype="query">
    	<cfargument name="bib_ID" required="no" type="numeric">
        <cfargument name="distinct" required="no" type="string">

        <cfquery name="getBibDepartments" datasource="#application.dsn.library#">
        	SELECT
            	<cfif isdefined("arguments.distinct")>
                DISTINCT
                <cfelse>
                wbd.bib_ID,
                </cfif>
            	wbd.department_ID,
                d.name
            FROM
            	weeding_bib_department wbd
                INNER JOIN department d ON wbd.department_ID = d.ID
            <cfif isdefined("arguments.bib_ID")>
                    AND wbd.bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">
            </cfif>
            ORDER BY
            	d.name
        </cfquery>
		<cfreturn getBibDepartments>
    </cffunction>
    
    <cffunction name="get_bibs" access="public" returntype="any">
        <cfargument name="bib_ID" required="no" type="numeric" />
        <cfargument name="faculty_ID" required="no" type="numeric" />
        <cfargument name="item_barcode" required="no" type="numeric" />
        <cfargument name="librarian_ID" required="no" type="numeric" />
        <cfargument name="active" required="no" type="string" />
        <cfargument name="comment_added_after" required="no" type="date" />
        <cfargument name="date_added_after" required="no" type="date" />
        <cfargument name="department_ID" required="no" type="numeric" />
        <cfargument name="expired" required="no" type="string" />
        <cfargument name="expire_date" required="no" type="date" />
        <cfargument name="has_comments" required="no" type="string" />
        <cfargument name="acknowledged" required="no" type="string" />
        <cfargument name="needs_review" required="no" type="string" />
        <cfargument name="no_weed" required="no" type="string" />
        <cfargument name="printed" required="no" type="string" />
        <cfargument name="review_start_after" required="no" type="date" />
        <cfargument name="show_suppressed" required="no" type="string" />
        <cfargument name="sort" required="no" type="string" />
        <cfargument name="special_collections" required="no" type="string" />
        <cfargument name="special_collections_decision" required="no" type="string" />
        <cfargument name="title_kw" required="no" type="string" />
        <cfargument name="weed" required="no" type="string" />
		
        <cftry>
            <cfif isdefined("arguments.comment_added_after")>
                <cfset arguments.has_comments = 'yes'>
            </cfif>
            
            <cfquery name="weeding_bib" datasource="#application.dsn.library#">
                SELECT
                    <cfif isdefined("arguments.faculty_ID")>
                    	wic.comment "faculty_comment",
                        CONVERT(VARCHAR(10), wic.date, 120) "date",
                    <cfelseif isdefined("arguments.has_comments")>
                    	MAX(CONVERT(VARCHAR(10), wic.date, 120)) "comment_date",
                    </cfif>
                    wb.bib_ID,
                    wb.date_added,
                    wb.comment "librarian_comment",
                    wb.title,
                    wb.author,
                    wb.imprint,
                    wb.local_note,
                    wb.pub_dates_combined,
                    wb.special_collections,
                    wb.needs_review,
                    wb.no_weed,
                    wb.special_collections_decision,
                    wb.librarian_ID,
                    wb.review_start
                FROM
                    weeding_bib wb INNER JOIN weeding_item wi ON wb.bib_ID = wi.bib_ID
                    LEFT JOIN weeding_bib_department wbd ON wb.bib_ID = wbd.bib_ID
                    <cfif isdefined("arguments.has_comments") and arguments.has_comments eq 'yes'>
                    	INNER JOIN weeding_bib_comment wic ON (
                            wi.bib_ID = wic.bib_ID 
                            AND wic.comment IS NOT NULL
                            <cfif isdefined("arguments.acknowledged") and arguments.acknowledged eq 'yes'>
                                AND wic.acknowledged = 'yes'
                            <cfelseif isdefined("arguments.acknowledged") and arguments.acknowledged eq 'no'>
                                AND wic.acknowledged IS NULL
                            </cfif>
                            )
                    <cfelseif isdefined("arguments.has_comments") and arguments.has_comments eq 'no'>
                    	LEFT JOIN weeding_bib_comment wic ON
                        	wi.bib_ID = wic.bib_ID AND wic.acknowledged IS NULL
                    <cfelseif isdefined("arguments.faculty_ID")>
                    	LEFT JOIN weeding_bib_comment wic ON (
                        	wi.bib_ID = wic.bib_ID AND wic.faculty_ID = <cfqueryparam value="#arguments.faculty_ID#" cfsqltype="cf_sql_integer">)
                    </cfif>
                WHERE
                    wb.complete IS NULL
                    <cfif isdefined("arguments.title_kw")>
                    	<cfloop list="#arguments.title_kw#" index="kw" delimiters=" ">
                        	AND (
                            	wb.title LIKE <cfqueryparam value="#kw#%" cfsqltype="cf_sql_varchar">
                                OR wb.title LIKE <cfqueryparam value="% #kw#%" cfsqltype="cf_sql_varchar">
                                )
                        </cfloop>
                    </cfif>
                    <cfif isdefined("arguments.printed")>
                    	<cfif arguments.printed eq 'yes'>
                        	AND wb.printed = 'yes'
                        <cfelse>
                        	AND wb.printed IS NULL
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.has_comments") and arguments.has_comments eq 'no'>
                    	AND (
                            wic.comment IS NULL
                            <cfif isdefined("arguments.acknowledged") and arguments.acknowledged eq 'yes'>
                                OR wic.acknowledged = 'yes'
                            </cfif>
                        )
                    </cfif>
                    <cfif isdefined("arguments.bib_ID")>
                    	AND wb.bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">
                    </cfif>
                    <cfif isdefined("arguments.comment_added_after")>
                    	AND CONVERT(VARCHAR(10), wic.date, 120) >= CONVERT(VARCHAR(10), <cfqueryparam value="#arguments.comment_added_after#" cfsqltype="cf_sql_date">, 120)
                    </cfif>
                    <cfif isdefined("arguments.review_start_after")>
                    	AND CONVERT(VARCHAR(10), wb.review_start, 120) >= CONVERT(VARCHAR(10), <cfqueryparam value="#arguments.review_start_after#" cfsqltype="cf_sql_date">, 120)
                    </cfif>
                    <cfif isdefined("arguments.department_ID") and arguments.department_ID eq -1>
                    	AND wbd.department_ID Is Null
                    </cfif>
                    <cfif isdefined("arguments.department_ID") and arguments.department_ID neq -1>
                        AND wbd.department_ID = <cfqueryparam value="#arguments.department_ID#" cfsqltype="cf_sql_integer">
                    </cfif>
                    <cfif isdefined("arguments.librarian_ID")>
                        AND wb.librarian_ID = <cfqueryparam value="#arguments.librarian_ID#" cfsqltype="cf_sql_integer">
                    </cfif>
                    <cfif isdefined("arguments.faculty_ID")>
                    	<cfif not(isdefined("arguments.show_suppressed") and arguments.show-suppressed eq "yes")>
                            AND (
                                wic.suppress = 'no'
                                OR wic.suppress Is Null)
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.item_barcode")>
                        AND wi.item_barcode = <cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.special_collections")>
                    	<cfif arguments.special_collections eq 'yes'>
	                    	AND wb.special_collections = 'yes'
                            <cfif isdefined("arguments.special_collections_decision")>
                            	<cfif arguments.special_collections_decision eq 'yes' OR arguments.special_collections_decision eq 'no'>
	                            	AND wb.special_collections_decision = <cfqueryparam value="#arguments.special_collections_decision#" cfsqltype="cf_sql_varchar">
								</cfif>
                            <cfelse>
                            	AND wb.special_collections_decision IS NULL
                            </cfif>
                        <cfelseif arguments.special_collections eq 'no'>
	                    	AND (wb.special_collections <> 'yes' OR wb.special_collections IS NULL)
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.needs_review") and arguments.needs_review eq 'yes'>
                    	AND wb.needs_review = 'yes'
                    <cfelseif isdefined("arguments.needs_review") and arguments.needs_review eq 'no'>
                    	AND (wb.needs_review <> 'yes' OR wb.needs_review IS NULL)
                    </cfif>
                    <cfif isdefined("arguments.no_weed") and arguments.no_weed eq 'yes'>
                    	AND wb.no_weed = 'yes'
                    <cfelseif isdefined("arguments.no_weed") and arguments.no_weed eq 'no'>
                    	AND (wb.no_weed <> 'yes' OR wb.no_weed IS NULL)
                    </cfif>
                    <cfif isdefined("arguments.weed")>
                    	<cfif arguments.weed eq 'yes'>
                        	AND wb.no_weed IS NULL
                            AND (wb.special_collections IS NULL OR wb.special_collections_decision = 'no')
                            AND wb.needs_review IS NULL
                        <cfelseif arguments.weed eq 'no'>
                        	AND wb.no_weed = 'yes'
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.date_added_after")>
                    	AND
                        	wb.date_added > <cfqueryparam value="#arguments.date_added_after#" cfsqltype="cf_sql_date">
                    </cfif>
                    <cfif isdefined("arguments.expire_date")>
                    	AND
                            dateadd("d", #expire_interval#, wb.review_start)
                        > <cfqueryparam value="#arguments.expire_date#" cfsqltype="cf_sql_date">
                    </cfif>
                    <cfif isdefined("arguments.expired")>
                    	<cfif arguments.expired eq 'yes'>
                            AND
                                dateadd("d", #expire_interval#, wb.review_start)
	                            < <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
                        <cfelseif arguments.expired eq 'no'>
                            AND
                                dateadd("d", #expire_interval#, wb.review_start)
	                            > <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
                        </cfif>
                    </cfif>
                    <cfif isdefined("arguments.active")>
                    	AND 
                        	(
								<cfif arguments.active eq 'no'>
	                                wb.review_start IS NULL OR NOT
                                </cfif>
                                wb.review_start < <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
                                AND dateadd("d", #expire_interval#, wb.review_start) > <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
                                AND wb.no_weed IS NULL
                                AND (wb.special_collections IS NULL OR wb.special_collections_decision = 'no')
                                AND wb.needs_review IS NULL
                            )
                    </cfif>
                GROUP BY
                	<cfif isdefined("arguments.faculty_ID")>
                    	wic.comment,
                        CONVERT(VARCHAR(10), wic.date, 120),
                    </cfif>
                    wb.bib_ID,
                    wb.date_added,
					wb.comment,
                    wb.title,
                    wb.author,
                    wb.imprint,
                    wb.local_note,
                    wb.pub_dates_combined,
                    wb.special_collections,
                    wb.needs_review,
                    wb.no_weed,
                    wb.special_collections_decision,
                    wb.librarian_ID,
                    wb.review_start
                ORDER BY
                	<cfif isdefined("arguments.sort")>
                    	<cfif arguments.sort eq "title">
                        	wb.title,
                        <cfelseif arguments.sort eq "author">
                        	wb.author,
                        <cfelseif arguments.sort eq "call_no">
                        	MIN(wi.normalized_call_no),
                        <cfelseif arguments.sort eq "pubdate">
                        	wb.pub_dates_combined DESC,
                        </cfif>
                    </cfif>
					<cfif isdefined("arguments.has_comments")>
                        MAX(wic.date) DESC,
                    </cfif>
                    wb.date_added DESC,
                    wb.review_start DESC<cfif not(isdefined("arguments.sort") and arguments.sort eq 'title')>,
                    wb.title ASC</cfif>
            </cfquery>
            
            <cfreturn weeding_bib />
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
	</cffunction>

    <cffunction name="get_faculty_comments" returntype="query">
    	<cfargument name="bib_ID" type="numeric" required="yes">

        <cfquery name="getFacultyComments" datasource="#application.dsn.library#">
        	SELECT
            	faculty_ID,
                comment,
                acknowledged,
                date,
                '' "name"
            FROM
            	weeding_bib_comment
            WHERE
            	bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif getFacultyComments.recordcount eq 0>
        	<cfreturn getFacultyComments>
        </cfif>
        <cfloop query="getFacultyComments">
        	<cfinvoke
            	component="#application.voyager.cfc#"
                method="get_patron"
                iid="#getFacultyComments.faculty_ID#"
                returnvariable="patron"
            />
			<cfset getFacultyComments["name"][currentrow] = patron.lastname & ", " & patron.firstname>
        </cfloop>
        <cfreturn getFacultyComments>
    </cffunction>

    <cffunction name="get_item_stats" returntype="query">
    	<cfargument name="item_barcode" required="yes" type="string">
		<cfset arguments.item_barcode = REReplace(arguments.item_barcode, '_', '')>
        <cfquery name="item_stats" datasource="#application.dsn.voyager#">
            SELECT
                i.historical_charges, 
                i.historical_browses,
                to_char(max(cta.charge_date), 'YYYY-MM-DD') "latest_circ"
            FROM
                item i INNER JOIN item_barcode ib ON i.item_id = ib.item_id
                LEFT JOIN circ_trans_archive cta ON cta.item_id = i.item_id
            WHERE
	            ib.item_barcode = <cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">
            GROUP BY
                i.historical_charges, 
                i.historical_browses
        </cfquery>
        <cfreturn item_stats>
    </cffunction>
    
	<cffunction name="get_items" access="remote" returntype="any">
        <cfargument name="item_barcode" required="no" type="numeric" />
        <cfargument name="bib_ID" required="no" type="numeric" />
		
        <cftry>
            <cfquery name="item_records" datasource="#application.dsn.library#">
            	SELECT
                    '_' + wi.item_barcode item_barcode, <!--- JavaScript has a nasty tendency to convert barcodes into exponential notation, so we prepend a _ to the barcode in the initial query here and strip it off later --->
                    wi.librarian_ID,
                    wi.date_added,
                    wi.bib_ID,
                    wi.display_call_no,
                    wi.item_enum,
                    wi.chron,
                    wi.item_year,
                    wi.copy_number,
                    wi.location_code
                FROM
                    weeding_item wi
                WHERE
                	wi.complete IS NULL
                	<cfif isdefined("arguments.item_barcode")>
	                    AND wi.item_barcode = <cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.bib_ID")>
                    	AND wi.bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_bigint">
                    </cfif>
                ORDER BY
                	wi.location_code,
                    wi.normalized_call_no,
                	wi.copy_number,
                    convert(int, substring(substring(wi.item_enum, PATINDEX('%[0-9]%', wi.item_enum + 'z'), len(wi.item_enum)) + 'z', 1, PATINDEX('%[^0-9]%', substring(wi.item_enum, PATINDEX('%[0-9]%', wi.item_enum + 'z'), len(wi.item_enum)) + 'z') - 1)), <!--- numeric portion of item_enum --->
                    wi.chron,
                    wi.item_year
            </cfquery>
            
            <cfreturn item_records />
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
	</cffunction>
    
    <cffunction name="get_subscriptions" returntype="query">
    	<cfquery name="subscriptions" datasource="#application.dsn.library#">
        	SELECT
            	s.faculty_ID,
                s.department_ID,
                CASE
                	WHEN s.department_ID = -1 THEN 'No conspectus match'
                    ELSE d.name
                END "name"
            FROM
            	weeding_department_subscription s LEFT JOIN department d on s.department_ID = d.ID
            ORDER BY
            	s.faculty_ID
        </cfquery>
        <cfreturn subscriptions>
    </cffunction>
    
    <cffunction name="is_subscribed" returntype="string">
    	<cfargument name="faculty_ID" type="numeric" required="yes">
        <cfargument name="department_ID" type="numeric" required="yes">
        <cfquery name="getDeptSubscription" datasource="#application.dsn.library#">
        	SELECT *
            FROM weeding_department_subscription
            WHERE
            	faculty_ID = <cfqueryparam value="#arguments.faculty_ID#" cfsqltype="cf_sql_integer">
                AND department_ID = <cfqueryparam value="#arguments.department_ID#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif getDeptSubscription.recordcount eq 0>
	        <cfreturn 'no'>
        <cfelse>
        	<cfreturn 'yes'>
        </cfif>
    </cffunction>
    
    <cffunction name="mark_printed" returntype="any">
    	<cfargument name="bib_IDs" type="string" required="yes">
        <cftry>
        	<cfif not(isdefined("session.authorization.userid"))>
            	<cfthrow type="Not authorized">
            </cfif>
            
        	<cfset arguments.bib_IDs = REReplace(arguments.bib_IDs, "[^0-9,]", "", "ALL")>
            <cfif len(arguments.bib_IDs) eq 0>
            	<cfreturn 0>
            </cfif>
            <cfquery datasource="#application.dsn.library_rw#">
            	UPDATE
                	weeding_bib
                SET
                	printed = 'yes',
                    last_updated = #Now()#,
                    last_updated_ID = <cfqueryparam value="#session.authorization.userid#" cfsqltype="cf_sql_integer">
                WHERE
                	bib_ID IN (#arguments.bib_IDs#)
            </cfquery>
            
            <cfreturn 1>
            
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="overnight" returntype="any">
    	<cftry>
            <cfinvoke
                method="update_printed"
                returnvariable="printed_count"
            />
            
            <cfinvoke
            	method="update_complete"
                returnvariable="complete_count"
            />
            
            <cfset result = ''>
            
            <cfif complete_count gt 0>
            	<cfset result &= "<p>Items completed (withdrawn/transferred): " & complete_count>
            </cfif>
            
            <cfif printed_count gt 0>
            	<cfset result &= "<p>Titles reverted from printed queue: " & printed_count>
            </cfif>
            
            <cfreturn result>
            
            <cfcatch>
                <cfinvoke
                    component="#application.miscellaneous.cfc#"
                    method="error_notification"
                    detail="#cfcatch#"
                />
                <cfreturn ''>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="update_complete" returntype="any">
    	<cftry>
            <cfinvoke
                component="#application.voyager.cfc#"
                method="get_items"
                item_status="withdrawn"
                returnvariable="voyager_withdrawn"
            />
            
            <cfinvoke
                component="#application.voyager.cfc#"
                method="get_items"
                location_code="gsc%"
                returnvariable="voyager_scc"
            />

            <cfquery name="weeding_items" datasource="#application.dsn.library#">
            	SELECT
                	wi.item_barcode
                FROM
                	weeding_item wi
                WHERE
                	wi.complete IS NULL
            </cfquery>
            
            <cfquery name="completed_items" dbtype="query">
            	SELECT
                	weeding_items.item_barcode
                FROM
                	voyager_withdrawn,
                    weeding_items
                WHERE
                	weeding_items.item_barcode = voyager_withdrawn.item_barcode
                UNION
                SELECT
                	weeding_items.item_barcode
                FROM
                	voyager_scc,
                    weeding_items
                WHERE
                	weeding_items.item_barcode = voyager_scc.item_barcode
            </cfquery>
            
            <cfif completed_items.recordcount eq 0>
            	<cfreturn 0>
            </cfif>
            
            <cfloop query="completed_items">
            	<cfquery name="complete_item" datasource="#application.dsn.library_rw#">
                	UPDATE
                    	weeding_item
                    SET
                        complete = 'yes',
                        last_updated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
                    WHERE
                    	item_barcode = <cfqueryparam value="#completed_items.item_barcode#" cfsqltype="cf_sql_varchar">
                </cfquery>
            </cfloop>
           	
            <cfquery name="complete_bibs" datasource="#application.dsn.library_rw#">
                UPDATE
                	weeding_bib
                SET
                	complete = 'yes',
                    last_updated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
                WHERE
	                bib_ID in (
                        SELECT DISTINCT wb.bib_ID
                        FROM weeding_bib wb
                            INNER JOIN weeding_item wi on wb.bib_id = wi.bib_id and wi.complete = 'yes'
                            LEFT JOIN weeding_item wi_active on wb.bib_id = wi_active.bib_id and wi_active.complete IS NULL
                        WHERE wi_active.item_barcode IS NULL
	                        AND wb.complete IS NULL
                    )
            </cfquery>
            
            <cfreturn completed_items.recordcount>
            
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="update_printed" returntype="any">
    	<cftry>
        	<cfquery name="expired_printed" datasource="#application.dsn.library#">
            	SELECT
                	wb.bib_ID
                FROM
                	weeding_bib wb
                WHERE
                	wb.printed = 'yes'
                    AND wb.complete IS NULL
                    AND wb.last_updated < <cfqueryparam value="#DateAdd('d', print_expire_interval * -1, Now())#" cfsqltype="cf_sql_date">
            </cfquery>
            
            <cfquery name="update_expired" datasource="#application.dsn.library_rw#">
            	UPDATE weeding_bib
                SET
                	printed = NULL,
                    last_updated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">,
                    last_updated_ID = NULL
                WHERE
                	printed = 'yes'
                    AND complete IS NULL
                    AND last_updated < <cfqueryparam value="#DateAdd('d', print_expire_interval * -1, Now())#" cfsqltype="cf_sql_date">
            </cfquery>
            
            <cfreturn expired_printed.recordcount>
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
</cfcomponent>
