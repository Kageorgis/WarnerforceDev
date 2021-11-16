/**
   @Author Cognizant
   @name CRM_UploadDealProducts_Test
   @CreateDate 9 Feb 2016
   @Description Test class for CRM_UploadDealProductsController
   @Version <1.0>
   @reference Requirement no 83
*/
  
@isTest
private class CRM_UploadDealProducts_Test {
   
    /**
    *  Create Test Data. 
    *  @name allTheDataForThisTestClass
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    
    static void allTheDataForThisTestClass(){
            // create Storefront Account 
            List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
            System.assertEquals(1, mainAccountForStoreFront.size());
            mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
            insert mainAccountForStoreFront;

            //create country
            List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
            //create storefronts
            list<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id,true);
            system.debug('====storefronts====='+storefronts);
            
            list<Account> accounts = CRM_TestDataFactory.createAccounts(2, true);
            //update accounts
            accounts[0].Video_Digital__c  = true;
            accounts[0].Games_Digital__c  = true;
            accounts[0].Video_Physical__c = false;
            accounts[0].Games_Physical__c = false;
            accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            accounts[0].Storefront__c = storefronts[0].id;
            update accounts;
            
            List<Account> digitalAccount = new List<Account>();
            List<Account> physicalAccount = new List<Account>();
            
            digitalAccount.add(accounts[0]);
            physicalAccount.add(accounts[1]);
            
            //update opps with recordtypes
            list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(physicalAccount,1, true);

            Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
            //Id physicalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            //opps[1].Account = accounts[1];
            //opps[1].recordTypeId = physicalRecordTypeId;
            
            list<Opportunity> digitalOpps = CRM_TestDataFactory.createOpportunitiesWithAccounts(digitalAccount,1, false);
            digitalOpps[0].recordTypeId = digitalRecordTypeId;
            digitalOpps[0].Account = accounts[0];
            insert digitalOpps;
            
            system.assertEquals(1,opps.size());
            system.assertEquals(1,digitalOpps.size());
            
            List<String> strRegion = new List<String>();    
            strRegion.add('FR');
            strRegion.add('UK');
            
            //create country
            List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1,false);
            lstCountries[0].Country_Code2__c = 'FR';
            lstCountries[1].Country_Code2__c = 'UK';
            insert lstCountries;
            
            List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(2, false);
            lstLang[0].Language_Code_2__c = 'en';
            lstLang[1].Language_Code_2__c = 'fr';
            insert lstLang;
                                    
            //create local data
            List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
            lstLocalData[0].Language__c = lstLang[0].Id;
            lstLocalData[1].Language__c = lstLang[1].Id;
            insert lstLocalData;
            system.assertEquals(2,[select count() from Local_Title__c]);
        
            //create products and associate with Opportunities
            List<Product_Group__c> digitalPG = CRM_TestDataFactory.createProductGroups(1, true);
            List<Product2> digitalProducts = CRM_TestDataFactory.createProducts(digitalPG, 2, false);
            digitalProducts[0].External_Id__c= 'USA_en_12345_EST_HD';
            digitalProducts[1].External_Id__c='USA_fr_12345_EST_HD';
            digitalProducts[0].Product_Market__c='EST';
            digitalProducts[1].Product_Market__c='VODi';
            digitalProducts[0].Local_Title__c = lstLocalData[0].Id;
            digitalProducts[1].Local_Title__c = lstLocalData[1].Id;
            digitalProducts[0].Type__c= CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE;
            digitalProducts[1].Type__c=CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            digitalProducts[0].recordtypeId= CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            digitalProducts[1].recordtypeId=CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            insert digitalProducts;
            system.debug('===digitalProducts==='+digitalProducts);
            
            //List<Product_Group__c> physicalPG = CRM_TestDataFactory.createProductGroups(1, false);
            //physicalPG[0].Type__c = CRM_AppConstants.PHYSICAL_INITIALS;
            //physicalPG[0].External_Id__c = CRM_AppConstants.PHYSICAL_INITIALS +'pgTEST';
            //insert physicalPG;
            List<Product2> physicalProducts = CRM_TestDataFactory.createProducts(digitalPG, 2, false);
            physicalProducts[0].productCode= 'code1';
            physicalProducts[1].productCode='code2';
            physicalProducts[0].External_Id__c= 'USA_gr_12345_EST_HD';
            physicalProducts[0].Universal_Picture_Code__c ='upc1';
            physicalProducts[1].Universal_Picture_Code__c='upc2';
            physicalProducts[0].Product_Market__c='EST';
            physicalProducts[1].Product_Market__c='VODi';
            physicalProducts[0].Local_Title__c = lstLocalData[0].Id;
            physicalProducts[1].Local_Title__c = lstLocalData[1].Id;
            physicalProducts[0].Type__c= CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE;
            physicalProducts[1].Type__c=CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
            physicalProducts[0].recordtypeId= CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            physicalProducts[1].recordtypeId=CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            insert physicalProducts;
            system.debug('===physicalProducts==='+physicalProducts);
            
            List<PricebookEntry> pbEntriesDigital = CRM_TestDataFactory.createPriceBookEntries(digitalProducts, 1, true);
            List<PricebookEntry> pbEntriesPhysical = CRM_TestDataFactory.createPriceBookEntries(physicalProducts, 1, true);
            system.debug('===pbEntriesPhysical==='+pbEntriesPhysical);
            
            List<Pricing__c> lstPricing = CRM_TestDataFactory.createPricings(1,false);
            lstPricing[0].Price_Tier__c = '20';
            insert lstPricing;
            
            List<Pricebook_Entry_Period__c> digitalPEB =CRM_TestDataFactory.createPriceBookEntryPeriods(digitalProducts, 1, false);
            for(Pricebook_Entry_Period__c pbep : digitalPEB){
                pbep.Pricing__c = lstPricing[0].Id;
            }
            digitalPEB[1].Retailer_Product_ID__c = 'RPID1234';
            
            List<Pricebook_Entry_Period__c> physicalPEB=CRM_TestDataFactory.createPriceBookEntryPeriods(physicalProducts, 1, false);
            for(Pricebook_Entry_Period__c pbep : physicalPEB){
                pbep.Pricing__c = lstPricing[0].Id;
            }
            physicalPEB.addAll(digitalPEB);
            insert physicalPEB;
            
            List<OpportunityLineItem> dealproductsD = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntriesDigital, new list<Opportunity>{digitalOpps[0]}, 1, false);
            List<OpportunityLineItem> dealproductsP = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntriesPhysical, new list<Opportunity>{opps[0]}, 1, false);
            dealproductsP.addAll(dealproductsD);
            for(OpportunityLineItem ol: dealproductsP) {
                ol.UnitPrice = 10;
                ol.Promoted_Price__c=15;
            }
            insert dealproductsP;
            system.assertEquals(2,dealproductsP.size());
}
    
    /**
    *  Test 1: Test to insert new deal products into physical deal and update existing deal product record 
    *  Expected: new record should get inserted and existing should get updated
    *  @name unitTestPhysical
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    
    static testMethod void unitTestPhysical() {
        allTheDataForThisTestClass();
        Id physicalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,currencyISOCode,pricebook2Id,NR_Deal_Unique_Key__c,Digital_Country_Code__c,Account.Digital_Country_Code__c,RecordType.DeveloperName,Account.Revenue_Share__c,Market_Type__c,RecordTypeId,Sales_Organisation__c,Product_Type__c,
                                           (select id,Quantity,UnitPrice,Product2Id, Product2.productCode from OpportunityLineitems)
                                           from Opportunity
                                           where recordTypeId =: physicalRecordTypeId];
        system.debug('============opportunities============'+opportunities);
        Opportunity physicalDeal = opportunities[0];
        List<PricebookEntry> pbEntries = [select id,product2Id,product2.productCode from PricebookEntry];
        List<Product2> products = [select id from Product2];
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',physicalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(physicalDeal);
                    Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();         
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller);
                    CRM_UploadDealProductsController.DealWrapper  productSearchDealWrp = new CRM_UploadDealProductsController.DealWrapper();
                    list<CRM_UploadDealProductsController.DealWrapper> productSearchDealWrpList = new list<CRM_UploadDealProductsController.DealWrapper>();
                    //setting values in wrapper to fetch the product
                    productSearchDealWrp.dealId = physicalDeal.Id;
                    productSearchDealWrp.accountId = physicalDeal.AccountId;
                    productSearchDealWrp.dealCurrency = physicalDeal.currencyISOCode;
                    productSearchDealWrp.pricebookId = physicalDeal.pricebook2Id;
                    productSearchDealWrp.dealStartDate = physicalDeal.Start_Date__c;
                    productSearchDealWrp.dealEndDate  = physicalDeal.CloseDate;
                    productSearchDealWrpList.add(productSearchDealWrp);
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(physicalDeal.id);// method
                    system.assertEquals(false, pg.getDigitalDeal());
                                    
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadDealProductsController.OpportunityLineItemWrapper wrapper = new CRM_UploadDealProductsController.OpportunityLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Product2.productCode ='code1';
                    wrapper.lineItemRecord.Product2.Universal_Picture_Code__c='upc1';
                    wrapper.lineItemRecord.Reason__c = 'Space';
                    if(lineItems[0].lineItemRecord.Product2.productCode =='code1') {
                        wrapper.lineItemRecord.Product2.productCode ='code2';
                        wrapper.lineItemRecord.Product2.Universal_Picture_Code__c='upc2';
                    }    
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    lineItems.add(wrapper);
                    
                    //update existing record
                    lineItems[0].lineItemRecord.UnitPrice = 12;
                    lineItems[0].isRowModified = true;
                    /*************************************prepare data end***********************************************/
                    
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method
                    /*************************************asserts***********************************************/
                    system.assertEquals(Label.CRM_Upload_Message_Updated, savedlineItems[0].validation);
                    system.assertEquals(Label.CRM_Upload_Message_Created, savedlineItems[savedlineItems.size()-1].validation);
                    
                    //update existing record
                    lineItems[0].isRowRemoved = true;
                    /*************************************prepare data for delete***********************************************/
                    
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> dellineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method
                    /*************************************asserts***********************************************/
                    //system.assertEquals(savedlineItems.size()-1, dellineItems.size());
                    try{
                         CRM_UploadDealProductsController.deleteOpportunityLineItems(lineItems);
                    }
                    catch(Exception e){
                        system.assertEquals(true, e.getMessage().contains('null'));
                    }
        Test.stopTest();
    }
    
    /**
    *  Test 2: Test to insert new deal products into Digital deal and update existing deal product record 
    *  Expected: new record should get inserted and existing should get updated
    *  @name unitTestDigital
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestDigital() {
        allTheDataForThisTestClass();
        
        Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,pricebook2Id,currencyISOCode,Opportunity.RecordTypeId,
                                           (select id from OpportunityLineitems)
                                           from Opportunity
                                           where recordTypeId =: digitalRecordTypeId];
        Map<Id,Product2> products = new  Map<Id,Product2>([select id from Product2]);
        system.debug('============opportunities============'+opportunities);
        Opportunity digitalDeal = opportunities[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',digitalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(digitalDeal);
                    Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller);                 
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(digitalDeal.id);
                    system.assertEquals(true, pg.getDigitalDeal());
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadDealProductsController.OpportunityLineItemWrapper wrapper = new CRM_UploadDealProductsController.OpportunityLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.digital = new CRM_UploadDealProductsController.DigitalDealWrapper();
                    wrapper.digital.videoVersion ='12345';
                    wrapper.digital.channel ='EST';
                    wrapper.digital.format ='HD';
                    wrapper.digital.language ='en';

                    if(lineItems[0].lineItemRecord.Product2.External_Id__c== 'USA_en_12345_EST_HD')
                        wrapper.digital.language ='fr';
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    wrapper.lineItemRecord.UnitPrice=null;
                    wrapper.lineItemRecord.Reason__c = 'Advertising';
                    lineItems.add(wrapper);
                    
                    //product search
                    CRM_UploadDealProductsController.DealWrapper  productSearchDealWrp = new CRM_UploadDealProductsController.DealWrapper();
                    list<CRM_UploadDealProductsController.DealWrapper> productSearchDealWrpList = new list<CRM_UploadDealProductsController.DealWrapper>();
                    productSearchDealWrp.dealId = digitalDeal.Id;
                    productSearchDealWrp.accountId = digitalDeal.AccountId;
                    productSearchDealWrp.dealCurrency = digitalDeal.currencyISOCode;
                    productSearchDealWrp.pricebookId = digitalDeal.pricebook2Id;
                    productSearchDealWrp.dealStartDate = digitalDeal.Start_Date__c;
                    productSearchDealWrp.dealEndDate  = digitalDeal.CloseDate;
                    productSearchDealWrp.retailerProductId  = '0010';
                    productSearchDealWrp.productFormat = 'HD';
                    productSearchDealWrp.dealCurrency = digitalDeal.currencyISOCode;
                    productSearchDealWrp.language = 'en';
                    productSearchDealWrp.channel = 'EST';
                    productSearchDealWrpList.add(productSearchDealWrp);
                    CRM_UploadDealProductsController.CRM_SearchProductHandler productSearch = new CRM_UploadDealProductsController.CRM_SearchProductHandler(digitalDeal,products.keySet());
                    pbep = productSearch.getProductRetailerPricebookEntryPeriod(productSearchDealWrp);
                            
                    //update existing record
                    lineItems[0].lineItemRecord.UnitPrice = 12;
                    lineItems[0].isRowModified = true;
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,digitalDeal.id, true);
                    /*************************************asserts***********************************************/
                    system.assertEquals(Label.CRM_Upload_Message_Updated, savedlineItems[0].validation);
                    system.assertEquals(Label.CRM_Upload_Message_Created, savedlineItems[savedlineItems.size()-1].validation);
                    try{
                         CRM_UploadDealProductsController.deleteOpportunityLineItems(lineItems);
                    }
                    catch(Exception e){
                        system.assertEquals(true, e.getMessage().contains('null'));
                    }
                    
        Test.stopTest();
    }
    
    /**
    *  Test 3: Test to update existing deal product record of physical deal with improper information
    *  Expected: record should not be updated and should throw exception
    *  @name unitTestException
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    
    static testMethod void unitTestException() {
        allTheDataForThisTestClass();
        Id physicalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName, 
                                           (select id,Quantity,UnitPrice,Product2Id, Product2.productCode from OpportunityLineitems)
                                           from Opportunity
                                           where recordTypeId =: physicalRecordTypeId];
       system.debug('============opportunities============'+opportunities);
       Opportunity physicalDeal = opportunities[0];
       Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',physicalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(physicalDeal);
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller); 
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(physicalDeal.id);
                    /*************************************prepare data start***********************************************/
                    //update existing record
                    lineItems[0].lineItemRecord.Quantity = 0;
                    lineItems[0].isRowModified = null;
                    /*************************************prepare data end***********************************************/
                    try {
                        list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);
                    }
                    catch(Exception e){
                        /*************************************asserts***********************************************/
                        system.assertEquals(true, e.getMessage().contains('null'));
                    }
                    
        Test.stopTest();
    }
    
    /**
    *  Test 4: Test to insert new deal product record and update existing deal product record of physical deal with improper information
    *  Expected: record should not be created/updated and should throw validation messages
    *  @name unitTestValidationFailed
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestValidationFailed() {
        allTheDataForThisTestClass();
        Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,pricebook2Id,currencyISOCode,
                                           (select id from OpportunityLineitems)
                                           from Opportunity
                                           where recordTypeId =: digitalRecordTypeId];
        system.debug('============opportunities============'+opportunities);
        Opportunity digitalDeal = opportunities[0];
        
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',digitalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(digitalDeal);
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller); 
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(digitalDeal.id);
                    system.assertEquals(true, pg.getDigitalDeal());
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadDealProductsController.OpportunityLineItemWrapper wrapper = new CRM_UploadDealProductsController.OpportunityLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.digital = new CRM_UploadDealProductsController.DigitalDealWrapper();
                    wrapper.digital.videoVersion ='123456';
                    wrapper.digital.channel ='EST';
                    wrapper.digital.format ='HD';
                    wrapper.digital.language ='en';
                    if(lineItems[0].lineItemRecord.Product2.External_Id__c== 'USA_en_12345_EST_HD')
                        wrapper.digital.language ='fr';
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    lineItems.add(wrapper);
                    
                    System.debug('lineItems size: ' + lineItems.size());
                    
                    //update existing record
                    lineItems[0].lineItemRecord.Quantity = 0;
                    lineItems[0].lineItemRecord.Reason__c = 'Advertising';
                    lineItems[0].lineItemRecord.Replen_Quantity__c = 0;
                    lineItems[0].isRowModified = true;
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,digitalDeal.id, true);
                    
                    /*************************************asserts***********************************************/
                    for(CRM_UploadDealProductsController.OpportunityLineItemWrapper wrp: savedlineItems) {
                        if(wrp.digital.videoVersion =='123456') {
                            system.assertEquals(Label.CRM_Upload_Message_NotFound, wrp.validation);
                        }
                        if(wrp.lineItemRecord.id==lineItems[0].lineItemRecord.id) {
                            system.assertNotEquals(Label.CRM_Upload_Message_Updated, wrp.validation);
                        }
                        
                    }
                    
        Test.stopTest();
    }
    
     /**
    *  Test 5: Test to insert new deal product record and update existing deal product record of physical deal with improper information
    *  Expected: record should not be created/updated and should throw validation messages
    *  @name unitTestValidationFailed
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestValidationFailed2() {
        allTheDataForThisTestClass();
        Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,pricebook2Id,currencyISOCode, 
                                           (select id,Product2.Type__c,Product2.External_Id__c,Opportunity.CloseDate from OpportunityLineitems)
                                           from Opportunity
                                           where recordTypeId =: digitalRecordTypeId];
        system.debug('============opportunities============'+opportunities);
        Opportunity digitalDeal = opportunities[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',digitalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(digitalDeal);
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller); 
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(digitalDeal.id);
                    system.assertEquals(true, pg.getDigitalDeal());
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadDealProductsController.OpportunityLineItemWrapper wrapper = new CRM_UploadDealProductsController.OpportunityLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.digital = new CRM_UploadDealProductsController.DigitalDealWrapper();
                    wrapper.digital.videoVersion ='12345';
                    wrapper.digital.channel ='EST';
                    wrapper.digital.format ='HD';
                    wrapper.digital.language ='gr';
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    wrapper.lineItemRecord.Reason__c = 'Advertising & Space';
                    lineItems.add(wrapper);
                    system.debug('=======wrapper======='+wrapper);
                    CRM_UploadDealProductsController.OpportunityLineItemWrapper wrapper1 = new CRM_UploadDealProductsController.OpportunityLineItemWrapper();
                    wrapper1.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper1.lineItemRecord.Reason__c = 'Space';
                    wrapper1.digital = new CRM_UploadDealProductsController.DigitalDealWrapper();
                    wrapper1.digital.videoVersion ='12345';
                    wrapper1.digital.channel ='EST';
                    wrapper1.digital.format ='HD';
                    wrapper1.digital.language ='fr';
                    wrapper1.isRowModified=true;
                    wrapper1.existingId=null;
                    lineItems.add(wrapper1);
                    
                    Pricebook_Entry_Period__c pbep = [select id, Start_Date__c, End_Date__c,Product__r.External_Id__c from Pricebook_Entry_Period__c where Product__r.External_Id__c='USA_fr_12345_EST_HD' limit 1];
                    pbep.Start_Date__c = digitalDeal.CloseDate+1;
                    pbep.End_Date__c = pbep.Start_Date__c + 30;
                    update pbep;
                    system.debug('=======pbep======='+pbep);
                    system.debug('=======wrapper======='+wrapper);
                    //update existing record
                    //lineItems[0].lineItemRecord.product2.Street_Date__c = system.today()+10;
                    //lineItems[0].isRowModified = true;
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,digitalDeal.id, true);
                    
                    /*************************************asserts***********************************************/
                    for(CRM_UploadDealProductsController.OpportunityLineItemWrapper wrp: savedlineItems) {
                        if(wrp.digital.language=='gr') {
                            system.assertEquals(Label.CRM_Upload_Message_Type_Mismatch, wrp.validation);
                        }
                        if(wrp.digital.language=='fr') {
                            system.assertEquals(Label.CRM_Upload_Message_PBEP, wrp.validation);
                        }
                        //if(wrp.lineItemRecord.id==lineItems[0].lineItemRecord.id) {
                          //  system.assertEquals(Label.CRM_Upload_Message_Dates, wrp.validation);
                        //}
                    }
                    pg.getUserLocale();
              pg.opp = null;
              pg.getIsConsignmentCustomer();
              pg.opp = null;
              pg.getShowCoopFields();
              pg.opp = null;
              pg.getIsJapanRentalDeal();
              pg.opp = null;
              pg.getIsNRDeal();
              pg.opp = null;
              pg.getIsCoOpClosed();

                    try{
                        digitalDeal.accountID = null;
                        update digitalDeal;
                    }catch(system.Exception de){
                        CRM_UploadDealProductsController.logException(digitalDeal.Id,de);
                    } 
        Test.stopTest();
    }
    /**
    *  Test 1: Test to insert new deal products into physical deal
    *  Expected: new record should get inserted
    *  @name unitTestJapanRentalPhysical
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    
    static testMethod void unitTestJapanRentalPhysical() {

        list<Account> accounts = CRM_TestDataFactory.createAccounts(2, true);
        //update accounts
        accounts[0].Video_Digital__c  = false;
        accounts[0].Games_Digital__c  = false;
        accounts[0].Video_Physical__c = true;
        accounts[0].Games_Physical__c = true;
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        //accounts[0].Storefront__c = storefronts[0].id;
        accounts[0].Revenue_Share__c = true;
        update accounts;
        
        List<Account> physicalAccount = new List<Account>();
        
        physicalAccount.add(accounts[0]);
        
        //update opps with recordtypes
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(physicalAccount,1, false);
        opps[0].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        opps[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        insert opps;
        
        List<String> strRegion = new List<String>();    
        strRegion.add('FR');
        strRegion.add('UK');
        
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1,false);
        lstCountries[0].Country_Code2__c = 'FR';
        lstCountries[1].Country_Code2__c = 'UK';
        insert lstCountries;
        
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(2, false);
        lstLang[0].Language_Code_2__c = 'en';
        lstLang[1].Language_Code_2__c = 'fr';
        insert lstLang;
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Language__c = lstLang[0].Id;
        lstLocalData[1].Language__c = lstLang[1].Id;
        insert lstLocalData;
        system.assertEquals(2,[select count() from Local_Title__c]);
                
        List<Product_Group__c> digitalPG = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> physicalProducts = CRM_TestDataFactory.createProducts(digitalPG, 2, false);
        physicalProducts[0].productCode= 'code1';
        physicalProducts[1].productCode='code2';
        physicalProducts[0].External_Id__c= 'USA_gr_12345_EST_HD';
        physicalProducts[0].Universal_Picture_Code__c ='upc1';
        physicalProducts[1].Universal_Picture_Code__c='upc2';
        physicalProducts[0].Local_Title__c = lstLocalData[0].Id;
        physicalProducts[1].Local_Title__c = lstLocalData[1].Id;
        physicalProducts[0].Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        physicalProducts[1].Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        physicalProducts[0].Type__c= CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE;
        physicalProducts[1].Type__c=CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        physicalProducts[0].recordtypeId= CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        physicalProducts[1].recordtypeId=CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        insert physicalProducts;
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : physicalProducts){
           productIds.add(prod.Id); 
        }
        
        List<PricebookEntry> pbEntriesPhysical = CRM_TestDataFactory.createPriceBookEntries(physicalProducts, 1, true);
        List<Pricebook_Entry_Period__c> physicalPEB=CRM_TestDataFactory.createPriceBookEntryPeriods(physicalProducts, 1, true);
        List<Decay_Curve_Template__c> dct = CRM_TestDataFactory.createDecayCurveTemplates(1,true);
        List<Decay_Curve_Item__c> dci = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(dct,1,false);
        dci[0].Percent_Allocation__c = 100;
        insert dci;
        
        dct[0].Status__c = 'Active';
        update dct;
        
        List<OpportunityLineItem> dealproductsP = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntriesPhysical, new list<Opportunity>{opps[0]}, 2, false);
        dealproductsP[0].UnitPrice = 10;
        dealproductsP[0].Promoted_Price__c=15;
        //dealproductsP[0].Override_Pricing__c = false;
        dealproductsP[0].Handling_Fee__c = 10;
        dealproductsP[0].Decay_Curve_Template__c = dct[0].Id;
        dealproductsP[1].UnitPrice = 10;
        dealproductsP[1].Promoted_Price__c=15;
        //dealproductsP[1].Override_Pricing__c = true;
        dealproductsP[1].Rental_Price__c = 10;
        dealproductsP[1].Decay_Curve_Template__c = dct[0].Id;
        insert dealproductsP;
        system.assertEquals(2,dealproductsP.size());
        Opportunity physicalDeal = opps[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',physicalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(physicalDeal);
                    Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();         
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller);
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(physicalDeal.id);// method
                    system.assertEquals(false, pg.getDigitalDeal());
                                    
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadDealProductsController.OpportunityLineItemWrapper wrapper = new CRM_UploadDealProductsController.OpportunityLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Product2.productCode ='code1';
                    wrapper.lineItemRecord.Product2.Universal_Picture_Code__c='upc1';
                    wrapper.lineItemRecord.Reason__c = 'Space';
                    if(lineItems[0].lineItemRecord.Product2.productCode =='code1') {
                        wrapper.lineItemRecord.Product2.productCode ='code2';
                        wrapper.lineItemRecord.Product2.Universal_Picture_Code__c='upc2';
                    }    
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    lineItems.add(wrapper);
                    
                    //update existing record
                    lineItems[0].lineItemRecord.UnitPrice = 12;
                    lineItems[0].isRowModified = true;
                    /*************************************prepare data end***********************************************/
                    
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method
                    /*************************************asserts***********************************************/
                    system.assertEquals(System.Label.CRM_Enter_Value_For_Rental_Fields, savedlineItems[0].validation);
                    
                    
                    //update existing record
                    lineItems[0].isRowRemoved = true;
                    /*************************************prepare data for delete***********************************************/
                    
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> dellineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method
                    /*************************************asserts***********************************************/
                    //system.assertEquals(savedlineItems.size()-1, dellineItems.size());
                    try{
                         CRM_UploadDealProductsController.deleteOpportunityLineItems(lineItems);
                    }
                    catch(Exception e){
                        system.assertEquals(true, e.getMessage().contains('null'));
                    }
        Test.stopTest();
    }
    
    static testMethod void unitTestJapanRentalPhysicalValidation1() {

        list<Account> accounts = CRM_TestDataFactory.createAccounts(2, true);
        //update accounts
        accounts[0].Video_Digital__c  = false;
        accounts[0].Games_Digital__c  = false;
        accounts[0].Video_Physical__c = true;
        accounts[0].Games_Physical__c = true;
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        //accounts[0].Storefront__c = storefronts[0].id;
        accounts[0].Revenue_Share__c = true;
        update accounts;
        
        List<Account> physicalAccount = new List<Account>();
        
        physicalAccount.add(accounts[0]);
        
        //update opps with recordtypes
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(physicalAccount,1, false);
        opps[0].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        opps[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        insert opps;
        
        List<Product_Group__c> digitalPG = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> physicalProducts = CRM_TestDataFactory.createProducts(digitalPG, 2, false);
        physicalProducts[0].productCode= 'code1';
        physicalProducts[1].productCode='code2';
        physicalProducts[0].External_Id__c= 'USA_gr_12345_EST_HD';
        physicalProducts[0].Universal_Picture_Code__c ='upc1';
        physicalProducts[1].Universal_Picture_Code__c='upc2';
        physicalProducts[0].Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        physicalProducts[1].Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        physicalProducts[0].Type__c= CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE;
        physicalProducts[1].Type__c=CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        physicalProducts[0].recordtypeId= CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        physicalProducts[1].recordtypeId=CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        insert physicalProducts;
        Set<Id> productIds = new Set<Id>();
        for(Product2 prod : physicalProducts){
            productIds.add(prod.Id);
        }
        
        List<PricebookEntry> pbEntriesPhysical = CRM_TestDataFactory.createPriceBookEntries(physicalProducts, 1, true);
        List<Pricebook_Entry_Period__c> physicalPEB=CRM_TestDataFactory.createPriceBookEntryPeriods(physicalProducts, 1, true);
        List<Decay_Curve_Template__c> dct = CRM_TestDataFactory.createDecayCurveTemplates(1,true);
        List<Decay_Curve_Item__c> dci = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(dct,1,false);
        dci[0].Percent_Allocation__c = 100;
        insert dci;
        
        dct[0].Status__c = 'Active';
        update dct;
    
        List<OpportunityLineItem> dealproductsP = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntriesPhysical, new list<Opportunity>{opps[0]}, 2, true);
        Opportunity physicalDeal = opps[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',physicalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(physicalDeal);
                    Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();         
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller);
                    
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(physicalDeal.id);// method
                    system.assertEquals(false, pg.getDigitalDeal());                                                          
                    
                    //update existing record
                    lineItems[0].lineItemRecord.Rental_Price__c = 10;
                    //lineItems[0].lineItemRecord.Handling_Fee__c = 10;
                    lineItems[0].isRowModified = true;
                    
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method

                    system.assertEquals(System.Label.CRM_Enter_Value_For_Rental_Fields, savedlineItems[0].validation);
                    
                    lineItems[0].lineItemRecord.Rental_Price__c = 10;
                    lineItems[0].lineItemRecord.Handling_Fee__c = 10;
                    lineItems[0].isRowModified = true;
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems1 = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method

                    system.assertEquals(System.Label.CRM_Enter_Value_For_Rental_Fields, savedlineItems1[0].validation);

                    lineItems[0].lineItemRecord.Revenue_Share__c = 10;
                    lineItems[0].isRowModified = true;
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems2 = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method

                    system.assertEquals(System.Label.CRM_Enter_Value_For_Rental_Fields, savedlineItems2[0].validation);
                    
                    lineItems[0].lineItemRecord.Number_of_Rentals_per_Unit__c = 10;
                    lineItems[0].isRowModified = true;
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems3 = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method

                    system.assertEquals(System.Label.CRM_Enter_Value_For_Rental_Fields, savedlineItems3[0].validation);

        Test.stopTest();
    }
    
    static testMethod void unitTestJapanRentalPhysicalValidation2() {

        list<Account> accounts = CRM_TestDataFactory.createAccounts(2, true);
        //update accounts
        accounts[0].Video_Digital__c  = false;
        accounts[0].Games_Digital__c  = false;
        accounts[0].Video_Physical__c = true;
        accounts[0].Games_Physical__c = true;
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        //accounts[0].Storefront__c = storefronts[0].id;
        accounts[0].Revenue_Share__c = true;
        update accounts;
        
        List<Account> physicalAccount = new List<Account>();
        
        physicalAccount.add(accounts[0]);
        
        //update opps with recordtypes
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(physicalAccount,1, false);
        opps[0].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        opps[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        insert opps;
        
        List<Product_Group__c> digitalPG = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> physicalProducts = CRM_TestDataFactory.createProducts(digitalPG, 2, false);
        physicalProducts[0].productCode= 'code1';
        physicalProducts[1].productCode='code2';
        physicalProducts[0].External_Id__c= 'USA_gr_12345_EST_HD';
        physicalProducts[0].Universal_Picture_Code__c ='upc1';
        physicalProducts[1].Universal_Picture_Code__c='upc2';
        physicalProducts[0].Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        physicalProducts[1].Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
        physicalProducts[0].Type__c= CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE;
        physicalProducts[1].Type__c=CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        physicalProducts[0].recordtypeId= CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        physicalProducts[1].recordtypeId=CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        insert physicalProducts;
        
        List<PricebookEntry> pbEntriesPhysical = CRM_TestDataFactory.createPriceBookEntries(physicalProducts, 1, true);
        List<Pricebook_Entry_Period__c> physicalPEB=CRM_TestDataFactory.createPriceBookEntryPeriods(physicalProducts, 1, true);
        List<Decay_Curve_Template__c> dct = CRM_TestDataFactory.createDecayCurveTemplates(1,true);
        List<Decay_Curve_Item__c> dci = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(dct,1,false);
        dci[0].Percent_Allocation__c = 100;
        insert dci;
        
        dct[0].Status__c = 'Active';
        update dct;
    
        List<OpportunityLineItem> dealproductsP = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntriesPhysical, new list<Opportunity>{opps[0]}, 2, true);
        Opportunity physicalDeal = opps[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',physicalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(physicalDeal);
                    Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();         
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller);
                    
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(physicalDeal.id);// method
                    system.assertEquals(false, pg.getDigitalDeal());                                                          
    
                    lineItems[0].lineItemRecord.Rental_Price__c = 10;
                    lineItems[0].lineItemRecord.Handling_Fee__c = 10;
                    lineItems[0].lineItemRecord.Revenue_Share__c = 10;
                    lineItems[0].lineItemRecord.Number_of_Rentals_per_Unit__c = 10;
                    lineItems[0].lineItemRecord.Final_Purchase_Price__c = 10;
                    lineItems[0].isRowModified = true;
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method

                    system.assertEquals(System.Label.CRM_Enter_Value_For_Rental_Fields, savedlineItems[0].validation);
                    
                    lineItems[0].lineItemRecord.Final_Purchase_Price__c = 10;
                    lineItems[0].lineItemRecord.Final_Purchase__c = 10;
                    lineItems[0].isRowModified = true;
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems1 = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method

                    system.assertEquals(system.Label.CRM_Enter_Value_For_Decay_Curve_Template_Japan, savedlineItems1[0].validation);
                    
                    lineItems[0].lineItemRecord.Decay_Curve_Template__c = dct[0].Id;
                    lineItems[0].isRowModified = true;
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems2 = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,physicalDeal.id, false);// method

        Test.stopTest();
    }
    
     /**
    *  Test : Test to insert new deal products into Digital deal and update existing deal product record 
    *  Expected: new record should get inserted and existing should get updated
    *  @name unitTestDigitalUSCAN
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestDigitalUSCAN() {
        allTheDataForThisTestClass();
        
        Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,currencyISOCode,pricebook2Id,Opportunity.RecordTypeId, 
                                           (select id from OpportunityLineitems)
                                           from Opportunity
                                           where recordTypeId =: digitalRecordTypeId];
        Map<Id,Product2> mapProducts = new Map<Id,product2>([SELECT Id From Product2]);
        system.debug('============opportunities============'+opportunities);
        Opportunity digitalDeal = opportunities[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadDealProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',digitalDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(digitalDeal);
                    Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();
                    CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller);                 
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(digitalDeal.id);
                    system.assertEquals(true, pg.getDigitalDeal());
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadDealProductsController.OpportunityLineItemWrapper wrapper = new CRM_UploadDealProductsController.OpportunityLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.digital = new CRM_UploadDealProductsController.DigitalDealWrapper();
                    wrapper.digital.videoVersion ='12345';
                    wrapper.digital.channel ='EST';
                    wrapper.digital.format ='HD';
                    wrapper.digital.language ='en';

                    if(lineItems[0].lineItemRecord.Product2.External_Id__c == 'USA_en_12345_EST_HD')
                     wrapper.digital.language ='fr';
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    wrapper.lineItemRecord.UnitPrice=null;
                    wrapper.lineItemRecord.Reason__c = 'Advertising';
                    lineItems.add(wrapper);
                    
                    //product search
                    CRM_UploadDealProductsController.DealWrapper  productSearchDealWrp = new CRM_UploadDealProductsController.DealWrapper();
                    list<CRM_UploadDealProductsController.DealWrapper> productSearchDealWrpList = new list<CRM_UploadDealProductsController.DealWrapper>();
                    productSearchDealWrp.dealId = digitalDeal.Id;
                    productSearchDealWrp.accountId = digitalDeal.AccountId;
                    productSearchDealWrp.dealCurrency = digitalDeal.currencyISOCode;
                    productSearchDealWrp.pricebookId = digitalDeal.pricebook2Id;
                    productSearchDealWrp.dealStartDate = digitalDeal.Start_Date__c;
                    productSearchDealWrp.dealEndDate  = digitalDeal.CloseDate;
                    productSearchDealWrp.retailerProductId  = '0010';
                    productSearchDealWrp.vendorId  = '808080';
                    productSearchDealWrp.productFormat = 'HD';
                    productSearchDealWrp.dealCurrency = digitalDeal.currencyISOCode;
                    productSearchDealWrp.language = 'en';
                    productSearchDealWrp.channel = 'EST';
                    productSearchDealWrpList.add(productSearchDealWrp);
                    CRM_UploadDealProductsController.CRM_SearchProductHandler productSearch = new CRM_UploadDealProductsController.CRM_SearchProductHandler(digitalDeal,mapProducts.keySet());
                    pbep = productSearch.getProductRetailerPricebookEntryPeriod(productSearchDealWrp);
                    //update existing record
                    lineItems[0].lineItemRecord.UnitPrice = 12;
                    lineItems[0].isRowModified = true;
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,digitalDeal.id, true);
                    /*************************************asserts***********************************************/
                    system.assertEquals(Label.CRM_Upload_Message_Updated, savedlineItems[0].validation);
                    system.assertEquals(Label.CRM_Upload_Message_Created, savedlineItems[savedlineItems.size()-1].validation);
                    pg.opp = null;        
                    pg.getIsUSCANDeal();
                    try{
                         CRM_UploadDealProductsController.deleteOpportunityLineItems(lineItems);
                    }
                    catch(Exception e){
                        system.assertEquals(true, e.getMessage().contains('null'));
                    }
                    
        Test.stopTest();
    }
    
     /**
    *  Test : Test to insert new deal products into Digital deal and update existing deal product record 
    *  Expected: new record should get inserted and existing should get updated
    *  @name unitTestDigitalUSCAN
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestDigitalUSCANWithRetailerIDOrVendotId() {
        allTheDataForThisTestClass();
        Id digitalRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,currencyISOCode,pricebook2Id, 
                                           (select id from OpportunityLineitems)
                                           from Opportunity
                                           where recordTypeId =: digitalRecordTypeId];
        Opportunity digitalDeal = opportunities[0];
        
        Test.startTest();
            PageReference pageRef = Page.CRM_UploadDealProducts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',digitalDeal.id);
            ApexPages.standardController controller = new ApexPages.standardController(digitalDeal);
            CRM_UploadDealProductsController pg = new CRM_UploadDealProductsController(controller);           
            list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> lineItems = CRM_UploadDealProductsController.getOpportunityLineItems(digitalDeal.id);
            system.assertEquals(true, pg.getDigitalDeal());
            
            //insert new Record
            CRM_UploadDealProductsController.OpportunityLineItemWrapper wrapper = new CRM_UploadDealProductsController.OpportunityLineItemWrapper();
            wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
            wrapper.digital = new CRM_UploadDealProductsController.DigitalDealWrapper();
            wrapper.isRowModified=true;
            wrapper.existingId=null;
            wrapper.lineItemRecord.UnitPrice=null;
            wrapper.lineItemRecord.Reason__c = 'Advertising';
            lineItems.add(wrapper);
            
            list<CRM_UploadDealProductsController.OpportunityLineItemWrapper> savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,digitalDeal.id, true);
            system.assertEquals(system.label.CRM_Digital_deal_Validation_For_UploadExtract, savedlineItems[1].validation,'VendorId/RetailerId/videoVersion Error Msg');
            
            wrapper.digital.retailerProductId ='RPID1234';
            savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,digitalDeal.id, true);
            system.assertEquals(system.label.CRM_Digital_deal_Format_Language_Channel_Validation, savedlineItems[1].validation,'Channel/Format/Language Error Msg');
            
            wrapper.digital.channel ='VODi';
            wrapper.digital.format ='DVD';
            wrapper.digital.language ='fr';
            
            savedlineItems = CRM_UploadDealProductsController.setOpportunityLineItems(lineItems,digitalDeal.id, true);
            system.assertEquals(system.label.CRM_Upload_Message_Created, savedlineItems[1].validation,'Record Created');
            
        Test.stopTest();  
    }
    
     /**
    *  Test : US : 909 : Test to search the record for Add prodcuts screen 
    *  Expected: Products get searched base on input
    *  @name unitTestDigitalUSCAN
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestingForSearchProductsScreenOnUploadExtract() {
        Id [] fixedSearchResults= new Id[1];
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        System.assertEquals(1, lstAccounts.size());
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        insert lstAccounts;
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 100, false);
        for (integer i=0;i<lstProduct.size();i++) {
            lstProduct[i].productCode = '1000'+i;
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        }
        lstProduct[0].productCode = 'TestProducts';
        lstProduct[0].External_Id__c = 'IRL_en_6000103443_EST_SD';
        insert lstProduct;
        
        for(Product2 prod  : [Select Id From Product2]){
            fixedSearchResults.add(prod.Id);
        }
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);       
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,2,false);
        Integer intCount = 0;
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = intCount > 0 ? CRM_RecordTypeUtil.RT_DEAL_DIGITAL : CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.Account = lstAccounts[0];
            intCount++;
        }
        insert lstDeals;
        
        Test.setFixedSearchResults(fixedSearchResults);
       
        String searchtext = 'TestProducts';
        List<CRM_UploadDealProductsController.productSearchWrapper> result = CRM_UploadDealProductsController.getProductsForAddSearchProductScreen(lstDeals[0].Id,lstDeals[0].pricebook2Id,searchtext);
        List<CRM_UploadDealProductsController.productSearchWrapper> result1 = CRM_UploadDealProductsController.getProductsForAddSearchProductScreen(lstDeals[1].Id,lstDeals[1].pricebook2Id,searchtext);
        system.assertNotEquals(result.size(),0);
    }
    
    /**
    *  Test : US : 936 : Need to hide Promoted_Price__c, ListPrice__c and Comments__c field on Upload/Extract screen
    *  Expected: above fields should not visible on Upload/Extract screen
    *  @name unitTestDigitalUSCAN
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestingHideFields() {
        Test.startTest();
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        System.assertEquals(1, lstAccounts.size());
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        insert lstAccounts;
        
        Integer intCount = 0;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,2,false);
        for(Opportunity opp : lstDeals) {
            opp.RecordTypeId = intCount > 0 ? CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND : CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.Account = lstAccounts[0];
            intCount++;
        }
        insert lstDeals;
        Test.stopTest();
        Apexpages.standardController std = new Apexpages.standardController(lstDeals[0]);
        CRM_UploadDealProductsController obj = new CRM_UploadDealProductsController(std);
        CRM_UploadDealProductsController.exportCSVFile(new List<String>{'Product Code', 'Product Name'});
        system.assertEquals(obj.getIsUSCANMEXTerritory(), true);
        Apexpages.standardController std1 = new Apexpages.standardController(lstDeals[1]);
        CRM_UploadDealProductsController obj1 = new CRM_UploadDealProductsController(std1);
        system.assertEquals(obj1.getIsUSCANMEXTerritory(), false);
    }
}