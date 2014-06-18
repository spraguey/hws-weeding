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
<cfsilent>
    <cfif isdefined("url.clear") and url.clear eq 'yes' and isdefined("session.weeding")>
        <cfloop collection="#session.weeding#" item="var">
            <cfset structdelete(session.weeding,var)>
        </cfloop>
    </cfif>
</cfsilent>
<cftry>
    <cfoutput>
        <cfinvoke
            component="#application.display.cfc#"
            method="display_breadcrumbs"
            breadcrumb="Weeding Home,Library Staff Portal,Manage Items"
            breadcrumb_url="#application.weeding.home#,.,?view=manage"
        />
        <cfif isLoggedIn() neq 'yes'>
            <h2>Manage Items</h2>
            <cfthrow message="Please log in.">
        </cfif>

        <cfif isAuthorized() neq 'yes'>
            <cfthrow
                message="You are not authorized to use this page.">
        </cfif>

		<cfset session.weeding.user=session.authorization>

		<!--- initialize session variables and set defaults --->
        <cfif not(isdefined("session.weeding"))>
            <cfset session.weeding = {}>
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
    
        <cfif not(isdefined("session.weeding.userid"))>
            <cfset session.weeding.userid = 0>
        </cfif>
        <cfif isdefined("url.userid")>
            <cfset session.weeding.userid = url.userid>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.deptid"))>
            <cfset session.weeding.deptid = 0>
        </cfif>
        <cfif isdefined("url.deptid")>
            <cfset session.weeding.deptid = url.deptid>
            <cfset session.weeding.userid = 0>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.hascomments"))>
            <cfset session.weeding.hascomments = ''>
        </cfif>
        <cfif isdefined("url.hascomments")>
            <cfset session.weeding.hascomments = url.hascomments>
            <cfset session.weeding.acknowledged = ''>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.acknowledged"))>
            <cfset session.weeding.acknowledged = ''>
        </cfif>
        <cfif isdefined("url.acknowledged")>
            <cfset session.weeding.acknowledged = url.acknowledged>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.expired"))>
            <cfset session.weeding.expired = ''>
        </cfif>
        <cfif isdefined("url.expired")>
            <cfset session.weeding.expired = url.expired>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.active"))>
            <cfset session.weeding.active = ''>
        </cfif>
        <cfif isdefined("url.active")>
            <cfset session.weeding.active = url.active>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.needsreview"))>
            <cfset session.weeding.needsreview = ''>
        </cfif>
        <cfif isdefined("url.needsreview")>
            <cfset session.weeding.needsreview = url.needsreview>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.printable"))>
            <cfset session.weeding.printable = ''>
        </cfif>
        <cfif isdefined("url.printable")>
            <cfset session.weeding.printable = url.printable>
        </cfif>
        <cfif not(isdefined("session.weeding.printed"))>
            <cfset session.weeding.printed = ''>
        </cfif>
        <cfif isdefined("url.printed")>
            <cfset session.weeding.printed = url.printed>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.specialcollections"))>
			<cfset session.weeding.specialcollections = ''>
            <cfset session.weeding.specialcollectionsdecision = ''>
        </cfif>
        <cfif isdefined("url.specialcollections")>
            <cfset session.weeding.specialcollections = url.specialcollections>
        	<cfset session.weeding.specialcollectionsdecision = ''>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif isdefined("url.specialcollectionsdecision")>
        	<cfset session.weeding.specialcollectionsdecision = url.specialcollectionsdecision>
        </cfif>
        <cfif not(isdefined("session.weeding.title_kw"))>
            <cfset session.weeding.title_kw = ''>
        </cfif>
        <cfif isdefined("url.title_kw")>
            <cfset session.weeding.title_kw = url.title_kw>
            <cfset session.weeding.offset = 0>
        </cfif>
        <cfif not(isdefined("session.weeding.mode"))>
        	<cfset session.weeding.mode = ''>
        </cfif>
        <cfif isdefined("url.mode")>
        	<cfset session.weeding.mode = url.mode>
            <cfif url.mode eq 'cataloging' and not(isdefined("url.sort"))>
            	<cfset session.weeding.sort = 'call_no'>
            </cfif>
            <cfif url.mode eq 'cataloging' and not(isdefined("url.page_size"))>
            	<cfset session.weeding.page_size = 50>
            </cfif>
        </cfif>

		<!--- start of limits section --->
		<cfif 
			session.weeding.userid neq 0
			or session.weeding.deptid neq 0
		 	or session.weeding.hascomments neq ''
			or session.weeding.expired neq ''
			or session.weeding.active neq ''
			or session.weeding.needsreview neq ''
			or session.weeding.printed neq ''
			or session.weeding.specialcollections neq ''
			or session.weeding.specialcollectionsdecision neq ''
			or session.weeding.title_kw neq ''
		>
        	<cfset limits_on = 'yes'>
        </cfif>
        <div class="p" id="limits_info">
        	<cfif isdefined("limits_on")>
            	<strong>Limits are in effect.</strong>
            </cfif>
            (<a class="link" onClick="$('##limits').show(); $('##limits_info').hide();">View/change limits</a>)
        </div>
		<div id="limits" style="display:none;">

            <p>(<a class="link" onClick="$('##limits').hide(); $('##limits_info').show();">Hide limits</a>)</p>
            
            <div class="p">
                <form method="get" action=".">
                    <strong>Title search (keyword):</strong>
                    <input type="hidden" name="view" value="manage"/>
                    <input type="text" length="50" name="title_kw" value="#session.weeding.title_kw#" />
                    <input type="submit"/>
                    <input type="button" value="Clear" onClick="window.location='?view=manage&title_kw=';"/>
                </form>
            </div>
            
			<cfif isAuthorized('admin') eq 'yes'>
                <cfinvoke
                    component="#application.authorization.cfc#"
                    method="get_users"
                    permission_name="Liaison"
                    returnvariable="liaisons"
                />
                <cfif session.weeding.userid neq 0 and session.weeding.userid neq session.authorization.userID>
                    <cfinvoke
                        component="#application.authorization.cfc#"
                        method="get_authorization"
                        librarian_ID="#session.weeding.userid#"
                        returnvariable="session.weeding.user"
                    />
                    <cfif not(isdefined("session.weeding.user.liaison") or isdefined("session.weeding.user.admin"))>
                        <!--- invalid user; reset to authorized (logged-in) user --->
                        <cfset session.weeding.user=session.authorization>
                        <cfset session.weeding.userid=session.weeding.user.userid>
                    </cfif>
                </cfif>
    			
                <div class="p">
                    <strong>Change user:</strong>
                    <select name="change_user" onChange="window.location='?view=manage&userid='+this.value">
                        <option value="0">All users</option>
                        <cfloop query="liaisons">
                            <cfif liaisons.ID eq session.weeding.userID>
                                <option value="#liaisons.ID#" selected="selected">#liaisons.lastname#, #liaisons.firstname#</option>
                            <cfelse>
                                <option value="#liaisons.ID#">#liaisons.lastname#, #liaisons.firstname#</option>
                            </cfif>
                        </cfloop>
                    </select>
                </div>
            </cfif>
    
            <cfinvoke
                component="#application.weeding.cfc#"
                method="get_bib_departments"
                distinct="yes"
                returnvariable="departments"
            />
            <cfset department_selected = 0>
    
            <div class="p">
                <strong>Select department:</strong>
                <select onChange="window.location='?view=manage&deptid='+this.value;">
                    <option value="0">All departments</option>
                    <cfif session.weeding.deptid eq -1>
                        <option value="-1" selected="selected">No department</option>
                        <cfset department_selected = -1>
                    <cfelse>
                        <option value="-1">No department</option>
                    </cfif>
                    <cfloop query="departments">
                        <cfif departments.department_ID eq session.weeding.deptid>
                            <option value="#departments.department_ID#" selected="selected">#departments.name#</option>
                            <cfset department_selected = departments.department_ID>
                        <cfelse>
                            <option value="#departments.department_ID#">#departments.name#</option>
                        </cfif>
                    </cfloop>
                </select>
            </div>
            
            <div class="p">
            	<strong>Sort order:</strong>
                <select onChange="window.location='?view=manage&sort='+this.value;">
                	<cfif session.weeding.hascomments eq 'yes'>
	                	<option value="">Comment date (most recent first)</option>
                    <cfelse>
                    	<option value="">Date added (most recent first)</option>
                    </cfif>
                   	<cfif session.weeding.sort eq 'author'>
	                    <option value="author" selected="selected">Author</option>
                    <cfelse>
	                    <option value="author">Author</option>
                    </cfif>
                   	<cfif session.weeding.sort eq 'title'>
	                    <option value="title" selected="selected">Title</option>
                    <cfelse>
	                    <option value="title">Title</option>
                    </cfif>
                    <cfif session.weeding.sort eq 'call_no'>
	                    <option value="call_no" selected="selected">Call number</option>
                    <cfelse>
	                    <option value="call_no">Call number</option>
                    </cfif>
                    <cfif session.weeding.sort eq 'pubdate'>
	                    <option value="pubdate" selected="selected">Publication date (most recent first)</option>
                    <cfelse>
	                    <option value="pubdate">Publication date (most recent first)</option>
                    </cfif>
                </select>
            </div>
            
            <div class="p">
                <strong>Items with faculty comments:</strong>
                <select onChange="window.location='?view=manage&hascomments='+this.value;">
                    <option value="">not limited</option>
                	<cfif session.weeding.hascomments eq 'yes'>
	                	<option value="yes" selected="selected">yes</option>
                    <cfelse>
	                	<option value="yes">yes</option>
                    </cfif>
                	<cfif session.weeding.hascomments eq 'no'>
	                	<option value="no" selected="selected">no</option>
                    <cfelse>
	                	<option value="no">no</option>
                    </cfif>
                </select>
                (Acknowledged:
                    <select onChange="window.location='?view=manage&acknowledged='+this.value;">
                    <option value="">not limited</option>
                        <cfif session.weeding.acknowledged eq 'yes'>
                            <option value="yes" selected="selected">yes</option>
                        <cfelse>
                            <option value="yes">yes</option>
                        </cfif>
                        <cfif session.weeding.acknowledged eq 'no'>
                            <option value="no" selected="selected">no</option>
                        <cfelse>
                            <option value="no">no</option>
                        </cfif>
                    </select>
                )
            </div>
            
            <div class="p">
                <strong>Items flagged for review:</strong>
                <select onChange="window.location='?view=manage&needsreview='+this.value;">
                    <option value="">not limited</option>
                	<cfif session.weeding.needsreview eq 'yes'>
	                	<option value="yes" selected="selected">yes</option>
                    <cfelse>
	                	<option value="yes">yes</option>
                    </cfif>
                	<cfif session.weeding.needsreview eq 'no'>
	                	<option value="no" selected="selected">no</option>
                    <cfelse>
	                	<option value="no">no</option>
                    </cfif>
                </select>
            </div>
            
            <div class="p">
                <strong>Special Collections review:</strong>
                <select onChange="window.location='?view=manage&specialcollections='+this.value;">
                    <option value="">not limited</option>
                	<cfif session.weeding.specialcollections eq 'yes'>
	                	<option value="yes" selected="selected">yes</option>
                    <cfelse>
	                	<option value="yes">yes</option>
                    </cfif>
                	<cfif session.weeding.specialcollections eq 'no'>
	                	<option value="no" selected="selected">no</option>
                    <cfelse>
	                	<option value="no">no</option>
                    </cfif>
                </select>

                <cfif isAuthorized('archives') eq 'yes'>
                (Decision:
                	<select onChange="window.location='?view=manage&specialcollectionsdecision=' + this.value;">
						<cfif session.weeding.specialcollectionsdecision eq 'any'>
                            <option value="any" selected="selected">not limited</option>
                        <cfelse>
                            <option value="any">not limited</option>
                        </cfif>
						<cfif session.weeding.specialcollectionsdecision eq ''>
                            <option value="" selected="selected">no decision</option>
                        <cfelse>
                            <option value="">no decision</option>
                        </cfif>
                        <cfloop list="yes,no" index="decision">
                        	<cfif session.weeding.specialcollectionsdecision eq LCase(decision)>
                                <option value="#LCase(decision)#" selected="selected">#decision#</option>
                            <cfelse>
                                <option value="#LCase(decision)#">#decision#</option>
                            </cfif>
                        </cfloop>
                    </select>
                )
                </cfif>
            </div>
            
            <div class="p">
                <strong>Active items:</strong>
                <select onChange="window.location='?view=manage&active='+this.value;">
                    <option value="">not limited</option>
                	<cfif session.weeding.active eq 'yes'>
	                	<option value="yes" selected="selected">yes</option>
                    <cfelse>
	                	<option value="yes">yes</option>
                    </cfif>
                	<cfif session.weeding.active eq 'no'>
	                	<option value="no" selected="selected">no</option>
                    <cfelse>
	                	<option value="no">no</option>
                    </cfif>
                </select>
            </div>

            <div class="p">
                <strong>Expired items:</strong>
                <select onChange="window.location='?view=manage&expired='+this.value;">
                    <option value="">not limited</option>
                	<cfif session.weeding.expired eq 'yes'>
	                	<option value="yes" selected="selected">yes</option>
                    <cfelse>
	                	<option value="yes">yes</option>
                    </cfif>
                	<cfif session.weeding.expired eq 'no'>
	                	<option value="no" selected="selected">no</option>
                    <cfelse>
	                	<option value="no">no</option>
                    </cfif>
                </select>
            </div>

            <cfif isdefined("session.weeding.user.liaison")>
                <div class="p">
                    <cfif session.weeding.userid neq session.weeding.user.userid>
                        <input type="checkbox" onClick="window.location='?view=manage&userid=#session.weeding.user.userid#';" /> My added items only
                    <cfelse>
                        <input type="checkbox" checked="checked" onClick="window.location='?view=manage&userid=0';" /> My added items only
                    </cfif>
                </div>
            </cfif>
            <div class="p">
            	<input type="button" onClick="window.location='?view=manage&clear=yes';" value="Clear limits"/>
            </div>
		</div>
        <hr/>
        <div class="p">
        	Printable version: 
        	<cfif session.weeding.printable eq 'yes'>
	        	<input type="checkbox" id="printable" checked="checked" onClick="window.location='?view=manage&printable=';"/>
            <cfelse>
	        	<input type="checkbox" id="printable" onClick="window.location='?view=manage&printable=yes';"/>
            </cfif>
        </div>
        <cfif isAuthorized('admin') eq 'yes'>
        	<div class="p">
            	Cataloging view:
            	<cfif session.weeding.mode eq 'cataloging'>
                	<input type="checkbox" id="view" checked="checked" onClick="window.location='?view=manage&mode=';"/>
                <cfelse>
                	<input type="checkbox" id="view" onClick="window.location='?view=manage&mode=cataloging';"/>
                </cfif>
            </div>
        </cfif>
        <cfif isAuthorized('cataloging') eq 'yes' and session.weeding.printed eq 'no'>
        	<div class="p">
            	<input type="button" value="Print" onClick="mark_printed();"/>
                <span id="mark_printed_status">&nbsp;</span>
            </div>
        </cfif>
        <hr/>
        <!--- end of limits section --->
        
        <cfinvoke
        	component="#application.weeding.cfc#"
            method="get_bibs"
            returnvariable="bibs"
        >
			<cfif department_selected neq 0>
                <cfinvokeargument name="department_ID" value="#department_selected#"/>
            </cfif>
            <cfif session.weeding.hascomments neq ''>
            	<cfinvokeargument name="has_comments" value="#session.weeding.hascomments#"/>
            </cfif>
            <cfif session.weeding.acknowledged neq ''>
                <cfinvokeargument name="acknowledged" value="#session.weeding.acknowledged#"/>
            </cfif>
            <cfif session.weeding.expired neq ''>
            	<cfinvokeargument name="expired" value="#session.weeding.expired#"/>
            </cfif>
            <cfif session.weeding.active neq ''>
            	<cfinvokeargument name="active" value="#session.weeding.active#"/>
            </cfif>
            <cfif session.weeding.printed neq ''>
            	<cfinvokeargument name="printed" value="#session.weeding.printed#"/>
            </cfif>
            <cfif session.weeding.userid neq 0>
            	<cfinvokeargument name="librarian_ID" value="#session.weeding.userid#">
            </cfif>
            <cfif session.weeding.needsreview neq ''>
            	<cfinvokeargument name="needs_review" value="#session.weeding.needsreview#">
            </cfif>
            <cfif session.weeding.specialcollections neq ''>
            	<cfinvokeargument name="special_collections" value="#session.weeding.specialcollections#">
            </cfif>
            <cfif session.weeding.sort neq ''>
            	<cfinvokeargument name="sort" value="#session.weeding.sort#">
            </cfif>
            <cfif session.weeding.specialcollectionsdecision neq ''>
            	<cfinvokeargument name="special_collections_decision" value="#session.weeding.specialcollectionsdecision#">
            </cfif>
            <cfif session.weeding.title_kw neq ''>
            	<cfinvokeargument name="title_kw" value="#session.weeding.title_kw#">
            </cfif>
        </cfinvoke>
        
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
            <p><strong>Items #start# - #end# of #bibs.recordcount#</strong></p>
            <cfinvoke
            	component="#application.display.cfc#"
                method="display_pager"
                records="#bibs.recordcount#"
                offset="#session.weeding.offset#"
                page_size="#session.weeding.page_size#"
            />
        	<div id="weeding_bibs">
				<cfif session.weeding.mode eq 'cataloging' or (isAuthorized('cataloging') eq 'yes' and isAuthorized('admin') eq 'no')>
                    <div style="width:900px; padding: 0 0 0 18px; border-bottom: 1px solid black;">
                        <div style="float:left; width:348px; padding: 0 5px 0 5px; border: 1px solid black; text-align:center;">
                            <strong>Title</strong>
                        </div>
                        <div style="float:left; width:250px;">
                            <div style="border: 1px solid black; text-align:center;">
                            	<cfif 
									session.weeding.specialcollections eq 'yes'
									and session.weeding.specialcollectionsdecision eq 'yes'
								>
	                            	<strong>Transfer</strong>
                                <cfelse>
	                            	<strong>Discard</strong>
                                </cfif>
                            </div>
                        </div>
                        <div style="float:left; width:250px;">
                            <div style="border: 1px solid black; text-align:center;">
                            	<strong>Retain</strong>
                            </div>
                        </div>
                    </div>
                    <div style="height: 1px; clear:both;">&nbsp;</div>
                </cfif>
            	<cfloop from="#start#" to="#end#" index="i">
                	<cfinvoke
                    	component="#application.weeding.cfc#"
                        method="display_bib"
                        bib_ID="#bibs['bib_ID'][i]#"
                    />
                </cfloop>
                <cfinvoke
                    component="#application.display.cfc#"
                    method="display_pager"
                    records="#bibs.recordcount#"
                    offset="#session.weeding.offset#"
                    page_size="#session.weeding.page_size#"
                />
            </div>
        <cfelse>
        	<p>No matching items found.</p>
        </cfif>
<!---        <cfdump var="#bibs#"> --->
        
        <div id="dump"></div>
		<script language="JavaScript" type="text/javascript">
        <!--
            function update(bibID){
                $("##status_"+bibID).html(
                    "Updating..."
                );
                
				$("##special_collections_" + bibID).is(':checked') ? special_collections = 'yes' : special_collections = 'no';
				$("##needs_review_" + bibID).is(':checked') ? needs_review = 'yes' : needs_review = 'no';
								
				if (special_collections == 'yes') {
					$("##no_weed_" + bibID).is(':checked') ? no_weed = 'yes' : no_weed = 'no';
				} else {
					no_weed='no';
				}

                querystring = "component=weeding&method=edit_bib&bib_ID=" + bibID + "&comment=" + $("##bib_"+bibID+"_comment").val() + "&special_collections=" + special_collections + "&needs_review=" + needs_review + "&no_weed=" + no_weed;
				<cfif isAuthorized('archives') eq 'yes'>
					querystring += "&special_collections_decision=" + $("##special_collections_decision_" + bibID).val();
				</cfif>
//    			window.alert(querystring);
    
                $("##status_"+bibID)
                    .load('#application.weeding.home#/scripts/update.cfm', querystring);
            }

            function addComment(bibID) {
                $("##bib_"+bibID+"_comment_#session.authorization.IID#_status").html("Updating...");
                sendURL = "/scripts/get.cfm?component=weeding&method=add_item_comment&bib_ID=" + bibID + "&comment=" + $("##bib_"+bibID+"_comment_#session.authorization.IID#_textarea").val();
//                window.alert(sendURL);
                $.ajax({
                    url: sendURL,
                    success: function(){
                        $("##bib_"+bibID+"_faculty_comment_status").html("Updated");
                        window.location.reload();
                    }
                });
            }

            function acknowledge(bibID, facultyID) {
                $("##bib_"+bibID+"_comment_"+facultyID+"_status").html("Updating...");
                sendURL = "/scripts/get.cfm?component=weeding&method=acknowledge&bib_ID=" + bibID + "&faculty_ID=" + facultyID;
//                window.alert(sendURL);
                $.ajax({
                    url: sendURL,
                    success: function(){
                        $("##bib_"+bibID+"_comment_"+facultyID+"_status").html("Updated");
                        $("##bib_"+bibID+"_comment_"+facultyID+"_acknowledge").hide();
                        if ($("##bib_"+bibID+"_comment_"+facultyID+"_acknowledged").length) {
							$("##bib_"+bibID+"_comment_"+facultyID+"_acknowledged").show();
						}
                    }
                });
            }
            
			function toggleNoWeed(bibID) {
				$("##special_collections_" + bibID).is(':checked') ? special_collections = 'yes' : special_collections = 'no';
				if (special_collections == 'yes') {
					$("##no_weed_span_" + bibID).show();
				} else {
					$("##no_weed_span_" + bibID).hide();
				}
			}

            function delete_department(bibID, department_ID){
                $("##status_"+bibID).html(
                    "Updating..."
                );
                
                querystring = "component=weeding&method=delete_bib_department&bib_ID=" + bibID + "&department_ID=" + department_ID;
    //			window.alert(querystring);
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?' + querystring,
                    success: function(){
                        $("##bib_" + bibID + "_department_" + department_ID).remove();
						$("##status_"+bibID).html(
							"Updated"
						);
                    }
                });
            }
    
            function addDept(bibID) {
                $("##status_"+bibID).html(
                    "Updating..."
                );
                
                deptname = $("##add_department_"+bibID).val();
    //			window.alert(deptname);
                $.ajax({
                    url: '#application.weeding.home#/scripts/get.cfm?component=miscellaneous&method=get_department_id&dept=' + deptname,
                    success: function(dept_ID){
                        dept_ID = jQuery.trim(dept_ID);
    //					$('##dump').html(dept_ID);
                        if (dept_ID == 0) {
                            window.alert('Department not found');
                        } else {
                            $.ajax({
                                url: '#application.weeding.home#/scripts/update.cfm?component=weeding&method=add_bib_department&bib_ID=' + bibID + '&department_ID=' + dept_ID,
                                success: function(response){
                                    if (jQuery.trim(response) == 'Error') {
										$("##status_"+bibID).html(
											"Unable to add department"
										);
                                    } else {
                                        new_dept_span = ' <span id="bib_' + bibID + '_department_' + dept_ID + '">' + deptname + ' [<a class="link" onclick="delete_department(';
                                        new_dept_span += "'" + bibID + "', '" + dept_ID + "');";
                                        new_dept_span += '">x</a>]';
                                        $("##bib_" + bibID + "_departments").append(new_dept_span);
										$("##status_"+bibID).html(
											"Updated"
										);
                                    }
                                }
                            });
                        }
                    }
                });
            }
    
            function enable_delete(bibID) {
    //			$("##item" + _barcode + "_delete")
                $("##bib_" + bibID + "_confirm").is(':checked') ? $("##bib_" + bibID + "_delete").removeAttr('disabled') : $("##bib_" + bibID + "_delete").attr('disabled', 'disabled');
            }
    
            function add_item(barcode, bibID) {
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?component=weeding&method=add_item&item_barcode=' + barcode,
                    success: function(result) {
    //					result = jQuery.trim(result);
    //					window.alert(result);
                        $("##item_" + barcode).appendTo("##bib_" + bibID + "_withdraw");
                        $("##add_item_" + barcode).hide();
                        $("##delete_item_" + barcode).show();
                    }
                });
            }
    
            function delete_item(barcode, bibID) {
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?component=weeding&method=delete_item&item_barcode=' + barcode,
                    success: function(result) {
    //					result = jQuery.trim(result);
    //					window.alert(result);
                        $("##item_" + barcode).appendTo("##bib_" + bibID + "_retain");
                        $("##add_item_" + barcode).show();
                        $("##delete_item_" + barcode).hide();
                    }
                });
            }
    
            function add_all(bibID) {
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?component=weeding&method=add_all&bib_ID=' + bibID,
                    success: function(result) {
    //					result = jQuery.trim(result);
    //					window.alert(result);
                        $(".bib_" + bibID + "_item").appendTo("##bib_" + bibID + "_withdraw");
                        $(".bib_" + bibID + "_item_add").hide();
                        $(".bib_" + bibID + "_item_delete").show();
                    }
                });
            }
    
            function delete_bib(bibID) {
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?component=weeding&method=delete_bib&bib_ID=' + bibID,
                    success: function(result) {
//    					result = jQuery.trim(result);
//		                $("##status_"+bibID).html(result);
						$("##bib_" + bibID + "_wrapper").remove();
                    }
                });
            }
    
            function toggle_printable() {
    //			$("##item" + _barcode + "_delete")
                if ($("##printable").is(':checked')) {
					$("##topbar").hide();
					$("##header").hide();
					$("##isloggedin").hide();
					$("##limits_info").hide();
					$("##footer").hide();
					$("body").css("background-image", 'none');
				} else {
					$("##topbar").show();
					$("##header").show();
					$("##isloggedin").show();
					$("##limits_info").show();
					$("##footer").show();
					$("body").css("background-image", "url('https://www.hws.edu/images/back.jpg')");
				}
            }
			
			function mark_printed() {
				window.print();
				
				var proceed = window.confirm("Mark titles as printed?");
				if (proceed==true) {

					$("##mark_printed_status").text("Processing...");
	
					sendUrl = '#application.weeding.home#/scripts/update.cfm?component=weeding&method=mark_printed&bib_IDs=';
					$(".manage_weeding_item").each(function() {
						//extract the bib_ID from each element's ID
						bibid = this.id.replace("bib_", "");
						sendUrl += bibid + ',';
					});
					sendUrl = sendUrl.slice(0,-1);
	//				window.alert(sendUrl);
					$.ajax({
						url: sendUrl,
						success: function(html) {
							$("##mark_printed_status").text("Done");
							window.location.reload();
						}
					});
				}
			}
    
            $(document).ready(function(){
                <cfinvoke
                    component="#application.miscellaneous.cfc#"
                    method="get_departments"
                    returnvariable="departments"
                />
                
                <cfloop query="departments">
                    <cfset departments["name"][currentrow] = REReplace(departments["name"][currentrow], "'", "&##039;", "all")>
                    <cfset departments["name"][currentrow] = REReplace(departments["name"][currentrow], ",", "&##044;", "all")>
                </cfloop>
        
                <cfset department_list = ListQualify(ValueList(departments.name), '"')>
                <cfset department_list = REReplace(department_list, "&##039;", "'", "all")>
                <cfset department_list = REReplace(department_list, "&##044;", ",", "all")>
                
                $(".add_department").autocomplete({
                    source: [#department_list#]
                });
				
				<cfif session.weeding.printable eq 'yes'>
					toggle_printable();
				</cfif>
            });
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
