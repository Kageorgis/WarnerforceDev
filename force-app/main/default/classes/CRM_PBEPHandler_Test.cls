/**
   @Author Aditi Satpute
   @name CRM_PBEPHandler_Test
   @CreateDate 23 Oct 2016
   @Description Test class for CRM_PBEPHandler
   @Version <1.0>
   @reference DEF#3713
 */

@isTest
public with sharing class CRM_PBEPHandler_Test {

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_After_Backdated_PBEP_With_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() - 130;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());
        lstOpportunity[0].Start_Date__c = System.today() + 141;
        lstOpportunity[0].Promo_Start_Date__c = System.today() + 142;
        lstOpportunity[0].Promo_End_Date__c = System.today() + 150;
        lstOpportunity[0].CloseDate = System.today() + 149;
        update lstOpportunity;

        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        
        Test.startTest();
        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    }
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_After_Future_PBEP_With_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());

        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        
        Test.startTest();
        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 135;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 145;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    }
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_But_Before_Future_PBEP_With_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());
        lstOpportunity[0].Start_Date__c = System.today() + 141;
        lstOpportunity[0].Promo_Start_Date__c = System.today() + 142;
        lstOpportunity[0].Promo_End_Date__c = System.today() + 150;
        lstOpportunity[0].CloseDate = System.today() + 149;
        update lstOpportunity;
        

        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        
        Test.startTest();
        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    }
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_But_Before_Backdated_PBEP_Without_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() - 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() - 130;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        // Verify Scenario 1 is not checked as true as PBEP Start Date < today>
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is not checked as Start Date < today and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());
        
        Test.startTest();
        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 135;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 145;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    countPBEP++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id) {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    countPBEP++;
                }
            }
        }
        System.assertEquals(2, countPBEP);

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }
    }
    
    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_But_After_Future_PBEP_Without_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());
        

        Test.startTest();
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_But_Before_Future_PBEP_Without_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 135;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 145;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());
        

        Test.startTest();
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                } else {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Single_PBEP_Inserted_With_Future_Date_Without_Existing_PBEP_And_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        Test.startTest();
        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        Test.stopTest();

        // Verify Process NR Batch checkbox is checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_But_Two_Before_Backdated_PBEP_Without_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() - 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() - 130;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].Start_Date__c = System.today() - 170;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].End_Date__c = System.today() - 160;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP2;

        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].isDuplicate__c = false;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].isDuplicate__c = true;
        update new List<Pricebook_Entry_Period__c> {lstPriceBookEntryPeriodNewlyInsertedPBEP1[0], lstPriceBookEntryPeriodNewlyInsertedPBEP2[0]};
        
        // Verify Scenario 1 is not checked as true as PBEP Start Date < today>
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is not checked as Start Date < today and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());
        
        Test.startTest();
        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 135;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 145;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    countPBEP++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id) {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    countPBEP++;
                }
            }
        }
        System.assertEquals(2, countPBEP);

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_But_Before_Backdated_PBEP_Without_Existing_Deal_And_DP_And_Multiple_Future_Present(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() - 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() - 130;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        //insert lstPriceBookEntryPeriodCreatedPBEP2;
        
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP3 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP3[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP3[0].Start_Date__c = System.today() + 40;
        lstPriceBookEntryPeriodCreatedPBEP3[0].End_Date__c = System.today() + 50;
        lstPriceBookEntryPeriodCreatedPBEP3[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP3[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP3[0].New_Release__c = true;
        insert new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriodCreatedPBEP2[0], lstPriceBookEntryPeriodCreatedPBEP3[0]};

        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].isDuplicate__c = false;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        lstPriceBookEntryPeriodCreatedPBEP2[0].isDuplicate__c = true;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Process_NR_Batch__c = false;
        lstPriceBookEntryPeriodCreatedPBEP3[0].isDuplicate__c = true;
        lstPriceBookEntryPeriodCreatedPBEP3[0].Process_NR_Batch__c = false;
        update new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriodNewlyInsertedPBEP1[0], lstPriceBookEntryPeriodCreatedPBEP2[0], lstPriceBookEntryPeriodCreatedPBEP3[0]};

        // Verify Scenario 1 is not checked as true as PBEP Start Date < today>
        List<Product2> lstProdExisting = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstProdExisting){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstProdExisting;

        // Verify Process NR Batch checkbox is not checked as Start Date < today and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                } else {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be false');
                }
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());
        
        Test.startTest();
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP4 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP4[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP4[0].Start_Date__c = System.today() + 160;
        lstPriceBookEntryPeriodCreatedPBEP4[0].End_Date__c = System.today() + 180;
        lstPriceBookEntryPeriodCreatedPBEP4[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP4[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP4[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP4;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.debug('--pbep--->'+pbep);
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    countPBEP++;
                } else {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    countPBEP++;
                }
            }
        }
        System.assertEquals(4, countPBEP);

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_With_Diff_Currency_Inserted_With_Future_Date_But_Before_Backdated_PBEP_Without_Existing_Deal_And_DP_And_Multiple_Future_Present(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() - 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() - 130;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        //insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1_1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].Start_Date__c = System.today() - 130;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].End_Date__c = System.today() - 10;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].New_Release__c = true;
        //insert lstPriceBookEntryPeriodNewlyInsertedPBEP1_1;

        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        //insert lstPriceBookEntryPeriodCreatedPBEP2;

        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2_1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2_1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2_1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2_1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2_1[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreatedPBEP2_1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2_1[0].New_Release__c = true;

        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP3 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP3[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP3[0].Start_Date__c = System.today() + 40;
        lstPriceBookEntryPeriodCreatedPBEP3[0].End_Date__c = System.today() + 50;
        lstPriceBookEntryPeriodCreatedPBEP3[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP3[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP3[0].New_Release__c = true;
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP3_1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP3_1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP3_1[0].Start_Date__c = System.today() + 40;
        lstPriceBookEntryPeriodCreatedPBEP3_1[0].End_Date__c = System.today() + 50;
        lstPriceBookEntryPeriodCreatedPBEP3_1[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreatedPBEP3_1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP3_1[0].New_Release__c = true;
        insert new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriodNewlyInsertedPBEP1[0], lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0], lstPriceBookEntryPeriodCreatedPBEP2[0], lstPriceBookEntryPeriodCreatedPBEP2_1[0], lstPriceBookEntryPeriodCreatedPBEP3_1[0], lstPriceBookEntryPeriodCreatedPBEP3[0]};

        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].isDuplicate__c = false;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        lstPriceBookEntryPeriodCreatedPBEP2[0].isDuplicate__c = true;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Process_NR_Batch__c = false;
        lstPriceBookEntryPeriodCreatedPBEP3[0].isDuplicate__c = true;
        lstPriceBookEntryPeriodCreatedPBEP3[0].Process_NR_Batch__c = false;
        
        lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].isDuplicate__c = false;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].Process_NR_Batch__c = false;
        lstPriceBookEntryPeriodCreatedPBEP2_1[0].isDuplicate__c = true;
        lstPriceBookEntryPeriodCreatedPBEP2_1[0].Process_NR_Batch__c = false;
        lstPriceBookEntryPeriodCreatedPBEP3_1[0].isDuplicate__c = true;
        lstPriceBookEntryPeriodCreatedPBEP3_1[0].Process_NR_Batch__c = false;
        update new List<Pricebook_Entry_Period__c>{
            lstPriceBookEntryPeriodNewlyInsertedPBEP1[0], lstPriceBookEntryPeriodCreatedPBEP2[0], lstPriceBookEntryPeriodCreatedPBEP3[0],
            lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0], lstPriceBookEntryPeriodCreatedPBEP2_1[0], lstPriceBookEntryPeriodCreatedPBEP3_1[0]
        };

        // Verify Scenario 1 is not checked as true as PBEP Start Date < today>
        List<Product2> lstProdExisting = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstProdExisting){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstProdExisting;

        // Verify Process NR Batch checkbox is not checked as Start Date < today and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id || pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1_1[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                } else {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be false');
                }
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());
        
        Test.startTest();
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP4 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP4[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP4[0].Start_Date__c = System.today() + 160;
        lstPriceBookEntryPeriodCreatedPBEP4[0].End_Date__c = System.today() + 180;
        lstPriceBookEntryPeriodCreatedPBEP4[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP4[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP4[0].New_Release__c = true;
        
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP4_1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP4_1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP4_1[0].Start_Date__c = System.today() + 160;
        lstPriceBookEntryPeriodCreatedPBEP4_1[0].End_Date__c = System.today() + 180;
        lstPriceBookEntryPeriodCreatedPBEP4_1[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreatedPBEP4_1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP4_1[0].New_Release__c = true;
        insert new List<Pricebook_Entry_Period__c> {lstPriceBookEntryPeriodCreatedPBEP4[0], lstPriceBookEntryPeriodCreatedPBEP4_1[0]};
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.debug('--pbep--->'+pbep);
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id || pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2_1[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    countPBEP++;
                } else {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    countPBEP++;
                }
            }
        }
        System.assertEquals(8, countPBEP);

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }
    }

   public static testMethod void Multiple_PBEP_Date_Changed_To_Future_Date_But_Before_First_PBEP_For_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        
        system.debug('lstPriceBookEntryPeriodNewlyInsertedPBEP1'+[Select Id,Price_Book__c,Product__c From Pricebook_Entry_Period__c Where Id IN :lstPriceBookEntryPeriodNewlyInsertedPBEP1]);
        
        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());
        lstOpportunity[0].Start_Date__c = System.today() + 141;
        lstOpportunity[0].Promo_Start_Date__c = System.today() + 142;
        lstOpportunity[0].Promo_End_Date__c = System.today() + 150;
        lstOpportunity[0].CloseDate = System.today() + 149;
        update lstOpportunity;
        
        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;

        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 350;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 450;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    countPBEP++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id) {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    countPBEP++;
                }
            }
        }
        System.assertEquals(2, countPBEP);
        Test.startTest();
        // Change Start Date for PBEP1
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        update lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP1 = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    countPBEP1++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id) {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    countPBEP1++;
                }
            }
        }
        System.assertEquals(2, countPBEP1);

        // Verify Product flags are set properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_With_Existing_Deal_And_DP_Date_Changed_To_Future_Date_But_Before_Additional_PBEP(){

        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        //lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        //update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 340;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 460;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    countPBEP++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id) {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    countPBEP++;
                }
            }
        }
        System.assertEquals(2, countPBEP);

        // Verify Product flags are set properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;

        Test.startTest();
        // Change Start Date for PBEP1
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP1 = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    countPBEP1++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id) {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    countPBEP1++;
                }
            }
        }
        System.assertEquals(2, countPBEP1);

        // Verify Product flags are set properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_With_Existing_Deal_And_DP_Date_Changed_To_Future_Date_But_After_Additioanl_PBEP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());

        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        Test.startTest();
        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 135;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 145;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        // insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Change Start Date for PBEP1
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 340;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 460;
        upsert new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriodCreatedPBEP2[0], lstPriceBookEntryPeriodNewlyInsertedPBEP1[0]};
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    countPBEP++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id) {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    countPBEP++;
                }
            }
        }
        System.assertEquals(2, countPBEP);

        // Verify Product flags are set properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_With_Existing_Deal_And_DP_Start_Date_Changed_From_Backdated_PBEP_To_Future_But_Before_Additional_PBEP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() - 130;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());
        lstOpportunity[0].Start_Date__c = System.today() + 141;
        lstOpportunity[0].Promo_Start_Date__c = System.today() + 142;
        lstOpportunity[0].Promo_End_Date__c = System.today() + 150;
        lstOpportunity[0].CloseDate = System.today() + 149;
        update lstOpportunity;

        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 160;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    }
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        // Change Start Date for PBEP1
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    }
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_With_Existing_Deal_And_DP_Start_Date_Changed_From_Backdated_PBEP_To_Future_But_After_Additional_PBEP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() - 130;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());
        lstOpportunity[0].Start_Date__c = System.today() + 141;
        lstOpportunity[0].Promo_Start_Date__c = System.today() + 142;
        lstOpportunity[0].Promo_End_Date__c = System.today() + 150;
        lstOpportunity[0].CloseDate = System.today() + 149;
        update lstOpportunity;

        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    }
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        // Change Start Date for PBEP1
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 160;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
      /*  for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                } else {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    }
            }
        }*/

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }
    
    public static testMethod void Multiple_PBEP_Start_Date_Changed_With_Future_Date_But_Before_Future_PBEP_Without_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 135;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 145;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 340;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 350;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        // Change Start Date for PBEP1
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        update lstPriceBookEntryPeriodCreatedPBEP2;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                } else {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_With_Date_Changed_To_Future_Date_But_Before_Additional_PBEP_Having_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP1[0].Start_Date__c = System.today() - 140;
        lstPriceBookEntryPeriodCreatedPBEP1[0].End_Date__c = System.today() - 130;
        lstPriceBookEntryPeriodCreatedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP1;

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].List_Price__c = 10;
        lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].New_Release__c = true;
        //lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].Process_NR_Batch__c = false;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP2;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP2);
        System.assertEquals(1, lstOpportunity.size());
        lstOpportunity[0].Start_Date__c = System.today() + 141;
        lstOpportunity[0].Promo_Start_Date__c = System.today() + 142;
        lstOpportunity[0].Promo_End_Date__c = System.today() + 150;
        lstOpportunity[0].CloseDate = System.today() + 149;
        update lstOpportunity;

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP1[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    countPBEP++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].Id) {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    countPBEP++;
                }
            }
        }
        System.assertEquals(2, countPBEP);

        // Verify Product flags are set properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;

        Test.startTest();
        // Change Start Date for PBEP2
        lstPriceBookEntryPeriodCreatedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP1[0].End_Date__c = System.today() + 30;
        update lstPriceBookEntryPeriodCreatedPBEP1;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        Integer countPBEP1 = 0;
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP1[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    countPBEP1++;
                } else if (pbep.Id == lstPriceBookEntryPeriodNewlyInsertedPBEP2[0].Id) {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    countPBEP1++;
                }
            }
        }
        System.assertEquals(2, countPBEP1);

        // Verify Product flags are set properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_Start_Date_Changed_With_Future_Date_But_Before_After_PBEP_Without_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        // Change Start Date for PBEP1
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 350;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 360;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                } else {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Multiple_PBEP_Start_Date_Changed_With_Duplicate_PBEP_Future_Date_But_Before_After_PBEP_Without_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() - 130;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() - 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].isDuplicate__c = true;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;


        // Verify Process NR Batch checkbox is not checked and isDuplicate is true
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                } else {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        // Change Start Date for PBEP2
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        Test.stopTest();

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
    }
}