/**
   @Author - Cloudcreations
   @name - WBSF_CalculateTotalWholesaleCost_Test
   @CreateDate - 01 October 2019
   @Description - Test Class for testing WBSF_CalculateTotalWholesaleCost class
   @Version - 1.0
   @reference  -None
*/
@isTest
public without sharing class WBSF_CalculateTotalWholesaleCost_Test {
    @isTest static void Test_CalculateTotalWholesaleCost(){
        Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ELLEN_Brand').getRecordTypeId()
        );
        insert account;
        Opportunity dealTest = new Opportunity(
            Name = 'dealTest', 
            StageName = 'Pitched',
            CloseDate = Date.today().addDays(30),
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('BE_KIND_Box_Deal').getRecordTypeId()
        );
        insert dealTest;
        Product2 productTest = new Product2(
            Name = 'productTest', 
            Product_Category__c = 'BE KIND. Box',
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('TPX_Products').getRecordTypeId()
        );
        insert productTest;        
        PricebookEntry pbeTest = new PricebookEntry(
            Product2Id = productTest.Id, 
            Pricebook2Id = Test.getStandardPricebookId(), 
            isActive = true,
            CurrencyIsoCode = 'USD',
            UnitPrice = 10
        );
        insert pbeTest;
        OpportunityLineItem oliTest = new OpportunityLineItem(
            OpportunityId = dealTest.id, 
            PricebookEntryId = pbeTest.Id, 
            UnitPrice = 10, 
            Quantity = 1
        );
        Test.startTest();
        insert oliTest;
        oliTest.Wholesale_unit_cost__c = 10;
        update oliTest;
        Test.stopTest();
        System.assertEquals(oliTest.Wholesale_unit_cost__c * oliTest.Quantity, [Select Total_Wholesale_Cost__c From OpportunityLineItem Where Id =:oliTest.Id].Total_Wholesale_Cost__c);
    }
}