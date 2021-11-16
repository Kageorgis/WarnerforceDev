/******* 
WBCP_ContactTriggerHandler_Test
Creation Date- 14 May 2021
Description- This class is to do code coverage for WBCP_ContactTriggerHandler
Author- Nilesh Jha
*******/

@isTest(SeeAllData=true)
public class WBCP_ContactTriggerHandler_Test {
    static testMethod void ContactBeforeTriggerTest()
    {
        Test.startTest();
        Account acct= new Account(Name='test Account');
        insert acct;
        Contact con = new Contact(AccountId=acct.Id,LastName='test Lastname',CP_Territory__c='All');
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBCP Licensee Contact').getRecordTypeId();
        insert con;
        Test.stopTest(); 
    }
  
    static testMethod void ContactAfterTriggerTest()
    {
        Test.startTest();
        Account acct1= new Account(Name='test Account1');
        insert acct1;
        Contact objCon = new Contact(AccountId=acct1.Id,LastName='test Lastname1',CP_Territory__c='All');
        objCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBCP Licensee Contact').getRecordTypeId();
        insert objCon;
        Contact updateContact = [Select id,LastName FROM contact where id =:objCon.id];
        updateContact.LastName='test LastnameXXX';
        update updateContact;
        Test.stopTest(); 
    }
    
    static testMethod void multiselectTerritoryTriggerTest()
    {
        Test.startTest();
        Account acct= new Account(Name='test Account');
        insert acct;
        Contact con = new Contact(AccountId=acct.Id,LastName='test Lastname',CP_Territory__c='Italy;Poland;United States;Canada;United Kingdom');
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBCP Licensee Contact').getRecordTypeId();
        insert con;
        Test.stopTest(); 
    }
    
    static testMethod void ContactAfterTriggerSelectedTriggerTest()
    {
        Test.startTest();
        Account acct1= new Account(Name='test Account1');
        insert acct1;
        Contact objCon = new Contact(AccountId=acct1.Id,LastName='test Lastname1',CP_Territory__c='All');
        objCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBCP Licensee Contact').getRecordTypeId();
        insert objCon;
        Contact updateContact = [Select id,LastName FROM contact where id =:objCon.id];
        updateContact.LastName='test LastnameXXX1';
        updateContact.CP_Territory__c='Italy;Poland;United States;Canada;United Kingdom';
        update updateContact;
        Test.stopTest(); 
    }
    
    static testMethod void ContactDeleteTriggerTest()
    {
        Test.startTest();
        Account acct= new Account(Name='test Account');
        insert acct;
        Contact con = new Contact(AccountId=acct.Id,LastName='test Lastname',CP_Territory__c='All');
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBCP Licensee Contact').getRecordTypeId();
        insert con;
        delete con;
        Test.stopTest(); 
    }
}