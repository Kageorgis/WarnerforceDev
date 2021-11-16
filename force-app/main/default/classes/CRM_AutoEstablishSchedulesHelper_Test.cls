/**
   @Author Cognizant
   @name CRM_AutoEstablishSchedulesHelper_Test
   @CreateDate 18/2/2016
   @Description Test class for CRM_AutoEstablishSchedulesHelper
   @Version <1.0>
   @reference
  */
@isTest
public with sharing class CRM_AutoEstablishSchedulesHelper_Test{
    
    // W-017642- Start - Added pricebooks for JV orgs
    public static Id priceBookUSJVId;
    public static Id priceBookCANJVId;
    static {
        if(priceBookUSJVId == null) {
            priceBookUSJVId = createUSPriceBookForJV().Id;
        }
        if(priceBookCANJVId == null) {
            priceBookCANJVId = createCANPriceBookForJV().Id;
        }
        
    }
    
    /* createUSPriceBookForJV()
     * This method is called to create JV PriceBook of US for a test class.
     */
    public static Pricebook2 createUSPriceBookForJV(){
        Pricebook2 JVPricebook = new Pricebook2(
            Name='SDS - US',
            IsActive=true,
            Business_Unit__c = CRM_AppConstants.TERRITORY_SDS_US_CODE,
            External_Id__c = CRM_AppConstants.TERRITORY_SDS_US_CODE + '-10',
            Product_Type__c='Physical',
            Country__c = 'USA'
        );
        insert JVPricebook;
		system.assertNotEquals(null, JVPricebook);
        return JVPricebook;
    }
    
     /* createCANPriceBookForJV()
     * This method is called to create CAN PriceBook of US for a test class.
     */
    public static Pricebook2 createCANPriceBookForJV(){
        Pricebook2 JVPricebook = new Pricebook2(
            Name='SDS - CAN',
            IsActive=true,
            Business_Unit__c = CRM_AppConstants.TERRITORY_SDS_CANADA_CODE,
            External_Id__c = CRM_AppConstants.TERRITORY_SDS_CANADA_CODE + '-10',
            Product_Type__c='Physical',
            Country__c = 'CAN'
        );
        insert JVPricebook;
		system.assertNotEquals(null, JVPricebook);
        return JVPricebook;
    }
    // W-017642- End - Added pricebooks for JV orgs

    /*Create Dummy Data Using CRM_TestDataFactory Class*/
    public static TestDataWrapper createData() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(5,false);
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        //List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,5,false);
        List<Product2> lstProduct =
            CRM_AutoPhysicalNRDealCreateService_Test.createProductsForNRBatch(lstProGrp, lstAccounts);
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false); 
        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].Status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate; 
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        Id digitalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        Id physicalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        Id physicalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        System.debug('--lstDecayCurveItem-->'+lstDecayCurveItem);
        System.assertEquals(5, lstAccounts.size());
        /*Setting Up the Account Data*/
        for(Account a: lstAccounts){
            a.Storefront__c = storefronts[0].Id;
            a.recordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            a.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[1].Games_Digital__c = true;
        lstAccounts[2].Video_Physical__c = true;
        lstAccounts[3].Video_Digital__c = true;
        lstAccounts[4].Video_Digital__c = true;
        lstAccounts[4].scheduleRevenueChanged__c  = false;
        insert lstAccounts;

        System.debug('lstAccounts::'+lstAccounts.size());
        /*Setting up the product data
        lstProduct[0].Type__c = 'Games Physical';
        lstProduct[0].RecordTypeId = physicalProductRecordTypeId;
        lstProduct[1].Type__c = 'Games Digital';
        lstProduct[1].RecordTypeId = digitalProductRecordTypeId;
        lstProduct[2].Type__c = 'Video Physical';
        lstProduct[2].RecordTypeId = physicalProductRecordTypeId;
        lstProduct[3].Type__c = 'Video Digital EST';
        lstProduct[3].RecordTypeId = digitalProductRecordTypeId;
        lstProduct[4].Type__c = 'Video Digital VODi';
        lstProduct[4].RecordTypeId = digitalProductRecordTypeId;
        for(Product2 p : lstProduct){
            //p.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            p.Street_Date__c = system.today()+1;
            p.NR_Product_Created__c = true;
            p.Street_Date_Has_Changed__c = false;
            p.CurrencyIsoCode = 'USD';
            p.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        }
        insert lstProduct;

        System.debug('lstProduct::'+lstProduct.size());*/

        //System.assertEquals(200,lstPriceBookEntry.size(),'Created 200 Enteries');
        /*Setting up opportunity Data*/
        for(Integer i=0 ;i<lstOpportunity.size();i++){
            lstOpportunity[i].CurrencyIsoCode = 'USD';
            String strdealProductType = '';
            if (lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = lstProduct[i].Type__c;
            }
            lstOpportunity[i].Product_Type__c = strdealProductType;
            lstOpportunity[i].AccountId = lstAccounts[i].Id;
            if (digitalDealRecordTypeId != null && physicalDealRecordTypeId != null) {
                if(lstOpportunity[i].Product_Type__c!= null){
                    if(lstOpportunity[i].Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || lstOpportunity[i].Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                        lstOpportunity[i].RecordtypeId = digitalDealRecordTypeId;
                    }else{
                        lstOpportunity[i].RecordtypeId = physicalDealRecordTypeId;
                    }
                }
            }
        }
        System.debug('lstOpportunity::'+lstOpportunity);
        insert lstOpportunity;
        System.debug('lstOpportunity::'+lstOpportunity.size());
        for(Integer i=0 ;i<lstPriceBookEntry.size();i++){
            lstPriceBookEntry[i].Product2Id = lstProduct[i].id;
        }
        insert lstPriceBookEntry;
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry.size());

        /*Setting up PriceBookEntryPeriod Data*/
        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = lstProduct[i].id;
            lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'USD';
            lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+1;
            lstPriceBookEntryPeriod[i].End_Date__c = System.today() +100;
            lstPriceBookEntryPeriod[i].List_Price__c = 10;
            if (lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                lstPriceBookEntryPeriod[i].New_Release__c = true;
            }
        }
        insert lstPriceBookEntryPeriod;

        TestDataWrapper tw = new TestDataWrapper();
        tw.lstAccounts = lstAccounts;
        tw.lstOpportunity = lstOpportunity;
        tw.lstProduct = lstProduct;
        tw.lstPriceBookEntry = lstPriceBookEntry;
        tw.lstDecayCurveTemplate = lstDecayCurveTemplate;
        tw.lstDecayCurveItem = lstDecayCurveItem;
        tw.lstPriceBookEntryPeriod = lstPriceBookEntryPeriod;

        return tw;
    }

    /*W-017642 - Start - Create Dummy Data of US for JV Orgs Using CRM_TestDataFactory Class*/
    public static TestDataWrapper createUSDataForJV() {
        
        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].Status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate; 
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);        
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUTil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Class_of_Trade__c = 'Wholesale 5';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
        lstAccounts[0].Decay_Curve_Template__c = lstDecayCurveTemplate[0].ID;
        lstAccounts[0].Sales_Organization__c = '9500';
        lstAccounts[0].Price_Book__c = priceBookUSJVId;
        insert lstAccounts;
        system.assertEquals(CRM_AppConstants.TERRITORY_SDS_US_CODE, lstAccounts[0].Sales_Organization__c);
        
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 2, false);
        
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
            deal.Promo_Start_Date__c = Date.today().addDays(-15);
            deal.Promo_End_Date__c = Date.today().addDays(15);
            deal.Start_Date__c = Date.today().addDays(-15);
            deal.CloseDate = Date.today().addDays(15);
            deal.Price_Type__c = 'ZPRD';
            deal.Pricebook2Id = priceBookUSJVId;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[0].RecordTypeId);
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 5, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prodInstance.CurrencyIsoCode = 'USD';
            prodInstance.CanUseQuantitySchedule = true;
            prodInstance.CanUseRevenueSchedule = true;
        }
        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        System.assertEquals(5,lstPriceBookEntries.size());
        
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries) {
            pbe.Pricebook2Id = priceBookUSJVId;
        }
        insert customLstPriceBookEntries;
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : lstPriceBookEntryPeriod){
            pebp.Price_Type__c = 'Wholesale 5';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            pebp.Price_Book__c = priceBookUSJVId;
        }
        insert lstPriceBookEntryPeriod;
        System.assertEquals(5,lstPriceBookEntryPeriod.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod1= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookUSJVId;
        }
        insert pricebookentryPeriod1;
        System.assertEquals(5,pricebookentryPeriod1.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookUSJVId;
        }
        insert pricebookentryPeriod2;
        System.assertEquals(5,pricebookentryPeriod2.size());
        
        List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstDeals, 5, false);
        for(Integer nProductCount = 0; nProductCount < lstProduct.size(); nProductCount++){ 
            for(OpportunityLineItem oli : lstDealProducts) {
                oli.Start_Date__c = Date.today().addDays(-15);
                oli.End_Date__c = Date.today().addDays(15);
                oli.Initial_Ship_Fcst__c = 100;
                oli.Replen_Ship_Fcst__c = 200;
                oli.Reason__c = 'DFI';
                oli.Account_Fund_Segment__c = 'NAT'; 
                oli.ListPrice__c = 30;
            }
        }
        insert lstDealProducts;
        system.debug('@@** lstDealProducts --> ' + lstDealProducts);
        System.assertEquals(10,lstDealProducts.size());   
        
        // Insert max Product limit per page
        //CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        TestDataWrapper tw = new TestDataWrapper();
        tw.lstAccounts = lstAccounts;
        tw.lstOpportunity = lstDeals;
        tw.lstProduct = lstProduct;
        tw.lstPriceBookEntry = lstPriceBookEntries;
        tw.lstDecayCurveTemplate = lstDecayCurveTemplate;
        tw.lstDecayCurveItem = lstDecayCurveItem;
        tw.lstPriceBookEntryPeriod = lstPriceBookEntryPeriod;
        tw.lstDealProducts = lstDealProducts;
        return tw;
    }
    /*W-017642 - End - Create Dummy Data of US for JV Orgs Using CRM_TestDataFactory Class*/
    
    /*W-017642 - Start - Create Dummy Data of CAN for JV Orgs Using CRM_TestDataFactory Class*/
    public static TestDataWrapper createCANDataForJV() {
        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].Status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate; 
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);        
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUTil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Class_of_Trade__c = 'Wholesale 5';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_CANADA_CODE;
        lstAccounts[0].Decay_Curve_Template__c = lstDecayCurveTemplate[0].ID;
        lstAccounts[0].Price_Book__c = priceBookCANJVId;
        lstAccounts[0].CurrencyIsoCode ='CAD';
        insert lstAccounts;
        system.assertEquals(CRM_AppConstants.TERRITORY_SDS_CANADA_CODE, lstAccounts[0].Sales_Organization__c);
                
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 2, false);
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
            deal.Promo_Start_Date__c = Date.today().addDays(-15);
            deal.Promo_End_Date__c = Date.today().addDays(15);
            deal.Start_Date__c = Date.today().addDays(-15);
            deal.CloseDate = Date.today().addDays(15);
            deal.Price_Type__c = 'ZPRD';
            deal.Pricebook2Id = priceBookCANJVId;
            deal.CurrencyIsoCode = 'CAD';
        }
        insert lstDeals;
	    system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[0].RecordTypeId);
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, false);
        lstProductGroup[0].CurrencyIsoCode = 'CAD';
        insert lstProductGroup;
        
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 5, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_CANADA_CODE;
            prodInstance.CurrencyIsoCode = 'CAD';
            prodInstance.CanUseQuantitySchedule = true;
            prodInstance.CanUseRevenueSchedule = true;
            prodInstance.ProductCode = String.valueOf(Math.random()).subString(0,6);
        }
        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pbe : lstPriceBookEntries) {
            pbe.CurrencyIsoCode = 'CAD';
        }
        insert lstPriceBookEntries;
        System.assertEquals(5,lstPriceBookEntries.size());
        
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries) {
            pbe.Pricebook2Id = priceBookCANJVId;
            pbe.CurrencyIsoCode = 'CAD';
        }
        insert customLstPriceBookEntries;
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : lstPriceBookEntryPeriod){
            pebp.Price_Type__c = 'Wholesale 5';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_CANADA_CODE;
            pebp.Price_Book__c = priceBookCANJVId;
            pebp.CurrencyIsoCode = 'CAD';
        }
        insert lstPriceBookEntryPeriod;
        System.assertEquals(5,lstPriceBookEntryPeriod.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod1= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookCANJVId;
            pebp.CurrencyIsoCode = 'CAD';
        }
        insert pricebookentryPeriod1;
        System.assertEquals(5,pricebookentryPeriod1.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookCANJVId;
            pebp.CurrencyIsoCode = 'CAD';
        }
        insert pricebookentryPeriod2;
        System.assertEquals(5,pricebookentryPeriod2.size());
        
        List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstDeals, 5, false);
        for(Integer nProductCount = 0; nProductCount < lstProduct.size(); nProductCount++){ 
            for(OpportunityLineItem oli : lstDealProducts) {
                oli.Start_Date__c = Date.today().addDays(-15);
                oli.End_Date__c = Date.today().addDays(15);
                oli.Initial_Ship_Fcst__c = 100;
                oli.Replen_Ship_Fcst__c = 0;
                oli.Reason__c = 'DFI';
                oli.Account_Fund_Segment__c = 'NAT'; 
                oli.ListPrice__c = 30;
            }
        }
        insert lstDealProducts;
        System.assertEquals(10,lstDealProducts.size());   
        
        // Insert max Product limit per page
        //CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        TestDataWrapper tw = new TestDataWrapper();
        tw.lstAccounts = lstAccounts;
        tw.lstOpportunity = lstDeals;
        tw.lstProduct = lstProduct;
        tw.lstPriceBookEntry = lstPriceBookEntries;
        tw.lstDecayCurveTemplate = lstDecayCurveTemplate;
        tw.lstDecayCurveItem = lstDecayCurveItem;
        tw.lstPriceBookEntryPeriod = lstPriceBookEntryPeriod;
        tw.lstDealProducts = lstDealProducts;
        return tw;
    }
    /*W-017642 - End - Create Dummy Data of US for JV Orgs Using CRM_TestDataFactory Class*/
    
    //W-017642 - Start
    @isTest
    private static void insertUpdeateUSJVData() {
        //Method to create Dummy Data
        TestDataWrapper tw = createUSDataForJV();
        
        List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem> (tw.lstDealProducts);
        Set<Id> lstDealProductsIds = new Set<Id>();
        
        for(OpportunityLineItem oli : lstDealProducts) {
            lstDealProductsIds.add(oli.Id);
        }
        List<OpportunityLineItemSchedule> olisToBeRemoved = new List<OpportunityLineItemSchedule>();
        for(OpportunityLineItemSchedule olis : [Select Id from OpportunityLineItemSchedule where OpportunityLineItemId IN: lstDealProductsIds]) {
            olisToBeRemoved.add(olis);
        }
        delete olisToBeRemoved;
        
        Test.startTest();
        for(OpportunityLineItem lineItem : lstDealProducts) {
            lineItem.New_Replen_Ship_Fcst__c = 800;
        }
        update lstDealProducts;
        Test.stopTest();        
    }
    
    @isTest
    private static void insertUpdeateCANJVData() {
        //Method to create Dummy Data
        TestDataWrapper tw = createCANDataForJV();
        
        List<OpportunityLineItem> lstDealProducts = new List<OpportunityLineItem> (tw.lstDealProducts);
        Set<Id> lstDealProductsIds = new Set<Id>();
        
        for(OpportunityLineItem oli : lstDealProducts) {
            lstDealProductsIds.add(oli.Id);
        }
        List<OpportunityLineItemSchedule> olisToBeRemoved = new List<OpportunityLineItemSchedule>();
        for(OpportunityLineItemSchedule olis : [Select Id from OpportunityLineItemSchedule where OpportunityLineItemId IN: lstDealProductsIds]) {
            olisToBeRemoved.add(olis);
        }
        delete olisToBeRemoved;
        
        Test.startTest();
        for(OpportunityLineItem lineItem : lstDealProducts) {
            lineItem.New_Replen_Ship_Fcst__c = 447;
            lineItem.Discount = 100;
        }
        update lstDealProducts;
        Test.stopTest();        
    }
    //W-017642 - End
    
    private static testMethod void schedulesWithInitialAndReplenQuantityWithoutTemplatesOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(7, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(41, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(21, schedules[0].Quantity);
                System.assertEquals(210, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(2, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(21, schedules[1].Quantity);
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(210, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndWithoutReplenQuantityAndTemplatesOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToOpportunityInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            //lstDealProduct[i].Discount = 90;
            lstDealProduct[i].Promoted_Price__c = 10;
            if (mapIdToOpportunityInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 20;
            }
            lstDealProduct[i].Quantity = 1;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type, Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';

                // As no replen Quantity present, it will move the Initial Quantity into Quantity
                System.assertEquals(20, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(10, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndWithoutReplenQuantityAndTemplatesWith100DiscountOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToOpportunityInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Discount = 100;
            lstDealProduct[i].Promoted_Price__c = 0;
            if (mapIdToOpportunityInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 20;
            }
            lstDealProduct[i].Quantity = 1;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type, Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';

                // As no replen Quantity present, it will move the Initial Quantity into Quantity
                System.assertEquals(20, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[0].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
            }
        }
    }
    private static testMethod void schedulesWithInitialAndReplenQuantityAlongWithTemplatesOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);

        System.assertEquals(1, tw.lstDecayCurveTemplate.size());
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
            //lstDealProduct[i].Discount = 90;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(17, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(41, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(3, schedules.size());
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(6, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(9, schedules[2].Quantity);
                System.assertEquals(60, schedules[0].Revenue);
                System.assertEquals(60, schedules[1].Revenue);
                System.assertEquals(90, schedules[2].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[2].Description);
            } else {
                System.assertEquals(4, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(6, schedules[2].Quantity);
                System.assertEquals(9, schedules[3].Quantity);
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(60, schedules[1].Revenue);
                System.assertEquals(60, schedules[2].Revenue);
                System.assertEquals(90, schedules[3].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityAlongWithAccountTemplatesOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(1, tw.lstDecayCurveTemplate.size());

        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        // Decay Curve Template set for Account
        for (Account acc : lstAccounts) {
            acc.Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
        }
        update lstAccounts;

        // Setting up OpportunityLineItem Data with no data set for Decay Curve Template
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
            //lstDealProduct[i].Discount = 90;
            lstDealProduct[i].Quantity = 1;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(17, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(41, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(3, schedules.size());
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(6, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(9, schedules[2].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[2].Description);
            } else {
                System.assertEquals(4, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(6, schedules[2].Quantity);
                System.assertEquals(9, schedules[3].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityAlongWithTemplatesAndNoPromoPriceOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
         Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = tw.lstPriceBookEntryPeriod;
        System.assertEquals(1, tw.lstDecayCurveTemplate.size());

        for(Pricebook_Entry_Period__c period : lstPriceBookEntryPeriod){
            period.List_Price__c = 0;
        }
        update lstPriceBookEntryPeriod;

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Discount = 100;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly with Quantity type as no Promo price is present
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(17, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(41, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(3, schedules.size());
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[2].Type);
                System.assertEquals(6, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(9, schedules[2].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[2].Description);
            } else {
                System.assertEquals(4, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[3].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(6, schedules[2].Quantity);
                System.assertEquals(9, schedules[3].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
            }
        }
    }

    private static testMethod void schedulesWithReplenAndPLQuantityWithTemplatesOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = tw.lstPriceBookEntryPeriod;

        System.assertEquals(1, tw.lstDecayCurveTemplate.size());
        for(Pricebook_Entry_Period__c period : lstPriceBookEntryPeriod){
            period.List_Price__c = 100;
        }
        update lstPriceBookEntryPeriod;

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
            lstDealProduct[i].P_L_Quantity__c = 21;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            lstDealProduct[i].P_L_Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly with Quantity type for Normal Decay Template and Revenue Type for PL Decay Template
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(32, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(41, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(6, schedules.size());
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[4].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[5].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[5].Type);
                System.assertEquals(6, schedules[0].Quantity);
                System.assertEquals(6, schedules[2].Quantity);
                System.assertEquals(9, schedules[4].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(0, schedules[3].Quantity);
                System.assertEquals(0, schedules[5].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(0, schedules[2].Revenue);
                System.assertEquals(0, schedules[4].Revenue);
                System.assertEquals(693, schedules[1].Revenue);
                System.assertEquals(693, schedules[3].Revenue);
                System.assertEquals(714, schedules[5].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[4].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[5].Description);
            } else {
                System.assertEquals(7, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[5].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[4].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[6].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[5].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[6].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(6, schedules[3].Quantity);
                System.assertEquals(9, schedules[5].Quantity);
                System.assertEquals(0, schedules[2].Quantity);
                System.assertEquals(0, schedules[4].Quantity);
                System.assertEquals(0, schedules[6].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(0, schedules[1].Revenue);
                System.assertEquals(0, schedules[3].Revenue);
                System.assertEquals(0, schedules[5].Revenue);
                System.assertEquals(693, schedules[2].Revenue);
                System.assertEquals(693, schedules[4].Revenue);
                System.assertEquals(714, schedules[6].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[5].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[4].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[6].Description);
            }
        }
    }

    private static testMethod void schedulesWithReplenAndTargetQuantityWithDecayTemplateAndNoPLTemplateOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        System.assertEquals(1, tw.lstDecayCurveTemplate.size());
        List<Account> lstAccounts = tw.lstAccounts;
        for (Account acc : lstAccounts) {
            acc.Consignment_Customer__c = true;
            if (acc.Games_Physical__c) {
                acc.Consignment_Multiplier_Games__c = 1.25;
            }
            if (acc.Video_Physical__c) {
                acc.Consignment_Multiplier_Video__c = 1.2;
            }
        }
        update lstAccounts;

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
            lstDealProduct[i].Target_Quantity__c = 21;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(22, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(41, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(4, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(0, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(6, schedules[2].Quantity);
                System.assertEquals(9, schedules[3].Quantity);
                System.assertEquals(10, schedules[0].Revenue);
                System.assertEquals(0, schedules[1].Revenue);
                System.assertEquals(0, schedules[2].Revenue);
                System.assertEquals(0, schedules[3].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
            } else {
                System.assertEquals(5, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(System.Today() + 1, schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[4].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(6, schedules[2].Quantity);
                System.assertEquals(6, schedules[3].Quantity);
                System.assertEquals(9, schedules[4].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(10, schedules[1].Revenue);
                System.assertEquals(0, schedules[2].Revenue);
                System.assertEquals(0, schedules[3].Revenue);
                System.assertEquals(0, schedules[4].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL, schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[4].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndPLQuantityOnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        Map<Id, Opportunity> mapIdToOpportunityInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        System.assertEquals(1, tw.lstDecayCurveTemplate.size());
        List<Account> lstAccounts = tw.lstAccounts;
        for (Account acc : lstAccounts) {
            acc.Consignment_Customer__c = true;
            if (acc.Games_Physical__c) {
                acc.Consignment_Multiplier_Games__c = 1.25;
            }
            if (acc.Video_Physical__c) {
                acc.Consignment_Multiplier_Video__c = 1.2;
            }
        }
        update lstAccounts;

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            if (mapIdToOpportunityInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 20;
            }
            lstDealProduct[i].P_L_Quantity__c = 21;
            lstDealProduct[i].Quantity = 1;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(10, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(20, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(2, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
                System.assertEquals(System.Today() + 1, schedules[1].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(210, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL, schedules[1].Description);
            } else {
                System.assertEquals(2, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(System.Today() + 1, schedules[1].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(210, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndPLQuantityWithDiscount100OnInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        Map<Id, Opportunity> mapIdToOpportunityInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        System.assertEquals(1, tw.lstDecayCurveTemplate.size());
        List<Account> lstAccounts = tw.lstAccounts;
        for (Account acc : lstAccounts) {
            acc.Consignment_Customer__c = true;
            if (acc.Games_Physical__c) {
                acc.Consignment_Multiplier_Games__c = 1.25;
            }
            if (acc.Video_Physical__c) {
                acc.Consignment_Multiplier_Video__c = 1.2;
            }
        }
        update lstAccounts;

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Discount = 100;
            lstDealProduct[i].Promoted_Price__c = 0;
            if (mapIdToOpportunityInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 20;
            }
            lstDealProduct[i].P_L_Quantity__c = 21;
            lstDealProduct[i].Quantity = 1;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(20, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_QUANTITY, schedules[0].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityWithoutTemplatesOnUpdateTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
        }
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }
        insert lstDealProduct;

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterInsert = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProductsAfterInsert.size());
        Map<Id, OpportunityLineItem> mapIdToInstanceWithExistingData = new Map<Id, OpportunityLineItem>(dealProductsAfterInsert);

        // Verify schedules are present and data is populated properly
        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, existingLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : existingLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstanceWithExistingData.get(schedule.OpportunityLineItemId);
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                System.assertEquals(41, dealProduct.Quantity);
            }
        }

        // Update the Quantity to recalculate the schedules
        Test.startTest();
        for(Integer i=0 ; i< dealProductsAfterInsert.size(); i++){
            if (mapIdToDealInstance.get(dealProductsAfterInsert[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                dealProductsAfterInsert[i].Replen_Quantity__c = 40;
            } else {
                dealProductsAfterInsert[i].Initial_Quantity__c = 25;
                dealProductsAfterInsert[i].Replen_Quantity__c = 40;
            }
        }
        update dealProductsAfterInsert;
        Test.stopTest();

        List<OpportunityLineItem> dealProductsAfterUpdate = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProductsAfterUpdate.size());
        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProductsAfterUpdate);
 
        // Verify the schedules are updated properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(existingLineItemSchedules.size(), newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(40, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(65, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(2, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityWithTemplateOnStreetDateUpdateTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Product2> lstProduct = tw.lstProduct;
        Map<Id, Pricebook_Entry_Period__c> mapProdIdToPBEP = new Map<Id, Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> lstPBEPToUpdate =
            [
                SELECT Start_Date__c, Product__c
                FROM Pricebook_Entry_Period__c
                WHERE Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
            ];
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            mapProdIdToPBEP.put(pbep.Product__c, pbep);
        }

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 40;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 25;
                lstDealProduct[i].Replen_Quantity__c = 40;
            }
        }
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }
        insert lstDealProduct;

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterInsert = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId , Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterInsert.size());

        // Verify schedules are present and data is populated properly based on Product Street Date
        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, existingLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterInsert) {
            System.assertEquals(System.today() + 1, dealProduct.Product2.Street_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 1, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }

        // Update the Release Date to recalculate the schedules
        Test.startTest();
        // For Physical Products update Product Street Date
        for (Product2 p : lstProduct){
            p.Street_Date__c = System.today() + 20;
        }
        update lstProduct;

        // For Digital Products update PBEP's Start Date
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            pbep.Start_Date__c = System.today() + 20;
        }
        update lstPBEPToUpdate;
        System.debug('-lstPBEPToUpdate->'+lstPBEPToUpdate);
        Test.stopTest();

        // Fetch Deal Products to verify Schedules are recalculated properly
        List<OpportunityLineItem> dealProductsAfterUpdate = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,Product2.RecalculateSchedules__c,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterUpdate.size());

        // Verify schedules are present and data is populated properly based on updated Product Street Date
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, newLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterUpdate) {
            System.assertEquals(System.today() + 20, dealProduct.Product2.Street_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 20, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                /*Commented as Product street date change code move from trigger into CRM_ProcessDealProductsBatch
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);*/
                System.assertEquals(true,dealProduct.Product2.RecalculateSchedules__c);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            }/* 
            Commented as Product street date change code move from trigger into CRM_ProcessDealProductsBatch
            else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }*/
        }
    }

    /**  JAPAN Methods  **/
    private static testMethod void schedulesWithInitialAndReplenForDigtitalAlongWithTemplatesOnRentalInsertTest_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
         Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        tw.lstDecayCurveTemplate = [SELECT Id, MaxDecayCurveItemDay__c FROM Decay_Curve_Template__c];
        System.assertEquals(1, tw.lstDecayCurveTemplate.size());

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,tw.lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, tw.lstAccounts, false);
        Map<Id, Account_Plan__c> mapAccountIdToAP = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.Handling_Fee__c = 100;
            accPlan.Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            accPlan.Rental_Price__c = 70;
            accPlan.Revenue_Share__c = 25.5;
            accPlan.Number_of_Rentals_per_Unit__c = 20;
            accPlan.Final_Purchase_Price__c = 20;
            accPlan.Final_Purchase__c = 30;
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            mapAccountIdToAP.put(accPlan.Customer__c, accPlan);
        }
        insert lstAccountPlan;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 10;
            }
            lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Handling_Fee__c = 100;
            lstDealProduct[i].Rental_Price__c = 70;
            lstDealProduct[i].Revenue_Share__c = 25.5;
            lstDealProduct[i].Number_of_Rentals_per_Unit__c = 20;
            lstDealProduct[i].Final_Purchase_Price__c = 20;
            lstDealProduct[i].Final_Purchase__c = 30;
            lstDealProduct[i].Account_Plan__c = mapAccountIdToAP.get(tw.lstOpportunity[i].AccountId).Id;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = 'Test';
            lstDealProduct[i].Promoted_Price__c = 10;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(19, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(10, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(3, schedules.size());
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(6, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(9, schedules[2].Quantity);
                System.assertEquals(60, schedules[0].Revenue);
                System.assertEquals(60, schedules[1].Revenue);
                System.assertEquals(90, schedules[2].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[2].Description);
            } else {
                System.assertEquals(5, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays(((Integer) tw.lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(10, schedules[0].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(0, schedules[2].Quantity);
                System.assertEquals(0, schedules[3].Quantity);
                System.assertEquals(0, schedules[4].Quantity);
                System.assertEquals(1000, schedules[0].Revenue);
                System.assertEquals(1178.1, schedules[1].Revenue,'10 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(1178.1, schedules[2].Revenue,'10 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(1213.8, schedules[3].Revenue,'10 * 70 * (25.5 / 100) * 20 * (34 / 100)');
                System.assertEquals(60, schedules[4].Revenue, '10 * 20 * (30 / 100)');
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityWithoutTemplatesOnRentalInsertTest_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,tw.lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, tw.lstAccounts, false);
        Map<Id, Account_Plan__c> mapAccountIdToAP = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            mapAccountIdToAP.put(accPlan.Customer__c, accPlan);
        }
        insert lstAccountPlan;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
            lstDealProduct[i].Account_Plan__c = mapAccountIdToAP.get(tw.lstOpportunity[i].AccountId).Id;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = 'Test';
            lstDealProduct[i].Promoted_Price__c = 10;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(20, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(21, schedules[0].Quantity);
                System.assertEquals(210, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityWithoutTemplatesOnSellThroughInsertTest_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        List<Account_Plan__c> lstAccountPlan = [SELECT RecordTypeId FROM Account_Plan__c];
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_SELL_THROUGH;
        }
        update lstAccountPlan;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(7, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(41, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(21, schedules[0].Quantity);
                System.assertEquals(210, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(2, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(21, schedules[1].Quantity);
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(210, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialWithBackOrderIQAndReplenQuantityWithoutTemplatesOnSellThroughInsertTest_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        List<Account_Plan__c> lstAccountPlan = [SELECT RecordTypeId FROM Account_Plan__c];
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_SELL_THROUGH;
        }
        update lstAccountPlan;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 10;
                lstDealProduct[i].Initial_Back_Order_Quantity__c = 10;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(7, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(41, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(21, schedules[0].Quantity);
                System.assertEquals(210, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(2, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(21, schedules[1].Quantity);
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(210, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialBackOrderAndWithoutInitialAndReplenQuantityAndTemplatesOnSellThroughInsertTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        List<Account_Plan__c> lstAccountPlan = [SELECT RecordTypeId FROM Account_Plan__c];
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_SELL_THROUGH;
        }
        update lstAccountPlan;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToOpportunityInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            //lstDealProduct[i].Discount = 90;
            lstDealProduct[i].Promoted_Price__c = 10;
            if (mapIdToOpportunityInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Back_Order_Quantity__c = 20;
                lstDealProduct[i].Initial_Quantity__c = 0;
            }
            lstDealProduct[i].Quantity = 1;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type, Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';

                // As no replen Quantity present, it will move the Initial Quantity into Quantity
                System.assertEquals(20, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(10, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
            }
        }
    }

    private static testMethod void schedulesWithOverridePricingForRentalTest_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
         Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        tw.lstDecayCurveTemplate = [SELECT Id, MaxDecayCurveItemDay__c FROM Decay_Curve_Template__c];
        System.assertEquals(1, tw.lstDecayCurveTemplate.size());

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,tw.lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan';
            cp.Target_Revenue__c = 5000;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, tw.lstAccounts, false);
        Map<Id, Account_Plan__c> mapAccountIdToAccpuntPlan = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.Share__c = 10;
            accPlan.Handling_Fee__c = 100;
            accPlan.Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            accPlan.Rental_Price__c = 70;
            accPlan.Revenue_Share__c = 25.5;
            accPlan.Number_of_Rentals_per_Unit__c = 20;
            accPlan.Final_Purchase_Price__c = 20;
            accPlan.Final_Purchase__c = 30;
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            mapAccountIdToAccpuntPlan.put(accPlan.Customer__c, accPlan);
        }
        insert lstAccountPlan;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 10;
            }
            lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Handling_Fee__c = 100;
            lstDealProduct[i].Rental_Price__c = 70;
            lstDealProduct[i].Revenue_Share__c = 25.5;
            lstDealProduct[i].Number_of_Rentals_per_Unit__c = 20;
            lstDealProduct[i].Final_Purchase_Price__c = 20;
            lstDealProduct[i].Final_Purchase__c = 30;
            lstDealProduct[i].Target_Quantity__c = 2;
            lstDealProduct[i].Account_Plan__c = mapAccountIdToAccpuntPlan.get(tw.lstOpportunity[i].AccountId).Id;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = 'Test';
            lstDealProduct[i].Promoted_Price__c = 10;
        }
        insert lstDealProduct;
        
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(19, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(10, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(3, schedules.size());
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(6, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(9, schedules[2].Quantity);
                System.assertEquals(60, schedules[0].Revenue);
                System.assertEquals(60, schedules[1].Revenue);
                System.assertEquals(90, schedules[2].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[2].Description);
            } else {
                System.assertEquals(5, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays(((Integer) tw.lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(10, schedules[0].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(0, schedules[2].Quantity);
                System.assertEquals(0, schedules[3].Quantity);
                System.assertEquals(0, schedules[4].Quantity);
                System.assertEquals(1000, schedules[0].Revenue);
                System.assertEquals(1178.1, schedules[1].Revenue,'10 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(1178.1, schedules[2].Revenue,'10 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(1213.8, schedules[3].Revenue,'10 * 70 * (25.5 / 100) * 20 * (34 / 100)');
                System.assertEquals(60, schedules[4].Revenue, '10 * 20 * (30 / 100)');
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);
            }
        }

        Test.startTest();
        // Override Rental Prices in Deal products
        lstDealProduct = [SELECT Id, Override_Pricing__c, Handling_Fee__c, Rental_Price__c, Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c, Final_Purchase__c FROM OpportunityLineItem];
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Override_Pricing__c = true;           
            lstDealProduct[i].Handling_Fee__c = 150;
            lstDealProduct[i].Rental_Price__c = 7;
            lstDealProduct[i].Revenue_Share__c = 5;
            lstDealProduct[i].Number_of_Rentals_per_Unit__c = 2;
            lstDealProduct[i].Final_Purchase_Price__c = 2;
            lstDealProduct[i].Final_Purchase__c = 10;
        }
        update lstDealProduct;      
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterUpdate = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,Target_Quantity__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProductsAfterUpdate.size());

        Map<Id, OpportunityLineItem> mapIdToInstanceAfterUpdate = new Map<Id, OpportunityLineItem>(dealProductsAfterUpdate);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedulesAfterUpdate = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedulesAfterUpdate =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(19, newLineItemSchedulesAfterUpdate.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedulesAfterUpdate) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstanceAfterUpdate.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(10, dealProduct.Quantity);
                System.assertEquals(4, dealProduct.Target_Quantity__c);
            }
            if (mapTypeToListOfSchedulesAfterUpdate.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedulesAfterUpdate.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedulesAfterUpdate.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedulesAfterUpdate.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedulesAfterUpdate.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(3, schedules.size());
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(6, schedules[0].Quantity);
                System.assertEquals(6, schedules[1].Quantity);
                System.assertEquals(9, schedules[2].Quantity);
                System.assertEquals(60, schedules[0].Revenue);
                System.assertEquals(60, schedules[1].Revenue);
                System.assertEquals(90, schedules[2].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_TEMPLATE + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[2].Description);
            } else {
                System.assertEquals(5, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays((Integer) tw.lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((System.Today() + 1).addDays(((Integer) tw.lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(10, schedules[0].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(0, schedules[2].Quantity);
                System.assertEquals(0, schedules[3].Quantity);
                System.assertEquals(0, schedules[4].Quantity);
                System.assertEquals(1500, schedules[0].Revenue);
                System.assertEquals(2.31, schedules[1].Revenue,'10 * 7 * (5 / 100) * 2 * (33 / 100)');
                System.assertEquals(2.31, schedules[2].Revenue,'10 * 7 * (5 / 100) * 2 * (33 / 100)');
                System.assertEquals(2.38, schedules[3].Revenue,'10 * 7 * (5 / 100) * 2 * (34 / 100)');
                System.assertEquals(2, schedules[4].Revenue, '10 * 2 * (3 / 100)');
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(tw.lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndWithoutReplenQuantityAndTemplatesOnInsertTest_ForGermany(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToOpportunityInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        for (Product2 prod : tw.lstProduct) {
          prod.Street_Date__c = system.today() - 120;
        }
        update tw.lstProduct;

        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
          pbep.Start_Date__c = system.today() - 120;
          pbep.End_Date__c = system.today() + 110;
        }
        update tw.lstPriceBookEntryPeriod;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Integer oppCount=0 ; oppCount< tw.lstOpportunity.size(); oppCount++){
            tw.lstOpportunity[oppCount].Customer_Delivery_Date__c = tw.lstOpportunity[oppCount].Promo_Start_Date__c + 1; // Setting up CDD date as promo start date + 1
        }
        update tw.lstOpportunity;
        
        for (Account acc : tw.lstAccounts) {
          acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
          acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_GERMANY_DIGITAL_COUNTRY_CODE;
        }
        update tw.lstAccounts;
        
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            //lstDealProduct[i].Discount = 90;
            lstDealProduct[i].Promoted_Price__c = 10;
            if (mapIdToOpportunityInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 20;
            }
            lstDealProduct[i].Quantity = 1; 
            lstDealProduct[i].Pricebook_Entry_Period__c = tw.lstPriceBookEntryPeriod[i].Id;
            //lstDealProduct[i].Quantity = 1;          
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.debug('-existingDealProducts.NR__c-->' + existingDealProducts.NR__c);
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItem.Opportunity.Customer_Delivery_Date__c, OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type, Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId, Quantity];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());   // US-296 Changes (Rev Rec Changes)
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';

                // As no replen Quantity present, it will move the Initial Quantity into Quantity
                System.assertEquals(20, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(system.today() - 120, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(10, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());   // US-296 Changes (Rev Rec Changes)
                System.assertEquals(schedules[0].OpportunityLineItem.Opportunity.Customer_Delivery_Date__c , schedules[0].ScheduleDate); // US-296 Changes (Rev Rec Changes) NR_Revenue_Recognition_Date__c //Customer_Delivery_Date__c - 10
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(20, schedules[0].Quantity); // US-296 Changes (Rev Rec Changes)
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
            }
        }
    }

    private static testMethod void scenario1_No_IQ_For_Physical_No_Replen_Quantity_For_Digital(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 0;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 0;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(21, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals((System.Today() + 1).addDays(7), schedules[0].ScheduleDate);
                System.assertEquals(21, schedules[0].Quantity);
                System.assertEquals(210, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            }
        }
    }
    
    private static testMethod void scenario2_No_IQ_And_RQ_For_Physical_No_Replen_But_EPOS_For_Digital(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        Set<Id> consignmentCustomerAccountId = new Set<Id>();
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 0;
                lstDealProduct[i].P_L_Quantity__c = 10;
                consignmentCustomerAccountId.add(mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).AccountId);
            } else {
                lstDealProduct[i].Initial_Quantity__c = 0;
                lstDealProduct[i].Replen_Quantity__c = 0;
            }
        }

        List<Account> accList = [SELECT Consignment_Customer__c, Games_Physical__c, Video_Physical__c, Consignment_Multiplier_Games__c, Consignment_Multiplier_Video__c FROM Account WHERE Id IN: consignmentCustomerAccountId];
        for (Account acc : accList) {
            acc.Consignment_Customer__c = true;
            if (acc.Games_Physical__c) {
                acc.Consignment_Multiplier_Games__c = 1.25;
            }
            if (acc.Video_Physical__c) {
                acc.Consignment_Multiplier_Video__c = 1.2;
            }
        }
        update accList;
    
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(8, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(1, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(2, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
                System.assertEquals(System.Today() + 1, schedules[1].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(100, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_PL, schedules[1].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals((System.Today() + 1), schedules[0].ScheduleDate);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            }
        }
    }

    private static testMethod void scenario3_IQ_But_No_RQ_For_Physical_No_Replen_Quantity_With_Decay_Curve_For_Digital(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 0;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
                lstDealProduct[i].Replen_Quantity__c = 0;
            }
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(20, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals((System.Today() + 1), schedules[0].ScheduleDate);
                System.assertEquals(20, schedules[0].Quantity);
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
            }
        }
    }

    private static testMethod void scenario4_No_IQ_And_RQ_For_Physical_No_Replen_For_Digital_With_Decay_Curve_Template_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
         Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        tw.lstDecayCurveTemplate = [SELECT Id, MaxDecayCurveItemDay__c FROM Decay_Curve_Template__c];
        System.assertEquals(1, tw.lstDecayCurveTemplate.size());

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,tw.lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, tw.lstAccounts, false);
        Map<Id, Account_Plan__c> mapAccountIdToAP = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.Handling_Fee__c = 100;
            accPlan.Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            accPlan.Rental_Price__c = 70;
            accPlan.Revenue_Share__c = 25.5;
            accPlan.Number_of_Rentals_per_Unit__c = 20;
            accPlan.Final_Purchase_Price__c = 20;
            accPlan.Final_Purchase__c = 30;
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            mapAccountIdToAP.put(accPlan.Customer__c, accPlan);
        }
        insert lstAccountPlan;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 0;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 0;
            }
            lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Handling_Fee__c = 100;
            lstDealProduct[i].Rental_Price__c = 70;
            lstDealProduct[i].Revenue_Share__c = 25.5;
            lstDealProduct[i].Number_of_Rentals_per_Unit__c = 20;
            lstDealProduct[i].Final_Purchase_Price__c = 20;
            lstDealProduct[i].Final_Purchase__c = 30;
            lstDealProduct[i].Account_Plan__c = mapAccountIdToAP.get(tw.lstOpportunity[i].AccountId).Id;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = 'Test';
            lstDealProduct[i].Promoted_Price__c = 10;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());

        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(1, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        System.assertEquals(3, tw.lstDecayCurveItem.size());
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            }
        }
    }

    private static testMethod void scenario5_IQ_But_No_RQ_For_Physical_No_Replen_For_Digital_With_Decay_Curve_Template_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,tw.lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, tw.lstAccounts, false);
        Map<Id, Account_Plan__c> mapAccountIdToAP = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            mapAccountIdToAP.put(accPlan.Customer__c, accPlan);
        }
        insert lstAccountPlan;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 0;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 0;
                lstDealProduct[i].Replen_Quantity__c = 21;
            }
            lstDealProduct[i].Account_Plan__c = mapAccountIdToAP.get(tw.lstOpportunity[i].AccountId).Id;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = 'Test';
            lstDealProduct[i].Promoted_Price__c = 10;
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(1, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            }
        }
    }

    private static testMethod void scenario6_IQ_But_No_IBO_Quantity_For_Physical_With_Decay_Curve_And_Replen_Present_For_Digital_Sell_Through_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        List<Account_Plan__c> lstAccountPlan = [SELECT RecordTypeId FROM Account_Plan__c];
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_SELL_THROUGH;
        }
        update lstAccountPlan;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 0;
                lstDealProduct[i].Replen_Quantity__c = 0;
                lstDealProduct[i].Decay_Curve_Template__c = tw.lstDecayCurveTemplate[0].Id;
            }
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(1, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(21, schedules[0].Quantity);
                System.assertEquals(210, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            }
        }
    }

    private static testMethod void scenario7_No_IQ_But_IBO_Quantity_For_Physical_No_Replen_For_Digital_Sell_Through_Japan(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        List<Account_Plan__c> lstAccountPlan = [SELECT RecordTypeId FROM Account_Plan__c];
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_SELL_THROUGH;
        }
        update lstAccountPlan;

        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            //lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 0;
            } else {
                lstDealProduct[i].Initial_Back_Order_Quantity__c = 0;
                lstDealProduct[i].Replen_Quantity__c = 0;
            }
        }

        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }

        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id FROM OpportunityLineItemSchedule];
        System.assertEquals(0, existingLineItemSchedules.size());

        Test.startTest();
        insert lstDealProduct;
        Test.stopTest();

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProducts = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProducts.size());

        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProducts);

        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            //System.assert(mapIdToInstance.contiansKey(schedule.OpportunityLineItemId));
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(1, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            }
        }
    }

private static testMethod void scenario8_WithNullInitialAndReplenQuantityWithoutTemplatesOnUpdateTest(){
        //Method to create Dummy Data
        TestDataWrapper tw = createData();
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Discount = 90;
            if (mapIdToDealInstance.get(lstDealProduct[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 21;
            } else {
                lstDealProduct[i].Initial_Quantity__c = 20;
            }
        }
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }
        insert lstDealProduct;

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterInsert = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProductsAfterInsert.size());
        Map<Id, OpportunityLineItem> mapIdToInstanceWithExistingData = new Map<Id, OpportunityLineItem>(dealProductsAfterInsert);

        // Verify schedules are present and data is populated properly
        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(5, existingLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : existingLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstanceWithExistingData.get(schedule.OpportunityLineItemId);
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(21, dealProduct.Quantity);
            } else {
                System.assertEquals(20, dealProduct.Quantity);
            }
        }

        // Update the Quantity to recalculate the schedules
        Test.startTest();
        for(Integer i=0 ; i< dealProductsAfterInsert.size(); i++){
            if (mapIdToDealInstance.get(dealProductsAfterInsert[i].OpportunityId).RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                dealProductsAfterInsert[i].Replen_Quantity__c = null;
            } else {
                dealProductsAfterInsert[i].Initial_Quantity__c = null;
                dealProductsAfterInsert[i].Initial_Back_Order_Quantity__c = null;
            }
        }
        update dealProductsAfterInsert;
        Test.stopTest();

        List<OpportunityLineItem> dealProductsAfterUpdate = [SELECT Id, Quantity, Initial_Quantity__c, Replen_Quantity__c, Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c, Product2.Street_Date__c, UnitPrice
            FROM OpportunityLineItem];
        System.assertEquals(5, dealProductsAfterUpdate.size());
        Map<Id, OpportunityLineItem> mapIdToInstance = new Map<Id, OpportunityLineItem>(dealProductsAfterUpdate);
 
        // Verify the schedules are updated properly
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule];
        Map<String, List<OpportunityLineItemSchedule>> mapTypeToListOfSchedules =
            new Map<String, List<OpportunityLineItemSchedule>>();
        System.assertEquals(5, newLineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : newLineItemSchedules) {
            OpportunityLineItem dealProduct = mapIdToInstance.get(schedule.OpportunityLineItemId);
            String strDigitalType = '';
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                strDigitalType = 'Digital';
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                strDigitalType = 'Physical';
                System.assertEquals(1, dealProduct.Quantity);
            }
            if (mapTypeToListOfSchedules.containsKey(strDigitalType + '-' + dealProduct.Id)) {
                mapTypeToListOfSchedules.get(strDigitalType + '-' + dealProduct.Id).add(schedule);
            } else {
                mapTypeToListOfSchedules.put(strDigitalType + '-' + dealProduct.Id, new List<OpportunityLineItemSchedule>{schedule});
            }
        }
        for (String strType : mapTypeToListOfSchedules.keySet()) {
            List<OpportunityLineItemSchedule> schedules = mapTypeToListOfSchedules.get(strType);
            if (strType.contains('Digital')) {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            } else {
                System.assertEquals(1, schedules.size());
                System.assertEquals(System.Today() + 1, schedules[0].ScheduleDate);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            }
        }
    }

     public class TestDataWrapper {
        public List<Account> lstAccounts;
        public List<Opportunity> lstOpportunity;
        public List<Product2> lstProduct;
        public List<PricebookEntry> lstPriceBookEntry;
        public List<Decay_Curve_Template__c>  lstDecayCurveTemplate;
        public List<Decay_Curve_Item__c> lstDecayCurveItem;
        public List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod;
        public List<OpportunityLineItem> lstDealProducts;
    }
}