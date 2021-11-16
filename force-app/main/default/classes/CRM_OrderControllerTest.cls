/**
@Author-Cognizant Technology Solutions
@name-CRM_OrderControllerTest
@CreateDate-Date>
@Description-Test Class to cover different scenarios that will occur for CRM_OrderControllerTest
@Version-<1.0>
@reference-None
*/
@isTest(SeeAllData=false) 
public class CRM_OrderControllerTest{ 
    
    @testsetup
    public static void createTestData(){
        integer numOfProduct = 1;
        
            
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'SFDC Support Level 3' Limit 1];
        System.assertEquals(1, profiles.size());
        
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'UserNoAccess',
            Username = String.valueOf(d).substring(0,8) + 'abc123@test.com',
            Email = 'abc123@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testUser;
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false); 
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Planning_Customer__c = True;
        lstAccounts[0].Status__c = 'N';
        upsert lstAccounts;        
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1,true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup,numOfProduct,false); 
        for(Product2 prodInstance : lstProduct){
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        }
        insert lstProduct;
        
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,true);
        Test.startTest();
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = new List<Pricebook_Entry_Period__c>();
        for(Pricebook_Entry_Period__c pbep : CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct,1,false)){
            pbep.Start_Date__c = System.today()+1;
            lstPriceBookEntryPeriiod.add(pbep);
        }
        insert lstPriceBookEntryPeriiod;
        System.debug('lstPriceBookEntryPeriiod::'+lstPriceBookEntryPeriiod);
        
        List<Order> lstOrder = CRM_TestDataFactory.createOrders(lstAccounts,1,false);
        lstOrder[0].Customer_PO_Number__c = '123456';
        insert lstOrder;
        
        List<OrderItem> lstOrderProduct = CRM_TestDataFactory.createOrderProductWithOrder(lstPriceBookEntries,lstOrder,numOfProduct,true);
        System.assertEquals(numOfProduct, [SELECT Id FROM OrderItem Where OrderId =: lstOrder[0].Id].Size()); 
        
        Test.stopTest();
    }

    public static testMethod void testCloneOrderWithOutProducts(){
        List<Order> lstOrder = [Select Id,Status,Order_Submitted_Date__c From Order limit 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOrder[0]);
        CRM_OrderController obj = new CRM_OrderController(sc);
        list<String> retCloneOrder = CRM_OrderController.cloneOrderProducts(lstOrder[0].Id,false);
        Test.stopTest();
        System.assertEquals('Open', [SELECT Id,Status,Order_Submitted_Date__c FROM Order Where id =: retCloneOrder[0]].Status);
    }
    
    public static testMethod void testCloneOrderWithProducts(){
        List<Order> lstOrder = [Select Id,Status,Order_Submitted_Date__c From Order limit 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOrder[0]);
        CRM_OrderController obj = new CRM_OrderController(sc);
        list<string> retCloneOrder = CRM_OrderController.cloneOrderProducts(lstOrder[0].Id,true);
        Test.stopTest();
        System.assertEquals('Open', [SELECT Id,Status,Order_Submitted_Date__c FROM Order Where id =: retCloneOrder[0]].Status);
        System.assertEquals(1, [SELECT Id FROM OrderItem Where OrderId =: retCloneOrder[0]].Size());
    }
    
    public static testMethod void testActivateOrderWithOpenStatus(){
        List<Order> lstOrder = [Select Id,OrderNumber,Status,Count_of_Order_Product__c From Order limit 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOrder[0]);
        CRM_OrderController obj = new CRM_OrderController(sc);
        CRM_OrderController.activateOrder(lstOrder[0].Id);
        Test.stopTest();
        System.assertEquals('Submitted', [SELECT Id,Status FROM Order Where id =: lstOrder[0].Id].Status);
    }
    
    public static testMethod void testActivateOrderWithoutOpenStatus(){
        List<Order> lstOrder = [Select Id,OrderNumber,Status,Count_of_Order_Product__c From Order limit 1];
        lstOrder[0].Status = 'Failed';
        update lstOrder[0];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOrder[0]);
        CRM_OrderController obj = new CRM_OrderController(sc);
        try{
            CRM_OrderController.activateOrder(lstOrder[0].Id);
        }catch(Exception e){
            system.assertequals(System.label.CRM_Order_Activation_Error,e.getMessage());
        }
        Test.stopTest();
        System.assertEquals('Failed', [SELECT Id,Status FROM Order Where id =: lstOrder[0].Id].Status);
    }
    
    public static testMethod void testActivateOrderWithoutOrderProduct(){
        List<Order> lstOrder = [Select Id,OrderNumber,Status,Count_of_Order_Product__c From Order limit 1];
        Delete [SELECT Id FROM OrderItem Where OrderId =: lstOrder[0].Id];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOrder[0]);
        CRM_OrderController obj = new CRM_OrderController(sc);
        try{
            CRM_OrderController.activateOrder(lstOrder[0].Id);
        }catch(Exception e){
            system.assertequals(System.label.CRM_Order_Item_Not_Present,e.getMessage());
        }
        Test.stopTest();
        System.assertEquals('Open', [SELECT Id,Status FROM Order Where id =: lstOrder[0].Id].Status);
    }
    
    public static testMethod void testActivateOrderWithNoAccess(){
        List<User> UserList = [Select Id From User Where LastName = 'UserNoAccess' limit 1];
        List<Order> lstOrder = [Select Id,OrderNumber,Status,Count_of_Order_Product__c From Order limit 1];
        System.runAs(UserList[0]){
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOrder[0]);
            CRM_OrderController obj = new CRM_OrderController(sc);
            try{
                CRM_OrderController.activateOrder(lstOrder[0].Id);
            }catch(Exception e){
                system.assertequals(System.label.CRM_Order_Activation_Error_Privilege,e.getMessage());
            }
            Test.stopTest();
        }
    }

    /*
    public static List<Id> dealIds = new List<Id>();
    // This method is use to crreate order test data.
    static testMethod void GenerateOrderTestDataMethod(){
        
        List<Account> listSoldToAccounts = new List<Account>();
        List<Opportunity> lstDeals;
        List<Id> dpIds = new List<Id>();
        List<Product2> lstProduct2 = new List<Product2>();
        List<PricebookEntry>  lstPricebookEntry = new List<PricebookEntry>();
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstUpdatedOpportunityLineItem = new List<OpportunityLineItem>();
        
        List<Account> accountList = CRM_TestDataFactory.createAccounts(1,false);
        for(Account account : accountList){
            account.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            listSoldToAccounts.add(account);
        }
        
        insert listSoldToAccounts;
        System.assertNotEquals(null, listSoldToAccounts[0].Id, 'Error while creating Accounts');
        // create product for the order
        
        List<Product2> listOfProducts = new List<Product2>();
        
        //Create Products
        listOfProducts = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,true);
        
        //Create PriceBook Entries
        lstPricebookEntry = CRM_TestDataFactory.createPriceBookEntries(listOfProducts,1,true);
        
        CRM_TestDataFactory.createPriceBookEntryPeriods(listOfProducts,1,true);
        
        // Create Deals to generate Order and Order Products from the deal
        lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(listSoldToAccounts,1,true);
        System.assertEquals(1, lstDeals.size(), 'Created Opportunity');
        dealIds.add(lstDeals[0].Id);
        //Create Deal Product
        lstOpportunityLineItem = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricebookEntry,lstDeals,1,false);
        for(OpportunityLineItem oli : lstOpportunityLineItem){
            oli.Initial_Quantity__c =2;
            oli.Promoted_Price__c =10;
            lstUpdatedOpportunityLineItem.add(oli);
            dpIds.add(oli.Id);
        }
        insert lstUpdatedOpportunityLineItem;
        
        System.AssertEquals(1,lstUpdatedOpportunityLineItem.size(),'Created Deal Product');
        
        Test.StartTest();
        
    }
    
    */
}