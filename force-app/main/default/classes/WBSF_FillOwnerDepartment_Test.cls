/**
   @Author - Cloudcreations
   @name - WBSF_FillOwnerDepartment
   @CreateDate - 31 July 2019
   @Description - Opportunity Trigger Handler for updating Owner Department Field
   @Version - 1.0
   @reference  -None
*/

@isTest
public with sharing class WBSF_FillOwnerDepartment_Test {
    @isTest static void Test_FillOwnerDepartment(){
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'WBSF Studio - Standard User' LIMIT 1];
        String roleName = 'My Test Role';
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = roleName);
        insert userRole;
        User user = new User(
            ProfileId = profile.Id,
            Username = 'testUser@wbstudio.dev',
            Email = 'testUser@wbstudio.dev',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'tuser',
            LastName = 'Tester',
            UserRoleId = userRole.Id
        );
        insert user;
        Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBSF_Studio_Individual_Contacts').getRecordTypeId()
        );
        Opportunity dealTest = new Opportunity(
            Name = 'dealTest', 
            StageName = 'Opportunity',
            CloseDate = Date.today().addDays(30),
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('WBSF_Studio_Deal').getRecordTypeId()
        );
        System.runAs(user){
	        insert account;
	        Test.startTest();
            insert dealTest;
            dealTest.AccountId = account.Id;
            update dealTest;
	        Test.stopTest();
        }
        System.assertEquals(roleName, [SELECT Owner_Role_Department__c FROM Opportunity WHERE Id = :dealTest.Id].Owner_Role_Department__c);
    }
}