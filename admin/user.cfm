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
                breadcrumb="Weeding Home,Admin Portal,Manage Users"
                breadcrumb_url="#application.weeding.home#,.,?view=user"
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
            
            
            <cfif isdefined("url.libid")>
                <h3>Edit User</h3>
                <!--- start single user edit --->
                <cfinvoke
                    component="#application.authorization.cfc#"
                    method="get_user"
                    returnvariable="edit_user"
                >
                    <cfif isdefined("session.authorization.admin") and isdefined("url.libid")>
                        <cfinvokeargument name="userid" value="#url.libid#">
                        <cfinvokeargument name="expired" value="any">
                    <cfelse>
                        <cfinvokeargument name="userid" value="#session.authorization.userid#">
                    </cfif>
                </cfinvoke>
                
                <cfif edit_user.recordcount neq 1>
                    <cfthrow
                        message="Error retrieving user info."
                    />
                </cfif>
                
                <div class="grid_8 alpha">
                    <cfif isdefined("session.authorization.admin")>
                        <p><strong>First name:</strong><input type="text" id="firstname" value="#edit_user.firstname#"></p>
                        <p><strong>Last name:</strong> <input type="text" id="lastname" value="#edit_user.lastname#"></p>
                        <p><strong>CWID:</strong> <input type="text" id="cwid" value="#edit_user.cwid#"></p>
                        <p>
                            <strong>Expired?</strong>
                            <cfif edit_user.expired eq 'yes'>
                                <input type="checkbox" id="expired" checked="checked"/>
                            <cfelse>
                                <input type="checkbox" id="expired"/>
                            </cfif>
                            |
                            <strong>Admin</strong>
                            <cfif edit_user.role eq 'admin'>
                                <input type="checkbox" id="admin" checked="checked"/>
                            <cfelse>
                                <input type="checkbox" id="admin"/>
                            </cfif>
                        </p>
                    </cfif>
                    
                    <cfif isdefined("session.authorization.admin")>
                        <p><strong>Department:</strong>
                            <cfinvoke
                                component="#application.miscellaneous.cfc#"
                                method="get_department_list"
                                returnvariable="departments"
                            />
                            <select id="library_department" onChange="update_department();">
                                <option value=''>None</option>
                                <cfloop query="departments">
                                    <cfif departments.ID eq edit_user.library_department_ID>
                                        <option value="#departments.ID#" selected="selected">#departments.dept#</option>
                                    <cfelse>
                                        <option value="#departments.ID#">#departments.dept#</option>
                                    </cfif>
                                </cfloop>
                            </select>
                        </p>
                        <p><strong>Directory order</strong>: <input type="text" size="1" id="directory_order" value="#edit_user.directory_order#"></p>
                        <p><strong>Title:</strong> <input type="text" id="jobtitle" name="title" value="#edit_user.title#" size="50" maxlength="100"></p>
                        <p><strong>E-mail:</strong> <input type="text" id="email" name="email" value="#edit_user.email#" size="50" maxlength="50"></p>
                    <cfelse>
                        <p><strong>Department:</strong> #edit_user.library_department#</p>
                        <p><strong>Title:</strong> #edit_user.title#</p>
                        <p><strong>E-mail:</strong> #edit_user.email#</p>
                    </cfif>
                    <p><strong>Phone:</strong> <input type="text" id="phone" name="phone" value="#edit_user.phone#" size="50" maxlength="50"></p>
                    
                    <p><strong>Permissions:</strong>
                        <cfinvoke
                            component="#application.authorization.cfc#"
                            method="get_user_permissions"
                            librarian_ID="#edit_user.ID#"
                            returnvariable="user_permissions"
                        />
                        <cfset is_liaison = 'no'>
                        <cfif user_permissions.recordcount neq 0 and user_permissions.permission_name neq ''>
                            <cfloop query="user_permissions">
                                #user_permissions.permission_name#<cfif isdefined("session.authorization.admin")> [<a class="link" onClick="delete_permission(#user_permissions.permission_ID#);">x</a>]</cfif><cfif currentrow neq user_permissions.recordcount>, </cfif>
                                <cfif user_permissions.permission_name eq 'Liaison'>
                                    <cfset is_liaison = 'yes'>
                                </cfif>
                            </cfloop>
                        </cfif>
                    </p>
                    <cfif isdefined("session.authorization.admin")>
                        <cfinvoke
                            component="#application.authorization.cfc#"
                            method="get_permissions"
                            returnvariable="permissions"
                        />
                        <p><strong>Add permission:</strong>
                            <select id="new_permission" onChange="add_permission();">
                                <option value="">--- Select a permission ---</option>
                                <cfloop query="permissions">
                                    <option value="#permissions.ID#">#permissions.description#</option>
                                </cfloop>
                            </select>
                        </p>
                    </cfif>
                    
                    <p><input type="button" value="Apply Changes" onClick="update();"/> <input type="button" onClick="document.location='?view=user&libid=#edit_user.ID#';" value="Cancel"/> <span id="status"></span></p>
                </div>

                <div class="grid_4 omega">
<!---
                    <cfif edit_user.image_url neq ''>
                        <p><img src="#edit_user.image_url#" width="200"/></p>
                    </cfif>

                    <form name="formUpload" id="formUpload" method="post" enctype="multipart/form-data" action="user_pic_action.cfm?libid=#edit_user.ID#">
                        <p><input type="file" size="50" name="file"></p>
                        <p><input type="submit" name="submit" value="Change picture"></p>
                    </form>
--->
                </div>
                
                <div class="grid_12 alpha omega">
                    <cfif isdefined("session.authorization.admin")>
                        <hr />
                        <p><strong>Change user:</strong>
                            <select onChange="document.location='?view=user&libid=' + this.value">
                                <option>--- Select a user ---</option>
                                <cfinvoke
                                    component="#application.authorization.cfc#"
                                    method="get_user"
                                    expired="no"
                                    returnvariable="users"
                                />
                                <cfloop query="users">
                                    <cfif isdefined("url.libid") and url.libid eq users.id>
                                        <option value="#users.id#" selected="selected">#users.lastname#, #users.firstname#</option>
                                    <cfelse>
                                        <option value="#users.id#">#users.lastname#, #users.firstname#</option>
                                    </cfif>
                                </cfloop>
                            </select>
                        </p>
                        <p><a href="?view=user&listusers">List all users</a></p>
                    </cfif>
                </div>
                    
                <script language="JavaScript" type="text/javascript">
                <!--
                    function update(){
                        $("##status").html("Updating...");
                        sendUrl="#application.weeding.home#/scripts/update.cfm?component=authorization&method=update_user&ID=#edit_user.ID#";
                        <cfif isdefined("session.authorization.admin")>
                            sendUrl+="&firstname=" + $("##firstname").val();
                            sendUrl+="&lastname=" + $("##lastname").val();
                            sendUrl+="&cwid=" + $("##cwid").val();
                            sendUrl+="&directory_order=0" + $("##directory_order").val();
                            sendUrl+="&title=" + $("##jobtitle").val();
                            sendUrl+="&email=" + $("##email").val();
                            $("##admin").is(':checked') ? sendUrl+="&role=admin" : sendUrl+="&role=user";
                            $("##expired").is(':checked') ? sendUrl+="&expired=yes" : sendUrl+="&expired=no";
                        </cfif>
                        sendUrl+="&phone=" + $("##phone").val();
//                				window.alert(sendUrl);
                        $.ajax({
                            url: sendUrl,
                            success: function(result) {
                                result = jQuery.trim(result);
                                $("##status").html(result);
                                if (result == 'Updated') {
                                    window.location.reload();
                                }
                            }
                        });
                    }
                    
                    <cfif isdefined("session.authorization.admin")>
                        function add_permission(){
                            if ($("##new_permission").val() != '') {
                                $("##status").html("Updating...");
                                sendUrl="#application.weeding.home#/scripts/update.cfm?component=authorization&method=add_user_permission&user_ID=#edit_user.ID#";
                                sendUrl+="&permission_ID=" + $("##new_permission").val();
//									window.alert(sendUrl);
                                $.ajax({
                                    url: sendUrl,
                                    success: function(result) {
                                        result = jQuery.trim(result);
                                        $("##status").html(result);
                                        if (result == 'Updated') {
                                            window.location.reload();
                                        }
                                    }
                                });
                            }
                        }

                        function delete_permission(pid){
                            $("##status").html("Updating...");
                            sendUrl="#application.weeding.home#/scripts/update.cfm?component=authorization&method=delete_user_permission&user_ID=#edit_user.ID#";
                            sendUrl+="&permission_ID=" + pid;
//									window.alert(sendUrl);
                                $.ajax({
                                url: sendUrl,
                                success: function(result) {
                                    result = jQuery.trim(result);
                                    $("##status").html(result);
                                    if (result == 'Updated') {
                                        window.location.reload();
                                    }
                                }
                            });
                        }

                        function update_department(){
                            $("##status").html("Updating...");
                            sendUrl="#application.weeding.home#/scripts/update.cfm?component=authorization&method=update_user&ID=#edit_user.ID#";
                            sendUrl+="&library_department_ID=" + $("##library_department").val();
//									window.alert(sendUrl);
                            $.ajax({
                                url: sendUrl,
                                success: function(result) {
                                    result = jQuery.trim(result);
                                    $("##status").html(result);
                                    if (result == 'Updated') {
                                        window.location.reload();
                                    }
                                }
                            });
                        }

                        function add_subject() { 
                            $("##addSubjectStatus").html('<img src="/images/ajax-loader.gif" alt="Loading..."/>');
                            sendUrl = '#application.weeding.home#/scripts/update.cfm?component=conspectus&method=add_librarian_subject&librarian_ID=#edit_user.ID#&subject_ID=' + $('##subject_select').val();
                    //                            window.alert(sendUrl);
                            $.ajax({
                                url: sendUrl,
                                success: function(result) {
                                    result = jQuery.trim(result);
                                    $("##addSubjectStatus").html(result);
                                    if (result == 'Updated') {
                                        window.location.reload();
                                    }
                                }
                            });
                        }
                        
                        function delete_subject(subjectId) {
                            $("##status").html('Deleting...');
                            sendUrl = '#application.weeding.home#/scripts/update.cfm?component=conspectus&method=delete_librarian_subject&librarian_ID=#edit_user.ID#&subject_ID=' + subjectId;
                    //                            window.alert(sendUrl);
                            $.ajax({
                                url: sendUrl,
                                success: function(result) {
                                    result = jQuery.trim(result);
                                    $("##status").html(result);
                                    if (result == 'Updated') {
                                        window.location.reload();
                                    }
                                }
                            });
                        }

                    </cfif>
                //-->
                </script>
                <!--- end single user edit --->
            <cfelseif isdefined("url.newuser")>
                <!--- begin add new user --->
                <h3>New User</h3>
                <div class="grid_8 alpha">
                    <p><strong>First name:</strong> <input type="text" id="firstname"/></p>
                    <p><strong>Last name:</strong> <input type="text" id="lastname"/></p>
                    <p><strong>CWID:</strong> <input type="text" id="cwid"/></p>
                    <p>
                        <strong>Admin?</strong>
                        <input type="checkbox" id="admin"/>
                    </p>

                    <p><strong>Department:</strong>
                        <cfinvoke
                            component="#application.miscellaneous.cfc#"
                            method="get_department_list"
                            returnvariable="departments"
                        />
                        <select id="library_department">
                            <option value='0'>None</option>
                            <cfloop query="departments">
                                <option value="#departments.ID#">#departments.dept#</option>
                            </cfloop>
                        </select>
                    </p>

                    <p><strong>Directory order</strong>: <input type="text" size="1" id="directory_order"/></p>
                    <p><strong>Title:</strong> <input type="text" id="jobtitle" name="title" size="50" maxlength="100"/></p>
                    <p><strong>E-mail:</strong> <input type="text" id="email" name="email" size="50" maxlength="50"/></p>
                    <p><strong>Phone:</strong> <input type="text" id="phone" name="phone" size="50" maxlength="50"/></p>
                    
                    <p><input type="button" value="Add User" onClick="add_user();"/> <span id="status"></span></p>
                </div>
                <script language="JavaScript" type="text/javascript">
                <!--
                    function add_user(){
                        $("##status").html("Updating...");
                        sendUrl="#application.weeding.home#/scripts/get.cfm?component=authorization&method=add_user";
                        sendUrl+="&firstname=" + $("##firstname").val();
                        sendUrl+="&lastname=" + $("##lastname").val();
                        sendUrl+="&cwid=" + $("##cwid").val();
                        $("##admin").is(':checked') ? sendUrl+="&role=admin" : sendUrl+="&role=user";
                        sendUrl+="&library_department_ID=" + $("##library_department").val();
                        sendUrl+="&directory_order=0" + $("##directory_order").val();
                        sendUrl+="&title=" + $("##jobtitle").val();
                        sendUrl+="&email=" + $("##email").val();
                        sendUrl+="&phone=" + $("##phone").val();
//                                    window.alert(sendUrl);
                        $.ajax({
                            url: sendUrl,
                            success: function(result) {
                                result = jQuery.trim(result);
                                if (!isNaN(parseFloat(result)) && isFinite(result)) {
                                    $("##status").html('Updated');
                                    window.location.href='?view=user&libid=' + result;
                                } else {
                                    $("##status").html(result);
                                }
                            }
                        });
                    }
                //-->
                </script>
                <!--- end add new user --->
            <cfelse>
                <h3>List Users</h3>
                <!--- begin list users --->
                <p>
                    <cfif isdefined("url.expired")>
                        <input type="checkbox" checked="checked" onClick="window.location.href='?view=user&listusers';" /> Include expired users
                    <cfelse>
                        <input type="checkbox" onClick="window.location.href='?view=user&listusers&expired=all';" /> Include expired users
                    </cfif>
                </p>
                <cfinvoke
                    component="#application.authorization.cfc#"
                    method="get_user"
                    returnvariable="users"
                >
                    <cfif isdefined("url.expired")>
                        <cfinvokeargument name="expired" value="#url.expired#">
                    </cfif>
                </cfinvoke>
                <table class="sortable">
                    <tr>
                        <th>Name</th>
                        <th>Permissions</th>
                        <cfif isdefined("url.expired")>
                            <th>Expired?</th>
                        </cfif>
                    </tr>
                    <cfloop query="users">
                        <tr>
                            <td><a href="?view=user&libid=#users.ID#">#users.lastname#, #users.firstname#</a></td>
                            <td>
                                <cfinvoke
                                    component="#application.authorization.cfc#"
                                    method="get_user_permissions"
                                    librarian_ID="#users.ID#"
                                    returnvariable="permissions"
                                />
                                <cfif users.role eq 'admin'>Admin<cfif permissions.recordcount neq 0 and permissions.permission_name neq ''>, </cfif></cfif>
                                <cfloop query="permissions">
                                    #permissions.permission_name#<cfif currentrow neq permissions.recordcount>, </cfif>
                                </cfloop>
                            </td>
                            <cfif isdefined("url.expired")>
                                <td>#users.expired#</td>
                            </cfif>
                        </tr>
                    </cfloop>
                </table>
                <p><a href="?view=user&newuser">Add new user</a></p>
                <!--- end list users --->
             </cfif>
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
