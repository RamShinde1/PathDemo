({
	doInit : function(component, event, helper) {
		helper.getScreening(component);
	},
    handleFinish : function(component, event, helper) {
        helper.replaceScreener(component);
    }
})