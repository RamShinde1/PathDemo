({
    doInit: function(component, event, helper) {
        helper.getinitialData(component, event, helper);
    },
    handleNextClick: function(component, event, helper) {
        const allRequiredFields = component.find('RequiredFieldVal');
        var isValid = true;

        for (var allRequiredField of allRequiredFields) {
            if (allRequiredField.get('v.value') == '' || allRequiredField.get('v.value') == null) {
                helper.showErrorToast(component, 'Please complete all required fields ' + allRequiredField.get('v.label'));
                isValid = false;
                break;
            } else if (component.find('DurationVal').get('v.value') < 10) {
                helper.showErrorToast(component, 'Please enter duration in minutes');
                isValid = false;
            }
        }
        if (isValid) {
            helper.getAssessmentLineItems(component, event, helper);
        }
    },
    handlePreviousClick: function(component, event, helper) {
        component.set('v.ScreenNumber', 1);
    }
});