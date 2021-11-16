@isTest
public with sharing class ContactController_Test {

    @testSetup static void dataSetup() {
        WBCP_TerritoryData__c wbcpTerrData = new WBCP_TerritoryData__c(
            Name = 'United States',
            Allocable_Territory_Code__c='US',
            Destination_Region__c='North America');
        insert wbcpTerrData;
    }

    @isTest static void ContactController_Test_Global(){
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP North America');
        insert userRole;
        Profile userProfile = [select id from profile where name='System Administrator'];
        User testUser = new User(ProfileId = userProfile.Id, Username = 'testUser@wbcp2.com', Email = 'testUser2@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser2', LastName = 'LastTest2',
                                  UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Global', Country = 'United States');
        insert testUser;

        System.runAs(testUser){
            Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee').getRecordTypeId(),
            Sharing__c = 'Studio Wide'
        );
        insert account;
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee_Contact').getRecordTypeId(),
            AccountId = account.Id,
            Email = 'test@warnertest.com',
            CP_Territory__c='United States',
            CP_Region__c='North America'
        );
        insert contact;
            ContactController.getRelatedContacts(account.Id);
            //ContactController.getRelatedContactsForListView();
        }
    }

    @isTest static void ContactController_Test_Local(){
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP Local Regional Role');
        insert userRole;
        Profile userProfile = [select id from profile where name='WBCP - NAM Licensee Platform'];
        User testUser = new User(ProfileId = userProfile.Id, Username = 'testUser@wbcp.com', Email = 'testUser@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser', LastName = 'LastTest',
                                  UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Local', Country = 'United States');
        insert testUser;

        System.runAs(testUser){
            Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee').getRecordTypeId(),
            Sharing__c = 'Studio Wide'
        );
        insert account;
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee_Contact').getRecordTypeId(),
            AccountId = account.Id,
            Email = 'test@warnertest.com',
            CP_Territory__c='United States',
            CP_Region__c='North America'
        );
        insert contact;
            ContactController.getRelatedContacts(account.Id);
            ContactController.getRelatedContactsForListView();
        }
    }

    @isTest static void ContactController_Test_Regional(){
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP Local Regional Role');
        insert userRole;
        Profile userProfile = [select id from profile where name='WBCP - NAM Licensee Platform'];
        User testUser = new User(ProfileId = userProfile.Id, Username = 'testUser@wbcp3.com', Email = 'testUser3@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser3', LastName = 'LastTest3',
                                  UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Regional', Country = 'United States');
        insert testUser;

        System.runAs(testUser){
            Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee').getRecordTypeId(),
            Sharing__c = 'Studio Wide'
        );
        insert account;
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee_Contact').getRecordTypeId(),
            AccountId = account.Id,
            Email = 'test@warnertest.com',
            CP_Territory__c='United States',
            CP_Region__c='North America'
        );
        insert contact;
            ContactController.getRelatedContacts(account.Id);
            ContactController.getRelatedContactsForListView();
        }
    }
}