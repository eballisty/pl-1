<plugin>
	<name>Starter Plugin</name>
	<package>starter</package>
	<directoryFormat>packageOnly</directoryFormat>
	<version>1.18.1.11</version>
	<provider>Blue River</provider>
	<providerURL>http://www.blueriver.com</providerURL>
	<category>Application</category>
	<settings>
		<setting>
			<name>plMode</name>
			<label>Plugin Mode</label>
			<type>Select</type>
			<defaultvalue>Development</defaultvalue>
			<optionlist>Development^Production</optionlist>
		</setting>
	</settings>
	<eventHandlers>
		<eventHandler event="onApplicationLoad" component="plugin.handler" persist="true" />
	</eventHandlers>
</plugin>
