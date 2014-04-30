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

<cfcomponent name="conspectus" output="false">
    <cffunction name="conspectus_match_departments" access="public" returntype="any">
        <cfargument name="lcclass" type="string" required="no">
        <cfargument name="normalized_lcclass" type="string" required="no">
        
        <cfif isdefined("arguments.lcclass")>
			<cfset lc_letter = REReplace(arguments.lcclass, "^\s*([A-Za-z]+).*$", "\U\1")>
            <cfset lc_number = REReplace(arguments.lcclass, "^\s*[A-Za-z]+\s*([0-9]*\.?[0-9]+).*$", "\1")>
            <cfset conspectus_matches = QueryNew("department_ID,subject_ID,level_ID,Subclassplus1,start_letter,start_number,end_letter,end_number")>
        </cfif>
        <cfif isdefined("arguments.normalized_lcclass")>
        	<!--- strip off anything after class group -- otherwise e.g. TR183 won't match 'TR183 .M34' --->
			<cfset arguments.normalized_lcclass = REReplace(arguments.normalized_lcclass, '^([^0-9]*[0-9]*).*$', '\1', 'ALL')>
        </cfif>
        <cfquery name="conspectus" datasource="library">
            SELECT
                lc_range_ID,
                NormalizedStartNum,
                NormalizedEndNum,
                Subclassplus1,
                subject_ID,
                level_ID,
                department_ID
            FROM
                lc_classes lc INNER JOIN subject_range_level srl ON lc.ID = srl.lc_range_ID
                INNER JOIN subject s ON s.ID = srl.subject_ID
            <cfif isdefined("arguments.normalized_lcclass")>
            WHERE
            	NormalizedStartNum <= <cfqueryparam value="#arguments.normalized_lcclass#" cfsqltype="cf_sql_varchar">
                AND NormalizedEndNum >= <cfqueryparam value="#arguments.normalized_lcclass#" cfsqltype="cf_sql_varchar">
            </cfif>
        </cfquery>
        <cfif isdefined("arguments.normalized_lcclass")>
        	<cfreturn conspectus>
        </cfif>
        <cfloop query="conspectus">
            <cfset start_letter = REReplace(conspectus.Subclassplus1, "^([A-Za-z]+).*$", "\U\1")>
            <cfset start_number = REReplace(conspectus.Subclassplus1, "^[A-Za-z]+\s*([0-9]*\.?[0-9]+).*$", "\1")>
            <cfset end_letter = start_letter>
            <cfif ReFind("-", conspectus.Subclassplus1)>
                <cfset end_number = REReplace(conspectus.Subclassplus1, "^.*-([0-9.]+).*$", "\1")>
            <cfelse>
                <cfset end_number = start_number>
            </cfif>
            <cfif lc_letter gte start_letter AND lc_letter lte end_letter AND lc_number gte start_number AND lc_number lte end_number>
                <cfscript>
                    newrow = QueryAddRow(conspectus_matches);
                    QuerySetCell(conspectus_matches, "department_ID", "#conspectus.department_ID#");
                    QuerySetCell(conspectus_matches, "subject_ID", "#conspectus.subject_ID#");
                    QuerySetCell(conspectus_matches, "level_ID", "#conspectus.level_ID#");
                    QuerySetCell(conspectus_matches, "Subclassplus1", "#conspectus.Subclassplus1#");
                    QuerySetCell(conspectus_matches, "start_letter", "#start_letter#");
                    QuerySetCell(conspectus_matches, "start_number", "#start_number#");
                    QuerySetCell(conspectus_matches, "end_letter", "#end_letter#");
                    QuerySetCell(conspectus_matches, "end_number", "#end_number#");
                </cfscript>
            </cfif>
        </cfloop>
        <cfreturn conspectus_matches>
    </cffunction>
</cfcomponent>