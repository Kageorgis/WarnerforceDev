/**
   @Author Cognizant
   @name CRM_AutoTargetPBEPInsertBatch_Test
   @CreateDate 20 Feb 2016
   @Description Test class for CRM_AutoTargetCreationPBEPInsertBatch
   @Version <1.0>
  */

@isTest(SeeAllData=false)
public with sharing class CRM_AutoTargetPBEPInsertBatch_Test {
     /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    */
    private static void createTestData() {
    	//Accout List
    	List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(10, false);
        for(integer i=0;i<2;i++){
        	lstAccounts[i].Pending_Account_Plan_Creation__c = true;
        }
        insert lstAccounts;
        System.assertEquals(10,[Select count() From Account]);
        
        //Product Group List
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1,[Select count() From Product_Group__c]);
        
        //Product List
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp,10,true);
        System.assertEquals(10,[Select count() From Product2]);
        
        //PricebookEntry List
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,true);
        System.assertEquals(10,[Select count() From PricebookEntry]);
        
        //Pricebook Entry Period List
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct,1,false);
        for(Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod){
        	pbep.Pending_Account_Plan_Creation__c = true;
        }
        insert lstPriceBookEntryPeriod;
        System.assertEquals(10,[Select count() From Pricebook_Entry_Period__c]);
    }
    
    /**
    *  Test 1
    *  @name test_CRM_AutoTargetPBEPInsertBatch
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void test_CRM_AutoTargetPBEPInsertBatch(){
    	createTestData();
    	
    	//Account List which have Pending_Account_Plan_Creation__c = false
    	system.assertEquals(8,[Select count() From Account where Pending_Account_Plan_Creation__c = false]);
    	
    	Test.startTest();
    		CRM_AutoTargetCreationPBEPInsertBatch batchInstace = new CRM_AutoTargetCreationPBEPInsertBatch();
    		Database.executeBatch(batchInstace,10);
    	Test.stopTest();
    	
    	//Assert number of updated account
    	system.assertEquals(10,[Select count() From Account where Pending_Account_Plan_Creation__c = true]);
    }
}