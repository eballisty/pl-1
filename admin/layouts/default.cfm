<cfset $.rc.baseURL = cgi.script_name>

<cfsavecontent variable="body"><cfoutput>
	<div class="admin-container">#$.rc.bodyContent#</div>
</cfoutput></cfsavecontent>

<cfoutput>#application.pluginManager.renderAdminTemplate(body=body,pageTitle='Admin')#</cfoutput>
