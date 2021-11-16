/**
 * @Author Cognizant
 * @name CRM_PublishAssortmentsControllerTest
 * @CreateDate 21 June 2016
 * @Description Test class for CRM_PublishAssortmentsController
 * @Version <1.0>
 */
@isTest(seeAllData=false)
private class CRM_PublishAssortmentsControllerTest {
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
        
        Pricebook2  pb = new Pricebook2();
		pb.Name = 'PB'+1;
        pb.Business_Unit__c = '2500';
		pb.Country__c = '435';
		pb.CurrencyIsoCode = 'USD';
		pb.Description = 'Price book';
		pb.External_Id__c = pb.Name;
		pb.IsActive = True;
		pb.Product_Type__c = 'Physical'; 
        insert pb;
        
        // Insert Account (10 for assortment account and 1 for pricing account)
         lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        for(Account acc : lstAccounts) {
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            acc.Price_book__c =pb.id;
        }
        insert lstAccounts;
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        // Create 5 Products
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
         
        lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts,1,true);
        
       /* lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, false);
        
        for(PricebookEntry pbEntry : lstPriceBookEntries){
            pbEntry.Pricebook2Id = pb[0].id;
        }
        insert lstPriceBookEntries;
       
       
        for(Product2 prod : lstProducts){
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.UnitPrice = 10.00;
        pbEntry.CurrencyIsoCode = prod.CurrencyIsoCode;
        pbEntry.Product2Id = prod.Id;                
        pbEntry.IsActive = true;
        pbEntry.Pricebook2Id = pb[0].id;
        lstPriceBookEntries.add(pbEntry);
        }
        insert lstPriceBookEntries;
        */    
        List<Pricebook_Entry_Period__c> pbeplst = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        /*
        for(Pricebook_Entry_Period__c pbep : pbeplst){
         pbep.Price_book__c = pb[0].id;
        }
        insert pbeplst;
        */
        
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
        lstBundles[0].Price_Book__c = pb.id;
        
        insert lstBundles;
        
        List<Config__c> lstConfig = new List<Config__c>();
        Config__c config = new Config__c();
        config.Assortment__c = lstBundles[0].Id;  
        config.RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_VRAC;                     
        lstConfig.add(config);
            
        if(!lstConfig.isEmpty()){
            insert lstConfig;
        }
        
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
            //oppty.Pricebook2Id =pb[0].id;
            system.debug('opp Value oppty -- >'+oppty.Sent_To_SAP__c+'unique publish key-->'+oppty.UniquePublishKey__c);          
        }
        insert lstOpportunity;
        
        lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries,lstOpportunity, 5, true);

        system.debug('opp Value -- >'+lstOpportunity[0]);
        // Create a list of bundle products
        lstBundleProducts = new List<Bundle_Product__c>();
        // Add products to bundle (100 Products)
        for (Integer i=0; i < lstProducts.size(); i++) {
            Bundle_Product__c bProd = new Bundle_Product__c();
            bProd.Bundle__c = lstBundles[0].Id;
            bProd.Product__c = lstProducts[i].Id;
            bProd.List_Price__c = 20;
            bProd.Assortment_Price__c = 10;
            bProd.Share__c = 20;
            
            lstBundleProducts.add(bProd);
        }
        // Insert Assortment Products
        insert lstBundleProducts;              
        
        //Create POS Forcast
        POSForcast = CRM_TestDataFactory.createPOSForecast(lstBundles[0]);
        insert POSForcast;
    }
    
   
    
    static testmethod void test_publishNewAssortment() {
        setupTestData();
        
        Test.startTest();
                       
        Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
        CRM_PublishAssortmentsController controller = new CRM_PublishAssortmentsController(stdCon);
        
        CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User testUser = new User(Alias = 'wassort',ByPassValidationRule__c=true ,Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
        system.runAs(testUser){
            lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL;
            update lstBundles[0];
            
            lstBundles[0].Publish_In_Progress__c = false;
            lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
            update lstBundles[0];  
        }
        system.assertEquals('Approved',lstBundles[0].Assortment_Status__c);
        
        /*
        CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
        */ 
        
        system.runAs(testUser){
            lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;
            lstBundles[0].Publish_In_Progress__c = false;
            update lstBundles[0];
 
        }
        system.assertEquals('Draft',lstBundles[0].Assortment_Status__c);
        try{
        CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
        }
        catch(exception e){
            system.assertEquals(null, e.getmessage());
        }       
        
        Test.stopTest();
        
    } 
    
     static testmethod void test_getSAPDealsForCancellation() {
        setupTestData();
        
        Test.startTest();
                                                     
        
        Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
        CRM_PublishAssortmentsController controller = new CRM_PublishAssortmentsController(stdCon);

        list<opportunity> lstOpportunitynew = [select id,UniquePublishKey__c,Sent_To_SAP__c,Assortment_Account__c,Bundle__c from opportunity where Bundle__c = :lstBundles[0].Id];                        
        for(Opportunity oppty : lstOpportunitynew) {
            oppty.Sent_To_SAP__c=system.now();            
            system.debug('opp Value oppty -- >'+oppty.Sent_To_SAP__c);     
        }
        update lstOpportunitynew;
        system.debug('Opportunity value for assortment new  --->'+[select id,UniquePublishKey__c,Sent_To_SAP__c,Assortment_Account__c,Bundle__c from opportunity where Bundle__c = :lstBundles[0].Id]);                        
        
        CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
                       
        Test.stopTest(); 
        system.debug('Opportunity value for assortment --->'+[select id,UniquePublishKey__c,Last_Published_Date__c,Sent_To_SAP__c,Assortment_Account__c,Bundle__c from opportunity where Bundle__c = :lstBundles[0].Id]);                        
        for(Opportunity opp : [select id,UniquePublishKey__c,Last_Published_Date__c,Sent_To_SAP__c,Assortment_Account__c,Bundle__c from opportunity where Bundle__c = :lstBundles[0].Id])
        system.assertNotEquals(null,opp.Last_Published_Date__c);
    }
    
    static testmethod void test_syncDeletedAssortmentProducts() {
        // setup test data
        setupTestData();
        
        // Publish the assortment
        Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
        CRM_PublishAssortmentsController controller = new CRM_PublishAssortmentsController(stdCon);
        CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User testUser = new User(Alias = 'wassort',ByPassValidationRule__c=true ,Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
        
        system.runAs(testUser){
            update new Bundle_Product__c(Share__c=40, Id= lstBundleProducts[lstBundleProducts.size()-2].Id);
            
	        // Delete one/last assortment product and republish the assortment
	        delete lstBundleProducts[lstBundleProducts.size()-1];
	        
	        lstBundles[0].Publish_In_Progress__c = false;
            update lstBundles[0];
	        
	        CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
	        
	        OpportunityLineItem[] listLineItems = [select Id from OpportunityLineItem where Opportunity.Bundle__c = :lstBundles[0].Id
	                        and UniquePublishKey__c <> null];
        }
        
        Test.stopTest();
    }
    
     //US : 814 : Update Finance Review Field Update on Campaining Assortment after publish
    static testmethod void test_publishNewAssortmentForFinanceReviewFieldUpdate() {
        setupTestData();
        
        lstBundles[0].Campaign_Type__c = CRM_AppConstants.ASSORTMENT_TRADE_CAMPAING_TYPE;
        update lstBundles[0];
        
        Test.startTest();
                       
            Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
            CRM_PublishAssortmentsController controller = new CRM_PublishAssortmentsController(stdCon);
            
            CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
            User testUser = new User(Alias = 'wassort',ByPassValidationRule__c=true ,Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
            system.runAs(testUser){
                lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL;
                update lstBundles[0];
                
                lstBundles[0].Publish_In_Progress__c = false;
                lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
                update lstBundles[0];  
            }
            system.assertEquals('Approved',lstBundles[0].Assortment_Status__c);
            
            /*
            CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
            */ 
            
            system.runAs(testUser){
                lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;
                lstBundles[0].Publish_In_Progress__c = false;
                update lstBundles[0];
     
            }
            system.assertEquals('Draft',lstBundles[0].Assortment_Status__c);
            try{
                CRM_PublishAssortmentsController.publishAssortment(lstBundles[0].Id);
            }
            catch(exception e){
                system.assertEquals(null, e.getmessage());
            }       
        Test.stopTest();
        
        Decimal quantity = 0;
        Decimal estimatedRevenue = 0;
        Decimal returnsRevenue = 0;
        Decimal couponingForecast = 0;
        Decimal estimatedSalesAllowancesValue = 0;
        Decimal totalCostOfProducts = 0;
        Decimal PAPCost = 0;
        Decimal handlingLogistics = 0;
        Decimal royaltyAmount = 0;

        List<OpportunityLineItem> dealProducts = [Select Id,Estimated_Revenue_Formula__c,Total_Quantity__c,Returns_Revenue__c,Couponing_Forecast__c,Estimated_Sales_Allowances_Value__c,
                                                        Total_Cost_of_Products__c,PAP_Cost__c,Handling_Logistics__c,Royalty_Fee_Cost__c
                                                 FROM OpportunityLineItem
                                                 WHERE opportunity.Bundle__c = :lstBundles[0].Id AND opportunity.Bundle__r.RecordTypeId = :CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN AND
                                                 opportunity.Bundle__r.Campaign_Type__c = :CRM_AppConstants.ASSORTMENT_TRADE_CAMPAING_TYPE];
    
       for(OpportunityLineItem dp : dealProducts){
            quantity += dp.Total_Quantity__c != null ? dp.Total_Quantity__c : 0;
            estimatedRevenue += dp.Estimated_Revenue_Formula__c != null ? dp.Estimated_Revenue_Formula__c : 0;
            returnsRevenue += dp.Returns_Revenue__c != null ? dp.Returns_Revenue__c : 0;
            couponingForecast += dp.Couponing_Forecast__c != null ? dp.Couponing_Forecast__c : 0;
            estimatedSalesAllowancesValue += dp.Estimated_Sales_Allowances_Value__c != null ? dp.Estimated_Sales_Allowances_Value__c : 0;
            totalCostOfProducts += dp.Total_Cost_of_Products__c != null ? dp.Total_Cost_of_Products__c : 0;
            PAPCost += dp.PAP_Cost__c != null ? dp.PAP_Cost__c : 0;
            handlingLogistics += dp.Handling_Logistics__c != null ? dp.Handling_Logistics__c : 0;
            royaltyAmount += dp.Royalty_Fee_Cost__c != null ? dp.Royalty_Fee_Cost__c : 0;
        }
        
        List<Bundle__c> assortment = [SELECT Quantity__c,Estimated_Revenue__c,Returns_Revenue__c,Couponing_Forecast__c,Estimated_Sales_Allowances_Value__c,
                                      Total_Cost_of_Products__c,PAP_Cost__c,Handling_Logistics__c,Royalty_Amountc__c,Profitability_Date_Stamped__c
                                      From Bundle__c Where Id =: lstBundles[0].Id];
        if(!assortment.isEmpty()){                             
            system.assertEquals(quantity,assortment[0].Quantity__c);
            system.assertEquals(estimatedRevenue,assortment[0].Estimated_Revenue__c);
            system.assertEquals(returnsRevenue,assortment[0].Returns_Revenue__c);
            system.assertEquals(couponingForecast,assortment[0].Couponing_Forecast__c);
            system.assertEquals(estimatedSalesAllowancesValue,assortment[0].Estimated_Sales_Allowances_Value__c);
            system.assertEquals(totalCostOfProducts,assortment[0].Total_Cost_of_Products__c);
            system.assertEquals(PAPCost,assortment[0].PAP_Cost__c);
            system.assertEquals(handlingLogistics,assortment[0].Handling_Logistics__c);
            system.assertEquals(royaltyAmount,assortment[0].Royalty_Amountc__c);
        }
    }
    
    static testmethod void test_publishAssortmentFinalActions_NegativeTest() {
        List<Pricebook2> lstPricebook = CRM_TestDataFactory.createPricebooks(1, false);
        for(Pricebook2 pb : lstPricebook) {
        	pb.Product_Type__c = 'Physical'; 
        }
        insert lstPricebook;
    	
		List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, true);
		List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        for(Opportunity oppty : lstOpportunity) {
            oppty.UniquePublishKey__c = 'Test-Opportunity'; 
        }
        insert lstOpportunity;
        
        lstOpportunity[0].StageName = 'Cancelled';
        update lstOpportunity;
        
        List<Bundle__c> lstBundles = CRM_TestDataFactory.createBundles(1, false);
        lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;
        lstBundles[0].Name = 'Test Bundle';
        lstBundles[0].RecordTypeId = CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstBundles[0].High_Level_Target__c = 20000;
        lstBundles[0].Promo_Start_Date__c = Date.today().addDays(1);
        lstBundles[0].Promo_End_Date__c = Date.today().addDays(30);
        lstBundles[0].Start_Date__c = Date.today().addDays(1);
        lstBundles[0].Account_Split_Template__c = null;
        lstBundles[0].Pricing_Account__c = lstAccounts[0].Id;
        lstBundles[0].Price_Book__c = lstPricebook[0].Id;
        lstBundles[0].Price_Book__r = lstPricebook[0];
        
		CRM_BatchPublishAssortmentFinalActions publishAssortment = new CRM_BatchPublishAssortmentFinalActions();
		publishAssortment.assortment = lstBundles[0];
		publishAssortment.mapFinalDealsStageChanges = new Map<String, String>{'Test-Opportunity' => 'Planned'};
		publishAssortment.publishErrors = new CRM_PublishAssortmentHelper.PublishError[]{};
		Test.startTest();
		Database.executeBatch(publishAssortment, CRM_PublishAssortmentHelper.PUBLISH_BATCH_SIZE);
		Test.stopTest();
    }
}