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
    <cfset intro =
		"<p>Below is a list of all the items under review for withdrawal from the library collection. Items are matched to departments based upon on the <a href='/reports/conspectus.cfm'>library conspectus</a>. The <a href='/documents/CD_policy.pdf'>Collection Development Policy</a> lists criteria used to select books for review/withdrawal from the collection.</p>
		<p>Departments with at least one matching item show as hyperlinks below. To provide feedback, including any request to retain materials, click the hyperlink to view the current items under review.  Items will remain on the list to allow feedback for six months before they are withdrawn from the collection.</p>
		<p>To receive alerts when additional items are added in a particular conspectus area, you can choose the 'subscribe' option. Updates are scheduled to be sent on the first day of each month.</p>
		<p>Please contact your <a href='/liaisons.cfm'>liaison</a> to discuss the review process or to address any questions or concerns.</p>"
	/>
	<cfset title = "Collection Review">
    <cfinclude template = "../config.cfm">
</cfsilent>

<cfinvoke
	component="#application.display.cfc#"
    method="display_header"
    title="#title#"
    nofollow="yes"
    jquery="yes"
    custom_css=".itemdecision {width:180px; margin-left:18px; float:left;}"
    charset="utf-8"
/>
<body>
    <cfinclude template="/includes/header.cfm">
    <div id="body">
        <div id="main">
    
    <!-- =========================== column one =========================== --> 
    
            <div id="column_full">
            	<cfif isdefined("url.deptid") AND url.deptid neq 0>
                    <cfinvoke
                        component="#application.display.cfc#"
                        method="display_breadcrumbs"
                        breadcrumb="#title#,Recommendations by Department"
                        breadcrumb_url="#cgi.SCRIPT_NAME#?deptid=0,#cgi.SCRIPT_NAME#?deptid=#url.deptid#"
                    />
                <cfelseif isdefined("session.weeding.deptid") AND (not(isdefined("url.deptid")) OR url.deptid neq 0)>
                    <cfinvoke
                        component="#application.display.cfc#"
                        method="display_breadcrumbs"
                        breadcrumb="#title#,Recommendations by Department"
                        breadcrumb_url="#cgi.SCRIPT_NAME#?deptid=0,#cgi.SCRIPT_NAME#?deptid=#session.weeding.deptid#"
                    />
                <cfelse>
                    <cfinvoke
                        component="#application.display.cfc#"
                        method="display_breadcrumbs"
                        breadcrumb="#title#"
                        breadcrumb_url="#cgi.SCRIPT_NAME#"
                    />
                </cfif>
                
                <div style="width:300px; font-size:10px; float:right;">
                    <cfinclude template="/includes/login.cfm">
                </div>

                <cftry>
               	    <cfoutput>
                        <h3>#title#</h3>
                        <cfif not(isdefined("session.verified"))>
                            <cfthrow message="You must log in to view reports.">
                        </cfif>

						<cfif not(isdefined("session.user.faculty"))>
                            <cfthrow
                                message="This tool is only available to faculty.">
                        </cfif>

						<!--- initialize session variables and set defaults --->
                        <cfif not(isdefined("session.weeding"))>
                            <cfset session.weeding = {}>
                        </cfif>
                        <cfif not(isdefined("session.weeding.deptid"))>
                            <cfset session.weeding.deptid = 0>
                        </cfif>
                        <cfif isdefined("url.deptid")>
                            <cfset session.weeding.deptid = url.deptid>
                            <cfset session.weeding.offset = 0>
                        </cfif>
                        <cfif not(isdefined("session.weeding.offset"))>
                            <cfset session.weeding.offset = 0>
                        </cfif>
                        <cfif isdefined("url.offset")>
                            <cfset session.weeding.offset = url.offset>
                        </cfif>
                        <cfif not(isdefined("session.weeding.page_size"))>
                            <cfset session.weeding.page_size = 25>
                        </cfif>
                        <cfif isdefined("url.page_size")>
                            <cfset session.weeding.page_size = url.page_size>
                            <cfset session.weeding.offset = 0>
                        </cfif>
                        <cfif not(isdefined("session.weeding.sort"))>
                            <cfset session.weeding.sort = ''>
                        </cfif>
                        <cfif isdefined("url.sort")>
                            <cfset session.weeding.sort = url.sort>
                        </cfif>
                    
        <cfif session.weeding.deptid eq 0>
        	<!--- splash page --->

			<!--- intro text set in header --->
            <div style="margin-bottom: 12px;">
                #intro#
            </div>

			<cfinvoke
				component="#application.miscellaneous.cfc#"
				method="get_departments"
                exclude_suppressed="yes"
				returnvariable="departments"
			/>
            <table style="width:0px;">
            	<tr>
                	<th>Department</th>
                    <th>Liaison</th>
                    <th colspan="2">Subscription options</th>
                </tr>
                <cfloop query="departments">
                	<tr id="department_#departments.ID#">
                        <cfinvoke
                            component="#application.weeding.cfc#"
                            method="get_bibs"
                            department_ID="#departments.ID#"
                            active="yes"
                            returnvariable="bibs"
                        />
                        <td>
							<cfif bibs.recordcount eq 0>
                                #departments.name#
                            <cfelse>
                                <a href="index.cfm?deptid=#departments.ID#">#departments.name#</a>
                            </cfif>
                            (#bibs.recordcount#)
                        </td>
                        <cfinvoke
                        	component="#application.miscellaneous.cfc#"
                            method="get_liaisons_by_deptid"
                            deptId="#departments.ID#"
                            returnvariable="liaisons"
                        />
                        <td>
                        	<cfif liaisons.recordcount neq 0>
	                        	<cfloop query="liaisons">
                                	<a href="/forms/contact.cfm?who=#liaisons.ID#" target="_blank">#liaisons.firstname# #liaisons.lastname#</a><cfif currentrow neq liaisons.recordcount>,</cfif>
                                </cfloop>
                            </cfif>
                        </td>
                        <cfinvoke
                        	component="#application.weeding.cfc#"
                            method="is_subscribed"
                            department_ID="#departments.ID#"
                            faculty_ID="#session.user.IID#"
                            returnvariable="subscribed"
                        />
                        <cfif subscribed eq 'yes'>
                            <td id="subscribe_#departments.ID#" style="padding-left: 20px;"><strong>Subscribed</strong></td>
                            <td id="unsubscribe_#departments.ID#" style="padding-left: 20px;"><a class="link" onClick="unsubscribe('#departments.ID#');">Unsubscribe</a></td>
                        <cfelse>
                            <td id="subscribe_#departments.ID#" style="padding-left: 20px;"><a class="link" onClick="subscribe('#departments.ID#');">Subscribe</a></td>
                            <td id="unsubscribe_#departments.ID#" style="padding-left: 20px;"><strong>Not Subscribed</strong></td>
                        </cfif>
                    </tr>
                </cfloop>
                <tr id="department_-1">
                    <cfinvoke
                        component="#application.weeding.cfc#"
                        method="get_bibs"
                        department_ID="-1"
                        active="yes"
                        returnvariable="bibs"
                    />
                    <td>
                        <cfif bibs.recordcount eq 0>
                            No conspectus match
                        <cfelse>
                            <a href="index.cfm?deptid=-1">No conspectus match</a>
                        </cfif>
                        (#bibs.recordcount#)
                    </td>
                    <td>&nbsp;</td>
                    <cfinvoke
                        component="#application.weeding.cfc#"
                        method="is_subscribed"
                        department_ID="-1"
                        faculty_ID="#session.user.IID#"
                        returnvariable="subscribed"
                    />
                    <cfif subscribed eq 'yes'>
                        <td id="subscribe_-1" style="padding-left: 20px;"><strong>Subscribed</strong></td>
                        <td id="unsubscribe_-1" style="padding-left: 20px;"><a class="link" onClick="unsubscribe('-1');">Unsubscribe</a></td>
                    <cfelse>
                        <td id="subscribe_-1" style="padding-left: 20px;"><a class="link" onClick="subscribe('-1');">Subscribe</a></td>
                        <td id="unsubscribe_-1" style="padding-left: 20px;"><strong>Not Subscribed</strong></td>
                    </cfif>
                </tr>
            </table>
            
			<script language="JavaScript" type="text/javascript">
            <!--
                function subscribe(deptid){
					querystring = "component=weeding&method=add_dept_subscription&faculty_ID=#session.user.IID#&department_ID=" + deptid;
//					window.alert(querystring);
		
					$.ajax({
						url: '/scripts/update.cfm?' + querystring,
						success: function(result) {
							$("##subscribe_" + deptid).remove();
							$("##unsubscribe_" + deptid).remove();
							new_cells = "<td id='subscribe_" + deptid + "' style='padding-left: 20px;'><strong>Subscribed</strong></td>";
							new_cells += "<td id='unsubscribe_" + deptid + "' style='padding-left: 20px;'><a class='link' onclick=" + '"unsubscribe(' + "'" + deptid + "'" + ');">Unsubscribe</a></td>';
//							window.alert(new_cells);
							$("##department_" + deptid).append(new_cells);
						}
					});
                }
                
                function unsubscribe(deptid){
					querystring = "component=weeding&method=delete_dept_subscription&faculty_ID=#session.user.IID#&department_ID=" + deptid;
//					window.alert(querystring);
		
					$.ajax({
						url: '/scripts/update.cfm?' + querystring,
						success: function(result) {
							$("##subscribe_" + deptid).remove();
							$("##unsubscribe_" + deptid).remove();
							new_cells = "<td id='subscribe_" + deptid + "' style='padding-left: 20px;'><a class='link' onclick=" + '"subscribe(' + "'" + deptid + "'" + ');">Subscribe</a></td>';
							new_cells += "<td id='unsubscribe_" + deptid + "' style='padding-left: 20px;'><strong>Not Subscribed</strong></td>";
//							window.alert(new_cells);
							$("##department_" + deptid).append(new_cells);
						}
					});
                }
                
            //-->
            </script>
    
        	<cfthrow/>
            <!--- end splash page --->
        </cfif>
        
        <!--- begin list page --->
		<cfinvoke
        	component="#application.weeding.cfc#"
            method="get_bib_departments"
            distinct="yes"
            returnvariable="departments"
        />
        <cfset department_selected = 0>

        <div class="p">
        	<strong>Select department:</strong>
            <select onChange="window.location='index.cfm?deptid='+this.value;">
                <option value="0">---</option>
                <cfloop query="departments">
                    <cfif departments.department_ID eq session.weeding.deptid>
                        <option value="#departments.department_ID#" selected="selected">#departments.name#</option>
                        <cfset department_selected = departments.department_ID>
                    <cfelse>
                        <option value="#departments.department_ID#">#departments.name#</option>
                    </cfif>
                </cfloop>
                <cfif session.weeding.deptid eq -1>
	                <option value="-1" selected="selected">No conspectus match</option>
                    <cfset department_selected = -1>
                <cfelse>
	                <option value="-1">No conspectus match</option>
                </cfif>
            </select>
        </div>
        
        <cfif department_selected eq 0>
        	<cfthrow
            	detail = "Select a department to begin."
            />
        </cfif>
        
        <div class="p">
        	<strong>Sort by:</strong>
            <select onChange="window.location='index.cfm?sort='+this.value;">
                <cfloop list="Date,Author,Title" index="field">
                    <cfif field eq "Date">
                    	<option value="dateadded">Date added (most recent first)</option>
                    <cfelse>
                        <cfif session.weeding.sort eq LCase(field)>
                            <option value="#LCase(field)#" selected="selected">#field#</option>
                        <cfelse>
                            <option value="#LCase(field)#">#field#</option>
                        </cfif>
                    </cfif>
                </cfloop>
            </select>
        </div>
        
        <cfinvoke
        	component="#application.weeding.cfc#"
            method="get_bibs"
            department_ID="#department_selected#"
            faculty_ID="#session.user.IID#"
            active="yes"
            returnvariable="bibs"
            sort="#session.weeding.sort#"
        />
        
        <cfif bibs.recordcount neq 0>
        	<cfif bibs.recordcount gt session.weeding.page_size>
            	<cfif session.weeding.offset gt bibs.recordcount>
                	<cfset start = bibs.recordcount>
                <cfelse>
                	<cfset start = session.weeding.offset + 1>
                </cfif>
                <cfif session.weeding.offset + session.weeding.page_size gt bibs.recordcount>
                	<cfset end = bibs.recordcount>
                <cfelse>
                	<cfset end = session.weeding.offset + session.weeding.page_size>
                </cfif>
            <cfelse>
                <cfset start = 1>
                <cfset end = bibs.recordcount>
            </cfif>
            <p><strong>Titles #start# - #end# of #bibs.recordcount#</strong></p>
            <cfinvoke
            	component="#application.display.cfc#"
                method="display_pager"
                records="#bibs.recordcount#"
                offset="#session.weeding.offset#"
                page_size="#session.weeding.page_size#"
            />
        	<div id="weeding_items">
            	<cfloop from="#start#" to="#end#" index="i">
                	<div class="p" style="border-bottom:1px solid black; text-indent:-18px; padding-left:18px; padding-bottom: 18px; line-height:24px;">
                    	#i#) #bibs['title'][i]#
                        <cfinvoke
                        	component="#application.voyager.cfc#"
                            method="get_catalog_url"
                            bib_ID="#bibs['bib_ID'][i]#"
                            returnvariable="voyager_URL"
                        />
                        (<a href="#voyager_URL#" target="_blank">More info</a>)
                        <br/>
                        <cfif bibs['author'][i] neq ''>
	                        #bibs['author'][i]#<br/>
                        </cfif>
                        #bibs['imprint'][i]#<br/>
                        <cfinvoke
                        	component="#application.voyager.cfc#"
                            method="get_items"
                            bib_ID="#bibs['bib_ID'][i]#"
                            returnvariable="bib_items"
                        />
                        
                        #bib_items.display_call_no#<br/> <!--- account for different call_no? --->
                        <cfif bib_items.recordcount gt 1>
                            <cfinvoke
                                component="#application.weeding.cfc#"
                                method="get_items"
                                bib_ID="#bibs['bib_ID'][i]#"
                                returnvariable="weeding_items"
                            />
                            <cfset weed_barcodes = REReplace(QuotedValueList(weeding_items.item_barcode, ","), "_", "", "ALL")>
                            <cfquery name="to_weed" dbtype="query">
                            	SELECT
                                	*
                                FROM
                                	bib_items
                                WHERE
                                	bib_items.item_barcode IN (#PreserveSingleQuotes(weed_barcodes)#)
                                ORDER BY
                                	copy_number,
                                	item_enum,
                                    chron
                            </cfquery>
                            
                            <cfquery name="to_retain" dbtype="query">
                            	SELECT
                                	*
                                FROM
                                	bib_items
                                WHERE
                                	bib_items.item_barcode NOT IN (#PreserveSingleQuotes(weed_barcodes)#)
                                ORDER BY
                                	copy_number,
                                	item_enum,
                                    chron
                            </cfquery>
                            
                            <cfif to_weed.recordcount + to_retain.recordcount neq 0>
								<cfif to_weed.recordcount neq 0>
                                    <div class="itemdecision">
                                        <strong>Withdraw:</strong><br/>
                                        <cfloop query="to_weed">
                                            #item_enum#
                                            #chron#
                                            copy #copy_number#
                                            <br/>
                                        </cfloop>
                                    </div>
                                </cfif>
                                <cfif to_retain.recordcount neq 0>
                                    <div class="itemdecision">
                                        <strong>Retain:</strong><br/>
                                        <cfloop query="to_retain">
                                            #item_enum#
                                            #chron#
                                            copy #copy_number#
                                            <br/>
                                        </cfloop>
                                    </div>
                                <cfelse>
                                    <div class="itemdecision">
                                        <strong>Retain:</strong><br/>
                                        None<br/>
                                    </div>
                                </cfif>
                            </cfif>
                        <cfelse>
                            <div class="itemdecision">
                                <strong>Withdraw:</strong><br/>
                                #bib_items.item_enum#
		                        #bib_items.chron#
                                copy #bib_items.copy_number#
                                <br/>
                            </div>
                            <div class="itemdecision">
                                <strong>Retain:</strong><br/>
                                None<br/>
                            </div>
                        </cfif>
                        <div style="height:1px; clear:both;">&nbsp;</div>
                        Added #DateFormat(bibs['review_start'][i], 'mmm d, yyyy')#<br/>
                        <cfif bibs['librarian_comment'][i] neq ''>
                        <strong>Librarian comment:</strong> #bibs['librarian_comment'][i]#<br/>
                        </cfif>
                        <strong>Your comments:</strong><br/>
                        <textarea id="bib_#bibs['bib_ID'][i]#_comment" rows="5" cols="60">#bibs['faculty_comment'][i]#</textarea><br/>
                        <input type="button" onClick="update('#bibs['bib_ID'][i]#');" value="Update" />
                        <span id="status_#bibs['bib_ID'][i]#"></span>
                    </div>
                </cfloop>
            </div>
            <cfinvoke
            	component="#application.display.cfc#"
                method="display_pager"
                records="#bibs.recordcount#"
                offset="#session.weeding.offset#"
                page_size="#session.weeding.page_size#"
            />
        <cfelse>
        	<p>The selected department has no titles to review.</p>
        </cfif>
<!---        <cfdump var="#items#"> --->
        
		<script language="JavaScript" type="text/javascript">
        <!--
            function update(bibID){
                $("##status_"+bibID).html(
                    "Updating..."
                );
                
				querystring = "component=weeding&method=add_item_comment&bib_ID=" + bibID + "&comment=" + $("##bib_"+bibID+"_comment").val();
//					window.alert(querystring);
	
                $("##status_"+bibID)
                    .load('/scripts/update.cfm', querystring);
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

<!-- =========================== end column one =========================== --> 

</div>

        <cfinvoke
            component="#application.display.cfc#"
            method="display_footer"
        />

    </body>
</html>