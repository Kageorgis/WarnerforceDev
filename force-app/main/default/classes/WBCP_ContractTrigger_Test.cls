/******* 
WBCP_AccountTriggerHandler_Test
Creation Date- 22 July 2021
Description- This class is to do code coverage for WBCP_ContractTrigger
Author- Nilesh Jha
*******/
@isTest
public class WBCP_ContractTrigger_Test {
    static testMethod void Test()
    {
        Test.startTest();
        string RecTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        String licenseeRecTypeId = CP_ProductUtility.getRecordTypeId(CP_Contract__c.getSobjectType(),'WBCP Contracts'); 
        
        Account acct= new Account(Name='test Account');
        acct.RecordTypeId=RecTypeid;
        acct.cp_Licensee_Code__c='10001';
        insert acct;
        
        CP_Contract__c contract = new CP_Contract__c(Name='TEST',Contract_No__c='10001');
        contract.RecordTypeId=licenseeRecTypeId;
        insert contract;
        
        Account acct1= new Account(Name='test Account');
        acct1.RecordTypeId=RecTypeid;
        acct1.cp_Licensee_Code__c='10002';
        insert acct1; 
        
        CP_Contract__c contract1 = new CP_Contract__c(id=contract.id,Contract_No__c='10002');
        update contract1;
        Test.stopTest(); 
        
    }
}