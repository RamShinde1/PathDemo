({
    getinitialData: function(component, event, helper) {
        let getData = component.get('c.getAssessment');
        getData.setParams({ recordId: component.get('v.recordId') });
        getData.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let payload = response.getReturnValue();
                component.set('v.assessmentWrapper', payload);
                component.set('v.assessmentRecord', payload.assessment);
            }
        });
        $A.enqueueAction(getData);
    },

    getAssessmentLineItems: function(component, event, helper) {
        let getData = component.get('c.getAssessmentLineItems');
        let assessment = component.get('v.assessmentRecord')
        getData.setParams({ 
            contactId : assessment.Associate__c,
            templateId : assessment.Template__c,
            assessmentId : assessment.Id,
            panelRound : assessment.PanelRound__c
        });
        getData.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let assessmentLineItems = response.getReturnValue();
                let totalMaxScore = 0;
                for (let lineItem of assessmentLineItems) {
                    totalMaxScore += lineItem.MaxScore__c;
                }
                component.set('v.totalMaxScore', totalMaxScore);
                component.set('v.assessmentLineItems', assessmentLineItems);
                component.set('v.ScreenNumber', 2);
            }
        });
        $A.enqueueAction(getData);
    },
    showErrorToast: function(component, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: 'Error Message',
            message: message,
            duration: ' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showSuccessToast: function(component, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: 'Success Message',
            message: message,
            duration: ' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    }
});