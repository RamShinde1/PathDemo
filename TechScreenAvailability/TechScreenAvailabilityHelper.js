({
    getPicklistValues: function(component) {
        const actn = component.get('c.getRoleId');
        var userrole;
        actn.setCallback(this, response => {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                userrole = response.getReturnValue();
                component.set('v.UserRoleName', userrole);
            }
        });

        {
            const action = component.get('c.getSlotPicklistValues');
            action.setCallback(this, response => {
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    const payload = response.getReturnValue();
                    component.set('v.programTypeOptions', payload.programTypeOptions);  
                }
            });
            $A.enqueueAction(action);
            $A.enqueueAction(actn);
        }
    },
    openAvailabilityModal: function(component) {
        let modal = component.find('availability-modal');
        let backdrop = component.find('availability-modal-backdrop');

        $A.util.removeClass(modal, 'slds-fade-in-hide');
        $A.util.addClass(modal, 'slds-fade-in-open');

        $A.util.addClass(backdrop, 'slds-backdrop_open');

        component.set('v.cssStyle', '.forceStyle .viewport .oneHeader {z-index:0!important} .forceStyle .viewport{overflow:hidden!important}');
    },
    toggleRepeatOptionsMenu: function(component) {},
    toggleUpdateAllInSeriesMenu: function(component) {
        let options = component.find('series-options');
        let mode = component.get('v.mode');

        if (mode === 'Edit') {
            $A.util.removeClass(options, 'slds-hide');
        } else {
            $A.util.addClass(options, 'slds-hide');
        }
    },
    saveAvailability: function(component) {
        let availability = {};
        let mode = component.get('v.mode');
        let isRepeating = component.find('repeat-checkbox').get('v.checked');
        availability['programType'] = component.get('v.programType');
        availability['startTime'] = component.get('v.startDateTime');
        availability['previousStartTime'] = component.get('v.previousStart');
        availability['isSeries'] = isRepeating;
        availability['id'] = component.get('v.selectedId');
        availability['repeatDays'] = component.get('v.repeatDaysSelected');
        availability['endDate'] = component.get('v.endDate');

        const isValid = this.validate(component, availability);

        if (isValid) {
            let option = component.get('v.selectedRadioOption');
            if (Array.isArray(option)) {
                option = option[0];
            }
            console.log(option);
            if (isRepeating) {
                if (mode === 'Edit') {
                    if (option === 'updateThis') {
                        this.update(component, availability);
                    } else if (option === 'updateFuture') {
                        this.updateFuture(component, availability);
                    } else if (option === 'updateSeries') {
                        this.updateSeries(component, availability);
                    } else if (option === 'deleteThis') {
                        this.delete(component, availability);
                    } else if (option === 'deleteFuture') {
                        this.deleteFuture(component, availability);
                    } else {
                        this.deleteSeries(component, availability);
                    }
                } else {
                    this.createSeries(component, availability);
                }
            } else {
                if (mode === 'Edit') {
                    if (option === 'updateThis') {
                        this.update(component, availability);
                    } else if (option === 'deleteThis') {
                        this.delete(component, availability);
                    }
                } else {
                    this.create(component, availability);
                }
            }
        }
    },
    closeAvailabilityModal: function(component) {
        let modal = component.find('availability-modal');
        let backdrop = component.find('availability-modal-backdrop');

        $A.util.removeClass(modal, 'slds-fade-in-open');
        $A.util.addClass(modal, 'slds-fade-in-hide');

        $A.util.removeClass(backdrop, 'slds-backdrop_open');

        component.set('v.cssStyle', '');
    },
    clearAvailabilityValues: function(component) {
        component.set('v.availabilityData', { isScheduled: false, isOwner: true });
        component.set('v.mode', 'Add');
        component.set('v.selectedId', null);
        component.set('v.startDateTime', null);
        component.set('v.previousStart', null);
        component.set('v.isRepeating', false);
        component.set('v.programType', 'Regular');
        component.set('v.repeatDaysSelected', []);
        component.set('v.endDate', null);
        const repeatCmp = component.find('repeat-checkbox');
        if (repeatCmp) {
            repeatCmp.set('v.checked', false);
        }
        const endDateCmp = component.find('end-date');
        if (endDateCmp) {
            endDateCmp.set('v.errors', []);
        }
        const startDateTimeCmp = component.find('start-date-time');
        if (startDateTimeCmp) {
            startDateTimeCmp.set('v.errors', []);
        }
    },
    populateAvailabilityValues: function(component, availabilityData) {
        component.set('v.mode', 'Edit');
        component.set('v.selectedRadioOption', 'updateThis');
        console.log(availabilityData);
        component.set('v.selectedId', availabilityData.id);
        component.set('v.startDateTime', availabilityData.start.toISOString());
        component.set('v.previousStart', availabilityData.start.toISOString());
        component.set('v.programType', availabilityData.programType);
        const repeatCmp = component.find('repeat-checkbox');
        if (repeatCmp) {
            repeatCmp.set('v.checked', availabilityData.isSeries);
        }
        component.set('v.isRepeating', availabilityData.isSeries);
        component.set('v.repeatDaysSelected', availabilityData.repeatDays);
        component.set('v.endDate', availabilityData.endDate);
    },
    create: function(component, screenDetail) {
        let action = component.get('c.createSlot');
        action.setParams({
            screenDetailString: JSON.stringify(screenDetail)
        });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                this.closeAvailabilityModal(component);
                component.find('calendarComponent').refetch();
                if (component.get('v.UserRoleName') == 'Screener') {
                    this.toastSuccess(component, 'Screening availability created successfully!');
                } else {
                    this.toastSuccess(component, 'Panel availability created successfully!');
                }
            } else {
                console.log('ERROR: TechscreenAvailabilityHelper createSlot');
                let errors = response.getError();
                if (errors && errors[0].message == 'DuplicateException') {
                    this.toastWarning(component, 'Block already scheduled for selected date and time');
                } else {
                    if (component.get('v.UserRoleName') == 'Screener') {
                        this.toastError(component, 'ERROR: Screening availability not created!');
                    } else {
                        this.toastError(component, 'ERROR: Panel availability not created!');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    createSeries: function(component, screenDetail) {
        let action = component.get('c.createSlotSeries');
        action.setParams({ screenDetailString: JSON.stringify(screenDetail) });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                this.closeAvailabilityModal(component);
                component.find('calendarComponent').refetch();
                if (component.get('v.UserRoleName') == 'Screener') {
                    this.toastSuccess(component, 'Screening availability created successfully!');
                } else {
                    this.toastSuccess(component, 'Panel availability created successfully!');
                }
            } else {
                console.log('ERROR: TechscreenAvailabilityHelper createSeries');
                console.log('ERROR: TechscreenAvailabilityHelper createSlot');
                let errors = response.getError();
                if (errors && errors[0].message == 'DuplicateException') {
                    this.toastWarning(component, 'Block already scheduled for selected dates and times');
                } else {
                    if (component.get('v.UserRoleName') == 'Screener') {
                        this.toastError(component, 'ERROR: Screening availability not created!');
                    } else {
                        this.toastError(component, 'ERROR: Panel availability not created!');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    update: function(component, screenDetail) {
        let action = component.get('c.updateSlot');
        action.setParams({ screenDetailString: JSON.stringify(screenDetail) });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                this.closeAvailabilityModal(component);
                component.find('calendarComponent').refetch();
                if (component.get('v.UserRoleName') == 'Screener') {
                    this.toastSuccess(component, 'Screening availability updated successfully!');
                } else {
                    this.toastSuccess(component, 'Panel availability updated successfully!');
                }
            } else {
                console.log('ERROR: TechscreenAvailabilityHelper update');
                let errors = response.getError();
                if (errors && errors[0].message == 'ScreenScheduledException') {
                    this.toastWarning(component, 'Screening scheduled for block');
                } else if (errors && errors[0].message == 'DuplicateException') {
                    this.toastWarning(component, 'Block already scheduled for selected dates and times');
                } else {
                    if (component.get('v.UserRoleName') == 'Screener') {
                        this.toastError(component, 'ERROR: Screening availability not updated!');
                    } else {
                        this.toastError(component, 'ERROR: Panel availability not updated!');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateFuture: function(component, screenDetail) {
        let action = component.get('c.updateFutureSeries');
        action.setParams({ screenDetailString: JSON.stringify(screenDetail) });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                this.closeAvailabilityModal(component);
                component.find('calendarComponent').refetch();
                if (component.get('v.UserRoleName') == 'Screener') {
                    this.toastSuccess(component, 'Screening availability updated successfully!');
                } else {
                    this.toastSuccess(component, 'Panel availability updated successfully!');
                }
            } else {
                console.log('ERROR: TechscreenAvailabilityHelper updateFuture');
                let errors = response.getError();
                if (errors && errors[0].message == 'ScreenScheduledException') {
                    this.toastWarning(component, 'Screening scheduled for future block');
                } else if (errors && errors[0].message == 'DuplicateException') {
                    this.toastWarning(component, 'Block already scheduled for selected dates and times');
                } else {
                    if (component.get('v.UserRoleName') == 'Screener') {
                        this.toastError(component, 'ERROR: Screening availability not updated!');
                    } else {
                        this.toastError(component, 'ERROR: Panel availability not updated!');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateSeries: function(component, screenDetail) {
        let action = component.get('c.updateSlotSeries');
        action.setParams({ screenDetailString: JSON.stringify(screenDetail) });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                this.closeAvailabilityModal(component);
                component.find('calendarComponent').refetch();
                if (component.get('v.UserRoleName') == 'Screener') {
                    this.toastSuccess(component, 'Screening availability updated successfully!');
                } else {
                    this.toastSuccess(component, 'Panel availability updated successfully!');
                }
            } else {
                console.log('ERROR: TechscreenAvailabilityHelper createSlot');
                let errors = response.getError();
                if (errors && errors[0].message == 'ScreenScheduledException') {
                    this.toastWarning(component, 'Screening scheduled for block in series');
                } else if (errors && errors[0].message == 'DuplicateException') {
                    this.toastWarning(component, 'Block already scheduled for selected dates and times');
                } else {
                    if (component.get('v.UserRoleName') == 'Screener') {
                        this.toastError(component, 'ERROR: Screening availability not updated!');
                    } else {
                        this.toastError(component, 'ERROR: Panel availability not updated!');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    delete: function(component, screenDetail) {
        let action = component.get('c.deleteSlot');
        action.setParams({ screenDetailString: JSON.stringify(screenDetail) });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                this.closeAvailabilityModal(component);
                component.find('calendarComponent').refetch();
                if (component.get('v.UserRoleName') == 'Screener') {
                    this.toastSuccess(component, 'Screening availability deleted successfully!');
                } else {
                    this.toastSuccess(component, 'Panel availability deleted successfully!');
                }
            } else {
                console.log('ERROR: TechscreenAvailabilityHelper createSlot');
                let errors = response.getError();
                if (errors && errors[0].message == 'ScreenScheduledException') {
                    this.toastWarning(component, 'Screening scheduled for block');
                } else {
                    if (component.get('v.UserRoleName') == 'Screener') {
                        this.toastError(component, 'ERROR: Screening availability not deleted!');
                    } else {
                        this.toastError(component, 'ERROR: Panel availability not deleted!');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    deleteFuture: function(component, screenDetail) {
        let action = component.get('c.deleteFutureSeries');
        action.setParams({ screenDetailString: JSON.stringify(screenDetail) });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                this.closeAvailabilityModal(component);
                component.find('calendarComponent').refetch();
                this.toastSuccess(component, 'Screening availability deleted successfully!');
            } else {
                console.log('ERROR: TechscreenAvailabilityHelper createSlot');
                let errors = response.getError();
                if (errors && errors[0].message == 'ScreenScheduledException') {
                    this.toastWarning(component, 'Screening scheduled for future block');
                } else {
                    this.toastError(component, 'ERROR: Screening availability not deleted!');
                }
            }
        });
        $A.enqueueAction(action);
    },
    deleteSeries: function(component, screenDetail) {
        let action = component.get('c.deleteSlotSeries');
        action.setParams({ screenDetailString: JSON.stringify(screenDetail) });
        action.setCallback(this, function(response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                this.closeAvailabilityModal(component);
                component.find('calendarComponent').refetch();
                this.toastSuccess(component, 'Screening availability deleted successfully!');
            } else {
                console.log('ERROR: TechscreenAvailabilityHelper createSlot');
                let errors = response.getError();
                if (errors && errors[0].message == 'ScreenScheduledException') {
                    this.toastWarning(component, 'Screening scheduled for block in series');
                } else {
                    this.toastError(component, 'ERROR: Screening availability not deleted!');
                }
            }
        });
        $A.enqueueAction(action);
    },
    validate: function(component, availability) {
        console.log(availability);
        let isValid = true;

        if (availability.startTime) {
            component.find('start-date-time').set('v.errors', []);
        } else {
            isValid = false;
            component.find('start-date-time').set('v.errors', [{ message: 'Start Date and Time is required' }]);
        }

        if (availability.isSeries) {
            if (!component.find('repeat-days').checkValidity()) {
                isValid = false;
            }
            if (availability.endDate) {
                if (availability.startTime && new Date(availability.startTime).getTime() > new Date(availability.endDate).getTime()) {
                    component.find('end-date').set('v.errors', [{ message: 'End Date cannot be less than Start Date' }]);
                    isValid = false;
                } else {
                    component.find('end-date').set('v.errors', []);
                }
            } else {
                component.find('end-date').set('v.errors', [{ message: 'Repeat Through Date is required' }]);
                isValid = false;
            }
        }
        console.log(isValid);
        return isValid;
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
    toastWarning: function(component, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: 'warning',
            message: message
        });
        toastEvent.fire();
    }
});