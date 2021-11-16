/**
   @Author Vaibhav Trivedi
   @name CRM_BatchDealProductRollup_Test
   @CreateDate 29 Feb 2016
   @Description Test class for CRM_BatchDealProductRollup
   @Version <1.0>
   @reference Requirement no 53
  */
@isTest(seeAllData = false)
private class CRM_BatchDealProductRollup_Test{
    /**
    *create custom setting to bypass the validation rule
    */
    private static void createCustomSetting(){
        CRM_Default_Configuration__c cs = new CRM_Default_Configuration__c();
        cs.Informatica_User_Id__c = UserInfo.getUserId().subString(0, 15);
        insert cs;
        System.assertNotEquals(null,cs);
    }    
    /**
     *  create Test Data For Single Schedule On Deal Product
     *  @name createTestDataForSingleSchedules
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    private static void createTestDataForSingleSchedules() {
        createCustomSetting();
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_ACTUALS;
        List<Account> lstAccounts = CRM_TestDataTemplate.createAccounts(1, true);
        List<Product_Group__c> lstProductGroup = CRM_TestDataTemplate.createProductGroups(1, true);
        List<Product2> lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, date.today(), date.today(), 1, true);
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataTemplate.createPriceBookEntries(lstProducts, 1, true);
        CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts,1,true);
        List<Opportunity> lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstAccounts, 
                                        CRM_AppConstants.OPPORTUNITY_STAGE_Actuals_Sales, date.today() -60, date.today() + 60, dealRecordTypeId, 1, false);
        lstDeals[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_POS_Actuals;
        lstDeals[0].Promo_Start_Date__c = date.today() + 1;
        lstDeals[0].Promo_End_Date__c = date.today() + 61;
        insert lstDeals;
        List<OpportunityLineItem> lstDealProducts =  CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntry, lstDeals, 10, 1, true);
        List<OpportunityLineItemSchedule> lstSchedules = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts, 10, 
                                                            CRM_AppConstants.SCHEDULE_TYPE_BOTH, date.today() + 15, 900, 1, true);
    }
    
   /**
     *  Test Method For Single Schedule On Deal Product
     *  @name TestScenario1
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    private static testMethod void TestScenario1() {
        createTestDataForSingleSchedules();
        CRM_BatchDealProductRollup batchDealProduct = new CRM_BatchDealProductRollup();
        Test.startTest();
        Database.executeBatch(batchDealProduct);
        Test.stopTest();
        List<OpportunityLineItem> lstUpdatedDealProduct = [Select Id, POS_Quantity__c, POS_Revenue__c  From OpportunityLineItem];
        System.assertEquals(10,lstUpdatedDealProduct[0].POS_Quantity__c);
        System.assertEquals(900.00,lstUpdatedDealProduct[0].POS_Revenue__c);
  
    }
    
    /**
     *  create Test Data For two Schedules On Deal Product
     *  @name createTestDataForTwoSchedules
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    private static void createTestDataForTwoSchedules() {
        createCustomSetting();
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_ACTUALS;
        List<Account> lstAccounts = CRM_TestDataTemplate.createAccounts(1, true);
        List<Product_Group__c> lstProductGroup = CRM_TestDataTemplate.createProductGroups(1, true);
        List<Product2> lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, date.today(), date.today(), 1, true);
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataTemplate.createPriceBookEntries(lstProducts, 1, true);
        CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts,1,true);
        List<Opportunity> lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstAccounts, 
                                        CRM_AppConstants.OPPORTUNITY_STAGE_Actuals_Sales, date.today() -60, date.today() + 60, dealRecordTypeId, 1, false);
        lstDeals[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_POS_Actuals;
        lstDeals[0].Promo_Start_Date__c = date.today() + 1;
        lstDeals[0].Promo_End_Date__c = date.today() + 61;
        insert lstDeals;
        List<OpportunityLineItem> lstDealProducts =  CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntry, lstDeals, 10, 1, true);
        List<OpportunityLineItemSchedule> lstSchedules = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts, 10, 
                                                            CRM_AppConstants.SCHEDULE_TYPE_BOTH, date.today() + 15, 900, 2, true);
        
    }
    
    /**
     *  Test Method For two Schedules On Deal Product
     *  @name TestScenario2
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    private static testMethod void TestScenario2() {
        createTestDataForTwoSchedules();
        CRM_BatchDealProductRollup batchDealProduct = new CRM_BatchDealProductRollup();
        Test.startTest();
        Database.executeBatch(batchDealProduct);
        Test.stopTest();
        List<OpportunityLineItem> lstUpdatedDealProduct = [Select Id, POS_Quantity__c, POS_Revenue__c  From OpportunityLineItem];
        System.assertEquals(20,lstUpdatedDealProduct[0].POS_Quantity__c);
        System.assertEquals(1800.00,lstUpdatedDealProduct[0].POS_Revenue__c);
  
    }
    
    /**
     *  create Test Data For Bulk(200) Schedules On Deal Product
     *  @name createTestDataForBulkSchedules
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    private static void createTestDataForBulkSchedules() {
        createCustomSetting();
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_ACTUALS;
        List<Account> lstAccounts = CRM_TestDataTemplate.createAccounts(1, true);
        List<Product_Group__c> lstProductGroup = CRM_TestDataTemplate.createProductGroups(1, true);
        List<Product2> lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, date.today(), date.today(), 1, true);
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataTemplate.createPriceBookEntries(lstProducts, 1, true);
        CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts,1,true);
        List<Opportunity> lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstAccounts, 
                                        CRM_AppConstants.OPPORTUNITY_STAGE_Actuals_Sales, date.today() -60, date.today() + 60, dealRecordTypeId, 1, false);
        lstDeals[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_POS_Actuals;
        lstDeals[0].Promo_Start_Date__c = date.today() + 1;
        lstDeals[0].Promo_End_Date__c = date.today() + 61;
        insert lstDeals;
        List<OpportunityLineItem> lstDealProducts =  CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntry, lstDeals, 10, 1, true);
        List<OpportunityLineItemSchedule> lstSchedules = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts, 10, 
                                                            CRM_AppConstants.SCHEDULE_TYPE_BOTH, date.today() + 15, 900, 200, true);
        
    }
    
    /**
     *  Test method For Bulk(200) Schedules On Deal Product
     *  @name TestScenario3
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    private static testMethod void TestScenario3() {
        createTestDataForBulkSchedules();
        CRM_BatchDealProductRollup batchDealProduct = new CRM_BatchDealProductRollup();
        Test.startTest();
        Database.executeBatch(batchDealProduct);
        Test.stopTest();
        List<OpportunityLineItem> lstUpdatedDealProduct = [Select Id, POS_Quantity__c, POS_Revenue__c  From OpportunityLineItem];
        System.assertEquals(2000,lstUpdatedDealProduct[0].POS_Quantity__c);
        System.assertEquals(180000.00,lstUpdatedDealProduct[0].POS_Revenue__c);
  
    }
    
    
    
}