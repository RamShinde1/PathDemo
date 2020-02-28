public without sharing class ScreeningSlotService {

    private static final Integer SCREEN_DURATION = 30;

    private static List<Schema.SObjectType> SERVICE_SOBJECTS = 
        new Schema.SObjectType[] {
            ScreeningSlot__c.SObjectType,
            Screening__c.SObjectType
        };

    public static List<ScreeningController.ScheduleDetail> getAllSlots(Date startDate, Date endDate,string componentName){
        List<ScreeningController.ScheduleDetail> scheduleDetailList = new List<ScreeningController.ScheduleDetail>();
        if(componentName=='ScheduleTechScreen'){
            
            if(endDate < Date.today()){
                return scheduleDetailList;
            }
            
            Date startOrTodayDate = startDate < Date.today() ? Date.today() : startDate;
            
            List<ScreeningSlot__c> screeningSlots = new List<ScreeningSlot__c>([SELECT Id, Screener__c, Screener__r.Name, StartTime__c, ProgramType__c, 
                                                                                (SELECT Id, ScreenStatus__c, ScreenType__c, Candidate__c, Candidate__r.Name FROM Screenings__r WHERE ScreenStatus__c NOT IN ('Cancelled','Rescheduled') ORDER BY CreatedDate DESC)
                                                                                FROM ScreeningSlot__c
                                                                                WHERE DAY_ONLY(StartTime__c) >= :startOrTodayDate AND DAY_ONLY(StartTime__c) <= :endDate AND RecordType.Name='Tech Screen']);
            for(ScreeningSlot__c screeningSlot : screeningSlots){
                ScreeningController.ScheduleDetail scheduleDetail = new ScreeningController.ScheduleDetail();
                scheduleDetail.id = screeningSlot.Id;
                scheduleDetail.startTime = screeningSlot.StartTime__c;
                scheduleDetail.endTime = screeningSlot.StartTime__c.addMinutes(SCREEN_DURATION);
                scheduleDetail.title = screeningSlot.ProgramType__c == 'Regular' ? '' : screeningSlot.ProgramType__c;
                scheduleDetail.screenerId = screeningSlot.Screener__c;
                scheduleDetail.screenerName = screeningSlot.Screener__r.Name;
                scheduleDetail.recordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Tech Screen').getRecordTypeId();
                
                if (!screeningSlot.Screenings__r.isEmpty()) {
                    scheduleDetail.isScheduled = true;
                    scheduleDetail.candidateName = screeningSlot.Screenings__r[0].Candidate__r.Name;
                    scheduleDetail.screenType = screeningSlot.Screenings__r[0].ScreenType__c;
                    scheduleDetail.color = '#3e8ede';
                }
                else {
                    scheduleDetail.isScheduled = false;
                    scheduleDetail.color = '#3eba4d';
                }
                System.debug(scheduleDetail);
                scheduleDetailList.add(scheduleDetail);   
            }
        }
        else if(componentName=='SchedulePanel')
        {
            if(endDate < Date.today()){
                return scheduleDetailList;
            }
            
            Date startOrTodayDate = startDate < Date.today() ? Date.today() : startDate;
            
            List<ScreeningSlot__c> screeningSlots = new List<ScreeningSlot__c>([SELECT Id, Screener__c, Screener__r.Name, StartTime__c, ProgramType__c,
                                                                                (SELECT Id, Associate__c, Status__c, Mode__c, Associate__r.Name  FROM Assessments__r WHERE Status__c NOT IN ('Cancelled','Rescheduled') ORDER BY CreatedDate DESC)
                                                                                FROM ScreeningSlot__c
                                                                                WHERE DAY_ONLY(StartTime__c) >= :startOrTodayDate AND DAY_ONLY(StartTime__c) <= :endDate AND RecordType.Name='Panel']);
            for(ScreeningSlot__c screeningSlot : screeningSlots){
              ScreeningController.ScheduleDetail scheduleDetail = new ScreeningController.ScheduleDetail();
                scheduleDetail.id = screeningSlot.Id;
                scheduleDetail.startTime = screeningSlot.StartTime__c;
                scheduleDetail.endTime = screeningSlot.StartTime__c.addMinutes(SCREEN_DURATION);
                scheduleDetail.title = screeningSlot.ProgramType__c == 'Regular' ? '' : screeningSlot.ProgramType__c;
                scheduleDetail.screenerId = screeningSlot.Screener__c;
                scheduleDetail.screenerName = screeningSlot.Screener__r.Name;
                scheduleDetail.recordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
                
                if (!screeningSlot.Assessments__r.isEmpty()) {
                    scheduleDetail.isScheduled = true;
                    scheduleDetail.candidateName = screeningSlot.Assessments__r[0].Associate__r.Name;
                    scheduleDetail.screenType = screeningSlot.Assessments__r[0].Mode__c;
                    scheduleDetail.color = '#3e8ede';
                }
                else {
                    scheduleDetail.isScheduled = false;
                    scheduleDetail.color = '#3eba4d';
                }
                scheduleDetailList.add(scheduleDetail);   
            }
        }
        return scheduleDetailList;
    }

    public static List<ScreeningController.Detail> getSlotDetails(Id screenerId, Date startDate, Date endDate, Boolean showAll,string componentName){
        List<ScreeningController.Detail> screeningDetailList = new List<ScreeningController.Detail>();
         List<ScreeningSlot__c> screeningSlots = new List<ScreeningSlot__c>([SELECT Id, Screener__c, Screener__r.Name, StartTime__c, ProgramType__c, 
                                                                                (SELECT Id, ScreenStatus__c, ScreenType__c, Candidate__c, Candidate__r.Name FROM Screenings__r WHERE ScreenStatus__c NOT IN ('Cancelled','Rescheduled') ORDER BY CreatedDate DESC)
                                                                                FROM ScreeningSlot__c 
                                                                                WHERE DAY_ONLY(StartTime__c) >= :startDate AND DAY_ONLY(StartTime__c) <= :endDate AND Screener__c = :screenerId]);
        for(ScreeningSlot__c screeningSlot : screeningSlots){
            System.debug(screeningSlot);
            ScreeningController.Detail screenDetail = new ScreeningController.Detail();
            screenDetail.id = screeningSlot.Id;
            screenDetail.programType = screeningSlot.ProgramType__c;
            screenDetail.startTime = screeningSlot.StartTime__c;
            screenDetail.endTime = screeningSlot.StartTime__c.addMinutes(SCREEN_DURATION);
            screenDetail.title = screeningSlot.ProgramType__c == 'Regular' ? '' : screeningSlot.ProgramType__c;
            screenDetail.isSeries = false;
            screenDetail.isOwner = true;
            screenDetail.screenerId = screeningSlot.Screener__c;
            screenDetail.screenerName = screeningSlot.Screener__r.Name;
            if(!screeningSlot.Screenings__r.isEmpty()){
                screenDetail.color =  '#3e8ede';
                screenDetail.isScheduled = true;
                screenDetail.screenType = screeningSlot.Screenings__r[0].ScreenType__c;
                screenDetail.candidateId = screeningSlot.Screenings__r[0].Candidate__c;
                screenDetail.candidateName = screeningSlot.Screenings__r[0].Candidate__r.Name;
            }
            else {
                screenDetail.color = '#3eba4d';
                screenDetail.isScheduled = false;
            }
            screeningDetailList.add(screenDetail);
        }

        if(showAll){
            String userRole = ScreeningController.getRoleId();
            if(userRole == 'Screener'){
                List<ScreeningSlot__c> allScreeningSlots = new List<ScreeningSlot__c>([SELECT Id, Screener__c, Screener__r.Name, StartTime__c, ProgramType__c, 
                                                                                       (SELECT Id, ScreenStatus__c, ScreenType__c, Candidate__c, Candidate__r.Name FROM Screenings__r WHERE ScreenStatus__c NOT IN ('Cancelled','Rescheduled') ORDER BY CreatedDate DESC)
                                                                                       FROM ScreeningSlot__c
                                                                                       WHERE DAY_ONLY(StartTime__c) >= :startDate AND DAY_ONLY(StartTime__c) <= :endDate AND Screener__c != :screenerId and RecordType.Name='Tech Screen']);
                
                for(ScreeningSlot__c screeningSlot : allScreeningSlots){
                    ScreeningController.Detail screenDetail = new ScreeningController.Detail();
                    screenDetail.id = screeningSlot.Id;
                    screenDetail.programType = screeningSlot.ProgramType__c;
                    screenDetail.startTime = screeningSlot.StartTime__c;
                    screenDetail.endTime = screeningSlot.StartTime__c.addMinutes(SCREEN_DURATION);
                    screenDetail.title = screeningSlot.ProgramType__c == 'Regular' ? screeningSlot.Screener__r.Name : screeningSlot.Screener__r.Name+' - '+screeningSlot.ProgramType__c;
                    screenDetail.isSeries = false;
                    screenDetail.isOwner = true;
                    screenDetail.screenerId = screeningSlot.Screener__c;
                    screenDetail.screenerName = screeningSlot.Screener__r.Name;
                    if(!screeningSlot.Screenings__r.isEmpty()){
                        screenDetail.color =  '#9c27b0';
                        screenDetail.isScheduled = true;
                        screenDetail.screenType = screeningSlot.Screenings__r[0].ScreenType__c;
                        screenDetail.candidateId = screeningSlot.Screenings__r[0].Candidate__c;
                        screenDetail.candidateName = screeningSlot.Screenings__r[0].Candidate__r.Name;
                    }
                    else {
                        screenDetail.color = '#ff9800';
                        screenDetail.isScheduled = false;
                    }
                    screeningDetailList.add(screenDetail);
                }
                return screeningDetailList;
            }
            else if(userRole == 'Panelist'){
                List<ScreeningSlot__c> allScreeningSlots = new List<ScreeningSlot__c>([SELECT Id, Screener__c, Screener__r.Name, StartTime__c, ProgramType__c, 
                                                                                       (SELECT Id, Status__c, Mode__c, Associate__c, Associate__r.Name FROM Assessments__r WHERE Status__c NOT IN ('Cancelled','Rescheduled') ORDER BY CreatedDate DESC)
                                                                                       FROM ScreeningSlot__c
                                                                                       WHERE DAY_ONLY(StartTime__c) >= :startDate AND DAY_ONLY(StartTime__c) <= :endDate AND Screener__c != :screenerId and RecordType.Name='Panel']);
                
                for(ScreeningSlot__c screeningSlot : allScreeningSlots){
                    System.debug(screeningSlot);
                    ScreeningController.Detail screenDetail = new ScreeningController.Detail();
                    screenDetail.id = screeningSlot.Id;
                    screenDetail.programType = screeningSlot.ProgramType__c;
                    screenDetail.startTime = screeningSlot.StartTime__c;
                    screenDetail.endTime = screeningSlot.StartTime__c.addMinutes(SCREEN_DURATION);
                    screenDetail.title  =screeningSlot.Screener__r.Name;
                    screenDetail.isSeries = false;
                    screenDetail.isOwner = true;
                    screenDetail.screenerId = screeningSlot.Screener__c;
                    screenDetail.screenerName = screeningSlot.Screener__r.Name;
                    if(!screeningSlot.Assessments__r.isEmpty()){
                        screenDetail.color =  '#9c27b0';
                        screenDetail.isScheduled = true;
                        screenDetail.screenType = screeningSlot.Assessments__r[0].Mode__c;
                        screenDetail.candidateId = screeningSlot.Assessments__r[0].Associate__c;
                        screenDetail.candidateName = screeningSlot.Assessments__r[0].Associate__r.Name;
                    }
                    else {
                        screenDetail.color = '#ff9800';
                        screenDetail.isScheduled = false;
                    }
                    screeningDetailList.add(screenDetail);
                }
                return screeningDetailList;
            }
            
        }
        
        return screeningDetailList;
    }
    

    public static void createSlot(ScreeningController.Detail screenDetail){
        List<ScreeningSlot__c> duplicateSlots = new List<ScreeningSlot__c>([SELECT Id FROM ScreeningSlot__c WHERE Screener__c = :UserInfo.getUserId() AND StartTime__c = :screenDetail.startTime]);

        if(!duplicateSlots.isEmpty()){
            throw new AuraHandledException('DuplicateException');
        }

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(SERVICE_SOBJECTS);

        String usrRole = [select UserRole.Name FROM User where Id =: UserInfo.getUserId()].UserRole.Name;
        ScreeningSlot__c screeningSlot = new ScreeningSlot__c();
        screeningSlot.Screener__c = UserInfo.getUserId();
        screeningSlot.StartTime__c = screenDetail.startTime;
        if(usrRole == 'Panelist'){
            screeningSlot.RecordTypeId = Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
             screeningSlot.ProgramType__c = '';
        }else if(usrRole == 'Screener'){
            screeningSlot.RecordTypeId = Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Tech Screen').getRecordTypeId();
             screeningSlot.ProgramType__c = screenDetail.programType;
        }
        
        uow.registerNew(screeningSlot);

        uow.commitWork();
    }

    public static void createSeries(ScreeningController.Detail screenDetail){
        List<ScreeningSlot__c> currentScreeningSlots = new List<ScreeningSlot__c>([SELECT Id, StartTime__c FROM ScreeningSlot__c WHERE Screener__c = :UserInfo.getUserId() 
                                                                                                                                    AND DAY_ONLY(StartTime__c)>=:screenDetail.startTime.date() 
                                                                                                                                    AND DAY_ONLY(StartTime__c) <= :screenDetail.endDate]);

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(SERVICE_SOBJECTS);
        System.debug(screenDetail.repeatDays);
        List<ScreeningSlot__c> newScreenings = new List<ScreeningSlot__c>();
        Time screenDateTime = screenDetail.startTime.time();
        for(Date currDate = screenDetail.startTime.date(); currDate <= screenDetail.endDate; currDate = currDate.addDays(1)){
            if(screenDetail.repeatDays.contains(getDay(currDate))){
                ScreeningSlot__c screeningSlot = new ScreeningSlot__c();
                screeningSlot.Screener__c = UserInfo.getUserId();
                screeningSlot.StartTime__c = Datetime.newInstance(currDate, screenDateTime);
                screeningSlot.ProgramType__c = screenDetail.programType;
                uow.registerNew(screeningSlot);
                newScreenings.add(screeningSlot);
            }
        }

        if(checkIsDuplicate(newScreenings, currentScreeningSlots)){
            throw new AuraHandledException('DuplicateException');
        }

        uow.commitWork();
    }

    public static void updateSlot(ScreeningController.Detail screenDetail){
        ScreeningSlot__c currentScreeningSlot = [SELECT Id, ProgramType__c, StartTime__c, Screener__c, 
                                                (SELECT Id FROM Screenings__r WHERE ScreenStatus__c NOT IN ('Cancelled','Rescheduled')) 
                                                FROM ScreeningSlot__c WHERE Id = :screenDetail.Id LIMIT 1];
        List<ScreeningSlot__c> duplicateSlots = [SELECT Id FROM ScreeningSlot__c WHERE Id != :screenDetail.id AND Screener__c = :currentScreeningSlot.Screener__c AND StartTime__c = :screenDetail.startTime];
        if(!currentScreeningSlot.Screenings__r.isEmpty()){
            throw new AuraHandledException('ScreenScheduledException');
        }
        if(!duplicateSlots.isEmpty()){
            throw new AuraHandledException('DuplicateException');
        }

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(SERVICE_SOBJECTS); 

        currentScreeningSlot.StartTime__c = screenDetail.startTime;
        currentScreeningSlot.ProgramType__c = screenDetail.programType;
        uow.registerDirty(currentScreeningSlot);

        uow.commitWork();
    }

    public static void deleteSlot(ScreeningController.Detail screenDetail){
        ScreeningSlot__c currentScreeningSlot = [SELECT Id, (SELECT Id FROM Screenings__r WHERE ScreenStatus__c NOT IN ('Cancelled','Rescheduled')) FROM ScreeningSlot__c WHERE Id = :screenDetail.Id LIMIT 1];
        
        if(!currentScreeningSlot.Screenings__r.isEmpty()){
            throw new AuraHandledException('ScreenScheduledException');
        }

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(SERVICE_SOBJECTS); 

        uow.registerDeleted(currentScreeningSlot);
        
        uow.commitWork();
    }

    private static String getDay(Date selectedDate){
        Datetime dt = datetime.newInstance(selectedDate.year(), selectedDate.month(), selectedDate.day());
        return String.valueOf(dt.format('EEEE'));
    }

    private static Boolean checkIsDuplicate(List<ScreeningSlot__c> newScreeningSlots, List<ScreeningSlot__c> currentScreeningSlots){
        for(ScreeningSlot__c newScreeningSlot : newScreeningSlots){
            for(ScreeningSlot__c currentScreeningSlot : currentScreeningSlots){
                if(newScreeningSlot.StartTime__c == currentScreeningSlot.StartTime__c){
                    return true;
                }
            }
        }
        return false;
    }

    /*
    private static String getSeriesDays(Set<String> repeatDays){
        String seriesDays = '';
        for(String day : repeatDays){
            seriesDays += (day+';');
        }
        return seriesDays.removeEnd(';');
    }

    private static Set<Date> getExceptionDays(String exceptionString){
        Set<Date> exceptionSet = new Set<Date>();
        if(String.isNotBlank(exceptionString)){
            for(String dateString : exceptionString.split(';')){
                exceptionSet.add(Date.valueOf(dateString));
            }
        }
        
        return exceptionSet;
    }
    */
}