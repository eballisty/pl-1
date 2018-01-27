component extends="mura.plugin.pluginGenericEventHandler" accessors=true output=false {
	public void function onApplicationLoad(required struct $) output=false {
		variables.pluginConfig.addEventHandler(this);
		variables.package = variables.pluginConfig.getPackage();

		loadFramework($);
	}

	private void function loadFramework(required struct $) output=false {
		lock name="frameworkInitBlock-#variables.package#" type="exclusive" timeout="200" {
			application[variables.package] = structNew();
			application[variables.package].framework = createObject("component", "#variables.package#.pl1.lib.framework").init(variables.pluginConfig);
			application[variables.package].framework.autoWire();
		}
	}

	public any function onGlobalRequestStart(required struct $) {
		if (variables.pluginConfig.getSetting('plMode') == "Development") {
			loadFramework($);
		}
	}
}
