/**
   @Author Cognizant
   @name CRM_AddOrderProductsController_Test
   @CreateDate 14 Dec 2015
   @Description Test class for CRM_AddOrderProductsController
   @Version <1.0>
   @reference Requirement no 35
  */

@isTest 
private class CRM_AddOrderProductsController_Test {
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get #@testSetup
    */
    
     static void createTestData() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO; 
        upsert lstAccounts;
    /*Date For CRM_AddProductsHelper Class*/
        List<String> regionLst = new List<String>();
        regionLst.add('Africa');
        List<Country__c> lstCntry = CRM_TestDataFactory.createCountries(regionLst ,1,true);
        List<Language__c> lstLang =  CRM_TestDataFactory.createLanguages(1, true);
        List<Local_Title__c> lstLocalTitle =CRM_TestDataFactory.createLocalTitles(lstCntry ,lstLang ,1, true);       
    /*Date For CRM_AddProductsHelper Class*/
        List<Order> lstOrders = CRM_TestDataFactory.createOrders(lstAccounts, 1, false);
        lstOrders[0].AccountId = lstAccounts[0].id; 
        insert lstOrders;
        system.assertNotEquals(null, lstOrders[0].id);
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        system.assertNotEquals(null, lstProductGroup[0].id);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 5, false); 
        System.assertEquals(5, lstProduct.size());
        for (Product2 prod : lstProduct) {
            prod.ProductCode = '1000230554';
            prod.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prod.Product_Format__c = '4';
            prod.Product_Rating__c = 'UK - Minimum 12 Ye';
            prod.Product_Genre__c = 'ACTION';
            prod.Release_Category__c = '23';
            prod.Franchise_Type__c = 'X4';
            prod.Product_Language_Code__c = 'SR';
            prod.SAP_Dist_chain_product_Status__c = '11';
            prod.Plant_Specific_Material_Status__c='01';
            prod.Type__c = 'Video Physical';
            prod.Recommended_Price__c = 150;
            prod.Street_Date__c=system.today();
            prod.IsActive =true;
            
         }
        lstProduct[0].Exclusive_Customer__c = lstAccounts[0].Id;
        lstProduct[0].Local_Title__c = lstLocalTitle[0].id; 
        lstProduct[0].Type__c = 'Video Physical'; 
        lstProduct[0].Franchise_Type__c = 'TV';
        lstProduct[0].Delivery_Lead_Days__c = 1;
        insert lstProduct;
        System.assertNotEquals(null,lstProduct[0].id);
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        system.assertNotEquals(null, lstPriceBookEntries[0].id);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true); 
        system.assertNotEquals(null, lstPriceBookEntryPeriod[0].id);
        List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntries, lstOrders, 5, true);
        system.assertNotEquals(null, lstOrderProduct[0].id);
        // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
    }
    static void createTestDataForRevShare() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        //lstAccounts[0].RecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Revenue_Share__c = true;
        lstAccounts[0].Sales_Organization__c ='8003';
        upsert lstAccounts;
    /*Date For CRM_AddProductsHelper Class*/
        List<String> regionLst = new List<String>();
        regionLst.add('Africa');
        List<Country__c> lstCntry = CRM_TestDataFactory.createCountries(regionLst ,1,true);
        List<Language__c> lstLang =  CRM_TestDataFactory.createLanguages(1, true);
        List<Local_Title__c> lstLocalTitle =CRM_TestDataFactory.createLocalTitles(lstCntry ,lstLang ,1, true);       
    /*Date For CRM_AddProductsHelper Class*/
        List<Order> lstOrders = CRM_TestDataFactory.createOrders(lstAccounts, 1, false);
        lstOrders[0].AccountId = lstAccounts[0].id;
        //lstOrders[1].AccountId = lstAccounts[1].id;
        lstOrders[0].RecordTypeId=CRM_RecordTypeUtil.RT_ORDER_REV_SHARE;
        system.debug('lstOrders::::::::::'+lstOrders);
        insert lstOrders;
        system.assertNotEquals(null, lstOrders[0].id);
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        system.assertNotEquals(null, lstProductGroup[0].id);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 5, false); 
        System.assertEquals(5, lstProduct.size());
        for (Product2 prod : lstProduct) {
            prod.ProductCode = '1000230554';
            prod.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prod.Product_Format__c = '4';
            prod.Product_Rating__c = 'UK - Minimum 12 Ye';
            prod.Product_Genre__c = 'ACTION';
            prod.Product_Market__c='1';
            prod.Release_Category__c = '23';
            prod.Franchise_Type__c = 'X4';
            prod.Product_Language_Code__c = 'SR';
            prod.SAP_Dist_chain_product_Status__c = '11';
            prod.Plant_Specific_Material_Status__c='01';
            prod.Type__c = 'Video Physical';
            prod.Recommended_Price__c = 150;
            prod.Street_Date__c=system.today();
            prod.IsActive =true;
            
         }
        lstProduct[0].Exclusive_Customer__c = lstAccounts[0].Id;
        lstProduct[0].Local_Title__c = lstLocalTitle[0].id; 
        lstProduct[0].Type__c = 'Video Physical'; 
        lstProduct[0].Franchise_Type__c = 'TV';
        lstProduct[0].Delivery_Lead_Days__c = 1;
        insert lstProduct;
        System.assertNotEquals(null,lstProduct[0].id);
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        system.assertNotEquals(null, lstPriceBookEntries[0].id);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true); 
        system.assertNotEquals(null, lstPriceBookEntryPeriod[0].id);
        List<OrderItem> lstOrderProduct = new List<OrderItem>(); //CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntries, lstOrders, 5, true);
        for (Integer nOrderProdCount = 0; nOrderProdCount < lstProduct.size() ; nOrderProdCount ++){
            OrderItem objOrderProduct = new OrderItem();
            objOrderProduct.OrderId = lstOrders[0].Id;
            objOrderProduct.PricebookEntryId = lstPriceBookEntries[nOrderProdCount].Id;
            objOrderProduct.Quantity = 1;
            objOrderProduct.UnitPrice = 14.10;                
            lstOrderProduct.add(objOrderProduct);
        }
        insert lstOrderProduct;
        system.assertNotEquals(null, lstOrderProduct[0].id);
        system.Debug('lstOrderProduct :: '+lstOrderProduct.size());
        // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
    }
    
   /**
    *  Test 1: Test to update existing order product. 
    *  Expected: Existing deal products should be updated
    *  @name updateOrderProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    
    static testMethod void updateOrderProduct(){
        createTestData();
        Test.setCurrentPageReference(new PageReference('Page.CRM_AddOrderProducts'));
        Order order1 = [Select ID,Pricebook2Id,CurrencyIsoCode FROM Order][0];
        
                
        ApexPages.StandardController sc = new ApexPages.StandardController(order1);
        CRM_AddOrderProductsController ctrl = new CRM_AddOrderProductsController(sc);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.sortByField = 'Name';
        searchFilter.sortOrder = 'ASC';
        searchFilter.pageCount = 1;
     /*Filter Criteria to cover CRM_AddProductsHelper Coverage*/
        searchFilter.title= 'PR';
        //searchFilter.text = 'Prod';
        searchFilter.isMarketingMaterial = true;
        searchFilter.recommendedPriceFrom = 100;
        searchFilter.recommendedPriceTo = 500;
        //searchFilter.bundleProductsOnly = true;
        searchFilter.materialNumber = '1000230554';
        searchFilter.productFormats = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Format__c', '4');
        searchFilter.productRatings = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Rating__c', 'UK - Minimum 12 Ye');
        searchFilter.productGenres = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Genre__c', 'ACTION');
        searchFilter.releaseCategories = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Release_Category__c', '23');
        searchFilter.franchiseTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Franchise_Type__c', 'X4');
        searchFilter.prodLanguages =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Language_Code__c', 'SR');
        searchFilter.distChainProdStatus =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'SAP_Dist_chain_product_Status__c', '11'); 
        searchFilter.productTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', 'Video Physical');
     /*Filter Criteria to cover CRM_AddProductsHelper Coverage*/
                
        CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
        
        CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOrderProductsController.getProducts(order1.Id, order1.Pricebook2Id, searchFilter);
        System.assert(productWrapper.products != null, 'Product fetched successfully');
        
        List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
        for(CRM_DataObjects.ProductItem prod : productWrapper.products){
            CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
            system.debug('prod ::: '+prod);
            productToSave.productId = prod.productId;
            productToSave.pricebookEntryId = prod.pricebookEntryId;
            productToSave.quantity = prod.quantity +1;
            productToSave.listPrice = prod.listPrice;
            lstProductToSave.add(productToSave);
        }
        CRM_AddOrderProductsController.saveProducts(order1.Id, lstProductToSave);
    }
    
   /**
    *  Test 2: Test to remove existing order product. 
    *  Expected: Existing deal products should be deleted
    *  @name removeOrderProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void removeOrderProduct(){
        createTestData();
        Test.setCurrentPageReference(new PageReference('Page.CRM_AddOrderProducts'));
        Order order1 = [Select ID, Pricebook2Id, CurrencyIsoCode, EffectiveDate, EndDate FROM Order][0];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(order1);
        CRM_AddOrderProductsController ctrl = new CRM_AddOrderProductsController(sc);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.sortByField = 'Name';
        searchFilter.sortOrder = 'ASC';
        searchFilter.pageCount = 1;
        
        searchFilter.title= 'PR';
        //searchFilter.text = 'Prod';
        searchFilter.isMarketingMaterial = true;
        searchFilter.recommendedPriceFrom = 100;
        searchFilter.recommendedPriceTo = 500;
        //searchFilter.bundleProductsOnly = true;
        searchFilter.materialNumber = '1000230554';
        searchFilter.productFormats = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Format__c', '4');
        searchFilter.productRatings = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Rating__c', 'UK - Minimum 12 Ye');
        searchFilter.productGenres = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Genre__c', 'ACTION');
        searchFilter.releaseCategories = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Release_Category__c', '23');
        searchFilter.franchiseTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Franchise_Type__c', 'X4');
        searchFilter.prodLanguages =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Language_Code__c', 'SR');
        searchFilter.distChainProdStatus =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'SAP_Dist_chain_product_Status__c', '11'); 
        searchFilter.productTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', 'Video Physical');
     /*Filter Criteria to cover CRM_AddProductsHelper Coverage*/
       
        
        CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
        
        CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOrderProductsController.getProducts(order1.Id, order1.Pricebook2Id, searchFilter);
        System.assert(productWrapper.products != null, 'Product fetched successfully');
        
        List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
        for(CRM_DataObjects.ProductItem prod : productWrapper.products){
            CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
            productToSave.productId = prod.productId;
            productToSave.pricebookEntryId = prod.pricebookEntryId;
            productToSave.quantity = 0;
            lstProductToSave.add(productToSave);
        }
        CRM_AddOrderProductsController.saveProducts(order1.Id, lstProductToSave);
    }
    
   /**
    *  Test 3: Test to add new order product. 
    *  Expected: new deal products should be added
    *  @name addOrderProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void addOrderProduct(){
        createTestData();
        Test.setCurrentPageReference(new PageReference('Page.CRM_AddOrderProducts'));
        Order order1 = [Select ID, Pricebook2Id, CurrencyIsoCode, EffectiveDate, EndDate FROM Order][0];
        OrderItem orderItem = [Select ID FROM OrderItem where OrderId=:order1.Id][0];
        delete orderItem;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(order1);
        CRM_AddOrderProductsController ctrl = new CRM_AddOrderProductsController(sc);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.sortByField = 'Name';
        searchFilter.sortOrder = 'ASC';
        searchFilter.pageCount = 1;
        searchFilter.title= 'PR';
        //searchFilter.text = 'Prod';
        searchFilter.isMarketingMaterial = true;
        searchFilter.recommendedPriceFrom = 100;
        searchFilter.recommendedPriceTo = 500;
        //searchFilter.bundleProductsOnly = true;
        searchFilter.materialNumber = '1000230554';
        searchFilter.productFormats = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Format__c', '4');
        searchFilter.productRatings = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Rating__c', 'UK - Minimum 12 Ye');
        searchFilter.productGenres = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Genre__c', 'ACTION');
        searchFilter.releaseCategories = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Release_Category__c', '23');
        searchFilter.franchiseTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Franchise_Type__c', 'X4');
        searchFilter.prodLanguages =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Language_Code__c', 'SR');
        searchFilter.distChainProdStatus =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'SAP_Dist_chain_product_Status__c', '11'); 
        searchFilter.productTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', 'Video Physical');
        
        CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
        
        CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOrderProductsController.getProducts(order1.Id, order1.Pricebook2Id, searchFilter);
        System.assert(productWrapper.products != null, 'Product fetched successfully');
        system.debug('product count -->'+productWrapper.products);
        List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
        for(CRM_DataObjects.ProductItem prod : productWrapper.products){
            CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
            productToSave.productId = prod.productId;
            productToSave.pricebookEntryId = prod.pricebookEntryId;
            productToSave.quantity = 1;
            productToSave.listPrice = prod.listPrice;
            lstProductToSave.add(productToSave);
        }
        CRM_AddOrderProductsController.saveProducts(order1.Id, lstProductToSave);
        //System.assertEquals(ctrl.isUKSalesOrgOrder,false);
        System.assertNotEquals(ctrl.sourceIp ,null);
    }
    
    static testMethod void SaveOrderProduct1(){
        createTestData();
        Test.setCurrentPageReference(new PageReference('Page.CRM_AddOrderProducts'));
        Order order1 = [Select ID, Pricebook2Id, CurrencyIsoCode, EffectiveDate, EndDate FROM Order][0];
        order1.RecordTypeId= CRM_RecordTypeUtil.RT_ORDER_RETURN;
        update order1;
        system.debug('PriceBook Value for Order =-->'+order1.Pricebook2Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(order1);
        CRM_AddOrderProductsController ctrl = new CRM_AddOrderProductsController(sc);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.sortByField = 'Name';
        searchFilter.sortOrder = 'ASC';
        searchFilter.pageCount = 1;
        
        CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
        
        CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOrderProductsController.getProducts(order1.Id, order1.Pricebook2Id, searchFilter);
        
        system.debug('Product count -->'+productWrapper.products);
        List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
        for(CRM_DataObjects.ProductItem prod : productWrapper.products){
            CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
            productToSave.productId = prod.productId;
            productToSave.pricebookEntryId = prod.pricebookEntryId;
            productToSave.quantity = 1;
            productToSave.listPrice = prod.listPrice;
            lstProductToSave.add(productToSave);
        }
        CRM_AddOrderProductsController.saveProducts(order1.Id, lstProductToSave);
        
        System.assertNotEquals(ctrl.sourceIp ,null);
    }
    
    /**
    *  Test 1: Test to update existing order product. 
    *  Expected: Existing deal products should be updated
    *  @name updateOrderProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    
    static testMethod void updateOrderProductForRevShare(){
        createTestDataForRevShare();
        Test.setCurrentPageReference(new PageReference('Page.CRM_AddOrderProducts'));
        Order order1 = [Select ID,Pricebook2Id,CurrencyIsoCode FROM Order Where RecordTypeId=:CRM_RecordTypeUtil.RT_ORDER_REV_SHARE Limit 1];
        
                
        ApexPages.StandardController sc = new ApexPages.StandardController(order1);
        CRM_AddOrderProductsController ctrl = new CRM_AddOrderProductsController(sc);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.sortByField = 'Name';
        searchFilter.sortOrder = 'ASC';
        searchFilter.pageCount = 1;
     /*Filter Criteria to cover CRM_AddProductsHelper Coverage*/
        searchFilter.title= 'PR';
        //searchFilter.text = 'Prod';
        searchFilter.isMarketingMaterial = true;
        searchFilter.recommendedPriceFrom = 100;
        searchFilter.recommendedPriceTo = 500;
        //searchFilter.bundleProductsOnly = true;
        searchFilter.materialNumber = '1000230554';
        searchFilter.productFormats = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Format__c', '4');
        searchFilter.productRatings = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Rating__c', 'UK - Minimum 12 Ye');
        searchFilter.productGenres = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Genre__c', 'ACTION');
        searchFilter.releaseCategories = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Release_Category__c', '23');
        searchFilter.franchiseTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Franchise_Type__c', 'X4');
        searchFilter.prodLanguages =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Language_Code__c', 'SR');
        searchFilter.distChainProdStatus =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'SAP_Dist_chain_product_Status__c', '11'); 
        searchFilter.productTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', 'Video Physical');
     /*Filter Criteria to cover CRM_AddProductsHelper Coverage*/
                
        CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
        
        CRM_DataObjects.ProductWrapper productWrapper = CRM_AddOrderProductsController.getProducts(order1.Id, order1.Pricebook2Id, searchFilter);
        System.assert(productWrapper.products != null, 'Product fetched successfully');
        
        List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
        system.debug('productWrapper.products ::: '+productWrapper.products);
        system.debug('productWrapper.products ::: '+productWrapper.products.size());
        for(CRM_DataObjects.ProductItem prod : productWrapper.products){
            CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
            system.debug('prod ::: '+prod);
            productToSave.productId = prod.productId;
            productToSave.pricebookEntryId = prod.pricebookEntryId;
            productToSave.quantity = prod.quantity +1;
            productToSave.listPrice = prod.listPrice;
            lstProductToSave.add(productToSave);
        }
        CRM_AddOrderProductsController.saveProducts(order1.Id, lstProductToSave);
        
        ctrl.getUserLocale();
        ctrl.getUserLocaleLanguage();
        ctrl.getUserDateFormat();
    } 
}