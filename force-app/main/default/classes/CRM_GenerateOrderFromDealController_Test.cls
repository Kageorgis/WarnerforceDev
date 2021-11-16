/**
   @Author-Cognizant Technology Solutions
   @name-CRM_GenerateOrderFromDealController_Test
   @CreateDate-Date>
   @Description-Test Class to cover different scenarios that will occur for CRM_GenerateOrderFromDealController
   @Version-<1.0>
   @reference-None
  */
@isTest
private class CRM_GenerateOrderFromDealController_Test{
/**
    *  Description-Test Method to pass the Deal Id to Flow parameter and test different scenario's 
    *  @name-CRM_GenerateOrderFromDealControllerTestDataMethod()
    *  @param-None
    *  @return-None
    *  @throws exception- An unhandled fault has occurred while processing the flow.  Please contact your system administrator for more information.
    */
    public static List<Id> dealIds = new List<Id>();
    static testMethod void CRM_GenerateOrderFromDealControllerTestDataMethod(){
        List<Account> lstSoltToAccounts = new List<Account>();
        List<Opportunity> lstDeals;
        List<Id> dpIds = new List<Id>();
        List<Product2> lstProduct2 = new List<Product2>();
        List<PricebookEntry>  lstPricebookEntry = new List<PricebookEntry>();
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstUpdatedOpportunityLineItem = new List<OpportunityLineItem>();
        ApexPages.StandardController sc;
        CRM_GenerateOrderFromDealController testOrder;
        
        User u = [Select Id from User where Id =: userInfo.getUserId()];
        System.runAs(u) {
            //Creating accounts to pass as parameter while creating opportunities
            List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
            
            for (Account acct : lstAccounts)
            {
                acct.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
                lstSoltToAccounts.add(acct);
            }
            insert lstSoltToAccounts;
            
            System.assertNotEquals(null, lstSoltToAccounts[0].Id, 'Error while creating Accounts');
            
            //Create Products
            lstProduct2 = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,true);
            
            //Create PriceBook Entries
            lstPricebookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct2,1,true);
            
            CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct2,1,true);
            
            // Create Deals to generate Order and Order Products from the deal
            lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstSoltToAccounts,1,true);
            System.assertEquals(1, lstDeals.size(), 'Created Opportunity');
            dealIds.add(lstDeals[0].Id);
            //Create Deal Product
            lstOpportunityLineItem = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricebookEntry,lstDeals,1,false);
            for(OpportunityLineItem oli : lstOpportunityLineItem){
                oli.Initial_Quantity__c =2;
                oli.Promoted_Price__c =10;
                lstUpdatedOpportunityLineItem.add(oli);
                dpIds.add(oli.Id);
            }
            insert lstUpdatedOpportunityLineItem;
            
            System.AssertEquals(1,lstUpdatedOpportunityLineItem.size(),'Created Deal Product');
            
            Test.StartTest();

            sc = new ApexPages.StandardController(lstDeals[0]);
            testOrder = new CRM_GenerateOrderFromDealController(sc);
            
            CRM_GenerateOrderFromDealController.generateOrderAndOrderProducts(dealIds);
            
            List<Order> orderRec = [select Id from Order where OpportunityId IN:dealIds];
            
            if(orderRec != null) {
                CRM_GenerateOrderFromDealController.generateOrderProducts(orderRec[0].Id,dpIds);
            }
            

            PageReference pageRef = Page.CRM_GenerateOrderFromDeal;
            Test.setCurrentPage(pageRef);
            
            try{
                sc = new ApexPages.StandardController(lstDeals[0]);
                testOrder = new CRM_GenerateOrderFromDealController(sc);
                CRM_GenerateOrderFromDealController.generateOrderAndOrderProducts(dealIds);
                
            }
            catch(Exception e){
                System.AssertEquals(true,e.getMessage().contains(null));
                
            }
            delete lstDeals;   
            Test.StopTest();
        } 
    }
    /**
    *  Description-Test Method to pass the Deal Id to Flow parameter and test different scenario's 
    *  @name-CRM_GenerateOrderFromDealControllerTestDataMethod()
    *  @param-None
    *  @return-None
    *  @throws exception- An unhandled fault has occurred while processing the flow.  Please contact your system administrator for more information.
    */
    static testMethod void CRM_GenerateOrderFromDealController_WIthRevShareAcc_NoMarketType_TestDataMethod(){
        List<Account> lstSoltToAccounts = new List<Account>();
        List<Opportunity> lstDeals;
        List<Id> dpIds = new List<Id>();
        List<Product2> lstProduct2 = new List<Product2>();
        List<PricebookEntry>  lstPricebookEntry = new List<PricebookEntry>();
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstUpdatedOpportunityLineItem = new List<OpportunityLineItem>();
        ApexPages.StandardController sc;
        CRM_GenerateOrderFromDealController testOrder;
        
        User u = [Select Id from User where Id =: userInfo.getUserId()];
        System.runAs(u) {
            //Creating accounts to pass as parameter while creating opportunities
            List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
            
            for (Account acct : lstAccounts)
            {
                acct.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
                acct.Revenue_Share__c = TRUE;
                lstSoltToAccounts.add(acct);
            }
            insert lstSoltToAccounts;
            
            System.assertNotEquals(null, lstSoltToAccounts[0].Id, 'Error while creating Accounts');
            
            //Create Products
            lstProduct2 = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,true);
            
            //Create PriceBook Entries
            lstPricebookEntry =CRM_TestDataFactory.createPriceBookEntries(lstProduct2,1,true);
            
            CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct2,1,true);
            
            // Create Deals to generate Order and Order Products from the deal
            lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstSoltToAccounts,1,true);
            System.assertEquals(1, lstDeals.size(), 'Created Opportunity');
            dealIds.add(lstDeals[0].Id);
            //Create Deal Product
            lstOpportunityLineItem = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricebookEntry,lstDeals,1,false);
            for(OpportunityLineItem oli : lstOpportunityLineItem){
                oli.Initial_Quantity__c =2;
                oli.Promoted_Price__c =10;
                lstUpdatedOpportunityLineItem.add(oli);
                dpIds.add(oli.Id);
            }
            insert lstUpdatedOpportunityLineItem;
            System.AssertEquals(1,lstUpdatedOpportunityLineItem.size(),'Created Deal Product');
            
            Test.StartTest();

            sc = new ApexPages.StandardController(lstDeals[0]);
            testOrder = new CRM_GenerateOrderFromDealController(sc);
            CRM_GenerateOrderFromDealController.generateOrderAndOrderProducts(dealIds);
            List<Order> orderRec = [select Id from Order where OpportunityId IN:dealIds];
            
            if(orderRec != null) {
                CRM_GenerateOrderFromDealController.generateOrderProducts(orderRec[0].Id,dpIds);
            }

            PageReference pageRef = Page.CRM_GenerateOrderFromDeal;
            Test.setCurrentPage(pageRef);
            
            try{
                sc = new ApexPages.StandardController(lstDeals[0]);
                testOrder = new CRM_GenerateOrderFromDealController(sc);
                //testOrder.params = null;
                CRM_GenerateOrderFromDealController.generateOrderAndOrderProducts(dealIds);
                
            }
            catch(Exception e){
                System.AssertEquals(true,e.getMessage().contains(null));
                
            }
            delete lstDeals;   
            Test.StopTest();
        } 
    }
    /**
    *  Description-Test Method to pass the Deal Id to Flow parameter and test different scenario's 
    *  @name-CRM_GenerateOrderFromDealControllerTestDataMethod()
    *  @param-None
    *  @return-None
    *  @throws exception- An unhandled fault has occurred while processing the flow.  Please contact your system administrator for more information.
    */
    static testMethod void CRM_GenerateOrderFromDealController_WIthRevShareAcc_WithMarketType_TestDataMethod(){
        List<Account> lstSoltToAccounts = new List<Account>();
        List<Opportunity> lstDeals;
        List<Product2> lstProduct2 = new List<Product2>();
        List<Id> dpIds = new List<Id>();
        List<PricebookEntry>  lstPricebookEntry = new List<PricebookEntry>();
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstUpdatedOpportunityLineItem = new List<OpportunityLineItem>();
        ApexPages.StandardController sc;
        CRM_GenerateOrderFromDealController testOrder;
        
        User u = [Select Id from User where Id =: userInfo.getUserId()];
        System.runAs(u) {
            //Creating accounts to pass as parameter while creating opportunities
            List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
            
            for (Account acct : lstAccounts)
            {
                acct.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
                acct.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                acct.Revenue_Share__c = TRUE;
                acct.BillingStreet = 'test';
              acct.BillingCity = 'test';
              acct.BillingPostalCode = '232344';
              acct.BillingCountry = 'Japan';
              acct.BillingCountryCode = 'JP';
                lstSoltToAccounts.add(acct);
            }
            insert lstSoltToAccounts;
            
            System.assertNotEquals(null, lstSoltToAccounts[0].Id, 'Error while creating Accounts');
            
            //Create Products
            lstProduct2 = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
            for(Product2 p:lstProduct2){
                p.Product_Market__c = CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE;
            }
            insert lstProduct2;
            //Create PriceBook Entries
            lstPricebookEntry =CRM_TestDataFactory.createPriceBookEntries(lstProduct2,1,true);
            
            CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct2,1,true);
            
            // Create Deals to generate Order and Order Products from the deal
            lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstSoltToAccounts,1,false);
            for (Opportunity deal : lstDeals)
            {
                 deal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                 deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
            }
            insert lstDeals;
            System.assertEquals(1, lstDeals.size(), 'Created Opportunity');
            dealIds.add(lstDeals[0].Id);
            //Create Deal Product
            lstOpportunityLineItem = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricebookEntry,lstDeals,1,false);
            for(OpportunityLineItem oli : lstOpportunityLineItem){
                oli.Initial_Quantity__c =2;
                oli.Promoted_Price__c =10;
                lstUpdatedOpportunityLineItem.add(oli);
            }
            insert lstUpdatedOpportunityLineItem;
            
            for(OpportunityLineItem oli : lstUpdatedOpportunityLineItem){
                dpIds.add(oli.Id);
            }
            System.AssertEquals(1,lstUpdatedOpportunityLineItem.size(),'Created Deal Product');
            
            Test.StartTest();
            system.debug('dealIds -------------'+dealIds);
            sc = new ApexPages.StandardController(lstDeals[0]);
            testOrder = new CRM_GenerateOrderFromDealController(sc);
            CRM_GenerateOrderFromDealController.generateOrderAndOrderProducts(dealIds);
            

            PageReference pageRef = Page.CRM_GenerateOrderFromDeal;
            Test.setCurrentPage(pageRef);
            
            try{
                sc = new ApexPages.StandardController(lstDeals[0]);
                testOrder = new CRM_GenerateOrderFromDealController(sc);
                List<Id> dealIdRecs = new List<Id>();
                List<Opportunity> opId = [select Id,StageName from Opportunity where Id IN:lstDeals];
                for(Opportunity opRec : opId){
                    dealIdRecs.add(opRec.Id);
                }
                
                //testOrder.params = null;
                List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
                Date d = System.today();
                User testUser = new User(
                    FirstName = 'Test',
                    LastName = 'User',
                    Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
                    Email = 'abc@test.com',
                    Alias = String.valueOf(d).substring(0,8),
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US', 
                    LocalesIdKey = 'en_US',
                    TimezonesIdKey = 'America/Los_Angeles',
                    IsActive = true,
                    ProfileId = profiles[0].Id,
                    ByPassValidationRule__c = true
                );
                    insert testUser;
                 System.runas(testUser) {
                    opId[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
                    update opId;
                 }
                
                
                
                CRM_GenerateOrderFromDealController.generateOrderAndOrderProducts(dealIdRecs);
                
                List<Order> orderRec = [select Id from Order where OpportunityId IN:dealIdRecs];
                system.assertNotEquals(null, orderRec);
                if(orderRec != null) {
                    CRM_GenerateOrderFromDealController.generateOrderProducts(orderRec[0].Id,dpIds);
                }
            }
            catch(Exception e){
                system.debug('exception ---------------------------------'+e);
                System.AssertEquals(true,e.getMessage().contains(null));
            }
            delete lstDeals;   
            Test.StopTest();
        } 
    }
    static testMethod void CRM_GenerateOrderFromDealController_japanException_TestDataMethod(){
        List<Account> lstSoltToAccounts = new List<Account>();
        List<Opportunity> lstDeals;
        List<Product2> lstProduct2 = new List<Product2>();
        List<PricebookEntry>  lstPricebookEntry = new List<PricebookEntry>();
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstUpdatedOpportunityLineItem = new List<OpportunityLineItem>();
        ApexPages.StandardController sc;
        CRM_GenerateOrderFromDealController testOrder;
        //Creating accounts to pass as parameter while creating opportunities
            List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
    
            for (Account acct : lstAccounts)
            {
                acct.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
                acct.Revenue_Share__c = TRUE;
                acct.Sales_Organization__c = '8003';
                lstSoltToAccounts.add(acct);
            }
            insert lstSoltToAccounts;
             System.assertNotEquals(null, lstSoltToAccounts[0].Id, 'Error while creating Accounts');
            
            //Create Products
            lstProduct2 = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
            for(Product2 prod : lstProduct2){
              prod.Product_Market__c = '2';
            }
            insert lstProduct2;
            
            //Create PriceBook Entries
            lstPricebookEntry =CRM_TestDataFactory.createPriceBookEntries(lstProduct2,1,true);
            
            CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct2,1,true);
            
            // Create Deals to generate Order and Order Products from the deal
            lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstSoltToAccounts,1,false);
            for (Opportunity deal : lstDeals)
            {
                deal.Market_Type__c = '2';
                deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
            }
            insert lstDeals;
            dealIds.add(lstDeals[0].Id);
            System.assertEquals(1, lstDeals.size(), 'Created Opportunity');
            System.assertEquals(null,lstDeals[0].Sales_Organisation__c);
            //Create Deal Product
            lstOpportunityLineItem = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricebookEntry,lstDeals,1,false);
            for(OpportunityLineItem oli : lstOpportunityLineItem){
                oli.Initial_Quantity__c =2;
                oli.Promoted_Price__c =10;
                lstUpdatedOpportunityLineItem.add(oli);
            }
            insert lstUpdatedOpportunityLineItem;
            System.AssertEquals(1,lstUpdatedOpportunityLineItem.size(),'Created Deal Product');
            
            Test.StartTest();

            sc = new ApexPages.StandardController(lstDeals[0]);
            testOrder = new CRM_GenerateOrderFromDealController(sc);
            CRM_GenerateOrderFromDealController.generateOrderAndOrderProducts(dealIds);
            

            PageReference pageRef = Page.CRM_GenerateOrderFromDeal;
            Test.setCurrentPage(pageRef);
            try{
                sc = new ApexPages.StandardController(lstDeals[0]);
                testOrder = new CRM_GenerateOrderFromDealController(sc);
                //testOrder.params = null;
                CRM_GenerateOrderFromDealController.generateOrderAndOrderProducts(dealIds);
                
            }
            catch(Exception e){
                System.AssertEquals(e.getMessage(),null);
                
            } 
            Test.StopTest();
    }
}