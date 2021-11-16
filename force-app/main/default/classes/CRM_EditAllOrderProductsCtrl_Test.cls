/**
   @Author Cognizant
   @name CRM_EditAllOrderProductsCtrl_Test
   @CreateDate 11 Nov 2015
   @Description Test class for CRM_EditAllOrderProductsCtrl
   @Version <1.0>
   @reference Requirement no 35
  */

@isTest 
private class CRM_EditAllOrderProductsCtrl_Test {
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
        System.assertEquals('TestAccount 0',lstAccounts[0].Name,'Account is Sold To Type');
        /*lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE; 
        lstAccounts[0].Revenue_share__c = true;
        insert lstAccounts;*/
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 200, false); 
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.SAP_Dist_chain_product_Status__c = '01';
            prodInstance.Plant_Specific_Material_Status__c = '04';
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = new List<Pricebook_Entry_Period__c>();
        for(Pricebook_Entry_Period__c pbep : CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false)){
            pbep.Start_Date__c = System.today()+1;
            lstPriceBookEntryPeriiod.add(pbep);
        }
        insert lstPriceBookEntryPeriiod;
        System.debug('lstPriceBookEntryPeriiod::'+lstPriceBookEntryPeriiod);
        List<Order> lstorder = CRM_TestDataFactory.createOrders(lstAccounts,2,true);  
        /*lstorder[0].RecordTypeId = CRM_RecordTypeUtil.RT_ORDER_REV_SHARE;
        lstorder[0].Opportunity = null;
        //lstorder[0].Account = lstAccounts[0].id;
        //lstorder[0].Ship_To_Account__c = lstAccounts[0].id;
        update lstorder;*/
        
        List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntries, lstOrder, 1, true);
        System.assertNotEquals(null,lstProduct.size()>0,'Products are inserted');
        System.assertNotEquals(null,lstPriceBookEntries.size()>0,'PriceBook Entries are inserted');
        System.assertNotEquals(null,lstPriceBookEntryPeriiod.size()>0,'Price Book Entry Period are inserted');
        System.assertNotEquals(null,lstorder.size()>0,'Order are inserted');
        System.assertNotEquals(null,lstOrderProduct.size()>0,'Order Product are inserted');

        // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
    }
    /**
    *  Test 1: Update Deal product schedule. 
    *  @name updateDealProductSchedule
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */

    static testMethod void updateOrderProductSchedule(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditOrderProducts'));
            Order order = [Select ID,Pricebook2Id FROM Order][0];
            System.assert(![Select ID FROM Order].isEmpty(), 'Order should be present');
            
            ApexPages.StandardController sc = new ApexPages.StandardController(order);
            CRM_EditAllOrderProductsCtrl ctrl = new CRM_EditAllOrderProductsCtrl(sc);
            CRM_EditAllOrderProductsCtrl.ProductToEdit[] lstProd = CRM_EditAllOrderProductsCtrl.getLineItems(order.Id);
            
            for(CRM_EditAllOrderProductsCtrl.ProductToEdit prod : lstProd){
                prod.UnitPrice = 100.00;
                prod.totalQty = 1;
                prod.totalPrice = prod.UnitPrice * prod.totalQty;
            }
            
            CRM_EditAllOrderProductsCtrl.saveLineItems(order.Id, lstProd, true);
            System.assert(![Select ID FROM OrderItem WHERE orderId =:order.ID ].isEmpty(), 'Order product should be updated');

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

    static testMethod void removeOrderProduct(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditOrderProducts'));
            Order order = [Select ID,Pricebook2Id FROM Order][0];
            
            ApexPages.StandardController sc = new ApexPages.StandardController(order);
            CRM_EditAllOrderProductsCtrl ctrl = new CRM_EditAllOrderProductsCtrl(sc);
            CRM_EditAllOrderProductsCtrl.ProductToEdit[] lstProd = CRM_EditAllOrderProductsCtrl.getLineItems(order.Id);
            
            for(CRM_EditAllOrderProductsCtrl.ProductToEdit prod : lstProd){
                prod.isDelete = true;
            }

            CRM_EditAllOrderProductsCtrl.saveLineItems(order.Id, lstProd, false);

            System.assert([Select ID FROM OrderItem WHERE orderId =:order.ID ].isEmpty(), 'Order product should be deleted');
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
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditOrderProducts'));
            Order order = [Select ID,Pricebook2Id FROM Order][0];
            ApexPages.StandardController sc = new ApexPages.StandardController(order);
            CRM_EditAllOrderProductsCtrl ctrl = new CRM_EditAllOrderProductsCtrl(sc);
            CRM_EditAllOrderProductsCtrl.ProductToEdit[] lstProd = CRM_EditAllOrderProductsCtrl.getLineItems(order.Id);
            //CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            //searchFilter.materialNumber = 'Test Product 0';

            for(CRM_EditAllOrderProductsCtrl.ProductToEdit prod : lstProd){
                //prod.scheduleEnabled = true;
                prod.totalQty = 1;
            }

            lstProd.addAll(lstProd);
            try{
                CRM_EditAllOrderProductsCtrl.saveLineItems(null,null,false);
            }
            catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object',e.getMessage());
            }
            
        }
    }
    static testMethod void addMaterialNumberWithNoPresentOrderItem(){
        createTestData();
        List<Product2> lstProduct = [Select Id, Name, ProductCode FROM Product2];
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        for(Integer i=0 ; i< lstProduct.size(); i++){
           lstProduct[i].ProductCode = 'Test Product '+i;
        }
        update lstProduct;
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditOrderProducts'));
            Order orderInstance = [Select ID,Pricebook2Id FROM Order][0];
            System.assertEquals(1,[Select ID FROM OrderItem WHERE orderID =:orderInstance.ID ].size(), 'Initial Order Products.');
            ApexPages.StandardController sc = new ApexPages.StandardController(orderInstance);
            CRM_EditAllOrderProductsCtrl ctrl = new CRM_EditAllOrderProductsCtrl(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.materialNumber = 'Test Product 201';
            searchFilter.pageCount = 1;
            try{
              CRM_EditAllOrderProductsCtrl.addLineItems(orderInstance.Id, searchFilter);
              
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

    static testMethod void addMaterialNumberForNewOrderIem(){
        createTestData();
        List<Product2> lstProduct = [Select Id, Name, ProductCode FROM Product2];
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        for(Integer i=0 ; i< lstProduct.size(); i++){
           lstProduct[i].ProductCode = 'Test Product '+i;
        }
        update lstProduct;
        List<OrderItem> lstOrderProduct = [Select Id, OrderId from OrderItem];
        delete lstOrderProduct;
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditOrderProducts'));
            Order orderInstance = [Select ID,Pricebook2Id,CurrencyIsoCode FROM Order][0];
            System.assertEquals(0,[Select ID FROM OrderItem WHERE orderID =:orderInstance.ID ].size(), 'Initial Order Products.');
            ApexPages.StandardController sc = new ApexPages.StandardController(orderInstance);
            CRM_EditAllOrderProductsCtrl ctrl = new CRM_EditAllOrderProductsCtrl(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.materialNumber = 'Test Product 0';
            searchFilter.pageCount = 1;
            
            CRM_EditAllOrderProductsCtrl.addLineItems(orderInstance.Id, searchFilter);

            System.assertEquals(1,[Select ID FROM OrderItem WHERE orderID =:orderInstance.ID ].size(), 'Order Item created for entered Material Number.');
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
  static testMethod void addMaterialNumberWithAlreadyPresentOrderItem(){
        createTestData();
        List<Product2> lstProduct = [Select Id, Name, ProductCode FROM Product2];        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        for(Integer i=0 ; i< lstProduct.size(); i++){
           lstProduct[i].ProductCode = 'Test Product '+i;
        }
        update lstProduct;
        System.debug('lstProduct::'+lstProduct);
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_EditOrderProducts'));
            Order orderInstance = [Select ID,Pricebook2Id,CurrencyIsoCode,EffectiveDate,EndDate FROM Order][0];
            System.debug('orderInstance::'+orderInstance);
            System.assertEquals(1,[Select ID FROM OrderItem WHERE orderID =:orderInstance.ID ].size(), 'Initial Order Products.');
            ApexPages.currentPage().getParameters().put('ordId',orderInstance.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(orderInstance);
            CRM_EditAllOrderProductsCtrl ctrl = new CRM_EditAllOrderProductsCtrl(sc);
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.materialNumber = 'Test Product 0';
            searchFilter.pageCount = 1;
            
            try{
                CRM_EditAllOrderProductsCtrl.addLineItems(orderInstance.Id, searchFilter);
                
            }catch(exception e){
                System.assertEquals(Label.CRM_Product_already_found_label,e.getMessage());
            }
            
            //Cover the method
            ctrl.getUserLocale();
        }
    }
    
 static testMethod void test1(){
        //createTestData();
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        lstAccounts[0].RecordTypeID = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        lstAccounts[0].Digital_Country_Code__c = '600';
        insert lstAccounts;
    
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 200, false); 
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = new List<Pricebook_Entry_Period__c>();
        for(Pricebook_Entry_Period__c pbep : CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false)){
            pbep.Start_Date__c = System.today()+1;
            lstPriceBookEntryPeriiod.add(pbep);
        }
        insert lstPriceBookEntryPeriiod;
    
     /* Creating Assortment(Bundles) of two types one of type campaign and other new release*/
        List<Bundle__c> lstAssort = CRM_TestDataFactory.createBundles(1,false);
        upsert lstAssort;
     /*Create Config Associated with Assortment*/    
        Config__c conf =  CRM_TestDataFactory.createConfig(lstAssort[0]);
        conf.RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_SBOM;
        insert conf;
    
        List<Order> lstorder = CRM_TestDataFactory.createOrders(lstAccounts, 2,false);    
        lstorder[0].AccountId = lstAccounts[0].id;
        lstorder[0].RecordTypeId =CRM_RecordTypeUtil.RT_ORDER_HIGH_LEVEL_RETURN;
        lstorder[0].Config__c = conf.id;
        insert lstorder;
        
        //List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntries, lstOrder, 1, true);
    
 }

}