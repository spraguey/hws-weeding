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

<cfcomponent name="voyager">

	<cffunction name="get_bibs" access="public" returntype="any">
		<cfargument name="item_barcode_recordset" type="query" required="no">
        <cfargument name="item_barcodes" type="string" required="no">
        <cfargument name="marc_fields" type="string" required="no">
        <cfargument name="bib_ID" type="numeric" required="no">
        <cfargument name="bib_ID_recordset" type="query" required="no">
        
		<cftry>
			<cfif isdefined("arguments.item_barcode_recordset") AND arguments.item_barcode_recordset.recordcount neq 0>
	            <cfset item_barcode_list = ValueList(arguments.item_barcode_recordset.item_barcode)>
			</cfif>
			<cfquery name="getBibs" datasource="#application.dsn.voyager#">
				SELECT DISTINCT
					<cfif isdefined("arguments.marc_fields")>
                        <cfloop list="#arguments.marc_fields#" index="field">
                        	<cfif isnumeric(field) and len(field) eq 3>
                            	HOBARTDB.GETBIBTAG(bd.BIB_ID, '#field#') "field_#field#",
                                <cfset need_bib_data = 'yes'>
                            </cfif>
                        </cfloop>
                    </cfif>
					<cfif isdefined("arguments.item_barcode_recordset")>
						ib.ITEM_BARCODE,
					</cfif>
					bt.BIB_ID,
					bt.TITLE,
					bt.AUTHOR,
					bt.ISBN,
					bt.EDITION,
					bt.PUB_DATES_COMBINED,
					bt.IMPRINT
				FROM
					BIB_TEXT bt
                    <cfif isdefined("need_bib_data")>
                    	INNER JOIN BIB_DATA bd ON bt.BIB_ID = bd.BIB_ID
                    </cfif>
					<cfif isdefined("arguments.item_barcode_recordset") or isdefined("item_barcodes")>
                    	INNER JOIN BIB_MFHD bm ON bt.BIB_ID = bm.BIB_ID
                        INNER JOIN MFHD_ITEM mi ON bm.MFHD_ID = mi.MFHD_ID
                        INNER JOIN ITEM_BARCODE ib ON mi.ITEM_ID = ib.ITEM_ID
					</cfif>
				WHERE
                	1=1
                    <cfif isdefined("arguments.bib_ID")>
                    	AND bt.BIB_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.bib_ID_recordset")>
                    	AND bt.BIB_ID IN (#ListQualify(ValueList(arguments.bib_ID_recordset.bib_ID), "'", ", ", "ALL")#)
                    </cfif>
					<cfif isdefined("arguments.item_barcode_recordset")>
						AND ib.ITEM_BARCODE IN (#ListQualify(item_barcode_list, "'", ",", "ALL")#)
                    <cfelseif isdefined("arguments.item_barcodes")>
						<cfset tmparray = ListToArray(arguments.item_barcodes)>
                        <cfloop from="#ArrayLen(tmparray)#" to="1" step="-1" index="i">
                            <cfif Len(tmparray[i]) neq 14>
                                <cfset arraydeleteat(tmparray, i)>
                            </cfif>
                        </cfloop>
                        
                        AND ib.ITEM_BARCODE IN (#ListQualify(ArrayToList(tmparray, ","), "'", ",", "ALL")#)
					</cfif>
					
			</cfquery>
			<cfreturn getBibs>
			<cfcatch>
				<cfset temp = StructNew()>
				<cfset temp.catch = cfcatch>
                <cfif isdefined("item_barcode_list")>
					<cfset temp.item_barcode_list = item_barcode_list>
                </cfif>
				<cfreturn temp>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="get_bib_mfhds" access="public" returntype="any">
		<cfargument name="item_barcode_recordset" type="query" required="no">
        <cfargument name="item_barcodes" type="string" required="no">
        <cfargument name="marc_fields" type="string" required="no">
        <cfargument name="item_status" type="numeric" required="no">
        <cfargument name="bib_ID" type="numeric" required="no">
        
		<cftry>
			<cfif isdefined("arguments.item_barcode_recordset") AND arguments.item_barcode_recordset.recordcount neq 0>
	            <cfset item_barcode_list = ValueList(arguments.item_barcode_recordset.item_barcode)>
			</cfif>
			<cfquery name="getBibs" datasource="#application.dsn.voyager#">
				SELECT DISTINCT
					<cfif isdefined("arguments.marc_fields")>
                        <cfloop list="#arguments.marc_fields#" index="field">
                        	<cfif isnumeric(field) and len(field) eq 3>
                            	HOBARTDB.GETBIBTAG(bd.BIB_ID, '#field#') "field_#field#",
                                <cfset need_bib_data = 'yes'>
                            </cfif>
                        </cfloop>
                    </cfif>
					<cfif isdefined("arguments.item_barcode_recordset")>
						ib.ITEM_BARCODE,
					</cfif>
					bt.BIB_ID,
					bt.TITLE,
					bt.AUTHOR,
					bt.ISBN,
					bt.EDITION,
					bt.PUB_DATES_COMBINED,
					bt.IMPRINT,
                    mm.DISPLAY_CALL_NO,
                    mi.ITEM_ENUM,
                    mi.CHRON,
                    mi.YEAR,
                    i.COPY_NUMBER,
                    pl.LOCATION_NAME "PERM_LOCATION_NAME",
                    tl.LOCATION_NAME "TEMP_LOCATION_NAME"<cfif isdefined("arguments.item_status")>,
                    its.item_status</cfif>
				FROM
					BIB_TEXT bt
                    <cfif isdefined("need_bib_data")>
                    	INNER JOIN BIB_DATA bd ON bt.BIB_ID = bd.BIB_ID
                    </cfif>
                    INNER JOIN BIB_MFHD bm ON bt.BIB_ID = bm.BIB_ID
                    INNER JOIN MFHD_MASTER mm ON bm.MFHD_ID = mm.MFHD_ID
                    INNER JOIN MFHD_ITEM mi ON bm.MFHD_ID = mi.MFHD_ID
                    INNER JOIN ITEM i ON mi.ITEM_ID = i.ITEM_ID
                    INNER JOIN ITEM_BARCODE ib ON mi.ITEM_ID = ib.ITEM_ID
                    <cfif isdefined("arguments.item_status")>
	                    INNER JOIN ITEM_STATUS its ON i.ITEM_ID = its.ITEM_ID
                    </cfif>
                    INNER JOIN LOCATION pl ON i.PERM_LOCATION = pl.LOCATION_ID
                    LEFT JOIN LOCATION tl ON i.TEMP_LOCATION = tl.LOCATION_ID
				WHERE
                	1=1
                    <cfif isdefined("arguments.bib_ID")>
                    	AND bt.bib_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_bigint">
                    </cfif>
					<cfif isdefined("arguments.item_barcode_recordset")>
						AND ib.ITEM_BARCODE IN (#ListQualify(item_barcode_list, "'", ",", "ALL")#)
                    <cfelseif isdefined("arguments.item_barcodes")>
						<cfset tmparray = ListToArray(arguments.item_barcodes)>
                        <cfloop from="#ArrayLen(tmparray)#" to="1" step="-1" index="i">
                            <cfif Len(tmparray[i]) neq 14>
                                <cfset arraydeleteat(tmparray, i)>
                            </cfif>
                        </cfloop>
                        
                        AND ib.ITEM_BARCODE IN (#ListQualify(ArrayToList(tmparray, ","), "'", ",", "ALL")#)
					</cfif>
					<cfif isdefined("arguments.item_status")>
                    	AND its.ITEM_STATUS = <cfqueryparam value="#arguments.item_status#" cfsqltype="cf_sql_varchar">
                    </cfif>
			</cfquery>
			<cfreturn getBibs>
			<cfcatch>
				<cfset temp = StructNew()>
				<cfset temp.catch = cfcatch>
                <cfif isdefined("item_barcode_list")>
					<cfset temp.item_barcode_list = item_barcode_list>
                </cfif>
				<cfreturn temp>
			</cfcatch>
		</cftry>
	</cffunction>

    <cffunction name="get_callno_from_barcode" access="public" returntype="query">
        <cfargument name="barcode" type="string" required="yes">
        <cfquery name="getCallno" datasource="#application.dsn.voyager#">
            SELECT
            	LOCATION_ID,
                NORMALIZED_CALL_NO,
                DISPLAY_CALL_NO,
                ITEM_ENUM,
                CHRON,
                YEAR,
                SUPPRESS_IN_OPAC,
            FROM
                ITEM_BARCODE,
                MFHD_ITEM,
                MFHD_MASTER
            WHERE
                ITEM_BARCODE.ITEM_ID = MFHD_ITEM.ITEM_ID
                AND MFHD_ITEM.MFHD_ID = MFHD_MASTER.MFHD_ID
                AND ITEM_BARCODE.ITEM_BARCODE = <cfqueryparam value="#arguments.barcode#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfreturn getCallno>
    </cffunction>
    
	<cffunction name="get_catalog_url" access="public" returntype="string">
    	<cfargument name="bib_ID" required="no" type="numeric">
		<cfset catalog_base = 'http://voyager.hws.edu'>
        <cfif isdefined("arguments.bib_ID")>
        	<cfset catalog_url = catalog_base & '/vwebv/holdingsInfo?bibId=' & arguments.bib_ID>
            <cfreturn catalog_url>
        <cfelseif isdefined("arguments.title")>
        	<cfset arguments.title = REReplace(arguments.title, ' ', '+', 'all')>
        	<cfset catalog_url = catalog_base & "/vwebv/search?searchArg=" & arguments.title & "&searchCode=TKEY^&limitTo=none&recCount=25&searchType=1&page.search.search.button=Search">
            <cfreturn catalog_url>
        </cfif>
        <cfreturn catalog_base>
    </cffunction>

    <!--- get department name from IID --->
    <cffunction name="get_dept" access="public" returntype="string">
        <cfargument name="iid" type="numeric" required="yes">
        <cftry>
            <cfinvoke
                method="get_department_by_iid"
                iid="#arguments.iid#"
                returnvariable="dept_ID"
            />
    
            <cfinvoke
                component="cfc.miscellaneous"
                method="get_department_name"
                returnvariable="dept"
                dept_id="#dept_id#"
            >
            <cfreturn dept>
            <cfcatch>
            	<cfreturn 'Unknown department'>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- get department ID from IID --->
    <cffunction name="get_department_by_iid" access="public" returntype="numeric">
        <cfargument name="iid" type="numeric" required="yes">
        <cfquery name="lookupRequestorDepartment" datasource="#application.dsn.library#">
            SELECT
                department_ID
            FROM
                requestor_department
            WHERE
                requestor_ID = <cfqueryparam value="#arguments.iid#" cfsqltype="cf_sql_bigint">
        </cfquery>
        <cfif lookupRequestorDepartment.recordcount eq 1>
            <cfreturn lookupRequestorDepartment.department_ID>
        </cfif>
        
        <!--- not found in lookup table --->
        <cfif len(arguments.iid) lt 8> <!--- iid is dept_id --->
            <cfquery name="lookupDepartment" datasource="#application.dsn.library#">
                SELECT
                    ID
                FROM
                    department
                WHERE
                    ID = <cfqueryparam value="#arguments.iid#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfif lookupDepartment.recordcount eq 1>
                <cfquery name="updateRequestorDepartment" datasource="#application.dsn.library_rw#">
                    INSERT INTO
                        requestor_department (requestor_ID, department_ID)
                    VALUES (
                        <cfqueryparam value="#arguments.iid#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#lookupDepartment.ID#" cfsqltype="cf_sql_integer">
                    )
                </cfquery>
                <cfreturn lookupDepartment.ID>
            <cfelse>
                <cfreturn 0>
            </cfif>
        <cfelse> <!--- cwid --->
            <cfquery name="lookupVoyagerDepartment" datasource="#application.dsn.voyager#">
                SELECT
                    ADDRESS_LINE1 "dept"
                FROM
                    PATRON,
                    PATRON_ADDRESS
                WHERE
                    PATRON.PATRON_ID = PATRON_ADDRESS.PATRON_ID
                    AND PATRON_ADDRESS.ADDRESS_TYPE = 1
                    AND PATRON.INSTITUTION_ID = <cfqueryparam value="#arguments.iid#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <cfif lookupVoyagerDepartment.recordcount eq 1>
                <cfquery name="verifyDepartment" datasource="#application.dsn.library#">
                    SELECT
                        ID,
                        see
                    FROM
                        department
                    WHERE
                        name = <cfqueryparam value="#lookupVoyagerDepartment.dept#" cfsqltype="cf_sql_varchar">
                </cfquery>
                <cfif verifyDepartment.recordcount eq 1>
                    <cfif verifyDepartment.see neq ''>
                        <cfset departmentId = verifyDepartment.see>
                    <cfelse>
                        <cfset departmentId = verifyDepartment.ID>
                    </cfif>
                    <cfquery name="updateRequestorDepartment" datasource="#application.dsn.library_rw#">
                        INSERT INTO
                            requestor_department (requestor_ID, department_ID)
                        VALUES (
                            <cfqueryparam value="#arguments.iid#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#departmentId#" cfsqltype="cf_sql_integer">
                        )
                    </cfquery>
                    <cfreturn departmentId>
                <cfelse>
                    <cfreturn 0>
                </cfif>
             <cfelse>
                <cfreturn 0>
             </cfif>
         </cfif>
    </cffunction>
    
    <cffunction name="get_item_history" access="public" returntype="any">
    	<cfargument name="item_barcode" type="string" required="yes">
        <cftry>
        	<cfif not(isdefined("session.authorization.circulation") or isdefined("session.authorization.helpdesk") or isdefined("session.authorization.admin"))>
            	<cfthrow type="Not authorized">
            </cfif>
            
            <cfquery name="item_history" datasource="#application.dsn.voyager#">
            	SELECT * FROM (
                    SELECT
                        p.first_name,
                        p.last_name,
                        p.institution_ID,
                        pg.patron_group_name,
                        to_char(cta.charge_date, 'yyyy-mm-dd HH24:MI:SS') "charge_date",
                        to_char(cta.due_date, 'yyyy-mm-dd HH24:MI:SS') "due_date",
                        to_char(cta.discharge_date, 'yyyy-mm-dd HH24:MI:SS') "discharge_date",
                        cta.renewal_count,
                        to_char(cta.recall_date, 'yyyy-mm-dd HH24:MI:SS') "recall_date",
                        to_char(cta.recall_due_date, 'yyyy-mm-dd HH24:MI:SS') "recall_due_date",
                        pa.address_line1 "email_address"
                    FROM
                        item_barcode ib
                        INNER JOIN circ_trans_archive cta on ib.item_ID = cta.item_ID
                        INNER JOIN patron p ON cta.patron_ID = p.patron_ID
                        INNER JOIN circ_policy_matrix cpm on cpm.circ_policy_matrix_ID = cta.circ_policy_matrix_ID
                        INNER JOIN circ_policy_group cpg on cpg.circ_group_id = cpm.circ_group_id
                        INNER JOIN patron_group pg on cta.patron_group_ID = pg.patron_group_ID
                        INNER JOIN patron_address pa on pa.address_type = '3' and p.patron_ID = pa.patron_ID
                    WHERE
                        ib.item_barcode = <cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">
                        <cfif isdefined("session.authorization.circulation")>
                            AND cpg.circ_group_ID = 1
                        <cfelseif isdefined("session.authorization.helpdesk")>
                            AND cpg.circ_group_ID = 2
                        </cfif>
                    ORDER BY
                    	cta.charge_date DESC
                 )
                 WHERE ROWNUM = 1
            </cfquery>
            
            <cfreturn item_history>
            
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="get_item_status" access="public" returntype="any">
    	<cfargument name="item_barcode" type="string" required="yes">
        <cfquery name="itemStatus" datasource="#application.dsn.voyager#">
            SELECT
            	ist.ITEM_STATUS_TYPE,
                ist.ITEM_STATUS_DESC,
                ibs.BARCODE_STATUS_TYPE,
                ibs.BARCODE_STATUS_DESC
            FROM
            	ITEM_BARCODE ib INNER JOIN ITEM_STATUS its ON ib.ITEM_ID = its.ITEM_ID
                INNER JOIN ITEM_STATUS_TYPE ist ON its.ITEM_STATUS = ist.ITEM_STATUS_TYPE
                INNER JOIN ITEM_BARCODE_STATUS ibs ON ib.BARCODE_STATUS = ibs.BARCODE_STATUS_TYPE
            WHERE
                ib.ITEM_BARCODE = '#arguments.item_barcode#'
            ORDER BY
                its.ITEM_STATUS DESC <!--- this makes Withdrawn supersede lost, * supersede charged/not, etc. --->
        </cfquery>
        
        <cfreturn itemStatus>
    </cffunction>
    
    <cffunction name="get_items" access="public" returntype="any">
        <cfargument name="lc_class" type="string" required="no">
        <cfargument name="location_code" type="string" required="no">
        <cfargument name="location_ID" type="string" required="no">
        <cfargument name="normalized_start_num" type="string" required="no">
        <cfargument name="normalized_end_num" type="string" required="no">
        <cfargument name="countonly" type="string" required="no">
        <cfargument name="bib_ID" type="numeric" required="no">
        <cfargument name="item_barcode" type="string" required="no">
        <cfargument name="item_type" type="string" required="no">
        <cfargument name="item_status" type="string" required="no">
        
        <cftry>
        	<cfif isdefined("arguments.location_code")>
            	<cfset arguments.location_code = UCase(arguments.location_code)>
            </cfif>
            
        	<cfquery name="items" datasource="#application.dsn.voyager#">
            	SELECT
				<cfif isdefined("arguments.countonly") and arguments.countonly eq 'yes'>
                    count(DISTINCT ib.ITEM_BARCODE) "item_count"
                <cfelse>
                	ib.ITEM_BARCODE,
                    i.ITEM_ID,
                    l.LOCATION_CODE,
                    mi.ITEM_ENUM,
                    mi.CHRON,
                    mi.YEAR,
					mm.MFHD_ID,
					mm.NORMALIZED_CALL_NO,
					mm.DISPLAY_CALL_NO,
                    bm.BIB_ID,
                    i.COPY_NUMBER, <!--- field order used in staff/admin/weeding/upload.cfm --->
                    ity.ITEM_TYPE_CODE,
                    ist.ITEM_STATUS_DESC
                </cfif>
                FROM
                	ITEM i INNER JOIN LOCATION l ON ((i.PERM_LOCATION = l.LOCATION_ID AND i.TEMP_LOCATION = 0) OR i.TEMP_LOCATION = l.LOCATION_ID)
                    INNER JOIN MFHD_ITEM mi ON mi.ITEM_ID = i.ITEM_ID
                    INNER JOIN MFHD_MASTER mm ON mi.MFHD_ID = mm.MFHD_ID
                    INNER JOIN ITEM_BARCODE ib ON (i.ITEM_ID = ib.ITEM_ID AND ib.BARCODE_STATUS = '1')
                    INNER JOIN BIB_MFHD bm ON bm.MFHD_ID = mm.MFHD_ID
                    INNER JOIN ITEM_TYPE ity ON i.ITEM_TYPE_ID = ity.ITEM_TYPE_ID
                    INNER JOIN 
                    (
                    	SELECT
                        	its.ITEM_ID,
                        	MAX(its.ITEM_STATUS) ITEM_STATUS_ID
                    	FROM ITEM_STATUS its
						<cfif isdefined("arguments.item_status")>
                            INNER JOIN ITEM_STATUS_TYPE ist2 ON its.ITEM_STATUS = ist2.ITEM_STATUS_TYPE AND lower(ist2.ITEM_STATUS_DESC) = lower(<cfqueryparam value="#arguments.item_status#" cfsqltype="cf_sql_varchar">)
                        </cfif>
                        GROUP BY its.ITEM_ID
                    ) t1 ON t1.ITEM_ID = i.ITEM_ID
                    INNER JOIN ITEM_STATUS_TYPE ist ON t1.ITEM_STATUS_ID = ist.ITEM_STATUS_TYPE
                WHERE
                	<cfif not(isdefined("arguments.item_status"))>
                		ist.ITEM_STATUS_DESC <> 'Withdrawn'
                    <cfelse>
                    	1=1
                    </cfif>
                    <cfif isdefined("arguments.item_type")>
                    	AND lower(ity.ITEM_TYPE_CODE) = lower(<cfqueryparam value="#arguments.item_type#" cfsqltype="cf_sql_varchar">)
                    </cfif>
                    <cfif isdefined("arguments.item_barcode")>
                    	AND ib.item_barcode = <cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.bib_ID")>
                    	AND bm.BIB_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_biging">
                    </cfif>
                    <cfif isdefined("arguments.location_code")>
                    	AND l.LOCATION_CODE LIKE <cfqueryparam value="#arguments.location_code#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.location_ID")>
                    	AND l.LOCATION_ID = <cfqueryparam value="#arguments.location_ID#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.normalized_start_num")>
                    	AND mm.NORMALIZED_CALL_NO >= <cfqueryparam value="#arguments.normalized_start_num#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.normalized_end_num")>
                    	AND mm.NORMALIZED_CALL_NO <= <cfqueryparam value="#arguments.normalized_end_num#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.lc_class")>
                    	AND substr(mm.NORMALIZED_CALL_NO, 1, #Len(arguments.lc_class)#) = <cfqueryparam value="#arguments.lc_class#" cfsqltype="cf_sql_varchar">
                    </cfif>
                ORDER BY
                	l.LOCATION_CODE,
                    mm.NORMALIZED_CALL_NO,
                	i.COPY_NUMBER,
                    to_number(regexp_substr(mi.item_enum, '[0-9]+')),
                    mi.CHRON,
                    mi.YEAR
            </cfquery>
            
            <cfif isdefined("arguments.countonly") and arguments.countonly eq 'yes'>
            	<cfreturn items.item_count>
            </cfif>

            <cfreturn items>

        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="get_items_by_status" access="public" returntype="any">
    	<cfargument name="item_status_ID" type="numeric" required="no">
        <cfargument name="item_status_desc" type="string" required="no">
        <cfargument name="item_status_date_min" type="date" required="no">
        <cfargument name="item_status_date_max" type="date" required="no">
        <cfargument name="item_status_date_min_days" type="date" required="no">
        <cfargument name="item_status_date_max_days" type="date" required="no">
        
        <!--- this excludes suppressed mfhd/bib. if you want to get withdrawn status use get_items --->
        
        <cfif isdefined("arguments.item_status_date_min_days")>
        	<cfset arguments.item_status_date_min = DateAdd("d", (arguments.item_status_date_min_days * -1), Now())>
        </cfif>
        <cfif isdefined("arguments.item_status_date_max_days")>
        	<cfset arguments.item_status_date_max = DateAdd("d", (arguments.item_status_date_max_days * -1), Now())>
        </cfif>
        
        <cftry>
            <cfquery name="items_by_status" datasource="#application.dsn.voyager#">
                SELECT 
                    bt.TITLE,
                    bt.AUTHOR,
                    bt.BEGIN_PUB_DATE,
                    bt.PUBLISHER,
                    mm.DISPLAY_CALL_NO,
                    mm.NORMALIZED_CALL_NO,
                    it.ITEM_ID,
                    itb.ITEM_BARCODE,
                    mi.ITEM_ENUM,
                    its.ITEM_STATUS_DATE,
                    l.LOCATION_NAME
                FROM 
                    MFHD_MASTER mm INNER JOIN BIB_MFHD bm ON (mm.MFHD_ID = bm.MFHD_ID and mm.SUPPRESS_IN_OPAC = 'N')
                    INNER JOIN BIB_TEXT bt ON bt.BIB_ID = bm.BIB_ID
                    INNER JOIN MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
                    INNER JOIN ITEM it ON mi.ITEM_ID = it.ITEM_ID
                    INNER JOIN ITEM_BARCODE itb ON (it.ITEM_ID = itb.ITEM_ID and itb.BARCODE_STATUS = 1)
                    INNER JOIN ITEM_STATUS its ON it.ITEM_ID = its.ITEM_ID
                    INNER JOIN ITEM_STATUS_TYPE ist ON its.ITEM_STATUS = ist.ITEM_STATUS_TYPE
                    INNER JOIN LOCATION l ON (it.TEMP_LOCATION = l.LOCATION_ID OR (it.TEMP_LOCATION = 0 AND it.PERM_LOCATION = l.LOCATION_ID))
                WHERE
                	<cfif isdefined("arguments.item_status_ID")>
                    its.ITEM_STATUS = <cfqueryparam value="#arguments.item_status_ID#" cfsqltype="cf_sql_varchar">
                    <cfelseif isdefined("arguments.item_status_desc")>
                    lower(ist.ITEM_STATUS_DESC) = lower(<cfqueryparam value="#arguments.item_status_desc#" cfsqltype="cf_sql_varchar">)
                    <cfelse>
                        <cfthrow type="Item status not defined">
                    </cfif>
                    <cfif isdefined("arguments.item_status_date_min")>
                        AND to_char(its.ITEM_STATUS_DATE, 'yyyy-mm-dd') >= <cfqueryparam value="#DateFormat(arguments.item_status_date_min, 'yyyy-mm-dd')#" cfsqltype="cf_sql_varchar">
                    </cfif>
                    <cfif isdefined("arguments.item_status_date_max")>
	                    AND to_char(its.ITEM_STATUS_DATE, 'yyyy-mm-dd') <= <cfqueryparam value="#DateFormat(arguments.item_status_date_max, 'yyyy-mm-dd')#" cfsqltype="cf_sql_varchar">
                    </cfif>
                ORDER BY
                    l.LOCATION_NAME,
                    mm.NORMALIZED_CALL_NO
            </cfquery>
        	
            <cfreturn items_by_status>
            
        	<cfcatch>
            	<cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="get_location" access="public" returntype="query">
    	<cfargument name="location_name" type="string" required="no">
        <cfargument name="location_code" type="string" required="no">
        <cfargument name="location_ID" type="string" required="no">

        <cfquery name="getLocation" datasource="#application.dsn.voyager#">
        	SELECT
            	LOCATION_ID,
                LOCATION_CODE,
                LOCATION_NAME,
                MFHD_COUNT
            FROM
            	LOCATION
            WHERE
            	1=1
                <cfif isdefined("arguments.location_name")>
                	AND LOCATION_NAME Like <cfqueryparam value="#arguments.location_name#%" cfsqltype="cf_sql_varchar">
                </cfif>
                <cfif isdefined("arguments.location_code")>
                	AND lower(LOCATION_CODE) = lower(<cfqueryparam value="#arguments.location_code#" cfsqltype="cf_sql_varchar">)
                </cfif>
                <cfif isdefined("arguments.location_ID")>
                	AND LOCATION_ID = <cfqueryparam value="#arguments.location_ID#" cfsqltype="cf_sql_varchar">
                </cfif>
        </cfquery>
        
        <cfreturn getLocation>
    </cffunction>
    
    <cffunction name="get_location_stats" access="public" returntype="query">
    	<cfargument name="location_ID" type="string" required="yes">
    
		<cfset cutoff = right(year(now()) - 5, 1)>
        <cfset max_bucket = left(year(now()) - 5, 3) & cutoff>
        <cfset min_bucket = max_bucket - 40>
        
        <cfquery name="getLocationStats" datasource="#application.dsn.voyager#">
            SELECT
                LC_CLASS,
                sum(
                    case
                        when BUCKET = 'Unknown' then 0
						when to_number(BUCKET) < #min_bucket# then ITEM_COUNT 
						else 0
                    end
                ) as PRE_#min_bucket#,
                <cfloop from="#min_bucket#" to="#max_bucket#" step="10" index="i">
                    sum(
                        case
							when BUCKET = 'Unknown' then 0
                            when to_number(BUCKET) = #i# then ITEM_COUNT
							else 0
                        end
                    ) as b#i#_#i+9#,
                </cfloop>
                sum(
                    case
                        when BUCKET = 'Unknown' then ITEM_COUNT else 0
                    end
                ) as UNKNOWN,
                sum(ITEM_COUNT) as TOTAL
            FROM
            (
                SELECT
                    regexp_replace(MFHD_MASTER.NORMALIZED_CALL_NO, '^([A-Z]+)[^A-Z].*', '\1') as LC_CLASS,
                    case
                    	when regexp_like(BEGIN_PUB_DATE, '[^0-9u]', 'i') then 'Unknown'
                        when BEGIN_PUB_DATE Is Null then 'Unknown'
                        when BEGIN_PUB_DATE LIKE '%uu%' then 'Unknown'
                        when BEGIN_PUB_DATE LIKE '%u%' then concat(to_char(to_number(substr(BEGIN_PUB_DATE, 1, 3)) - 1), '#cutoff#')
                        when to_number(substr(BEGIN_PUB_DATE, 4, 1)) < #cutoff# then concat(to_char(to_number(substr(BEGIN_PUB_DATE, 1, 3)) - 1), '#cutoff#')
                        else concat(substr(BEGIN_PUB_DATE, 1, 3), '#cutoff#')
                    end as BUCKET,
                    count(ITEM.ITEM_ID) as ITEM_COUNT
                FROM
                    ITEM
                    INNER JOIN MFHD_ITEM ON ITEM.ITEM_ID = MFHD_ITEM.ITEM_ID
                    INNER JOIN MFHD_MASTER ON MFHD_MASTER.MFHD_ID = MFHD_ITEM.MFHD_ID
                    INNER JOIN BIB_MFHD ON BIB_MFHD.MFHD_ID = MFHD_MASTER.MFHD_ID
                    INNER JOIN BIB_TEXT ON BIB_TEXT.BIB_ID = BIB_MFHD.BIB_ID
                WHERE
                    PERM_LOCATION = <cfqueryparam value="#arguments.location_ID#" cfsqltype="cf_sql_varchar">
                    AND MFHD_MASTER.CALL_NO_TYPE = '0'
                GROUP BY
                    regexp_replace(MFHD_MASTER.NORMALIZED_CALL_NO, '^([A-Z]+)[^A-Z].*', '\1'),
                    case
                    	when regexp_like(BEGIN_PUB_DATE, '[^0-9u]', 'i') then 'Unknown'
                        when BEGIN_PUB_DATE Is Null then 'Unknown'
                        when BEGIN_PUB_DATE LIKE '%uu%' then 'Unknown'
                        when BEGIN_PUB_DATE LIKE '%u%' then concat(to_char(to_number(substr(BEGIN_PUB_DATE, 1, 3)) - 1), '#cutoff#')
                        when to_number(substr(BEGIN_PUB_DATE, 4, 1)) < #cutoff# then concat(to_char(to_number(substr(BEGIN_PUB_DATE, 1, 3)) - 1), '#cutoff#')
                        else concat(substr(BEGIN_PUB_DATE, 1, 3), '#cutoff#')
                    end
            )
            GROUP BY
                LC_CLASS
            ORDER BY
                LC_CLASS
        </cfquery>
        
        <cfreturn getLocationStats>
    </cffunction>
    
	<cffunction name="get_mfhds" access="public" returntype="any">
		<cfargument name="item_barcode_recordset" type="query" required="no">
        <cfargument name="item_barcode" type="string" required="no">
        <cfargument name="bib_ID" type="numeric" required="no">
		<cftry>
			<cfif isdefined("arguments.item_barcode_recordset") AND arguments.item_barcode_recordset.recordcount neq 0>
	            <cfset item_barcode_list = ValueList(arguments.item_barcode_recordset.item_barcode)>
			</cfif>
			<cfquery name="getMfhds" datasource="#application.dsn.voyager#">
				SELECT
					<cfif isdefined("arguments.item_barcode_recordset") OR isdefined("arguments.item_barcode")>
						ib.ITEM_BARCODE,
                        mi.ITEM_ENUM,
                        mi.CHRON,
                        mi.YEAR,
					</cfif>
					mm.MFHD_ID,
                    l.LOCATION_ID,
					l.LOCATION_NAME,
                    l.LOCATION_DISPLAY_NAME,
					mm.NORMALIZED_CALL_NO,
					mm.DISPLAY_CALL_NO
				FROM
					MFHD_MASTER mm INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
					<cfif isdefined("arguments.item_barcode_recordset") OR isdefined("arguments.item_barcode")>
                    	INNER JOIN MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
                        INNER JOIN ITEM_BARCODE ib ON ib.ITEM_ID = mi.ITEM_ID
					</cfif>
                    <cfif isdefined("arguments.bib_ID")>
                    	INNER JOIN BIB_MFHD bm ON bm.BIB_ID = <cfqueryparam value="#arguments.bib_ID#" cfsqltype="cf_sql_bigint"> AND bm.MFHD_ID = mm.MFHD_ID
                    </cfif>
				WHERE
                	1=1
					<cfif isdefined("arguments.item_barcode_recordset")>
						AND ib.ITEM_BARCODE IN (#ListQualify(item_barcode_list, "'", ",", "ALL")#)
                    <cfelseif isdefined("arguments.item_barcode")>
                    	AND ib.ITEM_BARCODE = <cfqueryparam value="#arguments.item_barcode#" cfsqltype="cf_sql_varchar">
                    </cfif>
					<cfif isdefined("arguments.bib_ID")>
						
                    </cfif>
			</cfquery>
			<cfreturn getMfhds>
			<cfcatch>
				<cfset temp = StructNew()>
				<cfset temp.catch = cfcatch>
<!---
				<cfset temp.item_barcode_list = item_barcode_list>
--->
				<cfreturn temp>
			</cfcatch>
		</cftry>
	</cffunction>
	
    <cffunction name="get_newbooks" access="public" returntype="any">
    	<cfargument name="random" type="string" default="no" required="no">
        <cfargument name="count" type="numeric" required="no">
        
		<cftry>
        	<cfquery name="newbooks" datasource="#application.dsn.voyager#">
            	<cfif isdefined("arguments.count")>
                select * from (
                </cfif>
                select distinct
                    bt.bib_ID,
                    bt.isbn,
                    bt.title
                from patron p
                    inner join circ_transactions ct
                        on p.first_name = 'New Books' and p.patron_ID = ct.patron_ID
                    inner join mfhd_item mi on ct.item_id = mi.item_ID
                    inner join bib_mfhd bm on mi.mfhd_id = bm.mfhd_id
                    inner join bib_text bt on bm.bib_ID = bt.bib_ID
                <cfif arguments.random eq 'yes'>
<!---
                	order by dbms_random.value
--->
					order by mod(ora_hash(to_char(sysdate, 'YYYYMMDDHHMMSS') || bib_ID), 100)
                </cfif>
            	<cfif isdefined("arguments.count")>
                ) where rownum <= <cfqueryparam value="#arguments.count#" cfsqltype="cf_sql_integer">
                </cfif>
            </cfquery>
            
            <cfreturn newbooks>
            
        	<cfcatch>
            	<cfreturn QueryNew("isbn, title, author")>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <!--- get patron info from IID --->
    <cffunction name="get_patron" access="public" returntype="any">
        <cfargument name="iid" type="string" required="no">
        <cfargument name="username" type="string" required="no">
        <cfargument name="expired" type="string" required="no">
        
        <cftry>
            <cfif not(isdefined("session.verified") and session.verified eq 'yes')>
                <cfthrow type="not-authorized">
            </cfif>
            <cfset patron = StructNew()>
            <cfif isdefined("arguments.iid") and len(arguments.iid) lt 8> <!--- suid --->
                <cfquery name="getPatron" datasource="#application.dsn.library#">
                    SELECT
                        name As firstname
                    FROM
                        department
                    WHERE
                        ID = <cfqueryparam value="#iid#" cfsqltype="cf_sql_integer">
                </cfquery>
                <cfif getPatron.recordcount eq 1>
                    <cfset patron.iid = arguments.iid>
                    <cfset patron.firstname = getPatron.firstname>
                    <cfset patron.lastname = 'Department'>
                    <cfset patron.email_address = 'n/a'>
                    <cfset patron.status = 'n/a'>
                </cfif>
            <cfelse> <!--- cwid --->
                <cfquery name="getPatron" datasource="#application.dsn.voyager#">
                    SELECT
                        p.INSTITUTION_ID,
                        p.FIRST_NAME "firstname",
                        p.LAST_NAME "lastname",
                        pa.ADDRESS_LINE1 "email_address",
                        pg.PATRON_GROUP_NAME "status",
                        pb.BARCODE_STATUS,
                        p.EXPIRE_DATE
                    FROM
                        PATRON p INNER JOIN PATRON_ADDRESS pa ON p.PATRON_ID = pa.PATRON_ID
                        INNER JOIN PATRON_BARCODE pb ON p.PATRON_ID = pb.PATRON_ID
                        INNER JOIN PATRON_GROUP pg ON pb.PATRON_GROUP_ID = pg.PATRON_GROUP_ID
                    WHERE
                        pa.ADDRESS_TYPE = '3'
    --                    AND pb.BARCODE_STATUS = '1'
                        <cfif isdefined("arguments.iid")>
                            AND p.INSTITUTION_ID = <cfqueryparam value="#arguments.iid#" cfsqltype="cf_sql_varchar">
                        </cfif>
                        <cfif isdefined("arguments.username")>
                            AND lower(pa.ADDRESS_LINE1) = lower(<cfqueryparam value="#arguments.username#" cfsqltype="cf_sql_varchar"> || '@hws.edu')
                        </cfif>
                        <cfif isdefined("arguments.expired") and arguments.expired eq 'yes'>
                            AND p.EXPIRE_DATE < <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
                        <cfelseif isdefined("arguments.expired") and arguments.expired eq 'no'>
                            AND p.EXPIRE_DATE >= <cfqueryparam value="#Now()#" cfsqltype="cf_sql_date">
                        </cfif>
                </cfquery>
                <cfif getPatron.recordcount neq 0>
                    <cfif getPatron.expire_date lt Now()>
                        <cfset patron.expired = "yes">
                    </cfif>
                    <cfset patron.iid = getPatron.INSTITUTION_ID>
                    <cfset patron.firstname = getPatron.firstname>
                    <cfset patron.lastname = getPatron.lastname>
                    <cfset patron.email_address = getPatron.email_address>
                    <cfloop query="getPatron">
                        <cfset StructInsert(patron, getPatron.status, "yes", 1)>
                    </cfloop>
                </cfif>
            </cfif>
            <cfif isdefined("patron.iid")>
                <cfinvoke
                    method="get_dept"
                    iid="#patron.iid#"
                    returnvariable="patron.dept"
                />
            </cfif>
            <cfreturn patron>
            <cfcatch>
                <cfreturn cfcatch>
            </cfcatch>
        </cftry>
    </cffunction>
</cfcomponent>