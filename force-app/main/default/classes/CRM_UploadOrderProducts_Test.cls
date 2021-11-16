/**
   @Author Cognizant
   @name CRM_UploadOrderProducts_Test
   @CreateDate 11 Feb 2016
   @Description Test class for CRM_UploadOrderProductsController
   @Version <1.0>
   @reference Requirement no 83
  */
  
@isTest
private class CRM_UploadOrderProducts_Test {
    
    /**
    *  Create Test Data. 
    *  @name allTheDataForThisTestClass
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
         static void allTheDataForThisTestClass(){
            Id soldToRecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            //create accounts
            list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
            accounts[0].recordTypeId = soldToRecordTypeId;
            insert accounts;
            
            //create order
            List<Order> orders = CRM_TestDataFactory.createOrders(accounts, 2, false);
            orders[0].CurrencyIsoCode = 'USD';
            orders[1].CurrencyIsoCode = 'USD';
            orders[0].EndDate = system.today()+30;
            
            orders[1].EndDate = system.today()+30;
            insert orders;
            system.debug('===orders=created=='+orders);
            system.assertEquals(2,orders.size());
            //create products and associate with orders
            List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
            List<Product2> products = CRM_TestDataFactory.createProducts(pgs, 3, false);
            products[0].productCode= 'code1';
            products[0].Universal_Picture_Code__c ='upc1';
            products[1].productCode='code2';
            products[1].Universal_Picture_Code__c='upc2';
            products[2].productCode='code3';
            products[2].Universal_Picture_Code__c='upc3';
            insert products;
            system.debug('===products==='+products);
            
            List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true);
            system.debug('===pbEntries==='+pbEntries);
            
            List<Pricebook_Entry_Period__c> pbe=CRM_TestDataFactory.createPriceBookEntryPeriods(new list<product2>{products[0],products[1]}, 1, true);
            
            List<OrderItem> orderproducts = CRM_TestDataFactory.createOrderProductWithOrder(pbEntries, orders, 1, true);
            system.assertEquals(2,orderproducts.size());
    }
    
     /**
    *  Test 1: Test to insert new dealproducts and update existing record 
    *  Expected: new record should get inserted and existing should get updated
    *  @name unitTestPositive
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestPositive() {
        allTheDataForThisTestClass();
        list<Order> orders = [select id,EffectiveDate,EndDate,(select id,Quantity,UnitPrice,Pricebookentry.Product2Id, Pricebookentry.Product2.productCode from OrderItems)
                              from Order];
        system.debug('============orders============'+orders);
        List<PricebookEntry> pbEntries = [select id,product2Id,product2.productCode from PricebookEntry];
        List<Product2> products = [select id from Product2];
        String sort_By = 'Pricebookentry.Product2.Name ASC';
        
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadOrderProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',orders[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(orders[0]);
                             
                    CRM_UploadOrderProductsController pg = new CRM_UploadOrderProductsController(controller); 
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> lineItems = CRM_UploadOrderProductsController.getOrderLineItems(orders[0].id,sort_By);// method
                    
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadOrderProductsController.OrderLineItemWrapper wrapper = new CRM_UploadOrderProductsController.OrderLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Pricebookentry.Product2.productCode ='code1';
                    wrapper.lineItemRecord.Pricebookentry.Product2.Universal_Picture_Code__c='upc1';
                    if(lineItems[0].lineItemRecord.Pricebookentry.Product2.productCode =='code1') {
                        wrapper.lineItemRecord.Pricebookentry.Product2.productCode ='code2';
                        wrapper.lineItemRecord.Pricebookentry.Product2.Universal_Picture_Code__c='upc2';
                    }
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    wrapper.lineItemRecord.UnitPrice=null;
                    lineItems.add(wrapper);
                    
                    //update existing record
                    lineItems[0].lineItemRecord.UnitPrice = 12;
                    lineItems[0].isRowModified = true;
                    Pricebook_Entry_Period__c pbep = [select id, Start_Date__c, List_Price__c,End_Date__c,Product__r.External_Id__c from Pricebook_Entry_Period__c where Product__r.productCode=: wrapper.lineItemRecord.Pricebookentry.Product2.productCode limit 1];
                    pbep.Start_Date__c = orders[0].EffectiveDate+1;
                    pbep.End_Date__c = pbep.Start_Date__c + 30;
                    pbep.List_Price__c = 20;
                    update pbep;
                    /*************************************prepare data end***********************************************/
                    
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> savedlineItems = CRM_UploadOrderProductsController.setOrderLineItems(lineItems,orders[0].id);// method
                    /*************************************asserts***********************************************/
                    system.assertEquals(Label.CRM_Upload_Message_Updated, savedlineItems[0].validation);
                    system.assertEquals(Label.CRM_Upload_Message_Created, savedlineItems[savedlineItems.size()-1].validation);
                    /*************************************asserts***********************************************
                    
                    
                    /*************************************prepare data for delete***********************************************/
                    //update existing record
                    lineItems[0].isRowRemoved = true;
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> dellineItems = CRM_UploadOrderProductsController.setOrderLineItems(lineItems,orders[0].id);// method
                    /*************************************asserts***********************************************/
                    system.assertEquals(savedlineItems.size()-1, dellineItems.size());
                    
                    //list<CRM_UploadOrderProductsController.OrderLineItemWrapper> removedlineItems=CRM_UploadOrderProductsController.deleteOrderLineItems(savedlineItems);// method
                    /*************************************asserts***********************************************/
                    //system.assertEquals(savedlineItems.size(), removedlineItems.size());
        Test.stopTest();
    }
    
     /**
    *  Test 2: Test to insert new record orderProducts with improper information
    *  Expected: record should not be inserted and should throw exception
    *  @name unitTestException
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestException() {
       allTheDataForThisTestClass();
       list<Order> orders = [select id,EffectiveDate,EndDate,(select id,Quantity,UnitPrice,Pricebookentry.Product2Id, Pricebookentry.Product2.productCode from OrderItems)
                              from Order];
       system.debug('============orders============'+orders);
       String sort_By = 'Pricebookentry.Product2.Name ASC';
       Test.startTest();
                    PageReference pageRef = Page.CRM_UploadOrderProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',orders[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(orders[0]);
                    CRM_UploadOrderProductsController pg = new CRM_UploadOrderProductsController(controller); 
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> lineItems = CRM_UploadOrderProductsController.getOrderLineItems(orders[0].id,sort_By);
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadOrderProductsController.OrderLineItemWrapper wrapper = new CRM_UploadOrderProductsController.OrderLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Pricebookentry.Product2.productCode ='code1';
                    wrapper.isRowModified=null;
                    wrapper.existingId=null;
                    lineItems.add(wrapper);
                    /*************************************prepare data end***********************************************/
                    try {
                        list<CRM_UploadOrderProductsController.OrderLineItemWrapper> savedlineItems = CRM_UploadOrderProductsController.setOrderLineItems(lineItems,orders[0].id);
                    }
                    catch(Exception e){
                        /*************************************asserts***********************************************/
                        system.assertEquals(true, e.getMessage().contains('null'));
                    }
                    
        Test.stopTest();
    }
    
     /**
    *  Test 2: Test to insert new record orderProducts with improper information
    *  Expected: record should not be inserted and should throw exception
    *  @name unitTestException
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestException1() {
       allTheDataForThisTestClass();
       list<Order> orders = [select id,EffectiveDate,EndDate,(select id,Quantity,UnitPrice,Pricebookentry.Product2Id, Pricebookentry.Product2.productCode from OrderItems)
                              from Order limit 1];
       system.debug('============orders============'+orders);
       String sort_By = 'Pricebookentry.Product2.Name ASC';
       Test.startTest();
                    PageReference pageRef = Page.CRM_UploadOrderProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',orders[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(orders[0]);
                    CRM_UploadOrderProductsController pg = new CRM_UploadOrderProductsController(controller); 
                    orders[0].status=CRM_AppConstants.ORDER_STAGE_SUBMITTED;
                    orders[0].Customer_PO_Number__c ='12345';
                    update orders;
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> lineItems = CRM_UploadOrderProductsController.getOrderLineItems(orders[0].id,sort_By);
                    /*************************************prepare data start***********************************************/
                    CRM_UploadOrderProductsController.OrderLineItemWrapper wrapper = new CRM_UploadOrderProductsController.OrderLineItemWrapper();
                    lineItems[0].isRowRemoved=true;
                    lineItems[0].isRowModified=false;
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> dellineItems = CRM_UploadOrderProductsController.setOrderLineItems(lineItems,orders[0].id);
                    system.assertEquals(lineItems.size(), dellineItems.size());
                    
        Test.stopTest();
    }
    
    /**
    *  Test 3: Test to insert new order product record and update existing order product record of order with improper information
    *  Expected: record should not be created/updated and should throw validation messages
    *  @name unitTestValidationFailed
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestValidationFailed() {
        allTheDataForThisTestClass();
        list<Order> orders = [select id,(select id,Quantity,UnitPrice,Pricebookentry.Product2Id, Pricebookentry.Product2.productCode from OrderItems)
                              from Order];
        system.debug('============orders============'+orders);
        String sort_By = 'Pricebookentry.Product2.Name ASC';
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadOrderProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',orders[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(orders[0]);
                    CRM_UploadOrderProductsController pg = new CRM_UploadOrderProductsController(controller); 
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> lineItems = CRM_UploadOrderProductsController.getOrderLineItems(orders[0].id,sort_By);
                    
                    //update existing record
                    lineItems[0].lineItemRecord.Quantity = 0;
                    lineItems[0].isRowModified = true;
                    
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadOrderProductsController.OrderLineItemWrapper wrapper = new CRM_UploadOrderProductsController.OrderLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Pricebookentry.Product2.productCode ='codeABC';
                    wrapper.lineItemRecord.Quantity = 1;
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    lineItems.add(wrapper);
                    
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> savedlineItems = CRM_UploadOrderProductsController.setOrderLineItems(lineItems,orders[0].id);
                    
                    /*************************************asserts***********************************************/
                    for(CRM_UploadOrderProductsController.OrderLineItemWrapper wrp: savedlineItems) {
                        system.debug('wrp :::::: '+wrp+'----------'+wrp.lineItemRecord.Pricebookentry.Product2.productCode);
                        if(wrp.lineItemRecord.Pricebookentry.Product2.productCode =='codeABC' && wrp.existingId == null) {
                            system.assertEquals(Label.CRM_Upload_Message_NotFound, wrp.validation);
                        }
                        if(wrp.lineItemRecord.id==lineItems[0].lineItemRecord.id) {
                            system.assertNotEquals(Label.CRM_Upload_Message_Updated, wrp.validation);
                        }
                    }
        Test.stopTest();
    }
    
     /**
    *  Test 4: Test to insert new order product record and update existing order product record of order with improper information
    *  Expected: record should not be created/updated and should throw validation messages
    *  @name unitTestValidationFailed
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestValidationFailed2() {
        allTheDataForThisTestClass();
        list<Order> orders = [select id,EffectiveDate,EndDate,(select id,Quantity,UnitPrice,Pricebookentry.Product2Id, Pricebookentry.Product2.productCode from OrderItems)
                              from Order];
        system.debug('============orders============'+orders);
        String sort_By = 'Pricebookentry.Product2.Name ASC';
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadOrderProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',orders[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(orders[0]);
                    CRM_UploadOrderProductsController pg = new CRM_UploadOrderProductsController(controller); 
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> lineItems = CRM_UploadOrderProductsController.getOrderLineItems(orders[0].id,sort_By);
                    /*************************************prepare data start***********************************************/
                    
                    
                    //insert new Record
                    CRM_UploadOrderProductsController.OrderLineItemWrapper wrapper = new CRM_UploadOrderProductsController.OrderLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Pricebookentry.Product2.productCode ='code1';
                    wrapper.lineItemRecord.Pricebookentry.Product2.Universal_Picture_Code__c='upc1';
                    if(lineItems[0].lineItemRecord.Pricebookentry.Product2.productCode =='code1') {
                        wrapper.lineItemRecord.Pricebookentry.Product2.productCode ='code2';
                        wrapper.lineItemRecord.Pricebookentry.Product2.Universal_Picture_Code__c='upc2';
                    }
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    wrapper.lineItemRecord.UnitPrice=null;
                    lineItems.add(wrapper);
                    
                    Pricebook_Entry_Period__c pbep = [select id, Start_Date__c, End_Date__c,Product__r.External_Id__c from Pricebook_Entry_Period__c where Product__r.productCode= : wrapper.lineItemRecord.Pricebookentry.Product2.productCode limit 1];
                    pbep.Start_Date__c = orders[0].EndDate+1;
                    pbep.End_Date__c = pbep.Start_Date__c + 30;
                    update pbep;
                    //system.debug('=======pbep======='+pbep);
                    
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadOrderProductsController.OrderLineItemWrapper> savedlineItems = CRM_UploadOrderProductsController.setOrderLineItems(lineItems,orders[0].id);
                    
                    /*************************************asserts***********************************************/
                    for(CRM_UploadOrderProductsController.OrderLineItemWrapper wrp: savedlineItems) {
                        if(wrp.lineItemRecord.id==null) {
                            //system.assertEquals(Label.CRM_Upload_Message_Dates, wrp.validation);
                            system.assertEquals(Label.CRM_Upload_Message_PBEP, wrp.validation);
                        }
                    }
        Test.stopTest();
    }
}