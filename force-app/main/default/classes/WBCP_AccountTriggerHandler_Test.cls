/******* 
WBCP_AccountTriggerHandler_Test
Creation Date- 14 May 2021
Description- This class is to do code coverage for WBCP_AccountTriggerHandler
Author- Nilesh Jha
*******/
@isTest(SeeAllData=true)
public class WBCP_AccountTriggerHandler_Test {
    static testMethod void WbcpLicenseeTest()
    {
        Test.startTest();
        string RecTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Account acct= new Account(Name='test Account');
        acct.RecordTypeId=RecTypeid;
        insert acct;
        
        Account updateAcct = [Select id ,name,cp_Territories__c from Account where id=:acct.Id];
        updateAcct.cp_Territories__c='United States';
        updateAcct.Sub_Category__c='Accessories Other;Headwear / Cold Weather Acc.;Headwear / Cold Weather Acc.';
        update updateAcct;
        Test.stopTest(); 
    }
    
    static testMethod void WbcpLicenseeChangeTerritoriesTest()
    {
        Test.startTest();
        string RecTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Account acct= new Account(Name='test Account');
        acct.RecordTypeId=RecTypeid;
        insert acct;
        
        Account updateAcct = [Select id ,name,cp_Territories__c from Account where id=:acct.Id];
        updateAcct.cp_Territories__c='United States';
        updateAcct.Sub_Category__c='Accessories Other;Headwear / Cold Weather Acc.;Headwear / Cold Weather Acc.';
        update updateAcct;
        
        Account updateAcctTwo = [Select id ,name,cp_Territories__c from Account where id=:acct.Id];
        updateAcctTwo.cp_Territories__c='Germany'; 
        updateAcctTwo.Sub_Category__c='Plush';
        update updateAcctTwo;
        Test.stopTest(); 
    }
    
    static testMethod void WbcpRetailerTest()
    {
        Test.startTest();
        string RecTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
        Account acct= new Account(Name='test Account1',Sub_Category__c='Wipes');
        acct.RecordTypeId=RecTypeid;
        insert acct;
        
        Account updateAcct = [Select id ,name,cp_Territories__c from Account where id=:acct.Id];
        updateAcct.cp_Territories__c='United States';
        updateAcct.Sub_Category__c='Accessories Other;Headwear / Cold Weather Acc.;Headwear / Cold Weather Acc.';
        update updateAcct;
        Test.stopTest(); 
    }
}