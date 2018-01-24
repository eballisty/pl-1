component extends="mura.cfobject" output=false {
	// default view - ?action=default (maps to admin/views/default.cfm)
	public void function default(required struct $) {
		// example
		$.rc.resultVariable = $.rc.starter.default($);
	}
}
