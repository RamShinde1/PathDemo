({
    doInit : function(component, event, helper) {
        helper.initializeCalendar(component);
    },
    handleCancel : function(component, event, helper) {
        helper.closeScreeningModal(component);
    },
    handleSchedule : function(component, event, helper) {
        helper.createScheduleDetail(component);
        helper.closeScreeningModal(component);
    },
    handleFinish : function(component, event, helper) {
        helper.finishProcess(component);
    }
})