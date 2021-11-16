/******* 
WBCP_ContractTerritoryTrigger_Test
Creation Date- 22 July 2021
Description- This class is to do code coverage for WBCP_ContractTerritoryTrigger
Author- Nilesh Jha
*******/
@isTest
public class WBCP_ContractTerritoryTrigger_Test {
 static testMethod void ContractTerritoryTest(){
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
     
        
         WBCP_Country__c countryRecord = (WBCP_Country__c)TestDataFactory.createSObject('WBCP_Country__c',new Map<String,object>{
        	'Name' => 'United States','Territory_Code__c'=>'T01'
        });
        
         Contract_Territory__c ct = new Contract_Territory__c(Contract_No__c='10001',Territory_Code__c='T01'); 
          insert ct;
     
     Contract_Territory__c ct2 = new Contract_Territory__c(Contract_No__c='10001',Territory_Code__c='T011'); 
          insert ct2;
     ct2.Contract_No__c = null;
     update ct2;
        Test.stopTest(); 
    }
    
    static testMethod void InvalidContractContractTerritoryTest(){
        Test.startTest();
        string RecTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        String licenseeRecTypeId = CP_ProductUtility.getRecordTypeId(CP_Contract__c.getSobjectType(),'WBCP Contracts'); 
        
        Account acct= new Account(Name='test Account');
        acct.RecordTypeId=RecTypeid;
        acct.cp_Licensee_Code__c='10001';
        insert acct;
        
        CP_Contract__c contract = new CP_Contract__c(Name='TEST',Contract_No__c='003611');
        contract.RecordTypeId=licenseeRecTypeId;
        insert contract;
     
        
         WBCP_Country__c countryRecord = (WBCP_Country__c)TestDataFactory.createSObject('WBCP_Country__c',new Map<String,object>{
        	'Name' => 'United States','Territory_Code__c'=>'T01'
        });
     
        Contract_Territory__c ct = new Contract_Territory__c(Contract_No__c='003611',Territory_Code__c='T111'); 
        insert ct;
        Test.stopTest(); 
    }
}