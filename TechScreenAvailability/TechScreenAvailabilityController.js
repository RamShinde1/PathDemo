({
    doInit : function(component, event, helper){
        helper.getPicklistValues(component);
    },
    handleCreate : function(component, event, helper) {
        helper.clearAvailabilityValues(component);
        helper.toggleRepeatOptionsMenu(component);
        helper.toggleUpdateAllInSeriesMenu(component);
        helper.openAvailabilityModal(component);
    },
    handleRepeat : function(component, event, helper) {
        helper.toggleRepeatOptionsMenu(component);
    },
    handleSave : function(component, event, helper) {
        helper.saveAvailability(component);
    },
    handleClose : function(component, event, helper) {
        helper.closeAvailabilityModal(component);
        helper.clearAvailabilityValues(component);
    },
    handleSendAvailabilityDataEvent : function(component, event, helper) {
        let calEvent = event.getParam('availabilityData');
        component.set('v.availabilityData', calEvent);
        helper.populateAvailabilityValues(component, calEvent);
        helper.toggleRepeatOptionsMenu(component);
        helper.toggleUpdateAllInSeriesMenu(component);
        helper.openAvailabilityModal(component);
    },
    navigateToObject : function(component, event, helper){
        const recordId = event.currentTarget.dataset.id;
        const navEvent = $A.get('e.force:navigateToSObject');
        navEvent.setParams({
            recordId: recordId,
            isredirect: true
        });
        navEvent.fire();
    }
})