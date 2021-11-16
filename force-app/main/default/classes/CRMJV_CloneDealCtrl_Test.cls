/**
   @Author-Cognizant Technology Solutions
   @name-CRMJV_CloneDealCtrl_Test
   @CreateDate-Date> 15 June 2021
   @Description-Test Class to cover different scenarios that will occur for CRMJV_CloneDealCtrl
   @Version-<1.0>
   @reference-ER-007269
  */
@isTest(seeAllData=false)
public class CRMJV_CloneDealCtrl_Test{
    public static List<Product2> products =new List<Product2>();
    public static List<Product2> nonipproducts =new List<Product2>();
    public static List<OpportunityLineItem> dealProds = new List<OpportunityLineItem>();

    public static Id priceBookJVId;
    public static Id priceBookNonIPJVId;
    static{
        if(priceBookJVId == null){
            priceBookJVId = createPriceBookForJV().Id;
        }
        if(priceBookNonIPJVId == null){
            priceBookNonIPJVId = createNonIPPriceBookForJV().Id;
        }
    }
    
    /* createPriceBookForJV()
     * This method is called to create JV PriceBook for a test class.
     * SalesOrg = number of records to be created.
     * shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static Pricebook2 createPriceBookForJV(){
        Pricebook2 JVPricebook = new Pricebook2(
            Name = 'SDS - US',
            IsActive = true,
            Business_Unit__c = CRM_AppConstants.TERRITORY_SDS_US_CODE,
            External_Id__c = CRM_AppConstants.TERRITORY_SDS_US_CODE + '-10',
            Product_Type__c = 'Physical',
            Country__c = 'USA'
        );
        insert JVPricebook;
        system.assertNotEquals(null, JVPricebook);
        return JVPricebook;
    }

    /* createPriceBookForJV()
     * This method is called to create JV PriceBook for a test class.
     * SalesOrg = number of records to be created.
     * shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static Pricebook2 createNonIPPriceBookForJV(){
        Pricebook2 JVNonIPPricebook = new Pricebook2(
            Name = 'SDS Non-IP - US',
            IsActive = true,
            Business_Unit__c = CRM_AppConstants.TERRITORY_SDS_US_CODE,
            External_Id__c = CRM_AppConstants.TERRITORY_SDS_US_CODE + '-10-NONIP',
            Product_Type__c = 'Physical',
            Country__c = 'USA'
        );
        insert JVNonIPPricebook;
        system.assertNotEquals(null, JVNonIPPricebook);
        return JVNonIPPricebook;
    }

    static void testDataForJV(){
        User u = CRM_TestDataFactory.createUser('System Administrator', true);
        system.runAs(u){
            //create account 
            List<Account> accList = new List<Account>();
            List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            lstAccount[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount[0].Class_of_Trade__c ='Retail Cost';
            lstAccount[0].AccountNumber ='1234567891';
            lstAccount[0].Price_Book__c = priceBookJVId;
            accList.addAll(lstAccount);

            List<Account> lstAccount1 = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount1[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            lstAccount1[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount1[0].Class_of_Trade__c ='WHOLESALE 5';
            lstAccount1[0].AccountNumber ='1234567892';
            lstAccount1[0].Price_Book__c = priceBookJVId;
            accList.addAll(lstAccount1);

            List<Account> lstAccount2 = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount2[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_CANADA_CODE;
            lstAccount2[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount2[0].Class_of_Trade__c ='Retail Cost';
            lstAccount2[0].AccountNumber ='1234567893';
            lstAccount2[0].Price_Book__c = priceBookJVId;
            accList.addAll(lstAccount2);

            List<Account> lstAccount3 = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount3[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            lstAccount3[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount3[0].Class_of_Trade__c ='WHOLESALE 5';
            lstAccount3[0].AccountNumber ='1234567894';
            lstAccount3[0].Price_Book__c = null;
            accList.addAll(lstAccount3);

            List<Account> lstAccount9 = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount9[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            lstAccount9[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount9[0].Class_of_Trade__c ='WHOLESALE 5';
            lstAccount9[0].AccountNumber ='1234567899';
            lstAccount9[0].Price_Book__c = priceBookNonIPJVId;
            accList.addAll(lstAccount9);
            insert accList;
            system.assertEquals(CRM_AppConstants.TERRITORY_SDS_US_CODE, lstAccount[0].Sales_Organization__c);

            // Create Product and Prices
            integer intCount = 0;
            products = CRM_TestDataFactory.createProducts(5, false);
            for(Product2 prod : products) {
                prod.ProductCode = '10000' + intCount;
                prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
                prod.Product_Format__c = 'DVD';
                prod.isActive = true;
                intCount++;
            } 
            insert products;

            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1 , true); 
            System.assertEquals(5,pricebookentries.size());

            List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, false);
            for(PricebookEntry pbe : customLstPriceBookEntries){
                pbe.Pricebook2Id = priceBookJVId;
            }
            insert customLstPriceBookEntries;

            list<Pricebook_Entry_Period__c> pricebookentryPeriod= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod){
                pebp.Price_Type__c = 'WHOLESALE 5';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookJVId;
            }
            insert pricebookentryPeriod;
            System.assertEquals(5,pricebookentryPeriod.size());

            list<Pricebook_Entry_Period__c> pricebookentryPeriod1= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
                pebp.Price_Type__c = 'PROMOTION';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookJVId;
            }
            insert pricebookentryPeriod1;
            System.assertEquals(5,pricebookentryPeriod1.size());

            list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
                pebp.Price_Type__c = 'DEALER';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookJVId;
            }
            insert pricebookentryPeriod2;
            System.assertEquals(5,pricebookentryPeriod2.size());

            // Create Non IP Product and Prices
            integer intCount9 = 0;
            nonipproducts = CRM_TestDataFactory.createProducts(1, false);
            for(Product2 prod : nonipproducts) {
                prod.Name = 'Non IP 10000' + intCount9;
                prod.ProductCode = '10000' + intCount9;
                prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
                prod.Product_Format__c = 'DVD';
                prod.isActive = true;
                prod.External_Id__c = 'NONIP-10000' + intCount9;
                intCount9++;
            } 
            insert nonipproducts;

            List<PricebookEntry> pricebookentries9 = CRM_TestDataFactory.createPriceBookEntries(nonipproducts, 1 , true); 
            System.assertEquals(1,pricebookentries9.size());

            List<PricebookEntry> customLstPriceBookEntries9 = CRM_TestDataFactory.createPriceBookEntries(nonipproducts, 1, false);
            for(PricebookEntry pbe : customLstPriceBookEntries9){
                pbe.Pricebook2Id = priceBookNonIPJVId;
            }
            insert customLstPriceBookEntries9;

            list<Pricebook_Entry_Period__c> pricebookentryPeriod9= CRM_TestDataFactory.createPriceBookEntryPeriods(nonipproducts, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod9){
                pebp.Price_Type__c = 'WHOLESALE 5';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookNonIPJVId;
            }
            insert pricebookentryPeriod9;
            System.assertEquals(1,pricebookentryPeriod9.size());

            list<Pricebook_Entry_Period__c> pricebookentryPeriod19= CRM_TestDataFactory.createPriceBookEntryPeriods(nonipproducts, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod19){
                pebp.Price_Type__c = 'PROMOTION';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookNonIPJVId;
            }
            insert pricebookentryPeriod19;
            System.assertEquals(1,pricebookentryPeriod19.size());

            list<Pricebook_Entry_Period__c> pricebookentryPeriod29= CRM_TestDataFactory.createPriceBookEntryPeriods(nonipproducts, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod29){
                pebp.Price_Type__c = 'DEALER';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookNonIPJVId;
            }
            insert pricebookentryPeriod29;
            System.assertEquals(1,pricebookentryPeriod29.size());

            //create deal
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            lstOpportunity[0].Start_date__c = System.today();  
            lstOpportunity[0].CloseDate = System.today()+15;
            lstOpportunity[0].Promo_Start_Date__c = System.today();
            lstOpportunity[0].Promo_End_Date__c = System.today()+15;
            lstOpportunity[0].Pricebook2Id = priceBookJVId;
            //lstOpportunity[0].CurrencyIsoCode = 'USD';
            //lstOpportunity[0].Account
            insert lstOpportunity;
            List<Opportunity> opp = [select id,RecordTypeId from Opportunity where id IN: lstOpportunity];
            system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, opp[0].RecordTypeId);

            dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpportunity, 5, false);
            for(Integer nProductCount = 0; nProductCount < products.size(); nProductCount++){ 
                for(OpportunityLineItem oli : dealProds) {
                    oli.Reason__c = 'POS Rebate';
                    oli.Product2Id = products[nProductCount].Id;
                    oli.Comments__c = 'Test Comment';
                    oli.Pricebook_Entry_Period__c = pricebookentryPeriod[nProductCount].Id;
                    oli.Dollar_of_Discount__c = 3;
                    oli.Customer_Reference__c = 'Test Reference';
                    oli.Start_Date__c = lstOpportunity[0].Start_date__c;    //Date.today().addDays(-1);
                    oli.End_Date__c = lstOpportunity[0].CloseDate;          //Date.today().addDays(14);
                }
            }
            insert dealProds;
            System.assertEquals(5,dealProds.size());
        }
    }

    private static testmethod void testDealCloneWithSameAccount(){
        testDataForJV();
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstOpp[0].AccountId;
        dealWrapperSameAccount.accountName = lstOpp[0].Account.Name;

        Test.startTest();
        Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);
        System.assertNotEquals(null, cloneDeal, 'Opportunity Copied Successfully');

        CRMJV_CloneDealCtrl.cloneDealProducts(cloneDeal.Id, lstOpp[0].Id);
        Test.stopTest();

        System.assertEquals(lstOpp[0].Count_Opportunity_Products__c, [Select Count_Opportunity_Products__c From Opportunity Where Id =: cloneDeal.Id].Count_Opportunity_Products__c);
    }

    private static testmethod void testDealCloneWithSameTerritoryAccount(){
        testDataForJV();
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];
        List<Account> lstNewAccounts = [Select Id,Name,Price_Book__c,CurrencyIsoCode,Sales_Organization__c,Class_of_Trade__c From Account Where AccountNumber ='1234567892'];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameTerritoryAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameTerritoryAccount.dealId = lstOpp[0].id;
        dealWrapperSameTerritoryAccount.accountId = lstNewAccounts[0].Id;
        dealWrapperSameTerritoryAccount.accountName = lstNewAccounts[0].Name;

        Test.startTest();
        Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameTerritoryAccount);
        System.assertEquals(lstNewAccounts[0].Id, [Select AccountId From Opportunity Where Id =: cloneDeal.Id].AccountId, 'Opportunity Copied Successfully with new Account');

        CRMJV_CloneDealCtrl.cloneDealProducts(cloneDeal.Id, lstOpp[0].Id);
        Test.stopTest();

        System.assertEquals(lstOpp[0].Count_Opportunity_Products__c, [Select Count_Opportunity_Products__c From Opportunity Where Id =: cloneDeal.Id].Count_Opportunity_Products__c);
    }

    private static testmethod void testDealCloneWithBlankAccount(){
        testDataForJV();
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = null;
        dealWrapperSameAccount.accountName = null;

        Test.startTest();
        try{
            Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);        
        }catch(Exception e){
            System.assertEquals(e.getMessage(),System.label.CRM_Clone_Deal_Account_Is_Mandatory_Error);
        }
        Test.stopTest();
    }

    private static testmethod void testDealCloneWithBlankAccountPricebook(){
        testDataForJV();
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];
        List<Account> lstNewAccounts = [Select Id,Name,Price_Book__c,CurrencyIsoCode,Sales_Organization__c,Class_of_Trade__c From Account Where AccountNumber ='1234567894'];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstNewAccounts[0].Id;
        dealWrapperSameAccount.accountName = lstNewAccounts[0].Name;

        Test.startTest();
        try{
            Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);        
        }catch(Exception e){
            System.assertEquals(e.getMessage(),System.label.CRM_PriceBook_Not_Present_On_Account);
        }
        Test.stopTest();
    }

    private static testmethod void testDealCloneWithDiffTerritoryInAccount(){
        testDataForJV();
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];
        List<Account> lstNewAccounts = [Select Id,Name,Price_Book__c,CurrencyIsoCode,Sales_Organization__c,Class_of_Trade__c From Account Where AccountNumber ='1234567893'];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstNewAccounts[0].Id;
        dealWrapperSameAccount.accountName = lstNewAccounts[0].Name;

        Test.startTest();
        try{
            Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);
        }catch(Exception e){
            System.assertEquals(e.getMessage(),System.label.CRMJV_Clone_Deal_Current_Selected_Account_Territory_Different);
        }
        Test.stopTest();
    }

    private static testmethod void testDealCloneWithNRDeal(){
        testDataForJV();
        Test.startTest();

        List<Opportunity> lstOpp = [SELECT Id,AccountId,Account.Name,NR_Deal_Unique_Key__c,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];
        lstOpp[0].NR_Deal_Unique_Key__c = 'TestNRDeal';
        update lstOpp[0];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstOpp[0].AccountId;
        dealWrapperSameAccount.accountName = lstOpp[0].Account.Name;

        try{
            Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);
        }catch(Exception e){
            System.assertEquals(e.getMessage(),System.label.CRM_NR_Deals_Cannot_Be_Cloned_Error);
        }
        Test.stopTest();
    }

    private static testmethod void testDealCloneWhichIsInProgress(){
        testDataForJV();
        Test.startTest();

        List<Opportunity> lstOpp = [SELECT Id,AccountId,Account.Name,NR_Deal_Unique_Key__c,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];
        lstOpp[0].Clone_Deal__c = true;
        update lstOpp[0];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstOpp[0].AccountId;
        dealWrapperSameAccount.accountName = lstOpp[0].Account.Name;

        try{
            Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);
        }catch(Exception e){
            System.assertEquals(e.getMessage(),System.label.CRMJV_Clone_Deal_Batch_Inprogress);
        }
        Test.stopTest();
    }

    private static testmethod void testDealCloneWithDealProductWithErrors(){
        testDataForJV();
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];
        List<Product2> ProdListtoUpdate = new List<Product2>();

        for(Product2 prod: [Select Id,ProductCode,SAP_Dist_chain_product_Status__c,isActive From Product2 Where ProductCode in ('100000','100001')]){
            prod.isActive = false;            
            ProdListtoUpdate.add(prod);
        }
        update ProdListtoUpdate;

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstOpp[0].AccountId;
        dealWrapperSameAccount.accountName = lstOpp[0].Account.Name;

        Test.startTest();
        Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);
        System.assertNotEquals(null, cloneDeal, 'Opportunity Copied Successfully');

        CRMJV_CloneDealCtrl.cloneDealProducts(cloneDeal.Id, lstOpp[0].Id);
        Test.stopTest();

        System.assertEquals(3, [Select Success_Count__c From UploadObject__c Where DealId__c =: cloneDeal.Id LIMIT 1].Success_Count__c);
        System.assertEquals((Integer.valueOf(lstOpp[0].Count_Opportunity_Products__c - 2)),[Select Count_Opportunity_Products__c From Opportunity Where Id =: cloneDeal.Id].Count_Opportunity_Products__c);
    }

    private static testmethod void testDealCloneWithSameTerritoryDifferentPricebook(){
        testDataForJV();

        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name,Count_Opportunity_Products__c,Clone_Deal__c,Pricebook2Id FROM Opportunity LIMIT 1];
        List<Account> lstNewAccounts = [Select Id,Name,Price_Book__c,CurrencyIsoCode,Sales_Organization__c,Class_of_Trade__c From Account Where AccountNumber ='1234567899'];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);

        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstNewAccounts[0].Id;
        dealWrapperSameAccount.accountName = lstNewAccounts[0].Name;

        Test.startTest();
        Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);
        System.assertNotEquals(null, cloneDeal , 'Opportunity Copied Successfully');

        CRMJV_CloneDealCtrl.cloneDealProducts(cloneDeal.Id, lstOpp[0].Id);
        Test.stopTest();

        List<OpportunityLineItem> cloneOli = [Select Opportunity.Pricebook2Id From OpportunityLineItem Where OpportunityId =: cloneDeal.Id];
        System.assertNotEquals(lstOpp[0].Pricebook2Id, cloneOli[0].Opportunity.Pricebook2Id, 'Opportunity Copied Successfully With Opportunity Product');
    }

    static void testBulkDataForJV(){
        User u = CRM_TestDataFactory.createUser('System Administrator', true);
        system.runAs(u){
            integer num = 100;
            //create account  
            List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            lstAccount[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount[0].Class_of_Trade__c ='Retail Cost';
            lstAccount[0].AccountNumber ='123456789';
            lstAccount[0].Price_Book__c = priceBookJVId;
            insert lstAccount;
            system.assertEquals(CRM_AppConstants.TERRITORY_SDS_US_CODE, lstAccount[0].Sales_Organization__c);
            Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>();

            //create deal
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            lstOpportunity[0].Start_date__c = System.today();  
            lstOpportunity[0].CloseDate = System.today()+15;
            lstOpportunity[0].Promo_Start_Date__c = System.today();
            lstOpportunity[0].Promo_End_Date__c = System.today()+15;
            lstOpportunity[0].Pricebook2Id = priceBookJVId;
            //lstOpportunity[0].CurrencyIsoCode = 'USD';
            //lstOpportunity[0].Account
            insert lstOpportunity;
            List<Opportunity> opp =[select id,RecordTypeId from Opportunity where id IN: lstOpportunity];
            system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, opp[0].RecordTypeId);

            integer intCount = 0;
            products = CRM_TestDataFactory.createProducts(num, false);
            for(Product2 prod : products) {
                prod.ProductCode = '10000' + intCount;
                prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
                prod.Product_Format__c = 'DVD';
                prod.isActive = true;
                intCount++;
            }
            insert products;
            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1 , true); 
            System.assertEquals(num,pricebookentries.size());

            List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, false);
            for(PricebookEntry pbe : customLstPriceBookEntries){
                pbe.Pricebook2Id = priceBookJVId;
            }
            insert customLstPriceBookEntries;

            list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
                pebp.Price_Type__c = 'DEALER';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookJVId;
            }
            insert pricebookentryPeriod2;

            List<OpportunityLineItem> l1 = new List<OpportunityLineItem>();
            List<OpportunityLineItem> l2 = new List<OpportunityLineItem>();
            dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpportunity, num, false);
            for(Integer nProductCount = 0; nProductCount < products.size(); nProductCount++){
                for(OpportunityLineItem oli : dealProds) {
                    oli.Reason__c = 'POS Rebate';
                    oli.Product2Id = products[nProductCount].Id;
                    oli.Comments__c = 'Test Comment';
                    oli.Pricebook_Entry_Period__c = pricebookentryPeriod2[nProductCount].Id;
                    oli.Dollar_of_Discount__c = 3;
                    oli.Customer_Reference__c = 'Test Reference';
                    oli.Start_date__c = lstOpportunity[0].Start_date__c;    //Date.today().addDays(-1);
                    oli.End_date__c = lstOpportunity[0].CloseDate;          //Date.today().addDays(14);
                }
            }
            integer j = 1;
            for(OpportunityLineItem o: dealProds){
                if(j<=100){l1.add(o);}else{l2.add(o);}
                j++;
            }
            Test.startTest();
            insert l1;
            insert l2;
            System.assertEquals(num,dealProds.size());
            Test.stopTest();
        }
    }

    private static testmethod void testDealCloneWithBulkDataWithSameAccount(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testBulkDataForJV();

        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name,Count_Opportunity_Products__c,Clone_Deal__c FROM Opportunity LIMIT 1];

        Test.setCurrentPageReference(Page.CRMJV_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRMJV_CloneDealCtrl ctrl = new CRMJV_CloneDealCtrl(sc);
        
        CRMJV_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRMJV_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstOpp[0].AccountId;
        dealWrapperSameAccount.accountName = lstOpp[0].Account.Name;

        Opportunity cloneDeal = CRMJV_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);
        System.assertNotEquals(null, cloneDeal , 'Opportunity Copied Successfully');

        CRMJV_CloneDealCtrl.cloneDealProducts(cloneDeal.Id, lstOpp[0].Id);
    }
}