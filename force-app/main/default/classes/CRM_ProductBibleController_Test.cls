@isTest
private class CRM_ProductBibleController_Test {
    
    /**
*  Create Test Data. 
*  @name allTheDataForThisTestClass
*  @param None
*  @return None
*  @throws None
*/

    CRM_ProductBibleController.FilterWrapper FilterWrapper = new CRM_ProductBibleController.FilterWrapper();
    

    static void allTheDataForThisTestClass(){
        
        // create Storefront Account 
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        mainAccountForStoreFront[0].CurrencyISOCode = 'GBP';
        insert mainAccountForStoreFront;
        
        MPM__c   mpm = new MPM__c(MPM_Number__c = '12345');
        insert mpm;
        system.assertNotEquals(null, mpm.Id);
        
        
        Talent__c talent = new Talent__c(Name = 'Talent', Talent_Id__c = '55555');
        insert talent;
        system.assertNotEquals(null, talent.Id);
        
        MPM_Talent__c mpmTalent = new MPM_Talent__c(MPM__c = mpm.Id, Talent__c = talent.Id, Key__c = '98765', Role__c = 'Actor');
        insert mpmTalent;
        system.assertNotEquals(null, mpmTalent.Id);
        
        List<Title__c> lstTitle = CRM_TestDataFactory.createTitles(1, false);
        lstTitle[0].MPM__c = mpm.id;
        insert lstTitle;
        system.assertEquals(1, lstTitle.size());
        
        //create country
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'UK'}, 1, true);
        system.assertEquals(1, countries.size());
        
        //create storefronts
        list<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, lstTitle, countries, true);
        system.debug('====storefronts====='+storefronts);
        system.assertEquals(1, storefronts.size());
        
        List<Pricebook2> lstPB = CRM_TestDataFactory.createPricebooks(1, false);
        lstPB[0].CurrencyIsoCode = 'GBP';
        insert lstPB;
        system.assertEquals(1, lstPB.size());
        
        //update opps with recordtypes
        
        Test.startTest();
        
        list<Opportunity> digitalOpps = CRM_TestDataFactory.createOpportunitiesWithAccounts(mainAccountForStoreFront, 1, false);
        digitalOpps[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        digitalOpps[0].CurrencyIsoCode = 'GBP';
        digitalOpps[0].Pricebook2Id = lstPB[0].Id;
        insert digitalOpps;
        system.assertEquals(1, digitalOpps.size());        
        
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, false);
        lstLang[0].Language_Code_2__c = 'en';
        insert lstLang;
        system.assertEquals(1, lstLang.size());
        
        
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(countries, lstLang, 1, false);
        lstLocalData[0].Title__c = lstTitle[0].id;
        insert lstLocalData;
        system.assertEquals(1, lstLocalData.size());
        
        //create products and associate with Opportunities
        List<Product_Group__c> digitalPG = CRM_TestDataFactory.createProductGroups(1, true);
        system.assertEquals(1, digitalPG.size());
        
        List<Product2> digitalProducts = CRM_TestDataFactory.createProducts(digitalPG, 4, false);
        for(Product2 product : digitalProducts){
            product.Product_Market__c ='EST';
            product.Street_Date__c = System.today()+4;
            product.CurrencyIsoCode ='GBP';
            product.Local_Title__c = lstLocalData[0].Id;
            product.Product_Format__c ='HD';
            product.Type__c = CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE;
            product.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }    
        insert digitalProducts;
        system.assertEquals(4, digitalProducts.size());
        
        List<PricebookEntry> pbEntriesStd = CRM_TestDataFactory.createPriceBookEntries(digitalProducts, 1, false);
        for(PricebookEntry pbe : pbEntriesStd){
            pbe.CurrencyIsoCode = 'GBP';
        }
        insert pbEntriesStd;
        system.assertEquals(4, pbEntriesStd.size());
        
        List<PricebookEntry> pbEntriesDigital = CRM_TestDataFactory.createPriceBookEntriesStandard(digitalProducts, 1, false);
        for(PricebookEntry pbe : pbEntriesDigital){
            pbe.Pricebook2Id = lstPB[0].id;
        }
        insert pbEntriesDigital;
        system.assertEquals(4, pbEntriesDigital.size());
        
        List<Pricing__c> lstPricing = CRM_TestDataFactory.createPricings(1,false);
        lstPricing[0].Price_Tier__c = '20';
        insert lstPricing;
        system.assertEquals(1, lstPricing.size());
        
        List<Commercial_Avail__c> lstRP = CRM_TestDataFactory.createReleasePlans(1, lstTitle, storefronts, lstLocalData, countries, lstLang, true);
        system.assertEquals(1, lstRP.size());
        
        List<Client_Avail__c> lstCA = CRM_TestDataFactory.createClientAvails(lstPricing, lstRP, lstLocalData, mainAccountForStoreFront, storefronts, 1 ,false);
        lstCA[0].Status__c = 'Tentative';
        insert lstCA;
        system.assertEquals(1, lstCA.size());
        
        List<Pricebook_Entry_Period__c> digitalPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(digitalProducts, 1, false);
        for(Pricebook_Entry_Period__c pbep : digitalPBEP){
            pbep.CurrencyIsoCode = 'GBP';
            pbep.Start_Date__c = System.today() + 2;
            pbep.End_Date__c = System.today() + 25;
            pbep.Price_Book__c = lstPB[0].id;
            pbep.Account_Price__c = 14.50;
            pbep.Client_Avail__c = lstCA[0].Id;
        }
        insert digitalPBEP;
        system.assertEquals(4, digitalPBEP.size());
        
        List<OpportunityLineItem> dealproductsD = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntriesDigital, digitalOpps, 2, false);
        for(Integer i=0 ; i<dealproductsD.size() ; i++){
            dealproductsD[i].PricebookEntryId = pbEntriesDigital[i].id;
        }
        insert dealproductsD;
        system.assertEquals(2,dealproductsD.size());
        
        List<CRM_Field_Bible__c> lstCS = new List<CRM_Field_Bible__c>();
        lstCS.add(new CRM_Field_Bible__c(Name = 'mpm', Column_Label__c = 'MPM_Name__c', Wrapper_Label__c = 'mpmName', Record_Type__c = CRM_AppConstants.DIGITAL_INITIALS, Object__c = 'Product2', Order__c = 22));
        lstCS.add(new CRM_Field_Bible__c(Name = 'Age', Column_Label__c = 'Age', Wrapper_Label__c = 'mpmName', Record_Type__c = CRM_AppConstants.DIGITAL_INITIALS, Order__c = 21));
        lstCS.add(new CRM_Field_Bible__c(Name = 'RP', Column_Label__c = 'Current RP', Wrapper_Label__c = 'mpmName', Record_Type__c = CRM_AppConstants.DIGITAL_INITIALS));
        lstCS.add(new CRM_Field_Bible__c(Name = 'Validation', Column_Label__c = 'Validation', Wrapper_Label__c = 'mpmName', Record_Type__c = CRM_AppConstants.DIGITAL_INITIALS));
        lstCS.add(new CRM_Field_Bible__c(Name = 'Name', Column_Label__c = 'localTitleName', Wrapper_Label__c = 'mpmName', Record_Type__c = CRM_AppConstants.DIGITAL_INITIALS, Object__c = 'Product2'));
        
        insert lstCS;
        system.assertEquals(5, lstCS.size());
        Test.stopTest();
    }
    
    static testMethod void saveDealProduct() {
        allTheDataForThisTestClass();
        
        

        Opportunity digitalDeal = [SELECT Id, Name, Start_Date__c, CloseDate, AccountId, Account.Sales_Organization__c, StageName, Pricebook2Id, 
                                   CurrencyISOCode, Opportunity.RecordTypeId,
                                   (Select Id FROM OpportunityLineitems)
                                   FROM Opportunity
                                   WHERE RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL][0];
        
        List<PricebookEntry> pbEntries = [SELECT Id, Product2Id, Product2.ProductCode, Pricebook2Id FROM PricebookEntry 
                                          WHERE Pricebook2.IsStandard = false];
        system.debug(digitalDeal.Pricebook2Id+' '+pbEntries.size()+' '+pbEntries[2].Pricebook2Id);
        
        
        //Test.startTest();
        
        //PageReference pageRef = Page.CRM_ProductsBible;
        //Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id',digitalDeal.id);
        ApexPages.StandardController controller = new ApexPages.StandardController(digitalDeal);
        CRM_ProductBibleController pg = new CRM_ProductBibleController(controller); 
        
        List<CRM_DataObjects.PicklistOption> picklist1 = new List<CRM_DataObjects.PicklistOption>();
        picklist1.add(new CRM_DataObjects.PicklistOption('Actor','Actor'));
        
        CRM_ProductBibleController.FilterWrapper FilterWrapper2= new CRM_ProductBibleController.FilterWrapper();
        FilterWrapper2.roleFilter = picklist1;
        
        List<CRM_ProductBibleController.OpportunityWrapper> ow = CRM_ProductBibleController.getProducts(true, digitalDeal.Id, true, FilterWrapper2);
        
        List<CRM_ProductBibleController.OpportunityWrapper> lstDealWrapper = new List<CRM_ProductBibleController.OpportunityWrapper>();
        
        
        
        for(Integer i = 0 ; i <= 3 ; i++){
            CRM_ProductBibleController.OpportunityWrapper dealWrapper = new CRM_ProductBibleController.OpportunityWrapper();
            dealWrapper.pricebookEntryId = pbEntries[i].Id;
            dealWrapper.isDealProduct = true;
            dealWrapper.isRowModified = true;
            dealWrapper.quantity = 1;
            dealWrapper.listPrice = 10;
            lstDealWrapper.add(dealWrapper);
            system.assertEquals(i+1, lstDealWrapper.size());
        }
        
        List<CRM_ProductBibleController.OpportunityWrapper> dw = CRM_ProductBibleController.saveDealBibleProducts(lstDealWrapper, digitalDeal.Id, true);
        system.assertEquals(4, [SELECT count() from OpportunityLineItem]);
        
        /*List<Opportunity> TSOpps = [SELECT Id, Name, Start_Date__c, CloseDate, AccountId, Account.Sales_Organization__c, StageName, Pricebook2Id, 
CurrencyISOCode, Opportunity.RecordTypeId,
(Select Id FROM OpportunityLineitems)
FROM Opportunity
WHERE RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND];
*/
        List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>();
        CRM_DataObjects.PicklistOption option = new CRM_DataObjects.PicklistOption('Actor' ,'Actor');
        options.add(option);
        
        List<CRM_DataObjects.PicklistOption> options2 = new List<CRM_DataObjects.PicklistOption>();
        CRM_DataObjects.PicklistOption option2 = new CRM_DataObjects.PicklistOption('All Roles' ,Label.CRM_AllRoles);
        options2.add(option2);
        
        Set<String> mpmNos = new Set<String>{'12345'};
            
        Set<String> setMPM = CRM_ProductBibleController.getProductsWithMPMFilter(mpmNos, FilterWrapper2);
        System.debug('setMPM+++++'+setMPM);
        List<String> lstMPM = new List<String>();
        lstMPM.addAll(setMPM);
        System.debug('lstMPM+++++'+lstMPM);
        system.assertEquals('12345', lstMPM[0]);
        
        Set<String> setMPM2 = CRM_ProductBibleController.getProductsWithMPMFilter(mpmNos, FilterWrapper2);
        List<String> lstMPM2 = new List<String>(setMPM2);
        system.assertEquals('12345', lstMPM2[0]);
        
        pg.getUserLocaleLanguage();
        pg.getUserLocaleLowerCase();
        pg.getRCEditAccess();
        pg.getResourceURL();
        pg.getUserLocale();
        pg.getDigitalDeal();
        pg.getHandsonTable_Pro_Licencekey();
        
        //Test.stopTest();
    }
    
    
    static testMethod void deleteDealProduct() {
        allTheDataForThisTestClass();
        
        //Test.startTest();
        
        Opportunity digitalDeal = [SELECT Id, Name, Start_Date__c, CloseDate, AccountId, Account.Sales_Organization__c, StageName, Pricebook2Id, 
                                   CurrencyISOCode, Opportunity.RecordTypeId,
                                   (Select Id FROM OpportunityLineitems)
                                   FROM Opportunity
                                   WHERE RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL][0];
        
        List<PricebookEntry> pbEntries = [SELECT Id, Product2Id, Product2.ProductCode, Pricebook2Id FROM PricebookEntry 
                                          WHERE Pricebook2.IsStandard = false];
        system.debug(digitalDeal.Pricebook2Id+' '+pbEntries.size()+' '+pbEntries[2].Pricebook2Id);
        
        //Test.startTest();
        
        //PageReference pageRef = Page.CRM_ProductsBible;
        //Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id',digitalDeal.id);
        ApexPages.StandardController controller = new ApexPages.StandardController(digitalDeal);
        CRM_ProductBibleController pg = new CRM_ProductBibleController(controller); 
        
        List<OpportunityLineItem> existingOLI = [SELECT Id FROM OpportunityLineItem];
        
        List<CRM_ProductBibleController.OpportunityWrapper> lstDealWrapperDel = new List<CRM_ProductBibleController.OpportunityWrapper>();
        
        CRM_ProductBibleController.OpportunityWrapper dealWrapper = new CRM_ProductBibleController.OpportunityWrapper();
        dealWrapper.existingId = existingOLI[0].Id;
        dealWrapper.isDealProduct = false;
        dealWrapper.isRowModified = true;
        dealWrapper.quantity = 1;
        dealWrapper.listPrice = 10;
        lstDealWrapperDel.add(dealWrapper);
        
        List<CRM_ProductBibleController.OpportunityWrapper> dw = CRM_ProductBibleController.saveDealBibleProducts(lstDealWrapperDel, digitalDeal.Id, true);
        system.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);
        
        List<CRM_ProductBibleController.OpportunityWrapper> lstDealWrapperDel2 = new List<CRM_ProductBibleController.OpportunityWrapper>();
        
        CRM_ProductBibleController.OpportunityWrapper dealWrapper2 = new CRM_ProductBibleController.OpportunityWrapper();
        dealWrapper2.existingId = existingOLI[0].Id;
        dealWrapper2.isDealProduct = false;
        dealWrapper2.isRowModified = true;
        dealWrapper2.quantity = 1;
        dealWrapper2.listPrice = 10;
        lstDealWrapperDel2.add(dealWrapper2);
    List<CRM_ProductBibleController.OpportunityWrapper> ow = CRM_ProductBibleController.saveDealBibleProducts(lstDealWrapperDel2, digitalDeal.Id, true);
        system.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);
        
        //Test.stopTest();
    }
}