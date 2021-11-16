@IsTest
private class Test_CloneDealAndRelatedLists {
    static testMethod void validatedClone() {
        Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBSF_Studio_Individual_Contacts').getRecordTypeId()
        );
        insert account;
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBSF_Studio_Contact').getRecordTypeId(),
            AccountId = account.Id,
            Email = 'test@warnertest.com'
        );
        insert contact;
        Opportunity dealTest = new Opportunity(
            Name = 'dealTest', 
            AccountId = account.Id,
            CloseDate = Date.today(),
            StageName = 'Opportunity',
            Probability = 25,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('WBSF_Studio_Deal').getRecordTypeId()
        );
        insert dealTest;
        WBSF_Related_Contacts__c relatedContacts = new WBSF_Related_Contacts__c(
            WBSF_Deal__c = dealTest.Id,
            WBSF_Contact__c = contact.Id,
            WBSF_Role__c = 'Art Director',
            Relationship_Strength__c = 'Medium',
            RecordTypeId = WBSF_Related_Contacts__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Contact_to_Deal').getRecordTypeId()
        );
        insert relatedContacts;
        WBSF_Related_Company__c relatedCompany = new WBSF_Related_Company__c(
            WBSF_Deal__c = dealTest.Id,
            WBSF_Company__c = account.Id,
            WBSF_Role__c = 'Associate'
        );
        insert relatedCompany;
        Opportunity dealTestToClone = CloneDealAndRelatedLists.getDeal(dealTest.Id);
        Id newDealTestToCloneId = Id.valueOf(CloneDealAndRelatedLists.cloneDealFromRecord(dealTestToClone.Id,dealTestToClone.Name));
        System.assertNotEquals(null, newDealTestToCloneId);
    }
}