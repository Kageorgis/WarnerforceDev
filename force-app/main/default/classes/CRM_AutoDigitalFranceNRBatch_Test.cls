/**
   @Author Aditi Satpute
   @name CRM_AutoDigitalFranceNRBatch_Test
   @CreateDate 20 July 2016
   @Description Test class for CRM_AutoDigitalNRDealCreationBatch
   @Version <1.0>
   @reference Requirement no 274
 */
@isTest
public with sharing class CRM_AutoDigitalFranceNRBatch_Test {

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
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 3 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products but in this case for those
        // Products and Account no valid Account Plan is found so no deal Product is created
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Promoted_Price__c, SAP_Promoted_Price__c, Account_Plan__c, Opportunity.AccountId, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            System.assertEquals(20, dealProduct.Promoted_Price__c);
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
            System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Replen Quantity');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            }else {
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(55, dealProduct.Replen_Quantity__c);
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue, OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else if (schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            }else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

 /*   public static testMethod void Scenario1_With_Existing_Committed_Deal_And_Target_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 3 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products but in this case for those
        // Products and Account no valid Account Plan is found so no deal Product is created
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            // System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Replen Quantity');
            // System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            }else {
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(55, dealProduct.Replen_Quantity__c);
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
            
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue, OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else if (schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            }else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

  /*  public static testMethod void Scenario1_With_Existing_Approved_Deal_And_Target_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 3 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products but in this case for those
        // Products and Account no valid Account Plan is found so no deal Product is created
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            // System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Replen Quantity');
            // System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            } else {
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(55, dealProduct.Replen_Quantity__c);
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
            
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue, OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else if (schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
*/
    public static testMethod void Scenario1_Without_Existing_Deal_And_Target_Test(){
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Change the Sales Org of Account so that Opportunity Can be deleted
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        update tw.lstAccounts;*/

        // Delete existing deals so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
            } else if (acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE;
            }
        }
        update tw.lstAccounts;


        // Verify No valid opportunity records present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 3 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products but in this case for those
        // Products and Account no valid Account Plan is found so no deal Product is created
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            // System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Replen Quantity');
            // System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
            } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
            } else {
                if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                    System.assertEquals(55, dealProduct.Replen_Quantity__c);
                    System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                    System.assertEquals(55, dealProduct.Replen_Quantity__c);
                    System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
                }
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue, OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else if (schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else if (schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
       for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario1_With_Existing_Deal_And_No_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Account Plan present 
        System.assertEquals(5, [SELECT Id FROM Account_Plan__c].size());

        // Remove Targets to check deal Products created with Target Quantity on Account Plan
        List<Target__c> lstTargets = [SELECT Id FROM Target__c];
        delete lstTargets;

        // Verify no targets present
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

        // Verify 1 deal product records for 1 non Benelux digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products but in this case for those
        // Products and Account no valid Account Plan is found so no deal Product is created
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Digital_Country_Code__c, Account_Price__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            // System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Replen Quantity');
            // System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            System.assertEquals(55, dealProduct.Quantity, 'Quantity should be 1');
            System.assert(!CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) && dealProduct.Opportunity.Account.Digital_Country_Code__c != CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE);
            if (!CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                /*System.debug('--in if-->');
                System.assertEquals(1, dealProduct.Target_Quantity__c, 'Target Quantity should be 1 as no target present');
            } else {*/
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
            System.assertEquals(55, dealProduct.Replen_Quantity__c);
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(1, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(55, schedule.Quantity);
            System.assertEquals(1100, schedule.Revenue);
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario1_With_Existing_Deal_And_No_Target_Quantity_In_Account_Plan_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        List<Country_Plan__c> lstCountryPlan = [SELECT Id, Target_Quantity__c, Stretch_Target__c FROM Country_Plan__c];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = null;
            cp.Stretch_Target__c = null;
        }
        update lstCountryPlan;

        // Verify Account Plan present 
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Target_Quantity__c, Share__c FROM Account_Plan__c];
        for (Account_Plan__c ap : lstAccountPlan) {
            ap.Share__c = null;
        }
        update lstAccountPlan;
        System.assertEquals(5, lstAccountPlan.size());

        List<Account> lstAccount = [SELECT Id FROM Account WHERE Digital_Country_Code__c NOT IN: CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES AND  Digital_Country_Code__c != :CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE];

        // Remove Targets for FR to check deal Products created with Target Quantity on Account Plan
        List<Target__c> lstTargets = [SELECT Id FROM Target__c WHERE Account__c IN: lstAccount];
        delete lstTargets;

        if (CRM_AppConstants.BENELUX_SALES_ORGS.size() > 0) {
            // Verify targets present
            System.assertEquals(2, [SELECT Id from Target__c].size());
        } else {
            // Verify no targets present
            System.assertEquals(0, [SELECT Id from Target__c].size());
        }

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
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

        // Verify 3 deal product records for 3 Digital products should be created through batch
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Initial_Quantity__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan.Published Target / Deal Product.Account Price');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(3, dealProduct.Replen_Quantity__c, 'Replen Quantity = 0 as default value');
            } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan.Published Target / Deal Product.Account Price');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be sae as replen Quantity');
                System.assertEquals(3, dealProduct.Replen_Quantity__c, 'Replen Quantity = 0 as default value');
            } else {
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Target Quantity = 0 as No Target Quantity in Account Plan');
                System.assertEquals(1, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(0, dealProduct.Replen_Quantity__c, 'Replen Quantity = 0 as default value');
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue, OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else if (schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(0, schedule.Revenue);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario1_Without_Existing_Deal_And_No_Account_Plan_And_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Change the Sales Org of Account so that Opportunity Can be deleted
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        update tw.lstAccounts;*/

        // Delete existing deals so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        // After deleting opportunities again make the Sales Org as Germany
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        }
        update tw.lstAccounts;*/

        // Verify No valid opportunity records present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Remove Targets present for calculation so Deal Products not created
        List<Account_Plan__c> lstExistingAccountPlan = [SELECT Id FROM Account_Plan__c];
        delete lstExistingAccountPlan;

        List<Target__c> lstTargets = [SELECT Id FROM Target__c];
        delete lstTargets;

        // Verify no targets present
        System.assertEquals(0, [SELECT Id from Account_Plan__c].size());
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

        // Verify no new deal is created as no Account Plan present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records created through batch as no Account Plan present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Test(){

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

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
            String dealPeriod = '';
            if (
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
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

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Initial_Quantity__c,Promoted_Price__c, SAP_Promoted_Price__c, Account_Plan__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Account_Price__c, OpportunityId,Target_Quantity__c, Quantity, Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(20, dealProduct.Promoted_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                // Verify these deal products are linked with new deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

  /*  public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Planned_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // 3 additional deals created for Digital Products
        System.assertEquals(8, [SELECT Id FROM Opportunity].size());

        // Verify deal Products are cloned even if the deal Stage is not NR Default and existing deal products deleted
        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Initial_Quantity__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Quantity should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity should not be recalculated as Manually Schedule = true');
                // Verify deals products are now not related to existing deals as these are cloned and attached to new deal
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Schedules not created as Manually Schedule = true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
*/
    /*public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Approved_Future_Deal_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());
        
        
        // Change the Account Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Account acc : tw.lstAccounts) {
            acc.CurrencyIsoCode = 'GBP';
        }
        system.runAs(createUser()) {
            update tw.lstAccounts;
        }

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

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
            lstPBEP[i].Start_Date__c = system.today()+240;
            lstPBEP[i].End_Date__c = System.today() +260;
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // No additional deals created as no valid PBEP found
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }


        // Verify deal Products are not cloned and not modified even if deal Stage is non NR Default
        Integer countDigital = 0;
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                countDigital++;
            }
        }
        System.assertEquals(3, countDigital);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

  /*  public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Approved_Non_Future_Deal_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());
        
        
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

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // No additional deals created as no valid PBEP found
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify deal Products are not cloned and not modified even if deal Stage is non NR Default
        Integer countDigital = 0;
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                countDigital++;
            }
        }
        System.assertEquals(3, countDigital);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

    public static testMethod void Scenario2_With_Existing_Deal_With_Stage_Changed_And_Deal_Product_To_Be_Cloned_Present_Test(){

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

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
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
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

        // Verify n5 valid opportunity records present
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

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        System.assertEquals(10, [SELECT Id FROM Opportunity].size());

        /// Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        Integer countDigital = 0;
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Initial_Quantity__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                countDigital ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(3, countDigital);

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

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

  /*  public static testMethod void Scenario2_With_Existing_Deal_With_Stage_Committed_And_Deal_Product_To_Be_Cloned_Present_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

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
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
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

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify Satge Name is not changed
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
        }

        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        Integer countDigital = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsAfterBatchRun.size());

        // Verify Last Modified Dates are changed
        for (Integer j = 0; j < dealProductsAfterBatchRun.size(); j++) {
            OpportunityLineItem newDealProductInstance = dealProductsAfterBatchRun[j];
            OpportunityLineItem oldDealProductInstance = dealProductsBeforeBatchRun[j];
            if (newDealProductInstance.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertNotEquals(oldDealProductInstance.LastModifiedDate, newDealProductInstance.LastModifiedDate);
            }
       }

        for (OpportunityLineItem dealProduct : [SELECT Id, Replen_Quantity__c, Initial_Quantity__c,Opportunity.Account.Digital_Country_Code__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                countDigital ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(3, countDigital);

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
*/
  /*  public static testMethod void Scenario2_With_Existing_Deal_With_Stage_Approved_And_Deal_Product_To_Be_Cloned_Present_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

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
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
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

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        Integer countDigital = 0;
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Replen_Quantity__c, Opportunity.Account.Digital_Country_Code__c,Initial_Quantity__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                countDigital ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(3, countDigital);

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

  /*  public static testMethod void Scenario2_With_Existing_Deal_And_No_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity deal = tw.lstOpportunity[i];
            String dealPeriod = '';
            if (
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
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
            deal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
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

        // Verify 5 valid opportunity records present
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // 3 digital products should be Cloned and created through batch
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Replen_Quantity__c, Initial_Quantity__c, Opportunity.Account.Digital_Country_Code__c, Account_Price__c, Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(3, dealProduct.Replen_Quantity__c);
                    System.assertEquals(3, dealProduct.Quantity, 'Should be same as Target Quantity');
                } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(3, dealProduct.Replen_Quantity__c);
                    System.assertEquals(3, dealProduct.Quantity, 'Should be same as Target Quantity');
                }else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                    System.assertEquals(55, dealProduct.Replen_Quantity__c);
                    System.assertEquals(55, dealProduct.Quantity, 'Should be same as Target Quantity for FR');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue, OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else if (schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            }else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
*/
    public static testMethod void Scenario2_With_No_Existing_Deal_But_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
            } else if (acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE;
            }
        }
        update tw.lstAccounts;

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

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Replen_Quantity__c, Initial_Quantity__c, Opportunity.Account.Digital_Country_Code__c, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)|| dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');

                // Verify these deal products are linked with new deals different based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_No_Existing_Deal_And_No_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();
        
        for(Product2 p : tw.lstProduct){
            p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;

        // Change the Sales Org of Account so that Opportunity Can be deleted
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        update tw.lstAccounts;*/

        delete tw.lstOpportunity;

        // After deleting opportunities again make the Sales Org as Germany
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        }
        update tw.lstAccounts;*/

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

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // 3 digital products should be created through batch
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Replen_Quantity__c, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            // System.assertEquals(55, dealProduct.Quantity, 'Should be same as Initial Quantity');
            // System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Quantity = Account Plan.Target Quantity');
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Should be same as Target Quantity');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Should be same as Target Quantity');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            } else {
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Replen_Quantity__c);
                System.assertEquals(55, dealProduct.Quantity);
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue, OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else if (schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_With_Existing_Deal_And_Deal_Product_Present_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

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
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlan) {
            accountPlan.Share__c = 40;
        }
        update lstAccountPlan;

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
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 4
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
        for (OpportunityLineItem dealProduct : [Select Id, Account_Plan__c, SAP_Promoted_Price__c, Promoted_Price__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20.00, dealProduct.Promoted_Price__c);
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void Scenario3_With_No_Existing_Deal_And_Deal_Product_Present_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

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
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
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
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0]; 

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

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesDigital.Target__c = 50;
        t0_GamesDigital.Target_Units__c = 2.5;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(90, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify deal and deal products are created for Scenario 3 in case of France
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Opportunity.Account.Digital_Country_Code__c,Quantity, Replen_Quantity__c, Target_Quantity__c,Initial_Quantity__c, (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            // System.assertEquals(90, dealProduct.Quantity);
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
                System.assertEquals(3, dealProduct.Quantity);
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(3, schedule.Quantity);
                    System.assertEquals(60, schedule.Revenue);
                }
            } else {
                System.assertEquals(90, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(90, dealProduct.Replen_Quantity__c);
                System.assertEquals(90, dealProduct.Quantity);
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(90, schedule.Quantity);
                    System.assertEquals(1800, schedule.Revenue);
                }
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c);
            /*for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(90, schedule.Quantity);
                System.assertEquals(1800, schedule.Revenue);
            }*/
            
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void Scenario3_And_Scenario4_With_Existing_Deal_And_Deal_Product_Present_And_List_Price_Changed_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

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

        //Setting up the Scenario 3 data
        List<Country_Plan__c> lstCountryPlan = [SELECT Id, Target_Quantity__c FROM Country_PLan__c ORDER BY CreatedDate];
        for(Integer i=0 ; i< lstCountryPlan.size() ; i++){
            lstCountryPlan[i].Target_Quantity__c = 800;
        }
        update lstCountryPlan;
        System.assertEquals(5, lstCountryPlan.size(), 'Updated Country Plan');

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

        // Verify There is no Senario 1 OR 2 condition
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assertEquals(20, pbep.List_Price__c);
            }
        }

        // Verify Target flags are set as true such that there is Scenario 3 condition
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(88, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Change the List price of PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c];
        for(Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.List_Price__c = 10;
        }
        update lstPBEP;

        // Verify Process NR Batch checkbox is checked and List Price is also changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c,Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assertEquals(10, pbep.List_Price__c);
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
        for (OpportunityLineItem dealProduct : [Select Id,Replen_Quantity__c, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Updated Account Price');
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(20, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(88, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Target flags are reset properly after batch processing
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

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
        /*for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;*/

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
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
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assertEquals(20, pbep.List_Price__c);
            }
        }

        // Verify Target flags are set as false such that there is no Scenario 3 condition
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlanInstance : lstAccountPlan) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Change the List price of PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c];
        for(Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.List_Price__c = 10;
        }
        update lstPBEP;

        // Verify Process NR Batch checkbox is checked and List Price is also changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c,Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assertEquals(10, pbep.List_Price__c);
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
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Initial_Quantity__c,Target_Quantity__c, Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Updated Account Price');
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(5, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Account Plan flags are reset even after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void NR_Product_Creation_With_No_Deal_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        
        
        // Change the Account Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Account acc : tw.lstAccounts) {
            acc.CurrencyIsoCode = 'GBP';
        }
        system.runAs(createUser()) {
            update tw.lstAccounts;
        }
        
        // Delete existing deals so that no existing NR deals present in database
        delete tw.lstOpportunity;

        Map<Id,List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id,List<Account_Plan__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+10;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c, 'Should be true as Scenario1');
            }
        }

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is checked as Scenario 1
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
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Map<Id,List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id,List<Account_Plan__c>>();
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify no new Deal Product is cloned and modified as no valid pbep found
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify no digital deal products are cloned and created. Existing manually created physical deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c,Product2.Type__c,NR_Deal_Product_Unique_Key__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            if (dealProducts.Product2.Type__c.contains('Digital')) {
                System.assertEquals(21, dealProducts.Quantity);
                System.assertEquals(0, dealProducts.Target_Quantity__c);
                /*if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProducts.Opportunity.Account.Digital_Country_Code__c)) {
                    System.assertEquals(3, dealProducts.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(10, dealProducts.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }*/
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity from OpportunityLineItemSchedule];
        System.assertEquals(5, schedules.size(), 'Schedules as it is');

        // Verify Target flags are reset even after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
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

        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        // Setting up the Scenario 3 data
        List<Country_Plan__c> lstCountryPlan = [SELECT Id, Target_Quantity__c FROM Country_PLan__c ORDER BY CreatedDate];
        for(Integer i=0 ; i< lstCountryPlan.size() ; i++){
            lstCountryPlan[i].Target_Quantity__c = 800;
        }
        update lstCountryPlan;
        System.assertEquals(5, lstCountryPlan.size(), 'Updated Country Plan');

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c, Account_Price__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
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

        // Verify Target flags are set as true such that there is Scenario 3 condition
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(88, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR  flags are reset as we are checking only Scenario 3 when all Scenario 1, 2 ,4 are already executed
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
        for (OpportunityLineItem dealProduct : [Select Id,Initial_Quantity__c,Replen_Quantity__c, Target_Quantity__c, Account_Price__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                //System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        // Verify Schedules not created as Manually_Schedule__c = true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(88, accountPlanInstance.Target_Quantity__c);
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(200, targetInstance.Target__c);
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
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

        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        // Setting up the Scenario 3 data
        List<Country_Plan__c> lstCountryPlan = [SELECT Id, Target_Quantity__c, Stretch_Target__c FROM Country_Plan__c];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;

        // Create PricebookEntryPeriod which is not valid for the Product
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+140;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+160;
            tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'GBP';
        }
        update tw.lstPriceBookEntryPeriod;

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
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(90, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR  flags are set as we are checking  Scenario 3 along with Scenario 2
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

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void PBEP_List_Price_Changed_With_Existing_Deal_And_Deal_Product_And_No_Valid_PBEP_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();
        
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

        /*for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');*/
        // Setting up the Scenario 3 data
        List<Country_Plan__c> lstCountryPlan = [SELECT Id, Target_Quantity__c, Stretch_Target__c FROM Country_Plan__c];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;

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

        // Verify Target flags are reset as we are checking only Scenario 4 when all Scenario 1, 2 ,3 are already executed
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlanInstance : lstAccountPlan) {
            System.assertEquals(90, accountPlanInstance.Target_Quantity__c);
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;

        // Create PricebookEntryPeriod which is not valid for the Product
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].List_Price__c = 10;
            tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'GBP';
        }
        update tw.lstPriceBookEntryPeriod;

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is checked as List Price of PBEP is changed
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

        // Verify Schedules not created as Manually_Schedule__c = true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void Negative_Test_SendMail_With_RecordId() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        for(Product2 p : tw.lstProduct){
            List<String> lstErrors = new List<String>();
            lstErrors.add('Temporary Error1');
            lstErrors.add('Temporary Error2');
            automaticNRDealCreationBatch.lstExceptions.add(new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(p.Id,lstErrors));
        }
        Database.executeBatch(automaticNRDealCreationBatch, 10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify deal product records present
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Target flags are reset properly after batch processing
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c, 'True as there is error');
            }
        }

        // Verify checkbox is checked due to error
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }
    }

    public static testMethod void Negative_Test_SendMail_Without_RecordId() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        for(Product2 p : tw.lstProduct){
            List<String> lstErrors = new List<String>();
            lstErrors.add('Temporary Error1');
            lstErrors.add('Temporary Error2');
            automaticNRDealCreationBatch.lstExceptions.add(new CRM_AutoPhysicalNRDealCreationService.CRM_AutoPhysicalNRDealCreationServiceException(null,lstErrors));
        }
        Database.executeBatch(automaticNRDealCreationBatch, 10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify deal product records present
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Target flags are reset properly after batch processing
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c, 'False as there is no record Id present in error');
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Negative_Test_ResetProcessedProductFlags() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        for(Product2 p : tw.lstProduct){
            automaticNRDealCreationBatch.setProcessedProductIds.add(p.Id);
            p.CurrencyIsoCode = null;
        }

        System.assert(automaticNRDealCreationBatch.setProcessedProductIds.size() > 0);
        System.assert(automaticNRDealCreationBatch.lstExceptions.isEmpty());

        Test.startTest();
        automaticNRDealCreationBatch.resetProcessedProductFlags(tw.lstProduct, automaticNRDealCreationBatch.setProcessedProductIds);
        test.stopTest();

        System.assertEquals(0, automaticNRDealCreationBatch.setProcessedProductIds.size());
        System.assert(!automaticNRDealCreationBatch.lstExceptions.isEmpty());
    }

    /*public static testMethod void Negative_Test_ResetProcessedAccountPlanFlags() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Country_Plan__c, Country_Plan__r.NR_Product__c FROM Account_Plan__c];
        System.assertEquals(5, lstAccountPlan.size());

        for(Account_Plan__c accPlan : lstAccountPlan){
            automaticNRDealCreationBatch.setProcessedProductIds.add(accPlan.Country_Plan__r.NR_Product__c);
            accPlan.Country_Plan__c = null;
        }

        System.assert(automaticNRDealCreationBatch.setProcessedProductIds.size() > 0);
        System.assert(automaticNRDealCreationBatch.lstExceptions.isEmpty());

        Test.startTest();
        automaticNRDealCreationBatch.resetProcessedAccountPlanFlags(lstAccountPlan, automaticNRDealCreationBatch.setProcessedProductIds);
        test.stopTest();

        System.assertEquals(0, automaticNRDealCreationBatch.setProcessedProductIds.size());
        System.assert(!automaticNRDealCreationBatch.lstExceptions.isEmpty());
    }*/

    public static testMethod void Negative_Test_ResetProcessedPBEPFlags() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Country_Plan__c FROM Account_Plan__c];
        System.assertEquals(5, lstAccountPlan.size());

        for(Pricebook_Entry_Period__c pbep : tw.lstPricebookEntryPeriod){
            pbep.CurrencyIsoCode = 'ABC';
        }

        System.assert(automaticNRDealCreationBatch.lstExceptions.isEmpty());

        Test.startTest();
        automaticNRDealCreationBatch.resetProcessedPBEPFlags(tw.lstPricebookEntryPeriod);
        test.stopTest();

        System.assert(!automaticNRDealCreationBatch.lstExceptions.isEmpty());
    }

    
    /*public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario_2_And_3_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        // Previous Street Date not Specified
        for(Product2 p : tw.lstProduct){
           p.Street_Date_Has_Changed__c = false;
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

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlan) {
            accountPlan.Share__c = 40;
        }
        update lstAccountPlan;

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
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(21, schedule.Quantity);
            System.assertEquals(system.today(), schedule.ScheduleDate);
        }

        // Verify the Quantity is updated after creating Schedules
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(21, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c, 'Should be true as Scenario 2 & 3');
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__r.NR_Product__r.RecordTypeId,  Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        //System.assertEquals(5, automaticNRDealCreationBatch.lstExceptions.size());
        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Replen_Quantity__c, Initial_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');

                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        // Verify Target flags are not reset after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
            }
        }

        // Verify Product flags are not reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c, 'True as there is error');
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
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        // Previous Street Date not Specified
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
        
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlan) {
            accountPlan.Share__c = 40;
        }
        update lstAccountPlan;

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
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(21, schedule.Quantity);
            System.assertEquals(system.today(), schedule.ScheduleDate);
        }

        // Verify the Quantity is updated after creating Schedules
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(21, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c, 'Should be true as Scenario 2 & 3');
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
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
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItemSchedule].size(), 'Digital Schedules deleted');

        // Verify Target flags are not reset after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
            }
        }

        // Verify Flags are not reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Integer clonedDealProductsCount = 0;
        List<OpportunityLineItem> lstDealProducts = [Select Id,Initial_Quantity__c,Replen_Quantity__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ];
        System.assertEquals(5, lstDealProducts.size(), 'Initial Deal Products');

        for (OpportunityLineItem dealProduct : lstDealProducts) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                //System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // No new deal / Deal Product is created
        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario2_With_Batch_ReRun_Test(){

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        // Previous Street Date not Specified
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
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(21, schedule.Quantity);
            System.assertEquals(system.today(), schedule.ScheduleDate);
        }

        // Verify the Quantity is update after creating Schedules
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(21, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        // Verify There is only Scenario 2
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // As we are checking only Scenario 4 so make Target Revenue flag as false
        // Verify Target flags are set as false such that there is no Scenario 3 condition
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlanInstance : lstAccountPlan) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch1.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed, productAndAccountIdSet , mapIdToPBEPInstance, setProcessedProductIds );

        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItemSchedule].size(), 'Digital Schedules deleted');

        // Verify Target flags are reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Initial_Quantity__c, Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // No new deal / Deal Product is created
        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify Target flags are reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

        /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP )
           2. Deals -> D0 -> For A0 -> (GP, Start Date = System.Today())
           3. Deal Product -> D0 (DP0 with P0 batch created having unique Key)
      2. Product ->
           1. P0 (GP, Street Date = System.today() + 40) -> Valid Target with Revenue Changed to 100
      3. Run Batch -> Result
           1. While batch is Running ->  Change Product P0 Street Date to System.today() + 140 and Valid Target with Revenue Changed to 200
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

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Setting Up the Sold To Account Data with 'Games Digital Type'
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(1);
        System.assertEquals(1, lstAccounts.size());

        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Games_Digital__c = true;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
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
           //p.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;

        // Setting up 1 Target data for each Account and Product created
        List<Account_Plan__c> lstAccountPlan1 = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp, lstAccountPlan1, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 100;
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = lstProduct[i].id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE;
        } 
        insert lstTargets;
        System.debug('lstTargets::'+lstTargets);

        // Create a List of Target data before updating the target because the batch will run with these Target
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
        System.assertEquals(1, [Select Id, NR_Version__c from Account_Plan__c][0].NR_Version__c);
        System.assertEquals(lstAccountPlan[0].NR_Version__c, [Select Id, NR_Version__c from Account_Plan__c][0].NR_Version__c);

        System.assertEquals(1, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lstLineItemsWithSchedules = [Select Id,OpportunityId, (Select Id,OpportunityLineItemId from OpportunityLineItemSchedules)  from OpportunityLineItem];
        System.assertEquals(1, lstLineItemsWithSchedules.size(), 'Initial Deal Products');
        System.assertEquals(0, lstLineItemsWithSchedules[0].OpportunityLineItemSchedules.size(), 'Initial Deal Product Schedule');
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
        Datetime sDate =
                datetime.newInstance(
                    (lstProduct[0].Street_Date__c).year(),
                    (lstProduct[0].Street_Date__c).month(),
                    (lstProduct[0].Street_Date__c).day()
                );
        String currentMonth = sDate.format('MMM');
        List<Opportunity> fetchedDealsWithLatest = [Select Id, Name, NR_Deal_Unique_Key__c from Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(2, fetchedDealsWithLatest.size(), 'New Deals');
        System.debug('-fetchedDealsWithLatest--->'+fetchedDealsWithLatest);
        Opportunity newlyCreatedOpportunity = new Opportunity();
        for (Opportunity deal : fetchedDealsWithLatest) {
            if (deal.NR_Deal_Unique_Key__c != null && deal.Id != lstOpportunity[0].Id) {
                 newlyCreatedOpportunity = deal;
                 System.assertEquals('New Releases Games Digital '+currentMonth+' '+(system.today() + 40).year()+' ' + soldToAccount.Name, deal.Name);
            }
        }

        // Deal Product is cloned and attached to new deal thats why the count of Deal Products is still one
        // Verify the records created with previous StreetDate / Revenue change even if the
        // Street Date / Target Revenue was changed while batch was running
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId,Target_Quantity__c,Quantity, Opportunity.Name, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(1, dealProducts.size(), 'New Deal Products');
        System.assertEquals(1, dealProducts[0].Quantity);
        System.assertEquals(55, dealProducts[0].Target_Quantity__c);
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

        List<Account_Plan__c> lstAccountPlanToUpdate = [SELECT Id,NR_Version__c, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlanToUpdate) {
            accountPlan.Share__c = 40;
            System.assertEquals(0, accountPlan.NR_Version__c);
        }
        update lstAccountPlanToUpdate;
        System.assertEquals(1, lstAccountPlanToUpdate.size());
        List<Account_Plan__c> lstAccountPlanAfterUpdate = [Select Id, NR_Version__c, Target_Revenue_Has_Changed__c from Account_Plan__c];
        System.assertEquals(1, lstAccountPlanAfterUpdate[0].NR_Version__c);
        //System.assertNotEquals(lstAccountPlan[0].NR_Version__c, lstAccountPlanAfterUpdate[0].NR_Version__c);

        // As Version was changed Verify the Checkboxes (StreetDate changed and Target Revenue Changed) is still true even
        // when the batch was processed successfully
        System.assertEquals(true, [Select Id, Street_Date_Has_Changed__c from Product2][0].Street_Date_Has_Changed__c);
        System.assertEquals(true, lstAccountPlanAfterUpdate[0].Target_Revenue_Has_Changed__c);
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
        Datetime sDate1 =
                datetime.newInstance(
                    (updatedPBEP[0].Start_Date__c).year(),
                    (updatedPBEP[0].Start_Date__c).month(),
                    (updatedPBEP[0].Start_Date__c).day()
                );
        String currentMonth1 = sDate1.format('MMM');
        List<Opportunity> fetchedDealsWithLatest1 = [Select Id, Name, (Select Id,Quantity, Target_Quantity__c,OpportunityId, Opportunity.Name, Opportunity.Product_Type__c from OpportunityLineItems) from Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(3, fetchedDealsWithLatest1.size(), 'New Deals');
        System.assertEquals('New Releases Games Digital '+currentMonth1+' '+(system.today() + 140).year()+' ' + soldToAccount.Name, fetchedDealsWithLatest1[0].Name);

        // Deal Product is cloned and attached to new deal with updated Quantity thats why the count is still one
        // Verify the deal Product is cloned to the deal with changed StreetDate and updated with Quantity calculated based on Target Revenue
        // which was changed while batch was running previously
        List<OpportunityLineItem> fetchedDealProducts = fetchedDealsWithLatest1[0].OpportunityLineItems;
        System.assertEquals(1, fetchedDealProducts.size(), 'New Deal Products');
        System.assertEquals(fetchedDealsWithLatest1[0].Id, fetchedDealProducts[0].OpportunityId);
        System.assertEquals(1, fetchedDealProducts[0].Quantity);
        System.assertEquals(220, fetchedDealProducts[0].Target_Quantity__c);

        // Verify the Version and the checkboxes has been reset
        System.assertEquals(false, [Select Id, Street_Date_Has_Changed__c from Product2][0].Street_Date_Has_Changed__c);
        List<Account_Plan__c> lstAccountPlanAfterBatchRun = [Select Id, NR_Version__c, Target_Revenue_Has_Changed__c from Account_Plan__c];
        System.assertEquals(false, lstAccountPlanAfterBatchRun[0].Target_Revenue_Has_Changed__c);
        System.assertEquals(0, lstAccountPlanAfterBatchRun[0].NR_Version__c);
 
         // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
        }
    }*/

   /* public static testMethod void Scenario1_With_Existing_Multiple_Stage_Deal_And_Target_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        // Update Accounts to make all as Physical
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
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
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
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
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
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
            // Change the Sales Org of Account so that Opportunity Can be deleted
            /*for (Account acc : tw.lstAccounts) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            }
            update tw.lstAccounts;*/

            // Delete existing deals so that no existing NR deals present in database
             //List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            // delete oppList;

            // After deleting opportunities again make the Sales Org as Germany
            /*for (Account acc : tw.lstAccounts) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            }
            update tw.lstAccounts;*/

          //  oppList = CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
         //   System.assertEquals(5, oppList.size());

       /*     oppList[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 5 deal digital product records should be created through batch
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            //System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Replen Quantity');
            // System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
            } else {
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(55, dealProduct.Replen_Quantity__c);
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id,OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c) || schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
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

        // Verify flags reset properly
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }
    }
*/
   /* public static testMethod void Scenario2_With_Existing_Deal_With_Multiple_Stage_And_Deal_Product_To_Be_Cloned_Present_Test(){

        Set<String> setAccountIdAndProductId = new Set<String>();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        // Update Accounts to make all as Physical
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
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
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
            setAccountIdAndProductId.add(accountPlanInstance.Customer__c + '-' + accountPlanInstance.Country_Plan__r.NR_Product__c);
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify only 5 deal Products will be created as Account Plan is present only for 5 Products and Account combination
        Integer countDigital = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsAfterBatchRun.size());

        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Opportunity.Account.Digital_Country_Code__c,Replen_Quantity__c,Initial_Quantity__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(20, dealProduct.Account_Price__c);
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                    if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                        System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    } else {
                        System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                    }
                    System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                    //System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                    countDigital ++;
                }
            }
        }
        System.assertEquals(5, countDigital);

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }
    }
*/
  /*  public static testMethod void Scenario2_With_Existing_Deal_Having_DP_With_Stage_Committed_And_Deal_Product_To_Be_Cloned_Present_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

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
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
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
            //lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            if (i == 0) {
                lstNewProduct[i].Type__c = 'Games Physical';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (i == 1) {
                lstNewProduct[i].Type__c = 'Games Digital';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }else if (i == 2) {
                lstNewProduct[i].Type__c = 'Video Physical';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
                lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
                lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }
        }
        insert lstNewProduct;
        Test.startTest();
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
            }
        }

        List<Product2> existingProductsForBatch = [SELECT Id FROM Product2 WHERE NR_Product_Created__c = true OR Street_Date_Has_Changed__c = true];
        System.assertEquals(3, existingProductsForBatch.size());

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.addAll(tw.lstOpportunity);
            oppList.addAll(lstDealsForChangedStreetDate);
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update oppList;
        }

        // Verify 10 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItems ORDER BY Product2.RecordTypeId, CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        // Verify 10 deal product records present
        List<OpportunityLineItem> dealProductsBeforeBatchRun = new List<OpportunityLineItem>();

        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
            for (OpportunityLineItem item : dealInsatnce.OpportunityLineItems) {
                dealProductsBeforeBatchRun.add(item);
            }
        }
        System.assertEquals(10, dealProductsBeforeBatchRun.size());

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is checked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c WHERE Id IN: tw.lstPriceBookEntryPeriod]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify additional opportunity records are not created even if valid Deal Stage is changed to Non NR Default
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName,Product_Type__c,RecordTypeId,LastModifiedDate, (SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItems ORDER BY Product2.RecordTypeId, CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());

        System.assertEquals(dealsBeforeBatchRun.size(), dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = new List<OpportunityLineItem>();

        // Verify Satge Name is not changed
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
            for (OpportunityLineItem item : newDealInsatnce.OpportunityLineItems) {
                dealProductsAfterBatchRun.add(item);
            }
        }

        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        Integer countDigital = 0;
        System.assertEquals(10, dealProductsAfterBatchRun.size());

        // Verify Last Modified Dates are changed
        Integer countRecords = 0;
        for (Integer j = 0; j < dealProductsAfterBatchRun.size(); j++) {
            OpportunityLineItem newDealProductInstance = dealProductsAfterBatchRun[j];
            if (newDealProductInstance.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                //System.assertNotEquals(oldDealProductInstance.LastModifiedDate, newDealProductInstance.LastModifiedDate);
                countRecords++;
            }
        }
        System.assertEquals(6, countRecords);

        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Opportunity.Account.Digital_Country_Code__c,Replen_Quantity__c, OpportunityId,Initial_Quantity__c,  Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem WHERE Id NOT IN: lstNewDealProduct]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                //System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                countDigital ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(3, countDigital);

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
*/
    
     
    public static testMethod void Scenario2_And_3_With_Existing_Deal_And_Deal_Products_With_Updated_Initial_Quanitity_Test(){
		
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
          
        Test.startTest(); 
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Target_Quantity__c = 10;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            // Initial Quantity updated so it different from Target Quantity
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 15;
            }
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

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlan) {
            accountPlan.Share__c = 40;
        }
        update lstAccountPlan;

        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');
        System.assertEquals(5, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5, [Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(5, [Select Id, Quantity, Revenue  from OpportunityLineItemSchedule].size(), 'Initial Deal Products');

        for (OpportunityLineItem dealProduct : [Select (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules), Replen_Quantity__c, Id, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(15, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(15, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                for (OpportunityLineItemSchedule sch : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(15, sch.Quantity);
                    System.assertEquals(300, sch.Revenue);
                }
            }
        }

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__r.NR_Product__r.RecordTypeId,Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10); 
        Test.stopTest(); 
        System.assertEquals(8, [Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5, dealProducts.size(), 'New Deal Products');

        // Verify Schedules are not updated as Initial Quantity is not updated
        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Opportunity.Account.Digital_Country_Code__c, (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules), Id,Replen_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(15, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(15, dealProduct.Replen_Quantity__c, 'Not Updated as manually Updated');
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(15, schedule.Quantity);
                    System.assertEquals(300, schedule.Revenue);
                }
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

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    } 
    
    public static testMethod void Scenario2_And_3_With_Existing_Deal_And_Deal_Products_Without_Updated_Initial_Quanitity_Test(){
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();
		
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct; 
        
        Test.startTest();
        
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Target_Quantity__c = 10;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            // Initial Quantity not updated so it same as Target Quantity
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 1;
            }
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

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlan) {
            accountPlan.Share__c = 40;
        }
        update lstAccountPlan;

        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');
        System.assertEquals(5, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5, [Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(5, [Select Id, Quantity, Revenue  from OpportunityLineItemSchedule].size(), 'Initial Deal Products');

        for (OpportunityLineItem dealProduct : [Select (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules), Replen_Quantity__c, Initial_Quantity__c, Id, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(1, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                for (OpportunityLineItemSchedule sch : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(1, sch.Quantity);
                    System.assertEquals(20, sch.Revenue);
                }
            }
        }

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }
        
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        
        Test.stopTest();
		
        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        // Verify Schedules are not updated as Replen Quantity is not updated
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Opportunity.Account.Digital_Country_Code__c, (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules), Id,Replen_Quantity__c, Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Default 1');
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(1, schedule.Quantity);
                    System.assertEquals(20, schedule.Revenue);
                }
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

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    
 }

    public static testMethod void Scenario3_Insert_Account_Plan_Without_Existing_Deal_And_Deal_Products_Test() {

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;

        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Digital__c = true;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Video_Digital__c = false;
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
        insert lstAccounts[0];
        Account soldToAccountGP = lstAccounts[0];

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

        // Set Up 1 Games Physical Product data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
        System.assertEquals(1, lstProduct.size());
        Product2 p0_GamesDigital = lstProduct[0];
        p0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        p0_GamesDigital.Street_Date__c = System.today() + 1;
        p0_GamesDigital.CurrencyIsoCode = 'USD';
        p0_GamesDigital.Type__c = 'Games Digital';
        p0_GamesDigital.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        p0_GamesDigital.Local_Title__c = lstLocaTitle[0].Id;
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0]; 

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodCreated
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        Pricebook_Entry_Period__c existingDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        existingDealPriceBookPeriod.Product__c = p0_GamesDigital.id;
        existingDealPriceBookPeriod.Start_Date__c = System.today()-40;
        existingDealPriceBookPeriod.End_Date__c = System.today()-40;
        existingDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        existingDealPriceBookPeriod.List_Price__c = 10;
        existingDealPriceBookPeriod.New_Release__c = true;

        lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        Pricebook_Entry_Period__c streetDateChangeCurrentMonthDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        streetDateChangeCurrentMonthDealPriceBookPeriod.Product__c = p0_GamesDigital.id;
        streetDateChangeCurrentMonthDealPriceBookPeriod.Start_Date__c = System.today() + 1;
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+30;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;
        streetDateChangeCurrentMonthDealPriceBookPeriod.New_Release__c = true;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update lstPriceBookEntryPeriod;

        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
        }
        update lstProduct;

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is un checked as Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());

        // Verify 1 deal product records for 1 digital products should be created through batch
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Initial_Quantity__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
                System.assertEquals(3, dealProduct.Replen_Quantity__c, 'Default should be same as Target Quantity');
            } else {
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
                System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Default should be same as Target Quantity');
            }
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(1, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c) || schedule.OpportunityLineItem.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_Insert_Account_Plan_With_Existing_Deal_And_No_Deal_Products_Test() {

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
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
        delete lstCountryPlanToDelete;
        delete lstAccountPlanPlanToDelete;

        // Previous Street Date not Specified
        for(Product2 p : tw.lstProduct){
           p.Street_Date_Has_Changed__c = false;
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;

        // Insert Account Plan for Scenario 3
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,tw.lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
            cp.Stretch_Target__c = 10;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, tw.lstAccounts, false);
        for (Account_Plan__c accountPlanInsatnce : lstAccountPlan) {
            accountPlanInsatnce.Share__c = 10;
        }
        insert lstAccountPlan;
        System.assertEquals(5, lstAccountPlan.size());

        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(tw.lstAccounts , [SELECT Id FROM Product_Group__c] , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 50;
            lstTargets[i].Target_Units__c = 2.5;
            lstTargets[i].Account__c = tw.lstAccounts[i].Id;
            lstTargets[i].Product__c = tw.lstProduct[i].id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        } 
        insert lstTargets;

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
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId,  Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no new Deals inserted
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');

        // Verify deal Products inserted on Scenario 3 i.e Account Plan is inserted after deal is created
        List<OpportunityLineItem> dealProducts = [Select Id,Opportunity.Account.Digital_Country_Code__c,Target_Quantity__c,Replen_Quantity__c,Initial_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate, Revenue FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ];
        System.assertEquals(3, dealProducts.size(), 'Initial Deal Products');

        // Verify 3 digital deal products created.
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(3, dealProduct.Replen_Quantity__c, 'Should be same as Target Quantity');
                    System.assertEquals(3, dealProduct.Quantity);
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(3, schedule.Quantity);
                        System.assertEquals(60, schedule.Revenue);
                    }
                } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(3, dealProduct.Replen_Quantity__c, 'Should be same as Target Quantity');
                    System.assertEquals(3, dealProduct.Quantity);
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(3, schedule.Quantity);
                        System.assertEquals(60, schedule.Revenue);
                    }
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                    System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Should be same as Target Quantity');
                    System.assertEquals(55, dealProduct.Quantity);
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(55, schedule.Quantity);
                        System.assertEquals(1100, schedule.Revenue);
                    }
                }
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        // Verify Target flags are reset after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
            }
        }

        // Verify Product flags are  reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 1
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
   
    public static testMethod void Scenario3_Insert_Account_Plan_With_Existing_Deal_And_Deal_Products_Test() {
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
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
        delete lstCountryPlanToDelete;
        delete lstAccountPlanPlanToDelete;
 
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
        
        Test.startTest();
        
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Target_Quantity__c = 10;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Insert Account Plan for Scenario 3
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,tw.lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
            cp.Stretch_Target__c = 10;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, tw.lstAccounts, false);
        for (Account_Plan__c accountPlanInsatnce : lstAccountPlan) {
            accountPlanInsatnce.Share__c = 10;
        }
        insert lstAccountPlan;
        System.assertEquals(5, lstAccountPlan.size());

        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(tw.lstAccounts , [SELECT Id FROM Product_Group__c] , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 50;
            lstTargets[i].Target_Units__c = 2.5;
            lstTargets[i].Account__c = tw.lstAccounts[i].Id;
            lstTargets[i].Product__c = tw.lstProduct[i].id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        } 
        insert lstTargets;

        System.assertEquals(5, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5, [Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(5, [Select Id, Quantity, Revenue  from OpportunityLineItemSchedule].size(), 'Initial Deal Products');

        for (OpportunityLineItem dealProduct : [Select (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules),Replen_Quantity__c, Initial_Quantity__c, Id, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(1, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                for (OpportunityLineItemSchedule sch : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(1, sch.Quantity);
                    System.assertEquals(20, sch.Revenue);
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
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
        
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);

        System.assertEquals(5, [Select Id, Name from Opportunity].size(), 'No New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        // Verify Schedules are not updated as Initial Quantity is not updated
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Opportunity.Account.Digital_Country_Code__c, (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules), Id,Replen_Quantity__c,Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c) || dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Default 1');
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(1, schedule.Quantity);
                    System.assertEquals(20, schedule.Revenue);
                }
                physicalDealProducts++;
            }
        }
        System.assertEquals(3, physicalDealProducts);
        
        Test.stopTest();
        
        
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void Scenario3_Insert_Account_Plan_With_No_Valid_Existing_Deal_And_No_Deal_Products_Test() {

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        // Change the Deal Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Opportunity deal : tw.lstOpportunity) {
            deal.CurrencyIsoCode = 'GBP';
        }
        update tw.lstOpportunity;

        // Delete existing data because the checkbox for Scenario 3 will not be checked on insert of Account Plan
        // in test Data because Scenario 1 checkbox is already check 
        List<Country_Plan__c> lstCountryPlanToDelete = [SELECT Id FROM Country_Plan__c];
        List<Account_Plan__c> lstAccountPlanPlanToDelete = [SELECT Id FROM Account_Plan__c];
        delete lstCountryPlanToDelete;
        delete lstAccountPlanPlanToDelete;

        // Previous Street Date not Specified
        for(Product2 p : tw.lstProduct){
           p.Street_Date_Has_Changed__c = false;
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;

        // Insert Account Plan for Scenario 3
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,tw.lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
            cp.Stretch_Target__c = 10;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, tw.lstAccounts, false);
        for (Account_Plan__c accountPlanInsatnce : lstAccountPlan) {
            accountPlanInsatnce.Share__c = 10;
        }
        insert lstAccountPlan;
        System.assertEquals(5, lstAccountPlan.size());

        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(tw.lstAccounts , [SELECT Id FROM Product_Group__c] , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 50;
            lstTargets[i].Target_Units__c = 2.5;
            lstTargets[i].Account__c = tw.lstAccounts[i].Id;
            lstTargets[i].Product__c = tw.lstProduct[i].id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        } 
        insert lstTargets;

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
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new Deals inserted
        System.assertEquals(8, [Select Id, Name from Opportunity].size(), 'Initial Deals');

        // Verify deal Products inserted on Scenario 3 i.e Account Plan is inserted after deal is created
        List<OpportunityLineItem> dealProducts = [Select Id,Opportunity.Account.Digital_Country_Code__c,Target_Quantity__c,Replen_Quantity__c,Initial_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate, Revenue FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ];
        System.assertEquals(3, dealProducts.size(), 'Initial Deal Products');

        // Verify 3 digital deal products created.
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(3, dealProduct.Replen_Quantity__c, 'Should be same as Target Quantity');
                    System.assertEquals(3, dealProduct.Quantity);
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(3, schedule.Quantity);
                        System.assertEquals(60, schedule.Revenue);
                    }
                } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(3, dealProduct.Replen_Quantity__c, 'Should be same as Target Quantity');
                    System.assertEquals(3, dealProduct.Quantity);
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(3, schedule.Quantity);
                        System.assertEquals(60, schedule.Revenue);
                    }
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                    System.assertEquals(55, dealProduct.Replen_Quantity__c, 'Should be same as Target Quantity');
                    System.assertEquals(55, dealProduct.Quantity);
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(55, schedule.Quantity);
                        System.assertEquals(1100, schedule.Revenue);
                    }
                }
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        // Verify Target flags are reset after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
            }
        }

        // Verify Product flags are  reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 1
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }


    public static testMethod void Street_Date_Changed_With_Existing_Schedules_And_No_Account_Plan_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Map<Id,List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id,List<Account_Plan__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

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

        // Verify No new Deal is created as no Account Plan present
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');

        // Verify no new Deal Product is cloned and modified as no valid PBEP found
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify no digital deal products are cloned and created. Existing manually created physical deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,Opportunity.Account.Digital_Country_Code__c,OpportunityId,Manually_Schedule__c,Product2.Type__c,NR_Deal_Product_Unique_Key__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            if (dealProducts.Product2.Type__c.contains('Digital')) {
                System.assertEquals(21, dealProducts.Quantity);
                System.assertEquals(0, dealProducts.Target_Quantity__c);
                /*if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProducts.Opportunity.Account.Digital_Country_Code__c)) {
                    System.assertEquals(3, dealProducts.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(10, dealProducts.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                }*/
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity from OpportunityLineItemSchedule];
        System.assertEquals(5, schedules.size(), 'No Change');

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

    /** JAPAN Methods **/
    public static testMethod void Scenario1_JAPAN_With_Some_Existing_Valid_And_Some_Non_Existing_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Set the Sales Org as JAPAN for Account
        Integer countRec = 0;
        Account gamesDigital;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                if (acc.Games_Digital__c) {
                    gamesDigital = acc;
                }
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;
        System.assert(gamesDigital != null);
        
        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            String dealPeriod = '';
            if (
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
            ) {
                Integer currentQtr =
                    Decimal.valueOf(
                        (system.today() + 10).toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = 'Q' + currentQtr;
            } else {
                Datetime sDate =
                    datetime.newInstance(
                        (system.today() + 10).year(),
                        (system.today() + 10).month(),
                        (system.today() + 10).day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
                if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                    Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(System.today() + 10);
                    Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                    Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                    if (startDate != null && endDate != null) {
                        Datetime sDate1 =
                            datetime.newInstance(
                                startDate.year(),
                                startDate.month(),
                                startDate.day()
                            );
                        String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                        Datetime sDate2 =
                            datetime.newInstance(
                                endDate.year(),
                                endDate.month(),
                                endDate.day()
                            );
                        String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                        dealPeriod = startMonth + '-' + endMonth;
                    }
                }
            }
            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            }
        }
        update tw.lstOpportunity;

        List<Opportunity> oppToDeleteList = [SELECT Id FROM Opportunity WHERE AccountId = :gamesDigital.Id];
        delete oppToDeleteList;

        Map<Id, Opportunity> mapExistingDealIdToInstance = new Map<Id, Opportunity>([SELECT Id, Start_Date__c, CloseDate, Product_Type__c FROM Opportunity]);
        // Verify 4 valid opportunity records present
        System.assertEquals(4, mapExistingDealIdToInstance.size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Update Start date in order to check the schedule Date is set based on PBEP Start Date
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Start_Date__c = System.today() + 10;
        }
        update tw.lstPriceBookEntryPeriod;

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            productInstance.NR_Product_Created__c = true;
            productInstance.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        List<Country_Plan__c> lstCountryPlan = [SELECT Id,Country__c, Target_Quantity__c, NR_Product__c, NR_Product__r.RecordTypeId, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        Integer coundDigitalProduct = 0;
        Id productWithTargetQuantity;
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; // Added by ketan
            if (coundDigitalProduct > 0) {
                cp.Target_Quantity__c = null;
                cp.Target_Revenue__c = 5000;
            } else {
                productWithTargetQuantity = cp.NR_Product__c;
            }
            coundDigitalProduct++;
        }
        update lstCountryPlan;
        System.assert(productWithTargetQuantity != null);

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : [SELECT NR_Product_Created__c, Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Total_Target__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            if (accountPlanInstance.Country_Plan__r.NR_Product__c == productWithTargetQuantity) {
                System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            } else {
                System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
                System.assertEquals(550, accountPlanInstance.Total_Target__c);
                System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
            }
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            System.debug('---pbep->'+pbep);
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

        // Verify 3 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products but in this case for those
        // Products and Account no valid Account Plan is found so no deal Product is created
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        Integer countDealProduct = 0;
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Product2.Type__c,Opportunity.Account.Name, Opportunity.Start_Date__c,Opportunity.CloseDate, Opportunity.Promo_Start_Date__c, Opportunity.Promo_End_Date__c, Account_Plan__c, Promoted_Price__c, SAP_Promoted_Price__c, Opportunity.AccountId, OpportunityId,Product2Id, Account_Price__c, Opportunity.Name, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
            System.assertEquals(20, dealProduct.Account_Price__c);
            System.assertEquals(20, dealProduct.Promoted_Price__c);
            System.assertEquals(1, dealProduct.Quantity, 'Quantity should be 1');
            System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
            if (dealProduct.Product2Id == productWithTargetQuantity) {
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan.TargetQuantity');
                System.assertEquals(0, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                System.assertEquals(28, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Total Target / Deal Product.AccountPrice');
                System.assertEquals(0, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.Quantity);
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
            System.assertEquals(0, dealProduct.Replen_Quantity__c);
            if (!mapExistingDealIdToInstance.containsKey(dealProduct.OpportunityId)) {
                //System.assert(dealProduct.Opportunity.Name.contains('New Release'));
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(System.today() + 10);
                String productType;
                String marketType;
                Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                if (startDate != null && endDate != null) {
                    Datetime sDate1 =
                        datetime.newInstance(
                            startDate.year(),
                            startDate.month(),
                            startDate.day()
                        );
                    String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                    Datetime sDate2 =
                        datetime.newInstance(
                            endDate.year(),
                            endDate.month(),
                            endDate.day()
                        );
                    String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                    if (dealProduct.Product2.Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_GAMES_DIGITAL;
                    } else if (dealProduct.Product2.Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_DIGITAL;
                    }
                    // US JAPAN : 561
                    else if (dealProduct.Product2.Type__c == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE) {
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_DIGITAL;
                    }
                    String dealName = CRM_AppConstants.NR_Deal_Japan_Naming_INITIAL + productType + startDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year +' '+ startMonth + ' ' + startDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day +' '+ CRM_AppConstants.NR_Deal_Japan_Month_Connector + endDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year  +' '+ endMonth +' '+ endDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day + ' ' + dealProduct.Opportunity.Account.Name;
                    System.assertEquals(dealName, dealProduct.Opportunity.Name);
                    System.assertEquals(startDate, dealProduct.Opportunity.Start_Date__c);
                    System.assertEquals(endDate, dealProduct.Opportunity.CloseDate);
                    System.assertEquals(startDate, dealProduct.Opportunity.Promo_Start_Date__c);
                    System.assertEquals(endDate, dealProduct.Opportunity.Promo_End_Date__c);
                }
                countDealProduct++;
            } else {
                countDealProduct++;
            }
        }
        System.assertEquals(3, countDealProduct);

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, OpportunityLineItem.Product2Id, ScheduleDate, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(0, schedule.Revenue);
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(System.today() + 10, schedule.ScheduleDate);
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_JAPAN_With_Some_Existing_Deal_With_Stage_Committed_And_Deal_Product_To_Be_Cloned_Present_Test(){

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
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
        insert testUser;
        System.assert(testUser.Id != null, 'User should get created');

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Set the Sales Org as JAPAN for Account
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

         for(Opportunity opp : tw.lstOpportunity){
           if (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
               opp.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstOpportunity;
        System.assertEquals(5, tw.lstOpportunity.size(), 'Updated Products');

        List<Account_Plan__c> lstAccPlanUpdate = [SELECT Id,  Country_Plan__r.NR_Product__r.Product_Market__c, Target_Quantity__c, Total_Target__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAPId = new Map<Id, Id>();
        for (Account_Plan__c acc : lstAccPlanUpdate) {
            if (acc.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
                mapAccountIdToAPId.put(acc.Customer__c, acc.Id);
            }
        }
        update lstAccPlanUpdate;

        Test.startTest();
        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstNewOpp = CRM_TestDataFactory.createOpportunitiesWithAccounts(tw.lstAccounts,1,false);
        List<Opportunity> lstDealsForChangedStreetDate = new List<Opportunity>();
        System.assertEquals(5, lstNewOpp.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstNewOpp.size(); i++) {
            Opportunity d0_existingDeal = lstNewOpp[i];
            if (tw.lstAccounts[i].Games_Digital__c) {
                continue;
            }
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
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
            ) {
                Integer currentQtr =
                    Decimal.valueOf(
                        (system.today() + 140).toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = 'Q' + currentQtr;
            } else {
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(system.today() + 140);
                Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                if (startDate != null && endDate != null) {
                    Datetime sDate1 =
                        datetime.newInstance(
                            startDate.year(),
                            startDate.month(),
                            startDate.day()
                        );
                    String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                    Datetime sDate2 =
                        datetime.newInstance(
                            endDate.year(),
                            endDate.month(),
                            endDate.day()
                        );
                    String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                    dealPeriod = startMonth + '-' + endMonth;
                }
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
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE ){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                    d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                }
            }
            lstDealsForChangedStreetDate.add(d0_existingDeal);
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, lstDealsForChangedStreetDate, 1, false);
        //Setting up OpportunityLineItem Data

        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            if (tw.lstOpportunity[i].Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                lstDealProduct[i].Account_Plan__c = mapAccountIdToAPId.get(tw.lstOpportunity[i].AccountId);
            }
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;
        Set<String> existingDealProductKey = new Set<String>();
        for (OpportunityLineItem opp : [SELECT Opportunity.AccountId, Product2Id FROM OpportunityLineItem]) {
            existingDealProductKey.add(opp.Opportunity.AccountId + '-' + opp.Product2Id);
        }

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update oppList;
        }

        // Verify 9 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(9, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify 4 deal product records present
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(4, dealProductsBeforeBatchRun.size());

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedulesBeforeBatchRun = [SELECT Id, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.Product2.RecordTypeId, ScheduleDate, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(4, lineItemSchedulesBeforeBatchRun.size());
        Map<Id, OpportunityLineItemSchedule> mapExistingSchedules = new Map<Id, OpportunityLineItemSchedule>(lineItemSchedulesBeforeBatchRun);
        Integer countDigitalSchedule = 0;
        for (OpportunityLineItemSchedule schedule : lineItemSchedulesBeforeBatchRun) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(20, schedule.Revenue);
                System.assertEquals(system.today()+1, schedule.ScheduleDate);
                countDigitalSchedule++;
            } 
        }
        System.assertEquals(2, countDigitalSchedule);

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        List<Country_Plan__c> lstCountryPlan = [SELECT Id,Country__c, Target_Quantity__c, NR_Product__c, NR_Product__r.RecordTypeId, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        Integer coundDigitalProduct = 0;
        Id productWithTargetQuantity;
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //added by ketan
            if (coundDigitalProduct > 0) {
                cp.Target_Quantity__c = null;
                cp.Target_Revenue__c = 5000;
            } else {
                productWithTargetQuantity = cp.NR_Product__c;
            }
            coundDigitalProduct++;
        }
        update lstCountryPlan;
        System.assert(productWithTargetQuantity != null);

        List<Account_Plan__c> lstAccPlan = [SELECT Id, Target_Quantity__c, Total_Target__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c acc : lstAccPlan) {
            acc.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccPlan;

        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Total_Target__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            if (accountPlanInstance.Country_Plan__r.NR_Product__c == productWithTargetQuantity) {
                System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            } else {
                System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
                System.assertEquals(550, accountPlanInstance.Total_Target__c);
                System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
                
            }
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify additional opportunity records are not created even if valid Deal Stage is changed to Non NR Default
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());

        // Verify Satge Name is not changed
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            if(!mapIdToDealInstance.containsKey(newDealInsatnce.Id)) {
                System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT, newDealInsatnce.StageName);
            } else {
                System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
            }
        }

        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        Integer countDigital = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2.Type__c, Opportunity.Start_Date__c, Product2Id, Opportunity.Account.Name, Opportunity.CloseDate, Opportunity.Promo_Start_Date__c, Opportunity.Promo_End_Date__c, Promoted_Price__c, SAP_Promoted_Price__c, Account_Plan__c, Replen_Quantity__c, Opportunity.Name, Initial_Quantity__c,Opportunity.Account.Digital_Country_Code__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem];
        System.assertEquals(5, dealProductsAfterBatchRun.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(20, dealProduct.Promoted_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                if (dealProduct.Product2Id == productWithTargetQuantity) {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan.TargetQuantity');
                } else {
                    System.assertEquals(28, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Total Target / Deal Product.AccountPrice');                
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                
                // Verify these deal products are linked with existing deals based on changed Street Date
                if(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId)) {
                    System.assertEquals(1, dealProduct.Replen_Quantity__c);
                    //System.assert(dealProduct.Opportunity.Name.contains('New Release'));
                    Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(system.today()+140);
                    String productType;
                    String marketType;
                    Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                    Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                    if (startDate != null && endDate != null) {
                        Datetime sDate1 =
                            datetime.newInstance(
                                startDate.year(),
                                startDate.month(),
                                startDate.day()
                            );
                        String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                        Datetime sDate2 =
                            datetime.newInstance(
                                endDate.year(),
                                endDate.month(),
                                endDate.day()
                            );
                        String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                        if (dealProduct.Product2.Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                            productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_GAMES_DIGITAL;
                        } else if (dealProduct.Product2.Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                            productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_DIGITAL;
                        }
                        // US JAPAN : 561
                        else if (dealProduct.Product2.Type__c == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE) {
                            productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_DIGITAL;
                        }
                        String dealName = CRM_AppConstants.NR_Deal_Japan_Naming_INITIAL + productType + startDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year +' '+ startMonth + ' ' + startDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day +' '+ CRM_AppConstants.NR_Deal_Japan_Month_Connector + endDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year  +' '+ endMonth +' '+ endDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day + ' ' + dealProduct.Opportunity.Account.Name;
                        System.assertEquals(dealName, dealProduct.Opportunity.Name);
                        System.assertEquals(startDate, dealProduct.Opportunity.Start_Date__c);
                        System.assertEquals(endDate, dealProduct.Opportunity.CloseDate);
                        System.assertEquals(startDate, dealProduct.Opportunity.Promo_Start_Date__c);
                        System.assertEquals(endDate, dealProduct.Opportunity.Promo_End_Date__c);
                    }
                    countDigital ++;
                } else {
                    if (existingDealProductKey.contains(dealProduct.Opportunity.AccountId + '-' + dealProduct.Product2Id)) {
                        System.assertEquals(1, dealProduct.Replen_Quantity__c);
                    } else {
                        System.assertEquals(0, dealProduct.Replen_Quantity__c);
                    }
                    //System.assertEquals(1, dealProduct.Replen_Quantity__c);
                    countDigital ++;
                }
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(3, countDigital);

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedulesAfterBatchRun = [SELECT Id, OpportunityLineItem.Opportunity.AccountId, OpportunityLineItem.Product2Id, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.Product2.RecordTypeId, ScheduleDate, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedulesAfterBatchRun.size());
        Integer countDigitalScheduleAfterBatchRun = 0;
        for (OpportunityLineItemSchedule schedule : lineItemSchedulesAfterBatchRun) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!mapExistingSchedules.containsKey(schedule.Id));
                System.assertEquals(1, schedule.Quantity);
                if (existingDealProductKey.contains(schedule.OpportunityLineItem.Opportunity.AccountId + '-' + schedule.OpportunityLineItem.Product2Id)) {
                    System.assertEquals(20, schedule.Revenue);
                } else {
                    System.assertEquals(0, schedule.Revenue);
                }
                System.assertEquals(system.today()+140, schedule.ScheduleDate);
                countDigitalScheduleAfterBatchRun++;
            }
        }
        System.assertEquals(3, countDigitalScheduleAfterBatchRun);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    
    
    public static testMethod void Scenario3_JAPAN_Insert_Account_Plan_With_And_Without_Existing_Deal_And_Deal_Products_For_Target_Quantity_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set the Sales Org as JAPAN for Account
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.List_Price__c = 15;
        }
        update tw.lstPriceBookEntryPeriod;

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;
        
        
        Test.startTest();
        
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up Product Data to false as for scenario 3 both these checboxes are false 
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        
        List<Account_Plan__c> lstAccPlanUpdate = [SELECT Id,  Country_Plan__r.NR_Product__r.Product_Market__c, Target_Quantity__c, Total_Target__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAPId = new Map<Id, Id>();
        for (Account_Plan__c acc : lstAccPlanUpdate) {
            if (acc.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
                mapAccountIdToAPId.put(acc.Customer__c, acc.Id);
            }
        }
        update lstAccPlanUpdate;

         for(Integer i=0; i<tw.lstOpportunity.size();i++){
            Opportunity opp = tw.lstOpportunity[i];
            if (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                opp.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            } else {
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(System.today() + 1);
                Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                String dealPeriod;
                if (startDate != null && endDate != null) {
                    Datetime sDate1 =
                        datetime.newInstance(
                            startDate.year(),
                            startDate.month(),
                            startDate.day()
                        );
                    String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                    Datetime sDate2 =
                        datetime.newInstance(
                            endDate.year(),
                            endDate.month(),
                            endDate.day()
                        );
                    String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                    dealPeriod = startMonth + '-' + endMonth;
                }
                tw.lstOpportunity[i].NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
           }
        }
        update tw.lstOpportunity;

        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
            if (tw.lstOpportunity[i].Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                lstDealProduct[i].Account_Plan__c = mapAccountIdToAPId.get(tw.lstOpportunity[i].AccountId);
            }
        }
        insert lstDealProduct;
		
        
        
        List<Opportunity> deleteVideoDigitalOpp = [SELECT Id FROM Opportunity WHERE Account.Video_Digital__c = true];
        System.assertEquals(2, deleteVideoDigitalOpp.size());
        delete deleteVideoDigitalOpp;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlan) {
            accountPlan.Share__c = 40;
        }
        update lstAccountPlan;

        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');
        System.assertEquals(3,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(3,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c, Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }

        // One created for Digital and 2 created for physical
        Integer existingDigitalSchedules = 0;
        List<OpportunityLineItemSchedule> lstExistingSchedules = [Select Id, Quantity,OpportunityLineItem.Product2.RecordTypeId, Revenue, ScheduleDate, OpportunityLineItemId from OpportunityLineItemSchedule];
        System.assertEquals(3, lstExistingSchedules.size(), 'Initial Deal Product Schedule');
        Map<Id, OpportunityLineItemSchedule> existingSchedulesMap = new Map<Id, OpportunityLineItemSchedule>(lstExistingSchedules);
        for (OpportunityLineItemSchedule schedule : lstExistingSchedules) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(20, schedule.Revenue);
                System.assertEquals(system.today()+1, schedule.ScheduleDate);
                existingDigitalSchedules++;
            } else {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(0, schedule.Revenue);
                System.assertEquals(System.today() + 32, schedule.ScheduleDate, 'Product Street date');
            }
        }
        System.assertEquals(1, existingDigitalSchedules);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 4
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
        
        
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        
        Test.stopTest();
        
        
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id, Opportunity.Account.Sales_Organization__c, Opportunity.Account.Video_Digital__c, Account_Plan__c, Promoted_Price__c, SAP_Promoted_Price__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (dealProduct.Opportunity.Account.Video_Digital__c) {
                    System.assertEquals(15.00, dealProduct.Promoted_Price__c);
                    System.assertEquals(0, dealProduct.Replen_Quantity__c);
                    System.assertEquals(1, dealProduct.Quantity);
                } else {
                    System.assertEquals(20.00, dealProduct.Promoted_Price__c);
                    System.assertEquals(1, dealProduct.Replen_Quantity__c);
                }
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(15.00, dealProduct.Account_Price__c, 'Updated Account Price');
                //System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        // Verify Schedules updated
        Integer digitalSchedulesAfterBatchRun = 0;
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Opportunity.Account.Video_Digital__c ,OpportunityLineItem.Product2.RecordTypeId, Quantity, ScheduleDate, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (schedule.OpportunityLineItem.Opportunity.Account.Video_Digital__c) {
                    System.assert(!existingSchedulesMap.containsKey(schedule.Id), 'Schedules should be newly created');
                    //System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(1, schedule.Quantity);
                } else {
                    System.assert(existingSchedulesMap.containsKey(schedule.Id), 'Schedules should be newly created');
                    System.assertEquals(20, schedule.Revenue);
                }
                //System.assertEquals(1, schedule.Quantity);
                System.assertEquals(system.today()+1, schedule.ScheduleDate);
                digitalSchedulesAfterBatchRun++;
            } else {
                // No change for Physical
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(0, schedule.Revenue);
                System.assertEquals(System.today() + 32, schedule.ScheduleDate, 'Product Street date');
            }
        }
        System.assertEquals(3, digitalSchedulesAfterBatchRun);

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void Scenario3_JAPAN_Insert_Account_Plan_With_And_Without_Existing_Deal_And_Deal_Products_For_Target_Revenue_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set the Sales Org as JAPAN for Account
        Integer countRec = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.List_Price__c = 15;
        }
        update tw.lstPriceBookEntryPeriod;

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
           if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
               p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           }
        }
        update tw.lstProduct;

        List<Account_Plan__c> lstAccPlanUpdate = [SELECT Id,  Country_Plan__r.NR_Product__r.Product_Market__c, Target_Quantity__c, Total_Target__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAPId = new Map<Id, Id>();
        for (Account_Plan__c acc : lstAccPlanUpdate) {
            if (acc.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
                mapAccountIdToAPId.put(acc.Customer__c, acc.Id);
            }
        }
        update lstAccPlanUpdate;

        for(Integer i=0; i < tw.lstOpportunity.size(); i++){
           Opportunity opp = tw.lstOpportunity[i];
           if (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
               opp.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
           } else {
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(System.today() + 1);
                Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                String dealPeriod;
                if (startDate != null && endDate != null) {
                    Datetime sDate1 =
                        datetime.newInstance(
                            startDate.year(),
                            startDate.month(),
                            startDate.day()
                        );
                    String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                    Datetime sDate2 =
                        datetime.newInstance(
                            endDate.year(),
                            endDate.month(),
                            endDate.day()
                        );
                    String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                    dealPeriod = startMonth + '-' + endMonth;
                }
                tw.lstOpportunity[i].NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
           }
        }
        update tw.lstOpportunity;

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
            if (tw.lstOpportunity[i].Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                lstDealProduct[i].Account_Plan__c = mapAccountIdToAPId.get(tw.lstOpportunity[i].AccountId);
            }
        }
        insert lstDealProduct;

        List<Opportunity> deleteVideoDigitalOpp = [SELECT Id FROM Opportunity WHERE Account.Video_Digital__c = true];
        System.assertEquals(2, deleteVideoDigitalOpp.size());
        delete deleteVideoDigitalOpp;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Country_Plan__c> lstCountryPlan = [SELECT Id,Country__c, Target_Quantity__c, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //added by ketan
            cp.Target_Quantity__c = null;
            cp.Stretch_Target__c = 10;
        }
        update lstCountryPlan;

        List<Account_Plan__c> lstAccPlan = [SELECT Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c ap : lstAccPlan) {
            ap.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccPlan;

        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Revenue__c = 5000;
        }
        update lstCountryPlan;

        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');
        System.assertEquals(3,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(3,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c, Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }

        // One created for Digital and 2 created for physical
        Test.startTest();
        Integer existingDigitalSchedules = 0;
        List<OpportunityLineItemSchedule> lstExistingSchedules = [Select Id, Quantity,OpportunityLineItem.Product2.RecordTypeId, Revenue, ScheduleDate, OpportunityLineItemId from OpportunityLineItemSchedule];
        System.assertEquals(3, lstExistingSchedules.size(), 'Initial Deal Product Schedule');
        Map<Id, OpportunityLineItemSchedule> existingSchedulesMap = new Map<Id, OpportunityLineItemSchedule>(lstExistingSchedules);
        for (OpportunityLineItemSchedule schedule : lstExistingSchedules) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(20, schedule.Revenue);
                System.assertEquals(system.today()+1, schedule.ScheduleDate);
                existingDigitalSchedules++;
            } else {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(0, schedule.Revenue);
                System.assertEquals(System.today() + 32, schedule.ScheduleDate, 'Product Street date');
            }
        }
        System.assertEquals(1, existingDigitalSchedules);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Total_Target__c, Country_Plan__r.Target_Revenue__c, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
                System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
                System.assertEquals(550, accountPlanInstance.Total_Target__c);
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 4
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
       
        Test.stopTest();
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');
        
        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id, Opportunity.Account.sales_Organization__c, Opportunity.Account.Video_Digital__c, Account_Plan__c, Promoted_Price__c, SAP_Promoted_Price__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(15.00, dealProduct.Account_Price__c, 'Updated Account Price');
                if (dealProduct.Opportunity.Account.Video_Digital__c) {
                    System.assertEquals(15.00, dealProduct.Promoted_Price__c);
                } else {
                    System.assertEquals(20.00, dealProduct.Promoted_Price__c);
                }
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(37, dealProduct.Target_Quantity__c, '550 / 15 - Updated Quantity = Account Plan.Total_Target / Deal Product.AccountPrice');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        
        // Verify Schedules updated
        Integer digitalSchedulesAfterBatchRun = 0;
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, OpportunityLineItem.Opportunity.Account.Video_Digital__c ,OpportunityLineItem.Product2.RecordTypeId, Quantity, ScheduleDate, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (schedule.OpportunityLineItem.Opportunity.Account.Video_Digital__c) {
                    System.assert(!existingSchedulesMap.containsKey(schedule.Id), 'Schedules should be newly created');
                    System.assertEquals(1, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                } else {
                    System.assert(existingSchedulesMap.containsKey(schedule.Id), 'Schedules should not be newly created');
                    System.assertEquals(1, schedule.Quantity);
                    System.assertEquals(20, schedule.Revenue);
                }
                System.assertEquals(system.today()+1, schedule.ScheduleDate);
                digitalSchedulesAfterBatchRun++;
            } else {
                // No change for Physical
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(0, schedule.Revenue);
                System.assertEquals(System.today() + 32, schedule.ScheduleDate, 'Product Street date');
            }
        }
        System.assertEquals(3, digitalSchedulesAfterBatchRun);

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void Scenario1_JAPAN_With_Some_Existing_Valid_And_Some_Non_Existing_Deal_Music_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Set the Sales Org as JAPAN for Account
        Integer countRec = 0;
        Account gamesDigital;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                if (acc.Games_Digital__c) {
                    gamesDigital = acc;
                    acc.Games_Digital__c = false;
                    acc.Music_Digital__c = true;
                }
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    acc.Video_Digital__c = false;
                    acc.Music_Digital__c = true;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;
        System.assert(gamesDigital != null);

        // Update Start date in order to check the schedule Date is set based on PBEP Start Date
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Start_Date__c = System.today() + 10;
        }
        update tw.lstPriceBookEntryPeriod;

        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {CRM_AppConstants.JAPAN_COUNTRY_CODE}, 1, true);

        List<Title__c> lstTitles = [SELECT Id, Content_Type__c FROM Title__c];
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.MUSIC_TITTLE_CONTENT_TYPE;
        update lstTitles;

        List<Local_Title__c> lstLocaTitle = [SELECT Id, Country__c FROM Local_Title__c];
        delete lstLocaTitle;
        List<Language__c> lstlanguage = [SELECT Id FROM Language__c];
        lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;
        System.assertEquals(1, lstLocaTitle.size());
        /*List<Local_Title__c> lstLocaTitle = [SELECT Id, Country__c FROM Local_Title__c];
        System.assertEquals(1, lstLocaTitle.size());
        lstLocaTitle[0].Country__c = lstCountry[0].Id;
        update lstLocaTitle;*/

        // Verify Products are newly created due to which it will be considered for batch processing
        Integer countVideoProduct = 0;
        for (Product2 productInstance : tw.lstProduct) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (productInstance.Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                    productInstance.Type__c = CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE;
                    productInstance.Local_Title__c = lstLocaTitle[0].Id;
                } else if (productInstance.Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE) && countVideoProduct == 0) {
                    productInstance.Type__c = CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE;
                    productInstance.Local_Title__c = lstLocaTitle[0].Id;
                    countVideoProduct++;
                }
            }
            productInstance.NR_Product_Created__c = true;
            productInstance.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        Integer dealCount = 0;
        for (Integer i = 0; i<tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            String dealPeriod = '';
            if (
                    //tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
            ) {
                Integer currentQtr =
                    Decimal.valueOf(
                        (system.today() + 10).toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = 'Q' + currentQtr;
            } else {
                Datetime sDate =
                    datetime.newInstance(
                        (system.today() + 10).year(),
                        (system.today() + 10).month(),
                        (system.today() + 10).day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
                if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                    Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(System.today() + 10);
                    Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                    Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                    if (startDate != null && endDate != null) {
                        Datetime sDate1 =
                            datetime.newInstance(
                                startDate.year(),
                                startDate.month(),
                                startDate.day()
                            );
                        String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                        Datetime sDate2 =
                            datetime.newInstance(
                                endDate.year(),
                                endDate.month(),
                                endDate.day()
                            );
                        String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                        dealPeriod = startMonth + '-' + endMonth;
                    }
                }
            }
            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            if (d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            }
            String strdealProductType;
            if (tw.lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                if (tw.lstProduct[i].Type__c == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE)  {
                    strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
                } else {
                    strdealProductType = tw.lstProduct[i].Type__c;
                }
                dealCount++;
            }
            d0_existingDeal.Product_Type__c = strdealProductType;
        }
        update tw.lstOpportunity;

        List<Opportunity> oppToDeleteList = [SELECT Id FROM Opportunity WHERE AccountId = :gamesDigital.Id];
        delete oppToDeleteList;

        Map<Id, Opportunity> mapExistingDealIdToInstance = new Map<Id, Opportunity>([SELECT Id, Start_Date__c, CloseDate, Product_Type__c FROM Opportunity]);
        // Verify 4 valid opportunity records present
        System.assertEquals(4, mapExistingDealIdToInstance.size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        List<Country_Plan__c> lstCountryPlan = [SELECT Id,Country__c, Target_Quantity__c, NR_Product__c, NR_Product__r.RecordTypeId, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        Integer coundDigitalProduct = 0;
        Id productWithTargetQuantity;
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //Added by ketan
            if (coundDigitalProduct > 0) {
                cp.Target_Quantity__c = null;
                cp.Target_Revenue__c = 5000;
            } else {
                productWithTargetQuantity = cp.NR_Product__c;
            }
            coundDigitalProduct++;
        }
        update lstCountryPlan;
        System.assert(productWithTargetQuantity != null);

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : [SELECT NR_Product_Created__c, Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Total_Target__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            if (accountPlanInstance.Country_Plan__r.NR_Product__c == productWithTargetQuantity) {
                System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            } else {
                System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
                System.assertEquals(550, accountPlanInstance.Total_Target__c);
                System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
            }
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, isDuplicate__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            System.debug('---pbep->'+pbep);
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 1 additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 3 deal product records for 3 digital products should be created through batch
        // 2 products have same Type so 2 deals wil have 2 deal products but in this case for those
        // Products and Account no valid Account Plan is found so no deal Product is created
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        Integer countDealProduct = 0;
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c , Account_Plan__c,Product2.Type__c,Opportunity.Account.Name, Opportunity.Start_Date__c,Opportunity.CloseDate, Opportunity.Promo_Start_Date__c, Opportunity.Promo_End_Date__c, Opportunity.Product_Type__c, Promoted_Price__c, SAP_Promoted_Price__c, Opportunity.AccountId, OpportunityId,Product2Id, Account_Price__c, Opportunity.Name, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity,Opportunity.Account.Music_Digital__c, Opportunity.Account.Video_Digital__c FROM OpportunityLineItem]) {
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
            System.assertEquals(20, dealProduct.Account_Price__c);
            System.assertEquals(20, dealProduct.Promoted_Price__c);
            System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
            if (dealProduct.Product2Id == productWithTargetQuantity) {
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan.TargetQuantity');
                System.assertEquals(0, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.Quantity);
            } else {
                System.assertEquals(28, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Total Target / Deal Product.AccountPrice');
                System.assertEquals(0, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.Quantity);
            }
            System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
            if (!mapExistingDealIdToInstance.containsKey(dealProduct.OpportunityId)) {
                //System.assert(dealProduct.Opportunity.Name.contains('New Release'));
                System.assertEquals(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE, dealProduct.Opportunity.Product_Type__c);
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(System.today() + 10);
                String productType;
                String marketType;
                Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                if (startDate != null && endDate != null) {
                    Datetime sDate1 =
                        datetime.newInstance(
                            startDate.year(),
                            startDate.month(),
                            startDate.day()
                        );
                    String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                    Datetime sDate2 =
                        datetime.newInstance(
                            endDate.year(),
                            endDate.month(),
                            endDate.day()
                        );
                    String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                    if (dealProduct.Product2.Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_GAMES_DIGITAL;
                    } else if (dealProduct.Product2.Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_DIGITAL;
                    }
                    // US JAPAN : 561
                    else if (dealProduct.Product2.Type__c == CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE) {
                        productType = CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_DIGITAL;
                    }
                    String dealName = CRM_AppConstants.NR_Deal_Japan_Naming_INITIAL + productType + startDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year +' '+ startMonth + ' ' + startDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day +' '+ CRM_AppConstants.NR_Deal_Japan_Month_Connector + endDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year  +' '+ endMonth +' '+ endDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day + ' ' + dealProduct.Opportunity.Account.Name;
                    System.assertEquals(dealName, dealProduct.Opportunity.Name);
                    System.assertEquals(startDate, dealProduct.Opportunity.Start_Date__c);
                    System.assertEquals(endDate, dealProduct.Opportunity.CloseDate);
                    System.assertEquals(startDate, dealProduct.Opportunity.Promo_Start_Date__c);
                    System.assertEquals(endDate, dealProduct.Opportunity.Promo_End_Date__c);
                }
                countDealProduct++;
            } else {
                if (dealProduct.Opportunity.Account.Music_Digital__c) {
                    System.assertEquals(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE, dealProduct.Opportunity.Product_Type__c);
                    System.assertEquals(CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE, dealProduct.Product2.Type__c);
                    countDealProduct++;
                } else if (dealProduct.Opportunity.Account.Video_Digital__c){
                    System.assertEquals(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE, dealProduct.Opportunity.Product_Type__c);
                    System.assertEquals(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE, dealProduct.Product2.Type__c);
                    countDealProduct++;
                }
            }
        }
        System.assertEquals(3, countDealProduct);

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, ScheduleDate, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(3, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(0, schedule.Revenue);
            System.assertEquals(System.today() + 10, schedule.ScheduleDate);
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_JAPAN_Insert_Account_Plan_With_And_Without_Existing_Deal_And_Deal_Products_For_Target_Revenue_Music_Type_Test() {
    
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        List<Opportunity> deleteVideoDigitalOpp = [SELECT Id FROM Opportunity WHERE Account.Video_Digital__c = true];
        System.assertEquals(2, deleteVideoDigitalOpp.size());
        delete deleteVideoDigitalOpp;

        // Set the Sales Org as JAPAN for Account
        Integer countRec = 0;
        Account existingAcc;
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c || acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE;
                if (acc.Games_Digital__c) {
                    acc.Games_Digital__c = false;
                    acc.Music_Digital__c = true;
                    existingAcc = acc;
                }
                if (acc.Video_Digital__c && countRec == 0) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
                    acc.Video_Digital__c = false;
                    acc.Music_Digital__c = true;
                    countRec++;
                } else if (acc.Video_Digital__c) {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                }
            } else {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            }
        }
        update tw.lstAccounts;
        System.debug('--tw.lstAccounts-->'+tw.lstAccounts);
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.List_Price__c = 15;
        }
        update tw.lstPriceBookEntryPeriod;

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {CRM_AppConstants.JAPAN_COUNTRY_CODE}, 1, true);

        List<Title__c> lstTitles = [SELECT Id, Content_Type__c FROM Title__c];
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.MUSIC_TITTLE_CONTENT_TYPE;
        update lstTitles;

        Test.startTest();
        List<Local_Title__c> lstLocaTitle = [SELECT Id, Country__c FROM Local_Title__c];
        delete lstLocaTitle;
        List<Language__c> lstlanguage = [SELECT Id FROM Language__c];
        lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;
        System.assertEquals(1, lstLocaTitle.size());

        Integer countVideoProduct = 0;
        for(Product2 productInstance : tw.lstProduct){
            productInstance.NR_Product_Created__c = false;
            productInstance.Street_Date_Has_Changed__c = false;
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                productInstance.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            }
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (productInstance.Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE) {
                    productInstance.Type__c = CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE;
                    productInstance.Local_Title__c = lstLocaTitle[0].Id;
                } else if (productInstance.Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE) && countVideoProduct == 0) {
                    productInstance.Type__c = CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE;
                    productInstance.Local_Title__c = lstLocaTitle[0].Id;
                    countVideoProduct++;
                }
            }
        }
        System.debug('--tw.lstProduct-->'+tw.lstProduct);
        update tw.lstProduct;

        List<Account_Plan__c> lstAccPlanUpdate = [SELECT Id,  Country_Plan__r.NR_Product__r.Product_Market__c, Target_Quantity__c, Total_Target__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAPId = new Map<Id, Id>();
        for (Account_Plan__c acc : lstAccPlanUpdate) {
            if (acc.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
                mapAccountIdToAPId.put(acc.Customer__c, acc.Id);
            }
        }
        update lstAccPlanUpdate;

        tw.lstOpportunity = [SELECT Id, AccountId, RecordTypeId, Market_Type__c, Product_Type__c FROM Opportunity];
        for(Integer i = 0 ; i < tw.lstOpportunity.size(); i++){
            Opportunity opp = tw.lstOpportunity[i];
            String dealPeriod = '';
            Datetime sDate =
                datetime.newInstance(
                    (system.today() + 1).year(),
                    (system.today() + 1).month(),
                    (system.today() + 1).day()
                );
            String currentMonth = sDate.format('MMM');
            dealPeriod = currentMonth;
            if (opp.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
               opp.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            } else {
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(System.today() + 1);
                Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
                Date endDate = mapStartAndCloseDateForDeal.get('End Date');
                if (startDate != null && endDate != null) {
                    Datetime sDate1 =
                        datetime.newInstance(
                            startDate.year(),
                            startDate.month(),
                            startDate.day()
                        );
                    String startMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate1.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate1.format('MMM')) : sDate1.format('MMM');
                    Datetime sDate2 =
                        datetime.newInstance(
                            endDate.year(),
                            endDate.month(),
                            endDate.day()
                        );
                    String endMonth = CRM_AppConstants.NR_Deal_Japan_Month_Map.containsKey(sDate2.format('MMM')) ? CRM_AppConstants.NR_Deal_Japan_Month_Map.get(sDate2.format('MMM')) : sDate2.format('MMM');
                    dealPeriod = startMonth + '-' + endMonth;
                }
                opp.NR_Deal_Unique_Key__c = opp.AccountId + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE);
                opp.Product_Type__c = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            }
        }
        update tw.lstOpportunity;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
            if (tw.lstOpportunity[i].Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                lstDealProduct[i].Account_Plan__c = mapAccountIdToAPId.get(tw.lstOpportunity[i].AccountId);
            }
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

        List<Country_Plan__c> lstCountryPlan = [SELECT Id,Country__c, Target_Quantity__c, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; // added by ketan
            cp.Target_Quantity__c = null;
            cp.Stretch_Target__c = 10;
        }
        update lstCountryPlan;

        List<Account_Plan__c> lstAccPlan = [SELECT Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c ap : lstAccPlan) {
            ap.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccPlan;

        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Revenue__c = 5000;
        }
        update lstCountryPlan;

        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');
        System.assertEquals(3,tw.lstOpportunity.size(), 'Initial Deals');
        List<OpportunityLineItem> existingLineItems = [Select Id,Account_Price__c, Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem];
        System.assertEquals(3,existingLineItems.size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : existingLineItems) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }

        // One created for Digital and 2 created for physical
        Integer existingDigitalSchedules = 0;
        List<OpportunityLineItemSchedule> lstExistingSchedules = [Select Id, Quantity,OpportunityLineItem.Product2.RecordTypeId, Revenue, ScheduleDate, OpportunityLineItemId from OpportunityLineItemSchedule];
        System.assertEquals(3, lstExistingSchedules.size(), 'Initial Deal Product Schedule');
        Map<Id, OpportunityLineItemSchedule> existingSchedulesMap = new Map<Id, OpportunityLineItemSchedule>(lstExistingSchedules);
        for (OpportunityLineItemSchedule schedule : lstExistingSchedules) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(20, schedule.Revenue);
                System.assertEquals(system.today()+1, schedule.ScheduleDate);
                existingDigitalSchedules++;
            } else {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(0, schedule.Revenue);
                System.assertEquals(System.today() + 32, schedule.ScheduleDate, 'Product Street date');
            }
        }
        System.assertEquals(1, existingDigitalSchedules);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Total_Target__c, Country_Plan__r.Target_Revenue__c, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__r.RecordTypeId, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
                System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
                System.assertEquals(550, accountPlanInstance.Total_Target__c);
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 4
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id, Opportunity.Product_Type__c, Opportunity.Account.Video_Digital__c, Account_Plan__c, Promoted_Price__c, SAP_Promoted_Price__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(15.00, dealProduct.Account_Price__c, 'Updated Account Price');
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(37, dealProduct.Target_Quantity__c, '550 / 15 - Updated Quantity = Account Plan.Total_Target / Deal Product.AccountPrice');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        // Verify Schedules updated
        Integer digitalSchedulesAfterBatchRun = 0;
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Opportunity.Account.Music_Digital__c, OpportunityLineItem.Opportunity.AccountId, OpportunityLineItem.Opportunity.Account.Video_Digital__c ,OpportunityLineItem.Product2.RecordTypeId, Quantity, ScheduleDate, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                if (schedule.OpportunityLineItem.Opportunity.Account.Video_Digital__c || (schedule.OpportunityLineItem.Opportunity.Account.Music_Digital__c && schedule.OpportunityLineItem.Opportunity.AccountId != existingAcc.Id)) {
                    System.assertEquals(0, schedule.Revenue);
                } else {
                    System.assertEquals(20, schedule.Revenue);
                }
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(system.today()+1, schedule.ScheduleDate);
                digitalSchedulesAfterBatchRun++;
            } else {
                // No change for Physical
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(0, schedule.Revenue);
                System.assertEquals(System.today() + 32, schedule.ScheduleDate, 'Product Street date');
            }
        }
        System.assertEquals(3, digitalSchedulesAfterBatchRun);

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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

    public static testMethod void Scenario3_With_No_Existing_Deal_And_Deal_Product_Present_Italy_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

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
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE;
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
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0]; 

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

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesDigital.Target__c = 50;
        t0_GamesDigital.Target_Units__c = 2.5;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(90, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify deal and deal products are created for Scenario 3 in case of France
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Opportunity.Account.Digital_Country_Code__c,Quantity, Replen_Quantity__c, Target_Quantity__c,Initial_Quantity__c, (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            // System.assertEquals(90, dealProduct.Quantity);
            /*if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(0, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.Quantity);
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(1, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                }
            } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
                System.assertEquals(3, dealProduct.Quantity);
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(3, schedule.Quantity);
                    System.assertEquals(60, schedule.Revenue);
                }
            } else {*/
                System.assertEquals(90, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(90, dealProduct.Replen_Quantity__c);
                System.assertEquals(90, dealProduct.Quantity);
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(90, schedule.Quantity);
                    System.assertEquals(1800, schedule.Revenue);
                }
            //}
            System.assertEquals(null, dealProduct.Initial_Quantity__c);
            /*for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(90, schedule.Quantity);
                System.assertEquals(1800, schedule.Revenue);
            }*/
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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
    
    public static testMethod void Scenario1_Without_Existing_Deal_And_Target_US_GAMES_Test() {
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();

        // Change the Sales Org of Account so that Opportunity Can be deleted
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        update tw.lstAccounts;*/

        // Delete existing deals so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_WB_US_DIGITAL_COUNTRY_CODE;
            } else if (acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE;
            }
        }
        update tw.lstAccounts;

        // Verify No valid opportunity records present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        delete [SELECT Id, Account__c, Product__c, Target__c FROM Target__c];
        
        delete [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        
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

        // Verify 0 deals created for 3 digital products as no targets present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify 0 deal product records present as no targets present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
       for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
    
    public static testMethod void Scenario2_With_No_Existing_Deal_But_Deal_Product_To_Be_Cloned_Present_US_GAMES_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalFranceNRBatch_Test.createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_WB_US_DIGITAL_COUNTRY_CODE;
            } else if (acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE;
            }
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        delete [SELECT Id FROM Opportunity];
        
        // Verify 0 opportunity records present valid for Product before changing Street Date
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify 0 deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

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

        delete [SELECT Id, Account__c, Product__c, Target__c FROM Target__c];
        
        delete [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];

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

        // Verify 0 deals and deal products are created  as no targets present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is un checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
    
    public static testMethod void Scenario3_With_No_Existing_Deal_And_Deal_Product_Present_US_GAMES_Test() {

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        Set<Id> setProcessedProductIds = new Set<Id>();
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

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
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_CANADA_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_WB_CANADA_DIGITAL_COUNTRY_CODE;
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
        //p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        p0_GamesDigital = lstProduct[0]; 

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

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesDigital.Target__c = 50;
        t0_GamesDigital.Target_Units__c = 2.5;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(90, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify deal and deal products are created for Scenario 3 in case of France
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Opportunity.Account.Digital_Country_Code__c,Quantity, Replen_Quantity__c, Target_Quantity__c,Initial_Quantity__c, (SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            // System.assertEquals(90, dealProduct.Quantity);
            /*if (CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.contains(dealProduct.Opportunity.Account.Digital_Country_Code__c)) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(0, dealProduct.Replen_Quantity__c);
                System.assertEquals(1, dealProduct.Quantity);
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(1, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                }
            } else if (dealProduct.Opportunity.Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE) {
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Replen_Quantity__c);
                System.assertEquals(3, dealProduct.Quantity);
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(3, schedule.Quantity);
                    System.assertEquals(60, schedule.Revenue);
                }
            } else {*/
                System.assertEquals(90, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(90, dealProduct.Replen_Quantity__c);
                System.assertEquals(90, dealProduct.Quantity);
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(90, schedule.Quantity);
                    System.assertEquals(1800, schedule.Revenue);
                }
            //}
            System.assertEquals(null, dealProduct.Initial_Quantity__c);
            /*for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(90, schedule.Quantity);
                System.assertEquals(1800, schedule.Revenue);
            }*/
        }
        
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
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
}