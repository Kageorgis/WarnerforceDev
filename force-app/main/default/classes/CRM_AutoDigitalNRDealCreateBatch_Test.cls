/**
   @Author Aditi Satpute
   @name CRM_AutoDigitalNRDealCreateBatch_Test
   @CreateDate 08 Apr 2016
   @Description Test class for CRM_AutoDigitalNRDealCreationBatch
   @Version <1.0>
   @reference Requirement no 155
  */
  
@isTest 
private with sharing class CRM_AutoDigitalNRDealCreateBatch_Test {

    public static User createUser() {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(date.today()) + 'abcCADFNRB@test.com',
            Email = 'abc@test.com',
            Alias = String.valueOf(date.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testUser;
        return testUser;
    }

    public static testMethod void Scenario1_With_Existing_Deal_And_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        List<Account_Plan__c> lstAP = [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : lstAP) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Account_Plan__c, Quantity,Target_Quantity__c, Product2Id,Opportunity.AccountId FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
            } else {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                System.assertEquals(0, dealProduct.Target_Quantity__c);
                System.assertEquals(null, dealProduct.Account_Plan__c);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }
 
        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
        
    }

    public static testMethod void Scenario1_With_Existing_Committed_Deal_And_Target_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update oppList;
        }

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Quantity,Target_Quantity__c, Product2Id,Opportunity.AccountId FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
            } else {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                System.assertEquals(0, dealProduct.Target_Quantity__c);
            }        
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }
 
        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
        
    }

    public static testMethod void Scenario1_With_Existing_Approved_Deal_And_Target_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Make the deal as Approved
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            }
            update oppList;
        }

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name is still same
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Quantity,Target_Quantity__c, Product2Id,Opportunity.AccountId FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
            } else {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                System.assertEquals(0, dealProduct.Target_Quantity__c);
            }        
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }
 
        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
        
    }

    public static testMethod void Scenario1_Without_Existing_Deal_And_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Delete existing deals so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        // Verify No valid opportunity records present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c  + '-' +  accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 3 deals created for 3 digital products
        System.assertEquals(3, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Quantity, Opportunity.AccountId,Account_Price__c, Target_Quantity__c, Product2Id FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                System.assertEquals(1, dealProduct.Quantity, 'Shopuld not be updated');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
            } else {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                System.assertEquals(0, dealProduct.Target_Quantity__c);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Scenario1_With_Existing_Deal_And_No_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Remove Account Plan so no Targets present for clculation and Deal Products created with Quantity 1
        List<Account_Plan__c> lstExistingAccountPlan = [SELECT Id FROM Account_Plan__c];
        delete lstExistingAccountPlan;

        List<Target__c> lstTargets = [SELECT Id FROM Target__c];
        delete lstTargets;

        // Verify no targets present
        System.assertEquals(0, [SELECT Id from Account_Plan__c].size());
        System.assertEquals(0, [SELECT Id from Target__c].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem]) {
            System.assertEquals(1, dealProduct.Quantity, 'No Targets so Quantity should be 1');
            System.assertEquals(0, dealProduct.Target_Quantity__c, 'No Targets so Quantity should be 0');
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }
 
        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Scenario1_Without_Existing_Deal_And_No_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();

        // Delete existing delas so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        // Verify No valid opportunity records present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Remove Targets present for clculation so Deal Products created with Quantity 1
        //List<Account_Plan__c> lstExistingAccountPlan = [SELECT Id FROM Account_Plan__c];
        //delete lstExistingAccountPlan;

        List<Target__c> lstTargets = [SELECT Id FROM Target__c];
        delete lstTargets;

        // Verify no targets present
        //System.assertEquals(0, [SELECT Id from Account_Plan__c].size());
        System.assertEquals(0, [SELECT Id from Target__c].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }
 
        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 3 deals created for 3 digital products
        System.assertEquals(3, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Target_Quantity__c, Quantity FROM OpportunityLineItem]) {
            System.assertEquals(1, dealProduct.Quantity, 'No Targets so Quantity should be 1');
            System.assertEquals(0, dealProduct.Target_Quantity__c, 'No Targets so Quantity should be 0');
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstDealsForChangedStreetDate = CRM_TestDataFactory.createOpportunitiesWithAccounts(tw.lstAccounts,1,false);
        System.assertEquals(5, lstDealsForChangedStreetDate.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstDealsForChangedStreetDate.size(); i++) {
            Opportunity d0_existingDeal = lstDealsForChangedStreetDate[i];
            d0_existingDeal.AccountId = tw.lstAccounts[i].Id;
            d0_existingDeal.Name = 'Deal' + countDeal++;
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
            d0_existingDeal.CurrencyIsoCode = 'USD';
            d0_existingDeal.Start_Date__c = system.today() + 140;
            d0_existingDeal.CloseDate = system.today() + 160;
            d0_existingDeal.Promo_Start_Date__c = system.today() + 140;
            d0_existingDeal.Promo_End_Date__c = system.today() + 160;
            /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() + 140).year(),
                    (system.today() + 140).month(),
                    (system.today() + 140).day()
                );
            String currentMonth1 = sDate1.format('MMM');*/
            Integer currentQtr1 =
                Decimal.valueOf(
                    (system.today() + 140).toStartOfMonth().month()
                ).divide(3.0, 0, System.RoundingMode.UP).intValue();
            String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;

            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod1 + '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            String strdealProductType = '';
            if (tw.lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = tw.lstProduct[i].Type__c;
            }
            d0_existingDeal.Product_Type__c = strdealProductType;
            if(d0_existingDeal.Product_Type__c!= null){
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(lstDealsForChangedStreetDate);

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Verify 10 valid opportunity records present
        System.assertEquals(10, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        List<Account_Plan__c> lstAP = [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : lstAP) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(10, [SELECT Id FROM Opportunity].size());

        // Verify 7 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(7, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Account_Plan__c, OpportunityId, Target_Quantity__c, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                    System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                    System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(null, dealProduct.Account_Plan__c);
                }

                // Verify these deal products are linked with new deals different based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Planned_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // Verify existing deal Products present for existing deals
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        /// 3 additional deals created for Digital Products
        System.assertEquals(8, [SELECT Id FROM Opportunity].size());

        // Verify deal Products are cloned even if the deal Stage is not NR Default and existing deal products deleted
        // But 2 new deal products are inserted for 2 products there were no deal products present in a Non NR Default Deal
        System.assertEquals(7, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity as it is entered and it is not recalculated');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity should be recalculated');
                    System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId), 'Cloned Deal Product should not be attached to existing deal');
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity is 1 after calculating as no valid Account Plan Targets found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is 0 after calculating as no valid Account Plan Targets found');
                    System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId), 'Cloned Deal Product should not be attached to existing deal');
                }
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
            System.assert(!productInstance.NR_Product_Created__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Approved_Future_Deal_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();
        
        // Change the Account Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Account acc : tw.lstAccounts) {
            acc.CurrencyIsoCode = 'GBP';
        }
        system.runAs(createUser()) {
            update tw.lstAccounts;
        }

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        // Make the deal as Approved
        System.runas(testUser) {
            for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
                Opportunity d0_existingDeal = tw.lstOpportunity[i];
                d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            }
            update tw.lstOpportunity;
        }
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // Verify existing deal Products present for existing deals
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // No additional deals created for Digital Products as no valid PBEP Present
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify deal Products are not cloned and not updated even if deal Stage is non NR Default
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        Integer countDigital = 0;
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                countDigital++;
            }
        }
        System.assertEquals(3, countDigital);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
            System.assert(!productInstance.NR_Product_Created__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Approved_Non_Future_Deal_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();
        
        // Change the Account Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Account acc : tw.lstAccounts) {
            acc.CurrencyIsoCode = 'GBP';
        }
        system.runAs(createUser()) {
            update tw.lstAccounts;
        }

        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            d0_existingDeal.Start_Date__c = System.today() - 1;
            d0_existingDeal.Promo_Start_Date__c = System.today() - 1;
        }
        update tw.lstOpportunity;

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        // Make the deal as Approved
        System.runas(testUser) {
            for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
                Opportunity d0_existingDeal = tw.lstOpportunity[i];
                d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            }
            update tw.lstOpportunity;
        }
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // Verify existing deal Products present for existing deals
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // No additional deals created for Digital Products as no valid PBEP Present
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        /// Verify deal Products are not cloned and modified even if deal Stage is non NR Default
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        Integer countDigital = 0;
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                countDigital++;
            }
        }
        System.assertEquals(3, countDigital);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
            System.assert(!productInstance.NR_Product_Created__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_With_Stage_Changed_And_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstDealsForChangedStreetDate = CRM_TestDataFactory.createOpportunitiesWithAccounts(tw.lstAccounts,1,false);
        System.assertEquals(5, lstDealsForChangedStreetDate.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstDealsForChangedStreetDate.size(); i++) {
            Opportunity d0_existingDeal = lstDealsForChangedStreetDate[i];
            d0_existingDeal.AccountId = tw.lstAccounts[i].Id;
            d0_existingDeal.Name = 'Deal' + countDeal++;
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            d0_existingDeal.CurrencyIsoCode = 'USD';
            d0_existingDeal.Start_Date__c = system.today() + 140;
            d0_existingDeal.CloseDate = system.today() + 160;
            d0_existingDeal.Promo_Start_Date__c = system.today() + 140;
            d0_existingDeal.Promo_End_Date__c = system.today() + 160;
            /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() + 140).year(),
                    (system.today() + 140).month(),
                    (system.today() + 140).day()
                );
            String currentMonth1 = sDate1.format('MMM');*/
            Integer currentQtr1 =
                Decimal.valueOf(
                    (system.today() + 140).toStartOfMonth().month()
                ).divide(3.0, 0, System.RoundingMode.UP).intValue();
            String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            String strdealProductType = '';
            if (tw.lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = tw.lstProduct[i].Type__c;
            }
            d0_existingDeal.Product_Type__c = strdealProductType;
            if(d0_existingDeal.Product_Type__c!= null){
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(lstDealsForChangedStreetDate);

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Verify 10 valid opportunity records present
        System.assertEquals(10, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created even if valid Deal Stage is changed to Non NR Default
        System.assertEquals(10, [SELECT Id FROM Opportunity].size());

        // Verify deal Products are cloned and new deal products are inserted as the deal Stage is NR Default
        System.assertEquals(7, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');

                    // Verify these deal products are linked with existing deals based on changed Street Date
                    System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c);

                    // Verify these deal products are linked with existing deals based on changed Street Date
                    System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                }
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
            System.assert(!productInstance.NR_Product_Created__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_With_Stage_Committed_And_Deal_Product_To_Be_Cloned_Present_Test(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstDealsForChangedStreetDate = CRM_TestDataFactory.createOpportunitiesWithAccounts(tw.lstAccounts,1,false);
        System.assertEquals(5, lstDealsForChangedStreetDate.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstDealsForChangedStreetDate.size(); i++) {
            Opportunity d0_existingDeal = lstDealsForChangedStreetDate[i];
            d0_existingDeal.AccountId = tw.lstAccounts[i].Id;
            d0_existingDeal.Name = 'Deal' + countDeal++;
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            d0_existingDeal.CurrencyIsoCode = 'USD';
            d0_existingDeal.Start_Date__c = system.today() + 140;
            d0_existingDeal.CloseDate = system.today() + 160;
            d0_existingDeal.Promo_Start_Date__c = system.today() + 140;
            d0_existingDeal.Promo_End_Date__c = system.today() + 160;
            /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() + 140).year(),
                    (system.today() + 140).month(),
                    (system.today() + 140).day()
                );
            String currentMonth1 = sDate1.format('MMM');*/
            Integer currentQtr1 =
                Decimal.valueOf(
                    (system.today() + 140).toStartOfMonth().month()
                ).divide(3.0, 0, System.RoundingMode.UP).intValue();
            String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;

            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            String strdealProductType = '';
            if (tw.lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = tw.lstProduct[i].Type__c;
            }
            d0_existingDeal.Product_Type__c = strdealProductType;
            if(d0_existingDeal.Product_Type__c!= null){
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(lstDealsForChangedStreetDate);

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update oppList;
        }

        // Verify 10 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records present
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsBeforeBatchRun.size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created even if valid Deal Stage is changed to Non NR Default
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName,Product_Type__c,RecordTypeId,LastModifiedDate, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());

        /*Integer countDigital = 0;
        for (Opportunity digitalDeal : dealsAfterBatchRun) {
            if (mapIdToDealInstance.containsKey(digitalDeal.Id) && digitalDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL ) {
                if (digitalDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                    System.assertEquals(1, digitalDeal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : digitalDeal.OpportunityLineItems) {
                        System.assertEquals(digitalDeal.LastModifiedDate, dealProduct.LastModifiedDate);
                        countDigital++;
                    }
                } else {
                    System.assertEquals(2, digitalDeal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : digitalDeal.OpportunityLineItems) {
                        System.assertEquals(digitalDeal.LastModifiedDate, dealProduct.LastModifiedDate);
                        countDigital++;
                    }
                }
            }
        }
        System.assertEquals(5, countDigital);*/
        System.assertEquals(dealsBeforeBatchRun.size(), dealsAfterBatchRun.size());

        // Verify Satge Name is not changed
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
        }

        // Verify deal Products are cloned and new deal products are inserted as the deal Stage is NR Default
        System.assertEquals(7, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');

                    // Verify these deal products are linked with existing deals based on changed Street Date
                    System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c);

                    // Verify these deal products are linked with existing deals based on changed Street Date
                    System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                }
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
            System.assert(!productInstance.NR_Product_Created__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_With_Stage_Approved_And_Deal_Product_To_Be_Cloned_Present_Test(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstDealsForChangedStreetDate = CRM_TestDataFactory.createOpportunitiesWithAccounts(tw.lstAccounts,1,false);
        System.assertEquals(5, lstDealsForChangedStreetDate.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstDealsForChangedStreetDate.size(); i++) {
            Opportunity d0_existingDeal = lstDealsForChangedStreetDate[i];
            d0_existingDeal.AccountId = tw.lstAccounts[i].Id;
            d0_existingDeal.Name = 'Deal' + countDeal++;
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            d0_existingDeal.CurrencyIsoCode = 'USD';
            d0_existingDeal.Start_Date__c = system.today() + 140;
            d0_existingDeal.CloseDate = system.today() + 160;
            d0_existingDeal.Promo_Start_Date__c = system.today() + 140;
            d0_existingDeal.Promo_End_Date__c = system.today() + 160;
            /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() + 140).year(),
                    (system.today() + 140).month(),
                    (system.today() + 140).day()
                );
            String currentMonth1 = sDate1.format('MMM');*/
            Integer currentQtr1 =
                Decimal.valueOf(
                    (system.today() + 140).toStartOfMonth().month()
                ).divide(3.0, 0, System.RoundingMode.UP).intValue();
            String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;

            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            String strdealProductType = '';
            if (tw.lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = tw.lstProduct[i].Type__c;
            }
            d0_existingDeal.Product_Type__c = strdealProductType;
            if(d0_existingDeal.Product_Type__c!= null){
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(lstDealsForChangedStreetDate);

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Make the deal as Approved
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            }
            update oppList;
        }

        // Verify 10 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created even if valid Deal Stage is changed to Non NR Default
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify deal Products are cloned and new deal products are inserted as the deal Stage is NR Default
        System.assertEquals(7, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');

                    // Verify these deal products are linked with existing deals based on changed Street Date
                    System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c);

                    // Verify these deal products are linked with existing deals based on changed Street Date
                    System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                }
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
            System.assert(!productInstance.NR_Product_Created__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_And_No_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();
        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity deal = tw.lstOpportunity[i];
            /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() + 140).year(),
                    (system.today() + 140).month(),
                    (system.today() + 140).day()
                );
            String currentMonth1 = sDate1.format('MMM');*/
            Integer currentQtr1 =
                Decimal.valueOf(
                    (system.today() + 140).toStartOfMonth().month()
                ).divide(3.0, 0, System.RoundingMode.UP).intValue();
            String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;

            deal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            deal.Start_Date__c =  system.today()+140;
            deal.Promo_Start_Date__c =  system.today()+140;
            deal.CloseDate =  system.today()+160;
            deal.Promo_End_Date__c =  system.today()+160;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        }
        update tw.lstOpportunity;
        for (Opportunity deal : tw.lstOpportunity) {
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        }
        update tw.lstOpportunity;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        // Verify n5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }
        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records for 3 digital products should be Cloned and created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_No_Existing_Deal_But_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Verify 5 opportunity records present valid for Product before changing Street Date
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records present
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 3 additional deals are created for digital products based on new street date
        System.assertEquals(8, [SELECT Id FROM Opportunity].size());
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Id NOT IN: tw.lstOpportunity]);

        // Verify 7 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(7, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not change');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }

                // Verify these deal products are linked with new deals different based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_No_Existing_Deal_And_No_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();
        
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        delete tw.lstOpportunity;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        // Verify no valid opportunity records present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }
        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 3 opportunity records created for 3 digital products
        System.assertEquals(3, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records for 3 digital products should be Cloned and created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products each
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }        
        
        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_With_Existing_Deal_And_Deal_Product_Present_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up Product Data to false as for scenario 3 both these checboxes are false 
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Account_Price__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }

        // Verify Target flags are set
        List<Account_Plan__c> lstAP = [SELECT Id, Customer__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : lstAP) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Plan__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not change');
                    System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                    System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                    System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(null, dealProduct.Account_Plan__c);
                }
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Scenario3_And_Scenario4_With_Existing_Deal_And_Deal_Product_Present_And_List_Price_Changed_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up Product Data to false as for scenario 3 both these checboxes are false 
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Account_Price__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        // Verify There is no Senario 1 OR 2 condition
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            System.assertEquals(20, pbep.List_Price__c);
        }

        // Verify Target flags are set as true such that there is Scenario 3 condition
        for (Account_Plan__c accountPlanInstance :  [SELECT Id, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Targets changed should be true');
        }

        // Change the List price of PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c];
        for(Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.List_Price__c = 10;
        }
        update lstPBEP;

        // Verify Process NR Batch checkbox is checked and List Price is also changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            System.assertEquals(10, pbep.List_Price__c);
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 7 deal products present. 5 are existing deal products and 2 are newly created.
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(7,dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c, Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(20.00, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }
                digitalDealProducts++;
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Updated Account Price');
            }
        }
        System.assertEquals(5, digitalDealProducts);

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c,Product__r.RecordTypeId FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario4_With_Existing_Deal_And_Deal_Product_Present_And_List_Price_Changed_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up Product Data to false as for scenario 3 both these checboxes are false 
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Target_Quantity__c,Id,Account_Price__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        // Verify There is no Senario 1 OR 2 condition
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            System.assertEquals(20, pbep.List_Price__c);
        }

        // Verify Target flags are set as false such that there is no Scenario 3 condition
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlanInstance : lstAccountPlan) {
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;

        // Change the List price of PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c];
        for(Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.List_Price__c = 10;
        }
        update lstPBEP;

        // Verify Process NR Batch checkbox is checked and List Price is also changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            System.assertEquals(10, pbep.List_Price__c);
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 7 deal products present. 5 are existing deal products and 2 are newly created.
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(7,dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Updated Quantity = Target Revenue / Account Price');
                    System.assertEquals(20.00, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }
                digitalDealProducts++;
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Updated Account Price');
            }
        }
        System.assertEquals(5, digitalDealProducts);

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c,Product__r.RecordTypeId FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_With_No_Existing_Deal_And_Deal_Product_Present_Test(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());
        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        lstAccounts[0].Games_Digital__c = true;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Video_Digital__c = false;
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        insert lstAccounts[0];
        Account soldToAccountGD = lstAccounts[0];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the code will try to search the PriceBookEntryPeriod Start lies between the  Deal Start Date and End Date
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreated[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreated[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreated[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreated[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreated;

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriodCreated) {
            pbep.Process_NR_Batch__c = false;
        }
        update lstPriceBookEntryPeriodCreated;

        List<Product2> fetchedProducts = [SELECT Id,NR_Product_Created__c, Street_Date_Has_Changed__c FROM  Product2];
        System.assertEquals(1, fetchedProducts.size());

        fetchedProducts[0].NR_Product_Created__c = false;
        fetchedProducts[0].Street_Date_Has_Changed__c = false;
        update fetchedProducts;

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesDigital.Target__c = 200;
        //t0_GamesDigital.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
        }  

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no deal and deal products are created for Scenario 3
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsAfterBatchRun.size());

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void NR_Product_Creation_With_No_Deal_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        
        // Change the Account Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Account acc : tw.lstAccounts) {
            acc.CurrencyIsoCode = 'GBP';
        }
        system.runAs(createUser()) {
            update tw.lstAccounts;
        }

        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        delete tw.lstOpportunity;
        Set<Id> setProcessedProductIds = new Set<Id>();
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no deal and deal product is created
        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'New Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');

        // Verify Target flags are reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Street_Date_Changed_With_Existing_Schedules_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        
        // Change the Account Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Account acc : tw.lstAccounts) {
            acc.CurrencyIsoCode = 'GBP';
        }
        system.runAs(createUser()) {
            update tw.lstAccounts;
        }

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;

        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;

        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(1, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        //Setting up OpportunityLineItemSchedule Data
        for(Integer i=0 ; i< lstDealProductSchedule.size(); i++){
            lstDealProductSchedule[i].OpportunityLineItemId = lstDealProduct[i].id;
        }
        insert lstDealProductSchedule;
        
        //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+40;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+40;
        }
        update tw.lstPriceBookEntryPeriod;

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify the Quantity is update after creating Schedules
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(21, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify No new Deal is created as no valid PBEP found
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');

        // Verify no new Deal Product is cloned and modified
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify no digital deal products are cloned and modified. Existing manually created digital and physical deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c,Product2.Type__c,NR_Deal_Product_Unique_Key__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            if (dealProducts.Product2.Type__c.contains('Digital')) {
                System.assertEquals(21, dealProducts.Quantity);
                System.assertEquals(0, dealProducts.Target_Quantity__c);
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity from OpportunityLineItemSchedule];
        System.assertEquals(5, schedules.size(), 'No change');

        // Verify Target flags are reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Target_Revenue_Changed_With_Existing_Deal_And_Deal_Product_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBEP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up Product Data to false as for scenario 3 both these checboxes are false 
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.CurrencyIsoCode = 'GBP';
        }
        update tw.lstPriceBookEntryPeriod;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
        }  

        // Verify Process NR  flags are reset as we are checking only Scenario 3 when all Scenario 1, 2 ,4 are already executed
        List<Pricebook_Entry_Period__c> pbepList = new List<Pricebook_Entry_Period__c>();
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Target_Revenue_AND_PBEP_Start_Date_Changed_With_Existing_Deal_And_Deal_Product_And_No_Valid_PBEP_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBEP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up Product Data to false as for scenario 3 both these checboxes are false 
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        // Create PricebookEntryPeriod which is not valid for the Product
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+140;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+160;
            tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'GBP';
        }
        update tw.lstPriceBookEntryPeriod;

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
        }  

        // Verify Process NR  flags are set as we are checking  Scenario 3 along with Scenario 4
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5, dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void PBEP_List_Price_Changed_With_Existing_Deal_And_Deal_Product_And_No_Valid_PBEP_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();
        
        // Change the Account Currency to make a scenario such that no valid PBEP found for the record being processed
        /*for (Account acc : tw.lstAccounts) {
            acc.CurrencyIsoCode = 'GBP';
        }
        update tw.lstAccounts;*/

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up Product Data to false as for scenario 3 both these checboxes are false 
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        // Create PricebookEntryPeriod which is not valid for the Product
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].List_Price__c = 10;
            tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'GBP';
        }
        update tw.lstPriceBookEntryPeriod;

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset as we are checking only Scenario 4 when all Scenario 1, 2 ,3 are already executed
        List<Account_Plan__c> lstAccountPlan = new List<Account_Plan__c>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
            lstAccountPlan.add(accountPlanInstance);
        }
        update lstAccountPlan;

        // Verify Process NR Batch checkbox is checked as Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
    
    /*public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario_2_And_3_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
        }
        insert lstDealProduct;        
        //Setting up OpportunityLineItemSchedule Data
        for(Integer i=0 ; i< lstDealProductSchedule.size(); i++){
            lstDealProductSchedule[i].OpportunityLineItemId = lstDealProduct[i].id;
        }
        insert lstDealProductSchedule;
        
        //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id,Previous_Start_Date__c, Start_Date__c,Suggested_Price__c,
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        // Previous Start Date not Specified
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            lstPBEP[i].Previous_Start_Date__c = null;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(21, schedule.Quantity);
            System.assertEquals(system.today(), schedule.ScheduleDate);
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lineItems = [Select Id,OpportunityId from OpportunityLineItem];
        System.assertEquals(7,lineItems.size(), 'Initial Deal Products');
        Map<Id, OpportunityLineItem> mapIdToDealProductInsatnce = new Map<Id, OpportunityLineItem>(lineItems);
        Integer digitalDealProducts = 0;

        for (OpportunityLineItem dealProduct : [Select Id,Product2.RecordTypeId,OpportunityId,Quantity,Target_Quantity__c,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.debug('--dealProduct.OpportunityLineItemSchedules-->'+dealProduct.OpportunityLineItemSchedules);
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity);

                    //System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(10, dealProduct.Target_Quantity__c);

                    // Verify Schedules are not created with changed Date as Previous Start Date is not present
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(1, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(system.today()+140, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                }
                digitalDealProducts++;
            }
        }

        System.assertEquals(5, digitalDealProducts);

        // Verify Target flags are not reset properly after batch processing due to error present
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are not reset properly after batch processing due to error present
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c, 'True as error present');
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked due to error
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }
    }

    public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario2_3_With_Batch_ReRun_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
        }
        insert lstDealProduct;
        //Setting up OpportunityLineItemSchedule Data
        for(Integer i=0 ; i< lstDealProductSchedule.size(); i++){
            lstDealProductSchedule[i].OpportunityLineItemId = lstDealProduct[i].id;
        }
        insert lstDealProductSchedule;
        
        //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id,Previous_Start_Date__c, Start_Date__c,Suggested_Price__c,
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        // Previous Start Date not Specified
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(21, schedule.Quantity);
            System.assertEquals(system.today(), schedule.ScheduleDate);
        }

        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch1.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            productAndAccountIdSet,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );

        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lineItems = [Select Id,OpportunityId from OpportunityLineItem];
        System.assertEquals(7,lineItems.size(), 'Initial Deal Products');
        System.assertEquals(4, [SELECT Id FROM OpportunityLineItemSchedule].size(), 'Digital Schedules deleted');

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Flags are not reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked due to error
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity);
                    //System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    // Verify Schedules are not created with changed Date as Previous Start Date is not present
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(1, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(system.today()+140, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                }
                digitalDealProducts++;
            }
        }
        System.assertEquals(5, digitalDealProducts);

        // Run the batch again as the flags are checked
        //CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoDigitalNRDealCreationBatch();
        //List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch1.getNRProducts();
        //CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed, mapProductIdToAccountPlanList , mapIdToPBEPInstance, setProcessedProductIds );
        //Test.stopTest();
        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // No new deal / Deal Product is created
        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(7,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify Flags are reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Flags are reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is reset
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

    }

    public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario2_With_Batch_ReRun_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
        }
        insert lstDealProduct;        
        //Setting up OpportunityLineItemSchedule Data
        for(Integer i=0 ; i< lstDealProductSchedule.size(); i++){
            lstDealProductSchedule[i].OpportunityLineItemId = lstDealProduct[i].id;
        }
        insert lstDealProductSchedule;
        
        //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id,Previous_Start_Date__c, Start_Date__c,Suggested_Price__c,
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        // Previous Start Date not Specified
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(21, schedule.Quantity);
            System.assertEquals(system.today(), schedule.ScheduleDate);
        }

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c];
        for (Account_Plan__c accountPlanInstance : lstAccountPlan) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                accountPlanInstance.Target_Revenue_Has_Changed__c = false;
            }
        }
        update lstAccountPlan;

        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch1.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed, productAndAccountIdSet , mapIdToPBEPInstance, setProcessedProductIds );

        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lineItems = [Select Id,OpportunityId from OpportunityLineItem];
        System.assertEquals(7,lineItems.size(), 'Initial Deal Products');
        System.assertEquals(4, [SELECT Id FROM OpportunityLineItemSchedule].size(), 'Digital Schedules deleted');

        // Verify Target flags are not reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Flags are not reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked due to error
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity);
                    //System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    // Verify Schedules are not created with changed Date as Previous Start Date is not present
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(1, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(system.today()+140, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                }
                digitalDealProducts++;
            }
        }
        System.assertEquals(5, digitalDealProducts);

        // Run the batch again as the flags are checked
        //CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoDigitalNRDealCreationBatch();
        //List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch1.getNRProducts();
        //CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed, mapProductIdToAccountPlanList , mapIdToPBEPInstance, setProcessedProductIds );
        //Test.stopTest();
        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // No new deal / Deal Product is created
        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(7,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify Flags are reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Flags are reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is reset
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

    }*/

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GD )
           2. Deals -> D0 -> For A0 -> (GD, Start Date = System.Today())
           3. Deal Product -> D0 (DP0 with P0 batch created having unique Key)
      2. Product ->
           1. P0 (GD, Street Date = System.today() + 40 (i.e PBEP changed StartDate = System.today() + 40)) -> Valid Target with Revenue Changed to 100
      3. Run Batch -> Result
           1. While batch is Running ->  Change Product P0 Street Date i.e PBEP StartDate  to System.today() + 140 and Valid Target with Revenue Changed to 200
           2. After Batch runs -> 
                - P0
                    - New Deal D1 for changed Street Date = System.today() + 40 is created
                    - The existing deal product DP0 gets cloned to the new Deal D1 and DP1 is created
                    - The Street Date has changed and Target Revenue has changed checkboxes doesnt get
                      reset as the Version for both these records gets incremented because record got updated during batch was running
      4. Batch Runs Again
            - P0 is picked up for processing as the checkboxes were not reset in previous execution
            - New Deal D2 for changed Street Date = System.today() + 140 is created
            - The existing deal product DP1 gets cloned to the new Deal D2 and DP2 is now created
            - The Street Date has changed and Target Revenue has changed checkboxes gets reset
    
    
    public static testMethod void Street_Date_And_Target_Revenue_Changed_With_Version_Change() {
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Setting Up the Sold To Account Data with 'Games Digital Type'
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(1);
        System.assertEquals(1, lstAccounts.size());
        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Games_Digital__c = true;
        lstAccounts[0].Sales_Organization__c = null;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
        update lstAccounts[0];
        Account soldToAccount = lstAccounts[0];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Setting Up the Product data with Type Games Physical
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(), false);
        for(Product2 p : lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
           p.Street_Date_Has_Changed__c = true;
           p.CurrencyIsoCode = 'USD';
           p.Local_Title__c = lstLocaTitle[0].Id;
           p.Type__c = 'Games Digital';
           p.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
           p.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
           //p.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        insert lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        System.assertEquals(1, lstProduct.size());

        // Setting up 1 Price Book Entry record for each created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.assertEquals(1, lstPriceBookEntryPeriod.size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        lstPBEP[0].Start_Date__c = system.today()+40;
        lstPBEP[0].End_Date__c = System.today() + 60;
        update lstPBEP;

        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        for(Product2 p : lstProduct){
            p.NR_Product_Created__c = false;
        }
        update lstProduct;

        // Setting up 1 Target data for each Account and Product created
        List<Target__c> lstTargets = CRM_AutoPhysicalNRDealCreateService_Test.createTargetsForNRBatch(lstAccounts, lstProduct, lstProGrp);
        System.assertEquals(1, lstTargets.size());
        for(Integer i=0 ; i < lstTargets.size() ; i++){
            lstTargets[i].Target__c = 100;
            //lstTargets[i].Target_Revenue_Has_Changed__c = true;
        }
        update lstTargets;

        // Create a Map of Target data before updating the target because the batch will run with these Target
        // data and will have the previous version
        List<Account_Plan__c> lstAccountPlan = [Select Id,NR_Version__c, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c +'-'+accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        // Setting up 1 Deal data for the sold To Account
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(
                CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false),
                lstAccounts,
                lstProduct,
                lstPriceBookEntryPeriod
            );
        System.assertEquals(1, lstOpportunity.size());

        // Setting up Deal Product data such that batch deal deal Product already present for the above created Deal
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccounts[i].Id + '-' + lstPriceBookEntry[i].Product2Id;
        }
        insert lstDealProduct;
        System.assertEquals(1, lstDealProduct.size());

        // Verify Version before changing Product Street Date / Target Revenue
        System.assertEquals(0, [Select Id, NR_Version__c from Product2][0].NR_Version__c);
        List<Account_Plan__c> accPlans = [Select Id, NR_Version__c from Account_Plan__c];
        System.assertEquals(2, accPlans[0].NR_Version__c);
        System.assertEquals(lstAccountPlan[0].NR_Version__c, accPlans[0].NR_Version__c);

        System.assertEquals(1, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(1, [Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(0, [Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');
        System.assertEquals(system.today() + 40, lstPBEP[0].Start_Date__c);

        // Run the batch such that while running the Product Street Date / Target Revenue has been modified
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            automaticNRDealCreationBatch.getNRProducts(),
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );

        Test.startTest();

        // Verify New Deal for changed Street Date gets created
        Map<String, Date> mapStartAndCloseDateForDeal =
            CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(lstPBEP[0].Start_Date__c, 'Q');
        Integer currentQtr =
            Decimal.valueOf(
                lstPBEP[0].Start_Date__c.toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod = 'Q ' + currentQtr;
        List<Opportunity> fetchedDealsWithLatest = [Select Id, Name, NR_Deal_Unique_Key__c from Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(2, fetchedDealsWithLatest.size(), 'New Deals');
        System.debug('-fetchedDealsWithLatest--->'+fetchedDealsWithLatest);
        Opportunity newlyCreatedOpportunity = new Opportunity();
        for (Opportunity deal : fetchedDealsWithLatest) {
            if (deal.NR_Deal_Unique_Key__c != null && deal.Id != lstOpportunity[0].Id) {
                 newlyCreatedOpportunity = deal;
                 System.assertEquals('New Releases Games Digital '+dealPeriod+' '+(system.today() + 40).year()+' ' + soldToAccount.Name, deal.Name);
            }
        }

        // Deal Product is cloned and attached to new deal thats why the count of Deal Products is still one
        // Verify the records created with previous StreetDate / Revenue change even if the
        // Street Date / Target Revenue was changed while batch was running
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId,Target_Quantity__c,Quantity, Opportunity.Name, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(1, dealProducts.size(), 'New Deal Products');
        System.assertEquals(1, dealProducts[0].Quantity);
        System.assertEquals(5, dealProducts[0].Target_Quantity__c);
        System.assertEquals(newlyCreatedOpportunity.Id, dealProducts[0].OpportunityId, 'New Deal Products');

        // As the Batch is running the Version is updated due to change in Street Date and Target Revenue
        List<Pricebook_Entry_Period__c> updatedPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            updatedPBEP[i].Start_Date__c = system.today()+140;
            updatedPBEP[i].End_Date__c = System.today() +160;
        }
        update updatedPBEP;

        System.assertEquals(1, updatedPBEP.size());
        System.assertEquals(system.today() + 140, updatedPBEP[0].Start_Date__c);
        List<Account_Plan__c> lstAccountPlanAfterFirstBatchRun = [Select Id, NR_Version__c from Account_Plan__c];
        System.assertEquals(0, lstAccountPlanAfterFirstBatchRun[0].NR_Version__c);
        List<Target__c> lstTargetWithVersion = new List<Target__c>();
        for(Target__c t : [Select Id,Target__c, Account_Plan_Lookup__c, NR_Version__c from Target__c]){ // New field 'Account_Plan_Lookup__c' added by Hrushikesh
           t.Target__c = 200;
           lstTargetWithVersion.add(t);
        }
        update lstTargetWithVersion;

        List<Account_Plan__c> lstAccountPlanBeforeSecondBatchRun = [Select Id, Target_Revenue_Has_Changed__c, NR_Version__c from Account_Plan__c];
        System.assertEquals(1, lstAccountPlanBeforeSecondBatchRun[0].NR_Version__c);

        // As Version was changed Verify the Checkboxes (StreetDate changed and Target Revenue Changed) is still true even
        // when the batch was processed successfully
        System.assertEquals(true, [Select Id, Street_Date_Has_Changed__c from Product2][0].Street_Date_Has_Changed__c);
        System.assertEquals(true, lstAccountPlanBeforeSecondBatchRun[0].Target_Revenue_Has_Changed__c);
        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // Run the batch again and in this batch only the Product whose street Date / Target whose Revenue was modified
        // during previous batch was running will be considered
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch2 = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch2,1);
        Test.stopTest();

        // Verify a new Deal gets created For the Street Date Changed
        Map<String, Date> mapStartAndCloseDateForDeal1 =
            CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(
                updatedPBEP[0].Start_Date__c, 'Q'
            );
        Integer currentQtr1 =
            Decimal.valueOf(
                updatedPBEP[0].Start_Date__c.toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = 'Q ' + currentQtr1;
        List<Opportunity> fetchedDealsWithLatest1 = [Select Id, Name from Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(3, fetchedDealsWithLatest1.size(), 'New Deals');
        System.debug('-fetchedDealsWithLatest1--->'+fetchedDealsWithLatest1);
        System.assertEquals('New Releases Games Digital '+dealPeriod1+' '+(system.today() + 140).year()+' ' + soldToAccount.Name, fetchedDealsWithLatest1[0].Name);

        // Deal Product is cloned and attached to new deal with updated Quantity thats why the count is still one
        // Verify the deal Product is cloned to the deal with changed StreetDate and updated with Quantity calculated based on Target Revenue
        // which was changed while batch was running previously
        List<OpportunityLineItem> fetchedDealProducts = [Select Id,Quantity, Target_Quantity__c,OpportunityId, Opportunity.Name, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(1, fetchedDealProducts.size(), 'New Deal Products');
        System.assertEquals(fetchedDealsWithLatest1[0].Id, fetchedDealProducts[0].OpportunityId);
        System.assertEquals(1, fetchedDealProducts[0].Quantity);
        System.assertEquals(10, fetchedDealProducts[0].Target_Quantity__c);

        // Verify the Version and the checkboxes has been reset
        List<Account_Plan__c> lstAccountPlanAfterSecondBatchRun = [Select Id, Target_Revenue_Has_Changed__c, NR_Version__c from Account_Plan__c];
        System.assertEquals(false, [Select Id, Street_Date_Has_Changed__c from Product2][0].Street_Date_Has_Changed__c);
        System.assertEquals(false, lstAccountPlanAfterSecondBatchRun[0].Target_Revenue_Has_Changed__c);
        System.assertEquals(0, lstAccountPlanAfterSecondBatchRun[0].NR_Version__c);
 
         // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }*/

    public static testMethod void Scenario1_With_Existing_Multiple_Stage_Deal_And_Target_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();

        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        // Update Accounts to make all as Physical
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Sales_Organization__c = null ;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            if (i == 0) {
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 1) {
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 2) {
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = true;
            } else if (i == 3) {
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = true;
            } else if (i == 4) {
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Video_Digital__c = false;
            }
        }
        update lstAccounts;

        List<Local_Title__c> lstLocaTitle = [SELECT Id FROM Local_Title__c];
        System.assertEquals(1, lstLocaTitle.size());

        // Update Products to make all as Digital
        List<Product2> lstProduct = tw.lstProduct;
        System.assertEquals(5, lstProduct.size());
        for(Integer i=0; i<lstProduct.size(); i++){
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            }else if (i == 2) {
                lstProduct[i].Type__c = 'Video Digital';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstProduct[i].SAP_Material_Type__c = '';
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Digital';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstProduct[i].SAP_Material_Type__c = '';
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }
        }
        update lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = tw.lstPriceBookEntryPeriod;
        System.assertEquals(5, lstPriceBookEntryPeriod.size());

        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = lstProduct[i].id;
            lstPriceBookEntryPeriod[i].New_Release__c = true;
            lstPriceBookEntryPeriod[i].Process_NR_Batch__c = true;
        }
        update lstPriceBookEntryPeriod;

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            delete oppList;

            oppList = CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
            System.assertEquals(5, oppList.size());

            oppList[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            oppList[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            oppList[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            oppList[3].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;
            oppList[4].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update oppList;
        }

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, dealsBeforeBatchRun[0].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealsBeforeBatchRun[1].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, dealsBeforeBatchRun[2].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED, dealsBeforeBatchRun[3].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealsBeforeBatchRun[4].StageName);

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : [SELECT Id, NR_Product_Created__c, Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name is not changed
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, dealsAfterBatchRun[0].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealsAfterBatchRun[1].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, dealsAfterBatchRun[2].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED, dealsAfterBatchRun[3].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealsAfterBatchRun[4].StageName);

        // Verify 13 deal product records for 5 physical products should be created through batch
        System.assertEquals(13, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_With_Multiple_Stage_And_Deal_Product_To_Be_Cloned_Present_Test(){

        Set<String> setAccountIdAndProductId = new Set<String>();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();

        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        // Update Accounts to make all as Physical
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Sales_Organization__c = null ;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            if (i == 0) {
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 1) {
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 2) {
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = true;
            } else if (i == 3) {
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = true;
            } else if (i == 4) {
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Video_Digital__c = false;
            }
        }
        update lstAccounts;

        List<Local_Title__c> lstLocaTitle = [SELECT Id FROM Local_Title__c];
        System.assertEquals(1, lstLocaTitle.size());

        // Update Products to make all as Digital
        List<Product2> lstProduct = tw.lstProduct;
        System.assertEquals(5, lstProduct.size());
        for(Integer i=0; i<lstProduct.size(); i++){
            //lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            }else if (i == 2) {
                lstProduct[i].Type__c = 'Video Digital';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstProduct[i].SAP_Material_Type__c = '';
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Digital';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstProduct[i].SAP_Material_Type__c = '';
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }
        }
        update lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = tw.lstPriceBookEntryPeriod;
        System.assertEquals(5, lstPriceBookEntryPeriod.size());

        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = lstProduct[i].id;
            lstPriceBookEntryPeriod[i].New_Release__c = true;
        }
        update lstPriceBookEntryPeriod;

        List<Opportunity> existingDeals = [SELECT Id,StageName FROM Opportunity];
        delete existingDeals;

        existingDeals = CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
        System.assertEquals(5, existingDeals.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstDealsForChangedStreetDate = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(5, lstDealsForChangedStreetDate.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstDealsForChangedStreetDate.size(); i++) {
            Opportunity d0_existingDeal = lstDealsForChangedStreetDate[i];
            d0_existingDeal.AccountId = lstAccounts[i].Id;
            d0_existingDeal.Name = 'Deal' + countDeal++;
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            d0_existingDeal.CurrencyIsoCode = 'USD';
            d0_existingDeal.Start_Date__c = system.today() + 140;
            d0_existingDeal.CloseDate = system.today() + 160;
            d0_existingDeal.Promo_Start_Date__c = system.today() + 140;
            d0_existingDeal.Promo_End_Date__c = system.today() + 160;
            String dealPeriod = '';
            if (
                    lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE
            ) {
                Integer currentQtr =
                    Decimal.valueOf(
                        (system.today() + 140).toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = 'Q' + currentQtr;
            } else {
                Datetime sDate =
                    datetime.newInstance(
                        (system.today() + 140).year(),
                        (system.today() + 140).month(),
                        (system.today() + 140).day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
            }

            d0_existingDeal.NR_Deal_Unique_Key__c = lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(lstProduct[i].Type__c);
            String strdealProductType = '';
            if (tw.lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = lstProduct[i].Type__c;
            }
            d0_existingDeal.Product_Type__c = strdealProductType;
            if(d0_existingDeal.Product_Type__c!= null){
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);

        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update lstProduct;
        System.assertEquals(5, lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, existingDeals, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = existingDeals[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccounts[i].Id + '-' + lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity ORDER BY CreatedDate];
            System.assertEquals(10, oppList.size());
            oppList[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            oppList[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            oppList[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            oppList[3].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;
            oppList[4].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            oppList[5].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            oppList[6].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            oppList[7].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            oppList[8].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;
            oppList[9].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update oppList;
        }

        // Verify 10 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, dealsBeforeBatchRun[0].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealsBeforeBatchRun[1].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, dealsBeforeBatchRun[2].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED, dealsBeforeBatchRun[3].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealsBeforeBatchRun[4].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, dealsBeforeBatchRun[5].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealsBeforeBatchRun[6].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, dealsBeforeBatchRun[7].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED, dealsBeforeBatchRun[8].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealsBeforeBatchRun[9].StageName);

        // Verify 5 deal product records present
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsBeforeBatchRun.size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify additional opportunity records are not created even if valid Deal Stage is changed to Non NR Default
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());

        System.assertEquals(dealsBeforeBatchRun.size(), dealsAfterBatchRun.size());

        // Verify Satge Name is not change and Line Items LastModified Date is changed
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, dealsAfterBatchRun[0].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealsAfterBatchRun[1].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, dealsAfterBatchRun[2].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED, dealsAfterBatchRun[3].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealsAfterBatchRun[4].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, dealsAfterBatchRun[5].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealsAfterBatchRun[6].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, dealsAfterBatchRun[7].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED, dealsAfterBatchRun[8].StageName);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealsAfterBatchRun[9].StageName);


        Integer countDigital = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(13, dealProductsAfterBatchRun.size());

        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(20, dealProduct.Account_Price__c);
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                    countDigital ++;
                } else {
                    System.assertEquals(20, dealProduct.Account_Price__c);
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                    System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity = 0');
                    countDigital ++;
                }
            }
        }
        System.assertEquals(13, countDigital);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }



    public static testMethod void Scenario2_With_Existing_Deal_Having_DP_With_Stage_Committed_And_Deal_Product_To_Be_Cloned_Present_Test(){

        Set<String> setAccountIdAndProductId = new Set<String>();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstDealsForChangedStreetDate = CRM_TestDataFactory.createOpportunitiesWithAccounts(tw.lstAccounts,1,false);
        System.assertEquals(5, lstDealsForChangedStreetDate.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstDealsForChangedStreetDate.size(); i++) {
            Opportunity d0_existingDeal = lstDealsForChangedStreetDate[i];
            d0_existingDeal.AccountId = tw.lstAccounts[i].Id;
            d0_existingDeal.Name = 'Deal' + countDeal++;
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            d0_existingDeal.CurrencyIsoCode = 'USD';
            d0_existingDeal.Start_Date__c = system.today() + 140;
            d0_existingDeal.CloseDate = system.today() + 160;
            d0_existingDeal.Promo_Start_Date__c = system.today() + 140;
            d0_existingDeal.Promo_End_Date__c = system.today() + 160;
            String dealPeriod = '';
            if (
                    tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE
            ) {
                Integer currentQtr =
                    Decimal.valueOf(
                        (system.today() + 140).toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = 'Q' + currentQtr;
            } else {
                Datetime sDate =
                    datetime.newInstance(
                        (system.today() + 140).year(),
                        (system.today() + 140).month(),
                        (system.today() + 140).day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
            }

            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            String strdealProductType = '';
            if (tw.lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = tw.lstProduct[i].Type__c;
            }
            d0_existingDeal.Product_Type__c = strdealProductType;
            if(d0_existingDeal.Product_Type__c!= null){
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);
        Map<Id, Opportunity> mapNewValidDealInsatnce = new Map<Id, Opportunity>(lstDealsForChangedStreetDate);

        for (Product2 prod : tw.lstProduct) {
            prod.NR_Product_Created__c = false;
            prod.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;
        System.debug('---lstDealProduct->'+lstDealProduct);

        // Add new Product and its existing Deal Product
        List<Product2> lstNewProduct = CRM_TestDataFactory.createProducts([SELECT Id FROM Product_Group__c] ,tw.lstAccounts.size(),false);
        List<Local_Title__c> lstLocaTitle = [SELECT Id FROM Local_Title__c];
        for(Integer i=0; i<lstNewProduct.size(); i++){
            lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            lstNewProduct[i].Street_Date__c = system.today()+1;
            lstNewProduct[i].NR_Product_Created__c = true;
            lstNewProduct[i].Street_Date_Has_Changed__c = false;
            lstNewProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
            lstNewProduct[i].CurrencyIsoCode = 'USD';
            
            if (i == 0) {
                lstNewProduct[i].Type__c = 'Games Physical';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstNewProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
                lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
            } else if (i == 1) {
                lstNewProduct[i].Type__c = 'Games Digital';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstNewProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            }else if (i == 2) {
                lstNewProduct[i].Type__c = 'Video Physical';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
                lstNewProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
                lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
            } else if (i == 3) {
                lstNewProduct[i].Type__c = 'Video Digital EST';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstNewProduct[i].SAP_Material_Type__c = '';
            } else if (i == 4) {
                lstNewProduct[i].Type__c = 'Video Digital VODi';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstNewProduct[i].SAP_Material_Type__c = '';
            } else {
                lstNewProduct[i].Type__c = 'Games Physical';
                lstNewProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
            }
        }
        insert lstNewProduct;
        lstNewProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 WHERE Id IN: lstNewProduct ORDER BY CreatedDate];

        List<PricebookEntry> lstNewPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstNewProduct,1,false);
        for(Integer i=0 ;i<lstNewPriceBookEntry.size();i++){
            lstNewPriceBookEntry[i].Product2Id = lstNewProduct[i].id;
        }
        insert lstNewPriceBookEntry;
        
        CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstNewPriceBookEntry, lstNewProduct);

        for (Product2 prod : lstNewProduct) {
            prod.NR_Product_Created__c = false;
            prod.Street_Date_Has_Changed__c = false;
        }
        update lstNewProduct;

        List<OpportunityLineItem> lstNewDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstNewPriceBookEntry, lstDealsForChangedStreetDate, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstNewDealProduct.size(); i++){
            lstNewDealProduct[i].OpportunityId = lstDealsForChangedStreetDate[i].Id;
            lstNewDealProduct[i].PricebookEntryId = lstNewPriceBookEntry[i].Id;
            lstNewDealProduct[i].Manually_Schedule__c = true;
            lstNewDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + lstNewProduct[i].Id;
            System.assertEquals(1, lstNewDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstNewDealProduct;
        System.debug('---lstNewDealProduct->'+lstNewDealProduct);
        
        Test.startTest();
        Map<Id, Pricebook_Entry_Period__c> mapExistingPBEPIdToInstance = new Map<Id, Pricebook_Entry_Period__c>(tw.lstPriceBookEntryPeriod);
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, 
        End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            if (mapExistingPBEPIdToInstance.containsKey(lstPBEP[i].Id)) {
                lstPBEP[i].Previous_Start_Date__c = system.today()+1;
                lstPBEP[i].Start_Date__c = system.today()+140;
                lstPBEP[i].End_Date__c = System.today() +160;
            } else {
                lstPBEP[i].Process_NR_Batch__c = false;
            }
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 WHERE ID NOT IN: lstNewProduct]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            } else {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update oppList;
        }

        // Verify 10 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify 10 deal product records present
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(10, dealProductsBeforeBatchRun.size());

        List<Product2> existingProductsForBatch = [SELECT Id FROM Product2 WHERE NR_Product_Created__c = true OR Street_Date_Has_Changed__c = true];
        System.assertEquals(3, existingProductsForBatch.size());

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id IN: tw.lstPriceBookEntryPeriod]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch, 10);
        Test.stopTest();

        // Verify additional opportunity records are not created even if valid Deal Stage is changed to Non NR Default
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName,Product_Type__c,RecordTypeId,LastModifiedDate, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());
        
        /*Integer countDigital = 0;
        for (Opportunity digitalDeal : dealsAfterBatchRun) {
            if (mapNewValidDealInsatnce.containsKey(digitalDeal.Id) && digitalDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL ) {
                if (digitalDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                    System.assertEquals(2, digitalDeal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : digitalDeal.OpportunityLineItems) {
                        System.assertEquals(digitalDeal.LastModifiedDate, dealProduct.LastModifiedDate);
                        countDigital++;
                    }
                } else {
                    System.assertEquals(3, digitalDeal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : digitalDeal.OpportunityLineItems) {
                        System.assertEquals(digitalDeal.LastModifiedDate, dealProduct.LastModifiedDate);
                        countDigital++;
                    }
                }
            }
        }
        System.assertEquals(8, countDigital);*/
        System.assertEquals(dealsBeforeBatchRun.size(), dealsAfterBatchRun.size());

        // Verify Satge Name is not changed
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
        }

        // Verify 5 existing deal Products present and from another 5 records 3 are cloned and 2 new Deal Products should be created
        Integer countRecords = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, OpportunityId, Opportunity.LastModifiedDate, Opportunity.AccountId, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(12, dealProductsAfterBatchRun.size());

        // Verify Last Modified Dates are changed
        for (OpportunityLineItem oldDealProductInstance : dealProductsBeforeBatchRun) {
            for (OpportunityLineItem newDealProductInstance : dealProductsAfterBatchRun) {
                if (
                        newDealProductInstance.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL &&
                        oldDealProductInstance.Product2Id == newDealProductInstance.Product2Id &&
                        setAccountIdAndProductId.contains(newDealProductInstance.Opportunity.AccountId  + '-' + newDealProductInstance.Product2Id)
                ) {
                    //System.assertNotEquals(oldDealProductInstance.LastModifiedDate, newDealProductInstance.LastModifiedDate);
                    //System.assertEquals(newDealProductInstance.Opportunity.LastModifiedDate, newDealProductInstance.LastModifiedDate);
                    countRecords++;
                }
            }
        }
        System.assertEquals(3, countRecords);
        
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem WHERE Id NOT IN: lstNewDealProduct]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                } else {
                    System.assertEquals(1, dealProduct.Quantity, 'Quantity = 1 as no Target found');
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
       // Test.stopTest();
        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
        
    }

    public static testMethod void Street_Date_Changed_With_Existing_Schedules_And_No_Account_Plan_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<Id,List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id,List<Account_Plan__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        Set<String> eistingDealProductUniqueKey = new Set<String>();

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        
        // Delete Account Plan and Target data
        delete [SELECT Id FROM Account_Plan__c];
        delete [SELECT Id FROM Target__c];
        System.assertEquals(0, [SELECT Id FROM Account_Plan__c].size());
        System.assertEquals(0, [SELECT Id FROM Target__c].size());

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            eistingDealProductUniqueKey.add(tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id);
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;

        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(1, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        //Setting up OpportunityLineItemSchedule Data
        for(Integer i=0 ; i< lstDealProductSchedule.size(); i++){
            lstDealProductSchedule[i].OpportunityLineItemId = lstDealProduct[i].id;
        }
        insert lstDealProductSchedule;
        
        //Setting up the target data
        /*for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;*/

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+160;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+170;
        }
        update tw.lstPriceBookEntryPeriod;

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify the Quantity is updated after creating Schedules
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(21, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deal is created even if no Account Plan present
        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');

        // Verify new Deal Product is cloned and created 
        System.assertEquals(7, [Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify no digital deal products are cloned and created. Existing manually created physical deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProducts : [Select Id,Account_Plan__c,Target_Quantity__c,OpportunityId,Manually_Schedule__c,Product2.Type__c,NR_Deal_Product_Unique_Key__c, Quantity  from OpportunityLineItem]) {
            if (dealProducts.Product2.Type__c.contains('Digital')) {
                System.assertEquals(null, dealProducts.Account_Plan__c);
                if (eistingDealProductUniqueKey.contains(dealProducts.NR_Deal_Product_Unique_Key__c)) {
                    System.assert(dealProducts.Manually_Schedule__c);
                    System.assertEquals(21, dealProducts.Quantity);
                } else {
                    System.assert(!dealProducts.Manually_Schedule__c);
                    System.assertEquals(1, dealProducts.Quantity);
                }
                System.assertEquals(0, dealProducts.Target_Quantity__c);
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(5, clonedDealProductsCount);

        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity from OpportunityLineItemSchedule];
        System.assertEquals(7, schedules.size(), '5 Deal Product Schedule for Digital and 2 existing present for Physical');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_Insert_Account_Plan_With_Non_Valid_Existing_Deal_And_No_Deal_Products_Test() {

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        // Delete existing data because the checkbox for Scenario 3 will not be checked on insert of Account Plan
        // in test Data because Scenario 1 checkbox is already check 
        List<Country_Plan__c> lstCountryPlanToDelete = [SELECT Id FROM Country_Plan__c];
        List<Account_Plan__c> lstAccountPlanPlanToDelete = [SELECT Id FROM Account_Plan__c];
        List<Target__c> lstTargetToDelete = [SELECT Id FROM Target__c];
        delete lstCountryPlanToDelete;
        delete lstAccountPlanPlanToDelete;
        delete lstTargetToDelete;

        // Change the Deal Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Opportunity deal : tw.lstOpportunity) {
            deal.CurrencyIsoCode = 'GBP';
        }
        update tw.lstOpportunity;

        // Previous Street Date changed so that no existing deal present
        for(Product2 p : tw.lstProduct){
           p.Street_Date_Has_Changed__c = false;
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;

        // Insert Account Plan for Scenario 3
        List<Target__c> lstTargets = CRM_AutoPhysicalNRDealCreateService_Test.createTargetsForNRBatch(tw.lstAccounts, tw.lstProduct, [SELECT Id FROM Product_Group__c]);

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }      

        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        // Verify existng deal Present
        System.assertEquals(5, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0, [Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(0, [SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedule].size());

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no new Deals inserted in case of Scenario 3
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');

        // Verify deal Products not inserted on Scenario 3 i.e Account Plan is inserted
        List<OpportunityLineItem> dealProducts = [Select Id,Target_Quantity__c,Initial_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate, Revenue FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ];
        System.assertEquals(0, dealProducts.size(), 'Initial Deal Products');

        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(1, schedule.Quantity);
                    System.assertEquals(20, schedule.Revenue);
                }
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(0, clonedDealProductsCount);

        // Verify Target flags are reset after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Product flags are  reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 1
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Street_Date_Changed_To_Same_Quarter_With_Existing_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        // List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
        
        Date currentdate = system.today();
        Date startDateOfCurrentDate = currentdate.toStartOfMonth();
        Date endDateOfCurrentDate = currentdate.addDays(Date.daysInMonth(currentdate.year(), currentdate.month())-1);

        Integer currentQtr =
            Decimal.valueOf(currentdate.month()).divide(3.0, 0, System.RoundingMode.UP).intValue();

        Date startDateOfQuarter = date.newInstance(currentdate.year(), ((currentQtr - 1) * 3 + 1), 1);
        Date endDateOfQuarter = startDateOfQuarter.addMonths(3) - 1;
        System.debug('--endDateOfQuarter--'+endDateOfQuarter);
        Date oldStreetDate = startDateOfQuarter.addDays(75);

        if (startDateOfCurrentDate <= oldStreetDate  &&  oldStreetDate <= endDateOfCurrentDate) {
            oldStreetDate = currentdate.addMonths(-1);
        } else {
            oldStreetDate = oldStreetDate.addMonths(-1);
        }

        for (Opportunity deal : tw.lstOpportunity) {
            deal.CloseDate = endDateOfQuarter;
            deal.Start_Date__c = startDateOfQuarter;
            deal.Promo_Start_Date__c = startDateOfQuarter;
            deal.Promo_End_Date__c = endDateOfQuarter;
        }
        update tw.lstOpportunity;

        List<Pricebook_Entry_Period__c> lstPBEP1 = [SELECT Id,Previous_Start_Date__c, Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP1.size() ; i++){
            lstPBEP1[i].Start_Date__c = oldStreetDate;
            lstPBEP1[i].End_Date__c = oldStreetDate + 10;
        }
        update lstPBEP1;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 20;
            }
        }
        insert lstDealProduct;        
        
        //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Pricebook_Entry_Period__c> lstPBEP2 = [SELECT Id,Previous_Start_Date__c, Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP2.size() ; i++){
            lstPBEP2[i].Start_Date__c = endDateOfQuarter;
            lstPBEP2[i].End_Date__c = endDateOfQuarter +10;
            lstPBEP2[i].Previous_Start_Date__c = oldStreetDate;
        }
        update lstPBEP2;

        Map<Id,Opportunity> mapIdToOpportunity = new Map<Id, Opportunity>([Select Id, Name from Opportunity]);
        System.assertEquals(5, mapIdToOpportunity.size(), 'Initial Deals');
        List<OpportunityLineItem> lstLineItem = [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem Order By OpportunityId, CreatedDate];
        System.assertEquals(5, lstLineItem.size(), 'Initial Deal Products');
        Map<Id,OpportunityLineItem> mapIdToOpportunityLineItem = new Map<Id, OpportunityLineItem>(lstLineItem );
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Description, Quantity, OpportunityLineItem.Product2.RecordTypeId, ScheduleDate FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(5, lineItemSchedules.size());
        Map<Id,OpportunityLineItemSchedule> mapIdToOpportunityLineItemSchedule = new Map<Id, OpportunityLineItemSchedule>(lineItemSchedules);

        // Verify the Quantity is update after creating Schedules
        for (OpportunityLineItem dealProducts : lstLineItem) {
            System.assert(!dealProducts.Manually_Schedule__c);
            if (dealProducts.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProducts.Quantity);
                System.assertEquals(0, dealProducts.Target_Quantity__c);
            }
        }

        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.debug('--in if11111--');
                System.assertEquals(20, schedule.Quantity);
                System.assertEquals(oldStreetDate, schedule.ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedule.Description);
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lineItems = [Select Id,OpportunityId from OpportunityLineItem];
        System.assertEquals(7, lineItems.size(), 'Initial Deal Products');
        Map<Id, OpportunityLineItem> mapIdToDealProductInsatnce = new Map<Id, OpportunityLineItem>(lineItems);
        Integer digitalDealProducts = 0;

        Integer numberDaysDifference = oldStreetDate.daysBetween(oldStreetDate);
        System.debug('---numberDaysDifference-->'+numberDaysDifference);

        Date nweStreetDate = endDateOfQuarter;
        Date newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        System.debug('--newScheduleDate-->'+newScheduleDate);
        for (OpportunityLineItem dealProduct : [Select Id, Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, Description, ScheduleDate FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assert(mapIdToOpportunityLineItem.containsKey(dealProduct.Id));
                    System.assertEquals(20, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                    //System.assertEquals(10, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(20, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, dealProduct.OpportunityLineItemSchedules[0].Description);
                    System.assert(mapIdToOpportunityLineItemSchedule.containsKey(dealProduct.OpportunityLineItemSchedules[0].Id));
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, dealProduct.OpportunityLineItemSchedules[0].Description);
                }
                digitalDealProducts++;
            }
        }

        System.assertEquals(5, digitalDealProducts);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(50, accountPlanInstance.PublishedTarget__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }
    }

    public static testMethod void Revenue_Changed_With_Street_Date_Changed_To_Same_Quarter_With_Existing_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        // List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
        
        Date currentdate = system.today();
        Date startDateOfCurrentDate = currentdate.toStartOfMonth();
        Date endDateOfCurrentDate = currentdate.addDays(Date.daysInMonth(currentdate.year(), currentdate.month())-1);

        Integer currentQtr =
            Decimal.valueOf(currentdate.month()).divide(3.0, 0, System.RoundingMode.UP).intValue();

        Date startDateOfQuarter = date.newInstance(currentdate.year(), ((currentQtr - 1) * 3 + 1), 1);
        Date endDateOfQuarter = startDateOfQuarter.addMonths(3) - 1;
        System.debug('--endDateOfQuarter--'+endDateOfQuarter);
        Date oldStreetDate = startDateOfQuarter.addDays(75);

        if (startDateOfCurrentDate <= oldStreetDate  &&  oldStreetDate <= endDateOfCurrentDate) {
            oldStreetDate = currentdate.addMonths(-1);
        } else {
            oldStreetDate = oldStreetDate.addMonths(-1);
        }

        for (Opportunity deal : tw.lstOpportunity) {
            deal.CloseDate = endDateOfQuarter;
            deal.Start_Date__c = startDateOfQuarter;
            deal.Promo_Start_Date__c = startDateOfQuarter;
            deal.Promo_End_Date__c = endDateOfQuarter;
        }
        update tw.lstOpportunity;

        List<Pricebook_Entry_Period__c> lstPBEP1 = [SELECT Id,Previous_Start_Date__c, Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP1.size() ; i++){
            lstPBEP1[i].Start_Date__c = oldStreetDate;
            lstPBEP1[i].End_Date__c = oldStreetDate + 10;
        }
        update lstPBEP1;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 20;
            }
        }
        insert lstDealProduct;        
        
        //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Pricebook_Entry_Period__c> lstPBEP2 = [SELECT Id,Previous_Start_Date__c, Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP2.size() ; i++){
            lstPBEP2[i].Start_Date__c = endDateOfQuarter;
            lstPBEP2[i].End_Date__c = endDateOfQuarter +10;
            lstPBEP2[i].Previous_Start_Date__c = oldStreetDate;
        }
        update lstPBEP2;

        Map<Id,Opportunity> mapIdToOpportunity = new Map<Id, Opportunity>([Select Id, Name from Opportunity]);
        System.assertEquals(5, mapIdToOpportunity.size(), 'Initial Deals');
        List<OpportunityLineItem> lstLineItem = [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem Order By OpportunityId, CreatedDate];
        System.assertEquals(5, lstLineItem.size(), 'Initial Deal Products');
        Map<Id,OpportunityLineItem> mapIdToOpportunityLineItem = new Map<Id, OpportunityLineItem>(lstLineItem );
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Description, Quantity, OpportunityLineItem.Product2.RecordTypeId, ScheduleDate FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(5, lineItemSchedules.size());
        Map<Id,OpportunityLineItemSchedule> mapIdToOpportunityLineItemSchedule = new Map<Id, OpportunityLineItemSchedule>(lineItemSchedules);

        // Verify the Quantity is update after creating Schedules
        for (OpportunityLineItem dealProducts : lstLineItem) {
            System.assert(!dealProducts.Manually_Schedule__c);
            if (dealProducts.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProducts.Quantity);
                System.assertEquals(0, dealProducts.Target_Quantity__c);
            }
        }

        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.debug('--in if11111--');
                System.assertEquals(20, schedule.Quantity);
                System.assertEquals(oldStreetDate, schedule.ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedule.Description);
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(200, accountPlanInstance.PublishedTarget__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 and 3');
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lineItems = [Select Id,OpportunityId from OpportunityLineItem];
        System.assertEquals(7, lineItems.size(), 'Initial Deal Products');
        Map<Id, OpportunityLineItem> mapIdToDealProductInsatnce = new Map<Id, OpportunityLineItem>(lineItems);
        Integer digitalDealProducts = 0;

        Integer numberDaysDifference = oldStreetDate.daysBetween(oldStreetDate);
        System.debug('---numberDaysDifference-->'+numberDaysDifference);

        Date nweStreetDate = endDateOfQuarter;
        Date newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        System.debug('--newScheduleDate-->'+newScheduleDate);
        for (OpportunityLineItem dealProduct : [Select Id, Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, Description, ScheduleDate FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assert(mapIdToOpportunityLineItem.containsKey(dealProduct.Id));
                    System.assertEquals(20, dealProduct.Quantity);
                    //System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(20, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, dealProduct.OpportunityLineItemSchedules[0].Description);
                    System.assert(mapIdToOpportunityLineItemSchedule.containsKey(dealProduct.OpportunityLineItemSchedules[0].Id));
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, dealProduct.OpportunityLineItemSchedules[0].Description);
                }
                digitalDealProducts++;
            }
        }

        System.assertEquals(5, digitalDealProducts);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(200, accountPlanInstance.PublishedTarget__c);
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false after batch processing');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Along_with_Scenario1_Test_1(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2,false);
        System.assertEquals(2, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        lstAccounts[1].CurrencyISOCode = 'GBP';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0], lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        List<PricebookEntry> lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry2[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry2[0].CurrencyIsoCode = 'GBP';
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry> {lstPriceBookEntry1[0], lstPriceBookEntry2[0]};
        insert lstPriceBookEntry;
        System.assertEquals(2, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodStreetDateChanged =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodStreetDateChanged[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodStreetDateChanged[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodStreetDateChanged[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodStreetDateChanged[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodStreetDateChanged[0].List_Price__c = 20;
        lstPriceBookEntryPeriodStreetDateChanged[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodStreetDateChanged;
        lstPriceBookEntryPeriodStreetDateChanged[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodStreetDateChanged;

        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_has_Changed__c = false;
        }
        update lstProduct;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodStreetDateChanged);
        System.assertEquals(1, lstOpportunity.size());

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(2, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;

        // Change the Start Date of USD PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
        }  

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
        }

        // Verify Scenario 2 should be considered
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Before running Batch inserte NEW PBEP for GBP Account
        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreated[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 160;
        lstPriceBookEntryPeriodCreated[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreated[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreated[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreated;

        // Verify Scenario 2 should checked as Scenario 2 is given Priority an sScenario 1 is not checked
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deal is created for Scenario 1 and 2 and existing deal Product is cloned and created for USD Deal
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, (SELECT Id, Quantity, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(3, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsAfterBatchRun.size());

        for (Opportunity deal : dealsAfterBatchRun) {
            if (deal.Id == dealsBeforeBatchRun[0].Id) {
                System.assertEquals(0, deal.OpportunityLineItems.size());
                System.assertEquals(deal.AccountId, lstAccountUSD[0].Id);
            } else {
                
                if (deal.AccountId == lstAccountUSD[0].Id) {
                    System.assertEquals(1, deal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                        System.assertEquals(10, dealProduct.Target_Quantity__c);
                        System.assertEquals(20, dealProduct.Replen_Quantity__c);
                        System.assertEquals(15, dealProduct.P_L_Quantity__c);
                    }
                } else {
                    System.assertEquals(1, deal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                        System.assertEquals(10, dealProduct.Target_Quantity__c);
                        System.assertEquals(0, dealProduct.Replen_Quantity__c);
                        System.assertEquals(null, dealProduct.P_L_Quantity__c);
                    }
                }
            }   
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Along_with_Scenario1_Test_2(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2,false);
        System.assertEquals(2, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        lstAccounts[1].CurrencyISOCode = 'GBP';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0], lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        List<PricebookEntry> lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry2[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry2[0].CurrencyIsoCode = 'GBP';
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry> {lstPriceBookEntry1[0], lstPriceBookEntry2[0]};
        insert lstPriceBookEntry;
        System.assertEquals(2, lstPriceBookEntry.size());
        System.assertEquals(2, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodStreetDateChanged =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodStreetDateChanged[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodStreetDateChanged[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodStreetDateChanged[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodStreetDateChanged[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodStreetDateChanged[0].List_Price__c = 20;
        lstPriceBookEntryPeriodStreetDateChanged[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodStreetDateChanged;
        lstPriceBookEntryPeriodStreetDateChanged[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodStreetDateChanged;

        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_has_Changed__c = false;
        }
        update lstProduct;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodStreetDateChanged);
        System.assertEquals(1, lstOpportunity.size());

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(2, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        
        // Before running Batch inserte NEW PBEP for GBP Account
        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreated[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 160;
        lstPriceBookEntryPeriodCreated[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreated[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreated[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreated;

        // Verify Scenario 1 is checked true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodCreated[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // After New GBP PBEP is inserted Change the Start Date of USD PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
        }

        // Verify Scenario 2 should be considered and Scenario 1 flag is reset as Priority is given to Scenario 2
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deal is created for Scenario 1 and 2 and existing deal Product is cloned and created for USD Deal
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, (SELECT Id, Quantity, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(3, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsAfterBatchRun.size());

        for (Opportunity deal : dealsAfterBatchRun) {
            if (deal.Id == dealsBeforeBatchRun[0].Id) {
                System.assertEquals(0, deal.OpportunityLineItems.size());
                System.assertEquals(deal.AccountId, lstAccountUSD[0].Id);
            } else {
                
                if (deal.AccountId == lstAccountUSD[0].Id) {
                    System.assertEquals(1, deal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                        System.assertEquals(10, dealProduct.Target_Quantity__c);
                        System.assertEquals(20, dealProduct.Replen_Quantity__c);
                        System.assertEquals(15, dealProduct.P_L_Quantity__c);
                    }
                } else {
                    System.assertEquals(1, deal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                        System.assertEquals(10, dealProduct.Target_Quantity__c);
                        System.assertEquals(0, dealProduct.Replen_Quantity__c);
                        System.assertEquals(null, dealProduct.P_L_Quantity__c);
                    }
                }
            }   
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

        /**
     * Product - Type : Games Digital
     * 2 Accounts - USD & GBP with Games Digital checkbox as true
     * 1 Auto NR USD Deal1 and Deal Product1 for USD Account linked with USD PBEP    
     * 2 PBEPS changes before Batch Runs
     *      1. USD PBEP : NR = true & Deal and Deal Product already present -> now the Street Date is Changed
     *      2. GBP PBEP : NR = false present -> now PBEP is updated to true
     * Result
     *    - Product : Street Date Has Changed check box should be true even when the 2nd GBP PBEP
     *                is acting as newly inserted (As Priority is always given to Street Date has Changed)
     *    - USD Deal2 is created and Deal Product1 from USD Deal1 is moved to USD Deal2
     *    - GBP Deal 1 is created along with Deal Product1 
     */
    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Along_with_Scenario1_Update_Test_1(){
    
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2,false);
        System.assertEquals(2, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        lstAccounts[1].CurrencyISOCode = 'GBP';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0], lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        List<PricebookEntry> lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry2[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry2[0].CurrencyIsoCode = 'GBP';
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry> {lstPriceBookEntry1[0], lstPriceBookEntry2[0]};
        insert lstPriceBookEntry;
        System.assertEquals(2, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodStreetDateChanged =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodStreetDateChanged[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodStreetDateChanged[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodStreetDateChanged[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodStreetDateChanged[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodStreetDateChanged[0].List_Price__c = 20;
        lstPriceBookEntryPeriodStreetDateChanged[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodStreetDateChanged;
        lstPriceBookEntryPeriodStreetDateChanged[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodStreetDateChanged;

        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_has_Changed__c = false;
        }
        update lstProduct;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodStreetDateChanged);
        System.assertEquals(1, lstOpportunity.size());

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(2, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;

        // Change the Start Date of USD PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        // Verify Scenario 2 should be considered
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
        }  

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
        }


        // Before running Batch insert NEW PBEP for GBP Account
        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreated[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 160;
        lstPriceBookEntryPeriodCreated[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreated[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreated[0].New_Release__c = false;
        insert lstPriceBookEntryPeriodCreated;

        // Verify Process NR Batch checkbox is not checked as NR = false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodCreated[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        // Make NR = true for GBP PBEP so that it should be considered as Scenario 1
        lstPriceBookEntryPeriodCreated[0].New_Release__c = true;
        update lstPriceBookEntryPeriodCreated;

        // Verify Scenario 2 should checked as Scenario 2 is given Priority and Scenario 1 is not checked
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked for both PBEPs
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deal is created for Scenario 1 and 2 and existing deal Product is cloned and created for USD Deal
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, (SELECT Id, Quantity, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(3, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsAfterBatchRun.size());
        Integer dealProductsCount = 0;

        for (Opportunity deal : dealsAfterBatchRun) {
            if (deal.Id == dealsBeforeBatchRun[0].Id) {
                System.assertEquals(0, deal.OpportunityLineItems.size());
                System.assertEquals(deal.AccountId, lstAccountUSD[0].Id);
            } else {
                if (deal.AccountId == lstAccountUSD[0].Id) {
                    dealProductsCount++;
                    System.assertEquals(1, deal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                        System.assertEquals(10, dealProduct.Target_Quantity__c);
                        System.assertEquals(20, dealProduct.Replen_Quantity__c);
                        System.assertEquals(15, dealProduct.P_L_Quantity__c);
                    }
                } else {
                    dealProductsCount++;
                    System.assertEquals(1, deal.OpportunityLineItems.size());
                    for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                        System.assertEquals(10, dealProduct.Target_Quantity__c);
                        System.assertEquals(0, dealProduct.Replen_Quantity__c);
                        System.assertEquals(null, dealProduct.P_L_Quantity__c);
                    }
                }
            }   
        }
        System.assertEquals(2, dealProductsCount);

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    /**
     * Product - Type : Games Digital
     * 2 Accounts - USD & GBP with Games Digital checkbox as true
     * 1 Auto NR USD Deal1 and Deal Product1 for USD Account linked with USD PBEP    
     * 2 PBEPS changes before Batch Runs
     *      1. USD PBEP : NR = true & Deal and Deal Product already present -> NO Change in this
     *      2. GBP PBEP : NR = false present -> now PBEP is updated to true
     * Result
     *    - Product : NR Product Created check box should be true as PBEP 2 (with GBP) will now act as Newly inserted
     *    - No Change in USD Deal1 and its Deal Product1 
     *    - GBP Deal 1 is created along with Deal Product1 
     */
    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Along_with_Scenario1_Update_Test_2(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2,false);
        System.assertEquals(2, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        lstAccounts[1].CurrencyISOCode = 'GBP';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0], lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        List<PricebookEntry> lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry2[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry2[0].CurrencyIsoCode = 'GBP';
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry> {lstPriceBookEntry1[0], lstPriceBookEntry2[0]};
        insert lstPriceBookEntry;
        System.assertEquals(2, lstPriceBookEntry.size());
        System.assertEquals(2, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodStreetDateChanged =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodStreetDateChanged[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodStreetDateChanged[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodStreetDateChanged[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodStreetDateChanged[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodStreetDateChanged[0].List_Price__c = 20;
        lstPriceBookEntryPeriodStreetDateChanged[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodStreetDateChanged;
        lstPriceBookEntryPeriodStreetDateChanged[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodStreetDateChanged;

        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_has_Changed__c = false;
        }
        update lstProduct;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodStreetDateChanged);
        System.assertEquals(1, lstOpportunity.size());

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(2, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());

        
        // Before running Batch insert NEW PBEP for GBP Account with NR = false and later it becomes NR = true
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreated[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 160;
        lstPriceBookEntryPeriodCreated[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreated[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreated[0].New_Release__c = false;
        insert lstPriceBookEntryPeriodCreated;

        // Verify Scenario 1 is not checked as true as NR = false
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is not checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodCreated[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        // After New GBP PBEP is inserted update NR = true
        lstPriceBookEntryPeriodCreated[0].New_Release__c = true;
        update lstPriceBookEntryPeriodCreated;
        System.debug('lstPriceBookEntryPeriodCreated::'+lstPriceBookEntryPeriodCreated);

        
        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c  WHERE Id =: lstPriceBookEntryPeriodCreated[0].Id]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
        }

        // Verify Scenario 1 should be considered as GBP PBEP has been updated to NR = true and now should be considered to act as Newly inserted 
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deal is created for Scenario 1
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, (SELECT Id, Quantity, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(2, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsAfterBatchRun.size());
        Integer dealProductsCount = 0;

        for (Opportunity deal : dealsAfterBatchRun) {
            if (deal.Id == dealsBeforeBatchRun[0].Id) {
                dealProductsCount++;
                System.assertEquals(1, deal.OpportunityLineItems.size());
                System.assertEquals(deal.AccountId, lstAccountUSD[0].Id);
                // Existing deal Product is as it is but Target Quantity is recalculated
                for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    System.assertEquals(20, dealProduct.Replen_Quantity__c);
                    System.assertEquals(15, dealProduct.P_L_Quantity__c);
                }
            } else {
                dealProductsCount++;
                System.assertEquals(1, deal.OpportunityLineItems.size());
                for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    System.assertEquals(0, dealProduct.Replen_Quantity__c);
                    System.assertEquals(null, dealProduct.P_L_Quantity__c);
                }
            }   
        }
        System.assertEquals(2, dealProductsCount);

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    /**
     * Product - Type : Games Digital
     * 2 Accounts - USD & GBP with Games Digital checkbox as true
     * 2 PBEPS changes before Batch Runs
     *      1. USD PBEP : NR = true -> Newly inserted
     *      2. GBP PBEP : NR = false present -> now PBEP is updated to true and Its Start Date is changed
     * Result
     *    - Product : Street Date Has Changed check box should be true even when the 1st and 2nd PBEP
     *                is acting as newly inserted but 2nd GBP PBEP Street Date is Changed (As Priority is always given to Street Date has Changed)
     *    - New USD Deal 1 is created along with Deal Product1
     *    - New GBP Deal 1 is created along with Deal Product1 
     */
    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Along_with_Scenario1_Updated_Test_3(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2,false);
        System.assertEquals(2, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        lstAccounts[1].CurrencyISOCode = 'GBP';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0], lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        List<PricebookEntry> lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry2[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry2[0].CurrencyIsoCode = 'GBP';
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry> {lstPriceBookEntry1[0], lstPriceBookEntry2[0]};
        insert lstPriceBookEntry;
        System.assertEquals(2, lstPriceBookEntry.size());
        System.assertEquals(2, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 20;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(2, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());
        
        // Before running Batch insert NEW PBEP for GBP Account with NR = false
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 2;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 40;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = false;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodCreatedPBEP2[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        // After New GBP PBEP is inserted Change the Start Date of GBP PBEP and make NR = true
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 160;
        update lstPriceBookEntryPeriodCreatedPBEP2;
        System.debug('lstPriceBookEntryPeriodCreatedPBEP2::'+lstPriceBookEntryPeriodCreatedPBEP2);

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodCreatedPBEP2[0].Id]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
        }

        // Verify Scenario 2 should be considered and Scenario 1 flag is reset as Priority is given to Scenario 2 because PBEP 2 (With GBP) has changed its Start Date
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deal is created for Scenario 1 and 2 
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, (SELECT Id, Quantity, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(2, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsAfterBatchRun.size());

        for (Opportunity deal : dealsAfterBatchRun) {
            if (deal.AccountId == lstAccountUSD[0].Id) {
                System.assertEquals(1, deal.OpportunityLineItems.size());
                for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    System.assertEquals(0, dealProduct.Replen_Quantity__c);
                    System.assertEquals(null, dealProduct.P_L_Quantity__c);
                }
            } else {
                System.assertEquals(1, deal.OpportunityLineItems.size());
                for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    System.assertEquals(0, dealProduct.Replen_Quantity__c);
                    System.assertEquals(null, dealProduct.P_L_Quantity__c);
                }
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    /**
     * Product - Type : Games Digital
     * 2 Accounts - USD & GBP with Games Digital checkbox as true
     * 1 Auto NR USD Deal1 and Deal Product1 for USD Account linked with USD PBEP  
     * 1 Auto NR GBP Deal1 and Deal Product1 for GBP Account linked with GBP PBEP    
     * 2 PBEPS changes before Batch Runs
     *      1. USD PBEP : NR = true & Deal and Deal Product already present -> No Change in this
     *      2. GBP PBEP : NR = false present -> now PBEP is updated to true and Its Start Date is changed
     * Result
     *    - Product : Street Date Has Changed check box should be true even when the 2nd GBP PBEP
     *                is acting as newly inserted but is Street Date is Changed (As Priority is always given to Street Date has Changed)
     *    - No Change in USD Deal1 and its Deal Product1
     *    - GBP Deal 2 is created and Deal Product 1 from Deal 1 is moved to newly created Deal 2
     */
    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Along_with_Scenario1_Updated_Test_4(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);
        System.assertEquals(2, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        lstAccounts[1].CurrencyISOCode = 'GBP';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0], lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        List<PricebookEntry> lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry2[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry2[0].CurrencyIsoCode = 'GBP';
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry> {lstPriceBookEntry1[0], lstPriceBookEntry2[0]};
        insert lstPriceBookEntry;
        System.assertEquals(2, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodStreetDateChanged =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodStreetDateChanged[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodStreetDateChanged[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodStreetDateChanged[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodStreetDateChanged[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodStreetDateChanged[0].List_Price__c = 20;
        lstPriceBookEntryPeriodStreetDateChanged[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodStreetDateChanged;
        lstPriceBookEntryPeriodStreetDateChanged[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodStreetDateChanged;

        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_has_Changed__c = false;
        }
        update lstProduct;

        // Verify Process NR Batch checkbox is not checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodStreetDateChanged[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Account> lstAccountGBP = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'GBP' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(
                CRM_TestDataFactory.createOpportunitiesWithAccounts(
                    new List<Account>{lstAccountUSD[0], lstAccountGBP[0]}, 1, false
                ),
                new List<Account>{lstAccountUSD[0], lstAccountGBP[0]},
                new List<Product2>{lstProduct[0], lstProduct[0]},
                lstPriceBookEntryPeriodStreetDateChanged
            );
        System.assertEquals(2, lstOpportunity.size());

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(2, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Setting up 1 Price Book Entry Period for GBP Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreated[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 2;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 40;
        lstPriceBookEntryPeriodCreated[0].CurrencyIsoCode = 'GBP';
        lstPriceBookEntryPeriodCreated[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreated[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreated;

        // Verify Target flags are reset properly after batch processing
        List<Account_Plan__c> lstAccountPlanToUpdate = [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]; 
        for (Account_Plan__c accountPlanInstance : lstAccountPlanToUpdate) {
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlanToUpdate;

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodCreated[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, Account.CurrencyISOCode FROM Opportunity];
        System.assertEquals(2, dealsBeforeBatchRun.size());
        Opportunity oppUSD = new Opportunity();
        Opportunity oppGBP = new Opportunity();
        for (Opportunity opp : dealsBeforeBatchRun) {
            if (opp.Account.CurrencyISOCode == 'USD') {
                oppUSD = opp;
                oppUSD.CurrencyISOCode = 'USD';
            } else if (opp.Account.CurrencyISOCode == 'GBP') {
                oppGBP = opp;
                oppGBP.CurrencyISOCode = 'GBP';
            }
        }
        update new List<Opportunity>{oppUSD,oppGBP};

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            if (lstDealProduct[i].OpportunityId == oppUSD.Id) {
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[0].Id;
                lstDealProduct[i].PricebookEntryId = lstPriceBookEntry1[0].Id;
            } else {
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountGBP[0].Id + '-' + lstProduct[0].Id;
                lstDealProduct[i].PricebookEntryId = lstPriceBookEntry2[0].Id;
            }
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;

        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, LastModifiedDate FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsBeforeBatchRun.size());

        // GBP PBEP became Catalog
        lstPriceBookEntryPeriodCreated[0].New_Release__c = false;
        // Make this field false because as Scenario 1 is already Processed and deal n deal Product created by batch.
        lstPriceBookEntryPeriodCreated[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodCreated;

        // Reset the flags because Batch is run properly for GBP PBEP insert
        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_has_Changed__c = false;
        }
        update lstProduct;

        // Verify Scenario and 2 not checked
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is not checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodCreated[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        // Before Batch runs Change the Start Date of GBP PBEP and make NR = true
        lstPriceBookEntryPeriodCreated[0].New_Release__c = true;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 240;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 360;
        lstPriceBookEntryPeriodCreated[0].Previous_Start_Date__c = System.today() + 2;
        update lstPriceBookEntryPeriodCreated;
        System.debug('lstPriceBookEntryPeriodCreated::'+lstPriceBookEntryPeriodCreated);

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodCreated[0].Id]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
        }

        // Verify Scenario 2 should be considered and Scenario 1 flag is reset as Priority is given to Scenario 2 because PBEP 2 (With GBP) has changed its Start Date
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deal is created for Scenario 2 and existing deal Product is cloned and created for GBP newly created Deal
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, (SELECT Id, Quantity, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(3, dealsAfterBatchRun.size());
        Map<Id, OpportunityLineItem> mapOfDealProductsAfterBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id,LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(2, mapOfDealProductsAfterBatchRun.size());

        Integer countDealProducts = 0;
        for (Opportunity deal : dealsAfterBatchRun) {
            if (deal.AccountId == lstAccountUSD[0].Id && deal.Id == oppUSD.Id) {
                System.assertEquals(1, deal.OpportunityLineItems.size());
                countDealProducts++;
                for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                    System.assertEquals(20, dealProduct.Target_Quantity__c);
                    System.assertEquals(20, dealProduct.Replen_Quantity__c);
                    System.assertEquals(15, dealProduct.P_L_Quantity__c);
                }
            } else if (deal.AccountId == lstAccountGBP[0].Id && deal.Id == oppGBP.Id) {
                // Verify Deal Product deleted from old Deal
                System.assertEquals(0, deal.OpportunityLineItems.size());
            } else if (deal.AccountId == lstAccountGBP[0].Id && deal.Id != oppGBP.Id && deal.Id != oppUSD.Id) {
                System.assertEquals(1, deal.OpportunityLineItems.size());
                countDealProducts++;
                for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    System.assertEquals(20, dealProduct.Replen_Quantity__c);
                    System.assertEquals(15, dealProduct.P_L_Quantity__c);
                }
            }   
        }
        System.assertEquals(2, countDealProducts);

        // Verify existing USD Deal Product not modified
        Integer existingNonModifiedDealProductCount = 0;
        for (OpportunityLineItem dealProduct : dealProductsBeforeBatchRun) {
            if (mapOfDealProductsAfterBatchRun.containsKey(dealProduct.Id)) {
                System.assertEquals(dealProduct.LastModifiedDate, mapOfDealProductsAfterBatchRun.get(dealProduct.Id).LastModifiedDate);
                existingNonModifiedDealProductCount++;
            }
        }
        System.assertEquals(1, existingNonModifiedDealProductCount);

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Scenario3_And_4_With_No_Existing_Deal_And_Deal_Product_Present_Test(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());
        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        lstAccounts[0].Games_Digital__c = true;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Video_Digital__c = false;
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        insert lstAccounts[0];
        Account soldToAccountGD = lstAccounts[0];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the code will try to search the PriceBookEntryPeriod Start lies between the  Deal Start Date and End Date
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreated[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreated[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreated[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreated[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreated;

        List<Product2> fetchedProducts = [SELECT Id,NR_Product_Created__c, Street_Date_Has_Changed__c FROM  Product2];
        System.assertEquals(1, fetchedProducts.size());

        fetchedProducts[0].NR_Product_Created__c = false;
        fetchedProducts[0].Street_Date_Has_Changed__c = false;
        update fetchedProducts;

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriodCreated) {
            pbep.Process_NR_Batch__c = false;
        }
        update lstPriceBookEntryPeriodCreated;

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesDigital.Target__c = 200;
        //t0_GamesDigital.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
        }  

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            System.assertEquals(20, pbep.List_Price__c);
        }

        // Change the List price of PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c];
        for(Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.List_Price__c = 10;
            pbep.Start_Date__c = system.today()+140;
            pbep.End_Date__c = System.today() +160;
        }
        update lstPBEP;

        List<Product2> fetchedProducts_2 = [SELECT Id,NR_Product_Created__c, Street_Date_Has_Changed__c FROM  Product2];
        System.assertEquals(1, fetchedProducts_2.size());

        fetchedProducts_2[0].NR_Product_Created__c = false;
        fetchedProducts_2[0].Street_Date_Has_Changed__c = false;
        update fetchedProducts_2;

        // Verify Process NR Batch checkbox is checked and List Price is also changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            System.assertEquals(10, pbep.List_Price__c);
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify one deal and deal product created for Scenario 4 - PBEP insert
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Scenario4_With_Existing_DealsInAccount_But_No_Valid_Deal_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        //Setting up Product Data to false as for scenario 4 both these checboxes are false 
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        // Verify 5 opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());
        
        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            d0_existingDeal.AccountId = tw.lstAccounts[i].Id;
            d0_existingDeal.Start_Date__c = system.today() - 140;
            d0_existingDeal.CloseDate = system.today() - 120;
            d0_existingDeal.Promo_Start_Date__c = system.today() - 140;
            d0_existingDeal.Promo_End_Date__c = system.today() - 120;
        }
        update tw.lstOpportunity;

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify There is no Senario 1 OR 2 condition
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            System.assertEquals(20, pbep.List_Price__c);
        }

        // Verify Target flags are set as false such that there is no Scenario 3 condition
        for (Account_Plan__c accountPlanInstance :  [SELECT Id, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Targets changed should be false');
        }

        // Change the List price of PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c];
        for(Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.List_Price__c = 10;
        }
        update lstPBEP;

        // Verify Process NR Batch checkbox is checked and List Price is also changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            System.assertEquals(10, pbep.List_Price__c);
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 3 additional opportunity records created for Digital Products
        System.assertEquals(8, [Select Id, Name from Opportunity].size(), 'New Deals');

        // Verify 5 deal product records for 3 digital products should be created through batch
        // 2 Product have same Type so 2 deals have 2 Products
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5, dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c, Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(20.00, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                }
                digitalDealProducts++;
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Updated Account Price');
            }
        }
        System.assertEquals(5, digitalDealProducts);

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c,Product__r.RecordTypeId FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_After_Future_PBEP_With_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() - 130;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());

        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        
        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    }
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset 
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  
        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no new Deal is created nor modified
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, LastModifiedDate, (SELECT Id, LastModifiedDate, Quantity, Pricebook_Entry_Period__c, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());

        for (Opportunity deal : dealsAfterBatchRun) {
            System.assert(dealsBeforeBatchRun.containsKey(deal.Id));
            System.assertEquals(dealsBeforeBatchRun.get(deal.Id).LastModifiedDate, deal.LastModifiedDate);
            System.assertEquals(lstAccountUSD[0].Id, deal.AccountId);
            System.assertEquals(1, deal.OpportunityLineItems.size());
            for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                System.assert(dealProductsBeforeBatchRun.containsKey(dealProduct.Id));
                System.assertEquals(dealProductsBeforeBatchRun.get(dealProduct.Id).LastModifiedDate, dealProduct.LastModifiedDate);
                System.assertEquals(20, dealProduct.Target_Quantity__c);
                System.assertEquals(20, dealProduct.Replen_Quantity__c);
                System.assertEquals(15, dealProduct.P_L_Quantity__c);
                System.assertEquals(lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id, dealProduct.Pricebook_Entry_Period__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_But_Before_Future_PBEP_Without_Existing_Deal_And_DP(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());
         // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 135;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 145;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;
        
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());
        
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c,Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                } else {
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                }
            }
        }

        // Verify Scenario 1 is checked as true
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deal is created for Scenario 1
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, (SELECT Id,Pricebook_Entry_Period__c, Quantity, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());

        for (Opportunity deal : dealsAfterBatchRun) {
            System.assertEquals(lstAccountUSD[0].Id, deal.AccountId);
            System.assertEquals(1, deal.OpportunityLineItems.size());
            for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(0, dealProduct.Replen_Quantity__c);
                System.assertEquals(null, dealProduct.P_L_Quantity__c);
                System.assertEquals(lstPriceBookEntryPeriodCreatedPBEP2[0].Id, dealProduct.Pricebook_Entry_Period__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }

    public static testMethod void Multiple_PBEP_Inserted_With_Future_Date_After_Backdated_PBEP_With_Existing_Deal_And_DP_With_Scenario3(){
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);
        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();
        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Digital
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Games_Digital__c = true;
            lstAccounts[i].Games_Physical__c = false;
            lstAccounts[i].Video_Digital__c = false;
            lstAccounts[i].Video_Physical__c = false;
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
        }
        lstAccounts[0].CurrencyISOCode = 'USD';
        insert lstAccounts;

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        // Set Up 1 Games Digital Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() - 130;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;

        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, new List<Country_Plan__c>{lstCountryPlan[0]}, lstAccounts, true);

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        lstPriceBookEntry1[0].Product2Id = p0_GamesDigital.Id;
        lstPriceBookEntry1[0].CurrencyIsoCode = 'USD';
        insert lstPriceBookEntry1;
        System.assertEquals(1, lstPriceBookEntry1.size());

        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() - 130;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() - 120;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Process_NR_Batch__c = false;
        update lstPriceBookEntryPeriodNewlyInsertedPBEP1;

        List<Account> lstAccountUSD = [SELECT Id, Sales_Organization__c, Digital_Country_Code__c FROM Account WHERE CurrencyISOCode = 'USD' AND Storefront__c != null];
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccountUSD ,1,false), lstAccountUSD, lstProduct, lstPriceBookEntryPeriodNewlyInsertedPBEP1);
        System.assertEquals(1, lstOpportunity.size());
        for (Opportunity opp : lstOpportunity) {
            opp.Promo_Start_Date__c = system.today() - 130;
            opp.Promo_End_Date__c = system.today() - 120;
            opp.Start_Date__c = system.today() - 130;
            opp.CloseDate = system.today() - 120;
        }
        update lstOpportunity;

        // Verify Process NR Batch checkbox is not checked and isDuplicate is false
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id =: lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
            }
        }

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        for (Integer i=0; i<lstTargets.size(); i++) {
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = p0_GamesDigital.id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target__c = 200;
        }
        insert lstTargets;

        // Verify Scenario 1 is checked as false
        List<Product2> lstExistingProductUpdate = [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2];
        for(Product2 p : lstExistingProductUpdate){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                p.Street_Date_Has_Changed__c = false;
                p.NR_Product_Created__c = false;
            }
        }
        update lstExistingProductUpdate;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'USD'], lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccountUSD[0].Id + '-' + lstProduct[i].Id;
            lstDealProduct[i].Target_Quantity__c = 20;
            lstDealProduct[i].Replen_Quantity__c = 20;
            lstDealProduct[i].P_L_Quantity__c = 15;
            lstDealProduct[i].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;
        
        Map<Id,Opportunity> dealsBeforeBatchRun = new Map<Id,Opportunity>([SELECT Id, LastModifiedDate FROM Opportunity]);
        System.assertEquals(1, dealsBeforeBatchRun.size());
        Map<Id, OpportunityLineItem> dealProductsBeforeBatchRun = new Map<Id, OpportunityLineItem>([SELECT Id, LastModifiedDate FROM OpportunityLineItem]);
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        
        // Before running Batch insert NEW PBEP for USD Account with different Date Range
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreatedPBEP2 =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreatedPBEP2[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreatedPBEP2[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreatedPBEP2[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreatedPBEP2[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreatedPBEP2[0].List_Price__c = 20;
        lstPriceBookEntryPeriodCreatedPBEP2[0].New_Release__c = true;
        insert lstPriceBookEntryPeriodCreatedPBEP2;

        // Verify Process NR Batch checkbox is not checked and this PBEP is marked as duplicate
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (pbep.Id == lstPriceBookEntryPeriodCreatedPBEP2[0].Id) {
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                    System.assert(pbep.isDuplicate__c, 'IsDuplicate should be true');
                } else {
                    System.assert(!pbep.isDuplicate__c, 'IsDuplicate should be false');
                    System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                }
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set 
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no new Deal is created nor modified
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, AccountId, LastModifiedDate, (SELECT Id, LastModifiedDate, Quantity, Pricebook_Entry_Period__c, Target_Quantity__c, P_L_Quantity__c, Replen_Quantity__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());

        for (Opportunity deal : dealsAfterBatchRun) {
            System.assert(dealsBeforeBatchRun.containsKey(deal.Id));
            System.assertEquals(dealsBeforeBatchRun.get(deal.Id).LastModifiedDate, deal.LastModifiedDate);
            System.assertEquals(lstAccountUSD[0].Id, deal.AccountId);
            System.assertEquals(1, deal.OpportunityLineItems.size());
            for (OpportunityLineItem dealProduct : deal.OpportunityLineItems) {
                System.assert(dealProductsBeforeBatchRun.containsKey(dealProduct.Id));
                System.assertEquals(dealProductsBeforeBatchRun.get(dealProduct.Id).LastModifiedDate, dealProduct.LastModifiedDate);
                System.assertEquals(20, dealProduct.Target_Quantity__c);
                System.assertEquals(20, dealProduct.Replen_Quantity__c);
                System.assertEquals(15, dealProduct.P_L_Quantity__c);
                System.assertEquals(lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id, dealProduct.Pricebook_Entry_Period__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Revenue_Has_Changed__c, Country_Plan__r.NR_Product__r.RecordTypeId FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }  

        // Verify Product flags are reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }
}