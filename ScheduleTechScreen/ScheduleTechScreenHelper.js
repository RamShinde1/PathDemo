({
    initializeCalendar : function(component) {
        let thisContext = this;
       
        // Calendar options and callbacks
        $('#calendar').fullCalendar({
            height : $(window).height(),
            timezone: 'local',
            timeFormat: 'h(:mm)a',
            customButtons: {
                toggleAllSlots: {
                    text: 'Show All Slots',
                    click: $A.getCallback(function() {
                        thisContext.toggleAllSlots(component);
                    })
                }
            },
            header : {left:'',center:'title', right:'toggleAllSlots month,agendaWeek,agendaDay prev,next'},
            // Initial event fetching
            events : $A.getCallback(function(start, end, timezone, callback) {
                console.log('fetching events...');
                let action = component.get('c.getAllScreenings');
                console.log(start.toISOString());
                console.log(end.toISOString());
                
                action.setParams({
                    startDateString: start.toISOString(),
                    endDateString: end.toISOString(),
                    componentName:component.get('v.componentName')
                });
                action.setCallback(this, function(response) {
                    let state = response.getState();
                    console.log(state);
                    if (component.isValid() && state === 'SUCCESS') {
                        let events = response.getReturnValue();
                        events.forEach(function(element){
                            element['start'] = element.startTime;
                            element['end'] = element.endTime;
                        });
                        console.log(events);
                        callback(events);
                    }
                    else {
                        let errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log('Error message: ' + errors[0].message);
                            }
                            else {
                                console.log('Error in calling server-side getAllSlots() from initializeCalendar()');
                            }
                        } 
                    }
                });
                $A.enqueueAction(action);
            }),
            eventClick: $A.getCallback(function(calEvent, jsEvent, view) {                
                console.log('calEvent: ');
                console.log(calEvent);

                component.set('v.selectedSlot', calEvent);

                thisContext.populateScheduleDisplayDetails(component, calEvent);
                thisContext.toggleOptionsDisplay(component);
                thisContext.openScreeningModal(component);
            }),
            eventRender: $A.getCallback(function(event, element) {
                let showAll = component.get('v.showAll');
                if (!showAll && event.isScheduled) return false;
                return true;
            })
        });
    },
    toggleAllSlots : function(component) {
        let showAll = component.get('v.showAll');
        component.set('v.showAll', !showAll);
        this.rerenderCalendarEvents(component);
        if (showAll) {
            $('.fc-toggleAllSlots-button').removeClass('fc-state-active');
        }
        else {
            $('.fc-toggleAllSlots-button').addClass('fc-state-active');
        }
    },
    rerenderCalendarEvents : function(component) {
        $('#calendar').fullCalendar('rerenderEvents');
    },
    refetchCalendarEvents : function(component) {
        $('#calendar').fullCalendar('refetchEvents');
    },
    populateScheduleDisplayDetails : function(component, selectedSlotDetails) {

        if (selectedSlotDetails.candidateName == null) {
            selectedSlotDetails.candidateName = component.get('v.currentCandidateName');
        }
        component.set('v.screenerName', selectedSlotDetails.screenerName);
        component.set('v.startDateTime', selectedSlotDetails.startTime);
        component.set('v.screenType', selectedSlotDetails.screenType);
        component.set('v.candidateName', selectedSlotDetails.candidateName);
        component.set('v.isScheduled', selectedSlotDetails.isScheduled);
    },
    toggleOptionsDisplay : function(component) {
        let isScheduled = component.get('v.isScheduled');

        if (isScheduled) {
            this.showScheduledOptions(component);
        }
        else {
            this.showUnscheduledOptions(component);
        }
    },
    showScheduledOptions : function(component) {
        console.log('current slot is scheduled');
        
        if(component.get('v.componentName') == 'ScheduleTechScreen'){
            let scheduledOptions = component.find('screening-options-scheduled');
            let unscheduledOptions = component.find('screening-options-unscheduled');
            let scheduledButtonBar = component.find('button-bar-scheduled');
            let unscheduledButtonBar = component.find('button-bar-unscheduled');
            let scheduledTitle = component.find('modal-title-scheduled');
            let unscheduledTitle = component.find('modal-title-unscheduled');
            
            $A.util.removeClass(scheduledOptions, 'slds-hide');
            $A.util.addClass(scheduledOptions, 'slds-show');
            $A.util.removeClass(unscheduledOptions, 'slds-show');
            $A.util.addClass(unscheduledOptions, 'slds-hide');
            $A.util.removeClass(scheduledButtonBar, 'slds-hide');
            $A.util.addClass(scheduledButtonBar, 'slds-show');
            $A.util.addClass(scheduledButtonBar, 'button-bar');
            $A.util.removeClass(unscheduledButtonBar, 'button-bar');
            $A.util.removeClass(unscheduledButtonBar, 'slds-show');
            $A.util.addClass(unscheduledButtonBar, 'slds-hide');
            $A.util.removeClass(scheduledTitle, 'slds-hide');
            $A.util.addClass(scheduledTitle, 'slds-show');
            $A.util.removeClass(unscheduledTitle, 'slds-show');
            $A.util.addClass(unscheduledTitle, 'slds-hide');
        }
        else if(component.get('v.componentName') == 'SchedulePanel'){
            let scheduledOptions = component.find('Panel-options-scheduled');
            let unscheduledOptions = component.find('panel-options-unscheduled');
            let scheduledButtonBar = component.find('panel-button-bar-scheduled');
            let unscheduledButtonBar = component.find('panel-button-bar-unscheduled');
            let scheduledTitle = component.find('modal-title-scheduled-Panel');
            let unscheduledTitle = component.find('modal-title-unscheduled-Panel');
            
            $A.util.removeClass(scheduledOptions, 'slds-hide');
            $A.util.addClass(scheduledOptions, 'slds-show');
            $A.util.removeClass(unscheduledOptions, 'slds-show');
            $A.util.addClass(unscheduledOptions, 'slds-hide');
            $A.util.removeClass(scheduledButtonBar, 'slds-hide');
            $A.util.addClass(scheduledButtonBar, 'slds-show');
            $A.util.addClass(scheduledButtonBar, 'button-bar');
            $A.util.removeClass(unscheduledButtonBar, 'button-bar');
            $A.util.removeClass(unscheduledButtonBar, 'slds-show');
            $A.util.addClass(unscheduledButtonBar, 'slds-hide');
            $A.util.removeClass(scheduledTitle, 'slds-hide');
            $A.util.addClass(scheduledTitle, 'slds-show');
            $A.util.removeClass(unscheduledTitle, 'slds-show');
            $A.util.addClass(unscheduledTitle, 'slds-hide');
        }
        
    },
    showUnscheduledOptions : function(component) {
        console.log('current slot is unscheduled');
		
        if(component.get('v.componentName') == 'ScheduleTechScreen'){
            let scheduledOptions = component.find('screening-options-scheduled');
            let unscheduledOptions = component.find('screening-options-unscheduled');
            let scheduledButtonBar = component.find('button-bar-scheduled');
            let unscheduledButtonBar = component.find('button-bar-unscheduled');
            let scheduledTitle = component.find('modal-title-scheduled');
            let unscheduledTitle = component.find('modal-title-unscheduled');
            
            $A.util.removeClass(scheduledOptions, 'slds-show');
            $A.util.addClass(scheduledOptions, 'slds-hide');
            $A.util.removeClass(unscheduledOptions, 'slds-hide');
            $A.util.addClass(unscheduledOptions, 'slds-show');
            $A.util.removeClass(scheduledButtonBar, 'button-bar');
            $A.util.removeClass(scheduledButtonBar, 'slds-show');
            $A.util.addClass(scheduledButtonBar, 'slds-hide');
            $A.util.removeClass(unscheduledButtonBar, 'slds-hide');
            $A.util.addClass(unscheduledButtonBar, 'slds-show');
            $A.util.addClass(unscheduledButtonBar, 'button-bar');
            $A.util.removeClass(scheduledTitle, 'slds-show');
            $A.util.addClass(scheduledTitle, 'slds-hide');
            $A.util.removeClass(unscheduledTitle, 'slds-hide');
            $A.util.addClass(unscheduledTitle, 'slds-show');
        }
        else if(component.get('v.componentName') == 'SchedulePanel'){
            let scheduledOptions = component.find('Panel-options-scheduled');
            let unscheduledOptions = component.find('panel-options-unscheduled');
            let scheduledButtonBar = component.find('panel-button-bar-scheduled');
            let unscheduledButtonBar = component.find('panel-button-bar-unscheduled');
            let scheduledTitle = component.find('modal-title-scheduled-Panel');
            let unscheduledTitle = component.find('modal-title-unscheduled-Panel');
            
            $A.util.removeClass(scheduledOptions, 'slds-show');
            $A.util.addClass(scheduledOptions, 'slds-hide');
            $A.util.removeClass(unscheduledOptions, 'slds-hide');
            $A.util.addClass(unscheduledOptions, 'slds-show');
            $A.util.removeClass(scheduledButtonBar, 'button-bar');
            $A.util.removeClass(scheduledButtonBar, 'slds-show');
            $A.util.addClass(scheduledButtonBar, 'slds-hide');
            $A.util.removeClass(unscheduledButtonBar, 'slds-hide');
            $A.util.addClass(unscheduledButtonBar, 'slds-show');
            $A.util.addClass(unscheduledButtonBar, 'button-bar');
            $A.util.removeClass(scheduledTitle, 'slds-show');
            $A.util.addClass(scheduledTitle, 'slds-hide');
            $A.util.removeClass(unscheduledTitle, 'slds-hide');
            $A.util.addClass(unscheduledTitle, 'slds-show');
        }
        
    },
    openScreeningModal : function(component) {
        if(component.get('v.componentName') == 'ScheduleTechScreen'){
            let modal = component.find('screening-modal');
            
            $A.util.removeClass(modal, 'slds-fade-in-hide');
            $A.util.addClass(modal, 'slds-fade-in-open');
        }
        else if(component.get('v.componentName') == 'SchedulePanel'){
            let modal = component.find('Panel-modal');
            
            $A.util.removeClass(modal, 'slds-fade-in-hide');
            $A.util.addClass(modal, 'slds-fade-in-open');
        }
    },
    closeScreeningModal : function(component) {
        if(component.get('v.componentName') == 'ScheduleTechScreen'){
            let modal = component.find('screening-modal');
            
            $A.util.removeClass(modal, 'slds-fade-in-open');
            $A.util.addClass(modal, 'slds-fade-in-hide');    
        }
        else if(component.get('v.componentName') == 'SchedulePanel'){
            let modalPanel = component.find('Panel-modal');
            
            $A.util.removeClass(modalPanel, 'slds-fade-in-open');
            $A.util.addClass(modalPanel, 'slds-fade-in-hide');
        }
       
    },
    createScheduleDetail : function(component) {
        if(component.get('v.componentName') == 'ScheduleTechScreen'){
            let selectedSlot = component.get('v.selectedSlot');

        let scheduleDetail = {};
        
        scheduleDetail['id'] = selectedSlot.id;
        scheduleDetail['startTime'] = component.get('v.startDateTime');
        scheduleDetail['endTime'] = selectedSlot.endTime;
        scheduleDetail['title'] = '';
        scheduleDetail['color'] = '#b20000';
        scheduleDetail['isScheduled'] = true;
        scheduleDetail['screenerId'] = selectedSlot.screenerId;
        scheduleDetail['screenerName'] = component.get('v.screenerName');
        scheduleDetail['screenType'] = component.get('v.screenType') != null ? component.get('v.screenType') : 'Video';
        scheduleDetail['candidateName'] = component.get('v.candidateName');

        console.log('schedule detail: ');
        console.log(scheduleDetail);
        this.schedule(component, scheduleDetail);
        }
        else if(component.get('v.componentName') == 'SchedulePanel'){
            let selectedSlot = component.get('v.selectedSlot');

        let scheduleDetail = {};
        
        scheduleDetail['id'] = selectedSlot.id;
        scheduleDetail['startTime'] = component.get('v.startDateTime');
        scheduleDetail['endTime'] = selectedSlot.endTime;
        scheduleDetail['title'] = '';
        scheduleDetail['color'] = '#b20000';
        scheduleDetail['isScheduled'] = true;
        scheduleDetail['screenerId'] = selectedSlot.screenerId;
        scheduleDetail['screenerName'] = component.get('v.screenerName');
        scheduleDetail['screenType'] = component.get('v.screenType') != null ? component.get('v.screenType') : 'Video';
        scheduleDetail['candidateName'] = component.get('v.candidateName');

        console.log('schedule detail: ');
        console.log(scheduleDetail);
        this.schedule(component, scheduleDetail);
        }
        
    },
    schedule : function(component, scheduleDetail) {
        $A.util.removeClass(component.find('spinner'), 'slds-hide');
        console.log('in schedule');
        console.log('about to schedule this screening:');
        console.log(scheduleDetail);
        console.log(JSON.stringify(scheduleDetail));
        
        let action = component.get('c.scheduleScreening');
                action.setParams({
            scheduleDetailString: JSON.stringify(scheduleDetail),
            contactId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() === 'SUCCESS') {
                $A.util.addClass(component.find('spinner'), 'slds-hide');
                if(component.get('v.componentName') == 'ScheduleTechScreen'){
                    this.toastSuccess(component, 'Screening scheduled successfully!');
                }
                else if(component.get('v.componentName') == 'SchedulePanel'){
                    this.toastSuccess(component, 'Panel scheduled successfully!');
                }
                this.refetchCalendarEvents(component);
                this.finishProcess(component);
            }
            else {
                if(component.get('v.componentName') == 'ScheduleTechScreen'){
                    $A.util.addClass(component.find('spinner'), 'slds-hide');
                    console.log('Error in ScheduleTechScreenHelper schedule');
                    const error = response.getError();
                    if (error && error[0].message.includes('Work Authorization')) {
                        this.toastError(component, 'Please confirm that the candidate does not require sponsorship before scheduling a tech screen.');
                    }
                    else if(error && error[0].message.includes('AlreadyScheduledException')){
                        this.toastError(component, 'Tech Screen already schduled for selected slot. Please refresh the calendar.');
                    }
                        else {
                            this.toastError(component, 'ERROR: Screening not scheduled!');
                        }
                }
                else if(component.get('v.componentName') == 'SchedulePanel'){
                    $A.util.addClass(component.find('spinner'), 'slds-hide');
                    console.log('Error in ScheduleTechScreenHelper schedule');
                    const error = response.getError();
                    if (error && error[0].message.includes('Work Authorization')) {
                        this.toastError(component, 'Please confirm that the candidate does not require sponsorship before scheduling a Panel.');
                    }
                    else if(error && error[0].message.includes('AlreadyScheduledException')){
                        this.toastError(component, 'Panel already schduled for selected slot. Please refresh the calendar.');
                    }
                        else {
                            this.toastError(component, 'ERROR: Panel not scheduled!');
                        }
                }
                
                
            }
        });
        $A.enqueueAction(action); 
    },
    toastSuccess : function(component, message){
    	var toastEvent = $A.get('e.force:showToast');
    	toastEvent.setParams({
    		type: 'success',
    		message: message
    	});
        toastEvent.fire();
    },
    toastError : function(component, message){
    	var toastEvent = $A.get('e.force:showToast');
    	toastEvent.setParams({
    		type: 'error',
    		message: message
    	});
    	toastEvent.fire();
	},
    finishProcess : function(component) {
        let finishEvent = component.getEvent('finish');
        let payload = {"actionTaken" : "Schedule Tech Screen"};
        finishEvent.setParams({data : payload});
        finishEvent.fire();
    }
})