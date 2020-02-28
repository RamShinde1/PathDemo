@isTest
public class PanelOutComeControllerTest {

    @testSetup
    public static void setup() {
        Id roleId = [SELECT DeveloperName FROM UserRole WHERE DeveloperName = 'HR'].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'HR'].Id;
        User endUser = new User(
            ProfileId = profileId,
            LastName = 'EndUser',
            Email = 'salesforce@example.com',
            Username = 'salesforce@example.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = roleId,
            Department__c = 'Salesforce',
            Team__c = 'Salesforce'
        );
        insert endUser;

        System.runAs(endUser) {
            Id panelIdForTemplate = Schema.SObjectType.Template__c.getRecordTypeInfosByDeveloperName().get('Panel').getRecordTypeId();
            Id panelIdForTemplateLineItem = Schema.SObjectType.TemplateLineItem__c.getRecordTypeInfosByDeveloperName().get('Panel').getRecordTypeId();
            List<TemplateLineItem__c> templateLineItems = new List<TemplateLineItem__c>();
            Template__c newTemplate = new Template__c(Name = 'Test', Active__c = true, Description__c = 'test', RecordTypeId = panelIdForTemplate);
            insert newTemplate;

            for (Integer i = 0; i < 4; i++) {
                templateLineItems.add(
                    new TemplateLineItem__c(
                        MaxScore__c = 30,
                        Name = '.Net' + i,
                        Template__c = newTemplate.Id,
                        RecordTypeId = panelIdForTemplateLineItem
                    )
                );
            }
            insert templateLineItems;

            List<Contact> newContacts = new List<Contact>();
            for(Integer i = 1; i < 5; i++){
                newContacts.add(
                    new Contact(
                        FirstName = 'Unique',
                        LastName = 'User' + i,
                        Email = 'test01' + i + '@yopmail.com',
                        MobilePhone = '123456789' + i,
                        Phone = '023456789' + i,
                        Title = 'Test' + i,
                        IntacctContactRecordNumber__c = 'WGJ' + i,
                        IntacctEmployeeRecordNumber__c = 'WGJ' + i,
                        RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Revature').getRecordTypeId(),
                        MasterStage__c = 'Training'
                    )
                );
            }
            insert newContacts;

            //Four Associates: 1 = New Panel Scheduled, 2 = A Completed Panel that has Repanels and a Scheduled Assessment for the Repanel, 3 = Already completed, 4 = No Panel

            //New Panel for Unique User1 Schedule for Now
            Assessment__c newAssessment = new Assessment__c(
                Template__c = newTemplate.id,
                PanelRound__c = 1,
                RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByDeveloperName().get('Panel').getRecordTypeId(),
                Associate__c = newContacts[0].Id,
                Date__c = System.now()
            );
            insert newAssessment;

            ObjectReference__c user1ObjRef = [SELECT Id, Panel__c FROM ObjectReference__c WHERE Id IN (SELECT Last__c FROM Contact WHERE LastName = 'User1')];
            user1ObjRef.Panel__c = newAssessment.Id;
            update user1ObjRef;
            //End User1

            //Completed Panel for Unique User2 Schedule for Now, repanel, and a scheduled repanel for Now
            Assessment__c newAssessment2 = new Assessment__c(
                Template__c = newTemplate.id,
                PanelRound__c = 1,
                RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByDeveloperName().get('Panel').getRecordTypeId(),
                Associate__c = newContacts[1].Id,
                Date__c = System.now(),
                OverallFeedback__c = 'Repanel',
                ClientInterviewReady__c = false,
                Status__c = 'Complete'
            );
            insert newAssessment2;

            Id AssessmentLineItemRecordTypeid = Schema.SObjectType.Assessment_Line_Item__c.getRecordTypeInfosByDeveloperName()
                .get('Panel')
                .getRecordTypeId();

            list<Assessment_Line_Item__c> assessmentlineItems2 = new List<Assessment_Line_Item__c>();
            for (Integer i = 0; i < 4; i++) {
                if(i < 2){
                    assessmentlineItems2.add(
                        new Assessment_Line_Item__c(
                            Assessment__c = newAssessment2.Id,
                            Name = '.Net'+i,
                            Comment__c = 'Test',
                            MaxScore__c = 30,
                            NumericScore__c = 10,
                            RecordTypeId = AssessmentLineItemRecordTypeid,
                            Repanel__c = true
                        )
                    );
                }
                else{
                    assessmentlineItems2.add(
                        new Assessment_Line_Item__c(
                            Assessment__c = newAssessment2.Id,
                            Name = '.Net'+i,
                            Comment__c = 'Test',
                            MaxScore__c = 30,
                            NumericScore__c = 25,
                            RecordTypeId = AssessmentLineItemRecordTypeid,
                            Repanel__c = false
                        )
                    );
                }
            }
            insert assessmentlineItems2;

            Assessment__c newAssessment3 = new Assessment__c(
                Template__c = newTemplate.id,
                PanelRound__c = 2,
                RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByDeveloperName().get('Panel').getRecordTypeId(),
                Associate__c = newContacts[1].Id,
                Date__c = System.now()
            );
            insert newAssessment3;
            //End User2

            //User3, Passed Panel
            Assessment__c newAssessment4 = new Assessment__c(
                Template__c = newTemplate.id,
                PanelRound__c = 1,
                RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByDeveloperName().get('Panel').getRecordTypeId(),
                Associate__c = newContacts[2].Id,
                Date__c = DateTime.newInstance(2020,01,01),
                OverallFeedback__c = 'Pass',
                ClientInterviewReady__c = true,
                Status__c = 'Complete'
            );
            insert newAssessment4;

            list<Assessment_Line_Item__c> assessmentlineItems4 = new List<Assessment_Line_Item__c>();
            for (Integer i = 0; i < 4; i++) {
                assessmentlineItems4.add(
                    new Assessment_Line_Item__c(
                        Assessment__c = newAssessment4.Id,
                        Name = '.Net'+i,
                        Comment__c = 'Test',
                        MaxScore__c = 30,
                        NumericScore__c = 25,
                        RecordTypeId = AssessmentLineItemRecordTypeid,
                        Repanel__c = false
                    )
                );
            }
            insert assessmentlineItems4;

            ObjectReference__c user3ObjRef = [SELECT Id, Panel__c FROM ObjectReference__c WHERE Id IN (SELECT Last__c FROM Contact WHERE LastName = 'User3')];
            user3ObjRef.Panel__c = newAssessment4.Id;
            update user3ObjRef;
            //End User3
        }
    }

    @IsTest
    static void getAssessmentTest_Round1(){

        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user1 = [SELECT Id FROM Contact WHERE LastName = 'User1'];
        
        PanelOutComeController.AssessmentFieldsWrapper payload = new PanelOutComeController.AssessmentFieldsWrapper();
        Test.startTest();
        System.runAs(contextuser){
            payload = PanelOutComeController.getAssessment(user1.Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, payload.assessment);
        System.assertNotEquals(null, payload.modePicklistEntryOptions);
        System.assertNotEquals(null, payload.overAllFeedBackPicklistEntryOptions);
        System.assertNotEquals(null, payload.StablityPicklistEntryOptions);

        System.assertEquals(1, payload.assessment.PanelRound__c);
        System.assertEquals(System.now().date(), payload.assessment.Date__c.date());

    }

    @IsTest
    static void getAssessmentTest_Round1_Edit(){
        
        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user2 = [SELECT Id FROM Contact WHERE LastName = 'User2'];

        //Set Last Panel to the round 1 panel
        ObjectReference__c user2ObjRef = [SELECT Id, Panel__c FROM ObjectReference__c WHERE Id IN (SELECT Last__c FROM Contact WHERE LastName = 'User2')];
        user2ObjRef.Panel__c = [SELECT Id FROM Assessment__c WHERE Status__c = 'Complete' AND Associate__c = :user2.Id].Id;
        update user2ObjRef;
        
        PanelOutComeController.AssessmentFieldsWrapper payload = new PanelOutComeController.AssessmentFieldsWrapper();
        Test.startTest();
        System.runAs(contextuser){
            payload = PanelOutComeController.getAssessment(user2.Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, payload.assessment);
        System.assertNotEquals(null, payload.modePicklistEntryOptions);
        System.assertNotEquals(null, payload.overAllFeedBackPicklistEntryOptions);
        System.assertNotEquals(null, payload.StablityPicklistEntryOptions);

        System.assertEquals(1, payload.assessment.PanelRound__c);
        System.assertEquals(System.now().date(), payload.assessment.Date__c.date());
        
    }

    @IsTest
    static void getAssessmentTest_Round2(){
        
        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user2 = [SELECT Id FROM Contact WHERE LastName = 'User2'];

        //Set Last Panel to the round 1 panel
        ObjectReference__c user2ObjRef = [SELECT Id, Panel__c FROM ObjectReference__c WHERE Id IN (SELECT Last__c FROM Contact WHERE LastName = 'User2')];
        user2ObjRef.Panel__c = [SELECT Id FROM Assessment__c WHERE Status__c != 'Complete' AND Associate__c = :user2.Id].Id;
        update user2ObjRef;
        
        PanelOutComeController.AssessmentFieldsWrapper payload = new PanelOutComeController.AssessmentFieldsWrapper();
        Test.startTest();
        System.runAs(contextuser){
            payload = PanelOutComeController.getAssessment(user2.Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, payload.assessment);
        System.assertNotEquals(null, payload.modePicklistEntryOptions);
        System.assertNotEquals(null, payload.overAllFeedBackPicklistEntryOptions);
        System.assertNotEquals(null, payload.StablityPicklistEntryOptions);

        System.assertEquals(2, payload.assessment.PanelRound__c);
        System.assertEquals(System.now().date(), payload.assessment.Date__c.date());
        
    }

    @IsTest
    static void getAssessmentTest_AlreadyComplete(){

        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user3 = [SELECT Id FROM Contact WHERE LastName = 'User3'];
        
        PanelOutComeController.AssessmentFieldsWrapper payload = new PanelOutComeController.AssessmentFieldsWrapper();
        String errorMessage;
        Test.startTest();
        System.runAs(contextuser){
            try{
                payload = PanelOutComeController.getAssessment(user3.Id);
            }
            catch(Exception e){
                errorMessage = e.getMessage();
            }
        }
        Test.stopTest();

        System.assertEquals('The Last Panel has already been Scored',errorMessage);

    }

    @IsTest
    static void getAssessmentTest_NoPanel(){

        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user4 = [SELECT Id FROM Contact WHERE LastName = 'User4'];
        
        PanelOutComeController.AssessmentFieldsWrapper payload = new PanelOutComeController.AssessmentFieldsWrapper();
        String errorMessage;
        Test.startTest();
        System.runAs(contextuser){
            try{
                payload = PanelOutComeController.getAssessment(user4.Id);
            }
            catch(Exception e){
                errorMessage = e.getMessage();
            }
        }
        Test.stopTest();

        System.assertEquals('No Last Panel Found',errorMessage);

    }

    @IsTest
    static void getAssessmentLineItemTest_Round1(){
        
        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user1 = [SELECT Id FROM Contact WHERE LastName = 'User1'];
        Template__c template = [SELECT Id FROM Template__c];
        Assessment__c assessment = [SELECT Id FROM Assessment__c WHERE Associate__c = :user1.Id];

        List<Assessment_Line_Item__c> assessmentLineItems = new List<Assessment_Line_Item__c>();
        Test.startTest();
        System.runAs(contextuser){
            assessmentLineItems = PanelOutComeController.getAssessmentLineItems(user1.Id, template.Id, assessment.Id, 1.0);
        }
        Test.stopTest();

        System.assertEquals(4, assessmentLineItems.size());

    }

    @IsTest
    static void getAssessmentLineItemTest_Round1_Edit(){
        
        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user2 = [SELECT Id FROM Contact WHERE LastName = 'User2'];
        Template__c template = [SELECT Id FROM Template__c];
        Assessment__c assessment = [SELECT Id FROM Assessment__c WHERE Associate__c = :user2.Id AND Status__c = 'Complete'];

        List<Assessment_Line_Item__c> assessmentLineItems = new List<Assessment_Line_Item__c>();
        Test.startTest();
        System.runAs(contextuser){
            assessmentLineItems = PanelOutComeController.getAssessmentLineItems(user2.Id, template.Id, assessment.Id, 1.0);
        }
        Test.stopTest();

        System.assertEquals(4, assessmentLineItems.size());

        Integer repanels = 0;
        for(Assessment_Line_Item__c lineItem : assessmentLineItems){
            if(lineItem.Repanel__c == true){
                repanels++;
            }
        }
        System.assertEquals(2, repanels);

    }

    @IsTest
    static void getAssessmentLineItemTest_Round2(){
        
        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user2 = [SELECT Id FROM Contact WHERE LastName = 'User2'];
        Template__c template = [SELECT Id FROM Template__c];
        Assessment__c assessment = [SELECT Id FROM Assessment__c WHERE Associate__c = :user2.Id AND Status__c != 'Complete'];

        List<Assessment_Line_Item__c> assessmentLineItems = new List<Assessment_Line_Item__c>();
        Test.startTest();
        System.runAs(contextuser){
            assessmentLineItems = PanelOutComeController.getAssessmentLineItems(user2.Id, template.Id, assessment.Id, 2.0);
        }
        Test.stopTest();

        System.assertEquals(2, assessmentLineItems.size());

    }

    @IsTest
    static void getPreviousAssessmentTest(){
        
        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user2 = [SELECT Id FROM Contact WHERE LastName = 'User2'];

        Assessment__c assessment = new Assessment__c();

        Test.startTest();
        System.runAs(contextuser){
            assessment = PanelOutComeController.getPreviousAssessment(user2.Id, 2);
        }
        Test.stopTest();

        System.assertEquals(1, assessment.PanelRound__c);
        System.assertEquals(4, assessment.AssessmentLineItems__r.size());

    }

    @IsTest
    static void updateAssessmentTest(){

        User contextuser = [SELECT Id FROM User WHERE LastName = 'EndUser'];
        Contact user2 = [SELECT Id FROM Contact WHERE LastName = 'User2'];
        Assessment__c assessmentBeforeUpdate = [SELECT Id, OverallFeedback__c, ClientInterviewReady__c FROM Assessment__c WHERE Associate__c = :user2.Id AND Status__c = 'Complete'];
        List<Assessment_Line_Item__c> lineItemsBeforeUpdate = [SELECT Id, Repanel__c, NumericScore__c FROM Assessment_Line_Item__c WHERE Assessment__c = :assessmentBeforeUpdate.Id];
        
        Test.startTest();
        System.runAs(contextuser){
            assessmentBeforeUpdate.OverallFeedback__c = 'Pass';
            assessmentBeforeUpdate.ClientInterviewReady__c = true;
            for(Assessment_Line_Item__c lineItem : lineItemsBeforeUpdate){
                lineItem.Repanel__c = false;
                lineItem.NumericScore__c = 30;
            }
            PanelOutComeController.updateAssessment(assessmentBeforeUpdate, lineItemsBeforeUpdate);
        }
        Test.stopTest();

        Assessment__c assessmentAfterUpdate = [SELECT Id, OverallFeedback__c, ClientInterviewReady__c FROM Assessment__c WHERE Associate__c = :user2.Id AND Status__c = 'Complete'];
        List<Assessment_Line_Item__c> lineItemsAfterUpdate = [SELECT Id, Repanel__c, NumericScore__c FROM Assessment_Line_Item__c WHERE Assessment__c = :assessmentBeforeUpdate.Id];
        
        System.assertEquals('Pass', assessmentAfterUpdate.OverallFeedback__c);
        System.assertEquals(true, assessmentAfterUpdate.ClientInterviewReady__c);
        for(Assessment_Line_Item__c lineItem : lineItemsAfterUpdate){
            System.assertEquals(false,lineItem.Repanel__c);
            System.assertEquals(30,lineItem.NumericScore__c);
        }
        
    }

}