public with sharing class AssessmentsSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Assessment__c.Id,
            Assessment__c.RecordTypeId,
            Assessment__c.AnnualReviewStatus__c,
            Assessment__c.AssessmentName__c,
            Assessment__c.Associate__c,
            Assessment__c.Comments__c,
            Assessment__c.Date__c,
            Assessment__c.InterventionName__c,
            Assessment__c.Mood__c,
            Assessment__c.PanelName__c,
            Assessment__c.PayIncreaseNotes__c,
            Assessment__c.PayIncreaseRequestedDate__c,
            Assessment__c.PayIncreaseStatus__c,
            Assessment__c.QCName__c,
            Assessment__c.Training__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Assessment__c.SObjectType;
    }

    public Assessment__c selectById(Id assessmentId) {
        String query = String.format('select {0},Associate__r.Name,AssignedTo__r.Name  from {1} where Id = :assessmentId limit 1',
                                new List<String> {
                                    getFieldListString(),
                                    getSObjectName()
                                });

        System.debug('===AssessmentQuery:'+query);
        return (Assessment__c) Database.query(query);
    }
}