public class PanelOutComeController {
    @AuraEnabled
    public static AssessmentFieldsWrapper getAssessment(Id recordId) {
        Contact contactRecord = [
            SELECT
                Id,
                Name,
                LastPlacement__c,
                LastTrainingClass__c,
                LastTrainingClass__r.Training__r.TrainingTrack__r.DefaultTemplate__c,
                Last__r.Panel__c
            FROM contact
            WHERE Id = :recordId
        ];

        List<Assessment__c> lastAssessmentList = new List<Assessment__c>(
            [
                SELECT
                    Id,
                    Associate__c,
                    Placement__c,
                    AssignedTo__c,
                    PanelRound__c,
                    Template__c,
                    Duration__c,
                    RecordingLink__c,
                    RecordingConsent__c,
                    Status__c,
                    Comments__c,
                    Mode__c,
                    Date__c,
                    Stablity__c,
                    TrainingAssignment__c,
                    OverallFeedback__c,
                    CreatedDate,
                    ClientInterviewReady__c,
                    RecordTypeId,
                    (SELECT Id FROM AssessmentLineItems__r)
                FROM Assessment__c
                WHERE Id = :contactRecord.Last__r.Panel__c
            ]
        );

        if (lastAssessmentList.isEmpty()) {
            throw new PanelOutcomeException('No Last Panel Found');
        }

        Assessment__c assessmentRecord = lastAssessmentList[0];

        if (!assessmentRecord.AssessmentLineItems__r.isEmpty()) {
            if (assessmentRecord.Date__c.date() != Date.today()) {
                throw new PanelOutcomeException('The Last Panel has already been Scored');
            }
        }

        return new AssessmentFieldsWrapper(
            assessmentRecord,
            getModePickListValues(),
            getStablityPickListValues(),
            getOverAllFeedBackePickListValues()
        );
    }

    @AuraEnabled
    public static List<PicklistEntry> getOverAllFeedBackePickListValues() {
        List<Schema.PicklistEntry> options = Assessment__c.OverallFeedback__c.getDescribe().getPicklistValues();
        List<PicklistEntry> finalOptions = new List<PicklistEntry>();
        for (Schema.PicklistEntry option : options) {
            if (option.isActive()) {
                finalOptions.add(new PicklistEntry(option));
            }
        }
        return finalOptions;
    }

    @AuraEnabled
    public static List<PicklistEntry> getModePickListValues() {
        List<Schema.PicklistEntry> options = Assessment__c.Mode__c.getDescribe().getPicklistValues();
        List<PicklistEntry> finalOptions = new List<PicklistEntry>();
        for (Schema.PicklistEntry option : options) {
            if (option.isActive()) {
                finalOptions.add(new PicklistEntry(option));
            }
        }
        return finalOptions;
    }

    public static List<PicklistEntry> getStablityPickListValues() {
        List<Schema.PicklistEntry> options = Assessment__c.Stablity__c.getDescribe().getPicklistValues();
        List<PicklistEntry> finalOptions = new List<PicklistEntry>();
        for (Schema.PicklistEntry option : options) {
            if (option.isActive()) {
                finalOptions.add(new PicklistEntry(option));
            }
        }
        return finalOptions;
    }

    /*public static Integer getPanelRoundValue(Contact con) {
        integer panelRoundValue = 1;
        list<Assessment__c> getAllAssessmentRecords = getAllAssesments(con.Id);
        //We already did the repanel, so clear this.
        if (!getAllAssessmentRecords.isEmpty() && getAllAssessmentRecords[0].OverallFeedback__c != 'Repanel') {
            getAllAssessmentRecords.clear();
        }
        if (getAllAssessmentRecords.size() != 0 && con.LastPlacement__c == getAllAssessmentRecords[0].Placement__c) {
            panelRoundValue = Integer.valueOf(getAllAssessmentRecords[0].PanelRound__c + 1);
        }
        return panelRoundValue;
    }*/

    public static Assessment__c getPreviousAssessment(Id contactId, Decimal panelRound) {
        Id assessmentPanelRecordId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByDeveloperName().get('Panel').getRecordTypeId();
        Decimal previousPanelRound = panelRound - 1;
        List<Assessment__c> getPreviousAssessmentList = new List<Assessment__c>(
            [
                SELECT
                    Id,
                    Placement__c,
                    PanelRound__c,
                    OverallFeedback__c,
                    (
                        SELECT Id, TemplateLineItem__c, Name, ActualScore__c, MaxScore__c, Repanel__c, Comment__c, NumericScore__c
                        FROM AssessmentLineItems__r
                    )
                FROM Assessment__c
                WHERE Associate__c = :contactId AND RecordTypeId = :assessmentPanelRecordId AND PanelRound__c = :previousPanelRound
                ORDER BY createdDate DESC
                LIMIT 1
            ]
        );

        return getPreviousAssessmentList[0];
    }

    @AuraEnabled
    public static List<Assessment_Line_Item__c> getAssessmentLineItems(Id contactId, Id templateId, Id assessmentId, Decimal panelRound) {
        Id assessmentPanelRecordId = Schema.SObjectType.Assessment_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Panel').getRecordTypeId();
        List<Assessment_Line_Item__c> assessmentLineItems = new List<Assessment_Line_Item__c>(
            [
                SELECT Id, TemplateLineItem__c, Name, ActualScore__c, MaxScore__c, Repanel__c, Comment__c, NumericScore__c
                FROM Assessment_Line_Item__c
                WHERE Assessment__c = :assessmentId
            ]
        );

        if (assessmentLineItems.isEmpty()) {
            if (panelRound > 1) {
                Assessment__c previousAssessment = getPreviousAssessment(contactId, panelRound);
                for (Assessment_Line_Item__c currentLineItem : previousAssessment.AssessmentLineItems__r) {
                    if (currentLineItem.Repanel__c == true) {
                        assessmentLineItems.add(
                            new Assessment_Line_Item__c(
                                Name = currentLineItem.Name,
                                Assessment__c = assessmentId,
                                TemplateLineItem__c = currentLineItem.TemplateLineItem__c,
                                NumericScore__c = null,
                                MaxScore__c = currentLineItem.MaxScore__c
                            )
                        );
                    }
                }
            } else {
                List<TemplateLineItem__c> templateLineItems = new List<TemplateLineItem__c>(
                    [SELECT Id, Template__c, Name, MaxScore__c FROM TemplateLineItem__c WHERE Template__c = :templateId]
                );
                for (TemplateLineItem__c currentLineItem : templateLineItems) {
                    assessmentLineItems.add(
                        new Assessment_Line_Item__c(
                            Name = currentLineItem.Name,
                            Assessment__c = assessmentId,
                            TemplateLineItem__c = currentLineItem.Id,
                            NumericScore__c = null,
                            MaxScore__c = currentLineItem.MaxScore__c
                        )
                    );
                }
            }
        }

        return assessmentLineItems;
    }

    @AuraEnabled
    public static void updateAssessment(Assessment__c assessment, List<Assessment_Line_Item__c> assessmentLineItems) {
        update assessment;
        upsert assessmentLineItems;
    }

    public class AssessmentFieldsWrapper {
        @AuraEnabled
        public Assessment__c assessment;
        @AuraEnabled
        public List<PicklistEntry> modePicklistEntryOptions;
        @AuraEnabled
        public List<PicklistEntry> StablityPicklistEntryOptions;
        @AuraEnabled
        public List<PicklistEntry> overAllFeedBackPicklistEntryOptions;

        public AssessmentFieldsWrapper(){}
        
        public AssessmentFieldsWrapper(
            Assessment__c assessment,
            List<PicklistEntry> modePicklistEntryOptions,
            List<PicklistEntry> StablityPicklistEntryOptions,
            List<PicklistEntry> overAllFeedBackPicklistEntryOptions
        ) {
            this.assessment = assessment;
            this.modePicklistEntryOptions = modePicklistEntryOptions;
            this.StablityPicklistEntryOptions = StablityPicklistEntryOptions;
            this.overAllFeedBackPicklistEntryOptions = overAllFeedBackPicklistEntryOptions;
        }
    }

    public class PanelOutcomeException extends Exception{}
}