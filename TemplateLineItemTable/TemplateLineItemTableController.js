({
    doInit:function(component, event, helper) {
        component.set('v.assessment.OverallFeedback__c', 'Pass');
        component.set('v.assessment.ClientInterviewReady__c', true);
        helper.calculateTotalActualScore(component, event, helper);
    },
    callAction:function(component, event, helper) {
        let selectedId=event.getParam("changedInput");
        
        if(selectedId == 'NumericScore'){
            helper.calculateTotalActualScore(component);
        }
        else if(selectedId == 'Repanel'){
            let assessment = component.get('v.assessment');
            let assessmentLineItems = component.get('v.assessmentLineItems');
            let isClientReady = true;
            for(let lineItem of assessmentLineItems){
                if(lineItem.Repanel__c == true){
                    isClientReady = false;
                }
            }
            if(isClientReady){
                assessment.ClientInterviewReady__c = true;
                assessment.OverallFeedback__c = 'Pass';
            }else{
                assessment.ClientInterviewReady__c = false;
                assessment.OverallFeedback__c = 'Repanel';
            }
            component.set('v.assessment',assessment);
        }
    },
    handleFinalClick:function(component, event, helper) {
        const assessment = component.get('v.assessment');
        const assessmentLineItems = component.get('v.assessmentLineItems');
        let isValid=true;
        
        for(let assessmentLineItem of assessmentLineItems){
            if(assessmentLineItem.NumericScore__c == null){
                helper.showErrorToast(component,"Please complete all required fields");
                isValid=false;
                break;
            }
            if(assessmentLineItem.NumericScore__c > assessmentLineItem.MaxScore__c){
                helper.showErrorToast(component,"Actual Score cannot be greater than Max Score");
                isValid=false;
                break;
            }
        }
            
        if(isValid){
            helper.updateAssessment(component, helper, assessment, assessmentLineItems);
        }
    }
    
})