/**
@Author-Cognizant Technology Solutions
@name-CRM_ProductPricingHandler_Test
@CreateDate
@Description-The class is used to check scenarios that occur while calculating the Account Price on Deal Product
@Version-<1.0>
@reference-None
*/
@isTest
private class CRM_ProductPricingHandler_Test{

static List<Account> lstParentAccounts = new List<Account>();
static List<Account> lstChildAccounts = new List<Account>();
/**
*Description-The method is used to create test data and verify if expected functionality is covered 
*@name-testData
*/
static testmethod void testData(){   
    List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
    List<Product2> lstmodifiedProduct = new List<Product2>();
    List<Opportunity> lstChildOpportunity = new List<Opportunity>();
    List<Opportunity> lstParentOpportunity = new List<Opportunity>();
    List<OpportunityLineItem> lstDP = new List<OpportunityLineItem>();
    List<OpportunityLineItem> lstModifiedDP = new List<OpportunityLineItem>();
    
    modifyAndCreateAccounts();
        
    //Create and Modify Products
    List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(2,true),4,false);
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
    System.assertEquals(8,lstPriceBookEntry.size(),'Created 8 Enteries');
    
    // Updating Price Book Entry
    List<PricebookEntry> lstUpdtedPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstmodifiedProduct,1,false);
    System.assertEquals(8,lstPriceBookEntry.size(),'Created 8 Enteries');
    List<PricebookEntry> lstModifiedPriceBookEntry = new List<PricebookEntry>();
    
    for(PricebookEntry objPriceBookEntry:lstUpdtedPriceBookEntry){
        objPriceBookEntry.CurrencyIsoCode = 'GBP';
        lstModifiedPriceBookEntry.add(objPriceBookEntry);   
    }
    insert lstModifiedPriceBookEntry;
        
    //Create Price Book Entry Periods for the modified Products
    List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstmodifiedProduct,1,True);
    System.assertEquals(8, lstPriceBookEntryPeriod.size(), 'Created PriceBook Entry Periods' + lstPriceBookEntryPeriod.size());
    
    List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodModified = new List<Pricebook_Entry_Period__c>();
    if(!lstPriceBookEntryPeriod.isEmpty()){
            for (Pricebook_Entry_Period__c objPBEP : lstPriceBookEntryPeriod){
                objPBEP.Account_Price__c=100;
                objPBEP.List_Price__c = 100;
                objPBEP.Minimum_Price__c = 100;
                objPBEP.Retail_Price__c = 100;
                //objPBEP.Suggested_Price__c = 100;
                objPBEP.SR_Price__c = 100;
                objPBEP.Vendor_ID__c = 'VID12345';
                lstPriceBookEntryPeriodModified.add(objPBEP);
            }
            update lstPriceBookEntryPeriodModified;
        }
        
    // Create Opportunities where account is a parent account
    if(!lstParentAccounts.isEmpty()){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        lstParentOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstParentAccounts,4,True);
        System.assertEquals(20, lstParentOpportunity.size(), 'Created 20 Opportunities where AccountID is the Parent Account');
    }
            
     // Create Opportunity where account is a child account
   if(!lstChildAccounts.isEmpty()){
        Id standardPricebookId = System.Test.getStandardPricebookId(); 
        lstChildOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstChildAccounts,4,True);
        System.assertEquals(20, lstChildOpportunity.size(), 'Created 20 Opportunities where AccountID is Child Account and has a Parent Account');
    }
    
    User u = [Select Id from User where Id =: userInfo.getUserId()];
    System.runAs(u) {
    Test.startTest();
    
        //Adding Deal Products in a collection by using test data created above the Test.StartTest
        List<OpportunityLineItem> lstDealProductForParentAccounts;
        if(lstPriceBookEntry.size()>0 && lstParentOpportunity.size()>0){
            lstDealProductForParentAccounts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstParentOpportunity , 1, true);
            for (OpportunityLineItem objDP : lstDealProductForParentAccounts)
                lstDP.add(objDP);
        }
        if(lstPriceBookEntry.size()>0 && lstChildOpportunity.size()>0){
            List<OpportunityLineItem> lstDealProductForChildAccounts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstModifiedPriceBookEntry, lstChildOpportunity, 1, false);
 
               for (OpportunityLineItem objDP : lstDealProductForChildAccounts)
                   lstDP.add(objDP);
                   
        }
        
        List<OpportunityLineItem> lstLineItemsInserted =  [SELECT Id,UnitPrice,promoted_Price__c,Customer_Retail_Price__c,Minimum_Price__c,ListPrice__c,Account_Price__c,SR_Price__c,Vendor_ID__c FROM OpportunityLineItem];
        //system.debug('**'+lstDealProductForParentAccounts);
        if(!lstLineItemsInserted.isEmpty()){
            for (OpportunityLineItem objDP : lstLineItemsInserted){
                System.assertEquals(100,objDP.ListPrice__c,'List Price calculated');
                System.assertEquals(100,objDP.Minimum_Price__c,'Minimum Price calculated');
                //System.assertEquals(100,objDP.Customer_Retail_Price__c,'Customer Retail Price calculated');
                System.assertEquals(100,objDP.Account_Price__c,'Account Price calculated');
                System.assertEquals(100,objDP.promoted_Price__c,'Promoted Price calculated');
                System.assertEquals(100,objDP.UnitPrice,'Unit Price calculated');
                System.assertEquals(100,objDP.SR_Price__c,'SR Price');
                System.assertEquals('VID12345',objDP.Vendor_ID__c,'Vendor Id');
                 objDP.ListPrice__c = 11;
                //objDP.Account_Price__c = null;
                 lstModifiedDP.add(objDP);
            }
            upsert lstModifiedDP;
        }
        
        CRM_ProductPricingHandler.DealWrapper[] listDealWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
       
        OpportunityLineItem oli = lstDealProductForParentAccounts[0];
        CRM_ProductPricingHandler.DealWrapper dw = new CRM_ProductPricingHandler.DealWrapper();
        Opportunity opp = lstParentOpportunity[0];
        dw.dealId = oli.OpportunityId;
        dw.accountId = opp.AccountId;
        dw.dealCurrency = opp.CurrencyISOCode;
        dw.productId = oli.Product2Id;
        dw.pricebookId = opp.Pricebook2Id;
        dw.dealStartDate = opp.Start_Date__c;
        dw.dealEndDate = opp.CloseDate;
        dw.dealProduct = oli;
        listDealWrappers.add(dw);   
        
        CRM_ProductPricingHandler instance = new CRM_ProductPricingHandler(listDealWrappers);
        instance.getProductDatedListPrice(dw);
 
    Test.stopTest();
    }
    /*List<OpportunityLineItem> lstLineItems =  [SELECT Id,ListPrice__c,Account_Price__c FROM OpportunityLineItem];
        System.assertEquals(100,lstLineItems[0].Account_Price__c,'Account Price calculated');*/
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
    lstParentAccounts[1].Name  = 'Parent Account 2';
    lstParentAccounts[1].RecordTypeId =rtId;
    lstParentAccounts[2].Name  = 'Parent Account 3';
    lstParentAccounts[2].RecordTypeId =rtId;
    lstParentAccounts[3].Name  = 'Parent Account 4';
    lstParentAccounts[3].RecordTypeId =rtId;
    lstParentAccounts[4].Name  = 'Parent Account 5';
    lstParentAccounts[4].RecordTypeId =rtId;
    insert lstParentAccounts;
            
    lstChildAccounts = CRM_TestDataFactory.createAccounts(5,false);
    lstChildAccounts[0].Name = 'Child Account 1';
    lstChildAccounts[0].ParentId = lstParentAccounts[0].Id;
    lstChildAccounts[0].RecordTypeId =rtId;
    lstChildAccounts[1].Name = 'Child Account 2';
    lstChildAccounts[1].ParentId = lstParentAccounts[1].Id;
    lstChildAccounts[1].RecordTypeId =rtId;
    lstChildAccounts[2].Name = 'Child Account 3';
    lstChildAccounts[2].ParentId = lstParentAccounts[2].Id;
    lstChildAccounts[2].RecordTypeId =rtId;
    lstChildAccounts[3].Name = 'Child Account 4';
    lstChildAccounts[3].ParentId = lstParentAccounts[3].Id;
    lstChildAccounts[3].RecordTypeId =rtId;
    lstChildAccounts[4].Name = 'Child Account 5';
    lstChildAccounts[4].ParentId = lstParentAccounts[4].Id;
    lstChildAccounts[4].RecordTypeId =rtId;
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
    
}