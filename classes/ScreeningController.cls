public without sharing class ScreeningController {
    
    @AuraEnabled
    public static ScreeningController.SlotPicklistValues getSlotPicklistValues(){
        return new ScreeningController.SlotPicklistValues();
    }
    /** Added by Ramji****/
    @AuraEnabled
    public static String getRoleId(){
        Id usrId=UserInfo.getUserId();
        string usr=[SELECT UserRole.Name FROM User WHERE Id=:usrId].UserRole.Name;
        return usr;
    }
    /******* end*****/
    @AuraEnabled
   public static Screening__c getLastScreening(String contactId) {
        String  userRole = getRoleId();
       Screening__c lastScreening = ScreeningService.getLastScreening(contactId);
      //  if(userRole == 'Screener'){
            if (lastScreening != null) {
                return lastScreening;
            }
            else {
                throw new AuraHandledException('Could not get candidate\'s last screening.');
            }
       // }
        return lastScreening;
    }
     @AuraEnabled
     public static Assessment__c getLastPanelist(String contactId) {
        String  userRole = getRoleId();
      Assessment__c lastScreening = ScreeningService.getLastPanelist(contactId);
       // if(userRole == 'Panelist'){
            if (lastScreening != null) {
                return lastScreening;
            }
            else {
                throw new AuraHandledException('Could not get candidate\'s last screening.');
            }
        //}
        return lastScreening;
    }
    
    @AuraEnabled
    //add filter for Panlist
    public static String getScreenerFilter(String screenerId) {
        // Get Ids of screening roles: Screener and Trainer
        // Need to add Panlist role for screening panel replacment.(Ramji Shinde)
        String getUserRole = getRoleId();
        string whereClause;
        if(getUserRole == 'Screener'){
            Map<Id, UserRole> roleIds = new Map<Id, UserRole>([SELECT Id FROM UserRole WHERE (DeveloperName='Screener' OR DeveloperName='Trainer')]);
            String roleIdsSet = '';
            for (Id roleId : roleIds.keySet()) {
                roleIdsSet += '\'' + roleId + '\',';
            }
            String roles = '(' + roleIdsSet.substring(0,roleIdsSet.length()-1) + ')'; // not the best way to the remove final comma
             whereClause = '(UserRoleId IN ' + roles + ' AND Id!=\'' + screenerId + '\')';
           // return whereClause;
        }
        else if(getUserRole == 'Panelist'){
            Map<Id, UserRole> roleIds = new Map<Id, UserRole>([SELECT Id FROM UserRole WHERE DeveloperName='Panelist']);
            String roleIdsSet = '';
            for (Id roleId : roleIds.keySet()) {
                roleIdsSet += '\'' + roleId + '\',';
            }
            String roles = '(' + roleIdsSet.substring(0,roleIdsSet.length()-1) + ')'; // not the best way to the remove final comma
             whereClause = '(UserRoleId IN ' + roles + ' AND Id!=\'' + screenerId + '\')';
           // return whereClause;
        }
        return whereClause;
    }
    
    @AuraEnabled
    public static void assignScreener(String screeningId, String screenerId, String componentName) {
        ScreeningService.assignScreener(screeningId, screenerId, componentName);
    }
    
    @AuraEnabled
    public static void scheduleScreening(String scheduleDetailString, String contactId) {
        Contact userContact = [SELECT Id, Name, MasterStage__c, LastScreening__c, WorkAuthorization__c,
                               Recruiter__c, RecruitmentStatus__c, CareerCoach__c, CareerCoachStatus__c FROM Contact WHERE Id=:contactId];
        
        if (userContact.WorkAuthorization__c=='U.S. Citizen' || userContact.WorkAuthorization__c=='Green Card' || userContact.WorkAuthorization__c=='EAD') {
            JSONParser parser = JSON.createParser(scheduleDetailString);
            ScheduleDetail scheduleDetail = (ScheduleDetail)parser.readValueAs(ScreeningController.ScheduleDetail.class);
            
            ScreeningService.scheduleScreening(userContact, scheduleDetail.screenerId, scheduleDetail.screenType, scheduleDetail.id, scheduleDetail.startTime);
        }
        else {
            throw new AuraHandledException('Candidate\'s Work Authorization must be one of the following values: U.S. Citizen, Green Crad, or EAD.');
        }
    }
    
    @AuraEnabled
    public static List<ScheduleDetail> getAllScreenings(String startDateString, String endDateString,string componentName){
        Date startDate = Date.valueOf(startDateString);
        Date endDate = Date.valueOf(endDateString);
       
        return ScreeningService.getAllScreenings(startDate, endDate,componentName);
    }
    
    @AuraEnabled
    public static List<Detail> getAllSlots(String startDateString, String endDateString, String showAllString,string componentname){
        Date startDate = Date.valueOf(startDateString);
        Date endDate = Date.valueOf(endDateString);
        Boolean showAll = Boolean.valueOf(showAllString);
        return ScreeningSlotService.getSlotDetails(UserInfo.getUserId(), startDate, endDate, showAll,componentname);
    }
    
    @AuraEnabled
    public static void createSlot(String screenDetailString){
        JSONParser parser = JSON.createParser(screenDetailString);
        Detail screenDetail = (Detail)parser.readValueAs(Detail.class);
        ScreeningSlotService.createSlot(screenDetail);
    }
    
    @AuraEnabled
    public static void createSlotSeries(String screenDetailString){
        JSONParser parser = JSON.createParser(screenDetailString);
        Detail screenDetail = (Detail)parser.readValueAs(Detail.class);
        ScreeningSlotService.createSeries(screenDetail);
    }
    
    @AuraEnabled
    public static void updateSlot(String screenDetailString){
        JSONParser parser = JSON.createParser(screenDetailString);
        Detail screenDetail = (Detail)parser.readValueAs(Detail.class);
        ScreeningSlotService.updateSlot(screenDetail);
    }
    
    @AuraEnabled
    public static void deleteSlot(String screenDetailString){
        JSONParser parser = JSON.createParser(screenDetailString);
        Detail screenDetail = (Detail)parser.readValueAs(Detail.class);
        ScreeningSlotService.deleteSlot(screenDetail);
    }
    
    public class ScheduleDetail{
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public Datetime startTime{get;set;}
        @AuraEnabled public Datetime endTime{get;set;}
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public String color{get;set;}
        @AuraEnabled public Boolean isScheduled{get;set;}
        @AuraEnabled public String screenerId{get;set;}
        @AuraEnabled public String screenerName{get;set;}
        @AuraEnabled public String screenType{get;set;}
        @AuraEnabled public String candidateName{get;set;}
        @AuraEnabled public String recordTypeId{get;set;}
    }
    
    public class Detail{
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public String programType{get;set;}
        @AuraEnabled public Datetime previousStartTime{get;set;}
        @AuraEnabled public Datetime startTime{get;set;}
        @AuraEnabled public Datetime endTime{get;set;}
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public Boolean isSeries{get;set;}
        @AuraEnabled public Set<String> repeatDays{get;set;}
        @AuraEnabled public Date endDate{get;set;}
        @AuraEnabled public String color{get;set;}
        @AuraEnabled public Boolean isOwner{get;set;}
        @AuraEnabled public Boolean isScheduled{get;set;}
        @AuraEnabled public String screenerId{get;set;}
        @AuraEnabled public String screenerName{get;set;}
        @AuraEnabled public String screenType{get;set;}
        @AuraEnabled public String candidateId{get;set;}
        @AuraEnabled public String candidateName{get;set;}
    }
    
    public class SlotPicklistValues{
        @AuraEnabled List<PicklistEntry> programTypeOptions {get;set;}
        
        public SlotPicklistValues(){
            this.programTypeOptions = new List<PicklistEntry>();
            for (Schema.PicklistEntry a : ScreeningSlot__c.ProgramType__c.getDescribe().getPicklistValues()) {
                this.programTypeOptions.add(new PicklistEntry(a.getLabel(), a.getValue()));
            }
        }
    }
    public class SelectUser{
        @AuraEnabled List<PicklistEntry> UserOptions {get;set;}
        
        public SelectUser(){
            this.UserOptions = new List<PicklistEntry>();
            for (Schema.PicklistEntry a : User.Name.getDescribe().getPicklistValues()) {
                this.UserOptions.add(new PicklistEntry(a.getLabel(), a.getValue()));
            }
        }
    }
}