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
            breadcrumb="Weeding Home,Library Staff Portal,Add Items"
            breadcrumb_url="#application.weeding.home#,.,?view=upload"
        />
        <h2>Upload Items</h2>
        <cfif isLoggedIn() neq 'yes'>
            <cfthrow message="Please log in.">
        </cfif>

        <cfif isAuthorized('liaison') neq 'yes'>
            <cfthrow
                message="You are not authorized to use this page.">
        </cfif>

        <p>
            <strong>Mode:</strong>
            <input 
                type="radio" 
                name="inputMode" 
                value="single"
                onclick="$('##divFile').hide(); $('##divSingle').show(); $('##singleBarcode').focus();"
            /> Single
            <input 
                type="radio" 
                name="inputMode" 
                value="file"
                onclick="$('##divFile').show(); $('##divSingle').hide();"
            /> File
        </p>
        
        <p><strong>Current review period:</strong> #DateFormat(DateAdd('d', 7, Now()), 'mmm d, yyyy')# - #DateFormat(DateAdd('d', 187, Now()), 'mmm d, yyyy')#</p>
        
        <div id="divFile" style="display:none;">
<!---
            <p>This tool takes as input a text file of Voyager barcodes to be added to the Weeding Manager.</p>
--->
            <form action="process_file.cfm" method="post" enctype="multipart/form-data" name="frmProcessFile">
                <p>Browse to your barcode file, then click Go.</p>
                <p><input name="barcodefile" type="file" id="barcodefile" size="50" /></p>
                <div style="width:500px; border: 1px solid black;">
                    <p><strong>Optional fields to be added to all items</strong></p>
                    <p>
                        <strong>Department:</strong>
                        <select name="department_ID">
                            <option value="">Select a department</option>
                            <cfinvoke
                                component="#application.miscellaneous.cfc#"
                                method="get_departments"
                                returnvariable="departments"
                            >
                                <cfif isAuthorized('admin') eq 'no'>
                                    <cfinvokeargument name="liaison_ID" value="#session.authorization.userid#">
                                </cfif>
                            </cfinvoke>
                            <cfloop query="departments">
                                <cfoutput>
                                    <option value="#departments.ID#">#departments.name#</option>
                                </cfoutput>
                            </cfloop>
                        </select>
                    </p>
                    <p><strong>Comment</strong><br/><textarea name="comment" rows="5" cols="40"></textarea></p>
                </div>
                <p><input type="submit" name="Check" value="Go"></p>
            </form>
        </div>
        
        <div id="divSingle">
<!---
            <p>This tool accepts one item barcode at a time to add to the Weeding Manager.</p>
--->
            <p>
                <strong>Barcode:</strong>
                <input type="text" maxlength="14" id="singleBarcode" />
                <input type="button" value="Add" onClick="addBarcode($('##singleBarcode').val());" />
                <span id="addBarcodeStatus"></span>
            </p>
            <div class="p" id="newItems"></div>
        </div>
        <script language="JavaScript" type="text/javascript">
        <!--
            function addBarcode(currentBarcode) {
                $('##addBarcodeStatus').html('Working...');
//				currentBarcode = $('##singleBarcode').val();
                sendUrl = '#application.weeding.home#/scripts/update.cfm?component=weeding&method=add_item&item_barcode=' + currentBarcode;
                $.ajax({
                    url: sendUrl,
                    success: function(result) {
                        result = jQuery.trim(result);
                        if (result != 'Updated') {
                            $('##addBarcodeStatus').html(result);
                            return false;
                        }
                        $('##addBarcodeStatus').html('');
                        getDescription = '#application.weeding.home#/scripts/get.cfm?component=weeding&method=get_items&item_barcode=' + currentBarcode;
                        $.ajax({
                            url: getDescription,
                            success: function(result) {
                                result = jQuery.parseJSON(result);
                                var bibid = result.DATA[0][3];
                                
                                getBib = '#application.weeding.home#/libstaff/bib.cfm?bib_ID=' + bibid;
                                $.ajax({
                                    url: getBib,
                                    success: function(newitem) {
                                        $("##newItems").prepend(newitem);
                                        addDepartmentList();
                                    }
                                });
                            }
                        });
                    }
                });
                $('##singleBarcode').val('');
                $('##singleBarcode').focus();
            }
            
            function addDepartmentList() {
                <cfinvoke
                    component="#application.miscellaneous.cfc#"
                    method="get_departments"
                    returnvariable="departments"
                >
                    <cfif isAuthorized('admin') eq 'no'>
                        <cfinvokeargument name="liaison_ID" value="#session.authorization.userid#">
                    </cfif>
                </cfinvoke>
                
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
            }

            $('##singleBarcode').keypress(function(e) {
                if(e.which == 13) {
                    addBarcode($('##singleBarcode').val());
                }
            });					

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
                <cfif isAuthorized('archives')>
                    querystring += "&special_collections_decision=" + $("##special_collections_decision_" + bibID).val();
                </cfif>
//    			window.alert(querystring);
    
                $("##status_"+bibID)
                    .load('#application.weeding.home#/scripts/update.cfm', querystring);
                $('##singleBarcode').focus();
            }
            
            function toggleNoWeed(bibID) {
                $("##special_collections_" + bibID).is(':checked') ? special_collections = 'yes' : special_collections = 'no';
                if (special_collections == 'yes') {
                    $("##no_weed_span_" + bibID).show();
                } else {
                    $("##no_weed_span_" + bibID).hide();
                }
                $('##singleBarcode').focus();
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
                        $('##singleBarcode').focus();
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
                                        $('##singleBarcode').focus();
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
                        $('##singleBarcode').focus();
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
                        $('##singleBarcode').focus();
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
                        $('##singleBarcode').focus();
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
                        $('##singleBarcode').focus();
                    }
                });
            }
    
<!---
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
                <cfif 
                    isdefined("session.authorization.archives") 
                    or isdefined("session.authorization.admin")
                >
                    querystring += "&special_collections_decision=" + $("##special_collections_decision_" + bibID).val();
                </cfif>
//    			window.alert(querystring);
    
                $("##status_"+bibID)
                    .load('#application.weeding.home#/scripts/update.cfm', querystring);

            }
            
            function toggleNoWeed(bibid) {
                $("##special_collections_" + bibid).is(':checked') ? special_collections = 'yes' : special_collections = 'no';
                if (special_collections == 'yes') {
                    $("##no_weed_span_" + bibid).show();
                } else {
                    $("##no_weed_span_" + bibid).hide();
                }
            }
            
            function delete_department(bibID, department_ID){
                querystring = "component=weeding&method=delete_bib_department&bib_ID=" + bibID + "&department_ID=" + department_ID;
    //			window.alert(querystring);
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?' + querystring,
                    success: function(){
                        $("##bib_" + bibID + "_department_" + department_ID).remove();
                    }
                });
            }
    
            function addDept(bibid) {
                deptname = $("##add_department_" + bibid).val();
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
                                url: '#application.weeding.home#/scripts/update.cfm?component=weeding&method=add_bib_department&bib_ID=' + bibid + '&department_ID=' + dept_ID,
                                success: function(response){
                                    if (jQuery.trim(response) == 'Error') {
                                        window.alert('Unable to add department');
                                    } else {
                                        new_dept_span = ' <span id="bib_' + bibid + '_department_' + dept_ID + '">' + deptname + ' [<a class="link" onclick="delete_department(';
                                        new_dept_span += "'" + bibid + "', '" + dept_ID + "');";
                                        new_dept_span += '">x</a>]';
                                        $("##bib_" + bibid + "_departments").append(new_dept_span);
                                    }
                                }
                            });
                        }
                    }
                });
            }

            function deleteBarcode(barcode) {
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?component=weeding&method=delete_item&item_barcode=' + barcode + '&librarian_ID=#session.authorization.userid#',
                    success: function(result) {
                        $("##" + barcode).remove();
                    }
                });
                $('##singleBarcode').focus();
            }
            
            function deleteBib(bibid) {
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?component=weeding&method=delete_bib&bib_ID=' + bibid,
                    success: function(result) {
                        $("##" + bibid).remove();
                    }
                });
                $('##singleBarcode').focus();
            }
            
            function delete_department(bibid, department_ID){
                querystring = "component=weeding&method=delete_bib_department&bib_ID=" + bibid + "&department_ID=" + department_ID;
    //			window.alert(querystring);
                $.ajax({
                    url: '#application.weeding.home#/scripts/update.cfm?' + querystring,
                    success: function(){
                        $("##bib_" + bibid + "_department_" + department_ID).remove();
                    }
                });
                $('##singleBarcode').focus();
            }
    
            function getDepts(bibid) {
                sendUrl = "/scripts/get.cfm?component=weeding&method=get_bib_departments&bib_ID=" + bibid;
                $.ajax({
                    url: sendUrl,
                    success: function(result) {
                        result = jQuery.parseJSON(result);
                        for(var i = 0, l = result.DATA.length; i < l; i++) {
                            dept_ID = result.DATA[i][1];
                            deptname = result.DATA[i][2];
                            new_dept_span = ' <span id="bib_' + bibid + '_department_' + dept_ID + '">' + deptname + ' [<a class="link" onclick="delete_department(';
                            new_dept_span += "'" + bibid + "', '" + dept_ID + "');";
                            new_dept_span += '">x</a>]';
                            $("##departments_" + bibid).append(new_dept_span);
                        }
                    }
                });
            }
            
            function getItems(bibid) {
                weed_table = '<p><strong>Weed:</strong></p><table id="weed_items_' + bibid + '"><tr><th>Item</th><th>Charges</th><th>Browses</th><th>Last circ</th></tr></table>';
                keep_table = '<p><strong>Keep:</strong></p><table id="keep_items_' + bibid + '"><tr><th>Item</th><th>Charges</th><th>Browses</th><th>Last circ</th></tr></table>';
                $("##items_" + bibid).append(weed_table);
                $("##items_" + bibid).append(keep_table);
                sendUrl = "/scripts/get.cfm?component=voyager&method=get_items&bib_ID=" + bibid;
                $.ajax({
                    url: sendUrl,
                    success: function(result) {
                        bibitems = jQuery.parseJSON(result);
                        for(var i = 0, l = bibitems.DATA.length; i < l; i++) {
                            barcode = bibitems.DATA[i][0];
                            item_enum = bibitems.DATA[i][3];
                            chron = bibitems.DATA[i][4];
                            copy = bibitems.DATA[i][10];
                            if (item_enum == null) {
                                item_enum = '';
                            }
                            if (chron == null) {
                                chron = '';
                            }
                            stats_line = '<tr id="stats_' + barcode + '"><td>' + item_enum + ' ' + chron + ' copy ' + copy + '</td></tr>';
                            weedCheckUrl = "/scripts/get.cfm?component=weeding&method=get_items&item_barcode=" + barcode;
                            $.ajax({
                                url: weedCheckUrl,
                                success: function(result) {
                                    weedcheck = jQuery.parseJSON(result);
                                    if (weedcheck.DATA.length == 0) {
                                        $("##keep_items_" + bibid).append(stats_line);
                                    } else {
                                        $("##weed_items_" + bibid).append(stats_line);
                                    }
                                }
                            });
                            getStats(barcode);
                        }
                    }
                });
            }
            
            function getStats(barcode) {
                sendUrl = "/scripts/get.cfm?component=weeding&method=get_item_stats&item_barcode=" + barcode;
                $.ajax({
                    url: sendUrl,
                    success: function(result) {
                        result = jQuery.parseJSON(result);
                        hist_charges = result.DATA[0][0];
                        hist_browses = result.DATA[0][1];
                        last_charged = result.DATA[0][2];
                        if (last_charged == null) {
                            last_charged = '';
                        }
                        itemstats = '<td>' + hist_charges + '</td><td>' + hist_browses + '</td><td>' + last_charged + '</td>';
                        $("##stats_" + barcode).append(stats_table);
                    }
                });
            }

            function updateBib(bibid){
                $("##status_"+bibid).html(
                    "Updating..."
                );
                
                $("##special_collections_" + bibid).is(':checked') ? special_collections = 'yes' : special_collections = 'no';
                $("##needs_review_" + bibid).is(':checked') ? needs_review = 'yes' : needs_review = 'no';
                if (special_collections == 'yes') {
                    $("##no_weed_" + bibid).is(':checked') ? no_weed = 'yes' : no_weed = 'no';
                } else {
                    no_weed='no';
                }
                
                querystring = "component=weeding&method=edit_bib&bib_ID=" + bibid + "&comment=" + $("##comment_"+barcode).val() + "&special_collections=" + special_collections + "&needs_review=" + needs_review + "&no_weed=" + no_weed;
    //			window.alert(querystring);
    
                $("##status_"+bibid)
                    .load('#application.weeding.home#/scripts/update.cfm', querystring);

                $('##singleBarcode').focus();
            }

--->
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