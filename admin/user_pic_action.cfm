<cfsetting requesttimeout="3000">
<cfoutput>
<cfsilent>
	<cfparam name="url.libid" type="numeric" default="0">
	<cfset title = "Change Picture">
</cfsilent>
<cfinvoke
	component="cfc.display"
	method="display_header"
	title="#title#"
	jquery="yes"
    sorttable="yes"
	nofollow="yes"
/>
<body>
<cfinclude template="/includes/header.cfm">

<div id="body">
	<div id="main">
		<div class="container_16">
            <div class="grid_16">
                <cfinvoke
                    component="cfc.display"
                    method="display_breadcrumbs"
                    breadcrumb="Staff Tools,#title#"
                    breadcrumb_url="/staff/,#cgi.SCRIPT_NAME#"
                />
            </div>
			<div class="grid_12">
                <cftry>
                    <h2>#title#</h2>
                    <cfif not(isdefined("session.verified"))>
                        <cfthrow
                            message="Please log in."
                        />
                    </cfif>
                    
                    <cfif session.authorization.authorized neq 'yes'>
                        <cfthrow 
                            type="Not authorized"
                            detail="You are not authorized to use this page.">
                    </cfif>

					<cfif not(isdefined("session.authorization.admin") or isdefined("session.authorization.liaison"))>
                        <cfthrow
                            message="You are not authorized to use this tool."
                        />
                    </cfif>
                    
                    <cfif form.file neq ''>
                        <cffile
                            action="upload"
                            filefield="file"
                            destination="#expandPath('/images/')#"
                            accept="image/jpeg, image/gif, image/png"
                            nameconflict="makeunique"
                            result="uploaded_file"
                        />
                        <cfinvoke
                            component="#application.authorization.cfc#"
                            method="update_user"
                            returnvariable="update_user_check"
                            image_url="/images/#uploaded_file.serverFile#"
                        >
                            <cfif url.libid neq 0>
                                <cfinvokeargument name="ID" value="#url.libid#">
                            <cfelse>
                                <cfinvokeargument name="ID" value="#session.authorization.userid#">
                            </cfif>
                        </cfinvoke>
                    <cfelse>
                        <cfinvoke
                            component="#application.authorization.cfc#"
                            method="update_user"
                            returnvariable="update_user_check"
                            image_url=""
                        >
                            <cfif url.libid neq 0>
                                <cfinvokeargument name="ID" value="#url.libid#">
                            <cfelse>
                                <cfinvokeargument name="ID" value="#session.authorization.userid#">
                            </cfif>
                        </cfinvoke>
                    </cfif>
                    <meta http-equiv="refresh" content="0;URL=." />
                    <cfcatch>
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
                    </cfcatch>
                </cftry>

            </div>
			<cfinvoke
            	component="cfc.display"
                method="display_column2"
                services="no"
            />
            <div class="clear"></div>
		<!--- content end   --->
		</div>
        <cfinvoke
            component="cfc.display"
            method="display_footer"
        />
	</body>
</html>
</cfoutput>