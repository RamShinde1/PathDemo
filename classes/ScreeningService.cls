public without sharing class ScreeningService {
    private static List<Schema.SObjectType> SERVICE_SOBJECTS = 
        new Schema.SObjectType[] { 
            Screening__c.SObjectType
        };


    public static List<Screening__c> getByScreener(Id screenerId){
        return new ScreeningSelector().selectByScreener(screenerId);
    }

    public static Screening__c getById(Id screeningId) {
        return new ScreeningSelector().selectById(screeningId);   
    }
    public static Assessment__c selectById(Id screeningId) {
        return new AssessmentsSelector().selectById(screeningId);   
    }
    
    public static Screening__c getLastScreening(Id contactId) {
        Contact userContact = new ContactsSelector().selectById(contactId);
        if (userContact.LastScreening__c != null) {
            return getById(userContact.LastScreening__c);
        }
        else {
            return null;
        }
    }

    /************Sunayana*******************/
   
    public static Assessment__c getLastPanelist(Id contactId){
        Contact usrContact = new ContactsSelector().selectById(contactId);
       string assessmentRecord=[SELECT Id FROM Assessment__c  WHERE Associate__c =: usrContact.id ORDER BY LastModifiedDate DESC limit 1].id;
       return  selectById(assessmentRecord);
    }
    /*************End*********************/
    public static void assignScreener(Id screeningId, Id screenerId,String componentName) {
        // Assign replacement screener
        // add role and check before update(Ramji)
        String userRole = ScreeningController.getRoleId();
        if(componentName == 'AssignReplacementScreener'){
            Screening__c screening = [SELECT Id, Screener__c FROM Screening__c WHERE Id = :screeningId ];
            Id previousScreener = screening.Screener__c;
            screening.Screener__c = screenerId;
            update screening;
            
            // Create new task for newly assigned replacement screener
            insert ActivityService.getTask('ScheduledTechScreen',screeningId);
            
            // Close task for previously assigned screener
            ActivityService.updateTask('ScheduledTechScreen',screeningId,'Closed-Not Conducted',previousScreener);
        }
        else if(componentName =='AssignReplacementPanel')
        {
            system.debug('Hi..In Panelist');
            Assessment__c assessment = [select id, AssignedTo__c from Assessment__c where id =: screeningId ];
            assessment.AssignedTo__c = screenerId;
            update assessment;
        }
       
    }

    public static void scheduleScreening(Contact candidate, Id screenerId, String screenType, Id screeningSlotId, Datetime slotStartTime){
          String usrRole = ScreeningController.getRoleId();
         string screenerUsrRole=[SELECT UserRole.Name FROM User WHERE Id=:screenerId].UserRole.Name;

        ScreeningSlot__c screeningSlot = [SELECT Id,(SELECT Id FROM Screenings__r WHERE ScreenStatus__c != 'Cancelled') FROM ScreeningSlot__c WHERE Id=:screeningSlotId LIMIT 1];
        if(!screeningSlot.Screenings__r.isEmpty()){
            throw new AuraHandledException('AlreadyScheduledException');
        }

         ScreeningSlot__c screeningSlotPanel = [SELECT Id,(SELECT Id FROM Assessments__r WHERE Status__c != 'Cancelled') FROM ScreeningSlot__c WHERE Id=:screeningSlotId LIMIT 1];
        if(!screeningSlotPanel.Assessments__r.isEmpty()){
            throw new AuraHandledException('AlreadyScheduledException');
        }
        // Create screening record
      /***********Added by Ramji only for Panelist*********************/
        if(screenerUsrRole == 'Panelist')
        {
        Assessment__c assessment=new Assessment__c();
        assessment.Associate__c=candidate.Id;
        assessment.AssignedTo__c=screenerId;
        assessment.Date__c=slotStartTime;
        assessment.Status__c='Scheduled';
        assessment.ScreeningSlot__c = screeningSlotId;
        Id assessmentpanelid=Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
        assessment.RecordTypeId=assessmentpanelid;
        insert assessment;
        contact candidaterecord=[select id, first__c,Last__c from contact where id=:candidate.id ];
       
       if(candidaterecord.First__c!=Null)
       {
           ObjectReference__c objrefc=[select id,Panel__c from ObjectReference__c where id=:candidaterecord.First__c];
           if(objrefc.Panel__c==null){
           objrefc.Panel__c=assessment.id;
           
           update objrefc;
           }
       }
        
       if(candidaterecord.last__c!=Null)
       {
           ObjectReference__c objrefc=[select id,Panel__c from ObjectReference__c where id=:candidaterecord.last__c];
           objrefc.Panel__c=assessment.id;
           update objrefc;
       }
        
        } 
        
        /************end******************************/
        
        // Update candidate contact record
        // Only need to update for screening not for Panel (Ramji)
       

        // Create Scheduled Tech Screen Task
        // Do not create Task for Panel(Ramji)
      
        if(screenerUsrRole == 'Screener'){
            Screening__c screening = new Screening__c();
        screening.Candidate__c = candidate.Id;
        screening.ScreenType__c = screenType;
        screening.Screener__c = screenerId;
        screening.ScreenStatus__c = 'Scheduled';
        screening.ScreenDate__c = slotStartTime;
        screening.ScreeningSlot__c = screeningSlotId;
        screening.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Technical' AND SObjectType='Screening__c' LIMIT 1].Id;
        insert screening;
             
             candidate.LastScreening__c = screening.Id;
        candidate.MasterStage__c = 'Screening';
        if (candidate.Recruiter__c != null) {
            candidate.RecruitmentStatus__c = 'Tech Screen';
        }
        else if (candidate.Recruiter__c == null) {
            candidate.RecruitmentStatus__c = 'Tech Screen';
            candidate.QualifyingStatus__c = 'Recruiter Transfer';
            candidate.Recruiter__c = UserInfo.getUserId();
        }
        update candidate;
            insert ActivityService.getTask('ScheduledTechScreen',screening.Id);
            
            //Close callback tasks
            ActivityService.updateTasks(
                new List<String>{'CallbackContact','ContactNoLongerActiveInRevaturePro','CallbackAboutRevaturePro'}, 
                candidate.Id, 
                'Closed', 
                null
            ); 
        }
        
       
    }

    public static List<ScreeningController.ScheduleDetail> getAllScreenings(Date startDate, Date endDate,string componentName) {
        List<ScreeningController.ScheduleDetail> screeningSlots = ScreeningSlotService.getAllSlots(startDate, endDate,componentName);
        return screeningSlots;
    }
}