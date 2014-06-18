<cfoutput>
    <link href="#application.weeding.home#/css/library.css" rel="stylesheet" type="text/css"/>
    <link href="#application.weeding.home#/css/960.css" rel="stylesheet" type="text/css"/>
    <link href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/jquery-ui.min.js"></script>
    <cfinvoke
        component="#application.authorization.cfc#"
        method="set_authorization"
    />
</cfoutput>