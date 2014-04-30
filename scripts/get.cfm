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
<cfsetting requesttimeout="6000">
<cfif isdefined("url.method") and isdefined("url.component")>
	<cftry>
        <cfif isdefined("application." & url.component & ".cfc")>
            <cfset component_name = "#application[url.component].cfc#">
        <cfelse>
            <cfset component_name = "cfc.#url.component#">
        </cfif>
        <cfinvoke
            component="#component_name#"
            method="#url.method#"
            returnvariable="result"
        >
            <cfloop collection="#url#" item="var">
                <cfif var neq 'method' and var neq 'component' and var neq 'resultformat' and var neq 'errordetail'>
                    <cfinvokeargument name="#var#" value="#evaluate(var)#">
                </cfif>
            </cfloop>
        </cfinvoke>
        <cfif isdefined("result.errorcode")>
            <cfthrow object="#result#">
        </cfif>
		<cfif isdefined("url.resultformat") and url.resultformat eq "tsv">
            <cftry>
                <cfif result.recordcount neq 0>
                    <cfset tsv = ArrayNew(1)>
                    <cfset line = ArrayNew(1)>
                    <cfloop list="#result.columnlist#" index="col" delimiters=",">
                        <cfset ArrayAppend(line, col)>
                    </cfloop>
                    <cfset ArrayAppend(tsv, ArrayToList(line, '#chr(9)#'))>
                    <cfloop query="result">
                        <cfset line = ArrayNew(1)>
                        <cfloop list="#result.ColumnList#" index="col">
                            <cfset ArrayAppend(line, result[col][CurrentRow])>
                        </cfloop>
                        <cfset ArrayAppend(tsv, ArrayToList(line, '#chr(9)#'))>
                    </cfloop>
                    <cfset filename = 'query_' & DateFormat(Now(), 'yyyymmdd') & TimeFormat(Now(), 'HHmmss') & '.tsv'>
                    <cffile
                        action="write"
                        file="#ExpandPath('/tmp/' & filename)#"
                        output="#ArrayToList(tsv, chr(13) & chr(10))#"
                    />
                    <cfset tmp.filename="/tmp/#filename#">
                    <cfset tmp.recordcount=result.recordcount>
                <cfelse>
                    <cfset tmp.recordcount=0>
                </cfif>
                <cfoutput>#serializejson(tmp)#</cfoutput>
                <cfcatch>
                    <cfoutput>#serializejson(result)#</cfoutput>
                </cfcatch>
            </cftry>
        <cfelse>
            <cftry>
                <cfoutput>#result#</cfoutput>
                <cfcatch>
                    <cfoutput>#serializejson(result)#</cfoutput>
                </cfcatch>
            </cftry>
        </cfif>
        <cfcatch>
        	<cfoutput>#serializejson(result)#</cfoutput>
<!---            Error: 
			<cfoutput>
            	<cfif isdefined("cfcatch.detail")>
    	            #cfcatch.detail#
                <cfelse>
	            	#cfcatch.type#
                </cfif>
			</cfoutput>
            <cfif isdefined("url.errordetail")>
            	at line <cfoutput>#cfcatch.tagcontext[1].line#</cfoutput>
                <cfdump var="#cfcatch#">
            </cfif> --->
        </cfcatch>
    </cftry>
</cfif>