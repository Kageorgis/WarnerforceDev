/**
   @Author Cognizant Team
   @name CRM_AssortmentAccountHandler_Test 
   @CreateDate 
   @Description Test class for CRM_AssortmentAccountHandler
   @Version <1.0>
  */
@isTest(seeAllData=false)
private class CRM_AssortmentAccountHandler_Test {
    static List<Bundle__c> lstBundles;
    static List<Bundle_Product__c> lstBundleProducts;
    static List<Assortment_Account__c> lstBundleAccounts;
    static List<Opportunity> lstOpportunity; 
    static POS_Forecast__c POSForcast;
    static List<PricebookEntry> lstPriceBookEntries;
    static List<OpportunityLineItem> lstDealProduct;
    static List<Account> lstAccounts;
    static List<OpportunityLineItem> lstDealProducts;
    
    private static void setupTestData() {
        // Insert Account (10 for assortment account and 1 for pricing account)
        lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        for(Account acc : lstAccounts) {
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        }
        insert lstAccounts;
        
        // Create 10 Products
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 5, false);

        // update all 10 product records
        for (Integer i=0; i < lstProducts.size(); i++) {
            lstProducts[i].ProductCode = '1000230554';
            lstProducts[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            lstProducts[i].Product_Format__c = '4';
            lstProducts[i].Product_Rating__c = 'UK - Minimum 12 Ye';
            lstProducts[i].Product_Genre__c = 'ACTION';
            lstProducts[i].Release_Category__c = '23';
            lstProducts[i].Franchise_Type__c = 'X4';
            lstProducts[i].Product_Language_Code__c = 'EN';
            lstProducts[i].SAP_Dist_chain_product_Status__c = '11';
            lstProducts[i].Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
            lstProducts[i].Recommended_Price__c = 150;
            lstProducts[i].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
        }
        insert lstProducts;

        lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);

        lstBundles = CRM_TestDataFactory.createBundles(1, false);
        lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;
        lstBundles[0].Name = 'Test National Campaign Bundle';
        lstBundles[0].RecordTypeId = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
        lstBundles[0].High_Level_Target__c = 20000;
        lstBundles[0].Promo_Start_Date__c = Date.today().addDays(1);
        lstBundles[0].Promo_End_Date__c = Date.today().addDays(30);
        lstBundles[0].Start_Date__c = Date.today().addDays(1);
        lstBundles[0].Account_Split_Template__c = null;
        lstBundles[0].Campaign_Type__c = CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL;
        lstBundles[0].Pricing_Account__c = lstAccounts[0].Id;
        insert lstBundles;
        
        lstBundleAccounts = new List<Assortment_Account__c>();
        // Add products to bundle (100 Products)
        for (Integer i=0; i < lstAccounts.size(); i++) {
            Assortment_Account__c bAcc = new Assortment_Account__c();
            bAcc.Assortment__c = lstBundles[0].Id;
            bAcc.Account__c = lstAccounts[i].Id;
            bAcc.Share__c = 20;
            bAcc.Send_To_OTC__c = false;
            lstBundleAccounts.add(bAcc);
        }
        // Insert Assortment Products
        insert lstBundleAccounts;
        
        //Insert 10 Opportunity 
        lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        Integer counter=0;
        for(Opportunity oppty : lstOpportunity) {
            counter++;
            oppty.Hidden_Estimated_Quantity__c = 10;
            oppty.Bundle__c = lstBundles[0].Id;
            oppty.Assortment_Account__c=lstBundleAccounts[0].id; 
            oppty.Sent_To_SAP__c=system.now();            
            oppty.UniquePublishKey__c = 'Test'+counter; 
            system.debug('opp Value oppty -- >'+oppty.Sent_To_SAP__c+'unique publish key-->'+oppty.UniquePublishKey__c);          
        }
        insert lstOpportunity;
    }
    
    public static testmethod void cancelDeal_Test(){
        setupTestData();
        
        Test.startTest();
        
        delete lstBundleAccounts[0];
        
        List<Opportunity> lstUpdatedOpportunity = [Select StageName From Opportunity where Id =: lstOpportunity[0].Id];
        
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED, lstUpdatedOpportunity[0].StageName, 'Opportunity Stage should change to Cancelled');
        
        Test.stopTest();
    }    
}