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
    <cfoutput>
        <cfinvoke
            component="#application.display.cfc#"
            method="display_breadcrumbs"
            breadcrumb="Weeding Home,Admin Portal,Manage Departments"
            breadcrumb_url="#application.weeding.home#,.,?view=department"
        />
        <h2>#title#</h2>
        <cfif not(isdefined("session.verified"))>
            <cfthrow
                message="Please log in."
            />
        </cfif>
        
        <cfif not(session.authorization.authorized eq 'yes' and isdefined("session.authorization.admin"))>
            <cfthrow 
                type="Not authorized"
                detail="You are not authorized to use this page.">
        </cfif>
        
        <cfinvoke
            component="#application.miscellaneous.cfc#"
            method="get_departments"
            exclude_suppressed="no"
            include_see="yes"
            returnvariable="departments"
        />
        <cfinvoke
            component="#application.miscellaneous.cfc#"
            method="get_departments"
            exclude_suppressed="no"
            include_see="no"
            returnvariable="departments_top"
        />

        <table class="sortable">
            <tr>
                <th>Name</th>
                <th>Suppressed</th>
                <th>See</th>
                <th>&nbsp;</th>
            </tr>
            <cfloop query="departments">
                <tr>
                    <td>
                        <input type="text" value="#departments.name#" id="name_#departments.id#"/>
                    </td>
                    <td>
                        <select id="suppress_#departments.id#">
                            <option value="yes">Yes</option>
                            <cfif departments.suppress_approval neq 'yes'>
                                <option value="no" selected="selected">No</option>
                            <cfelse>
                                <option value="no">No</option>
                            </cfif>
                        </select>
                    </td>
                    <td>
                        <select id="see_#departments.id#">
                            <option value="0">None</option>
                            <cfloop query="departments_top">
                                <cfif departments.id neq departments_top.id>
                                    <cfif departments.see eq departments_top.ID>
                                        <option value="#departments_top.ID#" selected="selected">#departments_top.name#</option>
                                    <cfelse>
                                        <option value="#departments_top.ID#">#departments_top.name#</option>
                                    </cfif>
                                </cfif>
                            </cfloop>
                        </select>
                    </td>
                    <td>
                        <input type="button" value="Update" onclick="update(#departments.id#);"/>
                        <span id="status_#departments.id#"></span>
                    </td>
                </tr>
            </cfloop>
            <tr>
                <td>
                    <input type="text" value="" id="name_new"/>
                </td>
                <td>
                    <select id="suppress_new">
                        <option value="yes">Yes</option>
                        <option value="no" selected="selected">No</option>
                    </select>
                </td>
                <td>
                    <select id="see_new">
                        <option value="0">None</option>
                        <cfloop query="departments_top">
                            <option value="#departments_top.ID#">#departments_top.name#</option>
                        </cfloop>
                    </select>
                </td>
                <td>
                    <input type="button" value="Add" onclick="add();"/>
                    <span id="status_add"></span>
                </td>
            </tr>
        </table>
        <script language="JavaScript" type="text/javascript">
        <!--
            function add(){
                if ($("##name_new").val() == '') {
                    $("##status_add").html("Name required");
                    return 0;
                }
                $("##status_add").html("Updating...");
                sendUrl="#application.weeding.home#/scripts/get.cfm?component=miscellaneous&method=add_department";
                sendUrl+="&name=" + $("##name_new").val();
                sendUrl+="&suppress_approval=" + $("##suppress_new").val();
                sendUrl+="&see=" + $("##see_new").val();
//                window.alert(sendUrl);
                $.ajax({
                    url: sendUrl,
                    success: function(result) {
                        result = jQuery.trim(result);
                        if (!isNaN(parseFloat(result)) && isFinite(result)) {
                            $("##status_add").html('Updated');
                            window.location.reload();
                        } else {
                            $("##status_add").html(result);
                        }
                    }
                });
            }

          function update(deptID){
                $("##status_" + deptID).html("Updating...");
                sendUrl="#application.weeding.home#/scripts/get.cfm?component=miscellaneous&method=update_department";
                sendUrl+="&ID=" + deptID;
                sendUrl+="&name=" + $("##name_" + deptID).val();
                sendUrl+="&suppress_approval=" + $("##suppress_" + deptID).val();
                sendUrl+="&see=" + $("##see_" + deptID).val();
//                window.alert(sendUrl);
                $.ajax({
                    url: sendUrl,
                    success: function(result) {
                        result = jQuery.trim(result);
                        if (result == 'true') {
                            $("##status_" + deptID).html('Updated');
                            window.location.reload();
                        } else {
                            $("##status_" + deptID).html('Error');
                        }
                    }
                });
            }

            //-->
        </script>
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
