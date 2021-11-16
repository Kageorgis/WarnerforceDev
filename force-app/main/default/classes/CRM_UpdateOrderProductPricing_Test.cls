/**
@Author-Cognizant Technology Solutions
@name-CRM_UpdateOrderProductPricing_Test
@CreateDate
@Description-The class is used to check scenarios that occur while calculating the Account Price on Deal Product
@Version-<1.0>
@reference-None
*/
@isTest
private class CRM_UpdateOrderProductPricing_Test{

static List<Account> lstParentAccounts = new List<Account>();
static List<Account> lstChildAccounts = new List<Account>();
/**
*Description-The method is used to create test data and verify if expected functionality is covered 
*@name-testData
*/
static testmethod void testData(){   
    List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
    List<Product2> lstmodifiedProduct = new List<Product2>();
    List<Order> lstChildOrder = new List<Order>();
    List<Order> lstParentOrder = new List<Order>();
    List<OrderItem> lstOrderProduct = new List<OrderItem>();
    List<OrderItem> lstModifiedOrderProduct = new List<OrderItem>();
    
    modifyAndCreateAccounts();
        
    //Create and Modify Products
    List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(20,true),1,false);
    Integer prodCount = 0;
    //Loops over Product list and modifies parameter so that it does not match with the File Discounts
    for (Product2 objProduct : lstProduct){
        objProduct.Name = 'Product '+ prodCount;
        objProduct.Product_Format__c = 'Blu-Ray';
        //objProduct.Product_Type__c  = 'New Release';      
        lstmodifiedProduct.add(objProduct);
        prodCount ++;
    }
        
    if(!lstmodifiedProduct.isEmpty())  
        insert lstmodifiedProduct;  
            
    //Modfying the Product Parameters to match with that of few File Discounts
    lstmodifiedProduct[0].Product_Format__c = 'DVD';
    lstmodifiedProduct[1].Product_Format__c = 'DVD';
    update lstmodifiedProduct;
        
    // Get standard Pricebook and Create Pricebook entry for modified Products where Product Format will not match with that on File Discounts.
    lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstmodifiedProduct,1,true);
    System.assertEquals(20,lstPriceBookEntry.size(),'Created 20 Enteries');
        
    //Create Price Book Entry Periods for the modified Products
    List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstmodifiedProduct,1,True);
    System.assertNotEquals(null, lstPriceBookEntryPeriod.size(), 'Created 20 PriceBook Entry Periods');
        
    // Create Opportunities where account is a parent account
    if(!lstParentAccounts.isEmpty()){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        lstParentOrder = CRM_TestDataFactory.createOrders(lstParentAccounts,4,True);
        System.assertEquals(20, lstParentOrder.size(), 'Created 20 Opportunities where AccountID is the Parent Account');
    }
            
     // Create Order where account is a child account
    if(!lstChildAccounts.isEmpty()){
        Id standardPricebookId = System.Test.getStandardPricebookId(); 
        lstChildOrder = CRM_TestDataFactory.createOrders(lstChildAccounts,4,True);
        System.assertEquals(20, lstChildOrder.size(), 'Created 20 Opportunities where AccountID is Child Account and has a Parent Account');
    }
    
    User u = [Select Id from User where Id =: userInfo.getUserId()];
    System.runAs(u) {
    Test.startTest();
        //Adding Deal Products in a collection by using test data created above the Test.StartTest
        if(lstPriceBookEntry.size()>0 && lstParentOrder.size()>0){
            List<OrderItem> lstOrderProductForParentAccounts = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntry, lstParentOrder , 1, false);
            for (OrderItem objDP : lstOrderProductForParentAccounts)
            lstOrderProduct.add(objDP);
        }

        System.debug('lstOrderProduct---'+lstOrderProduct);
        if(lstPriceBookEntry.size()>0 && lstChildOrder.size()>0){
            List<OrderItem> lstOrderProductForChildAccounts = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntry, lstChildOrder, 1, false);
            for (OrderItem objDP : lstOrderProductForChildAccounts)
            lstOrderProduct.add(objDP);
            insert lstOrderProduct;
        }
        System.debug('lstOrderProduct---'+lstOrderProduct);
                
        if(!lstOrderProduct.isEmpty()){
            for (OrderItem objDP : lstOrderProduct){
                 objDP.List_Price__c = 110;
                 lstModifiedOrderProduct.add(objDP);  
            }
            update lstModifiedOrderProduct;
        }

    }
    List<OrderItem> lstLineItems =  [SELECT Id,List_Price__c,Account_Price__c FROM OrderItem];
    /*for(OrderItem objLine:  lstLineItems){
        objLine.List_Price__c =110;
        update objLine;
    }*/
    Test.stopTest();
}

/**
*Description-The method sets the name and Record Type as Sold To for Accounts being created
*@name-modifyAndCreateAccounts
*/
static void modifyAndCreateAccounts(){
    //Used to get Sold To Account Record Type
    Id rtId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            
    //Creating accounts which will be used as Parent Accounts
    lstParentAccounts = CRM_TestDataFactory.createAccounts(5,false);
    lstParentAccounts[0].Name  = 'Parent Account 1';
    lstParentAccounts[0].RecordTypeId =rtId;
    lstParentAccounts[0].Planning_Customer__c = True;
    lstParentAccounts[0].Status__c = 'N';
    lstParentAccounts[1].Name  = 'Parent Account 2';
    lstParentAccounts[1].RecordTypeId =rtId;
    lstParentAccounts[1].Planning_Customer__c = True;
    lstParentAccounts[1].Status__c = 'N';
    lstParentAccounts[2].Name  = 'Parent Account 3';
    lstParentAccounts[2].RecordTypeId =rtId;
    lstParentAccounts[2].Planning_Customer__c = True;
    lstParentAccounts[2].Status__c = 'N';
    lstParentAccounts[3].Name  = 'Parent Account 4';
    lstParentAccounts[3].RecordTypeId =rtId;
    lstParentAccounts[3].Planning_Customer__c = True;
    lstParentAccounts[3].Status__c = 'N';
    lstParentAccounts[4].Name  = 'Parent Account 5';
    lstParentAccounts[4].RecordTypeId =rtId;
    lstParentAccounts[4].Planning_Customer__c = True;
    lstParentAccounts[4].Status__c = 'N';
    insert lstParentAccounts;
            
    lstChildAccounts = CRM_TestDataFactory.createAccounts(5,false);
    lstChildAccounts[0].Name = 'Child Account 1';
    lstChildAccounts[0].ParentId = lstParentAccounts[0].Id;
    lstChildAccounts[0].RecordTypeId =rtId;
    lstChildAccounts[0].Planning_Customer__c = True;
    lstChildAccounts[0].Status__c = 'N';
    lstChildAccounts[1].Name = 'Child Account 2';
    lstChildAccounts[1].ParentId = lstParentAccounts[1].Id;
    lstChildAccounts[1].RecordTypeId =rtId;
    lstChildAccounts[1].Planning_Customer__c = True;
    lstChildAccounts[1].Status__c = 'N';
    lstChildAccounts[2].Name = 'Child Account 3';
    lstChildAccounts[2].ParentId = lstParentAccounts[2].Id;
    lstChildAccounts[2].RecordTypeId =rtId;
    lstChildAccounts[2].Planning_Customer__c = True;
    lstChildAccounts[2].Status__c = 'N';
    lstChildAccounts[3].Name = 'Child Account 4';
    lstChildAccounts[3].ParentId = lstParentAccounts[3].Id;
    lstChildAccounts[3].RecordTypeId =rtId;
    lstChildAccounts[3].Planning_Customer__c = True;
    lstChildAccounts[3].Status__c = 'N';
    lstChildAccounts[4].Name = 'Child Account 5';
    lstChildAccounts[4].ParentId = lstParentAccounts[4].Id;
    lstChildAccounts[4].RecordTypeId =rtId;
    lstChildAccounts[4].Planning_Customer__c = True;
    lstChildAccounts[4].Status__c = 'N';
    insert lstChildAccounts;
    modifyAndFileDiscountsForAccounts();

}

/**
*Description-The method modifies different fields/parameters values before inserting the File Discounts for mulptiple acconts
*@name-modifyAndFileDiscountsForAccounts
*/
static void modifyAndFileDiscountsForAccounts(){
    List<File_Discount__c> lstParentAccFileDiscounts = new List<File_Discount__c>();
    List<File_Discount__c> lstChildAccFileDiscounts = new List<File_Discount__c>();
        
    Date dtTodayDate = Date.today();

    if(!lstParentAccounts.isEmpty() && !lstChildAccounts.isEmpty()){
        //Creating and Modify File Discounts for Parent Accounts
        List<File_Discount__c> lstFileDiscountForParentAccounts = CRM_TestDataFactory.createFileDiscounts(lstParentAccounts,1,false);
        Integer fdParentCount = 0;
        //Loops over File Disocunts and modifies few parameters like format and Type so that it matches with Product Type and Format
        for(File_Discount__c fd:lstFileDiscountForParentAccounts){
            fd.Name = 'FD Parent' + fdParentCount;
            fd.Priority_Promotion__c = True;
            fd.Start_Date__c = System.today();
            fd.End_Date__c = dtTodayDate + 30;
            fd.Format__c =  'DVD';
            fd.Product_Type__c = 'New Release';
            fd.Discount_Percent__c = 12.00;
            lstParentAccFileDiscounts.add(fd);
            fdParentCount ++;
        }
        //Changing the parameter value so that few records do match the criteria and are excluded
        lstParentAccFileDiscounts[0].Format__c ='Blu-Ray';
        lstParentAccFileDiscounts[1].Format__c ='Blu-Ray';
        //Inserting File Discounts for accounts which are parent accounts and do not have any parent account
        insert lstParentAccFileDiscounts;

        //Creating and Modify File Discounts for Child Accounts
        List<File_Discount__c> lstFileDiscountForChildAccounts = CRM_TestDataFactory.createFileDiscounts(lstChildAccounts,2,false);
        Integer fdChildCount = 0;
        //Loops over File Disocunts and modifies few parameters like format and Type so that it matches with Product Type and Format
        for(File_Discount__c fd:lstFileDiscountForChildAccounts){
            fd.Name = 'FD Child' + fdChildCount;
            fd.Priority_Promotion__c = False;
            fd.Start_Date__c = System.today();
            fd.End_Date__c = dtTodayDate + 35;
            fd.Format__c =  'DVD';
            fd.Product_Type__c = 'Catalog';
            fd.Discount_Percent__c = 2.00;
            lstChildAccFileDiscounts.add(fd);
            fdChildCount++;
        }
        //Inserting File Disounts for accounts which have Parent Account    
        insert lstChildAccFileDiscounts;
    }
}
/**
*Description-The method check whether the product getting added as order product is available on the config associated with order. 
             If not throws an exception.#FR 455. 
*@name-validateOrderProduct
*/
 static testMethod void validateOrderProduct(){
     testData();
     /* Creating Assortment(Bundles) of two types one of type campaign and other new release*/
        List<Bundle__c> lstAssort = CRM_TestDataFactory.createBundles(1,false);
        upsert lstAssort;
     /*Create Config Associated with Assortment*/    
        Config__c conf =  CRM_TestDataFactory.createConfig(lstAssort[0]);
        List<Config__c> lstConf = new List<Config__c>();
        lstConf.add(conf);
        insert lstConf;
        system.assertNotEquals(null, lstConf[0].id);
     
     /*Create a Order with Config*/
         List<Order> lstOrder = [SELECT Id FROM Order Limit 1];
         System.AssertNotEquals(lstOrder.size(),0);
         lstOrder[0].Config__c = lstConf[0].Id;
         update lstOrder;
    /*Try to assign any random product to that order must throw an exception*/     
         List<PricebookEntry> lstPriceBookEntry  = [Select Id FROM PricebookEntry LIMIT 1];
         List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntry, lstOrder, 1, false);
         try{
             insert lstOrderProduct;
         }
         catch(Exception e)
         {
                Boolean expectedExceptionThrown =  e.getMessage().contains('The Product is not avalaible for this Order. Not added on the Config associated with the order.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
         } 
 }//End of Function
 
}