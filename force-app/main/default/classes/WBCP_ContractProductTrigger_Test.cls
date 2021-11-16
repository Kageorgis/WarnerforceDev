/******* 
WBCP_ContractProductTrigger_Test
Creation Date- 22 July 2021
Description- This class is to do code coverage for WBCP_ContractProductTrigger
Author- Nilesh Jha
*******/
@isTest
public class WBCP_ContractProductTrigger_Test {
    static testMethod void ProductTest(){
        Test.startTest();
        string RecTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        String licenseeRecTypeId = CP_ProductUtility.getRecordTypeId(CP_Contract__c.getSobjectType(),'WBCP Contracts'); 
        Id retRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
        
        Account acct= new Account(Name='test Account');
        acct.RecordTypeId=RecTypeid;
        acct.cp_Licensee_Code__c='10001';
        insert acct;
        
         Account retailerAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
        	'RecordTypeId' => retRecTypeid
        });
        
        
        
        CP_Contract__c contract = new CP_Contract__c(Name='TEST',Contract_No__c='10001');
        contract.RecordTypeId=licenseeRecTypeId;
        insert contract;
        
        WBCP_Country__c countryRecord = (WBCP_Country__c)TestDataFactory.createSObject('WBCP_Country__c',new Map<String,object>{
            'Name' => 'United States'
                });
        
        Property__c propRec = (Property__c)TestDataFactory.createSObject('Property__c',new Map<String,object>{
            'Name' => 'Justice League Core',
                'cp_Property_Code__c' => '000927'
                });
        
        WBCP_Master_Product__c prodRec =  (WBCP_Master_Product__c)TestDataFactory.createSObject('WBCP_Master_Product__c', new Map<String,Object>{
            	'Detail_Type_Link_Active__c' => True,
                'LOB_Standard__c' => 'LObStand',
                'LOB_Type_Standard__c' => 'DataLob',
                'North_America_Director__c' => 'Paula Sheron',
                'Product_Category_Code_Standard__c' => 'Product_Category_Code_Standard2',
                'Product_Category_Standard__c' => 'Product_Category_Standard2',
                'Product_Detail_Code__c' =>'1014',
                'Product_Type_Code_Standard__c' => 'Outdoor Toy & Sports',
                'Prod_Detail_Active__c' => True,
                'Product_Detail__c' => 'PCCode',
                'Product_Type_Standard__c' => 'std'
                }); 
        
             Contract_Product__c contractProduct = new Contract_Product__c(Contract_No__c='10001',Product_Detail__c='1014');
             insert contractProduct;
        
        Test.stopTest(); 
    }
}