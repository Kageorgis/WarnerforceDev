@isTest
public class Test_DealsAndRelatedObjectsController {
    
    @isTest static void listViews() {
        Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBSF_Studio_Individual_Contacts').getRecordTypeId(),
            Sharing__c = 'Studio Wide'
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
        List<DealsWrapper.View> listViews = DealsAndRelatedObjectsController.getListViews();
        Boolean result = true;
        if(listViews.size() == 0) result = false;
        System.assertEquals(true, result, 'listViews not loaded');
        DealsWrapper.View contactView = DealsAndRelatedObjectsController.insertView('contactView','Related Contacts', 'Opportunity.WBSF_Project_Phase__c');
        if(contactView == null) result = false;
        System.assertEquals(true, result, 'contactView not inserted');
        DealsWrapper.View companyView = DealsAndRelatedObjectsController.insertView('companyView','Related Companies', 'Opportunity.WBSF_Project_Phase__c');
        DealsAndRelatedObjectsController.deleteView(companyView.value);
        DealsWrapper.Table testTable = new DealsWrapper.Table();
        Id viewId = null;
        for(DealsWrapper.View view : listViews) {
            DealsWrapper.Table table = DealsAndRelatedObjectsController.getView(view.viewId, view.child);
            testTable = table;
            viewId = view.viewId;
            if(table.references.size() == 0) result = false;
            //System.assertEquals(true, result, 'table not loaded for '+view.child);
        }
        String dealHided = DealsAndRelatedObjectsController.hideDeal(String.valueOf(dealTest.Id), dealTest.Name, listViews.get(0).viewId);
        String columnsList = '[';
        for(DealsWrapper.Column column : testTable.columns) {
            columnsList += '{"apiName":"'+column.apiName+'","columnId":"'+column.columnId+'","fieldName":"'+column.fieldName+'","fieldType":"'+column.fieldType+'","isChild":'+column.isChild+',"isRestricted":'+column.isRestricted+',"isSelected":true,"isSortable":'+column.isSortable+',"isVisible":'+column.isVisible+',"label":"'+column.label+'","objectLabel":"'+column.objectLabel+'","originalFieldName":"'+column.originalFieldName+'","width":'+column.width+'},';
        }
        columnsList = columnsList.substring(0,columnsList.length()-1)+']';
        String filtersList = '[';
        for(DealsWrapper.Filter filter : testTable.filters) {
            filtersList += '{"apiName":"'+filter.apiName+'","fieldType":"'+filter.fieldType+'","filterId":"'+filter.filterId+'","isActive":'+filter.isActive+',"isRestricted":'+filter.isRestricted+',"label":"'+filter.label+'","operator":"'+filter.operator+'","operatorLabel":"'+filter.operatorLabel+'","value":"'+filter.value+'"},';
        }
        filtersList = filtersList.substring(0,filtersList.length()-1)+']';
        List<sObject> dataUpdated = DealsAndRelatedObjectsController.updateData('Related Contacts',columnsList, filtersList);
        if(dataUpdated.size() == 0) result = false;
        //System.assertEquals(true, result, 'data not updated');
        String updateColumnsList = '[';
        for(DealsWrapper.Column column : testTable.columns) {
            if(column.isVisible) {
                updateColumnsList += '{"apiName":"'+column.apiName+'","columnId":"'+column.columnId+'","fieldName":"'+column.fieldName+'","fieldType":"'+column.fieldType+'","isChild":'+column.isChild+',"isRestricted":'+column.isRestricted+',"isSelected":true,"isSortable":'+column.isSortable+',"isVisible":'+column.isVisible+',"label":"'+column.label+'","objectLabel":"'+column.objectLabel+'","originalFieldName":"'+column.originalFieldName+'","width":'+column.width+'},';
            }
        }
        updateColumnsList = updateColumnsList.substring(0,updateColumnsList.length()-1)+']';
        DealsWrapper.Table tableNewColumns = DealsAndRelatedObjectsController.updateColumns(viewId,'Related Contacts','Opportunity.WBSF_Project_Phase__c',updateColumnsList, filtersList);
        if(tableNewColumns.columns.size() == 0) result = false;
        //System.assertEquals(true, result, 'table not updated for columns');
        DealsWrapper.Table tableNewFilters = DealsAndRelatedObjectsController.updateFilters(viewId,'Related Contacts',columnsList, filtersList);
        if(tableNewFilters.filters.size() == 0) result = false;
        //System.assertEquals(true, result, 'table not updated for filters');
    }
    
    @isTest static void followContacts() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'WBSF Studio - Standard User' LIMIT 1];
        User user1 = new User(
            ProfileId = profile.Id,
            Username = 'testUser1@wbstudio.dev',
            Email = 'testUser1@wbstudio.dev',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'tuser1',
            LastName = 'Tester 1'
        );
        insert user1;
        User user2 = new User(
            ProfileId = profile.Id,
            Username = 'testUser2@wbstudio.dev',
            Email = 'testUser2@wbstudio.dev',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'tuser2',
            LastName = 'Tester 2'
        );
        insert user2;
        Integer followCount = DealsAndRelatedObjectsController.followContacts(String.valueOf(user1.Id)+';'+String.valueOf(user2.Id));
    }
    
    @isTest static void cloneDeal() {
        Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBSF_Studio_Individual_Contacts').getRecordTypeId(),
            Sharing__c = 'Studio Wide'
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
        Opportunity opportunity = DealsAndRelatedObjectsController.getDeal(dealTest.Id);
        Id dealTestIdCloned = Id.valueOf(DealsAndRelatedObjectsController.cloneDealFromRecord(opportunity.Id,opportunity.Name));
        String dealTestNameCloned = DealsAndRelatedObjectsController.cloneDeal(opportunity.Id,opportunity.Name);
    }
}