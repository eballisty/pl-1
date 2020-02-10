<!--- version 1.18.1.19 --->
<cfcomponent extends="mura.cfobject">
	<cfset variables.controllers = structNew()>
	<cfset variables.beans = structNew()>

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="pluginConfig" type="any" required="true">

		<cfset variables.pluginConfig = arguments.pluginConfig>

		<cfreturn this>
	</cffunction>

	<cffunction name="getPluginConfig" access="public" returntype="any" output="false">
		<cfreturn variables.pluginConfig>
	</cffunction>

	<cffunction name="handleRequest">
		<cfargument name="$">
		<cfif not structKeyExists(arguments, "$")>
			<cfset var req = structNew()>
			<cfset structAppend(req, url)>
			<cfset structAppend(req, form)>
			<cfset req.siteID = structKeyExists(session, "siteID") ? session.siteID : "default">
			<cfset local.$ = application.serviceFactory.getBean("MuraScope").init(req)>
		</cfif>

		<cfset var params = getCallingParams()>

		<cfset doRequest($=$, _section=params.section, _package=params.package, _basePath=params.basePath)>
	</cffunction>

	<cffunction name="doRequest">
		<cfargument name="$">
		<cfargument name="_section" required="true" default="">
		<cfargument name="_action" required="true" default="">
		<cfargument name="_controller" required="true" default="">
		<cfargument name="_layout" required="true" default="">
		<cfargument name="_vType" required="true" default="">
		<cfargument name="_package" required="true" default="#variables.pluginConfig.getPackage()#">
		<cfargument name="_basePath" required="true" default="#variables.pluginConfig.getPackage()#">
		<cfset var rp = structNew()>
		<cfset rp.section = getSection(argumentCollection = arguments)>
		<cfset rp.action = getAction(argumentCollection = arguments)>
		<cfset rp.controller = getController(argumentCollection = arguments)>
		<cfset rp.layout = getLayout(argumentCollection = arguments)>
		<cfset rp.vType = getViewType(argumentCollection = arguments)>

		<cfif isValidAction(rp)>
			<cfset rp.action = parseAction(rp)>
			<cfset rp.vType = parseVType(rp)>

			<cfset $.rc = structNew()>
			<cfset $.rp = rp>
			<cfset $.rc.pluginConfig = variables.pluginConfig>
			<cfset structAppend($.rc, variables.beans)>

			<cfif structKeyExists(rp.controller, rp.action)>
				<cfinvoke component="#rp.controller#" method="#rp.action#">
					<cfinvokeargument name="$" value="#$#">
				</cfinvoke>
			</cfif>

			<cfif not listFindNoCase("none,layout", rp.vType)>
				<cfif fileExists('#expandPath("/#arguments._basePath#")#/#rp.section#/views/#rp.action#.cfm')>
					<cfsavecontent variable="$.rc.bodyContent"><cfinclude template="/#arguments._basePath#/#rp.section#/views/#rp.action#.cfm"></cfsavecontent>
				<cfelse>
					<cfthrow type="Action Error" message="The Action does not exist.">
				</cfif>
			</cfif>
			<cfif not listFindNoCase("none", rp.vType)>
				<cfif fileExists('#expandPath("/#arguments._basePath#")#/#rp.section#/layouts/#rp.layout#.cfm')>
					<cfinclude template="/#arguments._basePath#/#rp.section#/layouts/#rp.layout#.cfm">
				<cfelseif fileExists('#expandPath("/#variables.pluginConfig.getPackage()#")#/pl1/layouts/#rp.layout#.cfm')>
					<cfinclude template="/#variables.pluginConfig.getPackage()#/pl1/layouts/#rp.layout#.cfm">
				<cfelse>
					<cfthrow type="Layout Error" message="The Layout does not exist.">
				</cfif>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getAction" access="private">
		<cfargument name="$">
		<cfargument name="_action">
		<cfset var returnVar = "">

		<cfif len(arguments._action)>
			<cfset returnVar = arguments._action>
		<cfelseif len(arguments.$.event('action'))>
			<cfset returnVar = arguments.$.event('action')>
		<cfelse>
			<cfset returnVar = "default">
		</cfif>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="getLayout" access="private">
		<cfargument name="$">
		<cfargument name="_layout">
		<cfset var returnVar = "">

		<cfif len(arguments._layout)>
			<cfset returnVar = arguments._layout>
		<cfelseif len(arguments.$.event('layout'))>
			<cfset returnVar = arguments.$.event('layout')>
		<cfelse>
			<cfset returnVar = "default">
		</cfif>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="getViewType" access="private">
		<cfargument name="$">
		<cfargument name="_vType">
		<cfset var returnVar = "">

		<cfif len(arguments._vType)>
			<cfset returnVar = arguments._vType>
		<cfelseif len(arguments.$.event('vType'))>
			<cfset returnVar = arguments.$.event('vType')>
		<cfelse>
			<cfset returnVar = "default">
		</cfif>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="getController" access="private">
		<cfargument name="$">
		<cfargument name="_section">
		<cfargument name="_controller">
		<cfargument name="_package" required="true" default="#variables.pluginConfig.getPackage()#">
		<cfset var section = getSection(argumentCollection = arguments)>
		<cfset var controller = getControllerName(argumentCollection = arguments)>
		<cfset var returnVar = "">
		<cfset var controllerPath = "">

		<cfif variables.pluginConfig.getSetting('plMode') eq "development">
			<cfset variables.controllers = structNew()>
		</cfif>

		<cfif not structKeyExists(variables.controllers, section)>
			<cfset controllerPath = "#arguments._package#.#section#.controller.#controller#">
			<cfset variables.controllers[section] = createObject('component', controllerPath).init(variables.pluginConfig)>
		</cfif>

		<cfset returnVar = variables.controllers[section]>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="getControllerName" access="private">
		<cfargument name="$">
		<cfargument name="_controller">
		<cfset var returnVar = "">

		<cfif len(arguments._controller)>
			<cfset returnVar = arguments._controller>
		<cfelseif len(arguments.$.event('controller'))>
			<cfset returnVar = arguments.$.event('controller')>
		<cfelse>
			<cfset returnVar = "main">
		</cfif>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="getSection" access="private">
		<cfargument name="$">
		<cfargument name="_section">
		<cfset var returnVar = "">

		<cfif len(arguments._section)>
			<cfset returnVar = arguments._section>
		<cfelse>
			<cfset returnVar = arguments.$.event('section')>
		</cfif>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="isValidAction" access="private">
		<cfargument name="rp">
		<cfset var returnVar = true>

		<cfif find(".", arguments.rp.action) and not (listFirst(arguments.rp.action, ".") eq arguments.rp.section)>
			<cfset returnVar = false>
		</cfif>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="parseAction" access="private">
		<cfargument name="rp">
		<cfset var returnVar = "">

		<cfif find(".", arguments.rp.action)>
			<cfset returnVar = listLast(arguments.rp.action, ".")>
		<cfelse>
			<cfset returnVar = arguments.rp.action>
		</cfif>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="parseVType" access="private">
		<cfargument name="rp">
		<cfset var returnVar = "">

		<cfif left(arguments.rp.action, 3) eq "act">
			<cfset returnVar = "none">
		<cfelseif right(arguments.rp.action, 4) eq "JSON">
			<cfset returnVar = "layout">
		<cfelse>
			<cfset returnVar = arguments.rp.vType>
		</cfif>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="getStackTrace">
		<cfset var i = "">
		<cfset var stackTrace = ArrayNew(1)>
		<cfset var j = CreateObject("java","java.lang.Thread").currentThread().getStackTrace()>

		<cfloop array="#j#" item="i">
			<cfif REFindNoCase("\.cf[cm]$", i.getFileName())>
				<cfset ArrayAppend(StackTrace, i.getFileName())>
			</cfif>
		</cfloop>

		<cfreturn stackTrace>
	</cffunction>

	<cffunction name="getCallingParams">
		<cfset var stackTrace = getStackTrace()>
		<cfset var fd = application.configBean.getFileDelim()>
		<cfset var callingFilePath = stackTrace[arrayLen(stackTrace)]>
		<cfset callingFilePath = replace(callingFilePath, expandPath(fd), "")>
		<cfset var arrPaths = listToArray(callingFilePath, fd)>
		<cfset arrayDeleteAt(arrPaths, arrayLen(arrPaths))>
		<cfset var section = arrPaths[arrayLen(arrPaths)]>

		<cfset arrayDeleteAt(arrPaths, arrayLen(arrPaths))>
		<cfset var baseFilePath = arrayToList(arrPaths, fd)>
		<cfset var package = arrayToList(arrPaths, ".")>

		<cfset returnVar = {
			"basePath": baseFilePath,
			"section": section,
			"package": package
		}>

		<cfreturn returnVar>
	</cffunction>

	<cffunction name="autoWire">
		<cfargument name="folder" default="model" required="true">
		<cfset var rs = "">

		<cfdirectory directory="#expandPath("/#variables.pluginConfig.getPackage()#/#arguments.folder#")#" action="list" name="rs" filter="*.cfc">
		<cfloop query="rs">
			<cfset variables.beans[listFirst(rs.name, '.')] = createObject("component", "#variables.pluginConfig.getPackage()#.#arguments.folder#.#listFirst(rs.name, '.')#").init(variables.pluginConfig)>
		</cfloop>

	</cffunction>

	<cffunction name="getBean">
		<cfargument name="beanName" required="true">

		<cfif structKeyExists(variables.beans, arguments.beanName)>
			<cfreturn variables.beans[arguments.beanName]>
		<cfelse>
			<cfreturn super.getBean(arguments.beanName)>
		</cfif>

	</cffunction>
</cfcomponent>
