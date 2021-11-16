/*
   @Author Aditi Satpute
   @name CRM_AutoPhysicalGermanyNRBatch_Test
   @CreateDate 6 Jun 2016
   @Description Test class for CRM_AutoPhysicalGermanyNRBatch
   @Version <1.0>
   @reference Requirement no 352
  */
  
@isTest
public with sharing class CRM_AutoPhysicalGermanyNRBatch_Test {

    public static CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper createData() {
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_GERMANY_DIGITAL_COUNTRY_CODE;
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
            }
            if (acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_SWEDEN_DIGITAL_COUNTRY_CODE;
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_SWEDEN_CODE;
            }
            if (acc.Video_Physical__c) {
                acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_SWEDEN_CODE;
            } 
            if (acc.Games_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
            }
        }
        update tw.lstAccounts;

        for (Integer i = 0; i < tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            String dealPeriod;
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
                Integer currentQtr =
                    Decimal.valueOf(
                        (system.today() + 30).toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = 'Q' + currentQtr;
            } else {
                Datetime sDate =
                    datetime.newInstance(
                        (system.today() + 30).year(),
                        (system.today() + 30).month(),
                        (system.today() + 30).day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
            }

            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
        }
        update tw.lstOpportunity;

        for (Product2 prod : tw.lstProduct) {
            prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
            prod.Street_Date__c = system.today() + 30;
            prod.Release_Category__c = null;
        }
        update tw.lstProduct;

        List<Pricebook_Entry_Period__c> lstPBEP = tw.lstPriceBookEntryPeriod;
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+30;
            lstPBEP[i].End_Date__c = System.today() +40;
        }
        update lstPBEP;

        List<Account_Plan__c> lstAccountPlan = [
            SELECT Id 
            FROM Account_Plan__c 
            WHERE 
                Customer__r.Sales_Organization__c =: CRM_AppConstants.TERRITORY_GERMANY_CODE 
                OR Customer__r.Digital_Country_Code__c =: CRM_AppConstants.ACCOUNT_GERMANY_DIGITAL_COUNTRY_CODE
                OR Customer__r.Digital_Country_Code__c =: CRM_AppConstants.ACCOUNT_SWEDEN_DIGITAL_COUNTRY_CODE
            ];
        if (lstAccountPlan.size() > 0) {
            System.assertEquals(4, lstAccountPlan.size());
            delete lstAccountPlan;
        }
        System.assertEquals(5, tw.lstTargets.size());

        Date startDate = (System.today() + 30).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        tw.lstTargets = [SELECT Id, Account_Plan_Lookup__c, GL_Calendar__c, Target__c, Account__c, Product__c FROM Target__c ORDER By CreatedDate];
        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
            target.Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE;
        }
        update tw.lstTargets;
        return tw;
    }

 
    public static testMethod void Scenario1_With_Existing_Deal_And_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 2 deal product records for 2 physical products should be created through batch
        List<OpportunityLineItem> lstLineItem = [SELECT Id, Target_Quantity__c FROM OpportunityLineItem];
        System.assertEquals(2, lstLineItem.size());
        for (OpportunityLineItem dealProduct : lstLineItem) {
            System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } /*else {
                System.assert(productInstance.NR_Product_Created__c);
            }*/
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario1_With_Existing_Deal_And_Target_With_Revenue_0_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        List<Target__c> lstTarget = [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c];
        for (Target__c targetInstance : lstTarget) {
            targetInstance.Target__c = 0;
        }
        update lstTarget;

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 2 deal product records for 2 physical products should be created through batch
        List<OpportunityLineItem> lstLineItem = [SELECT Id, Target_Quantity__c FROM OpportunityLineItem];
        System.assertEquals(2, lstLineItem.size());
        for (OpportunityLineItem oppLineItem : lstLineItem) {
            System.assertEquals(0, oppLineItem.Target_Quantity__c);
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } /*else {
                System.assert(productInstance.NR_Product_Created__c);
            }*/
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
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
            createData();

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify 2 deal product records for 2 physical products should be created through batch
        List<OpportunityLineItem> lstLineItem = [SELECT Id, Target_Quantity__c FROM OpportunityLineItem];
        System.assertEquals(2, lstLineItem.size());
        for (OpportunityLineItem dealProduct : lstLineItem) {
            System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } /*else {
                System.assert(productInstance.NR_Product_Created__c);
            }*/
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    /*public static testMethod void Scenario1_With_Existing_Committed_Deal_And_Target_Test(){

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
            createData();

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update oppList;
        }

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name is still same
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify 2 deal product records for 2 physical products should be created through batch
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

    public static testMethod void Scenario1_Without_Existing_Deal_And_Target_Test(){
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Change the Sales Org of Account so that Opportunity Can be deleted
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            acc.No_Pricing__c = true;
            acc.No_Demand__c = true;
        }
        update tw.lstAccounts;

        for(Product2 p : tw.lstProduct){
            p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;

        List<Product2> lstPhysicalProduct = [SELECT Id, Street_Date__c FROM Product2 WHERE RecordType.DeveloperName = 'Product'];
        System.assertEquals(2, lstPhysicalProduct.size());
        Product2 invalidTargetPhysicalProduct = lstPhysicalProduct[0];

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        GL_Calendar__c glcalendar2 = new GL_Calendar__c(
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            Name = System.today().year() + '-' + System.today().month(),
            Month__c = String.valueOf(System.today().month()), 
            Year__c = String.valueOf(System.today().year())
        );
        insert new List<GL_Calendar__c>{glcalendar1, glcalendar2};
        System.assert(glcalendar1.Id != null);

        // Set incorrect target for one physical product
        for (Target__c target : tw.lstTargets) {
            if (invalidTargetPhysicalProduct.id == target.Product__c) {
                target.GL_Calendar__c = glcalendar2.Id;
            } else {
                target.GL_Calendar__c = glcalendar1.Id;
            }
        }
        update tw.lstTargets;

        // Delete existing deals so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        }
        update tw.lstAccounts;

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;

        // Verify No valid opportunity records present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products are newly created due to which it will be considered for batch processing
        for (Product2 productInstance : tw.lstProduct) {
            System.assert(productInstance.NR_Product_Created__c);
            System.assert(!productInstance.Street_Date_Has_Changed__c);
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify only 1 opportunity record is created for 1 physical product with valid range of target
        System.assertEquals(1, [SELECT Id FROM Opportunity].size());

        // Verify 1 deal product record for 1 physical product with valid range of target should be Cloned and created through batch
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Quantity, Product2Id, Opportunity.No_Pricing__c, Opportunity.No_Demand__c, Target_Quantity__c,Opportunity.AccountId,Account_Price__c FROM OpportunityLineItem]) {
            System.assertNotEquals(invalidTargetPhysicalProduct.Id, dealProduct.Product2Id);
            System.assertEquals(20, dealProduct.Account_Price__c);
            System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
            System.assertEquals(true, dealProduct.Opportunity.No_Demand__c);
            System.assertEquals(true, dealProduct.Opportunity.No_Pricing__c);
            System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario1_With_Existing_Deal_And_No_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Remove Account Plan so no Targets present for calculation and Deal Products created with Quantity 1
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

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product created through batch as no targets present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());
        /*for (OpportunityLineItem dealProduct : [SELECT Id, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assertEquals(1, dealProduct.Quantity, 'No Targets so Quantity should be 1');
            System.assertEquals(1, dealProduct.Target_Quantity__c, 'No Targets so Quantity should be 1');
        }*/

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } /*else {
                System.assert(productInstance.NR_Product_Created__c);
            }*/
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario1_Without_Existing_Deal_And_No_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Change the Sales Org of Account so that Opportunity Can be deleted
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        update tw.lstAccounts;

        // Delete existing deals so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        }
        update tw.lstAccounts;

        // Verify No valid opportunity records present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Remove Targets present for calculation so Deal Products created with Quantity 1
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

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no deals created as no targets present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product reated through batch as no targets present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());
        /*for (OpportunityLineItem dealProduct : [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem]) {
            System.assertEquals(1, dealProduct.Quantity, 'No Targets so Quantity should be 1');
            System.assertEquals(1, dealProduct.Target_Quantity__c, 'No Targets so Quantity should be 1');
        }*/

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } /*else {
                System.assert(productInstance.NR_Product_Created__c);
            }*/
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Test(){
    
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

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
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(10, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId,Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                
                // Verify these deal products are linked with new deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Planned_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        Date startDate = (System.today() + 140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date__c = system.today()+140;
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // Verify existing deal Products present for existing deals
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // 2 additional deals created for Physical Products
        System.assertEquals(7, [SELECT Id FROM Opportunity].size());

        // Verify deal Products are cloned even if the deal Stage is not NR Default and existing deal products deleted
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Quantity as it is entered and it is not recalculated');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity should be recalculated');

                // Verify deals products are now not related to existing deals as these are cloned and attached to new deal
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Committed_Future_Deal_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
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
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

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
            for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
                Opportunity d0_existingDeal = tw.lstOpportunity[i];
                d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update tw.lstOpportunity;
        }
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // Verify existing deal Products present for existing deals
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // No additional deals created as no valid PBEP found
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }


        // Verify deal Products are not cloned but deleted even if deal Stage is non NR Default
        Integer countPhysical = 0;
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                countPhysical++;
            }
        }
        System.assertEquals(0, countPhysical);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Committed_Non_Future_Deal_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

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
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

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
            for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
                Opportunity d0_existingDeal = tw.lstOpportunity[i];
                d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update tw.lstOpportunity;
        }
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        // Verify existing deal Products present for existing deals
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // No additional deals created as no valid PBEP found
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify deal Products are not cloned but deleted even if deal Stage is non NR Default
        Integer countPhysical = 0;
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                countPhysical++;
            }
        }
        System.assertEquals(0, countPhysical);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_With_Stage_Changed_And_Deal_Product_To_Be_Cloned_Present_Test(){

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

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
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify additional opportunity records are not created even if valid Deal Stage is changed to Non NR Default
        System.assertEquals(10, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        Integer countPhysical = 0;
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                countPhysical ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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
            createData();

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
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
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

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        Integer countPhysical = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsAfterBatchRun.size());

        // Verify Last Modified Dates are changed
        /*for (Integer j = 0; j < dealProductsAfterBatchRun.size(); j++) {
            OpportunityLineItem newDealProductInstance = dealProductsAfterBatchRun[j];
            OpportunityLineItem oldDealProductInstance = dealProductsBeforeBatchRun[j];
            System.debug('--oldDealProductInstance-->'+oldDealProductInstance);
            System.debug('--newDealProductInstance-->'+newDealProductInstance);
            if (newDealProductInstance.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertNotEquals(oldDealProductInstance.LastModifiedDate, newDealProductInstance.LastModifiedDate);
            }
        }*/

        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                countPhysical ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    /*public static testMethod void Scenario2_With_Existing_Deal_With_Stage_Committed_And_Deal_Product_To_Be_Cloned_Present_Test(){

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
            createData();

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
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify additional opportunity records are not created even if valid Deal Stage is changed to Non NR Default
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        Integer countPhysical = 0;
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                countPhysical ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

    public static testMethod void Scenario2_With_Existing_Deal_And_No_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity deal = tw.lstOpportunity[i];
            String dealPeriod = '';
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Release Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no additional opportunity records created
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 2 deal product records for 2 physical products should be Cloned and created through batch
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Initial_Quantity__c, Opportunity.Account.Sales_Organization__c, Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                if (dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWEDEN_CODE) {
                    System.assertEquals(3, dealProduct.Quantity, 'Should be changed');
                    System.assertEquals(3, dealProduct.Initial_Quantity__c);
                } else {
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                    System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Should not be changed');
                }
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_No_Existing_Deal_But_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        Set<String> setAccountIdAndProductId = new Set<String>();

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date__c = system.today()+140;      
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 2 additional deals are created for physical products based on new street date
        System.assertEquals(7, [SELECT Id FROM Opportunity].size());
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Id NOT IN: tw.lstOpportunity]);

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Published Target / Account Price (50/20)');

                // Verify these deal products are linked with new deals different based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_No_Existing_Deal_And_No_Deal_Product_To_Be_Cloned_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        Set<String> setAccountIdAndProductId = new Set<String>();
        
        for(Product2 p : tw.lstProduct){
            p.NR_Product_Created__c = false;
            p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Change the Sales Org of Account so that Opportunity Can be deleted
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        update tw.lstAccounts;

        delete tw.lstOpportunity;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        }
        update tw.lstAccounts;

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify 2 opportunity records created for 2 physical products
        System.assertEquals(2, [SELECT Id FROM Opportunity].size());

        // Verify 2 deal product records for 2 physical products should be Cloned and created through batch
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
            System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_With_Existing_Deal_And_Deal_Product_Present_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
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
            lstDealProduct[i].Promoted_Price__c = 20;
            lstDealProduct[i].ListPrice__c = 15;
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

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Account Plan flags are not set
        for (Account_Plan__c accPlanInstance : [SELECT Id,Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assert(!accPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false');
        }

        // Verify Target flags are set
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Target flags are reset properly after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_With_No_Existing_Deal_And_Deal_Product_Present_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
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
        Product2 p0_GamesPhysical = lstProduct[0];
        p0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
        p0_GamesPhysical.Street_Date__c = System.today() + 30;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = new List<Account_Plan__c>();

        Date startDate = (system.today()+30).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesPhysical.Target__c = 200;
        t0_GamesPhysical.GL_Calendar__c = glcalendar1.Id;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodCreated
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c existingDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        existingDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        existingDealPriceBookPeriod.Start_Date__c = System.today()-40;
        existingDealPriceBookPeriod.End_Date__c = System.today()-40;
        existingDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        existingDealPriceBookPeriod.List_Price__c = 10;

        lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c streetDateChangeCurrentMonthDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        streetDateChangeCurrentMonthDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        streetDateChangeCurrentMonthDealPriceBookPeriod.Start_Date__c = (System.today() + 30).toStartOfMonth();
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+140;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        // Verify Process NR Batch checkbox is checked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is no Scenario 1 and 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify new deal and deal products are created for Scenario 3
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());

        // Verify Target flags are reset properly after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

   /* public static testMethod void Scenario3_And_Scenario4_With_Existing_Deal_And_Deal_Product_Present_And_List_Price_Changed_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
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

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target_Units__c = 10;
            tw.lstTargets[i].Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_QUANTITY;
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assertEquals(20, pbep.List_Price__c);
            }
        }

        // Verify Target flags are set as true such that there is Scenario 3 condition
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        // Change the List price of PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c];
        for(Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.List_Price__c = 10;
        }
        update lstPBEP;

        // Verify Process NR Batch checkbox is checked and List Price is also changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c,Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assertEquals(10, pbep.List_Price__c);
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                system.debug('Inside===========1==========');
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Updated Account Price');
                System.assertEquals(1, dealProduct.Quantity, 'Should not change');
                System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity = AP Target Quantity');
                
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Target flags are reset properly after batch processing
        List<Target__c> lstTargetsFetch = [SELECT Id, Account__c, Planned__c,Target_Maintained_As__c,Target_Units__c,Target__c,Account_Price__c,
                                                Product__c, Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Target__c];
      
        for (Target__c targetInstance : lstTargetsFetch) {
            system.debug('target======================>'+targetInstance);
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                 system.debug('Inside========2============='+targetInstance.Target_Revenue_Has_Changed__c);
                targetInstance.Planned__c = 10;
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }
        update lstTargetsFetch;

        for (Target__c targetInstance : [SELECT Id, Account__c, Planned__c, Product__c, Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(100, targetInstance.Target__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c,Product__r.RecordTypeId FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

    public static testMethod void Scenario4_With_Existing_Deal_And_Deal_Product_Present_And_List_Price_Changed_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
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

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target_Units__c = 10;
            tw.lstTargets[i].Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_QUANTITY;
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c, Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
                System.assertEquals(20, pbep.List_Price__c);
            }
        }

        // Verify Target flags are set as false such that there is no Scenario 3 condition
        List<Target__c> lstTarget = [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c];
        for (Target__c targetInstance : lstTarget) {
            System.assertEquals(200, targetInstance.Target__c);
            targetInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstTarget;

        // Change the List price of PBEP
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Process_NR_Batch__c FROM Pricebook_Entry_Period__c];
        for(Pricebook_Entry_Period__c pbep : lstPBEP) {
            pbep.List_Price__c = 10;
        }
        update lstPBEP;

        // Verify Process NR Batch checkbox is checked and List Price is also changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c,Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
                System.assertEquals(10, pbep.List_Price__c);
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c, Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Updated Account Price');
                System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity = AP Target Quantity');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Target flags are reset properly after batch processing
        List<Target__c> lstTargetsFetch = [SELECT Id, Account__c, Planned__c, Product__c, Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c];
        for (Target__c targetInstance : lstTargetsFetch) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                targetInstance.Planned__c = 10;
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }
        update lstTargetsFetch;

        for (Target__c targetInstance : [SELECT Id, Account__c, Planned__c, Product__c, Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(100, targetInstance.Target__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c,Product__r.RecordTypeId FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void NR_Product_Creation_With_No_Deal_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();

        // Change the Sales Org of Account so that Opportunity Can be deleted
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        update tw.lstAccounts;

        // Delete existing deals so that no existing NR deals present in database
        delete tw.lstOpportunity;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        }
        update tw.lstAccounts;

        Map<Id,List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id,List<Account_Plan__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+30;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+10).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        // Create PricebookEntryPeriod which is not valid for the Product
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+140;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+160;
        }
        update tw.lstPriceBookEntryPeriod;

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify no deal and deal product is created
        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'New Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
    

    public static testMethod void Street_Date_Changed_With_Existing_Schedules_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Map<Id,List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id,List<Account_Plan__c>>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');
		
        
        Test.startTest();
        
        
        Date startDate = (system.today()+40).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

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
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+160;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+170;
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
		
        
        
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        
        Test.stopTest();
        
        // Verify No new Deal is created as no valid PBEP found
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');

        // Verify no new Deal Product is cloned and created but the existing deal product that was supposed to be cloned gets deleted
        System.assertEquals(3,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify no physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c,Product2.Type__c,NR_Deal_Product_Unique_Key__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            if (dealProducts.Product2.Type__c.contains('Physical')) {
                System.assertEquals(1, dealProducts.Quantity);
                System.assertEquals(10, dealProducts.Target_Quantity__c);
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(0, clonedDealProductsCount);

        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity from OpportunityLineItemSchedule];
        System.assertEquals(3, schedules.size(), 'No Deal Product Schedule for Physical');

        // Verify Target flags are reset
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    
    }

    public static testMethod void Target_Revenue_Changed_With_Existing_Deal_And_Deal_Product_And_No_Valid_PBEP_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
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
        }
        update tw.lstPriceBookEntryPeriod;

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBEP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c, Account_Price__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }  

        // Verify Process NR  flags are reset as we are checking only Scenario 3 when all Scenario 1, 2 ,4 are already executed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c, Account_Price__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Target_Revenue_AND_PBEP_Start_Date_Changed_With_Existing_Deal_And_Deal_Product_And_No_Valid_PBEP_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        // Verify Process NR  flags are set as we are checking  Scenario 3 along with Scenario 4
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void PBEP_Start_Date_Changed_With_Existing_Deal_And_Deal_Product_And_No_Valid_PBEP_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset as we are checking only Scenario 4 when all Scenario 1, 2 ,3 are already executed
        List<Target__c> lstTarget = [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c];
        for (Target__c targetInstance : lstTarget) {
            System.assertEquals(200, targetInstance.Target__c);
            targetInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstTarget;

        // Verify Process NR Batch checkbox is checked as Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Negative_Test_SendMail_With_RecordId() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
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
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Target flags are reset properly after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(p.NR_Product_Created__c, 'True as there is error');
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 1
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Negative_Test_SendMail_Without_RecordId() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
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
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Target flags are reset properly after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c, 'False as there is no record Id present in error');
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 1
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Negative_Test_ResetProcessedProductFlags() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
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

    /*public static testMethod void Negative_Test_ResetProcessedTargetFlags() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        List<Target__c> lstTarget = [SELECT Id, Account__c, Product__c FROM Target__c];
        System.assertEquals(5, lstTarget.size());

        for(Target__c target : lstTarget){
            automaticNRDealCreationBatch.setProcessedProductIds.add(target.Product__c);
            target.CurrencyIsoCode = 'AAAA';
        }

        System.assert(automaticNRDealCreationBatch.setProcessedProductIds.size() > 0);
        System.assert(automaticNRDealCreationBatch.lstExceptions.isEmpty());

        Test.startTest();
        automaticNRDealCreationBatch.resetProcessedTargetFlags(lstTarget, automaticNRDealCreationBatch.setProcessedProductIds);
        test.stopTest();

        System.assertEquals(0, automaticNRDealCreationBatch.setProcessedProductIds.size());
        System.assert(!automaticNRDealCreationBatch.lstExceptions.isEmpty());
    }*/

    public static testMethod void Negative_Test_ResetProcessedPBEPFlags() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        List<Target__c> lstTarget = [SELECT Id FROM Target__c];
        System.assertEquals(5, lstTarget.size());

        for(Pricebook_Entry_Period__c pbep : tw.lstPricebookEntryPeriod){
            pbep.CurrencyIsoCode = 'ABC';
        }

        System.assert(automaticNRDealCreationBatch.lstExceptions.isEmpty());

        Test.startTest();
        automaticNRDealCreationBatch.resetProcessedPBEPFlags(tw.lstPricebookEntryPeriod);
        test.stopTest();

        System.assert(!automaticNRDealCreationBatch.lstExceptions.isEmpty());
    }

    public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario_2_And_3_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        for (Account acc : tw.lstAccounts) {
            acc.No_Demand__c = true;
        }
        update tw.lstAccounts;

        // Previous Street Date not Specified
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

        Date startDate = (system.today()+40).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        for(Product2 p : tw.lstProduct){
            p.Previous_Street_Date__c = null;
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
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

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

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        //System.assertEquals(5, automaticNRDealCreationBatch.lstExceptions.size());
        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify 2 physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Opportunity.No_Pricing__c, Opportunity.No_Demand__c, Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity);
                //System.assertEquals(0, dealProduct.Target_Quantity__c);
                System.assertEquals(10, dealProduct.Target_Quantity__c);

                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(false, dealProduct.Opportunity.No_Pricing__c);
                System.assertEquals(true, dealProduct.Opportunity.No_Demand__c);
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);

        // Verify Target flags are not reset after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Product flags are not reset properly after batch processing
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c, 'True as there is error');
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

    public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario2_3_With_Batch_ReRun_Test(){

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        // Previous Street Date not Specified
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

        Date startDate = (system.today()+40).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        for(Product2 p : tw.lstProduct){
            p.Previous_Street_Date__c = null;
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
            tw.lstTargets[i].Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lstLineItem = [Select (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules), Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem];
        System.assertEquals(5, lstLineItem.size(), 'Initial Deal Products');

        // Verify the Quantity is update after creating Schedules
        for (OpportunityLineItem dealProducts : lstLineItem) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(21, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
            for(OpportunityLineItemSchedule schedule : dealProducts.OpportunityLineItemSchedules) {
                System.assertEquals(21, schedule.Quantity);
                System.assertEquals(system.today(), schedule.ScheduleDate);
            }
        }

        Test.startTest();
//        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
//        Test.stopTest();

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItemSchedule].size(), 'Digital Schedules deleted');

        // Verify Target flags are not reset after batch processing
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Flags are not reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as Scenario 2 present
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                /*System.assertEquals(21, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);*/
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);

        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch1,10);
        Test.stopTest();
        
        // No new deal / Deal Product is created
        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify Flags are reset
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Flags are reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is reset
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario2_With_Batch_ReRun_Test(){

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        Set<String> productToAccountIdSet = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        // Previous Street Date not Specified
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

        Date startDate = (system.today()+40).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        for(Product2 p : tw.lstProduct){
            p.Previous_Street_Date__c = null;
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
            tw.lstTargets[i].Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

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

        // As we are checking only Scenario 4 so make Target Revenue flag as false
        List<Target__c> lstTarget = [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c];
        for (Target__c targetInstance : lstTarget) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                targetInstance.Target_Revenue_Has_Changed__c = false;
            }
        }
        update lstTarget;

        Test.startTest();
//        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
//        Test.stopTest();

        // Verify Target flags are reset
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Flags are not reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked due to Scenario 2 present
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Integer clonedDealProductsCount = 0;
        List<OpportunityLineItem> lstLineItems = [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ];
        System.assertEquals(5, lstLineItems.size(), 'Initial Deal Products');

        for (OpportunityLineItem dealProduct : lstLineItems) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                /*System.assertEquals(21, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);*/
                clonedDealProductsCount++;
            } else {
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
            }
        }
        System.assertEquals(2, clonedDealProductsCount);

        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch1,10);
        Test.stopTest();
        
        // No new deal / Deal Product is created
        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify Flags are reset
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Flags are reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is reset
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

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

        Set<String> setProductAndAccountIdSet = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        // Method to create Dummy Data

        // Setting Up the Sold To Account Data with 'Games Physical Type'
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(1);
        System.assertEquals(1, lstAccounts.size());
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        update lstAccounts;
        Account soldToAccount = lstAccounts[0];

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

        // Setting Up the Product data with Type Games Physical
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(), false);
        for(Product2 p : lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
           p.Street_Date_Has_Changed__c = true;
           p.CurrencyIsoCode = 'USD';
           p.Local_Title__c = lstLocaTitle[0].Id;
           p.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
           p.Type__c = 'Games Physical';
           p.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
           p.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        }
        insert lstProduct;

        Date startDate = (system.today()+40).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        System.assertEquals(1, lstProduct.size());
        for(Product2 p : lstProduct){
            p.NR_Product_Created__c = false;
        }
        update lstProduct;

        // Setting up 1 Target data for each Account and Product created
        List<Account_Plan__c> lstAccountPlan = new List<Account_Plan__c>();
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp, lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 100;
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = lstProduct[i].id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            lstTargets[i].Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE;
            lstTargets[i].GL_Calendar__c = glcalendar1.Id;
        } 
        insert lstTargets;
        System.debug('lstTargets::'+lstTargets);

        // Create a Map of Target data before updating the target because the batch will run with these Target
        // data and will have the previous version

        List<Target__c> lstTarget = [SELECT Id, Account__c,NR_Version__c, Product__r.RecordTypeId, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c];
        for (Target__c targetInstance : lstTarget) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(100, targetInstance.Target__c);
                System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
                setProductAndAccountIdSet.add(targetInstance.Product__c + '-' + targetInstance.Account__c);
            }
        }

        // Setting up 1 Price Book Entry record for each created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.assertEquals(1, lstPriceBookEntryPeriod.size());
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            lstPriceBookEntryPeriod[i].Start_Date__c = (System.today()-60).toStartOfMonth();
            lstPriceBookEntryPeriod[i].End_Date__c = System.today() +100;
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
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
        System.assertEquals(1, [Select Id, NR_Version__c from Target__c][0].NR_Version__c);
        System.assertEquals(lstTarget[0].NR_Version__c, [Select Id, NR_Version__c from Target__c][0].NR_Version__c);

        System.assertEquals(1, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(1, [Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(0, [Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');
        System.assertEquals(system.today() + 40, lstProduct[0].Street_Date__c);
        // Run the batch such that while running the Product Street Date / Target Revenue has been modified
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProduct , mapIdToPBEPList, setProcessedProductIds );

        // Verify New Deal for changed Street Date gets created
        Map<String, Date> mapStartAndCloseDateForDeal =
            CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(lstProduct[0].Street_Date__c, 'Q');

        Datetime sDate =
                datetime.newInstance(
                    (lstProduct[0].Street_Date__c).year(),
                    (lstProduct[0].Street_Date__c).month(),
                    (lstProduct[0].Street_Date__c).day()
                );
        String currentMonth = sDate.format('MMM');
        List<Opportunity> fetchedDealsWithLatest = [Select Id, Name, NR_Deal_Unique_Key__c from Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(2, fetchedDealsWithLatest.size(), 'New Deals');
        Opportunity newlyCreatedOpportunity = new Opportunity();
        Map<Id, Opportunity> mapExistingDeals = new Map<Id, Opportunity>(fetchedDealsWithLatest);
        System.debug('-fetchedDealsWithLatest--->'+fetchedDealsWithLatest);
        for (Opportunity deal : fetchedDealsWithLatest) {
            if (deal.NR_Deal_Unique_Key__c != null && deal.Id != lstOpportunity[0].Id) {
                newlyCreatedOpportunity = deal;
                System.assertEquals('New Releases Games Physical '+currentMonth+' '+(system.today() + 40).year()+' ' + soldToAccount.Name, deal.Name);
            }
        }

        // Deal Product is cloned and attached to new deal thats why the count of Deal Products is still one
        // Verify the records created with previous StreetDate / Revenue change even if the
        // Street Date / Target Revenue was changed while batch was running
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId,Quantity,Target_Quantity__c, Opportunity.Name, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(1, dealProducts.size(), 'New Deal Products');
        System.assertEquals(1, dealProducts[0].Quantity);
        System.assertEquals(5, dealProducts[0].Target_Quantity__c);
        System.assertEquals(newlyCreatedOpportunity.Id, dealProducts[0].OpportunityId, 'New Deal Products');

        // As the Batch is running the Version is updated due to change in Street Date and Target Revenue
        List<Product2> lstProductWithVersion = new List<Product2>();
        for(Product2 p : [Select Id, NR_Version__c from Product2]){
            p.Street_Date__c = System.today()+140;
//            p.NR_Product_Created__c = false;
            lstProductWithVersion.add(p);
        }
        update lstProductWithVersion;
        List<Product2> updatedProducts = [Select Id, NR_Version__c,Street_Date__c from Product2];
        System.assertEquals(1, updatedProducts.size());
        System.assertEquals(system.today() + 140, updatedProducts[0].Street_Date__c);

        System.assertEquals(0, [Select Id, NR_Version__c from Target__c][0].NR_Version__c);
        List<Target__c> lstTargetWithVersion = new List<Target__c>();
        Date startDate1 = (system.today()+140).toStartOfMonth();
        Date endDate1 = startDate1.addDays(Date.daysInMonth(startDate1.year(), startDate1.month())-1);
        GL_Calendar__c glcalendar2 = new GL_Calendar__c(
            Start_Date__c = startDate1,
            End_Date__c = endDate1,
            Name = startDate1.year() + '-' + startDate1.month(),
            Month__c = String.valueOf(startDate1.month()), 
            Year__c = String.valueOf(startDate1.year())
        );
        insert glcalendar2;
        System.assert(glcalendar2.Id != null);

        for(Target__c t : [Select Id,Target__c, Account_Plan_Lookup__c, NR_Version__c from Target__c]){     // new field ('Account_Plan_Lookup__c') added to the select query by Hrushikesh
           t.Target__c = 200;
           t.GL_Calendar__c = glcalendar2.Id;
           lstTargetWithVersion.add(t);
        }
        update lstTargetWithVersion;

        List<Target__c> lstTargetToUpdate = [Select Id, NR_Version__c from Target__c];
        System.assertEquals(1, lstTargetToUpdate.size());
        //lstAccountPlanToUpdate[0].NR_Version__c = 2;
        //update lstAccountPlanToUpdate;

        System.assertEquals(1, [Select Id, NR_Version__c from Product2][0].NR_Version__c);
        System.assertEquals(1, [Select Id, NR_Version__c from Target__c][0].NR_Version__c);
        System.assertNotEquals(lstProduct[0].NR_Version__c, [Select Id, NR_Version__c from Product2][0].NR_Version__c);
        //System.assertNotEquals(lstTarget[0].NR_Version__c, [Select Id, NR_Version__c from Target__c][0].NR_Version__c);

        // As Version was changed Verify the Checkboxes (StreetDate changed and Target Revenue Changed) is still true even
        // when the batch was processed successfully
        System.assertEquals(true, [Select Id, Street_Date_Has_Changed__c from Product2][0].Street_Date_Has_Changed__c);
        System.assertEquals(true, [Select Id, Target_Revenue_Has_Changed__c from Target__c][0].Target_Revenue_Has_Changed__c);

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        // Run the batch again and in this batch only the Product whose street Date / Target whose Revenue was modified
        // during previous batch was running will be considered
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch2 = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch2,1);
        Test.stopTest();

        // Verify a new Deal gets created For the Street Date Changed
        Map<String, Date> mapStartAndCloseDateForDeal1 =
            CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(
                updatedProducts[0].Street_Date__c, 'Q'
            );

        Datetime sDate1 =
                datetime.newInstance(
                    (updatedProducts[0].Street_Date__c).year(),
                    (updatedProducts[0].Street_Date__c).month(),
                    (updatedProducts[0].Street_Date__c).day()
                );
        String currentMonth1 = sDate1.format('MMM');
        List<Opportunity> fetchedDealsWithLatest1 = [Select Id,AccountId,NR_Deal_Unique_Key__c, Name from Opportunity ORDER BY CreatedDate, Promo_Start_Date__c DESC];
        System.assertEquals(3, fetchedDealsWithLatest1.size(), 'New Deals');
        System.debug('-fetchedDealsWithLatest1--->'+fetchedDealsWithLatest1);

        Opportunity newlyCreatedOpportunity1 = new Opportunity();
        for (Opportunity deal : fetchedDealsWithLatest1) {
            if (deal.NR_Deal_Unique_Key__c != null && deal.AccountId == soldToAccount.Id && !mapExistingDeals.containsKey(deal.Id)) {
                newlyCreatedOpportunity1 = deal;
             }
        }
        System.assertEquals('New Releases Games Physical '+currentMonth1+' '+(system.today() + 140).year()+' ' + soldToAccount.Name, newlyCreatedOpportunity1.Name);

        // Deal Product is cloned and attached to new deal with updated Quantity thats why the count is still one
        // Verify the deal Product is cloned to the deal with changed StreetDate and updated with Quantity calculated based on Target Revenue
        // which was changed while batch was running previously
        List<OpportunityLineItem> fetchedDealProducts = [Select Id,Quantity, Target_Quantity__c, OpportunityId, Opportunity.Name, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(1, fetchedDealProducts.size(), 'New Deal Products');
        System.assertEquals(newlyCreatedOpportunity1.Id, fetchedDealProducts[0].OpportunityId);
        System.assertEquals(1, fetchedDealProducts[0].Quantity);
        System.assertEquals(10, fetchedDealProducts[0].Target_Quantity__c);

        // Verify the Version and the checkboxes has been reset
        System.assertEquals(false, [Select Id, Street_Date_Has_Changed__c from Product2][0].Street_Date_Has_Changed__c);
        System.assertEquals(false, [Select Id, Target_Revenue_Has_Changed__c from Target__c][0].Target_Revenue_Has_Changed__c);
        System.assertEquals(0, [Select Id, NR_Version__c from Product2][0].NR_Version__c);
        System.assertEquals(0, [Select Id, NR_Version__c from Target__c][0].NR_Version__c);

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
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
            createData();

        // Update Accounts to make all as Physical
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
            lstAccounts[i].Storefront__c = null;
            if (i == 0) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 1) {
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 2) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 3) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 4) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
            }
        }
        update lstAccounts;

        List<Local_Title__c> lstLocaTitle = [SELECT Id FROM Local_Title__c];
        System.assertEquals(1, lstLocaTitle.size());

        // Update Products to make all as Physical
        List<Product2> lstProduct = tw.lstProduct;
        System.assertEquals(5, lstProduct.size());
        for(Integer i=0; i<lstProduct.size(); i++){
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
            lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }else if (i == 2) {
                lstProduct[i].Type__c = 'Video Physical';
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Physical';
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }
        }
        update lstProduct;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = tw.lstPriceBookEntryPeriod;
        System.assertEquals(5, lstPriceBookEntryPeriod.size());

        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = lstProduct[i].id;
            lstPriceBookEntryPeriod[i].New_Release__c = false;
        }
        update lstPriceBookEntryPeriod;

        // Make the deal as Committed
        System.runas(testUser) {
            // Change the Sales Org of Account so that Opportunity Can be deleted
            /*for (Account acc : lstAccounts) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            }
            update lstAccounts;

            // Delete existing deals so that no existing NR deals present in database
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            delete oppList;

            // After deleting opportunities again make the Sales Org as Germany
            for (Account acc : lstAccounts) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
                acc.Digital_Country_Code__c = null;
            }
            update lstAccounts;

            oppList = CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
            System.assertEquals(5, oppList.size());*/

            tw.lstOpportunity[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            tw.lstOpportunity[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            tw.lstOpportunity[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            tw.lstOpportunity[3].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;
            tw.lstOpportunity[4].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            for (Integer i = 0; i < tw.lstOpportunity.size(); i++) {
                String dealPeriod = '';
                Opportunity d0_existingDeal = tw.lstOpportunity[i];
                Date dealStartDate = system.today() + 30;
                Date dealEndDate = system.today() + 60;

                d0_existingDeal.Start_Date__c = dealStartDate;
                d0_existingDeal.CloseDate = dealEndDate;
                d0_existingDeal.Promo_Start_Date__c = dealStartDate;
                d0_existingDeal.Promo_End_Date__c = dealEndDate;
                if (
                    lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE  ||
                    lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE
                ) {
                    Integer currentQtr =
                        Decimal.valueOf(
                            (dealStartDate).toStartOfMonth().month()
                        ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                    dealPeriod = 'Q' + currentQtr;
                } else {
                    Datetime sDate =
                        datetime.newInstance(
                            (dealStartDate).year(),
                            (dealStartDate).month(),
                            (dealStartDate).day()
                        );
                    String currentMonth = sDate.format('MMM');
                    dealPeriod = currentMonth;
                }

                d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                d0_existingDeal.Product_Type__c = lstProduct[i].Type__c;
                d0_existingDeal.NR_Deal_Unique_Key__c = lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(lstProduct[i].Type__c);
            }
            update tw.lstOpportunity;
        }

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, NR_Deal_Unique_Key__c, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());
        System.debug('-dealsBeforeBatchRun--->'+dealsBeforeBatchRun);

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
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

        // Verify only 5 deal Products will be created as Account Plan is present only for 5 Products and Account combination
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }

        // Verify flags reset properly
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
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
            createData();

        // Update Accounts to make all as Physical
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
            lstAccounts[i].Storefront__c = null;
            lstAccounts[i].Digital_Country_Code__c = null;
            if (i == 0) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 1) {
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 2) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 3) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
            } else if (i == 4) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
            }
        }
        update lstAccounts;

        List<Local_Title__c> lstLocaTitle = [SELECT Id FROM Local_Title__c];
        System.assertEquals(1, lstLocaTitle.size());

        // Update Products to make all as Physical
        List<Product2> lstProduct = tw.lstProduct;
        System.assertEquals(5, lstProduct.size());
        for(Integer i=0; i<lstProduct.size(); i++){
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
            lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }else if (i == 2) {
                lstProduct[i].Type__c = 'Video Physical';
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Physical';
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }
        }
        update lstProduct;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = tw.lstPriceBookEntryPeriod;
        System.assertEquals(5, lstPriceBookEntryPeriod.size());

        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = lstProduct[i].id;
            lstPriceBookEntryPeriod[i].New_Release__c = false;
        }
        update lstPriceBookEntryPeriod;

        // Change the Sales Org of Account so that Opportunity Can be deleted
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        update tw.lstAccounts;

        List<Opportunity> existingDeals = [SELECT Id,StageName FROM Opportunity];
        delete existingDeals;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        }
        update tw.lstAccounts;
        

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
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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
           p.Street_Date__c = system.today()+140;
        }
        update lstProduct;
        System.assertEquals(5, lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
            setAccountIdAndProductId.add(targetInstance.Account__c + '-' + targetInstance.Product__c);
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
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


        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        Integer countPhysical = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsAfterBatchRun.size());

        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(20, dealProduct.Account_Price__c);
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                    countPhysical ++;
                } else {
                    System.assertEquals(20, dealProduct.Account_Price__c);
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                    System.assertEquals(1, dealProduct.Target_Quantity__c, 'Quantity = 1');
                    countPhysical ++;
                }
            }
        }
        System.assertEquals(5, countPhysical);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_Having_DP_With_Stage_Committed_And_Deal_Product_To_Be_Cloned_Present_Test(){

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
            createData();

        for (Account acc : tw.lstAccounts) {
            acc.Status__c=CRM_AppConstants.ACCOUNT_STATUS_BLOCKED;
        }
        update tw.lstAccounts;

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
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        Date startDate = (system.today()+140).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

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
            lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
            if (i == 0) {
                lstNewProduct[i].Type__c = 'Games Physical';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            } else if (i == 1) {
                lstNewProduct[i].Type__c = 'Games Digital';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }else if (i == 2) {
                lstNewProduct[i].Type__c = 'Video Physical';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            } else if (i == 3) {
                lstNewProduct[i].Type__c = 'Video Digital EST';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            } else if (i == 4) {
                lstNewProduct[i].Type__c = 'Video Digital VODi';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            } else {
                lstNewProduct[i].Type__c = 'Games Physical';
                lstNewProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
                lstNewProduct[i].Local_Title__c = lstLocaTitle[0].Id;
            }
        }
        insert lstNewProduct;

        List<PricebookEntry> lstNewPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstNewProduct,1,false);
        for(Integer i=0 ;i<lstNewPriceBookEntry.size();i++){
            lstNewPriceBookEntry[i].Product2Id = lstNewProduct[i].id;
        }
        insert lstNewPriceBookEntry;

        Test.startTest();
        CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstNewPriceBookEntry, lstNewProduct);

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

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            if (lstPBEP[i].Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                lstPBEP[i].Start_Date__c = system.today()+140;
                lstPBEP[i].End_Date__c = System.today() +160;
            }
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        for (Product2 prod : lstNewProduct) {
            prod.NR_Product_Created__c = false;
            prod.Street_Date_Has_Changed__c = false;
        }
        update lstNewProduct;
        
        List<Product2> existingProductsForBatch = [SELECT Id FROM Product2 WHERE NR_Product_Created__c = true OR Street_Date_Has_Changed__c = true];
        System.assertEquals(2, existingProductsForBatch.size());

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        // Verify additional opportunity records are not created even if valid Deal Stage is changed to Non NR Default
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName,Product_Type__c,RecordTypeId,LastModifiedDate, (SELECT Id, LastModifiedDate FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(10, dealsAfterBatchRun.size());

        /*Integer countPhysical = 0;
        for (Opportunity digitalDeal : dealsAfterBatchRun) {
            if (mapNewValidDealInsatnce.containsKey(digitalDeal.Id) && digitalDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                System.assertEquals(2, digitalDeal.OpportunityLineItems.size());
                for (OpportunityLineItem dealProduct : digitalDeal.OpportunityLineItems) {
                    System.assertEquals(digitalDeal.LastModifiedDate, dealProduct.LastModifiedDate);
                    countPhysical++;
                }
            }
        }
        System.assertEquals(4, countPhysical);*/
        System.assertEquals(dealsBeforeBatchRun.size(), dealsAfterBatchRun.size());

        // Verify Satge Name is not changed
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
        }

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        Integer countPhysical1 = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(10, dealProductsAfterBatchRun.size());

        // Verify Last Modified Dates are changed
        /*Integer countRecords = 0;
        for (Integer j = 0; j < dealProductsAfterBatchRun.size(); j++) {
            OpportunityLineItem newDealProductInstance = dealProductsAfterBatchRun[j];
            OpportunityLineItem oldDealProductInstance = dealProductsBeforeBatchRun[j];
            System.debug('--oldDealProductInstance-->'+oldDealProductInstance);
            System.debug('--newDealProductInstance-->'+newDealProductInstance);
            if (newDealProductInstance.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertNotEquals(oldDealProductInstance.LastModifiedDate, newDealProductInstance.LastModifiedDate);
                countRecords++;
            }
        }
        System.assertEquals(4, countRecords);*/

        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem WHERE Id NOT IN: lstNewDealProduct]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
                countPhysical1 ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical1);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

	public static testMethod void Street_Date_Changed_To_Same_Month_With_Existing_Schedules_Test(){

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        // List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        Date currentdate = system.today() + 30;
        Date startDateOfCurrentDate = currentdate.toStartOfMonth();
        Date endDateOfCurrentDate = currentdate.addDays(Date.daysInMonth(currentdate.year(), currentdate.month())-1);

        Date oldStreetDate = startDateOfCurrentDate;

        Datetime sDate =
            datetime.newInstance(
                (startDateOfCurrentDate).year(),
                (startDateOfCurrentDate).month(),
                (startDateOfCurrentDate).day()
            );
        String currentMonth = sDate.format('MMM');
        for (Integer i = 0; i < tw.lstOpportunity.size(); i++) {
            Opportunity deal = tw.lstOpportunity[i];
            deal.CloseDate = endDateOfCurrentDate;
            deal.Start_Date__c = startDateOfCurrentDate;
            deal.Promo_Start_Date__c = startDateOfCurrentDate;
            deal.Promo_End_Date__c = endDateOfCurrentDate;
            deal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + currentMonth+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
        }
        update tw.lstOpportunity;

        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = oldStreetDate;
           p.Street_Date_Has_Changed__c = false;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

        for(Product2 p : tw.lstProduct){
           p.Street_Date_Has_Changed__c = false;
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;

        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = startDateOfCurrentDate - 140;
            lstPBEP[i].End_Date__c = endDateOfCurrentDate + 140;
        }
        update lstPBEP;
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Process_NR_Batch__c = false;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 10;
                lstDealProduct[i].Replen_Quantity__c = 20;
            }
            System.debug('-----lstDealProduct[i]---->'+lstDealProduct[i]);
        }
        insert lstDealProduct;

        Map<Id,Opportunity> mapIdToOpportunity = new Map<Id, Opportunity>([Select Id, Name from Opportunity]);
        System.assertEquals(5, mapIdToOpportunity.size(), 'Initial Deals');
        List<OpportunityLineItem> lstLineItem = [Select Id,Target_Quantity__c,Product2.RecordTypeId, OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem Order By OpportunityId, CreatedDate];
        System.assertEquals(5, lstLineItem.size(), 'Initial Deal Products');
        Map<Id,OpportunityLineItem> mapIdToOpportunityLineItem = new Map<Id, OpportunityLineItem>(lstLineItem );
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Description, OpportunityLineItem.Product2.RecordTypeId, ScheduleDate,OpportunityLineItem.NR_Revenue_Recognition_Date__c, Revenue FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId, Description, Quantity];
        System.assertEquals(7, lineItemSchedules.size());
        Map<Id,OpportunityLineItemSchedule> mapIdToOpportunityLineItemSchedule = new Map<Id, OpportunityLineItemSchedule>(lineItemSchedules);

        // Verify the Quantity is update after creating Schedules
        for (OpportunityLineItem dealProducts : lstLineItem) {
            System.assert(!dealProducts.Manually_Schedule__c);
            if (dealProducts.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(30, dealProducts.Quantity);
                System.assertEquals(0, dealProducts.Target_Quantity__c);
            }
        }
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (schedule.OpportunityLineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                if (schedule.Description == CRM_AppConstants.SCHEDULE_INITIAL) {
                    System.assertEquals(10, schedule.Quantity);
                    System.assertEquals(200, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);

                   /*if (schedule.Revenue != 0) {
                        System.assertEquals(0, schedule.Quantity);
                        System.assertEquals(200, schedule.Revenue);
                        System.assertEquals(oldStreetDate, schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c);
                        System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                    } else {
                        System.assertEquals(10, schedule.Quantity);
                        System.assertEquals(0, schedule.Revenue);
                        System.assertEquals(oldStreetDate, schedule.ScheduleDate);
                    }*/
                    System.debug('---1111->');
                } else if (schedule.Description == CRM_AppConstants.SCHEDULE_REPLEN_DELAY) {
                    System.assertEquals(20, schedule.Quantity);
                    System.assertEquals(oldStreetDate.addDays(7), schedule.ScheduleDate);
                    System.debug('---222->');
                }
            }
        }

        List<Product2> lstProduct = [SELECT Street_Date__c, Previous_Street_Date__c, RecordTypeId, NR_Product_Created__c, Street_Date_Has_Changed__c FROM Product2];
        System.debug('-lstProduct-->'+lstProduct);
        for(Product2 p : lstProduct){
           p.Street_Date__c = oldStreetDate.addDays(15);
           p.Previous_Street_Date__c = oldStreetDate;
        }
        update lstProduct;

        Date startDate = (oldStreetDate.addDays(15)).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        tw.lstTargets = [SELECT Id, Account_Plan_Lookup__c, GL_Calendar__c, Target__c, Account__c, Product__c FROM Target__c ORDER By CreatedDate];
        for (Target__c target : tw.lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        update tw.lstTargets;

        // Verify Street date has Changed
        for (Product2 productInstance : [SELECT Street_Date__c, RecordTypeId, NR_Product_Created__c, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
                System.assert(productInstance.Street_Date_Has_Changed__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2'); 
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify 2 physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        Integer numberDaysDifference = oldStreetDate.daysBetween(oldStreetDate);

        Date nweStreetDate = oldStreetDate.addDays(15);
        Date newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        for (OpportunityLineItem dealProduct : [Select Id,NR_Revenue_Recognition_Date__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate, Description, Revenue FROM OpportunityLineItemSchedules ORDER BY ScheduleDate ASC)
            from OpportunityLineItem Order By OpportunityId, CreatedDate
        ]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(mapIdToOpportunityLineItem.containsKey(dealProduct.Id));
                System.assertEquals(30, dealProduct.Quantity);
                System.assertEquals(0, dealProduct.Target_Quantity__c);
                // System.assertEquals(10, dealProduct.Target_Quantity__c);
                /*System.assertEquals(3, dealProduct.OpportunityLineItemSchedules.size());

                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(200, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, dealProduct.OpportunityLineItemSchedules[0].Description);
                System.assertEquals(newScheduleDate.addDays(-10), dealProduct.NR_Revenue_Recognition_Date__c);
                System.assertEquals(dealProduct.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                System.assert(mapIdToOpportunityLineItemSchedule.containsKey(dealProduct.OpportunityLineItemSchedules[0].Id));

                System.assertEquals(10, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, dealProduct.OpportunityLineItemSchedules[1].Description);
                System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
                System.assert(mapIdToOpportunityLineItemSchedule.containsKey(dealProduct.OpportunityLineItemSchedules[1].Id));

                System.assertEquals(20, dealProduct.OpportunityLineItemSchedules[2].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, dealProduct.OpportunityLineItemSchedules[2].Description);
                System.assertEquals(newScheduleDate.addDays(7), dealProduct.OpportunityLineItemSchedules[2].ScheduleDate);
                System.assert(mapIdToOpportunityLineItemSchedule.containsKey(dealProduct.OpportunityLineItemSchedules[2].Id));*/

                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(10, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(200, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, dealProduct.OpportunityLineItemSchedules[0].Description);
                System.assertEquals(dealProduct.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                System.assert(mapIdToOpportunityLineItemSchedule.containsKey(dealProduct.OpportunityLineItemSchedules[0].Id));

                System.assertEquals(20, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, dealProduct.OpportunityLineItemSchedules[1].Description);
                System.assertEquals(newScheduleDate.addDays(7), dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
                System.assert(mapIdToOpportunityLineItemSchedule.containsKey(dealProduct.OpportunityLineItemSchedules[1].Id));

                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.NR_Product_Created__c);
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2'); 
        }
    }
    
    public static testMethod void Scenario3_Insert_Target_Without_Existing_Deal_And_Deal_Products_Test() {

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
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
        Product2 p0_GamesPhysical = lstProduct[0];
        p0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
        p0_GamesPhysical.Street_Date__c = System.today() + 32;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        //List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);
        List<Target__c> lstTargets = CRM_TestDataFactory.createProductTargets(lstAccounts, lstProduct, false);
        Date startDate = (System.today() + 32).toStartOfMonth();
        Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        insert glcalendar1;
        System.assert(glcalendar1.Id != null);

        for (Target__c target : lstTargets) {
            target.GL_Calendar__c = glcalendar1.Id;
        }
        insert lstTargets;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodCreated
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c existingDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        existingDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        existingDealPriceBookPeriod.Start_Date__c = System.today()-40;
        existingDealPriceBookPeriod.End_Date__c = System.today()-40;
        existingDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        existingDealPriceBookPeriod.List_Price__c = 10;

        lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c streetDateChangeCurrentMonthDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        streetDateChangeCurrentMonthDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        streetDateChangeCurrentMonthDealPriceBookPeriod.Start_Date__c = System.today().toStartOfMonth();
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+60;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        // Reset Scenario 4 as need to test Scenario 3 insert
        for(Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update lstPriceBookEntryPeriod;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Product flags are reset
        for (Product2 productInstance : [SELECT Id, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            System.assertEquals(false, productInstance.Street_Date_Has_Changed__c);
            System.assertEquals(false, productInstance.NR_Product_Created__c);
        }

        // Verify Target flags are set
        for (Target__c targetInstance : [SELECT Id, Account__c, Target_Revenue_Has_Changed__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should be set as Scenario 3');
        }

        // Verify Process NR Batch checkbox is checked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is no Scenario 1 and 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            System.debug('-pbep--->'+pbep);
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());

        // Verify 2 deal product records for 2 physical products should be created through batch
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            System.assertEquals(1, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
            System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
            System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Target Quantity should be 0');                
        }

        // Verify Schedules created as Initial Quantity is entered
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c,Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c DESC];
        System.assertEquals(1, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(0, schedule.Revenue);
            System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
        }

        // Verify Target flags are reset
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target_Revenue_Has_Changed__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should be reset as Scenario 3');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
}