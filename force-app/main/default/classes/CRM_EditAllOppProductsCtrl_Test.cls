/**
   @Author Cognizant
   @name CRM_EditAllOppProductsCtrl_Test
   @CreateDate 11 Nov 2015
   @Description Test class for CRM_EditAllOppProductsCtrl
   @Version <1.0>
   @reference Requirement no 35
  */

@isTest 
private class CRM_EditAllOppProductsCtrl_Test {
   /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None 
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static void createTestData() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        System.assertEquals(1, lstAccounts.size());
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert lstAccounts;
        
        //create country
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        //create storefronts
        list<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(lstAccounts, 'USD', countries[0].id,true);
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 200, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);       
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,true);
        
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Video_Digital__c  = true;
        lstAccounts[0].Games_Digital__c  = true;
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        lstAccounts[0].Storefront__c = storefronts[0].id;
        update lstAccounts;
        
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
            opp.Account = lstAccounts[0];
        }
        update lstDeals;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);
        for (OpportunityLineItem dealProduct : lstDealProduct) {
            dealProduct.Discount = 10;
        }
        insert lstDealProduct;
        System.AssertEquals(10,lstDealProduct[0].Discount,'Deal Product Discount is available');

        // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        //List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, true);
    }
    /**
    *  Test 1: Update Deal product schedule. 
    *  @name updateDealProductSchedule
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void updateDealProductSchedule(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];

        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            System.assert(![Select ID FROM OpportunityLineItemSchedule].isEmpty(), 'Schedule should be present');

            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
            CRM_DataObjects.ProductToEdit[] lstProd = CRM_EditAllOppProductsCtrl.getLineItems(deal.Id,null);

            for(CRM_DataObjects.ProductToEdit prod : lstProd){
                prod.customerRetailPrice = 100.00;
                prod.discount = 10;
                prod.replenQuantity = 10;
                prod.startDate = System.now().format('MM/dd/yyyy');
            }
            CRM_EditAllOppProductsCtrl.saveLineItems(deal.Id, lstProd, true);
            System.assert(![Select ID FROM OpportunityLineItemSchedule].isEmpty(), 'Schedule should be recalculated');
        }
    }

   /**
    *  Test 2: Remove deal product
    *  @name removeDealProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void removeDealProduct(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];

        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];

            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
            CRM_DataObjects.ProductToEdit[] lstProd = CRM_EditAllOppProductsCtrl.getLineItems(deal.Id,null);

            for(CRM_DataObjects.ProductToEdit prod : lstProd){
                prod.totalQty = 0;
            }

            CRM_EditAllOppProductsCtrl.saveLineItems(deal.Id, lstProd, false);

            System.assert([Select ID FROM OpportunityLineItem WHERE opportunityID =:deal.ID ].isEmpty(), 'Deal product should be deleted');
        }
    }

    /**
    *  Test 3: Test Negative case
    *  @name negativeCase
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void negativeCase(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];

        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            Opportunity deal = [Select ID,Pricebook2Id,Account.Price_Book__c,Account.Price_Book__r.Country__c FROM Opportunity][0];

            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
            CRM_DataObjects.ProductToEdit[] lstProd = CRM_EditAllOppProductsCtrl.getLineItems(deal.Id,null);
            System.assertEquals(1, lstProd.size());

            for(CRM_DataObjects.ProductToEdit prod : lstProd){
                prod.scheduleEnabled = true;
                prod.totalQty = 1;
            }

            try{
                CRM_EditAllOppProductsCtrl.saveLineItems(null, null, false);
            }catch(exception e){
                System.assertEquals('Attempt to de-reference a null object',e.getMessage());
            }
        }
    }
    /* Invalid due to validation rule : Deal must be created in Planned Status
    static testMethod void verifyReadOnlyPageTest(){
        createTestData();
        // Create 2 Physical deals
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 3, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CLOSED;
        }
        insert lstDeals;

        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(lstDeals[0]);
        CRM_EditAllOppProductsCtrl ctrl1 = new CRM_EditAllOppProductsCtrl(sc1);
        System.assert(ctrl1.isPageReadOnly, 'This should be true as the deal is Closed.');

        Test.stopTest();
    }*/
    static testMethod void verifyDigitalDealTest(){
        createTestData();
        // Create 2 Physical deals
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 3, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        }
        insert lstDeals;

        // Verify 5 deals present. 2 Digital and 3 Phisical
        System.assertEquals(4, [SELECT Id FROM Opportunity].size());

        Test.startTest();
        List<Opportunity> digitalDeals = [Select ID FROM Opportunity WHERE RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL];
        System.assertEquals(1, digitalDeals.size());

        ApexPages.StandardController sc1 = new ApexPages.StandardController(digitalDeals[0]);
        CRM_EditAllOppProductsCtrl ctrl1 = new CRM_EditAllOppProductsCtrl(sc1);
        System.assert(ctrl1.getIsDigitalDeal(), 'This should be true as the deal is Digital deal');
        
        ctrl1.getUserLocale();
        ctrl1.getIsQuantityReadOnly();
        List<Opportunity> physicalDeals = [Select ID FROM Opportunity WHERE RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL];
        System.assertEquals(3, physicalDeals.size());

        ApexPages.StandardController sc2 = new ApexPages.StandardController(physicalDeals[0]);
        CRM_EditAllOppProductsCtrl ctrl2 = new CRM_EditAllOppProductsCtrl(sc2);
        System.assert(!ctrl2.getIsDigitalDeal(), 'This should be false as the deal is Physical deal');
        Test.stopTest();
    }

    static testMethod void verifyIsConsignmentCustomer(){
        createTestData();
        // Create 1 consignment customer account for 3 physical deals
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Consignment_Customer__c = true;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 3, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        }
        insert lstDeals;

        // Verify 5 deals present. 2 Digital and 3 Phisical
        System.assertEquals(4, [SELECT Id FROM Opportunity].size());

        Test.startTest();
        List<Opportunity> digitalDeals = [Select ID FROM Opportunity WHERE RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_DIGITAL];
        System.assertEquals(1, digitalDeals.size());

        ApexPages.StandardController sc1 = new ApexPages.StandardController(digitalDeals[0]);
        CRM_EditAllOppProductsCtrl ctrl1 = new CRM_EditAllOppProductsCtrl(sc1);
        System.assert(!ctrl1.getIsConsignmentCustomer(), 'This should be false as the Account is not a consignment customer for Digital deal');

        List<Opportunity> physicalDeals = [Select ID FROM Opportunity WHERE RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL];
        System.assertEquals(3, physicalDeals.size());

        ApexPages.StandardController sc2 = new ApexPages.StandardController(physicalDeals[0]);
        CRM_EditAllOppProductsCtrl ctrl2 = new CRM_EditAllOppProductsCtrl(sc2);
        System.assert(ctrl2.getIsConsignmentCustomer(), 'This should be true as the Account is a consignment customer for Physical deal');
        Test.stopTest();
    }

    static testMethod void verifyGetFilterPicklistValues(){
        List<String> expectedOptions = new List<String>();
        expectedOptions.add('--None--');

        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple) {
            expectedOptions.add(f.getLabel());
        }

        Test.startTest();
        CRM_DataObjects.PicklistOption[] actualOptions = CRM_EditAllOppProductsCtrl.getFilterPicklistValues(
            'OpportunityLineItem',
            'Reason__c',
            '--None--'
        );
        
        System.assertEquals(expectedOptions.size(), actualOptions.size());
        Test.stopTest();
    }
    static testMethod void verifyLaMoulinetteForFranceTest(){
        createTestData();
        // Create 2 Physical deals
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 3, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        }
        insert lstDeals;

        System.assertEquals(4, [SELECT Id FROM Opportunity].size());

        Test.startTest();
        List<Opportunity> physicalDeals = [Select ID FROM Opportunity WHERE RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_PHYSICAL];
        System.assertEquals(3, physicalDeals.size());

        ApexPages.StandardController sc2 = new ApexPages.StandardController(physicalDeals[0]);
        CRM_EditAllOppProductsCtrl ctrl2 = new CRM_EditAllOppProductsCtrl(sc2);
        // System.assertEquals(ctrl2.showLaMouliNette, true, 'Show La Moulinette for France.');
        Test.stopTest();
    }
    /**
    *  Test 2: Add Bar Code/ Material Number
    *  @name addMaterialNumber
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void addMaterialNumberWithAlreadyPresentDealProduct(){
        createTestData();
        List<Product2> lstProduct = [Select Id, Name, ProductCode FROM Product2];
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        for(Integer i=0 ; i< lstProduct.size(); i++){
           lstProduct[i].Universal_Picture_Code__c = 'TestProduct '+i;
        }
        update lstProduct;
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            Opportunity deal = [Select ID,Pricebook2Id,Account.Price_Book__c,Account.Price_Book__r.Country__c FROM Opportunity][0];
            System.assertEquals(1,[Select ID FROM OpportunityLineItem WHERE opportunityID =:deal.ID ].size(), 'Initial Deal Products.');
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.materialNumber = 'TestProduct 0';
            searchFilter.pageCount = 1;
            try{
                CRM_EditAllOppProductsCtrl.addLineItems(deal.Id, searchFilter);
              
            }catch(exception e){
                System.assertEquals(Label.CRM_Product_already_found_label,e.getMessage());
            }
        }
    }
    /**
    *  Test 2: Add Bar Code/ Material Number
    *  @name addMaterialNumber
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void addMaterialNumberWithNoPresentDealProduct(){
        createTestData();
        List<Product2> lstProduct = [Select Id, Name, ProductCode FROM Product2];
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        for(Integer i=0 ; i< lstProduct.size(); i++){
           lstProduct[i].Universal_Picture_Code__c = 'TestProduct '+i;
        }
        update lstProduct;
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            Opportunity deal = [Select ID,Pricebook2Id,Account.Price_Book__c,Account.Price_Book__r.Country__c FROM Opportunity][0];
            System.assertEquals(1,[Select ID FROM OpportunityLineItem WHERE opportunityID =:deal.ID ].size(), 'Initial Deal Products.');
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.materialNumber = 'TestProduct 201';
            searchFilter.pageCount = 1;
            try{
                CRM_EditAllOppProductsCtrl.addLineItems(deal.Id, searchFilter);
              
            }catch(exception e){
                System.assertEquals(Label.CRM_No_Product_found_label,e.getMessage());
            }
        }
    }
    /**
    *  Test 2: Add Bar Code/ Material Number
    *  @name addMaterialNumber
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void addMaterialNumberForNewDealProduct(){
        createTestData();
        List<Product2> lstProduct = [Select Id, Name, ProductCode FROM Product2];
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        for(Integer i=0 ; i< lstProduct.size(); i++){
           lstProduct[i].Universal_Picture_Code__c = 'TestProduct '+i;
        }
        update lstProduct;
        List<OpportunityLineItem> lstDealProduct = [Select Id, OpportunityId from OpportunityLineItem];
        delete lstDealProduct;
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            Opportunity deal = [Select ID,Pricebook2Id,AccountId,Account.Price_Book__c,Account.Price_Book__r.Country__c FROM Opportunity][0];
            System.assertEquals(0,[Select ID FROM OpportunityLineItem WHERE opportunityID =:deal.ID ].size(), 'Initial Deal Products.');
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.materialNumber = 'TestProduct 0';
            searchFilter.pageCount = 1;
            CRM_EditAllOppProductsCtrl.addLineItems(deal.Id, searchFilter);

            System.assertEquals(1,[Select ID FROM OpportunityLineItem WHERE opportunityID =:deal.ID ].size(), 'Deal product created for entered Material Number.');
        }
    }
    
    static testMethod void updateDealTest(){
        createTestData();
        Double HighLevelForcast = 100;
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            Opportunity deal = [Select ID,Pricebook2Id,High_Level_Forecast__c FROM Opportunity][0]; 
            System.assertEquals(1,[Select ID FROM OpportunityLineItem WHERE opportunityID =:deal.ID ].size(), 'Initial Deal Products.');           
            try{
                CRM_EditAllOppProductsCtrl.updateDeal(deal.Id,HighLevelForcast);                
            }
            Catch(Exception e){
                 system.assertEquals(null,e.getMessage());   
            }
            
        }
    }
    static testMethod void updateCommittedDealTest(){
        Double HighLevelForcast = 500;
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 3, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.High_Level_Forecast__c = 100;
        }
        insert lstDeals;
        List<Product_Group__c> lstProductGroup2 = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup2, 200, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);   
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);
        for(OpportunityLineItem dealLineItem: lstDealProduct){
            dealLineItem.Initial_Quantity__c = 10;
            dealLineItem.Replen_Quantity__c = 10;
        }
        insert lstDealProduct;
        
        Test.startTest();
        
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());
        //User u1 = [Select Id from User where Profile.Name = 'System Administrator' and ByPassValidationRule__c = true and isActive = true Limit 1 ];
        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User u1 = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d) + 'abc@test.com',
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
        insert u1;
        System.runAs(u1) {
            lstDeals[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update lstDeals;
        }        
        
        User u2 = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u2) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            Opportunity deal = [Select ID, Pricebook2Id, High_Level_Forecast__c FROM Opportunity Where Id =: lstDeals[0].Id];
            deal.isChangedHLF__c = true;
            deal.High_Level_Forecast__c = HighLevelForcast;
            update deal;
            OpportunityLineItem oli = [Select ID, Initial_Quantity__c, Replen_Quantity__c FROM OpportunityLineItem WHERE opportunityID =: deal.ID Limit 1];
            //system.assertNotEquals(10,oli.Initial_Quantity__c,'IQ changed');
            
            try{
                oli.Initial_Quantity__c = 10;
                update oli;                              
            }
            Catch(Exception e){
                 system.assertEquals(null,e.getMessage());   
            }  
        }
        Test.stopTest();
    }
    //Japan Development #483 -- Starts Here --
    static testMethod void accountPlanTest(){
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 3, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.High_Level_Forecast__c = 100;
            opp.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE ;
        }
        insert lstDeals;
        
        List<Decay_Curve_Template__c> lstDecayCurveTemp = CRM_TestDataFactory.createDecayCurveTemplates(2, true);
        
        List<Product_Group__c> lstProductGroup2 = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup2, 200, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.Product_Market__c = CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);   
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);
        insert lstDealProduct;
        
        //Create Account Split Template
        Target_Split_Template__c accountSplitTemplate = new Target_Split_Template__c(Name = 'Test Account Split Template');
        insert accountSplitTemplate;
        
        //Create Account Split 
        Account_Split__c accountSplit1 = new Account_Split__c();
        accountSplit1.Target_Split_Template__c = accountSplitTemplate.Id;
        accountSplit1.Account__c = lstAccounts[0].Id;
        accountSplit1.Handling_Fee__c = 10;
        accountSplit1.Number_of_Rentals_per_Unit__c= 10;
        accountSplit1.Rental_Price__c = 10;
        accountSplit1.Revenue_Share__c = 10;
        accountSplit1.Share__c = 10;
        accountSplit1.Final_Purchase__c = 10;
        accountSplit1.Final_Purchase_Price__c= 10;
        accountSplit1.Decay_Curve__c = lstDecayCurveTemp[0].Id;
        insert accountSplit1;
        
         //Create Account Split 
        Account_Split__c accountSplit2 = new Account_Split__c();
        accountSplit2.Target_Split_Template__c = accountSplitTemplate.Id;
        accountSplit2.Account__c = lstAccounts[1].Id;
        accountSplit2.Handling_Fee__c = 20;
        accountSplit2.Number_of_Rentals_per_Unit__c= 20;
        accountSplit2.Rental_Price__c = 20;
        accountSplit2.Revenue_Share__c = 15;
        accountSplit2.Share__c = 15;
        accountSplit2.Final_Purchase__c = 15;
        accountSplit2.Final_Purchase_Price__c= 15;
        accountSplit2.Decay_Curve__c = lstDecayCurveTemp[0].Id;
        insert accountSplit2;
        
       //Create Country Plan
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct,true);
        lstCountryPlan[0].Target_Split_Template__c = accountSplitTemplate.Id;
        update lstCountryPlan;
                   
        System.debug('#lstCountryPlan ' +lstCountryPlan );
        
        //Assert to test Account Plan Creation 
        System.assertEquals(2, [Select Id From Account_Plan__c where Country_Plan__c =: lstCountryPlan[0].id].size(),'Account Plan created');
        
        Test.startTest();
        
        User u1 = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1 ];
        System.runAs(u1) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            
            Opportunity deal = [Select ID,Sales_Organisation__c FROM Opportunity][0]; 
            System.assertEquals(CRM_AppConstants.TERRITORY_JAPAN_CODE,[Select ID, Sales_Organisation__c FROM Opportunity WHERE Id =:deal.ID ].Sales_Organisation__c, 'Sales_Organisation__c chk');           
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
            CRM_DataObjects.ProductToEdit[] lstProd = CRM_EditAllOppProductsCtrl.getLineItems(deal.Id,null);
            
        } 
        
        Test.stopTest();
    } //Japan Development #483 -- Ends Here --
    
    //Japan Development #547 -- Starts Here --
    static testMethod void testInitialBackOrderQuantity(){
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 3, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.High_Level_Forecast__c = 100;
            opp.Market_Type__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE  ;
        }
        insert lstDeals;
        
        List<Decay_Curve_Template__c> lstDecayCurveTemp = CRM_TestDataFactory.createDecayCurveTemplates(2, true);
        
        List<Product_Group__c> lstProductGroup2 = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup2, 200, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.Product_Market__c = CRM_AppConstants.PRODUCT_SELL_THROUGH_MARKET_TYPE ;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);   
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);
        insert lstDealProduct;
        
        //Create Account Split Template
        Target_Split_Template__c accountSplitTemplate = new Target_Split_Template__c(Name = 'Test Account Split Template');
        insert accountSplitTemplate;
        
        //Create Account Split 
        Account_Split__c accountSplit1 = new Account_Split__c();
        accountSplit1.Target_Split_Template__c = accountSplitTemplate.Id;
        accountSplit1.Account__c = lstAccounts[0].Id;
        accountSplit1.Handling_Fee__c = 10;
        accountSplit1.Number_of_Rentals_per_Unit__c= 10;
        accountSplit1.Rental_Price__c = 10;
        accountSplit1.Revenue_Share__c = 10;
        accountSplit1.Share__c = 10;
        accountSplit1.Final_Purchase__c = 10;
        accountSplit1.Final_Purchase_Price__c= 10;
        accountSplit1.Decay_Curve__c = lstDecayCurveTemp[0].Id;
        insert accountSplit1;
        
         //Create Account Split 
        Account_Split__c accountSplit2 = new Account_Split__c();
        accountSplit2.Target_Split_Template__c = accountSplitTemplate.Id;
        accountSplit2.Account__c = lstAccounts[1].Id;
        accountSplit2.Handling_Fee__c = 20;
        accountSplit2.Number_of_Rentals_per_Unit__c= 20;
        accountSplit2.Rental_Price__c = 20;
        accountSplit2.Revenue_Share__c = 15;
        accountSplit2.Share__c = 15;
        accountSplit2.Final_Purchase__c = 15;
        accountSplit2.Final_Purchase_Price__c= 15;
        accountSplit2.Decay_Curve__c = lstDecayCurveTemp[0].Id;
        insert accountSplit2;
        
       //Create Country Plan
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct,true);
        lstCountryPlan[0].Target_Split_Template__c = accountSplitTemplate.Id;
        update lstCountryPlan;
                   
        System.debug('#lstCountryPlan ' +lstCountryPlan );
        
        //Assert to test Account Plan Creation 
        System.assertEquals(2, [Select Id From Account_Plan__c where Country_Plan__c =: lstCountryPlan[0].id].size(),'Account Plan created');
        //Japan Development #547 -- Starts Here -- 
        
        Test.startTest();
        
        User u1 = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1 ];
        System.runAs(u1) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            
            Opportunity deal = [Select ID,Sales_Organisation__c FROM Opportunity][0]; 
            System.assertEquals(CRM_AppConstants.TERRITORY_JAPAN_CODE,[Select ID, Sales_Organisation__c FROM Opportunity WHERE Id =:deal.ID ].Sales_Organisation__c, 'Sales_Organisation__c chk');           
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
            CRM_DataObjects.ProductToEdit[] lstProd = CRM_EditAllOppProductsCtrl.getLineItems(deal.Id,null);
            for(CRM_DataObjects.ProductToEdit prod : lstProd){
                prod.customerRetailPrice = 100.00;
                prod.discount = 10;
                prod.replenQuantity = 10;
                prod.initialbackorderquantity =10;
                prod.returnCost = 10;
                prod.startDate = System.now().format('MM/dd/yyyy');
            }
            CRM_EditAllOppProductsCtrl.saveLineItems(deal.Id, lstProd, true);
        } 
        
        Test.stopTest();
    } 
    
     //Japan Development #547 -- Starts Here --
    static testMethod void testValidationForInitialBackOrderQtyForSellThroughDeal(){
        List<Account> lstAccts = CRM_TestDataFactory.createAccounts(1, false); 
        for (Account acc : lstAccts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        }
        insert lstAccts;
        
        List<Opportunity> lstOppoDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccts, 1, false);
        for (Opportunity opp : lstOppoDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.High_Level_Forecast__c = 100;
            opp.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE  ;
        }
        insert lstOppoDeals;
        List<Product_Group__c> lstProductGroup2 = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup2, 200, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE ;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstOppoDeals, 1, false);
        Test.startTest();
        lstDealProduct[0].initial_back_order_quantity__c = 10;
        try{
            insert lstDealProduct;
        }catch(Exception e){
            System.assert(e != null);
            System.Assert(e.getMessage().contains('Please do not enter Initial Back Order Quantity for Deal having Market Type other than Sell through'));
        }
        Test.stopTest();
    }
    //Japan Development #547 -- Ends Here --
    
    //Japan Development #3926 -- Starts Here --
    static testMethod void testTargetQtyOnOppoProduct(){
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 3, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.High_Level_Forecast__c = 100;
            opp.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE ;
        }
        insert lstDeals;
        
        List<Decay_Curve_Template__c> lstDecayCurveTemp = CRM_TestDataFactory.createDecayCurveTemplates(2, true);
        
        List<Product_Group__c> lstProductGroup2 = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup2, 200, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.Product_Market__c = CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);   
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);
        insert lstDealProduct;
        
        //Create Account Split Template
        Target_Split_Template__c accountSplitTemplate = new Target_Split_Template__c(Name = 'Test Account Split Template');
        insert accountSplitTemplate;
        
        //Create Account Split 
        Account_Split__c accountSplit1 = new Account_Split__c();
        accountSplit1.Target_Split_Template__c = accountSplitTemplate.Id;
        accountSplit1.Account__c = lstAccounts[0].Id;
        accountSplit1.Handling_Fee__c = 10;
        accountSplit1.Number_of_Rentals_per_Unit__c= 10;
        accountSplit1.Rental_Price__c = 10;
        accountSplit1.Revenue_Share__c = 10;
        accountSplit1.Share__c = 10;
        accountSplit1.Final_Purchase__c = 10;
        accountSplit1.Final_Purchase_Price__c= 10;
        accountSplit1.Decay_Curve__c = lstDecayCurveTemp[0].Id;
        insert accountSplit1;
        
         //Create Account Split 
        Account_Split__c accountSplit2 = new Account_Split__c();
        accountSplit2.Target_Split_Template__c = accountSplitTemplate.Id;
        accountSplit2.Account__c = lstAccounts[1].Id;
        accountSplit2.Handling_Fee__c = 20;
        accountSplit2.Number_of_Rentals_per_Unit__c= 20;
        accountSplit2.Rental_Price__c = 20;
        accountSplit2.Revenue_Share__c = 15;
        accountSplit2.Share__c = 15;
        accountSplit2.Final_Purchase__c = 15;
        accountSplit2.Final_Purchase_Price__c= 15;
        accountSplit2.Decay_Curve__c = lstDecayCurveTemp[0].Id;
        insert accountSplit2;
        
       //Create Country Plan
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct,true);
        lstCountryPlan[0].Target_Split_Template__c = accountSplitTemplate.Id;
        update lstCountryPlan;
                   
        System.debug('#lstCountryPlan ' +lstCountryPlan );
        
        //Assert to test Account Plan Creation 
        System.assertEquals(2, [Select Id From Account_Plan__c where Country_Plan__c =: lstCountryPlan[0].id].size(),'Account Plan created');
        
        Test.startTest();
        
        User u1 = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1 ];
        System.runAs(u1) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditAllOppProducts'));
            
            Opportunity deal = [Select ID,Sales_Organisation__c FROM Opportunity][0]; 
            System.assertEquals(CRM_AppConstants.TERRITORY_JAPAN_CODE,[Select ID, Sales_Organisation__c FROM Opportunity WHERE Id =:deal.ID ].Sales_Organisation__c, 'Sales_Organisation__c chk');           
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
           CRM_DataObjects.ProductToEdit[] lstProd = CRM_EditAllOppProductsCtrl.getLineItems(deal.Id,null);
            for(CRM_DataObjects.ProductToEdit prod : lstProd){
                prod.customerRetailPrice = 100.00;
                prod.discount = 10;
                prod.handlingFee =10;
                prod.rentalPrice  =100;
                prod.revenueShare  =45;
                prod.numberOfRentals  =16;
                prod.finalPurchasePrice  =14;
                prod.finalPurchase  =10; 
                
            }
            CRM_EditAllOppProductsCtrl.saveLineItems(deal.Id, lstProd, true);
            
        } 
        
        Test.stopTest();
    } //Japan Development #3926 -- Ends Here --
    
    //US:936:US Games
    static testMethod void sellInForecasetTest() {
        Integer intCount = 0;
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false); 
        for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = intCount < 1 ? CRM_AppConstants.TERRITORY_US_CODE : CRM_AppConstants.TERRITORY_JAPAN_CODE;
            intCount++;
        }
        insert lstAccounts;
        
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 2, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.High_Level_Forecast__c = 100;
            opp.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE ;
        }
        insert lstDeals;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstDeals[0]);
        CRM_EditAllOppProductsCtrl ctrl = new CRM_EditAllOppProductsCtrl(sc);
        ctrl.getUserLocaleLowerCase();
        ctrl.getisAccessibleToUser();
        ctrl.getMaxProductLimit();
        Test.stopTest();
        System.assertEquals(ctrl.isUSCANMEXTerritory, true);
        System.assertEquals(ctrl.getIsNRDeal(), false);
    }
}