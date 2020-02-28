@isTest
public class ScreeningSlotTest {
    
    @isTest
    public static User createPanelUser(){
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        // string userRole=[SELECT Id FROM UserRole where Name='Screener'].id;
        Id roleId = [SELECT DeveloperName FROM UserRole WHERE DeveloperName = 'Panelist'].Id;
        User Panelist = new User(Alias = 'standt', Email='Paneltestshowall@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,UserRoleid=roleId, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='Paneltestshowall@user.user.spaghetti');
        insert Panelist;
        return Panelist;
    }
    @isTest
    static void makeCodeCoverage(){
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        // string userRole=[SELECT Id FROM UserRole where Name='Screener'].id;
        UserRole usrRole=new UserRole();
        usrRole.Name='Screener';
        usrRole.DeveloperName='UserScreener';
        insert usrRole;
        User screenerUser = new User(Alias = 'standt', Email='screenetestr@testorg.com', 
                                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,UserRoleid=usrRole.id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='screenertest@user.user.spaghetti');
        insert screenerUser;
        System.runAs(screenerUser) {
            ScreeningController.getScreenerFilter(null);
            ScreeningController.getSlotPicklistValues();
            string componentName='ScheduleTechScreen';
            ScreeningController.getAllScreenings('2018-01-01', '2018-01-01',componentName);
        }
    }
    @isTest
    static void makeCodeCoveragePanel(){
        User newPanelUser = createPanelUser();
        
        System.runAs(newPanelUser) {
            ScreeningController.getScreenerFilter(null);
            ScreeningController.getSlotPicklistValues();
            string componentName='SchedulePanel';
            ScreeningController.getAllScreenings('2018-01-01', '2018-01-01',componentName);
        }
    }
    
    @isTest
    static void testGetSlotDetails(){
        
        ScreeningSlot__c screenSlot = new ScreeningSlot__c();
        screenSlot.Screener__c = UserInfo.getUserId();
        screenSlot.StartTime__c = Datetime.valueOf('2018-01-23 03:30:00');
        screenSlot.SeriesEndDate__c = Date.valueOf('2018-01-23');
        
        ScreeningSlot__c screenSlot1 = new ScreeningSlot__c();
        screenSlot1.Screener__c = UserInfo.getUserId();
        screenSlot1.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
        screenSlot1.SeriesDays__c = 'Monday;Wednesday;Friday';
        screenSlot1.SeriesEndDate__c = Date.valueOf('2018-02-02');
        insert new List<ScreeningSlot__c>{screenSlot, screenSlot1};
            string componentName='ScheduleTechScreen';
        
        Test.startTest();
        List<ScreeningController.Detail> screenDetailList = ScreeningController.getAllSlots('2018-01-01', '2018-02-12', 'false',componentName);
        Test.stopTest();
    }
    @isTest
    static void testGetSlotPanelDetails(){
        ScreeningSlot__c screenSlot = new ScreeningSlot__c();
        screenSlot.Screener__c = UserInfo.getUserId();
        screenSlot.StartTime__c = Datetime.valueOf('2018-01-23 03:30:00');
        screenSlot.SeriesEndDate__c = Date.valueOf('2018-01-23');
        
        ScreeningSlot__c screenSlot1 = new ScreeningSlot__c();
        screenSlot1.Screener__c = UserInfo.getUserId();
        screenSlot1.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
        screenSlot1.SeriesDays__c = 'Monday;Wednesday;Friday';
        screenSlot1.SeriesEndDate__c = Date.valueOf('2018-02-02');
        insert new List<ScreeningSlot__c>{screenSlot, screenSlot1};
            string componentName='SchedulePanel';
        
        Test.startTest();
        List<ScreeningController.Detail> screenDetailList = ScreeningController.getAllSlots('2018-01-01', '2018-02-12', 'false',componentName);
        Test.stopTest();
    }
    @isTest
    static void testGetSlotDetailsShowAll(){
        // User newPanelUser1 = createPanelUser();
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        // string userRole=[SELECT Id FROM UserRole where Name='Screener'].id;
        UserRole usrRole=new UserRole();
        usrRole.Name='Screener';
        usrRole.DeveloperName='UserScreener';
        insert usrRole;
        User screener = new User(Alias = 'standt', Email='screenertestshowall@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,UserRoleid=usrRole.id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='screenertestshowall@user.user.spaghetti');
        insert screener;
        system.runAs(screener){
            ScreeningSlot__c screenSlot = new ScreeningSlot__c();
            screenSlot.StartTime__c = Datetime.valueOf('2018-01-23 03:30:00');
            screenSlot.SeriesEndDate__c = Date.valueOf('2018-01-23');
            screenSlot.RecordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Tech Screen').getRecordTypeId();
            
            ScreeningSlot__c screenSlot1 = new ScreeningSlot__c();
            screenSlot1.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
            screenSlot1.SeriesDays__c = 'Monday;Wednesday;Friday';
            screenSlot1.SeriesEndDate__c = Date.valueOf('2018-02-02');
            screenSlot1.RecordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Tech Screen').getRecordTypeId();
            insert new List<ScreeningSlot__c>{screenSlot, screenSlot1};
            string componentName='ScheduleTechScreen';
            
            Test.startTest();
            List<ScreeningController.Detail> screenDetailList = ScreeningController.getAllSlots('2018-01-01', '2018-02-12', 'true',componentName);
            Test.stopTest();
            
        }
    }
    @isTest
    static void testGetSlotPanelDetailsShowAll(){
        User newPanelUser2 = createPanelUser();
        
        system.runAs(newPanelUser2){
            ScreeningSlot__c screenSlot = new ScreeningSlot__c();
            screenSlot.StartTime__c = Datetime.valueOf('2020-01-23 03:30:00');
            screenSlot.SeriesEndDate__c = Date.valueOf('2020-01-23');
            screenSlot.RecordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
            
            Contact con = new Contact();
            con.FirstName = 'Sampletest';
            con.LastName = 'Recordnew';
            con.Email = 'samplepanel@example.com';
            con.MobilePhone = '8765432179';
            con.MasterStage__c = 'Qualifying';
            con.IntacctContactRecordNumber__c = 'WGJ';
            con.IntacctEmployeeRecordNumber__c = 'WGJ';
            con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Revature').getRecordTypeId();
            con.MasterStage__c = 'Screening';
            Insert con;
            
            Assessment__c assRecord1 = new Assessment__c();
            assRecord1.Associate__c = con.Id;
            assRecord1.AssignedTo__c = newPanelUser2.Id;
            assRecord1.Status__c = 'Scheduled';
            assRecord1.ScreeningSlot__c = screenSlot.id;
            assRecord1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
            insert assRecord1;
            
            ScreeningSlot__c screenSlot1 = new ScreeningSlot__c();
            screenSlot1.StartTime__c = Datetime.valueOf('2020-01-22 03:30:00');
            screenSlot1.SeriesDays__c = 'Monday;Wednesday;Friday';
            screenSlot1.SeriesEndDate__c = Date.valueOf('2020-02-02');
            screenSlot1.RecordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
            insert new List<ScreeningSlot__c>{screenSlot, screenSlot1};
                string componentName='SchedulePanel';
            Test.startTest();
            List<ScreeningController.Detail> screenDetailList = ScreeningController.getAllSlots('2018-01-01', '2020-12-12', 'true',componentName);
            Test.stopTest();
            
        }
    }
    @isTest
    static void testGetAllSlots(){
        ScreeningSlot__c screenSlot = new ScreeningSlot__c();
        screenSlot.Screener__c = UserInfo.getUserId();
        screenSlot.StartTime__c = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(12,30,0,0));
        screenSlot.SeriesEndDate__c = Date.valueOf(Date.today().addDays(7).toStartOfWeek());
        screenSlot.RecordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Tech Screen').getRecordTypeId();
        
        ScreeningSlot__c screenSlot1 = new ScreeningSlot__c();
        screenSlot1.Screener__c = UserInfo.getUserId();
        screenSlot1.StartTime__c = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(12,30,0,0));
        screenSlot1.SeriesDays__c = 'Sunday';
        screenSlot1.SeriesEndDate__c = Date.valueOf(Date.today().addDays(7).toStartOfWeek().addDays(14));
        screenSlot1.RecordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Tech Screen').getRecordTypeId();
        insert new List<ScreeningSlot__c>{screenSlot, screenSlot1};
            string componentName='ScheduleTechScreen';
        
        Test.startTest();
        List<ScreeningController.ScheduleDetail> screenDetailList = ScreeningSlotService.getAllSlots(Date.today().toStartOfMonth(), Date.today().toStartOfMonth().addDays(60),componentName);
        Test.stopTest();
    }
    
    @isTest
    static void getAllSlotsForPanel(){
        User newPanel = createPanelUser();
        
        System.runAs(newPanel) {
            ScreeningSlot__c screenSlot = new ScreeningSlot__c();
            screenSlot.Screener__c = newPanel.Id;
            screenSlot.StartTime__c = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(12,30,0,0));
            screenSlot.SeriesEndDate__c = Date.valueOf(Date.today().addDays(7).toStartOfWeek());
            screenSlot.RecordTypeId = Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
            
            ScreeningSlot__c screenSlot1 = new ScreeningSlot__c();
            screenSlot1.Screener__c = newPanel.Id;
            screenSlot1.StartTime__c = Datetime.newInstance(Date.today().addDays(7).toStartOfWeek(), Time.newInstance(12,30,0,0));
            screenSlot1.SeriesDays__c = 'Sunday';
            screenSlot1.SeriesEndDate__c = Date.valueOf(Date.today().addDays(7).toStartOfWeek().addDays(14));
            screenSlot1.RecordTypeId=Schema.SObjectType.ScreeningSlot__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
            insert new List<ScreeningSlot__c>{screenSlot, screenSlot1};
            string componentName='SchedulePanel';
            
            Test.startTest();
            List<ScreeningController.ScheduleDetail> screenDetailList = ScreeningSlotService.getAllSlots(Date.today().toStartOfMonth(), Date.today().toStartOfMonth().addDays(60),componentName);
            Test.stopTest();
        }
    }    
    @isTest
    static void testCreateSlot() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        // string userRole=[SELECT Id FROM UserRole where Name='Screener'].id;
        UserRole usrRole=new UserRole();
        usrRole.Name='Screener';
        usrRole.DeveloperName='UserScreener';
        insert usrRole;
        User screener = new User(Alias = 'standt', Email='screenertestcreate@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,UserRoleid=usrRole.id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='screenertestcreate@user.user.spaghetti');
        insert screener;
        system.runAs(screener){
            ScreeningController.Detail screenDetail = new ScreeningController.Detail();
            screenDetail.startTime = Datetime.valueOf('2018-01-23 03:30:00');
            Test.startTest();
            ScreeningController.createSlot(JSON.serialize(screenDetail));
            Test.stopTest();
        }
    }
    @isTest
    static void testPanelistCreateSlot() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        // string userRole=[SELECT Id FROM UserRole where Name='Screener'].id;
        UserRole usrRole=new UserRole();
        usrRole.Name='Panelist';
        usrRole.DeveloperName='UserScreener';
        insert usrRole;
        User Panelist = new User(Alias = 'standt', Email='panelisrttestcreate@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,UserRoleid=usrRole.id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='panelisrttestcreate@user.user.spaghetti');
        insert Panelist;
        system.runAs(Panelist){
            ScreeningController.Detail screenDetail = new ScreeningController.Detail();
            screenDetail.startTime = Datetime.valueOf('2018-01-23 03:30:00');
            Test.startTest();
            ScreeningController.createSlot(JSON.serialize(screenDetail));
            Test.stopTest();
        }
    }
    @isTest
    static void testCreateSeries() {
        ScreeningController.Detail screenDetail = new ScreeningController.Detail();
        screenDetail.startTime = Datetime.valueOf('2018-01-22 03:30:00');
        screenDetail.repeatDays = new Set<String>{'Monday', 'Wednesday', 'Friday'};
            screenDetail.endDate = Date.valueOf('2018-02-02');
        Test.startTest();
        ScreeningController.createSlotSeries(JSON.serialize(screenDetail));
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateSlot() {
        ScreeningSlot__c screenSlot = new ScreeningSlot__c();
        screenSlot.Screener__c = UserInfo.getUserId();
        screenSlot.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
        screenSlot.SeriesEndDate__c = Date.valueOf('2018-01-22');
        insert screenSlot;
        
        ScreeningController.Detail screenDetail = new ScreeningController.Detail();
        screenDetail.id = screenSlot.Id;
        screenDetail.startTime = Datetime.valueOf('2018-01-22 05:30:00');
        screenDetail.isSeries = false;
        screenDetail.endDate = Date.valueOf('2018-01-22');
        
        Test.startTest();
        ScreeningController.updateSlot(JSON.serialize(screenDetail));
        Test.stopTest();
    }
    
    /*
@isTest
static void testUpdateSlotInSeries() {
ScreeningSlot__c screenSlot = new ScreeningSlot__c();
screenSlot.Screener__c = UserInfo.getUserId();
screenSlot.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
screenSlot.SeriesDays__c = 'Monday;Wednesday;Friday';
screenSlot.SeriesEndDate__c = Date.valueOf('2018-02-02');
insert screenSlot;

ScreeningController.Detail screenDetail = new ScreeningController.Detail();
screenDetail.id = screenSlot.Id;
screenDetail.startTime = Datetime.valueOf('2018-01-24 05:30:00');
screenDetail.previousStartTime = Datetime.valueOf('2018-01-24 03:30:00');

Test.startTest();
ScreeningController.updateSlot(JSON.serialize(screenDetail));
Test.stopTest();

List<ScreeningSlot__c> screenSlotList = [SELECT Id, StartTime__c, IsSeries__c, SeriesEndDate__c, SeriesDays__c,Exception__c FROM ScreeningSlot__c ORDER BY StartTime__c];

System.assertEquals(2, screenSlotList.size());
System.assertEquals(Datetime.valueOf('2018-01-22 03:30:00'), screenSlotList[0].StartTime__c);
System.assertEquals(true, screenSlotList[0].IsSeries__c);
System.assertEquals('2018-01-24', screenSlotList[0].Exception__c);
System.assertEquals(Date.valueOf('2018-02-02'), screenSlotList[0].SeriesEndDate__c);
System.assertEquals(Datetime.valueOf('2018-01-24 05:30:00'), screenSlotList[1].StartTime__c);
System.assertEquals(false, screenSlotList[1].IsSeries__c);
}

@isTest
static void testUpdateSeries() {
ScreeningSlot__c screenSlot = new ScreeningSlot__c();
screenSlot.Screener__c = UserInfo.getUserId();
screenSlot.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
screenSlot.SeriesDays__c = 'Monday;Wednesday;Friday';
screenSlot.SeriesEndDate__c = Date.valueOf('2018-02-02');
insert screenSlot;

ScreeningController.Detail screenDetail = new ScreeningController.Detail();
screenDetail.id = screenSlot.Id;
screenDetail.startTime = Datetime.valueOf('2018-01-24 05:30:00');
screenDetail.repeatDays = new Set<String>{'Tuesday', 'Thursday'};
screenDetail.endDate = Date.valueOf('2018-02-01');

Test.startTest();
ScreeningController.updateSlotSeries(JSON.serialize(screenDetail));
Test.stopTest();

List<ScreeningSlot__c> screenSlotList = [SELECT Id, StartTime__c, IsSeries__c, SeriesEndDate__c, SeriesDays__c,Exception__c FROM ScreeningSlot__c ORDER BY StartTime__c];

System.assertEquals(1, screenSlotList.size());
System.assertEquals(Datetime.valueOf('2018-01-22 05:30:00'), screenSlotList[0].StartTime__c);
System.assertEquals(true, screenSlotList[0].IsSeries__c);
System.assertEquals('Tuesday;Thursday', screenSlotList[0].SeriesDays__c);
System.assertEquals(Date.valueOf('2018-02-01'), screenSlotList[0].SeriesEndDate__c);
}

@isTest
static void testUpdateFutureSeries() {
ScreeningSlot__c screenSlot = new ScreeningSlot__c();
screenSlot.Screener__c = UserInfo.getUserId();
screenSlot.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
screenSlot.SeriesDays__c = 'Monday;Wednesday;Friday';
screenSlot.SeriesEndDate__c = Date.valueOf('2018-02-02');
insert screenSlot;

ScreeningController.Detail screenDetail = new ScreeningController.Detail();
screenDetail.id = screenSlot.Id;
screenDetail.startTime = Datetime.valueOf('2018-01-26 05:30:00');
screenDetail.previousStartTime = Datetime.valueOf('2018-01-26 03:30:00');
screenDetail.repeatDays = new Set<String>{'Tuesday', 'Thursday'};
screenDetail.endDate = Date.valueOf('2018-02-01');

Test.startTest();
ScreeningController.updateFutureSeries(JSON.serialize(screenDetail));
Test.stopTest();

List<ScreeningSlot__c> screenSlotList = [SELECT Id, StartTime__c, IsSeries__c, SeriesEndDate__c, SeriesDays__c,Exception__c FROM ScreeningSlot__c ORDER BY StartTime__c];

System.assertEquals(2, screenSlotList.size());
System.assertEquals(Datetime.valueOf('2018-01-22 03:30:00'), screenSlotList[0].StartTime__c);
System.assertEquals(true, screenSlotList[0].IsSeries__c);
System.assertEquals('Monday;Wednesday;Friday', screenSlotList[0].SeriesDays__c);
System.assertEquals(Date.valueOf('2018-01-25'), screenSlotList[0].SeriesEndDate__c);
System.assertEquals(Datetime.valueOf('2018-01-26 05:30:00'), screenSlotList[1].StartTime__c);
System.assertEquals(true, screenSlotList[1].IsSeries__c);
System.assertEquals('Tuesday;Thursday', screenSlotList[1].SeriesDays__c);
System.assertEquals(Date.valueOf('2018-02-01'), screenSlotList[1].SeriesEndDate__c);
}
*/
    
    @isTest
    static void testDeleteSlot() {
        ScreeningSlot__c screenSlot = new ScreeningSlot__c();
        screenSlot.Screener__c = UserInfo.getUserId();
        screenSlot.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
        screenSlot.SeriesEndDate__c = Date.valueOf('2018-01-22');
        insert screenSlot;
        
        ScreeningController.Detail screenDetail = new ScreeningController.Detail();
        screenDetail.id = screenSlot.Id;
        
        Test.startTest();
        ScreeningController.deleteSlot(JSON.serialize(screenDetail));
        Test.stopTest();
    }
    
    /*
@isTest
static void testDeleteSlotInSeries() {
ScreeningSlot__c screenSlot = new ScreeningSlot__c();
screenSlot.Screener__c = UserInfo.getUserId();
screenSlot.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
screenSlot.SeriesDays__c = 'Monday;Wednesday;Friday';
screenSlot.SeriesEndDate__c = Date.valueOf('2018-02-02');
insert screenSlot;

ScreeningController.Detail screenDetail = new ScreeningController.Detail();
screenDetail.id = screenSlot.Id;
screenDetail.startTime = Datetime.valueOf('2018-01-24 03:30:00');

Test.startTest();
ScreeningController.deleteSlot(JSON.serialize(screenDetail));
Test.stopTest();

List<ScreeningSlot__c> screenSlotList = [SELECT Id, StartTime__c, IsSeries__c, SeriesEndDate__c, SeriesDays__c,Exception__c FROM ScreeningSlot__c ORDER BY StartTime__c];

System.assertEquals(1, screenSlotList.size());
System.assertEquals(Datetime.valueOf('2018-01-22 03:30:00'), screenSlotList[0].StartTime__c);
System.assertEquals(true, screenSlotList[0].IsSeries__c);
System.assertEquals('2018-01-24', screenSlotList[0].Exception__c);
System.assertEquals(Date.valueOf('2018-02-02'), screenSlotList[0].SeriesEndDate__c);
}

@isTest
static void testDeleteSeries() {
ScreeningSlot__c screenSlot = new ScreeningSlot__c();
screenSlot.Screener__c = UserInfo.getUserId();
screenSlot.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
screenSlot.SeriesDays__c = 'Monday;Wednesday;Friday';
screenSlot.SeriesEndDate__c = Date.valueOf('2018-02-02');
insert screenSlot;

ScreeningController.Detail screenDetail = new ScreeningController.Detail();
screenDetail.id = screenSlot.Id;

Test.startTest();
ScreeningController.deleteSlotSeries(JSON.serialize(screenDetail));
Test.stopTest();

List<ScreeningSlot__c> screenSlotList = [SELECT Id, StartTime__c, IsSeries__c, SeriesEndDate__c, SeriesDays__c,Exception__c FROM ScreeningSlot__c ORDER BY StartTime__c];

System.assertEquals(0, screenSlotList.size());
}

@isTest
static void testDeleteFutureSeries() {
ScreeningSlot__c screenSlot = new ScreeningSlot__c();
screenSlot.Screener__c = UserInfo.getUserId();
screenSlot.StartTime__c = Datetime.valueOf('2018-01-22 03:30:00');
screenSlot.SeriesDays__c = 'Monday;Wednesday;Friday';
screenSlot.SeriesEndDate__c = Date.valueOf('2018-02-02');
insert screenSlot;

ScreeningController.Detail screenDetail = new ScreeningController.Detail();
screenDetail.id = screenSlot.Id;
screenDetail.startTime = Datetime.valueOf('2018-01-26 03:30:00');

Test.startTest();
ScreeningController.deleteFutureSeries(JSON.serialize(screenDetail));
Test.stopTest();

List<ScreeningSlot__c> screenSlotList = [SELECT Id, StartTime__c, IsSeries__c, SeriesEndDate__c, SeriesDays__c,Exception__c FROM ScreeningSlot__c ORDER BY StartTime__c];

System.assertEquals(1, screenSlotList.size());
System.assertEquals(Datetime.valueOf('2018-01-22 03:30:00'), screenSlotList[0].StartTime__c);
System.assertEquals(true, screenSlotList[0].IsSeries__c);
System.assertEquals('Monday;Wednesday;Friday', screenSlotList[0].SeriesDays__c);
System.assertEquals(Date.valueOf('2018-01-25'), screenSlotList[0].SeriesEndDate__c);
}
*/
}