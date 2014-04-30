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
<cftry>
	<cfif not(isdefined("url.method") and isdefined("url.component"))>
    	<cfthrow
        	type="Error"
            detail="Method and component not defined"
        />
    </cfif>
    
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
            <cfif var neq 'method' and var neq 'component' and var neq 'errordetail'>
                <cfinvokeargument name="#var#" value="#evaluate(var)#">
            </cfif>
        </cfloop>
    </cfinvoke>
    <cfif isdefined("result.type")>
        <cfthrow object=#result# />
    <cfelse>
        Updated
    </cfif>
	<cfcatch>
        Error:
		<cfoutput>
        	#cfcatch.type#
            <cfif isdefined("cfcatch.message")>
            	(#cfcatch.message#)
            </cfif>
		</cfoutput>
        <cfif isdefined("url.errordetail")>
            <cfdump var="#cfcatch#">
        </cfif>
    </cfcatch>
</cftry>