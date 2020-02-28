({
    getScreening: function(component) {
        let action;
        let actionpanel;
        if (component.get('v.componentName') == 'AssignReplacementScreener') {
            action = component.get('c.getLastScreening');
            action.setParams({
                contactId: component.get('v.recordId')
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    let screening = response.getReturnValue();
                    component.set('v.screening', screening);
                    this.initializeFilter(component, screening.Screener__c);
                } else {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('Error message: ' + errors[0].message);
                        } else {
                            console.log('Error in calling ScreeningController getLastScreening');
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        } else if (component.get('v.componentName') == 'AssignReplacementPanel') {
            actionpanel = component.get('c.getLastPanelist');
            actionpanel.setParams({
                contactId: component.get('v.recordId')
            });
            actionpanel.setCallback(this, function(response) {
                let state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                  
                    let panel = response.getReturnValue();
                     component.set('v.panel', panel);
                    this.initializeFilter(component, panel.AssignedTo__c);
                } else {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('Error message: ' + errors[0].message);
                        } else {
                            console.log('Error in calling ScreeningController getLastScreening');
                        }
                    }
                }
            });
            $A.enqueueAction(actionpanel);
        }
    },
    initializeFilter: function(component, currentScreenerId) {
        let action = component.get('c.getScreenerFilter');
        action.setParams({
            screenerId: currentScreenerId
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                let whereClause = response.getReturnValue();
                component.set('v.replacementScreenerFilter', whereClause);
            } else {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                    } else {
                        console.log('Error in calling ScreeningController getScreener');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    validateInputs: function(component) {
        let screenerId = component.get('v.replacementScreener');
        return screenerId != null;
    },
    replaceScreener: function(component) {
        if (this.validateInputs(component)) {
            component.set('v.replacementScreenerIsError', false);
			let action = component.get('c.assignScreener');
            if (component.get('v.componentName') == 'AssignReplacementScreener') {
                action.setParams({
                    screeningId: component.get('v.screening.Id'),
                    screenerId: component.get('v.replacementScreener'),
                    componentName: component.get('v.componentName')
                });
            } else if (component.get('v.componentName') == 'AssignReplacementPanel') {
               action.setParams({
                    screeningId: component.get('v.panel.Id'),
                    screenerId: component.get('v.replacementScreener'),
                    componentName: component.get('v.componentName')
                });
            }

            action.setCallback(this, function(response) {
                let state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                    console.log('replaced screener');
                    if (component.get('v.componentName') == 'AssignReplacementScreener') {
                        this.toastSuccess(component, 'Screener replaced successfully!');
                    } else if (component.get('v.componentName') == 'AssignReplacementPanel') {
                        this.toastSuccess(component, 'Panel replaced successfully!');
                    }

                    this.finishProcess(component);
                } else {
                    if (component.get('v.componentName') == 'AssignReplacementScreener') {
                        this.toastError(component, 'ERROR: Screener not replaced!');
                    } else if (component.get('v.componentName') == 'AssignReplacementPanel') {
                        this.toastError(component, 'ERROR: Panel not replaced!');
                    }

                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('Error message: ' + errors[0].message);
                        } else {
                            console.log('Error in calling ScreeningController assignScreener');
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set('v.replacementScreenerIsError', true);
        }
    },
    toastSuccess: function(component, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: 'success',
            message: message
        });
        toastEvent.fire();
    },
    toastError: function(component, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: 'error',
            message: message
        });
        toastEvent.fire();
    },
    finishProcess: function(component) {
        component.getEvent('finish').fire();
    }
});