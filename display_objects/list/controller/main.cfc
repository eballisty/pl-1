component extends="mura.cfobject" output=false {
	// default view - ?action=default (maps to admin/views/default.cfm)
	public void function default(required struct $) {
		// example
		$.rc.resultVariable = $.getBean('starter').default($);
	}

	// list view - ?action=detail (maps to views/detail.cfm)
	public void function detail(required struct $) {
		// example
		$.rc.resultDetail = $.getBean('starter').getDetail($);
	}

	// action (controller and model only)
	public void function actDoAnAction(required struct $) {
		$.getBean('starter').action($, now());

		// redirect as "actions" have no views
		location(url='?action=default', addtoken='false');
	}
}
