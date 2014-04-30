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
<cfif isdefined("session.weeding")>
	<cfloop collection="#session.weeding#" item="var">
		<cfset structdelete(session.weeding,var)>
	</cfloop>
</cfif>

<cfoutput>
	<h2>#title#</h2>
	<cfif isLoggedIn() neq 'yes'>
		<cfthrow message="Please log in.">
	</cfif>

	<cfif isAuthorized() neq 'yes'>
		<cfthrow
			message="You are not authorized to use this page.">
	</cfif>
	
	<div class="p">
		<form method="get" action="index.cfm">
			<strong>Title search (keyword):</strong>
            <input type="hidden" name="view" value="manage"/>
			<input type="text" length="50" name="title_kw"/>
			<input type="submit"/>
		</form>
	</div>
	
	<cfif isAuthorized('liaison') eq 'yes'>
		<p><a href="?view=upload">Add items for weeding review</a></p>
		<p><a href="?view=manage">Manage/review items</a></p>
		<p><a href="/reports/collectionreview">Faculty view</a></p>
		<p>&nbsp;</p>
	</cfif>
	
	<cfif isAuthorized('cataloging') eq 'yes' and isAuthorized('admin') eq 'no'>
		<cfset format = "&sort=call_no&printable=yes&page_size=50">
	<cfelse>
		<cfset format = "">
	</cfif>


	<p><strong>Weeding queue</strong></p>
	<cfif isAuthorized('cataloging') eq 'yes'>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			delay="7"
			expired="yes"
			has_comments="no"
			acknowledged="yes"
			printed="no"
			returnvariable="weedable"
		/>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			delay="7"
			expired="yes"
			has_comments="no"
			acknowledged="yes"
			printed="yes"
			returnvariable="weedable_printed"
		/>
		<p><a href="?view=manage&expired=yes&printed=no&hascomments=no&acknowledged=yes#format#">Weedable titles</a>: #weedable.recordcount#</p>
		<cfif weedable_printed.recordcount neq 0>
			<p><a href="?view=manage&expired=yes&printed=yes&hascomments=no&acknowledged=yes#format#">Weedable titles (printed)</a>: #weedable_printed.recordcount#</p>
		</cfif>
	<cfelse>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			delay="7"
			expired="yes"
			has_comments="no"
			acknowledged="yes"
			returnvariable="weedable"
		/>
		<p><a href="?view=manage&expired=yes&hascomments=no&acknowledged=yes">Weedable titles</a>: #weedable.recordcount#</p>
	</cfif>
	<cfif isAuthorized('liaison') eq 'yes'>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			delay="7"
			active="yes"
			returnvariable="under_review"
		/>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			delay="7"
			active="no"
			expired="no"
			special_collections="no"
			needs_review="no"
			returnvariable="nyi"
		/>
		<p><a href="?view=manage&active=yes">Titles under faculty review</a>: #under_review.recordcount#</p>
		<p><a href="?view=manage&active=no&expired=no&specialcollections=no&needsreview=no">Not yet active</a>: #nyi.recordcount#</p>
	</cfif>
	<p>&nbsp;</p>

	<cfif isAuthorized('liaison') eq 'yes'>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			delay="7"
			expired="yes"
			has_comments="yes"
			acknowledged="no"
			returnvariable="weedable_comment"
		/>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			needs_review="yes"
			returnvariable="needs_review"
		/>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			special_collections="yes"
			returnvariable="special_collections"
		/>
		<p><strong>Review queue</strong></p>
		<p><a href="?view=manage&expired=yes&hascomments=yes&acknowledged=no">Comment review</a>: #weedable_comment.recordcount#</p>
		<p><a href="?view=manage&needsreview=yes">Needs review</a>: #needs_review.recordcount#</p>
	</cfif>
	<cfif isAuthorized('archives') eq 'yes'>
		<p><a href="?view=manage&specialcollections=yes">Special collections review</a>: #special_collections.recordcount#</p>
	</cfif>
	<cfif isAuthorized('archives') eq 'yes' or isAuthorized('cataloging') eq 'yes'>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			special_collections="yes"
			special_collections_decision="yes"
			printed="no"
			returnvariable="special_collections_transfer"
		/>
		<cfinvoke
			component="#application.weeding.cfc#"
			method="get_bibs"
			special_collections="yes"
			special_collections_decision="yes"
			printed="yes"
			returnvariable="special_collections_transfer_pending"
		/>
		<p><a href="?view=manage&specialcollections=yes&specialcollectionsdecision=yes&printed=no#format#">Transfer to special collections</a>: #special_collections_transfer.recordcount#</p>
		<cfif special_collections_transfer_pending.recordcount neq 0>
			<p><a href="?view=manage&specialcollections=yes&specialcollectionsdecision=yes&printed=yes#format#">Transfer to special collections (printed)</a>: #special_collections_transfer_pending.recordcount#</p>
		</cfif>
	</cfif>
	
	<cfif isAuthorized('admin') eq 'yes'>
	<p>&nbsp;</p>
	<p><strong>Tools</strong></p>
	<p><a class="link" onClick="update_completed();">Force completion of Voyager withdrawn/transferred items</a> <span id="update_completed_status"></span></p>
	<script language="JavaScript" type="text/javascript">
		<!--
		function update_completed() {
			$("##update_completed_status").text('Updating...');
			$.ajax({
				url: '/scripts/update.cfm?component=weeding&method=update_complete',
				success: function(result) {
					$("##update_completed_status").text('Done');
					window.location.reload();
				}
			});
		}
		//-->
	</script>
	</cfif>

</cfoutput>
