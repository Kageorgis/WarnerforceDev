/**
 * @Author Cognizant
 * @name CRM_ProcessDealProductPlannedCutOffTest
 * @CreateDate 4-1-18
 * @Description Test class for CRM_ProcessDealProductPlannedCutOffBatch
 * @Version <1.0>
 */


@isTest
public with sharing class CRM_ProcessDealProductPlannedCutOffTest {
    
    @testsetup  
    public static void createTestDataForBatchNotificationStatus(){ 
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
        insert userList;
        System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c ].size());
    }
    
    private static testmethod void NRCutOffDate_test(){        
     //Create Products
      List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
      
      //Loops over Product list
      for (Product2 objProduct : lstProduct){
          objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
          objProduct.Street_Date__c = System.today() + 10;    
      }
      insert lstProduct;
      lstProduct = [Select Id, Street_Date__c, Cut_Off_Period_Weeks__c From Product2 Where Id = :lstProduct[0].Id];
      
      List<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, false);
      
      //Loops over Account list
      for (Account acct : lstParentAccounts){
          acct.Sales_Organization__c = '6014';         
      }
      insert lstParentAccounts;
      
      List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstParentAccounts, 1, false);  
      //Loops over Deal list
      for (Opportunity deal : lstDeals){
          deal.No_Demand__c = true;         
      }
      insert lstDeals;          
                    
      List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
      List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.Start_Date__c = System.today() - 100;
            pbep.end_Date__c = System.today() + 100;
        }
        insert lstPBEP;
      List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);  
      
      //Loops over Deal Product list
      for (OpportunityLineItem objDealProduct : lstDealProducts){
          objDealProduct.Quantity = 5; 
          objDealProduct.initial_Quantity__c = 5; 
      }
      insert lstDealProducts;
      
      Test.startTest();
      Id batchJobId = Database.executeBatch(new CRM_ProcessDealProductPlannedCutOffBatch());
      Test.stopTest();
      
      System.assertEquals(5, [Select Planned_Quantity_at_Cut_Off_Date__c From OpportunityLineItem Where Id = :lstDealProducts[0].Id].Planned_Quantity_at_Cut_Off_Date__c);
    } 
    private static testmethod void testScenarioForNRCutOffDateChangedToFutureDate() {
    //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
       //update the Street_Date__c
        for(Product2 objProduct : lstProduct){
            objProduct.Street_Date__c = System.today() + 45;
        }
        insert lstProduct;
        List<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, false);
        for(Account acc : lstParentAccounts){
            acc.Sales_Organization__c = '6014';
        }      
        insert lstParentAccounts;
        
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstParentAccounts, 1, true);
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
            for (Pricebook_Entry_Period__c pbep : lstPBEP) {
                pbep.Start_Date__c = System.today() - 100;
                pbep.end_Date__c = System.today() + 100;
            }
            insert lstPBEP;
        List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);  
        for(OpportunityLineItem oli : lstDealProducts){
            oli.Is_Planned_Cut_Off_Qauntity_Updated__c = true;
        }
        insert lstDealProducts;
        
        System.debug('Cut off period  --> '+ [select NR_Cut_Off_Date__c from OpportunityLineItem where ID IN :lstDealProducts].NR_Cut_Off_Date__c );
        System.debug('NR  --> '+ [select NR__c from OpportunityLineItem where ID IN :lstDealProducts].NR__c );
        system.assertEquals(true, lstDealProducts[0].Is_Planned_Cut_Off_Qauntity_Updated__c);
        Test.startTest();
        Database.executeBatch(new CRM_ProcessDealProductPlannedCutOffBatch());
        Test.stopTest();
        
        System.assertEquals(false, [Select Is_Planned_Cut_Off_Qauntity_Updated__c From OpportunityLineItem Where Id = :lstDealProducts[0].Id].Is_Planned_Cut_Off_Qauntity_Updated__c);
   
    }
    
    public class TestException extends Exception {
    }
       
}