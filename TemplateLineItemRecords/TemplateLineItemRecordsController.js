({
    handleChange: function(component, event, helper) {
        const maxScoreValue = component.get('v.lineItem.MaxScore__c ');
        const actualScoreValue = component.get('v.lineItem.NumericScore__c');
        let selectedId = event.getSource().getLocalId();

        if (actualScoreValue > maxScoreValue) {
            helper.showErrorToast(component, 'Actual score should be less than the Max score');
        } else {
            let cmpEvent = component.getEvent('cmpAccEvent');
            cmpEvent.setParams({
                changedInput: selectedId
            });
            cmpEvent.fire();
        }
    }
});