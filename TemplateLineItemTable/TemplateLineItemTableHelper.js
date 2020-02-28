({
    updateAssessment:function(component, helper, assessment, assessmentLineItems) {
        
        let getData = component.get("c.updateAssessment");
        getData.setParams({
            "assessment":component.get('v.assessment'),
            "assessmentLineItems":component.get('v.assessmentLineItems')
        });
        getData.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.getEvent('finish').fire();
                helper.showSuccessToast(component,'Record created successfully')
            }else{
                helper.showErrorToast(component,'Error')
            } 
        });
        $A.enqueueAction(getData);
    },

    calculateTotalActualScore: function(component, event, helper) {
        const assessmentLineItems = component.get('v.assessmentLineItems');
        var totalActualScore=0;
        if(Array.isArray(assessmentLineItems)){
            for(let row of assessmentLineItems){
                if(row.NumericScore__c){
                    totalActualScore+=row.NumericScore__c;
                }
            }
        }
        else{
            totalActualScore+=assessmentLineItems.NumericScore__c;
        }
        component.set('v.totalActualScore',totalActualScore);
    },
    
    showSuccessToast : function(component,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message:message,
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },

    showErrorToast : function(component,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
})