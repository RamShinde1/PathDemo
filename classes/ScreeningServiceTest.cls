@isTest
private class ScreeningServiceTest {
    // getByScreener - Positive Cases
     @isTest
    public static User createPanelUser(){
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Screener'];
        // string userRole=[SELECT Id FROM UserRole where Name='Screener'].id;
        Id roleId = [SELECT DeveloperName FROM UserRole WHERE DeveloperName = 'Panelist'].Id;
        User Panelist = new User(Alias = 'standtu', Email='Paneltestshowallpanel@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,UserRoleid=roleId, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='Paneltestshowallpanel@user.user.spaghetti');
        insert Panelist;
        return Panelist;
    }
    @isTest
    private static void getScreeningsThatExistByScreenerThatExistsTest() {
        // Create screener with screenings
        Profile screenerProfile = [SELECT Id FROM Profile WHERE Name='Screener']; 
        UserRole usrRole=new UserRole();
        usrRole.Name='Screener';
        usrRole.DeveloperName='Screeneruser';
        insert usrRole;
        User screenerUser = new User(Alias = 'standtp', Email='standarduserpanel@testorg.com', 
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = screenerProfile.Id, UserRoleId = usrRole.Id,
                                     TimeZoneSidKey='America/New_York', UserName='superuniquepanel@user.user.spaghetti');
        insert screenerUser;
        System.runAs(screenerUser) {
            Contact con = new Contact();
            con.FirstName = 'Sample';
            con.LastName = 'Record';
            con.Email = 'sample@example.com';
            con.MobilePhone = '8765432178';
            con.MasterStage__c = 'Qualifying';
            con.DoNotSMS__c = false;
            Insert con;
            
            Screening__c screeningRecord = new Screening__c();
            screeningRecord.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Technical' LIMIT 1].Id;
            screeningRecord.Screener__c = screenerUser.Id;
            screeningRecord.Candidate__c = con.Id;
            insert screeningRecord;
            
            con.LastScreening__c = screeningRecord.Id;
            update con;
            
            // Verify that all screening records are retrieved
            Screening__c lastScreening = ScreeningController.getLastScreening(con.Id);
            List<Screening__c> screeningsRetrieved = ScreeningService.getByScreener(screenerUser.Id);
            System.assert(!screeningsRetrieved.isEmpty());
            System.assert(screeningsRetrieved.get(0).Id == screeningRecord.Id);
            string componentName='AssignReplacementScreener';
            ScreeningController.assignScreener(screeningsRetrieved[0].Id, screenerUser.Id,componentName);
            // the following lines may not be scalable
            List<Screening__c> screeningsInDatabase = [SELECT Id FROM Screening__c WHERE Screener__c=:screenerUser.Id];
            System.assert(screeningsRetrieved.size() == screeningsInDatabase.size());
            
        }
    }

   @isTest
    private static void assignPanelistTest() {
        User newPanel = createPanelUser();
        system.runAs(newPanel){
            Contact con = new Contact();
            con.FirstName = 'Sampletest';
            con.LastName = 'Recordnew';
            con.Email = 'samplepanel@example.com';
            con.MobilePhone = '8765432179';
            con.IntacctContactRecordNumber__c = 'WGJ';
            con.IntacctEmployeeRecordNumber__c = 'WGJ';
            con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Revature').getRecordTypeId();
            con.MasterStage__c = 'Screening';
            Insert con;
            
            Assessment__c assRecord = new Assessment__c();
            assRecord.Associate__c = con.Id;
            assRecord.AssignedTo__c = newPanel.Id;
           
             assRecord.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
            insert assRecord;
           Assessment__c lastAss = ScreeningController.getLastPanelist(con.id);
       }
    }
    
    @isTest
    private static void getScreeningsThatDontExistByScreenerThatExistsTest() {
        // Create screener without screenings
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User screenerUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='superunique@user.user.spaghetti');
        insert screenerUser;

        // Verify that no screening records are retrieved
        List<Screening__c> screeningsInDatabase = ScreeningService.getByScreener(screenerUser.Id);
        System.assert(screeningsInDatabase.isEmpty());
    }

    // scheduleScreening - Positive Case
    @isTest
    private static void scheduleScreeningTest() {
        // Create career coach, screener, and candidates
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
          //string userRole=[SELECT Id FROM UserRole where Name='Screener'].id;
        UserRole usrRole=new UserRole();
        usrRole.Name='Screener';
        usrRole.DeveloperName='Screeneruser';
        insert usrRole;
        User careerCoachUser = new User(Alias = 'standt', Email='cc@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='careercoach@user.user.spaghetti');
        insert careerCoachUser;

        User screenerUser = new User(Alias = 'standt', Email='screener@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,UserRoleID=usrRole.id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='screener@user.user.spaghetti');
        insert screenerUser;
        System.runAs(screenerUser) {
        Contact candidateWithoutCC = new Contact();
        candidateWithoutCC.LastName = 'No Career Coach';
        candidateWithoutCC.MasterStage__c = 'Screening';
        candidateWithoutCC.WorkAuthorization__c = 'U.S. Citizen';
        candidateWithoutCC.Recruiter__c = careerCoachUser.Id;
        candidateWithoutCC.IntacctContactRecordNumber__c = 'WGJ';
        candidateWithoutCC.IntacctEmployeeRecordNumber__c = 'WGJ';
        candidateWithoutCC.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Revature').getRecordTypeId();
        candidateWithoutCC.MasterStage__c = 'Screening';
        insert candidateWithoutCC;
        
        ScreeningSlot__c screeningSlot = new ScreeningSlot__c();
        insert screeningSlot;

        Contact cWithoutCCBefore = [SELECT Id, Name, LastName, MasterStage__c, LastScreening__c, CareerCoach__c, CareerCoachStatus__c, RecruitmentStatus__c FROM Contact WHERE Id=:candidateWithoutCC.Id LIMIT 1];

        System.assert(cWithoutCCBefore.LastScreening__c == null);

        // Create task Callback task
        Id recruiterId = UserInfo.getUserId();

        Task t2 = ActivityService.getTask('CallbackContact', candidateWithoutCC.Id);
        insert t2;

        // Schedule screenings for right now
        String screenType = 'Video';
        Datetime screenDate = Datetime.now();
        
           
        ScreeningService.scheduleScreening(cWithoutCCBefore, screenerUser.Id, screenType, screeningSlot.Id, screenDate.addDays(1));
        
        // Verify that the screening records and tasks are created and that the candidates are updated
        Screening__c screeningWithoutCC = [SELECT Id FROM Screening__c WHERE Candidate__c=:cWithoutCCBefore.Id AND Screener__c=:screenerUser.Id AND ScreenType__c=:screenType AND ScreenDate__c=:screenDate.addDays(1) AND ScreenStatus__c='Scheduled'];
        
        System.assert(screeningWithoutCC != null);
        

        Contact cWithoutCCAfter = [SELECT Id, Name, LastName, MasterStage__c, LastScreening__c, CareerCoach__c, CareerCoachStatus__c, RecruitmentStatus__c FROM Contact WHERE Id=:candidateWithoutCC.Id];

        System.assert(cWithoutCCAfter.RecruitmentStatus__c == 'Tech Screen');

        Task taskScreenScheduledWithoutCC = [SELECT Subject, Description FROM Task WHERE OwnerId=:screenerUser.Id AND Status='Not Started' AND WhoId=:cWithoutCCAfter.Id AND ProcessTaskID__c='ScheduledTechScreen'];
        
        System.assertEquals('Tech Screen Scheduled: ' + cWithoutCCAfter.Name, taskScreenScheduledWithoutCC.Subject);
     
    }
    }
        

    // scheduleScreening - Negative Case
    @isTest
    private static void scheduleScreeningWithoutOldTaskTest() {
        // Execute gracefully without task Callback task in database
        
        // Create career coach, screener, and candidates
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        // string userRole=[SELECT Id FROM UserRole where Name='Screener'].id;
        UserRole usrRole=new UserRole();
        usrRole.Name='Screener';
        usrRole.DeveloperName='UserScreener';
        insert usrRole;
        User careerCoachUser = new User(Alias = 'standt', Email='cc@testorg.com', 
                                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
                                        TimeZoneSidKey='America/Los_Angeles', UserName='careercoach@user.user.spaghetti');
        insert careerCoachUser;
        
        User screenerUser = new User(Alias = 'standt', Email='screener@testorg.com', 
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,UserRoleid=usrRole.id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='screener@user.user.spaghetti');
        insert screenerUser;
        System.runAs(screenerUser) {
            Contact candidateWithCC = new Contact();
            candidateWithCC.LastName = 'Has Career Coach';
            candidateWithCC.MasterStage__c = 'Screening';
            candidateWithCC.WorkAuthorization__c = 'U.S. Citizen';
            candidateWithCC.Recruiter__c = careerCoachUser.Id;
            candidateWithCC.IntacctContactRecordNumber__c = 'WGJ';
           candidateWithCC.IntacctEmployeeRecordNumber__c = 'WGJ';
           candidateWithCC.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Revature').getRecordTypeId();
           candidateWithCC.MasterStage__c = 'Screening';
            insert candidateWithCC;
            
            ScreeningSlot__c screeningSlot = new ScreeningSlot__c();
            insert screeningSlot;
            
            Contact cWithCCBefore = [SELECT Id, Name, LastName, MasterStage__c, LastScreening__c, CareerCoach__c, CareerCoachStatus__c, RecruitmentStatus__c FROM Contact WHERE Id=:candidateWithCC.Id LIMIT 1];
            
            System.assert(cWithCCBefore.LastScreening__c == null);
            
            // Schedule screenings for right now
            String screenType = 'Video';
            Datetime screenDate = Datetime.now();
            
            // Verify that scheduleScreening handles the expected QueryException or any other exceptions,
            // but still schedules screening and creates task
            QueryException uncaughtQueryException;
            Exception uncaughtException;
            
            try {
                ScreeningService.scheduleScreening(cWithCCBefore, screenerUser.Id, screenType, screeningSlot.Id, screenDate);
            }
            catch(QueryException qe) {
                uncaughtQueryException = qe;
            }
            catch(Exception e) {
                uncaughtException = e;
            }
            
            System.assertEquals(null, uncaughtQueryException, 'QueryExceptions should be handled by scheduleScreening');
            System.assertEquals(null, uncaughtException, 'Exceptions should be handled by scheduleScreening');
            
            Screening__c screeningWithCC = [SELECT Id FROM Screening__c WHERE Candidate__c=:cWithCCBefore.Id AND Screener__c=:screenerUser.Id AND ScreenType__c=:screenType AND ScreenDate__c=:screenDate and ScreenStatus__c='Scheduled'];
            
            System.assert(screeningWithCC != null);
            
            Contact cWithCCAfter = [SELECT Id, Name, LastName, MasterStage__c, LastScreening__c, RecruitmentStatus__c FROM Contact WHERE Id=:candidateWithCC.Id];
            
            System.assert(cWithCCAfter.LastScreening__c == screeningWithCC.Id);
            System.assert(cWithCCAfter.RecruitmentStatus__c == 'Tech Screen');
            
            //Task taskScreenScheduledWithCC = [SELECT Subject, Description FROM Task WHERE OwnerId=:screenerUser.Id AND ActivityDate=:screenDate.date() AND Status='Not Started' AND WhoId=:cWithCCAfter.Id AND ProcessTaskID__c='ScheduledTechScreen'];
            
            //System.assertEquals('Tech Screen Scheduled: ' + cWithCCAfter.Name, taskScreenScheduledWithCC.Subject);
        }
    }
    
    @isTest
    private static void schedulePanelWithRole() {
        // Execute gracefully without task Callback task in database
        User createPanelUserNew = createPanelUser();
        // Create career coach, screener, and candidates
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User careerCoachUser = new User(Alias = 'standt', Email='cc@testorg.com', 
                                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
                                        TimeZoneSidKey='America/Los_Angeles', UserName='careercoach@user.user.spaghetti');
        insert careerCoachUser;
         System.runAs(createPanelUserNew) {
            Contact candidateWithCC = new Contact();
            candidateWithCC.LastName = 'Has Career Coach';
            candidateWithCC.MasterStage__c = 'Screening';
            candidateWithCC.WorkAuthorization__c = 'U.S. Citizen';
            candidateWithCC.Recruiter__c = careerCoachUser.Id;
            candidateWithCC.IntacctContactRecordNumber__c = 'WGJ';
           candidateWithCC.IntacctEmployeeRecordNumber__c = 'WGJ';
           candidateWithCC.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Revature').getRecordTypeId();
           candidateWithCC.MasterStage__c = 'Screening';
            insert candidateWithCC;
            
            ScreeningSlot__c screeningSlot = new ScreeningSlot__c();
            insert screeningSlot;
            
            Contact cWithCCBefore = [SELECT Id, Name, LastName, MasterStage__c, LastScreening__c, CareerCoach__c, CareerCoachStatus__c, RecruitmentStatus__c FROM Contact WHERE Id=:candidateWithCC.Id LIMIT 1];
            
            System.assert(cWithCCBefore.LastScreening__c == null);
            
            // Schedule screenings for right now
            String screenType = 'Video';
            Datetime screenDate = Datetime.now();
            
            // Verify that scheduleScreening handles the expected QueryException or any other exceptions,
            // but still schedules screening and creates task
            QueryException uncaughtQueryException;
            Exception uncaughtException;
            
            try {
                ScreeningService.scheduleScreening(cWithCCBefore, createPanelUserNew.Id, screenType, screeningSlot.Id, screenDate);
            }
            catch(QueryException qe) {
                uncaughtQueryException = qe;
            }
            catch(Exception e) {
                uncaughtException = e;
            }
            
            System.assertEquals(null, uncaughtQueryException, 'QueryExceptions should be handled by scheduleScreening');
            System.assertEquals(null, uncaughtException, 'Exceptions should be handled by scheduleScreening');
            
          //  Screening__c screeningWithCC = [SELECT Id FROM Screening__c WHERE Candidate__c=:cWithCCBefore.Id AND Screener__c=:screenerUser.Id AND ScreenType__c=:screenType AND ScreenDate__c=:screenDate and ScreenStatus__c='Scheduled'];
            
         //   System.assert(screeningWithCC != null);
            
            Contact cWithCCAfter = [SELECT Id, Name, LastName, MasterStage__c, LastScreening__c, RecruitmentStatus__c FROM Contact WHERE Id=:candidateWithCC.Id];
            
        //    System.assert(cWithCCAfter.LastScreening__c == screeningWithCC.Id);
        //    System.assert(cWithCCAfter.RecruitmentStatus__c == 'Tech Screen');
            
            //Task taskScreenScheduledWithCC = [SELECT Subject, Description FROM Task WHERE OwnerId=:screenerUser.Id AND ActivityDate=:screenDate.date() AND Status='Not Started' AND WhoId=:cWithCCAfter.Id AND ProcessTaskID__c='ScheduledTechScreen'];
            
            //System.assertEquals('Tech Screen Scheduled: ' + cWithCCAfter.Name, taskScreenScheduledWithCC.Subject);
        }
    }
    
/* Disabled until ScreeningSlotService Refactored

    // getAllScreenings - Positive Case
    @isTest
    private static void getAllScreeningsValidDateRangeTest() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User screenerUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='superunique@user.user.spaghetti');
        insert screenerUser;

        Contact candidate = new Contact();
        candidate.LastName = 'Test Contact';
        candidate.MasterStage__c = 'Screening';
        insert candidate;

        // Over five days: 01/01/18 - 01/05/18,
        //  - Create 4 screening slots on: 01/01 - 01/04
        //  - Create 4 scheduled screenings on: 01/02 - 01/05
        Datetime day = Datetime.newInstance(2018, 1, 1);

        Id screeningRecordTypeTechnical = [SELECT Id FROM RecordType WHERE DeveloperName='Technical' LIMIT 1].Id;

        List<ScreeningSlot__c> slots = new List<ScreeningSlot__c>();
        
        for(Integer i = 0; i < 4; ++i){
            ScreeningSlot__c slot = new ScreeningSlot__c();
            slot.SeriesEndDate__c = (slot.StartTime__c = day + i).date();
            slot.Screener__c = screenerUser.Id;
            slots.add(slot);
        }

        insert slots;

        List<Screening__c> screens = new List<Screening__c>();
        for(Integer i = 1; i < 5; ++i){
            Screening__c screen = new Screening__c();
            screen.RecordTypeId = screeningRecordTypeTechnical;
            screen.ScreenDate__c = day + i;
            screen.Screener__c = screenerUser.Id;
            screen.Candidate__c = candidate.Id;
            screen.ScreenType__c = 'Video';
            screens.add(screen);
        }

        insert screens;

        List<ScreeningController.ScheduleDetail> screeningsRetrieved = new List<ScreeningController.ScheduleDetail>();
        Integer numScheduledScreenings = 0;

        // Verify the number of screening slots and the number of scheduled screenings during various date ranges
        // Check dates: 01/01 - 01/05
        screeningsRetrieved = ScreeningService.getAllScreenings(day.date(), (day+4).date());
        System.assertEquals(4, screeningsRetrieved.size());
        numScheduledScreenings = 0;
        for (ScreeningController.ScheduleDetail screeningRetrieved : screeningsRetrieved) {
            if (screeningRetrieved.isScheduled == true) {
                numScheduledScreenings++;
            }
        }
        System.assertEquals(3, numScheduledScreenings);

        // Check dates: 01/01 - 01/02
        screeningsRetrieved = ScreeningService.getAllScreenings(day.date(), (day+1).date());
        System.assertEquals(2, screeningsRetrieved.size());
        numScheduledScreenings = 0;
        for (ScreeningController.ScheduleDetail screeningRetrieved : screeningsRetrieved) {
            if (screeningRetrieved.isScheduled == true) {
                numScheduledScreenings++;
            }
        }
        System.assertEquals(1, numScheduledScreenings);

        // Check dates: 01/02
        screeningsRetrieved = ScreeningService.getAllScreenings((day+1).date(), (day+1).date());
        System.assertEquals(1, screeningsRetrieved.size());
        numScheduledScreenings = 0;
        for (ScreeningController.ScheduleDetail screeningRetrieved : screeningsRetrieved) {
            if (screeningRetrieved.isScheduled == true) {
                numScheduledScreenings++;
            }
        }
        System.assertEquals(1, numScheduledScreenings);

        // Check dates: 01/01
        screeningsRetrieved = ScreeningService.getAllScreenings(day.date(), day.date());
        System.assertEquals(1, screeningsRetrieved.size());
        numScheduledScreenings = 0;
        for (ScreeningController.ScheduleDetail screeningRetrieved : screeningsRetrieved) {
            if (screeningRetrieved.isScheduled == true) {
                numScheduledScreenings++;
            }
        }
        System.assertEquals(0, numScheduledScreenings);
    }

    // getAllScreenings - Negative Case
    @isTest
    private static void getAllScreeningsInvalidDateRangeTest() {
        // endDate is before startDate
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User screenerUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='superunique@user.user.spaghetti');
        insert screenerUser;

        Contact candidate = new Contact();
        candidate.LastName = 'Test Contact';
        candidate.MasterStage__c = 'Screening';
        insert candidate;

        Datetime day1 = Datetime.newInstance(2018, 1, 1);
        Datetime day2 = Datetime.newInstance(2018, 1, 2);

        Id screeningRecordTypeTechnical = [SELECT Id FROM RecordType WHERE DeveloperName='Technical' LIMIT 1].Id;

        List<ScreeningSlot__c> slots = new List<ScreeningSlot__c>();

        ScreeningSlot__c slot1 = new ScreeningSlot__c();
        slot1.StartTime__c = day1;
        slot1.SeriesEndDate__c = day1.date();
        slot1.Screener__c = screenerUser.Id;
        slots.add(slot1);

        ScreeningSlot__c slot2 = new ScreeningSlot__c();
        slot2.StartTime__c = day2;
        slot2.SeriesEndDate__c = day2.date();
        slot2.Screener__c = screenerUser.Id;
        slots.add(slot2);

        insert slots;

        List<Screening__c> screens = new List<Screening__c>();

        Screening__c screen2 = new Screening__c();
        screen2.RecordTypeId = screeningRecordTypeTechnical;
        screen2.ScreenDate__c = day2;
        screen2.Screener__c = screenerUser.Id;
        screen2.Candidate__c = candidate.Id;
        screen2.ScreenType__c = 'Video';
        screens.add(screen2);

        insert screens;

        List<ScreeningController.ScheduleDetail> screeningsRetrieved = new List<ScreeningController.ScheduleDetail>();
        Integer numScheduledScreenings = 0;

        // Try to break code:
        //  - Start Date: 01/02
        //  - End Date: 01/01
        screeningsRetrieved = ScreeningService.getAllScreenings(day2.date(), day1.date());
        System.assertEquals(0, screeningsRetrieved.size());
        numScheduledScreenings = 0;
        for (ScreeningController.ScheduleDetail screeningRetrieved : screeningsRetrieved) {
            if (screeningRetrieved.isScheduled == true) {
                numScheduledScreenings++;
            }
        }
        System.assertEquals(0, numScheduledScreenings);
    }
 */
    @isTest
    private static void getAllScreeningsNoDataTest() {
        // No slots or screenings in database
        Datetime day1 = Datetime.newInstance(2018, 1, 1);
        Datetime day2 = Datetime.newInstance(2018, 1, 2);
        string componentName='ScheduleTechScreen';

        List<ScreeningController.ScheduleDetail> screeningsRetrieved = new List<ScreeningController.ScheduleDetail>();
        Integer numScheduledScreenings = 0;

        screeningsRetrieved = ScreeningService.getAllScreenings(day1.date(), day2.date(),componentName);
        System.assertEquals(0, screeningsRetrieved.size());
        numScheduledScreenings = 0;
        for (ScreeningController.ScheduleDetail screeningRetrieved : screeningsRetrieved) {
            if (screeningRetrieved.isScheduled == true) {
                numScheduledScreenings++;
            }
        }
        System.assertEquals(0, numScheduledScreenings);
    }

}