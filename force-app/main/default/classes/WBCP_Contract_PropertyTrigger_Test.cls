/******* 
WBCP_Contract_PropertyTrigger_Test
Creation Date- 22 July 2021
Description- This class is to do code coverage for WBCP_Contract_PropertyTrigger
Author- Nilesh Jha
*******/
@isTest
public class WBCP_Contract_PropertyTrigger_Test {
    static testMethod void PropertyTest(){
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
        
        Contract_Property__c contrctPro = new Contract_Property__c(Contract_No__c='10001',Property__c='P001');
        insert contrctPro;
        
        Test.stopTest(); 
    }
}