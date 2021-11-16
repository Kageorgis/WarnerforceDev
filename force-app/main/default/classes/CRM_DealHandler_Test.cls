/**
@Author Aditi Satpute
@name CRM_DealHandler_Test 
@CreateDate 7 April 2016
@Description Test Class for CRM_DealHandler
@Version <1.0>
@reference Requirement no 155
*/
@isTest
public with sharing class CRM_DealHandler_Test {
    
    public static void createData() {   
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(5);
        System.debug('lstAccounts::'+lstAccounts);
        
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        
        List<Product2> lstProduct = CRM_AutoPhysicalNRDealCreateService_Test.createProductsForNRBatch(lstProGrp,lstAccounts);
        List<Product2> fetchProducts = [SELECT Id FROM Product2 ORDER BY CreatedDate];
        System.debug('lstProduct::'+lstProduct.size());
        
        List<Target__c> lstTargets = CRM_AutoPhysicalNRDealCreateService_Test.createTargetsForNRBatch(lstAccounts, fetchProducts, lstProGrp);
        System.debug('lstTargets::'+lstTargets.size());
        
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(fetchProducts);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry);
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(fetchProducts, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            pbep.Start_Date__c = System.today() + 20;
        }
        insert lstPriceBookEntryPeriod;
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);
        
        lstAccounts[1].Video_Digital__c = True;
        lstAccounts[3].Video_Digital__c = True;
        lstAccounts[4].Video_Digital__c = True;
        update lstAccounts;
        
        Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.debug('lstOpportunity::'+lstOpportunity);
        lstOpportunity[0].Product_Type__c = 'Games Physical';
        lstOpportunity[1].Product_Type__c = 'Games Digital';
        lstOpportunity[1].recordTypeId = digitalRecordTypeId;
        lstOpportunity[2].Product_Type__c = 'Video Physical';
        lstOpportunity[3].Product_Type__c = 'Video Digital';
        lstOpportunity[3].recordTypeId = digitalRecordTypeId;
        lstOpportunity[4].Product_Type__c = 'Video Digital';
        lstOpportunity[4].recordTypeId = digitalRecordTypeId;
        System.debug('lstOpportunity ::'+lstOpportunity);
        insert lstOpportunity ;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);
        for (Integer i=0; i < lstDealProduct.size(); i++) {
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriod[i].Id;
        }
        insert lstDealProduct;
        
        PriceBook2 wbieUS =  new Pricebook2(Name = CRM_AppConstants.WBIE_US_PRICEBOOK_NAME, 
                                            Description = 'WBIE US Pricebook', 
                                            IsActive = true, 
                                            Business_Unit__c = CRM_AppConstants.TERRITORY_US_CODE);
        insert wbieUS;
    }
    
    static testmethod void testDealStartDateChanged_No_Valid_PBEP() {
        createData();
        
        // Make Pricebook Entry Period invalid
        /*  List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c, End_Date__c FROM Pricebook_Entry_Period__c];
                for (Pricebook_Entry_Period__c pbep : lstPBEP) {
                    pbep.Start_Date__c = System.today() + 140;
                    pbep.End_Date__c = System.today() + 160;
                }
                update lstPBEP;*/
        
        List<Opportunity> lstDeal = [SELECT Id, Start_Date__c, CloseDate FROM Opportunity];
        System.assertEquals(5, lstDeal.size());
        
        
        // Verify Deal Products are present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        
        // Verify no invalid deal products present
        System.assertEquals(0, [SELECT Id,Invalid_Deal_Product__c FROM OpportunityLineItem WHERE Invalid_Deal_Product__c = true].size());
        
        Test.startTest();
        lstDeal[0].Start_Date__c = System.today()+150;
        lstDeal[0].Promo_Start_Date__c = System.today()+150;
        lstDeal[0].CloseDate = System.today()+170;
        lstDeal[0].Promo_End_Date__c = System.today()+170;
        
        lstDeal[1].Start_Date__c = System.today()+140;
        lstDeal[1].Promo_Start_Date__c = System.today()+140;
        lstDeal[1].CloseDate = System.today()+180;
        lstDeal[1].Promo_End_Date__c = System.today()+180;
        
        lstDeal[3].CloseDate = System.today()+10;
        update lstDeal;
        Test.stopTest();
        
        // Verify the deal products are marked invalid as no valid PBEP found
        System.assertEquals(3, [SELECT Id,Invalid_Deal_Product__c FROM OpportunityLineItem WHERE Invalid_Deal_Product__c = true].size());
    }
    
    static testmethod void testDealStartDateChanged_With_Non_Matching_Valid_PBEP_InvalidDP_Not_Present() {
        createData();
        
        List<Pricebook_Entry_Period__c> lstPBEP1 = CRM_TestDataFactory.createPriceBookEntryPeriods([SELECT Id FROM Product2 ORDER BY CreatedDate ASC], 1, false);
        System.debug('lstPBEP1::'+lstPBEP1);
        for (Integer i = 0; i < lstPBEP1.size(); i++) {
            lstPBEP1[i].Start_Date__c = System.today() + 140;
            lstPBEP1[i].End_Date__c = System.today() + 160;
        }
        insert lstPBEP1;
        List<Pricebook_Entry_Period__c> lstPBEP2 = CRM_TestDataFactory.createPriceBookEntryPeriods([SELECT Id FROM Product2 ORDER BY CreatedDate ASC], 1, false);
        for (Integer i = 0; i < lstPBEP2.size(); i++) {
            lstPBEP2[i].Start_Date__c = System.today();
            lstPBEP2[i].End_Date__c = System.today() + 15;
        }
        insert lstPBEP2;
        
        List<Opportunity> lstDeal = [SELECT Id, Start_Date__c, CloseDate FROM Opportunity];
        System.assertEquals(5, lstDeal.size());
        
        
        // Verify Deal Products are present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        
        // Verify no invalid deal products present
        System.assertEquals(0, [SELECT Id,Invalid_Deal_Product__c FROM OpportunityLineItem WHERE Invalid_Deal_Product__c = true].size());
        
        Test.startTest();
        lstDeal[0].Start_Date__c = System.today()+150;
        lstDeal[0].Promo_Start_Date__c = System.today()+150;
        lstDeal[0].CloseDate = System.today()+170;
        lstDeal[0].Promo_End_Date__c = System.today()+170;
        
        lstDeal[1].Start_Date__c = System.today()+140;
        lstDeal[1].Promo_Start_Date__c = System.today()+140;
        lstDeal[1].CloseDate = System.today()+180;
        lstDeal[1].Promo_End_Date__c = System.today()+180;
        
        lstDeal[3].CloseDate = System.today()+10;
        lstDeal[3].Promo_End_Date__c = System.today()+10;
        
        update lstDeal;
        Test.stopTest();
        
        // Verify nonly 3 deal products are marked invalid as 3 deal related Dates are modified and valid valid PBEP found for that date range
        System.assertEquals(3, [SELECT Id,Invalid_Deal_Product__c FROM OpportunityLineItem WHERE Invalid_Deal_Product__c = true].size());
    }
    
    static testmethod void testDealStartDateChanged_With_Matching_Valid_PBEP_InvalidDP_Present() {
        createData();
        
        // Make Pricebook Entry Period invalid
        List<Pricebook_Entry_Period__c> lstPBEP1 = CRM_TestDataFactory.createPriceBookEntryPeriods([SELECT Id FROM Product2 ORDER BY CreatedDate ASC], 1, false);
        System.debug('lstPBEP1::'+lstPBEP1);
        for (Integer i = 0; i < lstPBEP1.size(); i++) {
            lstPBEP1[i].Start_Date__c = System.today() + 120;
            lstPBEP1[i].End_Date__c = System.today() + 160;
        }
        insert lstPBEP1;
        List<Pricebook_Entry_Period__c> lstPBEP2 = CRM_TestDataFactory.createPriceBookEntryPeriods([SELECT Id FROM Product2 ORDER BY CreatedDate ASC], 1, false);
        for (Integer i = 0; i < lstPBEP2.size(); i++) {
            lstPBEP2[i].Start_Date__c = System.today();
            lstPBEP2[i].End_Date__c = System.today() + 15;
        }
        insert lstPBEP2;
        
        List<Opportunity> lstDeal = [SELECT Id, Start_Date__c, CloseDate FROM Opportunity];
        System.assertEquals(5, lstDeal.size());
        
        
        // Verify Deal Products are present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        
        // Verify no invalid deal products present
        System.assertEquals(0, [SELECT Id,Invalid_Deal_Product__c FROM OpportunityLineItem WHERE Invalid_Deal_Product__c = true].size());
        
        lstDeal[0].Start_Date__c = System.today()+150;
        lstDeal[0].Promo_Start_Date__c = System.today()+150;
        lstDeal[0].CloseDate = System.today()+170;
        lstDeal[0].Promo_End_Date__c = System.today()+170;
        
        lstDeal[1].Start_Date__c = System.today()+140;
        lstDeal[1].Promo_Start_Date__c = System.today()+140;
        lstDeal[1].CloseDate = System.today()+180;
        lstDeal[1].Promo_End_Date__c = System.today()+180;
        
        lstDeal[3].CloseDate = System.today()+10;
        lstDeal[3].Promo_End_Date__c = System.today()+10;
        update lstDeal;
        
        // Verify only 3 deal products are marked invalid as 3 deal related Dates are modified and valid PBEP found for that date range
        System.assertEquals(3, [SELECT Id,Invalid_Deal_Product__c FROM OpportunityLineItem WHERE Invalid_Deal_Product__c = true].size());
        
        delete lstPBEP2;
        
        Test.startTest();
        lstDeal[0].Start_Date__c = System.today()+25;
        lstDeal[1].Start_Date__c = System.today()+25;
        lstDeal[3].CloseDate = System.today()+25;
        lstDeal[3].Promo_End_Date__c = System.today()+25;
        
        update lstDeal;
        Test.stopTest();
        
        // Verify no invalid deal products present as the deal Start Date is changed and valid PBEP is found
        System.assertEquals(0, [SELECT Id,Invalid_Deal_Product__c FROM OpportunityLineItem WHERE Invalid_Deal_Product__c = true].size());
    }
    
    static testmethod void testDealCloneWithDealProducts() {
        createData();
        
        List<Opportunity> lstDeal = [SELECT Id, Name, StageName, Start_Date__c,Deal_Code__c, CloseDate FROM Opportunity Order BY Id];
        System.assertEquals(5, lstDeal.size());
        for (Integer i = 0 ; i < lstDeal.size(); i++) {
            Opportunity opp = lstDeal[i];
            opp.Deal_Code__c = String.valueOf(137*37) + i;
            opp.StageName = 'Planned';
        }
        update lstDeal;
        
        // Verify Deal Products are present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        
        // Verify Schedules present
        List<OpportunityLineItemSchedule> lstSchedules = [SELECT Id, Quantity,ScheduleDate, OpportunityLineItemId,Revenue FROM OpportunityLineItemSchedule];
        //System.assertEquals(7, lstSchedules.size());
        Map<Id, OpportunityLineItemSchedule> mapSchedules = new Map<Id, OpportunityLineItemSchedule>(lstSchedules);
        
        Test.startTest();
        List<Opportunity> lstClonedDeal = new List<Opportunity>();
        for (Opportunity opp : lstDeal) {
            lstClonedDeal.add(opp.clone());
        }
        insert lstClonedDeal;
        Test.stopTest();
        
        List<Opportunity> lstDealNew = [SELECT Id, Start_Date__c,Deal_Code__c, CloseDate FROM Opportunity WHERE Id NOT IN: lstDeal Order BY Id];
        System.assertEquals(5, lstDealNew.size());
        for (Integer i = 0 ; i < lstDealNew.size(); i++) {
            Opportunity opp = lstDealNew[i];
            System.assertNotEquals(String.valueOf(137*37) + i, opp.Deal_Code__c);
        }
    }
    
    static testmethod void NegativeTest() {
        try {
            System.assertEquals(0, [SELECT Id FROM CRM_Error_Log__c].size());
            throw new TestException('Test Exception');
            
        } catch (Exception ex) {
            Test.startTest();
            CRM_DealHandler instance = new CRM_DealHandler();
            instance.logAnException(ex, null);
            Test.stopTest();
            System.assertEquals(1, [SELECT Id FROM CRM_Error_Log__c].size());
        }
    }
    
    static testmethod void testPromotionalAssortmentDeleteError(){
        List<Bundle__c> lstAssortment = CRM_TestDataFactory.createBundles(1,false);
        Id promotionalRecordTypeId = Schema.SObjectType.Bundle__c.getRecordTypeInfosByName().get('Promotional Assortment').getRecordTypeId();
        lstAssortment[0].RecordTypeId= promotionalRecordTypeId;
        insert lstAssortment;
        System.assertEquals(1, lstAssortment.size());
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,true);
        System.assertEquals(1, lstAccounts.size());
        
        Bundle__c obj = [SELECT Id FROM Bundle__c];
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        lstDeals[0].Bundle__c = obj.Id;
        insert lstDeals;
        
        try {
            Test.startTest();
            List<Opportunity> lstDeletedDeals = [SELECT Id FROM Opportunity];
            delete lstDeletedDeals;
            Test.stopTest();
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  (e.getMessage().contains('You can not delete the deal as it is associated with Promotional/Campaign Assortment.')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
    
    public class TestException extends Exception {
    }
    
    static testmethod void testCheckScheduleRevenueChangedFlagOnAccountStageNameChangeCase(){
        
        User testUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        Test.startTest();
        /*Creating Account*/  
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert lstAccounts;
        
        /*Creating Opportunity With Account (Deal)*/
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,false);
        for (Opportunity deal: lstDeals){
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            deal.High_Level_Forecast__c = 100;
        }
        insert lstDeals; 
        
        lstAccounts[0].scheduleRevenueChanged__c = false;
        update lstAccounts;
        
        /*Creating Product with Product Group and Pricebook*/
        List<Product_Group__c> listProductGroups =   CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, listProductGroups.size(), 'Created ProductGroups');
        
        List<Product2> listProduct =   CRM_TestDataFactory.createProducts(listProductGroups,1,true);
        System.assertEquals(1, listProduct.size(), 'Created Products');
        
        List<PricebookEntry> listPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(listProduct,1,true);
        System.assertEquals(1, listPriceBookEntries.size(), 'Created Pricebook Entries');
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(listProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            pbep.Start_Date__c = System.today() - 20;
            pbep.end_Date__c = System.today() + 120;
        }
        insert lstPriceBookEntryPeriod;
        
        /*Creating Opportunity Line Item (Deal Products)*/
        List<OpportunityLineItem> listDealProductsWithOpportunities = CRM_TestDataFactory.createDealProductsWithOpportunities(listPriceBookEntries,lstDeals,1,false);
        listDealProductsWithOpportunities[0].Quantity = 10;
        listDealProductsWithOpportunities[0].UnitPrice = 10;
        insert listDealProductsWithOpportunities;
        System.assertEquals(1, listPriceBookEntries.size(), 'Created Deal Products');
        
        lstAccounts[0].scheduleRevenueChanged__c = false;
        update lstAccounts;
        
        System.runAs(testUser){
            submitDealForApproval(lstDeals[0]);
        }
        
        Test.stopTest();
        
        //Assert Account Flag scheduleRevenueChanged is checked after StageName has been changed on deal
        System.assertEquals(1,[Select Count() From Account Where scheduleRevenueChanged__c = true]);
        
        Account acc = new Account();
        lstAccounts = new List<Account>{acc};
            Database.SaveResult[] result = Database.update(lstAccounts, false);
        for(Integer i=0; i < result.size(); i++ ){
            if(!result[i].isSuccess()){
                CRM_DealHandler.logAnException(result[i].getErrors(),result[i].getId(),'Test','Test');
            }
        }
    }
    
    static void submitDealForApproval(Opportunity deal){
        PageReference pageRef = Page.CRM_DealApproval;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',deal.id);
        ApexPages.standardController controller = new ApexPages.standardController(deal);
        //CRM_DealHandler.isFirstRun = true;   
        CRM_DealApproval pg = new CRM_DealApproval(controller); 
        CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(deal.id);
        CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(deal.id);
    }
    
    //US#612 : Update Override Pricing Checkbox on Deal and Deal Product
    static testmethod void UpdateOverridePricingCheckboxOnDeal_Test(){
        
        /*Creating Account*/  
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        insert lstAccounts;
        
        /*Creating Rental Deals*/
        List<Opportunity> lstRentalDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 2,false);
        for(integer i=0 ; i<lstRentalDeals.size() ; i++){
            lstRentalDeals[i].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            lstRentalDeals[i].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE; 
            if(i==1){
                lstRentalDeals[i].NR_Deal_Unique_Key__c = 'Test123';
            }
        }
        insert lstRentalDeals;
        
        /*Creating Product with Product Group and Pricebook*/
        List<Product_Group__c> listProductGroups =   CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, listProductGroups.size(), 'Created ProductGroups');
        
        //Renatl Products
        List<Product2> lstRentalProduct =   CRM_TestDataFactory.createProducts(listProductGroups,4,false);
        for(Product2 p : lstRentalProduct){
            p.Product_Market__c = CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE; 
        }
        insert lstRentalProduct;
        System.assertEquals(4, lstRentalProduct.size(), 'Created Products');
        
        List<PricebookEntry> listRenatlPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstRentalProduct,1,true);
        System.assertEquals(4, listRenatlPriceBookEntries.size(), 'Created PricebookEntry');
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstRentalProduct, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            pbep.Start_Date__c = System.today() - 20;
            pbep.end_Date__c = System.today() + 120;
        }
        insert lstPriceBookEntryPeriod;
        
        /*Creating Opportunity Line Item (Deal Products)*/
        List<OpportunityLineItem> listDealProductsWithOpportunities = new List<OpportunityLineItem>();
        for(PricebookEntry pbe : listRenatlPriceBookEntries){
            for(integer i=0 ; i<lstRentalDeals.size() ; i++){
                OpportunityLineItem objDealProduct = new OpportunityLineItem();
                objDealProduct.OpportunityId = lstRentalDeals[i].Id;
                objDealProduct.PricebookEntryId = pbe.Id;
                objDealProduct.Quantity = 1;
                objDealProduct.UnitPrice = 14.10;
                if(i==1){
                    objDealProduct.NR_Deal_Product_Unique_Key__c = lstRentalDeals[i].Id+'-'+i;
                }
                listDealProductsWithOpportunities.add(objDealProduct);
            }
        }
        insert listDealProductsWithOpportunities;
        system.assertEquals(8,listDealProductsWithOpportunities.size());
        
        List<Opportunity> deals = [Select Override_Pricing__c,isHandlingFeeChanged__c,(Select Override_Pricing__c From OpportunityLineItems) From Opportunity Where Id =: lstRentalDeals[0].Id];
        for(Opportunity deal : deals){
            system.assertEquals(true,deal.Override_Pricing__c,'Non NR Rental Deal Override Pricing Checbox should be set to the true');
            system.assertEquals(true,deal.isHandlingFeeChanged__c);
            for(OpportunityLineItem dp : deal.OpportunityLineItems){
                system.assertEquals(true,dp.Override_Pricing__c,'Parent Deal Override Pricing Checkbox is true then Deal products Override Pricing Checkbox should be true');
            }
        }
        
        //Initially Override Pricing Checkbox is False
        deals = [Select Override_Pricing__c,(Select Override_Pricing__c From OpportunityLineItems) From Opportunity Where Id =: lstRentalDeals[1].Id];
        for(Opportunity deal : deals){
            system.assertEquals(false,deal.Override_Pricing__c);
            for(OpportunityLineItem dp : deal.OpportunityLineItems){
                system.assertEquals(false,dp.Override_Pricing__c);
            }
        }
        
        //Update Override Pricing checbox to true.
        deals[0].Override_Pricing__c = true;
        update deals;
        
        list<OpportunityLineItem> dealProducts = [Select Override_Pricing__c From OpportunityLineItem Where OpportunityId =: deals[0].Id];
        for(OpportunityLineItem dp : dealProducts){
            system.assertEquals(true,dp.Override_Pricing__c,'After Updating Override Pricing Checkbox to true on Deal all its Deal Products Override Pricing Checkbox should be set true');
        }
    }
    //US#207 starts
    /**
    *Description-The method is used to create test data and verify if expected functionality is covered 
    *@name-testData
    */
    
    static List<Opportunity> createdataforUpsert(){
        Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        Id rtAcDC =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Digital_Client'][0].Id;
        Product_Creation_Batch_Setting__c setting = new Product_Creation_Batch_Setting__c();
        setting.Name = 'Default';
        setting.Generate_CRM_Product__c = true;
        setting.Last_N_Days__c = 2;
        insert setting;
        
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(1,'ankitadilip.patil@cognizant.com','CRM');
        insert userList;
        System.assertEquals(1, [SELECT Id FROM Batch_Notification_Recipients__c].size());
        
        List<Account> accts1 = new List<Account>(); 
        
        accts1= CRM_TestDataFactory.createAccounts(1, false);
        accts1[0].RecordTypeID = rtAcDC;
        accts1[0].CurrencyIsoCode = 'USD';
        accts1[0].Price_Book__c = System.Test.getStandardPricebookId(); 
        accts1[0].Send_Pricing_to_CAS__c=true;
        
        insert accts1;
        
        system.assertequals(1,[select count() from account]);
        
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'Asia1', 'Asia2'}, 2, true);
        system.assertequals(2,[select count() from Country__c]);
        List<Title__c> titles = CRM_TestDataFactory.createTitles(1, false);
        titles[0].Video_Version__c = '99999999999999';
        titles[0].Digital_Planning__c = 'Yes';
        titles[0].Name = 'TestTitle';
        insert titles;
        system.assertequals(1,[select count() from Title__c]);
        
        List<Agreement__c> storeFronts = CRM_TestDataFactory.createStoreFronts(accts1, titles, countries, false);
        for(Integer Count = 0; Count < storeFronts.size(); Count++){
            storeFronts[count].CRM_Account__c = accts1[Count].Id;   
            storeFronts[count].Status__c = 'Active';
            storeFronts[count].Account__c = accts1[0].Id;
        }
        insert storeFronts;
        system.assertequals(1,[select count() from Agreement__c]);
        
        List<Pricing__c> prices = CRM_TestDataFactory.createPricings(2, true);
        system.assertequals(2,[select count() from Pricing__c]);
        
        List<Language__c> languages = CRM_TestDataFactory.createLanguages(1, true);
        system.assertequals(1,[select count() from Language__c]);         
        List<Local_Title__c> localTitles = CRM_TestDataFactory.createLocalTitles(countries, languages, 1, true);
        system.assertequals(2,[select count() from Local_Title__c]);
        //Create and Modify Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCount = 0;
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCount;
            objProduct.Product_Format__c = 'Blu-Ray'; 
            prodCount ++;
        }
        
        if(!lstProduct.isEmpty())   
            insert lstProduct;  
        system.assertequals(1,[select count() from Product2 where name like '%Product %']);
        //Create Price Book Entry Periods for the modified Products
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct,1,false);
        lstPriceBookEntryPeriod[0].Price_Book__c =System.Test.getStandardPricebookId();  
        insert lstPriceBookEntryPeriod;
        System.assertEquals(1, lstPriceBookEntryPeriod.size(), 'Created PriceBook Entry Periods' + lstPriceBookEntryPeriod.size());
        
        List<PricebookEntry> lstPriceBookEntry = [Select id,UnitPrice,CurrencyIsoCode,Product2Id,Pricebook2Id from PricebookEntry];
        
        //create deal
        Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(accts1,1,false);
        System.debug('lstOpportunity::'+lstOpportunity);
        lstOpportunity[0].Product_Type__c = 'Games Digital';
        lstOpportunity[0].recordTypeId = digitalRecordTypeId;
        System.debug('lstOpportunity ::'+lstOpportunity);
        insert lstOpportunity ;
        List<Opportunity> lstOppo =[select id,stagename from Opportunity]; 
        system.assertequals(1,lstOppo.size());
        system.debug('stagename*********************'+lstOppo[0].stagename);
        // create deal product        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);
        for (Integer j=0; j < lstDealProduct.size(); j++) {
            lstDealProduct[j].Pricebook_Entry_Period__c = lstPriceBookEntryPeriod[j].Id;
        }
        insert lstDealProduct;
        system.assertequals(1,[select count() from OpportunityLineItem]);
        return lstOppo;
    }
    
    static testmethod void testDataForCASUpsert(){  
        
        List<Opportunity> lstOppo =createdataforUpsert(); 
        // Make the deal as Committed
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size()); 
        
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
        System.assert(testUser.Id != null, 'User should get created');
        test.starttest();
        System.runas(testUser) {
            lstOppo[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update lstOppo;
        }
        test.stoptest();
        
    }
    //US#207 ends
    
    static testmethod void digitalDealDeletion_Test(){ //US#579
        
        createData();
        List<Opportunity> lstDeal = [SELECT Id, Start_Date__c, CloseDate FROM Opportunity LIMIT 1];
        lstDeal[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        lstDeal[0].Last_Approved_Date__c  = system.today(); 
        update lstDeal;
        try {
            Test.startTest();
            delete lstDeal;
            Test.stopTest();
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  (e.getMessage().contains('You cannot delete a digital deal if it has been committed.')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
    
    //Defect #4415: Overide Pricing checkbox is not automatically checked for JP
    private static testMethod void UpdateOverridePricingTrue_Test(){
        
        /*Creating Account*/  
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        insert lstAccounts;
        
        /*Creating Rental Deals*/
        List<Opportunity> lstRentalDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,false);
        lstRentalDeals[0].Market_Type__c = CRM_AppConstants.PRODUCT_SELL_THROUGH_MARKET_TYPE;
        lstRentalDeals[0].Override_Pricing__c = false;
        insert lstRentalDeals;
        
        test.startTest();
        lstRentalDeals[0].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        update lstRentalDeals;
        System.assertEquals(true, [Select Override_Pricing__c From Opportunity Where Id = :lstRentalDeals[0].Id].Override_Pricing__c);
        test.stopTest();
    } 
    
    //Defect #4415: Overide Pricing checkbox is not automatically checked for JP
    private static testMethod void UpdateOverridePricingFalse_Test(){
        
        /*Creating Account*/  
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        insert lstAccounts;
        
        /*Creating Rental Deals*/
        List<Opportunity> lstRentalDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,false);
        lstRentalDeals[0].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        lstRentalDeals[0].Override_Pricing__c = true;
        insert lstRentalDeals;
        System.debug('#Market_Type__c' + lstRentalDeals[0].Market_Type__c);
        System.debug('#Override_Pricing__c' + lstRentalDeals[0].Override_Pricing__c);
        test.startTest();
        lstRentalDeals[0].Market_Type__c = CRM_AppConstants.PRODUCT_SELL_THROUGH_MARKET_TYPE;
        update lstRentalDeals;
        System.debug('#Market_Type__c' + [Select Market_Type__c From Opportunity Where Id = :lstRentalDeals[0].Id].Market_Type__c);
        System.debug('#OverridePricing' + [Select Override_Pricing__c From Opportunity Where Id = :lstRentalDeals[0].Id].Override_Pricing__c);
        System.assertEquals(false, [Select Override_Pricing__c From Opportunity Where Id = :lstRentalDeals[0].Id].Override_Pricing__c);
        test.stopTest();
    }
    
    static testmethod void testaddChatterPostUSGames(){
        createData();
        List<Account> lstPhysicalAccounts = [Select Games_Digital__c,Games_Physical__c,Id From Account];
        for(Account acc : lstPhysicalAccounts){
            acc.Games_Digital__c = false;
            acc.Games_Physical__c = true;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        }
        update lstPhysicalAccounts;
        
        Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
        
        List<Opportunity> lstDeal141 = [SELECT Id, Name, StageName, Start_Date__c,Deal_Code__c, CloseDate FROM Opportunity Order BY Id];
        System.assertEquals(5, lstDeal141.size());
        for (Integer i = 0 ; i < lstDeal141.size(); i++) {
            Opportunity opp = lstDeal141[i];
            opp.StageName = 'Planned';
            opp.recordTypeId = digitalRecordTypeId;
            opp.Last_Approved_Co_op_Amount__c = 100;
        }
        Test.startTest();
        update lstDeal141;
        
        // Verify Deal Products are present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        
        // Verify no invalid deal products present
        System.assertEquals(0, [SELECT Id,Invalid_Deal_Product__c FROM OpportunityLineItem WHERE Invalid_Deal_Product__c = true].size());
        
        List<OpportunityLineItem> lstDeal151 = [SELECT Id, Name,Co_op_Actual_Amount__c FROM OpportunityLineItem Order BY Id];
        System.assertEquals(5, lstDeal151.size());
        for (Integer i = 0 ; i < lstDeal151.size(); i++) {
            OpportunityLineItem opp = lstDeal151[i];
            opp.Co_op_Actual_Amount__c = 5000;
        }
        update lstDeal151;
        
        List<OpportunityLineItem> lstDeal126 = [SELECT Id, Name,Co_op_Actual_Amount__c FROM OpportunityLineItem Order BY Id];
        System.assertEquals(5, lstDeal126.size());
        for (Integer i = 0 ; i < lstDeal126.size(); i++) {
            OpportunityLineItem opp = lstDeal126[i];
            opp.Co_op_Actual_Amount__c = 500000;
        }
        update lstDeal126;
        
        Test.stopTest();
        
    }
    
    /**
    *  Method to test the Pricebook Validation on Deal
    */
    private static testmethod void testDealPriceBookValidation(){
        createData();
        String errorMsg = '';
        
        List<Account> lstPhysicalAccounts = [Select Id, Name, Video_Physical__c, Sales_Organization__c From Account LIMIT 1];
        for(Account acc : lstPhysicalAccounts){
            acc.Video_Physical__c = true;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        }
        update lstPhysicalAccounts;
        
        Id posRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL).getRecordTypeId();
        
        Test.startTest();
        Opportunity opp = [SELECT Id, Name, StageName, Pricebook2Id, AccountId, SAP_Deal__c FROM Opportunity LIMIT 1];
        opp.RecordTypeId = posRecordTypeID;
        opp.AccountId = lstPhysicalAccounts[0].Id;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        
        try{
            update opp;
        }catch(Exception e){
            errorMsg = e.getMessage();
        }
        Test.stopTest();
        System.assert(errorMsg.contains(Label.CRM_Deal_Pricebook_Selection_Validation_Msg));
    }
    
    /**
    *  Method to test the Account selection Validation on Deal
    */
    private static testmethod void testDealAccountValidation(){
        createData();
        String errorMsg = '';
        
        List<Account> lstPhysicalAccounts = [Select Id, Name, Video_Physical__c, Sales_Organization__c From Account LIMIT 1];
        for(Account acc : lstPhysicalAccounts){
            acc.Video_Physical__c = false;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        }
        update lstPhysicalAccounts;
        
        Id posRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL).getRecordTypeId();
        
        Test.startTest();
        Opportunity opp = [SELECT Id, Name, StageName, Pricebook2Id, AccountId, SAP_Deal__c FROM Opportunity LIMIT 1];
        opp.RecordTypeId = posRecordTypeID;
        opp.AccountId = lstPhysicalAccounts[0].Id;
        opp.Pricebook2Id = [Select Id FROM Pricebook2 WHERE Name =: CRM_AppConstants.WBIE_US_PRICEBOOK_NAME LIMIT 1].Id;
        
        try{
            update opp;
        }catch(Exception e){
            errorMsg = e.getMessage();
        }
        Test.stopTest();
        System.assert(errorMsg.contains(Label.CRM_Wrong_Account_Selected));
    }
    //ER-006422 : UK - Forced EA Deal approval to Marketing
    static testmethod void testUpdateDealProductGroupOnDeal(){
         User testUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
         /*Creating Account*/  
         List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
         lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
         lstAccounts[0].Send_Pricing_to_CAS__c = false;
         insert lstAccounts;
         
         /*Creating Opportunity With Account (Deal)*/
         List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,false);
         for (Opportunity deal: lstDeals)
          deal.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
          
          insert lstDeals; 
          /*Creating Product with Product Group and Pricebook*/
          List<Product_Group__c> listProductGroups =   CRM_TestDataFactory.createProductGroups(1,true);
          System.assertEquals(1, listProductGroups.size(), 'Created ProductGroups');
        
          List<Product2> listProduct =   CRM_TestDataFactory.createProducts(listProductGroups,1,true);
          System.assertEquals(1, listProduct.size(), 'Created Products');
         
          List<PricebookEntry> listPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(listProduct,1,true);
          System.assertEquals(1, listPriceBookEntries.size(), 'Created Pricebook Entries');
        
          List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(listProduct, 1, false);
          for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            pbep.Start_Date__c = System.today() - 20;
            pbep.end_Date__c = System.today() + 120;
          }
        insert lstPriceBookEntryPeriod;

        /*Creating Opportunity Line Item (Deal Products)*/
        List<OpportunityLineItem> listDealProductsWithOpportunities = CRM_TestDataFactory.createDealProductsWithOpportunities(listPriceBookEntries,lstDeals,1,false);
        listDealProductsWithOpportunities[0].Quantity = 10;
        listDealProductsWithOpportunities[0].UnitPrice = 10;
        listDealProductsWithOpportunities[0].Account_Price__c= 10;
        listDealProductsWithOpportunities[0].Promoted_Price__c = 9;
        insert listDealProductsWithOpportunities;
        System.assertEquals(1, listPriceBookEntries.size(), 'Created Deal Products');

        Test.startTest();
        System.runAs(testUser){
        submitDealForApproval(lstDeals[0]);
          }
        Test.stopTest();
     }
    //ER-006422 ends  
}