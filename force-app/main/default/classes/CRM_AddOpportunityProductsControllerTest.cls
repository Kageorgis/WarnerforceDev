/**
   @Author Cognizant
   @name CRM_AddOpportunityProductsControllerTest
   @CreateDate 14 Dec 2015
   @Description Test class for CRM_AddOpportunityProductsController
   @Version <1.0>
   @reference Requirement no 35
  */

@isTest
private class CRM_AddOpportunityProductsControllerTest {

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
        
        lstAccounts[0].RecordTypeID = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        upsert lstAccounts;
        
        List<Account> lstAcct = [select id from Account];
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@ No. of Accounts: ' + lstAcct.size());
        
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 2, true);
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 20, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        }
        insert lstProduct;
        
        Product2 newProduct = new Product2();
        newProduct = lstProduct[0];
        newProduct.Exclusive_Customer__c = lstAccounts[0].Id;
        newProduct.ID = null;
        newProduct.External_Id__c = string.valueOf(math.random())+ string.ValueOf(5);
        insert newProduct;
        
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
        List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 10, true);
        // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
    }
    /**
    *  Test 2: Test to remove existing deal product. 
    *  Expected: Existing deal products should be deleted
    *  @name removeDealProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void removeDealProduct(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        createTestData();
        System.runAs(u) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CRM_AddOpportunityProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_AddOpportunityProductsController ctrl = new CRM_AddOpportunityProductsController(sc);
            //String str = ctrl.sourceIp;
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.sortByField = 'Name';
            searchFilter.sortOrder = 'ASC';
            searchFilter.pageCount = 1;
            
            CRM_AddOpportunityProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
            CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOpportunityProductsController.getProducts(deal.Id, deal.Pricebook2Id, searchFilter);
            List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
            
            List<ID> deletedProductIDs = new List<ID>();
            
            for(CRM_DataObjects.ProductItem prod : productWrapper.products){
                CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
                productToSave.productId = prod.productId;
                productToSave.pricebookEntryId = prod.pricebookEntryId;
                productToSave.quantity = 0;
                productToSave.listPrice = prod.listPrice;
                lstProductToSave.add(productToSave);
                
                deletedProductIDs.add(prod.productId);
            }
            
            System.debug('deletedProductIDs: ' + deletedProductIDs);
            CRM_AddOpportunityProductsController.saveProducts(deal.Id, lstProductToSave);
            
            System.assertEquals([Select count() FROM OpportunityLineItem WHERE opportunityID =: deal.ID AND product2ID IN :deletedProductIDs ], 0, 'Deal product should be deleted');
            Test.stopTest();
        }
    }
    
   /**
    *  Test 3: Test to add new deal product. 
    *  Expected: new deal products should be added
    *  @name addDealProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void addDealProduct(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        createTestData();
        System.runAs(u) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CRM_AddOpportunityProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            List<OpportunityLineItem> dealProductList = [Select ID FROM OpportunityLineItem where OpportunityId !=:deal.Id];
            delete dealProductList;

            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_AddOpportunityProductsController ctrl = new CRM_AddOpportunityProductsController(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.sortByField = 'Name';
            searchFilter.sortOrder = 'ASC';
            searchFilter.pageCount = 1;
            
            CRM_AddOpportunityProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
            CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOpportunityProductsController.getProducts(deal.Id, deal.Pricebook2Id, searchFilter);
            List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
            
            for(CRM_DataObjects.ProductItem prod : productWrapper.products){
                CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
                productToSave.productId = prod.productId;
                productToSave.pricebookEntryId = prod.pricebookEntryId;
                productToSave.quantity = 1;
                productToSave.listPrice = prod.listPrice;
                lstProductToSave.add(productToSave);
            }
            
            CRM_AddOpportunityProductsController.saveProducts(deal.Id, lstProductToSave);
            System.assert(![Select ID FROM OpportunityLineItem WHERE opportunityID =: deal.ID].isEmpty(), 'Deal product should be added');
            //System.assertEquals(ctrl.isUKSalesOrgDeal, false);
            Test.stopTest();
        }
    }
   /**
    *  Test 1: Test to update existing deal product. 
    *  Expected: Existing deal products should be updated
    *  @name updateDealProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void updateDealProduct(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        createTestData();
        System.runAs(u) {
        Test.startTest();        
            Test.setCurrentPageReference(new PageReference('Page.CRM_AddOpportunityProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            List<OpportunityLineItem> lstDealProduct = [Select Id, Name from OpportunityLineItem where OpportunityId =: deal.Id];
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_AddOpportunityProductsController ctrl = new CRM_AddOpportunityProductsController(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.sortByField = 'Name';
            searchFilter.sortOrder = 'ASC';
            searchFilter.pageCount = 1;
                        
            CRM_AddOpportunityProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
            CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOpportunityProductsController.getProducts(deal.Id, deal.Pricebook2Id, searchFilter);
            List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
            List<OpportunityLineItemSchedule> lstDealProductsSchedule =[Select Id from OpportunityLineItemSchedule where OpportunityLineItemId IN: lstDealProduct];
            delete lstDealProductsSchedule;
            for(CRM_DataObjects.ProductItem prod : productWrapper.products){
                CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
                productToSave.productId = prod.productId;
                productToSave.pricebookEntryId = prod.pricebookEntryId;
                productToSave.quantity = prod.quantity == null ? 1: prod.quantity + 1;
                productToSave.listPrice = prod.listPrice;
                lstProductToSave.add(productToSave);
            }
            system.debug('lstProductToSave===>'+lstProductToSave);
            CRM_AddOpportunityProductsController.saveProducts(deal.Id, lstProductToSave);
            system.debug('List --> : '+[Select ID, Quantity FROM OpportunityLineItem WHERE opportunityID =: deal.ID]);            
            System.assert(![Select ID, Quantity FROM OpportunityLineItem WHERE opportunityID =: deal.ID and Quantity > 1].isEmpty(), 'Deal product Quantity should be Updated');
            Test.stopTest();
        }
    }
    
    /**
    *  Test 4: Positive Test to add new deal product For Promotional Assortment. 
    *  Expected: new deal products should be added with Appropriate Prices
    *  @name addDealProductForPromotionalAssortment
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void addDealProductForPromotionalAssortmentTest1(){
        //Accounts
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        
        lstAccounts[0].RecordTypeID = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        //Benelux: #462
        lstAccounts[0].Sales_Organization__c = '6501';
        upsert lstAccounts;
        
        //File Discounts for Accounts
        List<File_Discount__c> fdList = CRM_TestDataFactory.createFileDiscounts(lstAccounts,1,false);
        fdList[0].Start_Date__c = Date.today() - 3;
        fdList[0].Discount_Percent__c = 3;
        insert fdList;
        
        //Product Group Record
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        //Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 2, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.Product_Price_Group__c = 'New Release';
            prodInstance.Product_Format__c = 'DVD';
        }
        insert lstProduct;
        
        //PriceBook Record
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        //PriceBookEntryPeriod Record
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
        
        //Promotional Assortment 
        List<Bundle__c> assortmentList = CRM_TestDataFactory.createBundles(1,false);
        assortmentList[0].RecordTypeID = CRM_RecordTypeUtil.RT_Promotional_Assortment;
        insert assortmentList;
        
        //Promotional Assortment Products
        List<Bundle_Product__c> assortmentPro = CRM_TestDataFactory.createBundleProducts(assortmentList,lstProduct,1,false);
        for (Bundle_Product__c assPro : assortmentPro) {
            assPro.Assortment_Price__c = 50;
        }
        insert assortmentPro;
        
        //Promotional Assortment Account
        Assortment_Account__c assortAccount = CRM_TestDataFactory.createAssortmentAccount(assortmentList[0],lstAccounts[0]);
        insert assortAccount;
        
        //Deal with Promotional Assortment 
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);
        lstDeals[0].Bundle__c = assortmentList[0].Id;
        insert lstDeals;
        
        // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CRM_AddOpportunityProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_AddOpportunityProductsController ctrl = new CRM_AddOpportunityProductsController(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.sortByField = 'Name';
            searchFilter.sortOrder = 'ASC';
            searchFilter.pageCount = 1;
            
            CRM_AddOpportunityProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
            CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOpportunityProductsController.getProducts(deal.Id, deal.Pricebook2Id, searchFilter);
            List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
            for(CRM_DataObjects.ProductItem prod : productWrapper.products){
                CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
                productToSave.productId = prod.productId;
                productToSave.pricebookEntryId = prod.pricebookEntryId;
                productToSave.quantity = 1;
                productToSave.listPrice = prod.listPrice;
                lstProductToSave.add(productToSave);
            }
            
            CRM_AddOpportunityProductsController.saveProducts(deal.Id, lstProductToSave);
            
            List<OpportunityLineItem> oppLIList = [select Id,ListPrice__c,Account_Price__c,Promoted_Price__c  From OpportunityLineItem where OpportunityId =: deal.Id limit 2];
            for(OpportunityLineItem oppLI : oppLIList){
                
                //Assert Deal Product ListPrice equal To Assortment Product's Assortment Price
                system.assertEquals(oppLI.ListPrice__c, assortmentPro[0].Assortment_Price__c);
                
                //File Discount equal to 3%
                Decimal discountPrice = (assortmentPro[0].Assortment_Price__c - (assortmentPro[0].Assortment_Price__c * 3/100));
                
                //Assert Deal Product Account Price and Promoted Price equal 48.50(apply 3% discount to Assortment Price(50))
                system.assertEquals(oppLI.Account_Price__c,discountPrice);
                system.assertEquals(oppLI.Promoted_Price__c,discountPrice);
            }
            Test.stopTest();
        }
    }
    
     /**
    *  Test 5: Nagative Test to add new deal product For Promotional Assortment. 
    *  Expected: new deal products should be added with Appropriate Prices
    *  @name addDealProductForPromotionalAssortmentTest2
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void addDealProductForPromotionalAssortmentTest2(){
        //Accounts
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);   
        Id rtId = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        for(Account acc : lstAccounts){
            acc.RecordTypeID = rtId;
        }
        upsert lstAccounts;
        
        //File Discounts For Accounts
        List<File_Discount__c> fdList = CRM_TestDataFactory.createFileDiscounts(lstAccounts,1,false);
        for(File_Discount__c fd : fdList){
            fd.Start_Date__c = Date.today() - 3;
            fd.Discount_Percent__c = 3;
        }
        insert fdList;
        
        //Product Group Record
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        //Products 
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 2, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.Product_Price_Group__c = 'New Release';
            prodInstance.Product_Format__c = 'DVD';
        }
        insert lstProduct;
        
        //Pricebook Entry 
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        //PriceBookEntryPeriod 
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
        
        //Promotional Assortment 
        List<Bundle__c> assortmentList = CRM_TestDataFactory.createBundles(1,false);
        assortmentList[0].RecordTypeID = CRM_RecordTypeUtil.RT_Promotional_Assortment;
        insert assortmentList;
        
        //Promotional Assortment Products
        List<Bundle_Product__c> assortmentPro = CRM_TestDataFactory.createBundleProducts(assortmentList,lstProduct,1,false);
        for (Bundle_Product__c assPro : assortmentPro) {
            assPro.Assortment_Price__c = 50;
        }
        insert assortmentPro;
        
        //Promotional Assortment Account
        Assortment_Account__c assortAccount = CRM_TestDataFactory.createAssortmentAccount(assortmentList[0],lstAccounts[0]);
        insert assortAccount;
        
        List<Account> accList = new List<Account>{lstAccounts[1]};
        //Deal With Promotional Assortment
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(accList, 1, false);
        lstDeals[0].Bundle__c = assortmentList[0].Id;
        insert lstDeals;
        
        // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CRM_AddOpportunityProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_AddOpportunityProductsController ctrl = new CRM_AddOpportunityProductsController(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.sortByField = 'Name';
            searchFilter.sortOrder = 'ASC';
            searchFilter.pageCount = 1;
            
            CRM_AddOpportunityProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
            CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOpportunityProductsController.getProducts(deal.Id, deal.Pricebook2Id, searchFilter);
            List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
            
            for(CRM_DataObjects.ProductItem prod : productWrapper.products){
                CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
                productToSave.productId = prod.productId;
                productToSave.pricebookEntryId = prod.pricebookEntryId;
                productToSave.quantity = 1;
                productToSave.listPrice = prod.listPrice;
                lstProductToSave.add(productToSave);
            }
            
            CRM_AddOpportunityProductsController.saveProducts(deal.Id, lstProductToSave);
            
            List<OpportunityLineItem> oppLIList = [select Id,ListPrice__c,Account_Price__c,Promoted_Price__c  From OpportunityLineItem where OpportunityId =: deal.Id limit 2];
            for(OpportunityLineItem oppLI : oppLIList){
                
                //Assert Deal Product ListPrice equal To PriceBook Entry Period ListPrice
                system.assertEquals(oppLI.ListPrice__c, lstPriceBookEntryPeriod[0].List_Price__c);
                
                //File Discount equal to 3%
                Decimal discountPrice = (lstPriceBookEntryPeriod[0].List_Price__c - (lstPriceBookEntryPeriod[0].List_Price__c * 3/100));
                
                //Assert Deal Product Account Price and Promoted Price equal 19.40(apply 3% discount to PBEP ListPrice(20))
                system.assertEquals(oppLI.Account_Price__c,discountPrice);
                system.assertEquals(oppLI.Promoted_Price__c,discountPrice);
            }
            Test.stopTest();
        }
    }
    
    /**
    *  Test 6 JAPAN US 480 : Filter Physical Product base on Product Market of Product and Market Type of Deal
    *  @name test_FilterPhysicalProductForProductMarket
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    **/
    static testmethod void test_FilterPhysicalProductForProductMarket() {
         // Insert Account
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        insert lstAccounts;
        
        //Product Group Record
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        //Products 
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroup,10,false);
        //update 5 product records With Product Market = RENTAL
        for (Integer i=0; i < lstProducts.size()-5; i++) {
             lstProducts[i].Product_Market__c = '1'; // Product Market = RENTAL
             lstProducts[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
             lstProducts[i].Product_Price_Group__c = 'New Release';
             lstProducts[i].Product_Format__c = 'DVD';
        }
        for (Integer i=5; i < lstProducts.size(); i++) {
             lstProducts[i].Product_Market__c = '2'; // Product Market = SELL THROUGH
             lstProducts[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
             lstProducts[i].Product_Price_Group__c = 'New Release';
             lstProducts[i].Product_Format__c = 'DVD';
        }
        insert lstProducts;
        
        //Assert Products with Product MArket equal to "RENTAL"
        System.assertEquals(5,[Select Count() From Product2 Where Product_Market__c = '1']);
        //Assert Products with Product MArket equal to "SELL THROUGH"
        System.assertEquals(5,[Select Count() From Product2 Where Product_Market__c = '2']);
        
        //Pricebook Entry 
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        //PriceBookEntryPeriod 
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        //Create Deal
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        for (Integer i=0; i < lstDeals.size(); i++) {
             lstDeals[i].Market_Type__c = '2';
             lstDeals[i].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        }
        insert lstDeals;
        
        // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CRM_AddOpportunityProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_AddOpportunityProductsController ctrl = new CRM_AddOpportunityProductsController(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.sortByField = 'Name';
            searchFilter.sortOrder = 'ASC';
            searchFilter.pageCount = 1;
            
            CRM_AddOpportunityProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
            CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOpportunityProductsController.getProducts(deal.Id, deal.Pricebook2Id, searchFilter);
            system.debug('productWrapper:::'+productWrapper);
            List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
            
            for(CRM_DataObjects.ProductItem prod : productWrapper.products){
                CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
                productToSave.productId = prod.productId;
                productToSave.pricebookEntryId = prod.pricebookEntryId;
                productToSave.quantity = 1;
                lstProductToSave.add(productToSave);
            }
            
            CRM_AddOpportunityProductsController.saveProducts(deal.Id, lstProductToSave);
            
            //Assert Deal Product inserted was RENTAL type of Product Market 
            system.assertEquals(0,[select Count() From OpportunityLineItem where OpportunityId =: deal.Id AND Product2.Product_Market__c = '1']);
            
            //Assert SELL THROUGH type of Product Market Deal Product was not inserted
            system.assertEquals(5,[select count() From OpportunityLineItem where OpportunityId =: deal.Id AND Product2.Product_Market__c = '2']);
            
            Test.stopTest();
        }
    }
    
    public static List<Account> lstAccounts = new List<Account>();
    public static List<Product2> lstProducts = new  List<Product2>();
    public static List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = new  List<Pricebook_Entry_Period__c>();
    public static List<PricebookEntry> lstPriceBookEntries = new List<PricebookEntry> ();
    
    static  List<Product2> createGermanyAccProducts(){ 
        //Product Group Record
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        //Products 
        lstProducts = CRM_TestDataFactory.createProducts(lstProductGroup,2,false);
        //update 5 product records With Product Market = RENTAL
        for (Integer i=0; i < lstProducts.size(); i++) {
             lstProducts[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
             lstProducts[i].Product_Price_Group__c = 'New Release';
             lstProducts[i].Product_Format__c = 'DVD';
             lstProducts[i].Street_Date__c = Date.today();
             lstProducts[i].CurrencyISoCode = 'USD';
             lstProducts[i].SAP_Sales_Org__c =CRM_AppConstants.TERRITORY_GERMANY_CODE;
        } 
        upsert lstProducts;
        //Assert Products with Product MArket equal to "RENTAL"
        System.assertEquals(2,[Select Count() From Product2]);
        return lstProducts; 
    }
    static  List<PricebookEntry> createPbe(List<Product2> lstProduct ){
         lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
         upsert lstPriceBookEntries;
         return lstPriceBookEntries;
    }
    static  List<Pricebook_Entry_Period__c> createPbePBEP(List<Product2> lstProduct ){
        lstPriceBookEntries =createPbe(lstProduct);
         //Assert Products with Product MArket equal to "RENTAL"
        System.assertEquals(2,[Select Count() From PricebookEntry]);
        //PriceBookEntryPeriod 
        lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, false);
        lstPriceBookEntryPeriod[0].List_Price__c =1323;
        lstPriceBookEntryPeriod[0].Start_Date__c =  Date.today()-100;
        lstPriceBookEntryPeriod[0].End_Date__c =  Date.today()+100;
        lstPriceBookEntryPeriod[0].CurrencyISoCode = 'USD';
        lstPriceBookEntryPeriod[1].List_Price__c =2222;
        lstPriceBookEntryPeriod[1].Start_Date__c =  Date.today()-100;
        lstPriceBookEntryPeriod[1].End_Date__c = Date.today()+100;
        lstPriceBookEntryPeriod[1].CurrencyISoCode = 'USD';
        
        insert lstPriceBookEntryPeriod;
        System.assertEquals(2,[Select Count() From Pricebook_Entry_Period__c]);
        return lstPriceBookEntryPeriod;
        
    }
    static List<Account> createGermanyAcc(){
         // Insert Account
        lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        upsert lstAccounts;
        return lstAccounts;
    }
  
    
    static  void testDataForGermany(){ 
        lstAccounts = createGermanyAcc();
        //Products 
        lstProducts = createGermanyAccProducts();
        lstPriceBookEntryPeriod = createPbePBEP(lstProducts);
    }
    static CRM_DataObjects.ProductWrapper createAndSaveLineItems( List<Opportunity> lstDeals ){
         Test.setCurrentPageReference(new PageReference('Page.CRM_AddOpportunityProducts'));
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            system.debug('deal::::::::'+deal);
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_AddOpportunityProductsController ctrl = new CRM_AddOpportunityProductsController(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.sortByField = 'Name';
            searchFilter.sortOrder = 'ASC';
            searchFilter.pageCount = 1;
            
            CRM_AddOpportunityProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
            CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOpportunityProductsController.getProducts(deal.Id, deal.Pricebook2Id, searchFilter);
            system.debug('productWrapper:::'+productWrapper);
            List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
            
            for(CRM_DataObjects.ProductItem prod : productWrapper.products){
                CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
                productToSave.productId = prod.productId;
                productToSave.pricebookEntryId = prod.pricebookEntryId;
                productToSave.quantity = 1;
                lstProductToSave.add(productToSave);
            }
             
            CRM_AddOpportunityProductsController.saveProducts(deal.Id, lstProductToSave);
            
            //Assert Deal Product inserted was RENTAL type of Product Market 
            system.assertEquals(2,[select Count() From OpportunityLineItem where OpportunityId =: deal.Id ]);
            return productWrapper;
        
    }
     /**
    *  Test Germany US#253 : Filter Product base and display Last Promotion Price and 3 month order history
    *  @name test_FilterPhysicalProductForProductMarket
    *  @param None
    *  @return None
     **/
    static testmethod void test_MoreInfoForGermany_scenario1() { 
        
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        testDataForGermany();
         //Create Deal
        Date startDateDeal1 =Date.today()-50;
        Date endDateDeal1 = Date.today()+100;
        Date startDateDeal2 = Date.today()-50;
        Date endDateDeal2 = Date.today()+100;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,2,false);
        lstDeals[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[0].Start_Date__c = startDateDeal1;
        lstDeals[0].Customer_delivery_Date__c = startDateDeal1;
        lstDeals[0].CloseDate = endDateDeal1;
        lstDeals[1].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[1].Start_Date__c = startDateDeal2;
        lstDeals[1].CloseDate = endDateDeal2;
        lstDeals[1].Customer_delivery_Date__c = startDateDeal1;
         
        insert lstDeals;
        
        System.assertEquals(2,[Select Count() From Opportunity]); 
        
        Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.startTest();
            CRM_DataObjects.ProductWrapper productWrapper = createAndSaveLineItems(lstDeals);
            List<Id> prodIds = new List<Id>();
            prodIds.addall(productWrapper.setProductIds);
            CRM_DataObjects.ProductWrapper pwrap = CRM_AddOpportunityProductsController.displayDealProdMoreInformation(deal.Id,prodIds);
            //Scenario 1 where 
            system.assertEquals(1323, pwrap.products[0].lastPromotedPrice);
            system.assertEquals(2222, pwrap.products[1].lastPromotedPrice); 
            Test.stopTest();
        }
    }
     
     /**
    *  Test Germany US#253 : Filter Product base and display Last Promotion Price and 3 month order history
    *  @name test_FilterPhysicalProductForProductMarket
    *  @param None
    *  @return None
     **/
    static testmethod void test_MoreInfoForGermany_scenario2() { 
        testDataForGermany();
         //Create Deal
        Date startDateDeal1 =Date.today()-50;
        Date endDateDeal1 = Date.today()+100;
        Date startDateDeal2 = Date.today()-50;
        Date endDateDeal2 = Date.today()+100;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,2,false);
        lstDeals[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[0].Start_Date__c = startDateDeal1;
        lstDeals[0].Customer_delivery_Date__c = startDateDeal1;
        lstDeals[0].CloseDate = endDateDeal1;
        lstDeals[1].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[1].Start_Date__c = startDateDeal2;
        lstDeals[1].CloseDate = endDateDeal2;
        lstDeals[1].Customer_delivery_Date__c = startDateDeal1;
         
        insert lstDeals;
        
        System.assertEquals(2,[Select Count() From Opportunity]);
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.startTest();
            CRM_DataObjects.ProductWrapper productWrapper = createAndSaveLineItems(lstDeals);
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            Opportunity deal2 = [Select ID,Pricebook2Id FROM Opportunity][1];
            List<Opportunity> lstDeals2 =new List<Opportunity>();
            lstDeals2.add(deal2);
            
             List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals2, 2, true);
            lstDealProducts[0].Promoted_Price__c =8888;
            lstDealProducts[1].Promoted_Price__c =9999;
            update lstDealProducts;
            //Assert Deal Product inserted was RENTAL type of Product Market 
            system.assertEquals(2,[select Count() From OpportunityLineItem where OpportunityId =: deal2.Id ]); 
            List<Id> prodIds = new List<Id>();
            prodIds.addall(productWrapper.setProductIds);
            CRM_DataObjects.ProductWrapper pwrap = CRM_AddOpportunityProductsController.displayDealProdMoreInformation(deal.Id,prodIds);
            //Scenario 1 where 
            system.assertEquals(8888, pwrap.products[0].lastPromotedPrice);
            system.assertEquals(9999, pwrap.products[1].lastPromotedPrice); 
            Test.stopTest();
        }
    }
     /**
    *  Test Germany US#253 : Filter Product base and display Last Promotion Price and 3 month order history
    *  @name test_FilterPhysicalProductForProductMarket
    *  @param None
    *  @return None
     **/
    static testmethod void test_MoreInfoForGermany_scenario3() { 
        testDataForGermany();
         //Create Deal
        Date startDateDeal1 =Date.today()-50;
        Date endDateDeal1 = Date.today()+100;
        Date startDateDeal2 = Date.today()-50;
        Date endDateDeal2 = Date.today()+100;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,2,false);
        lstDeals[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[0].Start_Date__c = startDateDeal1;
        lstDeals[0].Customer_delivery_Date__c = startDateDeal1;
        lstDeals[0].CloseDate = endDateDeal1;
        lstDeals[0].Deal_priority__c ='Normal' ;
        lstDeals[1].Deal_priority__c = 'High';
        lstDeals[1].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[1].Start_Date__c = startDateDeal1;
        lstDeals[1].CloseDate = endDateDeal1;
        lstDeals[1].Customer_delivery_Date__c = startDateDeal1;
         
        insert lstDeals;
        
        System.assertEquals(2,[Select Count() From Opportunity]);
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.startTest();
            CRM_DataObjects.ProductWrapper productWrapper = createAndSaveLineItems(lstDeals);
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            Opportunity deal2 = [Select ID,Pricebook2Id FROM Opportunity][1];
            List<Opportunity> lstDeals2 =new List<Opportunity>();
            lstDeals2.add(deal2);
            //Assert Deal Product inserted was RENTAL type of Product Market 
            system.assertEquals(2,[select Count() From OpportunityLineItem where OpportunityId =: deal.Id ]); 
            List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals2, 2, true);
            lstDealProducts[0].Promoted_Price__c =9876;
            lstDealProducts[1].Promoted_Price__c =5656;
            update lstDealProducts;
            //Assert Deal Product inserted was RENTAL type of Product Market 
            system.assertEquals(2,[select Count() From OpportunityLineItem where OpportunityId =: deal2.Id ]); 
            List<Id> prodIds = new List<Id>();
            prodIds.addall(productWrapper.setProductIds);
            CRM_DataObjects.ProductWrapper pwrap = CRM_AddOpportunityProductsController.displayDealProdMoreInformation(deal.Id,prodIds);
            //Scenario 1 where 
            system.assertEquals(9876, pwrap.products[0].lastPromotedPrice);
            system.assertEquals(5656, pwrap.products[1].lastPromotedPrice); 
            Test.stopTest();
        }
    }
      /**
    *  Test Germany US#253 : Filter Product base and display Last Promotion Price and 3 month order history
    *  @name test_FilterPhysicalProductForProductMarket
    *  @param None
    *  @return None
     **/
    static testmethod void test_MoreInfoForGermany_scenario4() { 
       testDataForGermany();
         //Create Deal
        Date startDateDeal1 =Date.today()-50;
        Date endDateDeal1 = Date.today()+100;
        Date startDateDeal2 = Date.today()-50;
        Date endDateDeal2 = Date.today()+100;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,2,false);
        lstDeals[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[0].Start_Date__c = startDateDeal1;
        lstDeals[0].Customer_delivery_Date__c = startDateDeal1;
        lstDeals[0].CloseDate = endDateDeal1;
        lstDeals[0].Overlapping_Deal_Counter__c = 5;
        lstDeals[1].Overlapping_Deal_Counter__c = 6;
        lstDeals[0].Deal_priority__c ='High' ;
        lstDeals[1].Deal_priority__c = 'High';
        lstDeals[1].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[1].Start_Date__c = startDateDeal1;
        lstDeals[1].CloseDate = endDateDeal1;
        lstDeals[0].CloseDate = endDateDeal1;
        lstDeals[1].Customer_delivery_Date__c = startDateDeal1;
         
        insert lstDeals;
        
        System.assertEquals(2,[Select Count() From Opportunity]);
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.startTest();
             CRM_DataObjects.ProductWrapper productWrapper = createAndSaveLineItems(lstDeals);
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            Opportunity deal2 = [Select ID,Pricebook2Id FROM Opportunity][1];
            List<Opportunity> lstDeals2 =new List<Opportunity>();
            lstDeals2.add(deal2);
            //Assert Deal Product inserted was RENTAL type of Product Market 
            system.assertEquals(2,[select Count() From OpportunityLineItem where OpportunityId =: deal.Id ]); 
            List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals2, 2, true);
            lstDealProducts[0].Promoted_Price__c =9876;
            lstDealProducts[1].Promoted_Price__c =5656;
            update lstDealProducts;
            //Assert Deal Product inserted was RENTAL type of Product Market 
            system.assertEquals(2,[select Count() From OpportunityLineItem where OpportunityId =: deal2.Id ]); 
            List<Id> prodIds = new List<Id>();
            prodIds.addall(productWrapper.setProductIds);
            CRM_DataObjects.ProductWrapper pwrap = CRM_AddOpportunityProductsController.displayDealProdMoreInformation(deal.Id,prodIds);
            //Scenario 1 where 
            system.assertEquals(9876, pwrap.products[0].lastPromotedPrice);
            system.assertEquals(5656, pwrap.products[1].lastPromotedPrice); 
            Test.stopTest();
        }
    }
      /**
    *  Test Germany US#253 : Filter Product base and display Last Promotion Price and 3 month order history
    *  @name test_FilterPhysicalProductForProductMarket
    *  @param None
    *  @return None
     **/
    static testmethod void test_MoreInfoForGermany_scenario5() { 
        testDataForGermany();
        //Create Deal
        Date startDateDeal1 =Date.today()-50;
        Date endDateDeal1 = Date.today()+100;
        Date startDateDeal2 = Date.today()-50;
        Date endDateDeal2 = Date.today()+100;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,2,false);
        
        lstDeals[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[0].Start_Date__c = startDateDeal1;
        lstDeals[0].Customer_delivery_Date__c = startDateDeal1;
        lstDeals[0].CloseDate = endDateDeal1;
        lstDeals[0].Overlapping_Deal_Counter__c = 5;
        lstDeals[0].Deal_priority__c ='High' ;
        lstDeals[0].CloseDate = endDateDeal1;
        
        lstDeals[1].Overlapping_Deal_Counter__c = 6;
        lstDeals[1].Deal_priority__c = 'High';
        lstDeals[1].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL; 
        lstDeals[1].Start_Date__c = startDateDeal1;
        lstDeals[1].CloseDate = endDateDeal1;
        lstDeals[1].Customer_delivery_Date__c = startDateDeal1;
        
        insert lstDeals;
        System.assertEquals(2,[Select Count() From Opportunity]);
        
        // deal pos actuals
        List<Opportunity> lstDealsPos = CRM_TestDataTemplate.createDealsWithAccounts(lstAccounts, 
                                        CRM_AppConstants.OPPORTUNITY_STAGE_Actuals_Sales, date.today() -60, date.today() + 60,CRM_RecordTypeUtil.RT_DEAL_ACTUALS, 2, false);
        lstDealsPos[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_POS_Actuals;
        lstDealsPos[0].Promo_Start_Date__c = date.today() + 1;
        lstDealsPos[0].Promo_End_Date__c = date.today() + 61;
        insert lstDealsPos;
        // deal pos actuals
        List<Opportunity> lstDealsPos1 = CRM_TestDataTemplate.createDealsWithAccounts(lstAccounts, 
                                        CRM_AppConstants.OPPORTUNITY_STAGE_Actuals_Sales, date.today() -60, date.today() + 60,CRM_RecordTypeUtil.RT_DEAL_ACTUALS, 2, false);
        lstDealsPos1[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_POS_Actuals;
        lstDealsPos1[0].Promo_Start_Date__c = date.today() + 2;
        lstDealsPos1[0].Promo_End_Date__c = date.today() + 62;
        insert lstDealsPos1;
        List<OpportunityLineItem> lstDealProductsPos =  CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries, lstDealsPos, 10, 1, true);
        List<OpportunityLineItem> lstDealProductsPos1 =  CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries, lstDealsPos1, 10, 1, true);
        
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.startTest();
              CRM_DataObjects.ProductWrapper productWrapper = createAndSaveLineItems(lstDeals);
            Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
            Opportunity deal2 = [Select ID,Pricebook2Id FROM Opportunity][1];
            List<Opportunity> lstDeals2 =new List<Opportunity>();
            lstDeals2.add(deal2);
            //Assert Deal Product inserted was RENTAL type of Product Market 
            system.assertEquals(2,[select Count() From OpportunityLineItem where OpportunityId =: deal.Id ]); 
            List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals2, 2, true);
            lstDealProducts[0].Promoted_Price__c =9876;
            lstDealProducts[1].Promoted_Price__c =5656;
            update lstDealProducts;
            //Assert Deal Product inserted was RENTAL type of Product Market 
            List<Id> prodIds = new List<Id>();
            prodIds.addall(productWrapper.setProductIds);
            CRM_DataObjects.ProductWrapper pwrap = CRM_AddOpportunityProductsController.displayDealProdMoreInformation(deal.Id,prodIds);
            //Scenario 1 where 
            system.assertEquals(20, pwrap.products[0].threeMonthOrderHistory); 
            
            Test.stopTest();
        }
    }
}