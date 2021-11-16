/**
   @Author Aditi Satpute
   @name CRM_AutoPhysicalFranceNRBatch_Test
   @CreateDate 24 Jun 2016
   @Description Test class for CRM_AutoPhysicalNRDealCreationBatch
   @Version <1.0>
   @reference Requirement no 274
  */
  
@isTest
public with sharing class CRM_AutoPhysicalFranceNRBatch_Test {

    public static CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper createData() {
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Integer countVD = 0;
        for (Account acc : tw.lstAccounts) {
            if (acc.Games_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (acc.Video_Physical__c) {
                if (CRM_AppConstants.BENELUX_SALES_ORGS != null && CRM_AppConstants.BENELUX_SALES_ORGS.size() > 0) {
                    for (String salesOrg : CRM_AppConstants.BENELUX_SALES_ORGS) {
                        acc.Sales_Organization__c = salesOrg;
                    }
                } else {
                    acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
                }
            } else if (acc.Games_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
            } else if (acc.Video_Digital__c) {
                if (countVD == 0 && CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES != null && CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES.size() > 0) {
                    for (String countryCode : CRM_AppConstants.BENELUX_DIGITAL_COUNTRY_CODES) {
                        acc.Digital_Country_Code__c = countryCode;
                    }
                    countVD ++;
                } else {
                    acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE;
                }
            }
        }
        update tw.lstAccounts;

        for (Integer i = 0; i < tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            String dealPeriod;
            Date dealStartDate = d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL ? system.today() + 32 : system.today() + 1;
            Date dealEndDate = d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL ? system.today() + 60 : system.today() + 30;

            d0_existingDeal.Start_Date__c = dealStartDate;
            d0_existingDeal.CloseDate = dealEndDate;
            d0_existingDeal.Promo_Start_Date__c = dealStartDate;
            d0_existingDeal.Promo_End_Date__c = dealEndDate;
            if (
                    tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE  ||
                    tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_SPAIN_CODE  ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE ||
                    tw.lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_SPAIN_DIGITAL_COUNTRY_CODE
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

            d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
        }
        update tw.lstOpportunity;

        for (Product2 prod : tw.lstProduct) {
            if (prod.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
                prod.Street_Date__c = System.today() + 32;
                prod.Release_Category__c = null;
            }
        }
        update tw.lstProduct;

        List<Country_Plan__c> lstCountryPlan = [SELECT Id, Target_Quantity__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
            cp.Stretch_Target__c = 10;
        }
        update lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c ORDER BY CreatedDate];
        for (Account_Plan__c ap : lstAccountPlan) {
            ap.Share__c = 10;
        }
        update lstAccountPlan;
        System.assertEquals(5, tw.lstTargets.size());
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

        List<Account_Plan__c> lstAP = [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : lstAP) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Promoted_Price__c, ListPrice__c, SAP_Promoted_Price__c, Account_Plan__c, Opportunity.AccountId, Opportunity.Account.Sales_Organization__c, Account_Price__c, Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(20, dealProduct.Promoted_Price__c);
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
            } else {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(20, dealProduct.ListPrice__c);
                System.assertEquals(dealProduct.ListPrice__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            }
        }

        // Verify Schedules created as Initial Quantity is entered
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c, ScheduleDate, Quantity];
        System.assertEquals(2, lineItemSchedules.size());

        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 2) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(60, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(3, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 0) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(1100, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(55, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
            }
        }

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
    }

  /*  public static testMethod void Scenario1_With_Existing_Committed_Deal_And_Target_Test(){

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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
            } else {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            }
        }

        // Verify Schedules created as Initial Quantity is entered
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id,OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate,OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c, ScheduleDate, Quantity];
        System.assertEquals(2, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 2) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(60, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(3, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
     /*552 comment      } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate); */
                /*if (i == 0) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(1100, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(55, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
        //552 Commented    }
        //552 Commented}

        // Verify Products processed properly and flag is reset
       /* 552 comment  for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
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
        }*/
//552 commented    }

    /*public static testMethod void Scenario1_With_Existing_Approved_Deal_And_Target_Test(){

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
            createData();

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
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
        }

        // Verify 2 deal product records for 2 physical products should be created through batch
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
            } else {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            }
        }

        // Verify Schedules created as Initial Quantity is entered
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate,OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c, ScheduleDate, Quantity];
        System.assertEquals(2, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
            }
        }

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
    } */

    public static testMethod void Scenario1_Without_Existing_Deal_And_Target_Test(){
        // Method to create Dummy Data
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
            if (acc.Video_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (acc.Games_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
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

        // Verify 2 deals created for 2 physical products
        System.assertEquals(2, [SELECT Id FROM Opportunity].size());

        // Verify 2 deal product records for 2 physical products should be created through batch
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Account_Price__c, Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
            } else {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            }
        }

        // Verify Schedules created as Initial Quantity is entered
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c DESC];
        System.assertEquals(2, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 0 || i == 2) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(1100, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(55, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
            }
        }

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
    }

    public static testMethod void Scenario1_With_Existing_Deal_And_No_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

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

        // Verify only 1 deal product record for 1 Non Benelux physical products should be created through batch
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Sales_Organization__c,Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            System.assert(!CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c));
            if (!CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                /*System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(1, dealProduct.Target_Quantity__c, 'Target Quantity should be 1 as no Target present');
                System.assertEquals(1, dealProduct.Initial_Quantity__c, 'Target Quantity should be 1 as no Target present');
            } else {*/
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            }
        }

        // Verify Schedules created as Initial Quantity is entered
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(1, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            System.assert(!CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c));
            if (!CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                /*System.assertEquals(1, schedule.Quantity);
                System.assertEquals(20, schedule.Revenue);            
            } else {*/
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 0) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(1100, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(55, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
            }
        }

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
    }

    public static testMethod void Scenario1_With_Existing_Deal_And_No_Target_Quantity_In_Account_Plan_Present_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // For FR Consider Ship To Account
        for (Account acc : tw.lstAccounts) {
            if (acc.Games_Physical__c) {
                if (CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(acc.Sales_Organization__c)) {
                    acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                }
            }
        }
        update tw.lstAccounts;

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

        List<Account> lstAccount = [SELECT Id FROM Account WHERE Sales_Organization__c NOT IN: CRM_AppConstants.BENELUX_SALES_ORGS];

        // Remove Targets for FR to check deal Products created with Target Quantity on Account Plan
        List<Target__c> lstTargets = [SELECT Id FROM Target__c WHERE Account__c IN: lstAccount];
        delete lstTargets;

        if (CRM_AppConstants.BENELUX_SALES_ORGS.size() > 0) {
            // Verify targets present
            System.assertEquals(1, [SELECT Id from Target__c].size());
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
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Price__c, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
            } else {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity should be 1');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Target Quantity = 0 as No Target Quantity in Account Plan');
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Target Quantity = 0 as No Target Quantity in Account Plan');
            }
        }

        // Verify Schedules created as Initial Quantity is entered as 0
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c, ScheduleDate, Quantity];
        System.assertEquals(2, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 2) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(60, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(3, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
            } else {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(0, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 0) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(20, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(1, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
            }
        }

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
    }

    public static testMethod void Scenario1_Without_Existing_Deal_And_No_Account_Plan_And_Target_Test(){
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
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        }
        update tw.lstAccounts;

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

        // Verify no new deal is created as no Account Plan present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records created through batch as no Account Plan present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

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

        List<Account_Plan__c> lstAP = [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : lstAP) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [SELECT Id, Account_Plan__c, ListPrice__c, SAP_Promoted_Price__c, Promoted_Price__c, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c, OpportunityId,Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(20, dealProduct.Promoted_Price__c);
                    System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                    System.assertEquals(20, dealProduct.ListPrice__c);
                    System.assertEquals(dealProduct.ListPrice__c, dealProduct.SAP_Promoted_Price__c);
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');

                // Verify these deal products are linked with new deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());
        /*for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(20, schedule.Revenue);
        }*/

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

    /*public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Planned_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // For FR Consider Ship To Account
        for (Account acc : tw.lstAccounts) {
            if (acc.Games_Physical__c) {
                if (CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(acc.Sales_Organization__c)) {
                    acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                }
            }
        }
        update tw.lstAccounts;

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity d0_existingDeal = tw.lstOpportunity[i];
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        }
        update tw.lstOpportunity;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(tw.lstOpportunity);

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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Quantity should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');

                // Verify deals products are now not related to existing deals as these are cloned and attached to new deal
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());
        /*for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(20, schedule.Revenue);
        }*/

        // Verify Products processed properly and flag is reset
       /* for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
                System.assert(!productInstance.NR_Product_Created__c);
            }
        }*/

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
     /*   for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

   /* public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Approved_Future_Deal_No_Valid_PBEP_Test(){
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
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
    }*/

  /*  public static testMethod void Scenario2_With_Deal_Product_To_Be_Cloned_Present_In_Approved_Non_Future_Deal_No_Valid_PBEP_Test(){
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED, dealInsatnce.StageName);
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
    }*/

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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Account_Price__c, Initial_Quantity__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                countPhysical ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());
        /*for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(20, schedule.Revenue);
        }*/

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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (Integer j = 0; j < dealProductsAfterBatchRun.size(); j++) {
            OpportunityLineItem newDealProductInstance = dealProductsAfterBatchRun[j];
            OpportunityLineItem oldDealProductInstance = dealProductsBeforeBatchRun[j];
            /*if (newDealProductInstance.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertNotEquals(oldDealProductInstance.LastModifiedDate, newDealProductInstance.LastModifiedDate);
            }*/
     /*   }

        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                countPhysical ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());
        /*for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(20, schedule.Revenue);
        }*/


        // Verify Products processed properly and flag is reset
     /*   for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [SELECT Id, Initial_Quantity__c, Opportunity.Account.Sales_Organization__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');
                countPhysical ++;
                // Verify these deal products are linked with existing deals based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());
        /*for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(20, schedule.Revenue);
        }*/

        // Verify Products processed properly and flag is reset
       /* for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
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

  /*  public static testMethod void Scenario2_With_Existing_Deal_And_No_Deal_Product_To_Be_Cloned_Present_Test(){
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c, Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
            } else {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(55, dealProduct.Quantity, 'Should be same as Initial Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Quantity = Account Plan.Target Quantity');
            }
        }

        // Verify Schedules created as Initial Quantity is entered as 55
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c, ScheduleDate, Quantity];
        System.assertEquals(2, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 2) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(60, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(3, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
           /* } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);*/
                /*if (i == 0) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(1100, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(55, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
       //552 Commented     }
        //552 Commented}

        // Verify Products processed properly and flag is reset
      /*  for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }*/

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 2
    /*    for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c,Target_Quantity__c, OpportunityId, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Quantity != Account Plan.Target Quantity as Manually Schedule true');

                // Verify these deal products are linked with new deals different based on changed Street Date
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            } else {
                System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());
        /*for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(20, schedule.Revenue);
        }*/

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
            if (acc.Video_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (acc.Games_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
            }
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2Id,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
            } else {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(55, dealProduct.Quantity, 'Should be same as Initial Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Quantity = Account Plan.Target Quantity');
            }
        }

        // Verify Schedules created as Initial Quantity is entered as 55
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c DESC];
        System.assertEquals(2, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);            
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 0 || i == 2) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(1100, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(55, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
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

    public static testMethod void Scenario3_With_Existing_Deal_And_Deal_Product_Present_Test(){
            //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // For FR Consider Ship To Account
        for (Account acc : tw.lstAccounts) {
            if (acc.Games_Physical__c) {
                if (CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(acc.Sales_Organization__c)) {
                    acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                }
            }
        }
        update tw.lstAccounts;

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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        List<Account_Plan__c> lstAP = [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : lstAP) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [Select Id, Account_Plan__c, ListPrice__c, SAP_Promoted_Price__c, Promoted_Price__c, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(20, dealProduct.Promoted_Price__c);
                    System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                } else {
                    System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                    System.assertEquals(20, dealProduct.ListPrice__c);
                    System.assertEquals(dealProduct.ListPrice__c, dealProduct.SAP_Promoted_Price__c);
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity != Deal Product.Target Quantity as Manually Schedule true');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());
        /*for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(20, schedule.Revenue);
        }*/

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
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
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = true;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;
        
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        
        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;
        

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

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesPhysical.Target__c = 50;
        t0_GamesPhysical.Target_Units__c = 5;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

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
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify deal and deal products are created for Scenario 3 in case of France
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Quantity, Target_Quantity__c,Initial_Quantity__c, (SELECT Id, Quantity, Revenue,OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            System.assertEquals(90, dealProduct.Quantity);
            System.assertEquals(90, dealProduct.Target_Quantity__c);
            System.assertEquals(90, dealProduct.Initial_Quantity__c);
            /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
            System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
            System.assertEquals(1800, dealProduct.OpportunityLineItemSchedules[0].Revenue);
            System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
            System.assertEquals(90, dealProduct.OpportunityLineItemSchedules[1].Quantity);
            System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
            System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
            */
            System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
            for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(90, schedule.Quantity);
                System.assertEquals(1800, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_And_Scenario4_With_Existing_Deal_And_Deal_Product_Present_And_List_Price_Changed_Test() {
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
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(88, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
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
        for (OpportunityLineItem dealProduct : [Select Id,Initial_Quantity__c,Opportunity.Account.Sales_Organization__c,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Account Price updated For France');
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(20, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(88, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Updated Quantity != Deal Product.Target Quantity as Manually Schedule true');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());
        /*for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(10, schedule.Revenue);
        }*/

        // Verify Target flags are reset properly after batch processing
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Process_NR_Batch__c,Product__r.RecordTypeId FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    
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
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlanInstance : lstAccountPlan) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Opportunity.Account.Sales_Organization__c,Initial_Quantity__c,Target_Quantity__c, Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(10.00, dealProduct.Account_Price__c, 'Account Price updated For France');
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(5, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity != Deal Product.Target Quantity as Manually Schedule true');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Account Plan flags are reset even after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
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
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        }
        update tw.lstAccounts;*/

        // Delete existing deals so that no existing NR deals present in database
        delete tw.lstOpportunity;

        // After deleting opportunities again make the Sales Org as Germany
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        }
        update tw.lstAccounts;*/

        Map<Id,List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id,List<Account_Plan__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+32;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

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
           p.Street_Date__c = system.today()+80;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
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

        // Verify the Quantity is updated after creating Schedules
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify Target flags are set as true such that there is Scenario 3 condition
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(88, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [Select Id,Initial_Quantity__c,Target_Quantity__c, Account_Price__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(88, accountPlanInstance.Target_Quantity__c);
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(200, targetInstance.Target__c);
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(90, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Initial_Quantity__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+140;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+160;
        }
        update tw.lstPriceBookEntryPeriod;

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

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
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Initial_Quantity__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity is not Updated as no valid PBEP Found');
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);

        // Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are reset properly after batch processing
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
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
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Commented Germany Code Changes
        /*for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }*/

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
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        /*
        // Commented Germany Code Changes
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c);
            }
        }*/

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

    /*(public static testMethod void Negative_Test_ResetProcessedAccountPlanFlags() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
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

        // Previous Street Date not Specified
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+80;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

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

        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
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

        // Verify the Quantity is updated after creating Schedules
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(21, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c, 'Should be true as Scenario 2 & 3');
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        //System.assertEquals(5, automaticNRDealCreationBatch.lstExceptions.size());
        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify 2 physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Opportunity.Account.Sales_Organization__c,Target_Quantity__c,Initial_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity);
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Updated Quantity != Deal Product.Target Quantity as Manually Schedule true');

                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);

        // Verify Target flags are not reset after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        /*
        // Commented Germany Code Changes
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
            }
        }*/

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
           p.Street_Date__c = system.today()+80;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

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

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlan) {
            accountPlan.Share__c = 40;
        }
        update lstAccountPlan;

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

        // Verify the Quantity is updated after creating Schedules
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(21, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c, 'Should be true as Scenario 2 & 3');
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

        Test.startTest();

//        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
//        Test.stopTest();

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItemSchedule].size(), 'Digital Schedules deleted');

        // Verify Target flags are not reset after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
        }

        // Verify Flags are not reset
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Integer clonedDealProductsCount = 0;
        List<OpportunityLineItem> lstDealProducts = [Select Id,Opportunity.Account.Sales_Organization__c,Initial_Quantity__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ];
        System.assertEquals(5, lstDealProducts.size(), 'Initial Deal Products');

        for (OpportunityLineItem dealProduct : lstDealProducts) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity);
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Updated Quantity != Deal Product.Target Quantity as Manually Schedule true');
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

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
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

  /*  public static testMethod void NegativeTest_Schedules_Insert_Fail_With_Scenario2_With_Batch_ReRun_Test(){

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
           p.Street_Date__c = system.today()+80;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

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
        
       /* //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets; */
       /*
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

        // Verify There is only Scenario 2
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
        }

//        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
//        Test.stopTest();

        Test.startTest();
        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(3, [SELECT Id FROM OpportunityLineItemSchedule].size(), 'Digital Schedules deleted');

        // Verify Target flags are reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
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
        for (OpportunityLineItem dealProduct : [Select Id,Opportunity.Account.Sales_Organization__c,Initial_Quantity__c, Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Quantity);
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Updated Quantity != Deal Product.Target Quantity as Manually Schedule true');
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                /*System.assertEquals(21, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);*/
               /* clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);

        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch1,10);
        Test.stopTest();

        // No new deal / Deal Product is created
        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify Target flags are reset
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
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

        Set<String> setProductAndAccountIdSet = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        // Method to create Dummy Data

        // Setting Up the Sold To Account Data with 'Games Physical Type'
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(1);
        System.assertEquals(1, lstAccounts.size());
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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
           p.Street_Date__c = system.today()+80;
           p.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
           p.Street_Date_Has_Changed__c = true;
           p.CurrencyIsoCode = 'USD';
           p.Local_Title__c = lstLocaTitle[0].Id;
           p.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
           p.Type__c = 'Games Physical';
           p.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
           p.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        }
        insert lstProduct;

        System.assertEquals(1, lstProduct.size());
        for(Product2 p : lstProduct){
            p.NR_Product_Created__c = false;
        }
        update lstProduct;

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;

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

        // Setting up 1 Target data for each Account and Product created
        List<Account_Plan__c> lstAccountPlan1 = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp, lstAccountPlan1, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 100;
            lstTargets[i].Target_Units__c = 5;
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = lstProduct[i].id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        } 
        insert lstTargets;
        System.debug('lstTargets::'+lstTargets);

 
        // Create a Map of Target data before updating the target because the batch will run with these Target
        // data and will have the previous version

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Target_Quantity__c,NR_Version__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlanInstance : lstAccountPlan) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
            setProductAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
        }

        List<Target__c> lstTarget = [SELECT Id, Account__c,NR_Version__c, Product__r.RecordTypeId, Product__c, Target__c FROM Target__c];
        for (Target__c targetInstance : lstTarget) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(100, targetInstance.Target__c);
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
        System.assertEquals(1, [Select Id, NR_Version__c from Account_Plan__c][0].NR_Version__c);
        System.assertEquals(lstAccountPlan[0].NR_Version__c, [Select Id, NR_Version__c from Account_Plan__c][0].NR_Version__c);

        System.assertEquals(1, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(1, [Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(0, [Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');
        System.assertEquals(system.today() + 80, lstProduct[0].Street_Date__c);
        // Run the batch such that while running the Product Street Date / Target Revenue has been modified
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProduct , mapIdToPBEPList, setProcessedProductIds );

        Test.startTest();
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
        System.debug('-fetchedDealsWithLatest--->'+fetchedDealsWithLatest);
        for (Opportunity deal : fetchedDealsWithLatest) {
            if (deal.NR_Deal_Unique_Key__c != null && deal.Id != lstOpportunity[0].Id) {
                newlyCreatedOpportunity = deal;
                System.assertEquals('New Releases Games Physical '+currentMonth+' '+(system.today() + 80).year()+' ' + soldToAccount.Name, deal.Name);
            }
        }

        // Deal Product is cloned and attached to new deal thats why the count of Deal Products is still one
        // Verify the records created with previous StreetDate / Revenue change even if the
        // Street Date / Target Revenue was changed while batch was running
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId,Quantity,Target_Quantity__c, Opportunity.Name, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(1, dealProducts.size(), 'New Deal Products');
        System.assertEquals(1, dealProducts[0].Quantity);
        System.assertEquals(55, dealProducts[0].Target_Quantity__c);
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

        System.assertEquals(0, [Select Id, NR_Version__c from Account_Plan__c][0].NR_Version__c);

        List<Account_Plan__c> lstAccountPlanToUpdate = [SELECT Id, Share__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlan : lstAccountPlanToUpdate) {
            accountPlan.Share__c = 40;
        }
        update lstAccountPlanToUpdate;

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c,NR_Version__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 2 & 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c,NR_Version__c, Product__r.RecordTypeId, Product__c, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(100, targetInstance.Target__c);
                // Commented Germany Code Changes
                // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
            }
        }

        System.assertEquals(1, [Select Id, NR_Version__c from Product2][0].NR_Version__c);
        System.assertEquals(1, [Select Id, NR_Version__c from Account_Plan__c][0].NR_Version__c);
        System.assertNotEquals(lstProduct[0].NR_Version__c, [Select Id, NR_Version__c from Product2][0].NR_Version__c);
        //System.assertNotEquals(lstAccountPlan[0].NR_Version__c, [Select Id, NR_Version__c from Account_Plan__c][0].NR_Version__c);

        // As Version was changed Verify the Checkboxes (StreetDate changed and Target Revenue Changed) is still true even
        // when the batch was processed successfully
        System.assertEquals(true, [Select Id, Street_Date_Has_Changed__c from Product2][0].Street_Date_Has_Changed__c);
        System.assertEquals(true, [Select Id, Target_Revenue_Has_Changed__c from Account_Plan__c][0].Target_Revenue_Has_Changed__c);

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }

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
        List<Opportunity> fetchedDealsWithLatest1 = [Select Id, Name from Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(2, fetchedDealsWithLatest.size(), 'New Deals');
        System.debug('-fetchedDealsWithLatest1--->'+fetchedDealsWithLatest1);
        System.assertEquals('New Releases Games Physical '+currentMonth1+' '+(system.today() + 140).year()+' ' + soldToAccount.Name, fetchedDealsWithLatest1[0].Name);

        // Deal Product is cloned and attached to new deal with updated Quantity thats why the count is still one
        // Verify the deal Product is cloned to the deal with changed StreetDate and updated with Quantity calculated based on Target Revenue
        // which was changed while batch was running previously
        List<OpportunityLineItem> fetchedDealProducts = [Select Id,Quantity, Initial_Quantity__c, Target_Quantity__c, OpportunityId, Opportunity.Name, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(1, fetchedDealProducts.size(), 'New Deal Products');
        System.assertEquals(fetchedDealsWithLatest1[0].Id, fetchedDealProducts[0].OpportunityId);
        System.assertEquals(1, fetchedDealProducts[0].Quantity);
        System.assertEquals(220, fetchedDealProducts[0].Target_Quantity__c);
        System.assertEquals(null, fetchedDealProducts[0].Initial_Quantity__c);

        // Verify the Version and the checkboxes has been reset
        System.assertEquals(false, [Select Id, Street_Date_Has_Changed__c from Product2][0].Street_Date_Has_Changed__c);
        System.assertEquals(false, [Select Id, Target_Revenue_Has_Changed__c from Account_Plan__c][0].Target_Revenue_Has_Changed__c);
        System.assertEquals(0, [Select Id, NR_Version__c from Product2][0].NR_Version__c);
        System.assertEquals(0, [Select Id, NR_Version__c from Account_Plan__c][0].NR_Version__c);

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }*/

  /*  public static testMethod void Scenario1_With_Existing_Multiple_Stage_Deal_And_Target_Test(){

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
            createData();

        // Update Accounts to make all as Physical
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].Storefront__c = null;
            if (i == 0) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (i == 1) {
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
            } else if (i == 2) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_SPAIN_CODE;
            } else if (i == 3) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
            } else if (i == 4) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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
            //lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            lstProduct[i].Street_Date__c = System.today() + 32;
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
                lstProduct[i].Street_Date__c = System.today() + 162;
            }else if (i == 2) {
                lstProduct[i].Type__c = 'Video Physical';
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SPAIN_CODE;
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Physical';
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            }
        }
        update lstProduct;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = tw.lstPriceBookEntryPeriod;
        System.assertEquals(5, lstPriceBookEntryPeriod.size());

        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = lstProduct[i].id;
            lstPriceBookEntryPeriod[i].New_Release__c = false;
            lstPriceBookEntryPeriod[i].End_date__c = System.today();
            lstPriceBookEntryPeriod[i].End_date__c = System.today() + 170;
        }
        update lstPriceBookEntryPeriod;

        // Make the deal as Committed
        System.runas(testUser) {
            String dealPeriod;
            // Change the Sales Org of Account so that Opportunity Can be deleted
            /*for (Account acc : tw.lstAccounts) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            }
            update tw.lstAccounts;*/

            // Delete existing deals so that no existing NR deals present in database
           //552 Commented  List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
             //552 Commented delete oppList;

            // After deleting opportunities again make the Sales Org as Germany
            /*for (Account acc : tw.lstAccounts) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            }
            update tw.lstAccounts;*/

         /*   oppList = CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
            System.assertEquals(5, oppList.size());

            oppList[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            oppList[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            oppList[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            oppList[3].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED;
            oppList[4].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            for (Integer i = 0; i < oppList.size(); i++) {
                Opportunity d0_existingDeal = oppList[i];
                Date dealStartDate = d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL ? system.today() + 32 : system.today() + 1;
                Date dealEndDate = d0_existingDeal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL ? system.today() + 170 : system.today() + 30;

                d0_existingDeal.Start_Date__c = dealStartDate;
                d0_existingDeal.CloseDate = dealEndDate;
                d0_existingDeal.Promo_Start_Date__c = dealStartDate;
                d0_existingDeal.Promo_End_Date__c = dealEndDate;
                if (
                    lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE  ||
                    lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_SPAIN_CODE
                ) {
                    Integer currentQtr =
                        Decimal.valueOf(
                            (dealStartDate).toStartOfMonth().month()
                        ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                    dealPeriod = 'Q' + currentQtr;
                } else {
                    if (lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_ITALY_CODE) {
                        
                        Datetime sDate =
                        datetime.newInstance(
                            ((System.today() + 162).toStartOfMonth()).year(),
                            ((System.today() + 162).toStartOfMonth()).month(),
                            ((System.today() + 162).toStartOfMonth()).day()
                        );
                        String currentMonth = sDate.format('MMM');
                        dealPeriod = currentMonth;
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
                }
                d0_existingDeal.NR_Deal_Unique_Key__c = lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(lstProduct[i].Type__c);
            }
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
        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Account_Price__c, Initial_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem]) {
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c) || dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SPAIN_CODE
            ) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
            } else {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            }
        }

        // Verify Schedules created as Initial Quantity is entered
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id,OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c DESC];
        System.assertEquals(5, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c) || schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SPAIN_CODE) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);            
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 0 || i == 2 || i == 4 || i == 6 || i == 8) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(1100, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(55, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
       //552 Commented     }
      //552 Commented     }

        // Verify Products processed properly and flag is reset
      /*552 Commented     for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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
    }*/

  /*  public static testMethod void Scenario2_With_Existing_Deal_With_Multiple_Stage_And_Deal_Product_To_Be_Cloned_Present_Test(){

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
            createData();

        // Update Accounts to make all as Physical
        List<Account> lstAccounts = tw.lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        for (Integer i=0; i<lstAccounts.size(); i++) {
            //lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            lstAccounts[i].Storefront__c = null;
            if (i == 0) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (i == 1) {
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
            } else if (i == 2) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_SPAIN_CODE;
            } else if (i == 3) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
            } else if (i == 4) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Digital__c= false;
                lstAccounts[i].Video_Digital__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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
            //lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
            }else if (i == 2) {
                lstProduct[i].Type__c = 'Video Physical';
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SPAIN_CODE;
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Physical';
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        }
        update tw.lstAccounts;*/

        /*552 Commented List<Opportunity> existingDeals = [SELECT Id,StageName FROM Opportunity];
        delete existingDeals;*/

        // After deleting opportunities again make the Sales Org as Germany
        /*for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        }
        update tw.lstAccounts;*/

        /*existingDeals = CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
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
            if (tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE || tw.lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_SPAIN_CODE) {
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
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Initial_Quantity__c = null;
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

        // Verify only 5 deal Products will be created as Account Plan is present only for 5 Products and Account combination
        Integer countPhysical = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsAfterBatchRun.size());

        for (OpportunityLineItem dealProduct : [SELECT Id,Opportunity.Account.Sales_Organization__c, Account_Price__c,Initial_Quantity__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                if (setAccountIdAndProductId.contains(dealProduct.Opportunity.AccountId  + '-' + dealProduct.Product2Id)) {
                    System.assertEquals(20, dealProduct.Account_Price__c);
                    if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c) || dealProduct.Opportunity.Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SPAIN_CODE
                    ) {
                        System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                        System.assertEquals(1, dealProduct.Initial_Quantity__c);
                        System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                    } else {
                        System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                        System.assertEquals(1, dealProduct.Initial_Quantity__c);
                        System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                    }
                    
                    countPhysical ++;
                }
            }
        }
        System.assertEquals(5, countPhysical);

        /* Verify Schedules not created as Initial Quantity is null
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());*/
        /*List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id,OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c DESC];
        System.assertEquals(5, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(20, schedule.Revenue);
            System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }
    }*/

   /* public static testMethod void Scenario2_With_Existing_Deal_Having_DP_With_Stage_Committed_And_Deal_Product_To_Be_Cloned_Present_Test(){

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
            lstNewProduct[i].Street_Date__c = system.today()+32;
            lstNewProduct[i].NR_Product_Created__c = true;
            lstNewProduct[i].Street_Date_Has_Changed__c = false;
            lstNewProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
            lstNewProduct[i].CurrencyIsoCode = 'USD';
            lstNewProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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

        CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstNewPriceBookEntry, lstNewProduct);

        Test.startTest();
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

        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(55, accountPlanInstance.Target_Quantity__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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
    /*    System.assertEquals(dealsBeforeBatchRun.size(), dealsAfterBatchRun.size());

        // Verify Satge Name is not changed
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
        }

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        Integer countPhysical1 = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(10, dealProductsAfterBatchRun.size());

        // Verify Last Modified Dates are changed
        Integer countRecords = 0;
        for (Integer j = 0; j < dealProductsAfterBatchRun.size(); j++) {
            OpportunityLineItem newDealProductInstance = dealProductsAfterBatchRun[j];
            OpportunityLineItem oldDealProductInstance = dealProductsBeforeBatchRun[j];
            System.debug('--oldDealProductInstance-->'+oldDealProductInstance);
            System.debug('--newDealProductInstance-->'+newDealProductInstance);
            if (newDealProductInstance.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                //System.assertNotEquals(oldDealProductInstance.LastModifiedDate, newDealProductInstance.LastModifiedDate);
                countRecords++;
            }
        }
        System.assertEquals(4, countRecords);

        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Account.Sales_Organization__c, Account_Price__c, OpportunityId,Initial_Quantity__c,  Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem WHERE Id NOT IN: lstNewDealProduct]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should not be changed');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                } else {
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Quantity = Account Plan.Target Quantity');
                }
                System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Quantity != Deal Product.Target Quantity as Manually Schedule true');
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
    }*/

    public static testMethod void Scenario2_And_3_With_Existing_Deal_And_Deal_Products_With_Updated_Initial_Quanitity_Test(){

        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
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
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 15;
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

        for (OpportunityLineItem dealProduct : [Select (SELECT Id, Quantity, Revenue, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate FROM OpportunityLineItemSchedules ORDER BY OpportunityLineItem.Opportunity.Sales_Organisation__c, ScheduleDate, Quantity), Initial_Quantity__c, Id, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,Opportunity.Account.Sales_Organization__c from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(15, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(15, dealProduct.Initial_Quantity__c);
                //if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    for (OpportunityLineItemSchedule sch : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(15, sch.Quantity);
                        System.assertEquals(300, sch.Revenue);
                        System.assertEquals(sch.OpportunityLineItem.Product2.Street_Date__c, sch.ScheduleDate);
                    }
                    /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(300, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(15, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);*/
                /*} else {
                    System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(300, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(15, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
                }*/
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        // Verify Schedules are not updated as Initial Quantity is not updated
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Opportunity.Account.Sales_Organization__c,(SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, Quantity, Revenue FROM OpportunityLineItemSchedules ORDER BY OpportunityLineItem.Opportunity.Sales_Organisation__c, ScheduleDate, Quantity), Id,Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(15, dealProduct.Quantity, 'Should be 1');
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(300, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(15, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);*/
                } else {
                    System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                    /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(300, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(15, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);*/
                }
                System.assertEquals(15, dealProduct.Initial_Quantity__c, 'Updated Quantity != Deal Product.Target Quantity as Manually Schedule true');
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(15, schedule.Quantity);
                    System.assertEquals(300, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }
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

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_And_3_With_Existing_Deal_And_Deal_Products_Without_Updated_Initial_Quanitity_Test(){
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;
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
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 10;
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

        for (OpportunityLineItem dealProduct : [Select (SELECT Id, Quantity, Revenue, OpportunityLineItem.NR_Revenue_Recognition_Date__c,OpportunityLineItem.Product2.Street_Date__c,ScheduleDate FROM OpportunityLineItemSchedules ORDER BY OpportunityLineItem.Opportunity.Sales_Organisation__c, ScheduleDate, Quantity), Initial_Quantity__c, Id,Opportunity.Account.Sales_Organization__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(10, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(10, dealProduct.Initial_Quantity__c);
                //if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    for (OpportunityLineItemSchedule sch : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(10, sch.Quantity);
                        System.assertEquals(200, sch.Revenue);
                        System.assertEquals(sch.OpportunityLineItem.Product2.Street_Date__c, sch.ScheduleDate);
                    }
                    /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(200, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(10, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
                } else {
                    System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(200, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(10, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
                }*/
            }
        }

        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(220, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(200, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        // Verify Schedules are not updated as Initial Quantity is not updated
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Opportunity.Account.Sales_Organization__c,(SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, Quantity, Revenue FROM OpportunityLineItemSchedules ORDER BY OpportunityLineItem.Opportunity.Sales_Organisation__c, ScheduleDate, Quantity), Id,Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(10, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(10, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(10, schedule.Quantity);
                    System.assertEquals(200, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }
                /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(200, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                System.assertEquals(10, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);*/
            } else {
                System.assertEquals(220, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(220, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                System.assertEquals(220, dealProduct.Initial_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(4400, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                System.assertEquals(220, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
                */
                for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(220, schedule.Quantity);
                    System.assertEquals(4400, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }
            }
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

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_Insert_Account_Plan_Without_Existing_Deal_And_Deal_Products_Test() {

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
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
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = true;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;

        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

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

        // Verify Process NR Batch checkbox is checked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is no Scenario 1 and 2
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
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
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
            } else {
                System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
                System.assertEquals(55, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
                System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            }
        }

        // Verify Schedules created as Initial Quantity is entered
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, OpportunityLineItem.Opportunity.Account.Sales_Organization__c,Quantity, Revenue FROM OpportunityLineItemSchedule Order BY OpportunityLineItem.Opportunity.Account.Sales_Organization__c DESC];
        System.assertEquals(1, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(schedule.OpportunityLineItem.Opportunity.Account.Sales_Organization__c)) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);            
            } else {
                System.assertEquals(55, schedule.Quantity);
                System.assertEquals(1100, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                /*if (i == 0) {
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(1100, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                } else {
                    System.assertEquals(55, schedule.Quantity);
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                }*/
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_Insert_Account_Plan_With_Existing_Deal_And_No_Deal_Products_Test() {

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

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
            lstTargets[i].Target_Units__c = 2.5;
            lstTargets[i].Target__c = 50;
            lstTargets[i].Account__c = tw.lstAccounts[i].Id;
            lstTargets[i].Product__c = tw.lstProduct[i].id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        } 
        insert lstTargets;
        /*List<Target__c> lstTargets = [SELECT Id, Product__c, RecordTypeId, Target__c FROM Target__c];
        for(Integer i=0 ; i< lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+lstTargets); 
        update lstTargets;*/
        System.assertEquals(5, lstTargets.size(), 'Updated Targets');

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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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

        // Verify no new Deals inserted
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        // Verify deal Products inserted on Scenario 3 i.e Account Plan is inserted after deal is created
        List<OpportunityLineItem> dealProducts = [Select Id,Account_Price__c,Opportunity.Account.Sales_Organization__c,Target_Quantity__c,Initial_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, Revenue,OpportunityLineItem.NR_Revenue_Recognition_Date__c, OpportunityLineItem.Product2.Street_Date__c,ScheduleDate FROM OpportunityLineItemSchedules ORDER BY OpportunityLineItem.Opportunity.Sales_Organisation__c, ScheduleDate, Quantity)
            from OpportunityLineItem
        ];
        System.assertEquals(2, dealProducts.size(), 'Initial Deal Products');

        // Verify 2 physical deal products created.
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(20, dealProduct.Account_Price__c);
                    System.assertEquals(3, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                    System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(3, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
                    /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(60, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(3, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);*/
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(3, schedule.Quantity);
                        System.assertEquals(60, schedule.Revenue);
                        System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                    }
                } else {
                    System.assertEquals(55, dealProduct.Quantity);
                    System.assertEquals(55, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                    System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                    /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(1100, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(55, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);*/
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(55, schedule.Quantity);
                        System.assertEquals(1100, schedule.Revenue);
                        System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                    }
                }
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);

        // Verify Target flags are reset after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Commented Germany Code Changes
        /*for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Product__r.RecordTypeId, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
            }
        }*/

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

    
    
    public static testMethod void Scenario3_Insert_Account_Plan_With_Existing_Deal_And_Deal_Products_Test() {
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<Id> setProcessedProductIds = new Set<Id>();

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
            // Initial Quantity not updated so it same as Target Quantity
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 10;
            }
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
        Map<Id, Account_Plan__c> mapIdToInstance = new Map<Id, Account_Plan__c>([SELECT Id, Target_Quantity__c FROM Account_Plan__c WHERE Id IN: lstAccountPlan]);

        //List<Target__c> lstTargets = [SELECT Id, Product__c, RecordTypeId, Target__c FROM Target__c];
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(tw.lstAccounts , [SELECT Id FROM Product_Group__c] , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target_Units__c = 2.5;
            lstTargets[i].Target__c = 50;
            lstTargets[i].Account__c = tw.lstAccounts[i].Id;
            lstTargets[i].Product__c = tw.lstProduct[i].id;
            lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        } 
        insert lstTargets;
        
        
        
        /*for(Integer i=0 ; i< lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+lstTargets); 
        update lstTargets;*/
        System.assertEquals(5, lstTargets.size(), 'Updated Targets');

        System.assertEquals(5, [Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5, [Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(5, [Select Id, Quantity, Revenue  from OpportunityLineItemSchedule].size(), 'Initial Deal Products');

        for (OpportunityLineItem dealProduct : [Select Opportunity.Account.Sales_Organization__c, (SELECT Id, Quantity,OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate, Revenue FROM OpportunityLineItemSchedules ORDER BY OpportunityLineItem.Opportunity.Sales_Organisation__c, ScheduleDate, Quantity), Initial_Quantity__c, Id, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(10, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(10, dealProduct.Initial_Quantity__c);
                /*if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(200, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(10, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
                    //for (OpportunityLineItemSchedule sch : dealProduct.OpportunityLineItemSchedules) {
                        //System.assertEquals(10, sch.Quantity);
                        //System.assertEquals(200, sch.Revenue);
                    //}
                } else {
                    System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(200, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(10, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
                }*/
                for (OpportunityLineItemSchedule sch : dealProduct.OpportunityLineItemSchedules) {
                    System.assertEquals(10, sch.Quantity);
                    System.assertEquals(200, sch.Revenue);
                    System.assertEquals(sch.OpportunityLineItem.Product2.Street_Date__c, sch.ScheduleDate);
                }
            }
        }
	
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
        
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);

        System.assertEquals(5, [Select Id, Name from Opportunity].size(), 'No New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        // Verify Schedules are not updated as Initial Quantity is not updated
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(5, lineItemSchedules.size());

        Integer physicalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Opportunity.Account.Sales_Organization__c,(SELECT Id, Quantity, OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate,  Revenue FROM OpportunityLineItemSchedules ORDER BY OpportunityLineItem.Opportunity.Sales_Organisation__c, ScheduleDate, Quantity), Id,Initial_Quantity__c, Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                if (CRM_AppConstants.BENELUX_SALES_ORGS.contains(dealProduct.Opportunity.Account.Sales_Organization__c)) {
                    System.assertEquals(20, dealProduct.Account_Price__c);
                    System.assertEquals(10, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                    System.assertEquals(10, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');                
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(10, schedule.Quantity);
                        System.assertEquals(200, schedule.Revenue);
                        System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                    }
                    /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(60, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(3, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);*/
                } else {
                    System.assertEquals(10, dealProduct.Quantity, 'Should be 1');
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Updated Quantity = Account Plan.Target Quantity');
                    System.assertEquals(10, dealProduct.Initial_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                    /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(1100, dealProduct.OpportunityLineItemSchedules[0].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(55, dealProduct.OpportunityLineItemSchedules[1].Quantity);
                    System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
                    System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);*/
                    for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                        System.assertEquals(10, schedule.Quantity);
                        System.assertEquals(200, schedule.Revenue);
                        System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                    }
                }
                physicalDealProducts++;
            }
        }
        System.assertEquals(2, physicalDealProducts);
        
        Test.stopTest();
        
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
        
        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
        
    }

        /* JAPAN Methods */
    public static testMethod void Scenario1_JAPAN_With_Existing_One_InValid_And_One_Valid_Deal_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        
        // Set the Sales Org as JAPAN for Account
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            if (acc.Games_Physical__c) {
                if (CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(acc.Sales_Organization__c)) {
                    acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                }
            }
        }
        update tw.lstAccounts;

        // Verify Products are newly created due to which it will be considered for batch processing
        // Set Product Market = 'Rental' for one Physical Product and 'Sell Through' on another Physical Product
        Integer count = 0;
        for (integer i=0 ; i < tw.lstProduct.size() ; i++) {
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                tw.lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                if (count == 0) {
                    tw.lstProduct[i].Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                    count++;
                } else {
                    tw.lstProduct[i].Product_Market__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
                }
            }
        }
        update tw.lstProduct;

        List<Country_Plan__c> lstCountryPlan = [SELECT Id,Country__c, Target_Quantity__c, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //added by ketan
            cp.Target_Quantity__c = null;
            cp.Target_Revenue__c = 5000;
            cp.Stretch_Target__c = 10;
        }
        update lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Country_Plan__r.NR_Product__r.Product_Market__c, Handling_Fee__c FROM Account_Plan__c];
        for (Account_Plan__c accPlan : lstAccountPlan) {
            if (accPlan.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            }
            accPlan.Handling_Fee__c = 100;
        }
        update lstAccountPlan;

        // Verify 5 opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Set Market Type = 'RNTAL'
        Integer countOpp = 0;
        Opportunity oppToDelete;
        Opportunity rentalOpp;
        String dealPeriod;
        for(integer i=0 ; i < tw.lstOpportunity.size() ; i++){
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                tw.lstOpportunity[i].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                if (countOpp == 0) {
                    rentalOpp = tw.lstOpportunity[i];
                    countOpp++;
                } else {
                    oppToDelete = tw.lstOpportunity[i];
                }
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(tw.lstProduct[i].Street_Date__c);
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
                tw.lstOpportunity[i].NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            }
        }
        update tw.lstOpportunity;



        List<Opportunity> oppToDeleteList = [SELECT Id FROM Opportunity WHERE Id = :oppToDelete.Id];
        delete oppToDeleteList;

        // Verify only 4 deals present, 3 for Digital, 1 for Rental Physical. Sell through Deal not present
        Map<Id, Opportunity> mapExitingOpp = new Map<Id, Opportunity>([SELECT Id,Market_Type__c, NR_Deal_Unique_Key__c, Start_Date__c, CloseDate FROM Opportunity]);
        System.assertEquals(4, mapExitingOpp.size());
        System.debug('--mapExitingOpp--->'+mapExitingOpp);
        
        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        for (Product2 prod : [SELECT Id, RecordTypeId, Street_Date__c, NR_Product_Created__c, Street_Date_Has_Changed__c FROM Product2]) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(prod.NR_Product_Created__c);
                System.assert(!prod.Street_Date_Has_Changed__c);
                System.assertEquals(System.today() + 32, prod.Street_Date__c);
            }
        }

        List<Account_Plan__c> lstExistingAccountPlan = [SELECT Id, Handling_Fee__c, Target_Quantity__c, Total_Target__c, Rental_Revenue_Per_Unit__c, Decay_Curve_Template__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Account_Plan__c> mapAccountIdToAaccountPlanId = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accountPlanInstance : lstExistingAccountPlan) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance);
            System.assertEquals(550, accountPlanInstance.Total_Target__c);
            System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
            System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
            System.assertEquals(100, accountPlanInstance.Handling_Fee__c);
            System.assertEquals(100, accountPlanInstance.Rental_Revenue_Per_Unit__c);
            System.assertEquals(null, accountPlanInstance.Decay_Curve_Template__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 1 additial opportunity record created for Sell Through
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 2 deal product records for 2 physical products should be created through batch
        // 1 for existing rental Deal
        // 1 for newly created sell through deal
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Account_Plan__c, Promoted_Price__c, SAP_Promoted_Price__c, Opportunity.AccountId, Opportunity.Start_Date__c, Opportunity.CloseDate, 
                    Opportunity.Promo_Start_Date__c, Opportunity.Promo_End_Date__c, Id,Product2.RecordTypeId,Opportunity.Name,
                    Opportunity.Market_Type__c,Opportunity.Account.Name,Product2.Street_Date__c,Product2.Product_Market__c,
                    Opportunity.Account.Sales_Organization__c, Account_Price__c, Initial_Quantity__c, 
                    Target_Quantity__c,Quantity FROM OpportunityLineItem
        ]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            //System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            //System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
            System.assertEquals(1, dealProduct.Quantity, 'Quantity should be default to 1');
            System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Target Quantity should be 0');
            System.assertEquals(dealProduct.Opportunity.Market_Type__c,dealProduct.Product2.Product_Market__c, 'Both Deal.Market_Type and Product.Product_Market Must be equal');
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId).Id, dealProduct.Account_Plan__c);
            if (dealProduct.Product2.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId).Handling_Fee__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(6, dealProduct.Target_Quantity__c, '550 / 100 - Target Quantity should be Account Plan.Total Target / Account Plan.Rental Revenue Per Unit');
                System.assertEquals(rentalOpp.Id, dealProduct.OpportunityId);
                // Verify the rental deal was present earlier
                System.assert(mapExitingOpp.containsKey(dealProduct.OpportunityId));
            } else {
                System.assertEquals(20, dealProduct.Promoted_Price__c);
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(28, dealProduct.Target_Quantity__c, '550 / 20 - Target Quantity should be Account Plan.Total Target / Deal Product.Account Price');               

                // Verify the deal was not present earlier which means it is newly created
                System.assert(!mapExitingOpp.containsKey(dealProduct.OpportunityId));
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(dealProduct.Product2.Street_Date__c);
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

                    String dealName = CRM_AppConstants.NR_Deal_Japan_Naming_INITIAL + CRM_AppConstants.NR_Deal_Japan_Market_Type_SELL_THROUGH + CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_PHYSICAL + startDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year +' '+ startMonth + ' ' + startDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day +' '+ CRM_AppConstants.NR_Deal_Japan_Month_Connector + endDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year  +' '+ endMonth +' '+ endDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day + ' ' + dealProduct.Opportunity.Account.Name;
                    System.assertEquals(dealName, dealProduct.Opportunity.Name);
                    System.assertEquals(startDate, dealProduct.Opportunity.Start_Date__c);
                    System.assertEquals(endDate, dealProduct.Opportunity.CloseDate);
                    System.assertEquals(startDate, dealProduct.Opportunity.Promo_Start_Date__c);
                    System.assertEquals(endDate, dealProduct.Opportunity.Promo_End_Date__c);
                }
            }
        }

        // Verify one Schedule created for Rental Deal Product as Initial Quantity is entered and no Account Plan Decay Curve Template present
        // Verify one Schedule created for Sell Deal Product similar to UK as Initial Quantity 
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Product2.Product_Market__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, OpportunityLineItem.OpportunityId,OpportunityLineItem.Product2.Street_Date__c, ScheduleDate, Description, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule ORDER BY OpportunityLineItem.Product2.Product_Market__c DESC];
        System.assertEquals(2, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (schedule.OpportunityLineItem.Product2.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                System.assertEquals(rentalOpp.Id, schedule.OpportunityLineItem.OpportunityId);
                System.assertEquals(System.today() + 32, schedule.OpportunityLineItem.Product2.Street_Date__c);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                System.assertEquals(1, schedule.Quantity, 'As Initial Qty = 0');
                System.assertEquals(0, schedule.Revenue, 'As Initial Qty = 0');
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedule.Description);
            } else {
                /*if (i == 0 || i == 2) {
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(20, schedule.Revenue, 'As Initial Qty * Promoted Price');
                    System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedule.Description);
                } else {
                    System.assertEquals(System.today() + 32, schedule.OpportunityLineItem.Product2.Street_Date__c);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                    System.assertEquals(1, schedule.Quantity, 'As Initial Qty = 1');
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedule.Description);
                }*/
                System.assertEquals(System.today() + 32, schedule.OpportunityLineItem.Product2.Street_Date__c);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                System.assertEquals(1, schedule.Quantity, 'As Initial Qty = 0');
                System.assertEquals(0, schedule.Revenue, 'As Zero Initial Quantity');
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedule.Description);
            }
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

   /* public static testMethod void Scenario2_JAPAN_With_Deal_Product_To_Be_Cloned_Present_In_Committed_Deal_Along_New_Deal_And_DP_Created_Test(){

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
            createData();

        // Make the Sales Org as JAPAN for Accounts
        Account gamesPhysicalAccount;
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            if (acc.Games_Physical__c) {
                if (CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(acc.Sales_Organization__c)) {
                    acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                }
                gamesPhysicalAccount = acc;
            }
        }
        update tw.lstAccounts;
        System.assertNotEquals(null, gamesPhysicalAccount);

        String dealPeriod = '';
        for(integer i=0 ; i < tw.lstOpportunity.size() ; i++){
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                tw.lstOpportunity[i].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(tw.lstProduct[i].Street_Date__c);
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
                tw.lstOpportunity[i].NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            }
        }
        update tw.lstOpportunity;

        Product2 gamesPhysicalProduct;
        for(Product2 p : tw.lstProduct){
            p.NR_Product_Created__c = false;
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                p.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                //p.Street_Date__c = system.today()+140;
                if (p.Type__c == 'Games Physical') {
                    gamesPhysicalProduct = p;
                }
            }
        }
        update tw.lstProduct;
        System.assertNotEquals(null, gamesPhysicalProduct);
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstDealsForChangedStreetDate = CRM_TestDataFactory.createOpportunitiesWithAccounts(new List<Account>{gamesPhysicalAccount},1,false);
        System.assertEquals(1, lstDealsForChangedStreetDate.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstDealsForChangedStreetDate.size(); i++) {
            Opportunity d0_existingDeal = lstDealsForChangedStreetDate[i];
            d0_existingDeal.AccountId = gamesPhysicalAccount.Id;
            d0_existingDeal.Name = 'Deal' + countDeal++;
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            d0_existingDeal.CurrencyIsoCode = 'USD';
            d0_existingDeal.Start_Date__c = system.today() + 140;
            d0_existingDeal.CloseDate = system.today() + 160;
            d0_existingDeal.Promo_Start_Date__c = system.today() + 140;
            d0_existingDeal.Promo_End_Date__c = system.today() + 160;
            if (gamesPhysicalAccount.Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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

            d0_existingDeal.NR_Deal_Unique_Key__c = gamesPhysicalAccount.Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(gamesPhysicalProduct.Type__c);
            d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;

            d0_existingDeal.Product_Type__c = gamesPhysicalProduct.Type__c;
            if(d0_existingDeal.Product_Type__c!= null){
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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
                d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            }
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);

        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate;     
        
        lstDecayCurveTemplate = [SELECT Id, MaxDecayCurveItemDay__c FROM Decay_Curve_Template__c];
        System.assertEquals(1, lstDecayCurveTemplate.size());

        List<Country_Plan__c> lstCountryPlan = [SELECT Id,Country__c, Target_Quantity__c, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //added by ketan
            cp.Target_Quantity__c = null;
            cp.Target_Revenue__c = 5000;
            cp.Stretch_Target__c = 10;
        }
        update lstCountryPlan;

        Test.startTest();
        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Customer__c, Country_Plan__r.NR_Product__r.Product_Market__c, Decay_Curve_Template__c, Handling_Fee__c FROM Account_Plan__c];
        Map<Id, Account_Plan__c> mapAccountIdToAP = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accPlan : lstAccountPlan) {
            if (accPlan.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
                accPlan.Handling_Fee__c = 100;
                accPlan.Decay_Curve_Template__c = lstDecayCurveTemplate[0].Id;
                accPlan.Rental_Price__c = 70;
                accPlan.Revenue_Share__c = 25.5;
                accPlan.Number_of_Rentals_per_Unit__c = 20;
                accPlan.Final_Purchase_Price__c = 20;
                accPlan.Final_Purchase__c = 30;
            }
            accPlan.Target_Revenue_Has_Changed__c = false;
            mapAccountIdToAP.put(accPlan.Customer__c, accPlan);
        }
        update lstAccountPlan;
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;
        System.debug('-lstAccountPlan---->'+lstAccountPlan);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            if (tw.lstProduct[i].Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                lstDealProduct[i].Handling_Fee__c = 100;
                lstDealProduct[i].Rental_Price__c = 70;
                lstDealProduct[i].Revenue_Share__c = 25.5;
                lstDealProduct[i].Number_of_Rentals_per_Unit__c = 20;
                lstDealProduct[i].Final_Purchase_Price__c = 20;
                lstDealProduct[i].Final_Purchase__c = 30;
                lstDealProduct[i].Decay_Curve_Template__c = lstDecayCurveTemplate[0].Id;
            }
            lstDealProduct[i].Account_Plan__c = mapAccountIdToAP.get(tw.lstOpportunity[i].AccountId).Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Verify Schedules created with Initial Quantity 1
        List<OpportunityLineItem> lineItemsBeforeBatchRun = [SELECT Id, Product2.Street_Date__c, Product2.RecordTypeId, (SELECT Id, Type, ScheduleDate, Description, Quantity, Revenue FROM OpportunityLineItemSchedules ORDER BY ScheduleDate) FROM OpportunityLineItem];
        System.assertEquals(5, lineItemsBeforeBatchRun.size());
        for (OpportunityLineItem dealProduct : lineItemsBeforeBatchRun) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
                System.assertEquals(5, schedules.size());
                System.assertEquals(system.today() + 32, dealProduct.Product2.Street_Date__c);
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(((Integer) lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(0, schedules[2].Quantity);
                System.assertEquals(0, schedules[3].Quantity);
                System.assertEquals(0, schedules[4].Quantity);
                System.assertEquals(100, schedules[0].Revenue);
                System.assertEquals(117.81, schedules[1].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(117.81, schedules[2].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(121.38, schedules[3].Revenue,'1 * 70 * (25.5 / 100) * 20 * (34 / 100)');
                System.assertEquals(6, schedules[4].Revenue, '1 * 20 * (30 / 100)');
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);
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

        // Change the Street Date to future
        for(Product2 p : tw.lstProduct){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                p.Street_Date__c = system.today()+140;
            }
        }
        update tw.lstProduct;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(system.today()+140, p.Street_Date__c);
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify 6 valid opportunity records present -> 5 existing deals and 1 new Deal which will be valid for Games Physical Product after Date change
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(6, dealsBeforeBatchRun.size());

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

        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, RecordTypeId, Country_Plan__r.NR_Product__r.Product_Market__c, Handling_Fee__c, Rental_Revenue_Per_Unit__c, Decay_Curve_Template__c, Country_Plan__r.Target_Revenue__c, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
            System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                System.assertEquals(463, accountPlanInstance.Rental_Revenue_Per_Unit__c);
                System.assertEquals(100, accountPlanInstance.Handling_Fee__c);
                System.assertEquals(lstDecayCurveTemplate[0].id, accountPlanInstance.Decay_Curve_Template__c);
            }
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify only 1 additional opportunity records are created for Video Physical Product after Dat change
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(7, dealsAfterBatchRun.size());

        // Verify Satge Name is not changed
        Opportunity newDeal;
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            if (mapIdToDealInstance.containsKey(newDealInsatnce.Id)) {
                System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
            } else {
                System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT, newDealInsatnce.StageName);
                newDeal = newDealInsatnce;
            }
        }
        System.assertNotEquals(null, newDeal);

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        Integer countPhysical = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsAfterBatchRun.size());

        for (OpportunityLineItem dealProduct : [SELECT Id, Opportunity.Market_Type__c,Account_Plan__c, Product2.Product_Market__c, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(2, dealProduct.Target_Quantity__c, 'Quantity = 550 / 463 - AccountPlan.Total Target / AccountPlan.Rental Revenue Per Unit');
                System.assertEquals(1, dealProduct.Initial_Quantity__c, 'Initial Quantity should be same as Quantity');
                System.assertEquals(CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE, dealProduct.Product2.Product_Market__c);
                System.assertEquals(dealProduct.Opportunity.Market_Type__c, dealProduct.Product2.Product_Market__c);
                if (dealProduct.OpportunityId != newDeal.Id) {
                    // Verify these deal products are linked with existing deals based on changed Street Date
                    System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                    countPhysical ++;
                } else {
                    System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                    countPhysical ++;
                }
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical);

        // Verify Schedules created with Initial Quantity 1
        List<OpportunityLineItem> lineItemsAfterBatchRun = [SELECT Id, Product2.Street_Date__c, Product2.RecordTypeId, (SELECT Id, Type, ScheduleDate, Description, Quantity, Revenue FROM OpportunityLineItemSchedules ORDER BY ScheduleDate) FROM OpportunityLineItem];
        System.assertEquals(5, lineItemsAfterBatchRun.size());
        Integer existingPhysicalProdScheduleCount = 0;
        for (OpportunityLineItem dealProduct : lineItemsAfterBatchRun) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
                System.assertEquals(5, schedules.size());
                System.assertEquals(system.today()+140, dealProduct.Product2.Street_Date__c);
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(((Integer) lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(0, schedules[2].Quantity);
                System.assertEquals(0, schedules[3].Quantity);
                System.assertEquals(0, schedules[4].Quantity);
                System.assertEquals(100, schedules[0].Revenue);
                System.assertEquals(117.81, schedules[1].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(117.81, schedules[2].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(121.38, schedules[3].Revenue,'1 * 70 * (25.5 / 100) * 20 * (34 / 100)');
                System.assertEquals(6, schedules[4].Revenue, '1 * 20 * (30 / 100)');
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);
                existingPhysicalProdScheduleCount++;
            }
        }
        // 5 each for 2 Physical Products
        System.assertEquals(2, existingPhysicalProdScheduleCount);

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

    public static testMethod void Scenario3_JAPAN_With_No_Existing_Deal_And_Deal_Product_Present_With_Rental_Product_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        insert lstAccounts[0];
        Account soldToAccountGP = lstAccounts[0];

        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        System.assertEquals(1, lstProGrp.size());

        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate; 
        
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
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        p0_GamesPhysical.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;  //Set Product Market equal to RENTAL
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = true;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //added by ketan
            cp.Target_Revenue__c = 5000;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, false);
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            accPlan.Handling_Fee__c = 100;
            accPlan.Decay_Curve_Template__c = lstDecayCurveTemplate[0].Id;
            accPlan.Rental_Price__c = 70;
            accPlan.Revenue_Share__c = 25.5;
            accPlan.Number_of_Rentals_per_Unit__c = 20;
            accPlan.Final_Purchase_Price__c = 20;
            accPlan.Final_Purchase__c = 30;
        }
        insert lstAccountPlan;

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesPhysical.Target__c = 50;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        
        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Revenue__c = 8000;
        }
        update lstCountryPlan;

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

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Total_Target__c, Rental_Revenue_Per_Unit__c, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.Target_Revenue__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(880, accountPlanInstance.Total_Target__c);
            System.assertEquals(8000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
            System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
            System.assertEquals(463, accountPlanInstance.Rental_Revenue_Per_Unit__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
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

        // Verify deal and deal products are created for Scenario 3 in case of JAPAN
        List<Opportunity> dealsAfterBatchRun = [SELECT Id,Market_Type__c FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        //Verify Deal Market Type equal to RENTAL
        System.assertEquals(CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE, dealsAfterBatchRun[0].Market_Type__c);
        lstDecayCurveTemplate = [SELECT Id, MaxDecayCurveItemDay__c FROM Decay_Curve_Template__c];
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Decay_Curve_Template__c,   Quantity,Opportunity.AccountId, Account_Plan__c,Opportunity.Market_Type__c,Product2.Product_Market__c,Target_Quantity__c,Initial_Quantity__c,
        Handling_Fee__c,Rental_Price__c, Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c, Final_Purchase__c,
        (SELECT Id, Quantity, Type, Description, Revenue, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
            System.assertEquals(dealProduct.Opportunity.Market_Type__c,dealProduct.Product2.Product_Market__c,'Product Market must be equal to Market Type on Deal');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(2, dealProduct.Target_Quantity__c, '880 / 463 - AccountPlan.TotalTarget / AccountPlan.Rental Revenue Per Unit');
            //System.assertEquals(90, dealProduct.Initial_Quantity__c);
            System.assertEquals(0, dealProduct.Initial_Quantity__c);
            System.assertEquals(100, dealProduct.Handling_Fee__c);
            System.assertEquals(70, dealProduct.Rental_Price__c);
            System.assertEquals(25.5, dealProduct.Revenue_Share__c);
            System.assertEquals(20, dealProduct.Number_of_Rentals_per_Unit__c);
            System.assertEquals(20, dealProduct.Final_Purchase_Price__c);
            System.assertEquals(30, dealProduct.Final_Purchase__c);
            System.assertEquals(lstDecayCurveTemplate[0].Id, dealProduct.Decay_Curve_Template__c);
            /*for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(1, schedule.Quantity);
                System.assertEquals(100, schedule.Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedule.Description);
            }*/
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            System.assertEquals(1, schedules.size());
            System.assertEquals(System.today() + 32, schedules[0].ScheduleDate);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
            System.assertEquals(1, schedules[0].Quantity);
            System.assertEquals(0, schedules[0].Revenue);
            System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedules[0].Description);
            /*System.assertEquals(5, schedules.size());
            System.assertEquals(System.today() + 32, schedules[0].ScheduleDate);
            System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
            System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
            System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
            System.assertEquals((System.today() + 32).addDays(((Integer) lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
            System.assertEquals(1, schedules[0].Quantity);
            System.assertEquals(0, schedules[1].Quantity);
            System.assertEquals(0, schedules[2].Quantity);
            System.assertEquals(0, schedules[3].Quantity);
            System.assertEquals(0, schedules[4].Quantity);
            System.assertEquals(100, schedules[0].Revenue);
            System.assertEquals(117.81, schedules[1].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
            System.assertEquals(117.81, schedules[2].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
            System.assertEquals(121.38, schedules[3].Revenue,'1 * 70 * (25.5 / 100) * 20 * (34 / 100)');
            System.assertEquals(6, schedules[4].Revenue, '1 * 20 * (30 / 100)');
            System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
            System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
            System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
            System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
            System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);*/
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_JAPAN_With_No_Existing_Deal_And_Deal_Product_Present_With_Sell_Through_Product_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
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
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        p0_GamesPhysical.Product_Market__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;  //Set Product Market equal to RENTAL
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = true;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //added by ketan
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;
        
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, false);
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
        }
        insert lstAccountPlan;

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesPhysical.Target__c = 50;
        t0_GamesPhysical.Target_Maintained_As__c = CRM_AppConstants.TARGET_MAINTAINED_AS_REVENUE;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        
        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;
        

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

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        // Verify Target flags are set
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(90, accountPlanInstance.Target_Quantity__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
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

        // Verify deal and deal products are created for Scenario 3 in case of JAPAN
        List<Opportunity> dealsAfterBatchRun = [SELECT Id,Market_Type__c FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        //Verify Deal Market Type equal to RENTAL
        System.assertEquals(CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE, dealsAfterBatchRun[0].Market_Type__c);
        
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Quantity,Account_Plan__c, Opportunity.AccountId, Opportunity.Market_Type__c,Product2.Product_Market__c,Target_Quantity__c,Initial_Quantity__c, (SELECT Id, Quantity, Type, Description, Revenue,OpportunityLineItem.NR_Revenue_Recognition_Date__c,OpportunityLineItem.Product2.Street_Date__c,ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
            System.assertEquals(dealProduct.Opportunity.Market_Type__c,dealProduct.Product2.Product_Market__c,'Product Market must be equal to Market Type on Deal');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(90, dealProduct.Target_Quantity__c);
            //System.assertEquals(90, dealProduct.Initial_Quantity__c);
            System.assertEquals(0, dealProduct.Initial_Quantity__c);
            /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
            System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
            System.assertEquals(20, dealProduct.OpportunityLineItemSchedules[0].Revenue);
            System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
            System.assertEquals(1, dealProduct.OpportunityLineItemSchedules[1].Quantity);
            System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
            System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
            */
            for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(1, schedule.Quantity, 'As Initial Qty = 1');
                System.assertEquals(0, schedule.Revenue, 'As Initial Quantity 0');
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedule.Description);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_JAPAN_With_Existing_Deal_And_Deal_Product_Present_With_Rental_Product_Account_Plan_Price_Change_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
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

        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate; 
        
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
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        p0_GamesPhysical.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;  //Set Product Market equal to RENTAL
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = true;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //added by ketan
            cp.Target_Revenue__c = 5000;
        }
        insert lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, false);
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            accPlan.Share__c = 10;
            accPlan.Handling_Fee__c = 100;
            accPlan.Decay_Curve_Template__c = lstDecayCurveTemplate[0].Id;
            accPlan.Rental_Price__c = 70;
            accPlan.Revenue_Share__c = 25.5;
            accPlan.Number_of_Rentals_per_Unit__c = 20;
            accPlan.Final_Purchase_Price__c = 20;
            accPlan.Final_Purchase__c = 30;
            accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
        }
        insert lstAccountPlan;

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesPhysical.Target__c = 50;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        
        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Revenue__c = 8000;
        }
        update lstCountryPlan;

        // Scenario 3 should not be present
        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        List<Account_Plan__c> lstAP = [SELECT Id, Total_Target__c, Rental_Revenue_Per_Unit__c, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.Target_Revenue__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        for (Account_Plan__c accountPlanInstance : lstAP) {
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
        }
        update lstAP;

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

        // Create existing NR deal and deal product
        // Setting up 1 Deal data for the sold To Account
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(
                CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false),
                lstAccounts,
                lstProduct,
                lstPriceBookEntryPeriod
            );
        System.assertEquals(1, lstOpportunity.size());
        for (Integer i=0; i< lstOpportunity.size(); i ++) {
            Opportunity deal = lstOpportunity[i];
            deal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
            deal.Start_Date__c = system.today() + 30;
            deal.CloseDate = system.today() + 60;
            deal.Promo_Start_Date__c = system.today() + 30;
            deal.Promo_End_Date__c = system.today() + 60;
            Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(lstProduct[i].Street_Date__c);
            Date startDate = mapStartAndCloseDateForDeal.get('Start Date');
            Date endDate = mapStartAndCloseDateForDeal.get('End Date');
            String dealPeriod = '';
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
            lstOpportunity[i].NR_Deal_Unique_Key__c = lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(lstProduct[i].Type__c);
        }
        update lstOpportunity;

        // Setting up Deal Product data such that batch deal deal Product already present for the above created Deal
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccounts[i].Id + '-' + lstPriceBookEntry[i].Product2Id;
            lstDealProduct[i].Handling_Fee__c = 100;
            lstDealProduct[i].Rental_Price__c = 70;
            lstDealProduct[i].Revenue_Share__c = 25.5;
            lstDealProduct[i].Number_of_Rentals_per_Unit__c = 20;
            lstDealProduct[i].Final_Purchase_Price__c = 20;
            lstDealProduct[i].Final_Purchase__c = 30;
            lstDealProduct[i].Target_Quantity__c = 2;
            lstDealProduct[i].Decay_Curve_Template__c = lstDecayCurveTemplate[0].Id;
            lstDealProduct[i].Account_Plan__c = mapAccountIdToAaccountPlanId.get(lstOpportunity[i].AccountId);
        }
        insert lstDealProduct;
        System.assertEquals(1, lstDealProduct.size());

        lstDecayCurveTemplate = [SELECT Id, MaxDecayCurveItemDay__c FROM Decay_Curve_Template__c];
        // Verify the schedules are created properly
        List<OpportunityLineItemSchedule> schedules = [SELECT Id,OpportunityLineItemId,ScheduleDate, Quantity, Revenue, Type,Description FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(5, schedules.size());
        System.debug('-schedules--->'+schedules);
        System.assertEquals(System.today() + 32, schedules[0].ScheduleDate);
        System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
        System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
        System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
        System.assertEquals((System.today() + 32).addDays(((Integer) lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
        System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
        System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
        System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
        System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
        System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
        System.assertEquals(1, schedules[0].Quantity);
        System.assertEquals(0, schedules[1].Quantity);
        System.assertEquals(0, schedules[2].Quantity);
        System.assertEquals(0, schedules[3].Quantity);
        System.assertEquals(0, schedules[4].Quantity);
        System.assertEquals(100, schedules[0].Revenue);
        System.assertEquals(117.81, schedules[1].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
        System.assertEquals(117.81, schedules[2].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
        System.assertEquals(121.38, schedules[3].Revenue,'1 * 70 * (25.5 / 100) * 20 * (34 / 100)');
        System.assertEquals(6, schedules[4].Revenue, '1 * 20 * (30 / 100)');
        System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
        System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
        System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
        System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
        System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);

        // Modify the Rental Price to check Scenario 3 is invoked
        for (Account_Plan__c accAP : lstAP) {
            accAP.Handling_Fee__c = 150;
            accAP.Rental_Price__c = 7;
            accAP.Revenue_Share__c = 5;
            accAP.Number_of_Rentals_per_Unit__c = 2;
            accAP.Final_Purchase_Price__c = 2;
            accAP.Final_Purchase__c = 10;
        }
        update lstAP;

        // Verify Target flags are set
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Total_Target__c, Rental_Revenue_Per_Unit__c, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.Target_Revenue__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            System.assertEquals(880, accountPlanInstance.Total_Target__c);
            System.assertEquals(8000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
            System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
            System.assertEquals(151, accountPlanInstance.Rental_Revenue_Per_Unit__c);
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true as Scenario 3');
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

        // Verify deal and deal products are created for Scenario 3 in case of JAPAN
        List<Opportunity> dealsAfterBatchRun = [SELECT Id,Market_Type__c FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        //Verify Deal Market Type equal to RENTAL
        System.assertEquals(CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE, dealsAfterBatchRun[0].Market_Type__c);
        
        List<OpportunityLineItem> dealProductsAfterBatchRun =
            [
                SELECT
                    Id,Quantity,Account_Plan__c, Opportunity.AccountId, Opportunity.Market_Type__c,Product2.Product_Market__c,Target_Quantity__c,Initial_Quantity__c,
                    Handling_Fee__c, Rental_Price__c, Revenue_Share__c, Number_of_Rentals_per_Unit__c, Final_Purchase_Price__c, Final_Purchase__c,
                    (SELECT Id, Quantity, Type, Description, Revenue, ScheduleDate FROM OpportunityLineItemSchedules)
                FROM OpportunityLineItem
            ];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
            System.assertEquals(dealProduct.Opportunity.Market_Type__c,dealProduct.Product2.Product_Market__c,'Product Market must be equal to Market Type on Deal');
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(6, dealProduct.Target_Quantity__c, '880 / 151 - AccountPlan.TotalTarget / AccountPlan.Rental Revenue Per Unit');
            //System.assertEquals(90, dealProduct.Initial_Quantity__c);
            System.assertEquals(1, dealProduct.Initial_Quantity__c);
            // Verify all Rental fields in deal product have been updated properly
            System.assertEquals(150, dealProduct.Handling_Fee__c);
            System.assertEquals(7, dealProduct.Rental_Price__c);
            System.assertEquals(5, dealProduct.Revenue_Share__c);
            System.assertEquals(2, dealProduct.Number_of_Rentals_per_Unit__c);
            System.assertEquals(2, dealProduct.Final_Purchase_Price__c);
            System.assertEquals(10, dealProduct.Final_Purchase__c);

            List<OpportunityLineItemSchedule> updatedSchedules = dealProduct.OpportunityLineItemSchedules;
            System.assertEquals(5, updatedSchedules.size());
            //System.assertEquals(System.today() + 32, updatedSchedules[0].ScheduleDate);
            System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[0].Day_Number__c), updatedSchedules[1].ScheduleDate);
            System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[1].Day_Number__c), updatedSchedules[2].ScheduleDate);
            System.assertEquals((System.today() + 32).addDays((Integer) lstDecayCurveItem[2].Day_Number__c), updatedSchedules[3].ScheduleDate);
            System.assertEquals((System.today() + 32).addDays(((Integer) lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), updatedSchedules[4].ScheduleDate);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, updatedSchedules[0].Type);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, updatedSchedules[1].Type);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, updatedSchedules[2].Type);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, updatedSchedules[3].Type);
            System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, updatedSchedules[4].Type);
            System.assertEquals(1, updatedSchedules[0].Quantity);
            System.assertEquals(0, updatedSchedules[1].Quantity);
            System.assertEquals(0, updatedSchedules[2].Quantity);
            System.assertEquals(0, updatedSchedules[3].Quantity);
            System.assertEquals(0, updatedSchedules[4].Quantity);
            System.assertEquals(150, updatedSchedules[0].Revenue);
            System.assertEquals(0.231, updatedSchedules[1].Revenue,'1 * 7 * (5 / 100) * 2 * (33 / 100)');
            System.assertEquals(0.231, updatedSchedules[2].Revenue,'1 * 7 * (5 / 100) * 2 * (33 / 100)');
            System.assertEquals(0.238, updatedSchedules[3].Revenue,'1 * 7 * (5 / 100) * 2 * (34 / 100)');
            System.assertEquals(0.2, updatedSchedules[4].Revenue, '1 * 2 * (10 / 100)');
            System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, updatedSchedules[0].Description);
            System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[0].Percent_Allocation__c) + ' %', updatedSchedules[1].Description);
            System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[1].Percent_Allocation__c) + ' %', updatedSchedules[2].Description);
            System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[2].Percent_Allocation__c) + ' %', updatedSchedules[3].Description);
            System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, updatedSchedules[4].Description);
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void JAPAN_With_InValid_Product_Market_Test(){

        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Change the Sales Org of Account to JAPAN
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            if (acc.Games_Physical__c) {
                if (CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(acc.Sales_Organization__c)) {
                    acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                }
            }
        }
        update tw.lstAccounts;

        // Delete existing deals so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        //Set Product Market = 'RENTAL'
        for (integer i=0 ; i < tw.lstProduct.size() ; i++) {
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                tw.lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                if( i <= 1 ){
                    tw.lstProduct[i].Product_Market__c = '3';
                }else{
                    tw.lstProduct[i].Product_Market__c = null;
                }
            }
        }
        update tw.lstProduct;

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

        // Verify deals should not be created
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify deal product records should not be created through batch
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        // Verify Schedules should not be created 
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

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
    }

    public static testMethod void Scenario1_JAPAN_With_Existing_One_InValid_And_One_Valid_Deal_Music_Test() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        
        // Set the Sales Org as JAPAN for Account
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            if (acc.Games_Physical__c) {
                if (CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(acc.Sales_Organization__c)) {
                    acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                }
                acc.Games_Physical__c = false;
                acc.Music_Physical__c = true;
                acc.Storefront__c = null;
            }
            if (acc.Video_Physical__c) {
                acc.Video_Physical__c = false;
                acc.Music_Physical__c = true;
                acc.Storefront__c = null;
            }
        }
        update tw.lstAccounts;
        System.debug('--tw.lstAccounts-->'+tw.lstAccounts);

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
        /*lstLocaTitle[0].Country__c = lstCountry[0].Id;
        update lstLocaTitle;*/

        // Verify Products are newly created due to which it will be considered for batch processing
        // Set Product Market = 'Rental' for one Physical Product and 'Sell Through' on another Physical Product
        Integer count = 0;
        for (integer i=0 ; i < tw.lstProduct.size() ; i++) {
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                tw.lstProduct[i].Type__c = CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE;
                tw.lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
                tw.lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                tw.lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                if (count == 0) {
                    tw.lstProduct[i].Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                    count++;
                } else {
                    tw.lstProduct[i].Product_Market__c = CRM_AppConstants.DEAL_SELL_THROUGH_MARKET_TYPE;
                }
            }
        }
        update tw.lstProduct;

        List<Country_Plan__c> lstCountryPlan = [SELECT Id,Country__c, Target_Quantity__c, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Country__c = 'Japan'; //added by ketan
            cp.Target_Quantity__c = null;
            cp.Target_Revenue__c = 5000;
            cp.Stretch_Target__c = 10;
        }
        update lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = [SELECT Id,Country_Plan__r.NR_Product__r.Product_Market__c, Handling_Fee__c FROM Account_Plan__c];
        for (Account_Plan__c accPlan : lstAccountPlan) {
            if (accPlan.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
            }
            accPlan.Handling_Fee__c = 100;
        }
        update lstAccountPlan;

        // Verify 5 opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Set Market Type = 'RNTAL'
        Integer countOpp = 0;
        Opportunity oppToDelete;
        Opportunity rentalOpp;
        String dealPeriod;
        Integer dealCount = 0;
        for(integer i=0 ; i < tw.lstOpportunity.size() ; i++){
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                tw.lstOpportunity[i].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                if (countOpp == 0) {
                    rentalOpp = tw.lstOpportunity[i];
                    countOpp++;
                } else {
                    oppToDelete = tw.lstOpportunity[i];
                }
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(tw.lstProduct[i].Street_Date__c);
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
                String strdealProductType;
                if (tw.lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                    strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
                } else if (dealCount == 0) {
                    if (tw.lstProduct[i].Type__c == CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE)  {
                        strdealProductType = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
                    } else {
                        strdealProductType = tw.lstProduct[i].Type__c;
                    }
                    dealCount++;
                }
                tw.lstOpportunity[i].Product_Type__c = strdealProductType;
                tw.lstOpportunity[i].NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            }
        }
        update tw.lstOpportunity;

        List<Opportunity> oppToDeleteList = [SELECT Id FROM Opportunity WHERE Id = :oppToDelete.Id];
        delete oppToDeleteList;

        // Verify only 4 deals present, 3 for Digital, 1 for Rental Physical. Sell through Deal not present
        Map<Id, Opportunity> mapExitingOpp = new Map<Id, Opportunity>([SELECT Id,Market_Type__c, NR_Deal_Unique_Key__c, Start_Date__c, CloseDate FROM Opportunity]);
        System.assertEquals(4, mapExitingOpp.size());
        System.debug('--mapExitingOpp--->'+mapExitingOpp);
        
        // Verify no deal product records present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

        for (Product2 prod : [SELECT Id, RecordTypeId, Street_Date__c, NR_Product_Created__c, Street_Date_Has_Changed__c FROM Product2]) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(prod.NR_Product_Created__c);
                System.assert(!prod.Street_Date_Has_Changed__c);
                System.assertEquals(System.today() + 32, prod.Street_Date__c);
            }
        }

        List<Account_Plan__c> lstExistingAccountPlan = [SELECT Id, Handling_Fee__c, Target_Quantity__c, Total_Target__c, Rental_Revenue_Per_Unit__c, Decay_Curve_Template__c, Country_Plan__r.Target_Revenue__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        Map<Id, Account_Plan__c> mapAccountIdToAaccountPlanId = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accountPlanInstance : lstExistingAccountPlan) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance);
            System.assertEquals(550, accountPlanInstance.Total_Target__c);
            System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
            System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
            System.assertEquals(100, accountPlanInstance.Handling_Fee__c);
            System.assertEquals(100, accountPlanInstance.Rental_Revenue_Per_Unit__c);
            System.assertEquals(null, accountPlanInstance.Decay_Curve_Template__c);
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 1');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify 1 additial opportunity record created for Sell Through
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        // Verify 2 deal product records for 2 physical products should be created through batch
        // 1 for existing rental Deal
        // 1 for newly created sell through deal
        System.assertEquals(2, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Account_Plan__c, Promoted_Price__c, SAP_Promoted_Price__c, Opportunity.AccountId, Opportunity.Start_Date__c, Opportunity.CloseDate, 
                    Opportunity.Promo_Start_Date__c, Opportunity.Promo_End_Date__c, Id,Product2.RecordTypeId,Opportunity.Name,Product2.Type__c,
                    Opportunity.Market_Type__c,Opportunity.Account.Name,Product2.Street_Date__c,Product2.Product_Market__c,Opportunity.Product_Type__c,
                    Opportunity.Account.Sales_Organization__c, Account_Price__c, Initial_Quantity__c, 
                    Target_Quantity__c,Quantity FROM OpportunityLineItem
        ]) {
            System.assertEquals(20, dealProduct.Account_Price__c);
            //System.assertEquals(55, dealProduct.Initial_Quantity__c, 'Target Quantity should be Account Plan. Target Qty');
            //System.assertEquals(55, dealProduct.Quantity, 'Quantity should be same as Initial Quantity');
            System.assertEquals(1, dealProduct.Quantity, 'Quantity should be default to 1');
            System.assertEquals(0, dealProduct.Initial_Quantity__c, 'Target Quantity should be 0 by default');
            System.assertEquals(dealProduct.Opportunity.Market_Type__c,dealProduct.Product2.Product_Market__c, 'Both Deal.Market_Type and Product.Product_Market Must be equal');
            System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
            if (dealProduct.Product2.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId).Handling_Fee__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(6, dealProduct.Target_Quantity__c, '550 / 100 - Target Quantity should be Account Plan.Total Target / Account Plan.Rental Revenue Per Unit');
                System.assertEquals(rentalOpp.Id, dealProduct.OpportunityId);
                // Verify the rental deal was present earlier
                System.assert(mapExitingOpp.containsKey(dealProduct.OpportunityId));
            } else {
                System.assertEquals(20, dealProduct.Promoted_Price__c);
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(28, dealProduct.Target_Quantity__c, '550 / 20 - Target Quantity should be Account Plan.Total Target / Deal Product.Account Price');               

                // Verify the deal was not present earlier which means it is newly created
                System.assert(!mapExitingOpp.containsKey(dealProduct.OpportunityId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId).Id, dealProduct.Account_Plan__c);
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(dealProduct.Product2.Street_Date__c);
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
                    String dealName = CRM_AppConstants.NR_Deal_Japan_Naming_INITIAL + CRM_AppConstants.NR_Deal_Japan_Market_Type_SELL_THROUGH + CRM_AppConstants.NR_Deal_Japan_Product_Type_VIDEO_PHYSICAL + startDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year +' '+ startMonth + ' ' + startDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day +' '+ CRM_AppConstants.NR_Deal_Japan_Month_Connector + endDate.year() + CRM_AppConstants.NR_Deal_Japan_Naming_Year  +' '+ endMonth +' '+ endDate.day() + CRM_AppConstants.NR_Deal_Japan_Naming_Day + ' ' + dealProduct.Opportunity.Account.Name;
                    System.assertEquals(dealName, dealProduct.Opportunity.Name);
                    System.assertEquals(startDate, dealProduct.Opportunity.Start_Date__c);
                    System.assertEquals(endDate, dealProduct.Opportunity.CloseDate);
                    System.assertEquals(startDate, dealProduct.Opportunity.Promo_Start_Date__c);
                    System.assertEquals(endDate, dealProduct.Opportunity.Promo_End_Date__c);
                }
            }
            System.assertEquals(CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE, dealProduct.Product2.Type__c);
            System.assertEquals(CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE, dealProduct.Opportunity.Product_Type__c);
        }

        // Verify one Schedule created for Rental Deal Product as Initial Quantity is entered and no Account Plan Decay Curve Template present
        // Verify one Schedule created for Sell Deal Product similar to UK as Initial Quantity 
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, OpportunityLineItem.Product2.Product_Market__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, OpportunityLineItem.OpportunityId,OpportunityLineItem.Product2.Street_Date__c, ScheduleDate, Description, OpportunityLineItem.Opportunity.Account.Sales_Organization__c, Quantity, Revenue FROM OpportunityLineItemSchedule ORDER BY Description DESC];
        System.assertEquals(2, lineItemSchedules.size());
        for (Integer i = 0; i < lineItemSchedules.size(); i++) {
            OpportunityLineItemSchedule schedule = lineItemSchedules[i];
            if (schedule.OpportunityLineItem.Product2.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                System.assertEquals(rentalOpp.Id, schedule.OpportunityLineItem.OpportunityId);
                System.assertEquals(System.today() + 32, schedule.OpportunityLineItem.Product2.Street_Date__c);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                System.assertEquals(1, schedule.Quantity, 'As Initial Qty = 1');
                System.assertEquals(0, schedule.Revenue, 'As Initial Qty = 0');
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedule.Description);
            } else {
                /*if (i == 0) {
                    System.assertEquals(schedule.OpportunityLineItem.NR_Revenue_Recognition_Date__c, schedule.ScheduleDate);
                    System.assertEquals(0, schedule.Quantity);
                    System.assertEquals(20, schedule.Revenue, 'As Initial Qty * Promoted Price');
                    System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedule.Description);
                } else {
                    System.assertEquals(System.today() + 32, schedule.OpportunityLineItem.Product2.Street_Date__c);
                    System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                    System.assertEquals(1, schedule.Quantity, 'As Initial Qty = 1');
                    System.assertEquals(0, schedule.Revenue);
                    System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedule.Description);
                }*/
                System.assertEquals(System.today() + 32, schedule.OpportunityLineItem.Product2.Street_Date__c);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
                System.assertEquals(1, schedule.Quantity, 'As Initial Qty = 1');
                System.assertEquals(0, schedule.Revenue, 'As Initial Qty = 0');
                System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, schedule.Description);
            }
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
    
   /* public static testMethod void Scenario2_JAPAN_With_Deal_Product_To_Be_Cloned_Present_In_Committed_Deal_Along_New_Deal_And_DP_Created_With_Override_Pricing_Test(){

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
            createData();

        // Make the Sales Org as JAPAN for Accounts
        Account gamesPhysicalAccount;
        for (Account acc : tw.lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
            if (acc.Games_Physical__c) {
                if (CRM_AppConstants.SALES_ORGS_TO_PROCESS_SHIP_TO.contains(acc.Sales_Organization__c)) {
                    acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
                }
                gamesPhysicalAccount = acc;
            }
        }
        update tw.lstAccounts;
        System.assertNotEquals(null, gamesPhysicalAccount);

        String dealPeriod = '';
        for(integer i=0 ; i < tw.lstOpportunity.size() ; i++){
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                tw.lstOpportunity[i].Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                Map<String, Date> mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForJapanDeal(tw.lstProduct[i].Street_Date__c);
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
                tw.lstOpportunity[i].NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            }
        }
        update tw.lstOpportunity;

        Product2 gamesPhysicalProduct;
        for(Product2 p : tw.lstProduct){
            p.NR_Product_Created__c = false;
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                p.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
                p.Product_Market__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;
                //p.Street_Date__c = system.today()+140;
                if (p.Type__c == 'Games Physical') {
                    gamesPhysicalProduct = p;
                }
            }
        }
        update tw.lstProduct;
        System.assertNotEquals(null, gamesPhysicalProduct);
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstDealsForChangedStreetDate = CRM_TestDataFactory.createOpportunitiesWithAccounts(new List<Account>{gamesPhysicalAccount},1,false);
        System.assertEquals(1, lstDealsForChangedStreetDate.size());
        Integer countDeal = 0;
        for (Integer i=0; i < lstDealsForChangedStreetDate.size(); i++) {
            Opportunity d0_existingDeal = lstDealsForChangedStreetDate[i];
            d0_existingDeal.AccountId = gamesPhysicalAccount.Id;
            d0_existingDeal.Name = 'Deal' + countDeal++;
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            d0_existingDeal.CurrencyIsoCode = 'USD';
            d0_existingDeal.Start_Date__c = system.today() + 140;
            d0_existingDeal.CloseDate = system.today() + 160;
            d0_existingDeal.Promo_Start_Date__c = system.today() + 140;
            d0_existingDeal.Promo_End_Date__c = system.today() + 160;
            if (gamesPhysicalAccount.Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
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

            d0_existingDeal.NR_Deal_Unique_Key__c = gamesPhysicalAccount.Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(gamesPhysicalProduct.Type__c);
            d0_existingDeal.Market_Type__c = CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE;

            d0_existingDeal.Product_Type__c = gamesPhysicalProduct.Type__c;
            if(d0_existingDeal.Product_Type__c!= null){
                if(d0_existingDeal.Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || d0_existingDeal.Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                }else{
                    d0_existingDeal.RecordtypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                }
            }
            if (tw.lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
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
                d0_existingDeal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + dealPeriod+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);
            }
        }
        insert lstDealsForChangedStreetDate;
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);

        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate;
        
        lstDecayCurveTemplate = [SELECT Id, MaxDecayCurveItemDay__c FROM Decay_Curve_Template__c];
        System.assertEquals(1, lstDecayCurveTemplate.size());

        Test.startTest();
        List<Country_Plan__c> lstCountryPlan = [SELECT Id, Target_Quantity__c, Target_Revenue__c, Stretch_Target__c FROM Country_Plan__c ORDER BY CreatedDate];
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = null;
            cp.Target_Revenue__c = 5000;
            cp.Stretch_Target__c = 10;
            cp.Country__c = 'Japan';
        }
        update lstCountryPlan;

        List<Account_Plan__c> lstAccountPlan = [SELECT Id, Country_Plan__r.NR_Product__r.Product_Market__c, Final_Purchase_Price__c, Final_Purchase__c, Customer__c, Decay_Curve_Template__c, Handling_Fee__c, Rental_Price__c, Revenue_Share__c, Number_of_Rentals_per_Unit__c  FROM Account_Plan__c];
        Map<Id, Account_plan__c> mapAccountIdToAP = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accPlan : lstAccountPlan) {
            if (accPlan.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                accPlan.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_PLAN_RENTAL;
                accPlan.Handling_Fee__c = 100;
                accPlan.Decay_Curve_Template__c = lstDecayCurveTemplate[0].Id;
                accPlan.Rental_Price__c = 70;
                accPlan.Revenue_Share__c = 25.5;
                accPlan.Number_of_Rentals_per_Unit__c = 20;
                accPlan.Final_Purchase_Price__c = 20;
                accPlan.Final_Purchase__c = 30;
            }
            accPlan.Target_Revenue_Has_Changed__c = false;
            mapAccountIdToAP.put(accPlan.Customer__c, accPlan);
        }
        update lstAccountPlan;
        for (Account_Plan__c accPlan : lstAccountPlan) {
            accPlan.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;
        System.debug('-lstAccountPlan---->'+lstAccountPlan);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            lstDealProduct[i].Handling_Fee__c = 200;
            lstDealProduct[i].Rental_Price__c = 70;
            lstDealProduct[i].Revenue_Share__c = 25.5;
            lstDealProduct[i].Number_of_Rentals_per_Unit__c = 20;
            lstDealProduct[i].Final_Purchase_Price__c = 20;
            lstDealProduct[i].Final_Purchase__c = 30;
            lstDealProduct[i].Account_plan__c = mapAccountIdToAP.get(tw.lstOpportunity[i].AccountId).Id;
            lstDealProduct[i].Override_Pricing__c = true;
            lstDealProduct[i].Decay_Curve_Template__c = lstDecayCurveTemplate[0].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Verify Schedules created with Initial Quantity 1
        List<OpportunityLineItem> lineItemsBeforeBatchRun = [SELECT Id, Product2.Street_Date__c, Product2.RecordTypeId, (SELECT Id, Type, ScheduleDate, Description, Quantity, Revenue FROM OpportunityLineItemSchedules ORDER BY ScheduleDate) FROM OpportunityLineItem];
        System.assertEquals(5, lineItemsBeforeBatchRun.size());
        for (OpportunityLineItem dealProduct : lineItemsBeforeBatchRun) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
                System.assertEquals(5, schedules.size());
                System.assertEquals(system.today() + 32, dealProduct.Product2.Street_Date__c);
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(((Integer) lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(0, schedules[2].Quantity);
                System.assertEquals(0, schedules[3].Quantity);
                System.assertEquals(0, schedules[4].Quantity);
                System.assertEquals(200, schedules[0].Revenue);
                System.assertEquals(117.81, schedules[1].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(117.81, schedules[2].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(121.38, schedules[3].Revenue,'1 * 70 * (25.5 / 100) * 20 * (34 / 100)');
                System.assertEquals(6, schedules[4].Revenue, '1 * 20 * (30 / 100)');
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);
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

        // Change the Street Date to future
        for(Product2 p : tw.lstProduct){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                p.Street_Date__c = system.today()+140;
            }
        }
        update tw.lstProduct;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(system.today()+140, p.Street_Date__c);
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify 6 valid opportunity records present -> 5 existing deals and 1 new Deal which will be valid for Games Physical Product after Date change
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(6, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify 5 deal product records present
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        Map<Id, OpportunityLineItem> mapIdToDPExisting = new Map<Id, OpportunityLineItem>(dealProductsBeforeBatchRun);
        System.assertEquals(5, dealProductsBeforeBatchRun.size());

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        System.debug('lstPBEP::'+lstPBEP);

        Map<Id, Id> mapAccountIdToAaccountPlanId = new Map<Id, Id>();
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Share__c, Country_Plan__r.Total_Stretched_Target__c, Country_Plan__r.Stretch_Target__c, Total_Target__c, RecordTypeId, Country_Plan__r.NR_Product__r.Product_Market__c, Handling_Fee__c, Rental_Revenue_Per_Unit__c, Decay_Curve_Template__c, Country_Plan__r.Target_Revenue__c, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            mapAccountIdToAaccountPlanId.put(accountPlanInstance.Customer__c, accountPlanInstance.Id);
            System.assertEquals(0, accountPlanInstance.Target_Quantity__c);
            System.assertEquals(5000, accountPlanInstance.Country_Plan__r.Target_Revenue__c);
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.Product_Market__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE) {
                System.assertEquals(100, accountPlanInstance.Handling_Fee__c);
                System.assertEquals(463, accountPlanInstance.Rental_Revenue_Per_Unit__c);
                System.assertEquals(lstDecayCurveTemplate[0].id, accountPlanInstance.Decay_Curve_Template__c);
            }
            System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2');
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            // Commented Germany Code Changes
            // System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify only 1 additional opportunity records are created for Video Physical Product after Dat change
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, StageName FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(7, dealsAfterBatchRun.size());

        // Verify Satge Name is not changed
        Opportunity newDeal;
        for (Opportunity newDealInsatnce : dealsAfterBatchRun) {
            if (mapIdToDealInstance.containsKey(newDealInsatnce.Id)) {
                System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, newDealInsatnce.StageName);
            } else {
                System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT, newDealInsatnce.StageName);
                newDeal = newDealInsatnce;
            }
        }
        System.assertNotEquals(null, newDeal);

        // Verify 5 deal product records from which 2 physical products should be Cloned and created through batch and 3 will be as it is as those are digital
        Integer countPhysical = 0;
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Product2Id, Product2.RecordTypeId, LastModifiedDate FROM OpportunityLineItem ORDER BY Product2.RecordTypeId, CreatedDate Desc];
        System.assertEquals(5, dealProductsAfterBatchRun.size());

        for (OpportunityLineItem dealProduct : [SELECT Id, Handling_Fee__c,Decay_Curve_Template__c, Override_Pricing__c, Opportunity.Market_Type__c,Account_Plan__c, Product2.Product_Market__c, Opportunity.Account.Sales_Organization__c, Initial_Quantity__c, Account_Price__c, OpportunityId, Target_Quantity__c, Quantity,Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(mapAccountIdToAaccountPlanId.containsKey(dealProduct.Opportunity.AccountId));
                System.assertEquals(mapAccountIdToAaccountPlanId.get(dealProduct.Opportunity.AccountId), dealProduct.Account_Plan__c);
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                //System.assertEquals(2, dealProduct.Target_Quantity__c, 'Quantity = 550 / 563 - AccountPlan.Total Target / AccountPlan.Rental Revenue Per Unit');
                System.assertEquals(1, dealProduct.Initial_Quantity__c, 'Initial Quantity should be same as Quantity');
                System.assertEquals(CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE, dealProduct.Product2.Product_Market__c);
                System.assertEquals(dealProduct.Opportunity.Market_Type__c, dealProduct.Product2.Product_Market__c);
                System.assertEquals(200, dealProduct.Handling_Fee__c);
                System.assertEquals(true, dealProduct.Override_Pricing__c);
                System.assertEquals(lstDecayCurveTemplate[0].Id, dealProduct.Decay_Curve_Template__c);
                System.assert(!mapIdToDPExisting.containsKey(dealProduct.Id));

                if (dealProduct.OpportunityId != newDeal.Id) {
                    // Verify these deal products are linked with existing deals based on changed Street Date
                    System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                    countPhysical ++;
                } else {
                    System.assert(!mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
                    countPhysical ++;
                }
            } else {
                System.assert(mapIdToDealInstance.containsKey(dealProduct.OpportunityId));
            }
        }
        System.assertEquals(2, countPhysical);

        // Verify Schedules created with Initial Quantity 1
        List<OpportunityLineItem> lineItemsAfterBatchRun = [SELECT Id, Product2.Street_Date__c, Product2.RecordTypeId, (SELECT Id, Type, ScheduleDate, Description, Quantity, Revenue FROM OpportunityLineItemSchedules ORDER BY ScheduleDate) FROM OpportunityLineItem];
        System.assertEquals(5, lineItemsAfterBatchRun.size());
        Integer existingPhysicalProdScheduleCount = 0;
        for (OpportunityLineItem dealProduct : lineItemsAfterBatchRun) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
                System.assertEquals(5, schedules.size());
                System.assertEquals(system.today()+140, dealProduct.Product2.Street_Date__c);
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[0].Day_Number__c), schedules[1].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[1].Day_Number__c), schedules[2].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays((Integer) lstDecayCurveItem[2].Day_Number__c), schedules[3].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(((Integer) lstDecayCurveTemplate[0].MaxDecayCurveItemDay__c) + 1), schedules[4].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[2].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[3].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[4].Type);
                System.assertEquals(1, schedules[0].Quantity);
                System.assertEquals(0, schedules[1].Quantity);
                System.assertEquals(0, schedules[2].Quantity);
                System.assertEquals(0, schedules[3].Quantity);
                System.assertEquals(0, schedules[4].Quantity);
                // System.assertEquals(100, schedules[0].Revenue);
                System.assertEquals(117.81, schedules[1].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(117.81, schedules[2].Revenue,'1 * 70 * (25.5 / 100) * 20 * (33 / 100)');
                System.assertEquals(121.38, schedules[3].Revenue,'1 * 70 * (25.5 / 100) * 20 * (34 / 100)');
                System.assertEquals(6, schedules[4].Revenue, '1 * 20 * (30 / 100)');
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL_HANDLING_FEE, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[0].Percent_Allocation__c) + ' %', schedules[1].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[1].Percent_Allocation__c) + ' %', schedules[2].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_DECAY_CURVE_TEMPLATE_JAPAN + String.valueOf(lstDecayCurveItem[2].Percent_Allocation__c) + ' %', schedules[3].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_FINAL_PURCHASE_PRICE, schedules[4].Description);
                existingPhysicalProdScheduleCount++;
            }
        }
        // 5 each for 2 Physical Products
        System.assertEquals(2, existingPhysicalProdScheduleCount);

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

    public static testMethod void Scenario3_With_No_Existing_Deal_And_Deal_Product_Present_For_Italy_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
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
        p0_GamesPhysical.Street_Date__c = System.today() + 132;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = true;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;
        
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        
        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;
        

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
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+160;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesPhysical.Target__c = 50;
        t0_GamesPhysical.Target_Units__c = 5;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

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
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify deal and deal products are created for Scenario 3 in case of France
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Quantity, Target_Quantity__c,Initial_Quantity__c, (SELECT Id, Quantity, Revenue,OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            System.assertEquals(90, dealProduct.Quantity);
            System.assertEquals(90, dealProduct.Target_Quantity__c);
            System.assertEquals(90, dealProduct.Initial_Quantity__c);
            /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
            System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
            System.assertEquals(1800, dealProduct.OpportunityLineItemSchedules[0].Revenue);
            System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
            System.assertEquals(90, dealProduct.OpportunityLineItemSchedules[1].Quantity);
            System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
            System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
            */
            System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
            for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(90, schedule.Quantity);
                System.assertEquals(1800, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario3_With_No_Existing_Deal_And_Deal_Product_Present_For_Spain_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SPAIN_CODE;
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
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SPAIN_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = true;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;
        
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        
        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;
        

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodCreated
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c existingDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        existingDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        existingDealPriceBookPeriod.Start_Date__c = System.today()-70;
        existingDealPriceBookPeriod.End_Date__c = System.today()-70;
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

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesPhysical.Target__c = 50;
        t0_GamesPhysical.Target_Units__c = 5;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

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
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify deal and deal products are created for Scenario 3 in case of France
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, Name FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assert(dealsAfterBatchRun[0].Name.contains(' Q'));
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Quantity, Promoted_Price__c, Opportunity.Account.Sales_Organization__c, Target_Quantity__c,Initial_Quantity__c, (SELECT Id, Quantity, Revenue,OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            System.assertEquals(20, dealProduct.Promoted_Price__c);
            System.assertEquals(3, dealProduct.Quantity);
            System.assertEquals(3, dealProduct.Target_Quantity__c, 'Account Plan Published Target / Deal Product Account Price');
            System.assertEquals(3, dealProduct.Initial_Quantity__c);

            /*System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
            System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[0].Quantity);
            System.assertEquals(1800, dealProduct.OpportunityLineItemSchedules[0].Revenue);
            System.assertEquals(dealProduct.OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
            System.assertEquals(90, dealProduct.OpportunityLineItemSchedules[1].Quantity);
            System.assertEquals(0, dealProduct.OpportunityLineItemSchedules[1].Revenue);
            System.assertEquals(dealProduct.OpportunityLineItemSchedules[1].OpportunityLineItem.Product2.Street_Date__c, dealProduct.OpportunityLineItemSchedules[1].ScheduleDate);
            */
            System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
            for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(3, schedule.Quantity);
                System.assertEquals(60, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
    
    public static testMethod void Scenario1_Without_Existing_Deal_And_Target_US_GAMES_Test(){
        // Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();

        // Delete existing deals so that no existing NR deals present in database
        List<Opportunity> lstExistingDeals = [SELECT Id FROM Opportunity];
        delete lstExistingDeals;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_CANADA_CODE;
            } else if (acc.Games_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
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

        // Verify 0 deals created for 2 physical products as no targets present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify 0 deal product records for 2 physical products should be created through batch as no targets present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());
        
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
    }

    public static testMethod void Scenario2_With_No_Existing_Deal_And_No_Deal_Product_To_Be_Cloned_Present_For_US_GAMES_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            createData();
        Set<String> setAccountIdAndProductId = new Set<String>();
        
        for(Product2 p : tw.lstProduct){
            p.NR_Product_Created__c = false;
            p.Street_Date__c = system.today()+140;
        }
        update tw.lstProduct;

        // Verify Street Date is changed
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        delete tw.lstOpportunity;

        // After deleting opportunities again make the Sales Org as Germany
        for (Account acc : tw.lstAccounts) {
            if (acc.Video_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
            } else if (acc.Games_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_MEXICO_CODE;
            }
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

        delete [SELECT Id FROM Target__c];
        delete [SELECT Id, Target_Quantity__c, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, PublishedTarget__c,    Target_Revenue_Has_Changed__c FROM Account_Plan__c];
        
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

        // Verify no opportunity records created for 2 physical products as no targets present
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());

        // Verify no deal product records for 2 physical products as no targets present
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem].size());

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
    
    public static testMethod void Scenario3_With_No_Existing_Deal_And_Deal_Product_Present_US_GAMES_Test(){

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_MEXICO_CODE;
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
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_MEXICO_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = true;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Target_Quantity__c = 500;
        }
        insert lstCountryPlan;
        
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        
        // Setting up the Scenario 3 data
        for (Country_Plan__c cp : lstCountryPlan) {
            cp.Stretch_Target__c = 80;
        }
        update lstCountryPlan;
        

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

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        t0_GamesPhysical.Target__c = 50;
        t0_GamesPhysical.Target_Units__c = 5;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

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
            //System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should not be changed for France');
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

        // Verify deal and deal products are created for Scenario 3 in case of France
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Quantity, Target_Quantity__c,Initial_Quantity__c, (SELECT Id, Quantity, Revenue,OpportunityLineItemId, OpportunityLineItem.Product2.Street_Date__c, OpportunityLineItem.NR_Revenue_Recognition_Date__c, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        for (OpportunityLineItem dealProduct : dealProductsAfterBatchRun) {
            System.assertEquals(90, dealProduct.Quantity);
            System.assertEquals(90, dealProduct.Target_Quantity__c);
            System.assertEquals(90, dealProduct.Initial_Quantity__c);
            System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
            for (OpportunityLineItemSchedule schedule : dealProduct.OpportunityLineItemSchedules) {
                System.assertEquals(90, schedule.Quantity);
                System.assertEquals(1800, schedule.Revenue);
                System.assertEquals(schedule.OpportunityLineItem.Product2.Street_Date__c, schedule.ScheduleDate);
            }
        }

        // Verify Account Plan flags are reset properly after batch processing
        for (Account_Plan__c accountPlanInstance : [SELECT Id, Country_Plan__r.NR_Product__r.RecordTypeId, Target_Revenue_Has_Changed__c FROM Account_Plan__c]) {
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!accountPlanInstance.Target_Revenue_Has_Changed__c);
            } else {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
}