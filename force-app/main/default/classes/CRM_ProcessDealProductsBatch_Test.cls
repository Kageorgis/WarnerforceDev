/**
 * @Author Aditi Satpute
 * @name CRM_ProcessDealProductsBatch_Test
 * @CreateDate 27th July 2016
 * @Description Test class for CRM_ProcessDealProductsBatch
 * @Version <1.0>
 */

@isTest
public with sharing class CRM_ProcessDealProductsBatch_Test {

    @testsetup  
    public static void createTestDataForBatchNotificationStatus(){ 
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
        insert userList;
        System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c ].size());
    }

    public static void createData() {
		insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
		
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(5);
        System.debug('lstAccounts::'+lstAccounts.size());

        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);

        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
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

        for(Integer i=0; i<lstProduct.size(); i++){
            lstProduct[i].Street_Date__c = system.today()+20;
            lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstProduct[i].CurrencyIsoCode = 'USD';
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            }else if (i == 2) {
                lstProduct[i].Type__c = 'Video Physical';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Digital EST';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Video Digital VODi';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            } else {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            }
        }
        insert lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        System.debug('lstProduct::'+lstProduct.size());

        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry);

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);

        // Create Deal with Promo_Start_Date__c = System.today() + 1
        List<Opportunity> lstOpportunity =
            CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);
        for (Integer i = 0; i < lstOpportunity.size(); i++) {
            if (lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                lstOpportunity[i].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
            } else if (lstProduct[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                lstOpportunity[i].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            }
        }
        insert lstOpportunity;
        System.debug('lstOpportunity::'+lstOpportunity);
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityWithTemplateOnNRProductStreetDateUpdateTest_UK(){
    	insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
    	
        //Method to create Dummy Data
        CRM_AutoEstablishSchedulesHelper_Test.TestDataWrapper tw = CRM_AutoEstablishSchedulesHelper_Test.createData();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Product2> lstProduct = tw.lstProduct;
        Map<Id, Pricebook_Entry_Period__c> mapProdIdToPBEP = new Map<Id, Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> lstPBEPToUpdate =
            [
                SELECT Start_Date__c, Product__c
                FROM Pricebook_Entry_Period__c
                WHERE Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
            ];
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            mapProdIdToPBEP.put(pbep.Product__c, pbep);
        }

        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Discount = 90;
            if (tw.lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 25;
                lstDealProduct[i].Replen_Quantity__c = 40;
            } else {
                lstDealProduct[i].Replen_Quantity__c = 40;
            }
        }
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }
        insert lstDealProduct;

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterInsert = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId , Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterInsert.size());

        // Verify schedules are present and data is populated properly based on Product Street Date
        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, existingLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterInsert) {
            System.assertEquals(System.today() + 1, dealProduct.Product2.Street_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 1, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }

        // Update the Release Date to recalculate the schedules
        // For Physical Products update Product Street Date
        for (Product2 p : lstProduct){
            p.Street_Date__c = System.today() + 20;
        }
        update lstProduct;

        // For Digital Products update PBEP's Start Date
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            pbep.Start_Date__c = System.today() + 20;
        }
        update lstPBEPToUpdate;
        System.debug('-lstPBEPToUpdate->'+lstPBEPToUpdate);

        List<Product2> lstUpdatedProductBeforeBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductBeforeBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(true, prod.RecalculateSchedules__c, 'Verify Street Date is changed so flag is set true');
            }
        }

        Test.startTest();
        CRM_ProcessDealProductsBatch recalculateScheduleBatch = new CRM_ProcessDealProductsBatch();
        Database.executeBatch(recalculateScheduleBatch,10);
        Test.stopTest();

        List<Product2> lstUpdatedProductAfterBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductAfterBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(false, prod.RecalculateSchedules__c, 'Verify Street Date changed flag is reset');
            }
        }

        // Fetch Deal Products to verify Schedules are recalculated properly
        List<OpportunityLineItem> dealProductsAfterUpdate = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterUpdate.size());

        // Verify schedules are present and data is populated properly based on updated Product Street Date
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, newLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterUpdate) {
            System.assertEquals(System.today() + 20, dealProduct.Product2.Street_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 20, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithCommittedDealOnNRProductStreetDateUpdateTest_UK(){
		insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));

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
        CRM_AutoEstablishSchedulesHelper_Test.TestDataWrapper tw = CRM_AutoEstablishSchedulesHelper_Test.createData();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Product2> lstProduct = tw.lstProduct;
        Map<Id, Pricebook_Entry_Period__c> mapProdIdToPBEP = new Map<Id, Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> lstPBEPToUpdate =
            [
                SELECT Start_Date__c, Product__c
                FROM Pricebook_Entry_Period__c
                WHERE Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
            ];
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            mapProdIdToPBEP.put(pbep.Product__c, pbep);
        }

        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Discount = 90;
            if (tw.lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 25;
                lstDealProduct[i].Replen_Quantity__c = 40;
            } else {
                lstDealProduct[i].Replen_Quantity__c = 40;
            }
        }
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
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

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterInsert = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,Product2.RecordTypeId,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId , Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,Opportunity.Promo_Start_Date__c,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterInsert.size());

        // Verify schedules are present and data is populated properly based on Product Street Date
        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, existingLineItemSchedules.size());
        Map<Id, OpportunityLineItemSchedule> mapSchedules =
            new Map<Id, OpportunityLineItemSchedule>(existingLineItemSchedules);

        for (OpportunityLineItem dealProduct : dealProductsAfterInsert) {
            System.assertEquals(System.today() + 1, dealProduct.Product2.Street_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                for (OpportunityLineItemSchedule schedule : schedules) {
                    System.assert(mapSchedules.containsKey(schedule.Id));
                }
            }
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 1, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }

        // Update the Release Date to recalculate the schedules
        // For Physical Products update Product Street Date
        for (Product2 p : lstProduct){
            p.Street_Date__c = System.today() + 20;
        }
        update lstProduct;
        System.debug('-lstProduct->'+lstProduct);

        // For Digital Products update PBEP's Start Date
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            pbep.Start_Date__c = System.today() + 20;
        }
        update lstPBEPToUpdate;
        System.debug('-lstPBEPToUpdate->'+lstPBEPToUpdate);

        List<Product2> lstUpdatedProductBeforeBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductBeforeBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(true, prod.RecalculateSchedules__c, 'Verify Street Date is changed so flag is set as true');
            }
        }

        Test.startTest();
        CRM_ProcessDealProductsBatch recalculateScheduleBatch = new CRM_ProcessDealProductsBatch();
        Database.executeBatch(recalculateScheduleBatch,10);
        Test.stopTest();

        List<Product2> lstUpdatedProductAfterBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductAfterBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(false, prod.RecalculateSchedules__c, 'Verify Street Date changed flag is false even if not deal product was processed as deal is committed');
            }
        }

        // Fetch Deal Products to verify Schedules are not recalculated
        List<OpportunityLineItem> dealProductsAfterUpdate = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,Product2.RecordTypeId,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,Opportunity.Promo_Start_Date__c,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterUpdate.size());

        // Verify schedules are present as it is and there is no change
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, newLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterUpdate) {
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                for (OpportunityLineItemSchedule schedule : schedules) {
                    System.assert(!mapSchedules.containsKey(schedule.Id));
                }
            }
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(System.today() + 20, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(System.today() + 20, schedules[0].ScheduleDate);
                System.assertEquals((System.today() + 20).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityWithTemplateOnNonNRProductStreetDateUpdateTest_UK(){
        insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
        
        //Method to create Dummy Data
        CRM_AutoEstablishSchedulesHelper_Test.TestDataWrapper tw = CRM_AutoEstablishSchedulesHelper_Test.createData();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Product2> lstProduct = tw.lstProduct;
        Map<Id, Pricebook_Entry_Period__c> mapProdIdToPBEP = new Map<Id, Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> lstPBEPToUpdate =
            [
                SELECT Start_Date__c, Product__c
                FROM Pricebook_Entry_Period__c
                WHERE Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
            ];
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            mapProdIdToPBEP.put(pbep.Product__c, pbep);
        }

        // Make the Product Non NR i.e Catalog
        for (Product2 p : lstProduct){
            p.Release_Category__c = null;
        }
        update lstProduct;

        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Discount = 90;
            if (tw.lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 25;
                lstDealProduct[i].Replen_Quantity__c = 40;
            } else {
                lstDealProduct[i].Replen_Quantity__c = 40;
            }
        }
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }
        insert lstDealProduct;

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterInsert = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,Product2.RecordTypeId,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId , Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,Opportunity.Promo_Start_Date__c,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterInsert.size());

        // Verify schedules are present and data is populated properly based on Product Street Date
        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, existingLineItemSchedules.size());
        Map<Id, OpportunityLineItemSchedule> mapSchedules =
            new Map<Id, OpportunityLineItemSchedule>(existingLineItemSchedules);

        for (OpportunityLineItem dealProduct : dealProductsAfterInsert) {
            System.assertEquals(System.today() + 1, dealProduct.Opportunity.Promo_Start_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                for (OpportunityLineItemSchedule schedule : schedules) {
                    System.assert(mapSchedules.containsKey(schedule.Id));
                }
            }
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 1, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Opportunity.Promo_Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Opportunity.Promo_Start_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }

        // Update the Release Date to recalculate the schedules
        // For Physical Products update Product Street Date
        for (Product2 p : lstProduct){
            p.Street_Date__c = System.today() - 120;
        }
        update lstProduct;
        System.debug('-lstProduct->'+lstProduct);

        // For Digital Products update PBEP's Start Date
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            pbep.Start_Date__c = System.today() - 120;
        }
        update lstPBEPToUpdate;
        System.debug('-lstPBEPToUpdate->'+lstPBEPToUpdate);

        List<Product2> lstUpdatedProductBeforeBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductBeforeBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(false, prod.RecalculateSchedules__c, 'Verify Street Date is changed so flag is false as Product is Catalog');
            }
        }

        Test.startTest();
        CRM_ProcessDealProductsBatch recalculateScheduleBatch = new CRM_ProcessDealProductsBatch();
        Database.executeBatch(recalculateScheduleBatch,10);
        Test.stopTest();

        List<Product2> lstUpdatedProductAfterBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductAfterBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(false, prod.RecalculateSchedules__c, 'Verify Street Date changed flag is false only');
            }
        }

        // Fetch Deal Products to verify Schedules are not recalculated
        List<OpportunityLineItem> dealProductsAfterUpdate = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,Product2.RecordTypeId,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,Opportunity.Promo_Start_Date__c,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterUpdate.size());

        // Verify schedules are present as it is and there is no change
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, newLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterUpdate) {
            System.assertEquals(System.today() + 1, dealProduct.Opportunity.Promo_Start_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                for (OpportunityLineItemSchedule schedule : schedules) {
                    System.assert(mapSchedules.containsKey(schedule.Id));
                }
            }
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() - 120, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Opportunity.Promo_Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Opportunity.Promo_Start_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithCommittedDealOnNRProductStreetDateUpdateTest_FR(){
		insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
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
        CRM_AutoEstablishSchedulesHelper_Test.TestDataWrapper tw = CRM_AutoEstablishSchedulesHelper_Test.createData();

        for (Account acc : tw.lstAccounts) {
            if (acc.Games_Physical__c || acc.Video_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (acc.Games_Digital__c || acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
            }
        }
        update tw.lstAccounts;

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Product2> lstProduct = tw.lstProduct;
        Map<Id, Pricebook_Entry_Period__c> mapProdIdToPBEP = new Map<Id, Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> lstPBEPToUpdate =
            [
                SELECT Start_Date__c, Product__c
                FROM Pricebook_Entry_Period__c
                WHERE Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
            ];
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            mapProdIdToPBEP.put(pbep.Product__c, pbep);
        }

        // Make the Product FR
        for (Product2 prod : lstProduct) {
            if (prod.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            }
        }
        update lstProduct;

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Discount = 90;
            if (tw.lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 25;
                lstDealProduct[i].Replen_Quantity__c = 40;
            } else {
                lstDealProduct[i].Replen_Quantity__c = 40;
            }
        }
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
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

        // Verify 5 valid opportunity records present
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, StageName, (SELECT Id, LastModifiedDate FROM OpportunityLineItems ORDER BY CreatedDate Desc) FROM Opportunity ORDER BY CreatedDate];
        System.assertEquals(5, dealsBeforeBatchRun.size());

        // Verify Satge Name has been updated
        for (Opportunity dealInsatnce : dealsBeforeBatchRun) {
            System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, dealInsatnce.StageName);
        }

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterInsert = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,Product2.RecordTypeId,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId , Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,Opportunity.Promo_Start_Date__c,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterInsert.size());

        // Verify schedules are present and data is populated properly based on Product Street Date
        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, existingLineItemSchedules.size());
        Map<Id, OpportunityLineItemSchedule> mapSchedules =
            new Map<Id, OpportunityLineItemSchedule>(existingLineItemSchedules);

        for (OpportunityLineItem dealProduct : dealProductsAfterInsert) {
            System.assertEquals(System.today() + 1, dealProduct.Product2.Street_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                for (OpportunityLineItemSchedule schedule : schedules) {
                    System.assert(mapSchedules.containsKey(schedule.Id));
                }
            }
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 1, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }

        // Update the Release Date to recalculate the schedules
        // For Physical Products update Product Street Date
        for (Product2 p : lstProduct){
            p.Street_Date__c = System.today() + 20;
        }
        update lstProduct;
        System.debug('-lstProduct->'+lstProduct);

        // For Digital Products update PBEP's Start Date
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            pbep.Start_Date__c = System.today() + 20;
        }
        update lstPBEPToUpdate;
        System.debug('-lstPBEPToUpdate->'+lstPBEPToUpdate);

        List<Product2> lstUpdatedProductBeforeBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductBeforeBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(true, prod.RecalculateSchedules__c, 'Verify Street Date is changed so flag is set as true');
            }
        }

        Test.startTest();
        CRM_ProcessDealProductsBatch recalculateScheduleBatch = new CRM_ProcessDealProductsBatch();
        Database.executeBatch(recalculateScheduleBatch,10);
        Test.stopTest();

        List<Product2> lstUpdatedProductAfterBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductAfterBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(false, prod.RecalculateSchedules__c, 'Verify Street Date changed flag is false even if not deal product was processed as deal is committed');
            }
        }

        // Fetch Deal Products to verify Schedules are not recalculated
        List<OpportunityLineItem> dealProductsAfterUpdate = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,Product2.RecordTypeId,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,Opportunity.Promo_Start_Date__c,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterUpdate.size());

        // Verify schedules are present as it is and there is no change
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, newLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterUpdate) {
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                for (OpportunityLineItemSchedule schedule : schedules) {
                    System.assert(!mapSchedules.containsKey(schedule.Id));
                }
            }
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(System.today() + 20, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(System.today() + 20, schedules[0].ScheduleDate);
                System.assertEquals((System.today() + 20).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    private static testMethod void schedulesWithInitialAndReplenQuantityWithTemplateOnNRProductStreetDateUpdateTest_FR(){
    	insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
    	
        //Method to create Dummy Data
        CRM_AutoEstablishSchedulesHelper_Test.TestDataWrapper tw = CRM_AutoEstablishSchedulesHelper_Test.createData();

        for (Account acc : tw.lstAccounts) {
            if (acc.Games_Physical__c || acc.Video_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (acc.Games_Digital__c || acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
            }
        }
        update tw.lstAccounts;
    
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<Product2> lstProduct = tw.lstProduct;
        Map<Id, Pricebook_Entry_Period__c> mapProdIdToPBEP = new Map<Id, Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> lstPBEPToUpdate =
            [
                SELECT Start_Date__c, Product__c
                FROM Pricebook_Entry_Period__c
                WHERE Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
            ];
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            mapProdIdToPBEP.put(pbep.Product__c, pbep);
        }

        // Make the Product FR
        for (Product2 prod : lstProduct) {
            if (prod.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            }
        }
        update lstProduct;
    
        /*Setting up OpportunityLineItem Data*/
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Quantity = 1;
            lstDealProduct[i].Discount = 90;
            if (tw.lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 25;
                lstDealProduct[i].Replen_Quantity__c = 40;
            } else {
                lstDealProduct[i].Replen_Quantity__c = 40;
            }
        }
        // Verify the Quantity is 1 before creation of schedules
        for (OpportunityLineItem existingDealProducts : lstDealProduct) {
            System.assertEquals(1, existingDealProducts.Quantity);
        }
        insert lstDealProduct;

        // Verify Deal Products are created properly
        List<OpportunityLineItem> dealProductsAfterInsert = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId , Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterInsert.size());

        // Verify schedules are present and data is populated properly based on Product Street Date
        List<OpportunityLineItemSchedule> existingLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, existingLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterInsert) {
            System.assertEquals(System.today() + 1, dealProduct.Product2.Street_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 1, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }

        // Update the Release Date to recalculate the schedules
        // For Physical Products update Product Street Date
        for (Product2 p : lstProduct){
            p.Street_Date__c = System.today() + 20;
        }
        update lstProduct;

        // For Digital Products update PBEP's Start Date
        for (Pricebook_Entry_Period__c pbep : lstPBEPToUpdate) {
            pbep.Start_Date__c = System.today() + 20;
        }
        update lstPBEPToUpdate;
        System.debug('-lstPBEPToUpdate->'+lstPBEPToUpdate);

        List<Product2> lstUpdatedProductBeforeBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductBeforeBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(true, prod.RecalculateSchedules__c, 'Verify Street Date is changed so flag is set true');
            }
        }

        Test.startTest();
        CRM_ProcessDealProductsBatch recalculateScheduleBatch = new CRM_ProcessDealProductsBatch();
        Database.executeBatch(recalculateScheduleBatch,10);
        Test.stopTest();

        List<Product2> lstUpdatedProductAfterBatchRun = [SELECT Id, RecalculateSchedules__c, RecordTypeId FROM Product2];
        for (Product2 prod : lstUpdatedProductAfterBatchRun) {
            if (prod.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(false, prod.RecalculateSchedules__c, 'Verify Street Date changed flag is reset');
            }
        }

        // Fetch Deal Products to verify Schedules are recalculated properly
        List<OpportunityLineItem> dealProductsAfterUpdate = [
            SELECT
                Id, Quantity, Initial_Quantity__c, Replen_Quantity__c,
                Replen_Delay_Days__c, Decay_Curve_Template__c, Opportunity.Account.Decay_Curve_Template__c,
                Opportunity.RecordTypeId, Opportunity.Start_Date__c, Product2.Product_Type__c,
                Product2.Street_Date__c, UnitPrice,
                (SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedules ORDER BY ScheduleDate, OpportunityLineItemId)
            FROM OpportunityLineItem
        ];
        System.assertEquals(5, dealProductsAfterUpdate.size());

        // Verify schedules are present and data is populated properly based on updated Product Street Date
        List<OpportunityLineItemSchedule> newLineItemSchedules = [SELECT Id,OpportunityLineItemId, ScheduleDate, Quantity, Revenue, Type,Description  FROM OpportunityLineItemSchedule ORDER BY ScheduleDate, OpportunityLineItemId];
        System.assertEquals(7, newLineItemSchedules.size());

        for (OpportunityLineItem dealProduct : dealProductsAfterUpdate) {
            System.assertEquals(System.today() + 20, dealProduct.Product2.Street_Date__c);
            List<OpportunityLineItemSchedule> schedules = dealProduct.OpportunityLineItemSchedules;
            if (dealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                System.assertEquals(System.today() + 20, mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c);
                System.assertEquals(40, dealProduct.Quantity);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(mapProdIdToPBEP.get(dealProduct.Product2Id).Start_Date__c, schedules[0].ScheduleDate);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(40, schedules[0].Quantity);
                System.assertEquals(400, schedules[0].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[0].Description);
            } else {
                System.assertEquals(65, dealProduct.Quantity);
                System.assertEquals(2, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(dealProduct.Product2.Street_Date__c, schedules[0].ScheduleDate);
                System.assertEquals((dealProduct.Product2.Street_Date__c).addDays(7), schedules[1].ScheduleDate);
                System.assertEquals(25, schedules[0].Quantity);
                System.assertEquals(40, schedules[1].Quantity);
                System.assertEquals(250, schedules[0].Revenue);
                System.assertEquals(400, schedules[1].Revenue);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[0].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_TYPE_BOTH, schedules[1].Type);
                System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, schedules[0].Description);
                System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, schedules[1].Description);
            }
        }
    }

    public static testMethod void Update_Schedule_Dates_On_Non_NR_Deal_Promo_Start_Date_Changed_Test() {
        createData();

        // Make the Product Street Date less than Promo Start Date of Deal which is System.today() + 1
        List<Product2> lstProduct = [SELECT Street_Date__c FROM Product2 ORDER BY CreatedDate ASC];
        for(Integer i=0; i<lstProduct.size(); i++){
            lstProduct[i].Street_Date__c = system.today();
        }
        update lstProduct; 

        // Make the PBEP Start Date less than Promo Start Date of Deal which is System.today() + 1
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Start_Date__c, End_Date__c FROM Pricebook_Entry_Period__c ORDER BY CreatedDate ASC];
        for(Integer i=0; i<lstPBEP.size(); i++){
            lstPBEP[i].Start_Date__c = system.today();
            lstPBEP[i].End_Date__c = system.today() + 1;
            lstPBEP[i].New_Release__c = false;
        }
        update lstPBEP;

        List<Opportunity> lstOpportunity = [SELECT Id, RecordTypeId FROM Opportunity ORDER BY CreatedDate ASC];
        List<PricebookEntry> lstPriceBookEntry = [SELECT Id FROM PricebookEntry ORDER BY CreatedDate ASC];

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
            if (lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 20;
            } else if (lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 10;
            }
        }
        insert lstDealProduct;

        List<OpportunityLineItem> lstLineItemsBeforeBatchRun = [SELECT Id, Quantity, Opportunity.Promo_Start_Date__c, Product2.RecordTypeId, (SELECT Id, Revenue, Quantity, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(5, lstLineItemsBeforeBatchRun.size());

        for (OpportunityLineItem lineItem : lstLineItemsBeforeBatchRun) {
            System.assertEquals(1, lineItem.OpportunityLineItemSchedules.size());
            System.assertEquals(System.today() + 1, lineItem.Opportunity.Promo_Start_Date__c);
            System.assertEquals(lineItem.Opportunity.Promo_Start_Date__c, lineItem.OpportunityLineItemSchedules[0].ScheduleDate);
            if (lineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, lineItem.Quantity);
                System.assertEquals(20, lineItem.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(400, lineItem.OpportunityLineItemSchedules[0].Revenue);
            } else {
                System.assertEquals(10, lineItem.Quantity);
                System.assertEquals(10, lineItem.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(200, lineItem.OpportunityLineItemSchedules[0].Revenue);
            }
        }

        Test.startTest();

        // Change Promo Start date
        List<Opportunity> lstOpportunityToUpdate = [SELECT UpdateScheduleDates__c, Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityToUpdate) {
            deal.Promo_Start_Date__c = System.today() + 30;
            deal.Start_Date__c = System.today() + 30;
            deal.Promo_End_Date__c = System.today() + 60;
            deal.CloseDate = System.today() + 60;
        }
        update lstOpportunityToUpdate;

        // Verify checkbox is checked on change of Promo Start Date
        List<Opportunity> lstOpportunityBeforeBatchRun = [SELECT UpdateScheduleDates__c, Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityBeforeBatchRun) {
            System.assert(deal.UpdateScheduleDates__c, 'Checkbox should be true');
        }

        CRM_ProcessDealProductsBatch batchInstance = new CRM_ProcessDealProductsBatch();
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify checkbox is reset after batch is run
        List<Opportunity> lstOpportunityAfterBatchRun = [SELECT UpdateScheduleDates__c, Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityAfterBatchRun) {
            System.assert(!deal.UpdateScheduleDates__c, 'Checkbox should be false');
        }

        List<OpportunityLineItem> lstLineItemsAfterBatchRun = [SELECT Id, Quantity, Opportunity.Promo_Start_Date__c, Product2.RecordTypeId, (SELECT Id, Revenue, Quantity, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(5, lstLineItemsAfterBatchRun.size());

        for (OpportunityLineItem lineItem : lstLineItemsAfterBatchRun) {
            System.assertEquals(1, lineItem.OpportunityLineItemSchedules.size());
            System.assertEquals(System.today() + 30, lineItem.Opportunity.Promo_Start_Date__c);
            System.assertEquals(lineItem.Opportunity.Promo_Start_Date__c, lineItem.OpportunityLineItemSchedules[0].ScheduleDate);
            if (lineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, lineItem.Quantity);
                System.assertEquals(20, lineItem.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(400, lineItem.OpportunityLineItemSchedules[0].Revenue);
            } else {
                System.assertEquals(10, lineItem.Quantity);
                System.assertEquals(10, lineItem.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(200, lineItem.OpportunityLineItemSchedules[0].Revenue);
            }
        }
    }

    public static testMethod void No_Update_Schedule_Dates_On_NR_Deal_Promo_Start_Date_Changed_Test(){

        createData();

        // Make the PBEP Start Date greater than Promo Start Date of Deal which is System.today() + 1
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Start_Date__c, Product__c, End_Date__c FROM Pricebook_Entry_Period__c ORDER BY CreatedDate ASC];
        for(Integer i=0; i<lstPBEP.size(); i++){
            lstPBEP[i].Start_Date__c = system.today() + 30;
            lstPBEP[i].End_Date__c = system.today() + 60;
        }
        update lstPBEP;

        List<Opportunity> lstOpportunity = [SELECT Id, RecordTypeId FROM Opportunity ORDER BY CreatedDate ASC];
        delete lstOpportunity;
        List<PricebookEntry> lstPriceBookEntry = [SELECT Id, Product2Id FROM PricebookEntry ORDER BY CreatedDate ASC];
        List<Product2> lstProduct = [SELECT Id,Type__c, RecordTypeId, Street_Date__c FROM Product2 ORDER BY CreatedDate ASC];
        for(Integer i=0; i<lstProduct.size(); i++){
            lstProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        }
        update lstProduct;

        List<Account> lstAccount = [SELECT Id,Sales_Organization__c,Digital_Country_Code__c FROM Account WHERE RecordTypeId !=: CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT ORDER BY CreatedDate ASC];
        List<Opportunity> lstNewOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount,1,false), lstAccount, lstProduct, lstPBEP);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = lstNewOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].Promoted_Price__c = 20;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
            if (lstNewOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 20;
            } else if (lstNewOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 10;
            }
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccount[i].Id + '-' + lstPriceBookEntry[i].Product2Id;
        }
        insert lstDealProduct;

        List<OpportunityLineItem> lstLineItemsBeforeBatchRun = [SELECT Id, Quantity, Opportunity.Promo_Start_Date__c, Product2.RecordTypeId, (SELECT Id, Revenue, Quantity, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(5, lstLineItemsBeforeBatchRun.size());

        for (OpportunityLineItem lineItem : lstLineItemsBeforeBatchRun) {
            System.assertEquals(1, lineItem.OpportunityLineItemSchedules.size());
            if (lineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, lineItem.Quantity);
                System.assertEquals(20, lineItem.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(400, lineItem.OpportunityLineItemSchedules[0].Revenue);
                System.assertEquals(System.today() + 30, lineItem.OpportunityLineItemSchedules[0].ScheduleDate);
            } else {
                System.assertEquals(10, lineItem.Quantity);
                System.assertEquals(10, lineItem.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(200, lineItem.OpportunityLineItemSchedules[0].Revenue);
                System.assertEquals(System.today() + 20, lineItem.OpportunityLineItemSchedules[0].ScheduleDate);
            }
            System.assertNotEquals(lineItem.Opportunity.Promo_Start_Date__c, lineItem.OpportunityLineItemSchedules[0].ScheduleDate);
        }

        Test.startTest();

        // Change Promo Start date
        List<Opportunity> lstOpportunityToUpdate = [SELECT Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityToUpdate) {
            deal.Promo_Start_Date__c = System.today() + 60;
            deal.Promo_End_Date__c = System.today() + 90;
        }
        update lstOpportunityToUpdate;

        // Verify checkbox is checked on change of Promo Start Date
        List<Opportunity> lstOpportunityBeforeBatchRun = [SELECT UpdateScheduleDates__c,Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityBeforeBatchRun) {
            System.assert(deal.UpdateScheduleDates__c, 'Checkbox should be true');
        }

        CRM_ProcessDealProductsBatch batchInstance = new CRM_ProcessDealProductsBatch();
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify checkbox is reset after batch is run
        List<Opportunity> lstOpportunityAfterBatchRun = [SELECT UpdateScheduleDates__c, Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityAfterBatchRun) {
            System.assert(!deal.UpdateScheduleDates__c, 'Checkbox should be false');
        }

        List<OpportunityLineItem> lstLineItemsAfterBatchRun = [SELECT Id, Quantity, Opportunity.Promo_Start_Date__c, Product2.RecordTypeId, (SELECT Id, Revenue, Quantity, ScheduleDate FROM OpportunityLineItemSchedules) FROM OpportunityLineItem];
        System.assertEquals(5, lstLineItemsAfterBatchRun.size());

        // Schedule Dates should not be changed as those are NR
        for (OpportunityLineItem lineItem : lstLineItemsBeforeBatchRun) {
            System.assertEquals(1, lineItem.OpportunityLineItemSchedules.size());
            if (lineItem.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, lineItem.Quantity);
                System.assertEquals(20, lineItem.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(400, lineItem.OpportunityLineItemSchedules[0].Revenue);
                System.assertEquals(System.today() + 30, lineItem.OpportunityLineItemSchedules[0].ScheduleDate);
            } else {
                System.assertEquals(10, lineItem.Quantity);
                System.assertEquals(10, lineItem.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(200, lineItem.OpportunityLineItemSchedules[0].Revenue);
                System.assertEquals(System.today() + 20, lineItem.OpportunityLineItemSchedules[0].ScheduleDate);
            }
            System.assertNotEquals(lineItem.Opportunity.Promo_Start_Date__c, lineItem.OpportunityLineItemSchedules[0].ScheduleDate);
        }
    }

    public static testMethod void Negative_Test_SendMail_With_RecordId() {
        //Method to create Dummy Data
        createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        List<Opportunity> lstOpportunity = [SELECT Id, RecordTypeId FROM Opportunity ORDER BY CreatedDate ASC];
        List<PricebookEntry> lstPriceBookEntry = [SELECT Id FROM PricebookEntry ORDER BY CreatedDate ASC];

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
            if (lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 20;
            } else if (lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 10;
            }
        }
        insert lstDealProduct;

        // Change Promo Start date
        List<Opportunity> lstOpportunityToUpdate = [SELECT Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityToUpdate) {
            deal.Promo_Start_Date__c = System.today() + 60;
            deal.Start_Date__c = System.today() + 60;
            deal.Promo_End_Date__c = System.today() + 90;
            deal.CloseDate = System.today() + 90;
        }
        update lstOpportunityToUpdate;

        // Verify checkbox is checked on change of Promo Start Date
        List<Opportunity> lstOpportunityBeforeBatchRun = [SELECT UpdateScheduleDates__c, Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityBeforeBatchRun) {
            System.assert(deal.UpdateScheduleDates__c, 'Checkbox should be true');
        }

        Test.startTest();
        CRM_ProcessDealProductsBatch batchInstance = new CRM_ProcessDealProductsBatch();
        for(Opportunity p : [SELECT Id FROM Opportunity]){
            List<String> lstErrors = new List<String>();
            lstErrors.add('Temporary Error1');
            lstErrors.add('Temporary Error2');
            batchInstance.lstExceptions.add(new CRM_ProcessDealProductsBatch.CRM_ProcessDealProductsBatchException(p.Id, lstErrors));
        }
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify checkbox is unchecked even after batch processing even after error
        List<Opportunity> lstOpportunityAfterBatchRun = [SELECT UpdateScheduleDates__c, Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityAfterBatchRun ) {
            System.assert(!deal.UpdateScheduleDates__c, 'Checkbox should be false');
        }
    }

    public static testMethod void Negative_Test_SendMail_Without_RecordId() {
        //Method to create Dummy Data
        createData();

        // Verify 5 valid opportunity records present
        System.assertEquals(5, [SELECT Id FROM Opportunity].size());

        List<Opportunity> lstOpportunity = [SELECT Id, RecordTypeId FROM Opportunity ORDER BY CreatedDate ASC];
        List<PricebookEntry> lstPriceBookEntry = [SELECT Id FROM PricebookEntry ORDER BY CreatedDate ASC];

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);
        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
            if (lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
                lstDealProduct[i].Replen_Quantity__c = 20;
            } else if (lstOpportunity[i].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) {
                lstDealProduct[i].Initial_Quantity__c = 10;
            }
        }
        insert lstDealProduct;

        // Change Promo Start date
        List<Opportunity> lstOpportunityToUpdate = [SELECT Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityToUpdate) {
            deal.Promo_Start_Date__c = System.today() + 60;
            deal.Start_Date__c = System.today() + 60;
            deal.Promo_End_Date__c = System.today() + 90;
            deal.CloseDate = System.today() + 90;
        }
        update lstOpportunityToUpdate;

        // Verify checkbox is checked on change of Promo Start Date
        List<Opportunity> lstOpportunityBeforeBatchRun = [SELECT UpdateScheduleDates__c, Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityBeforeBatchRun) {
            System.assert(deal.UpdateScheduleDates__c, 'Checkbox should be true');
        }

        Test.startTest();
        CRM_ProcessDealProductsBatch batchInstance = new CRM_ProcessDealProductsBatch();
        for(Opportunity p : [SELECT Id FROM Opportunity]){
            List<String> lstErrors = new List<String>();
            lstErrors.add('Temporary Error1');
            lstErrors.add('Temporary Error2');
            batchInstance.lstExceptions.add(new CRM_ProcessDealProductsBatch.CRM_ProcessDealProductsBatchException(null, lstErrors));
        }
        Database.executeBatch(batchInstance, 10);
        Test.stopTest();

        // Verify checkbox is unchecked even after batch processing even after error
        List<Opportunity> lstOpportunityAfterBatchRun = [SELECT UpdateScheduleDates__c, Promo_Start_Date__c, Start_Date__c, Promo_End_Date__c, CloseDate FROM Opportunity];
        for (Opportunity deal : lstOpportunityAfterBatchRun ) {
            System.assert(!deal.UpdateScheduleDates__c, 'Checkbox should be false');
        }
    }

    static testmethod void NegativeTest() {
    	insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
    	
        try {
            System.assertEquals(0, [SELECT Id FROM CRM_Error_Log__c].size());
            throw new TestException('Test Exception');
        } catch (Exception ex) {
            Test.startTest();
            CRM_ProcessDealProductsBatch instance = new CRM_ProcessDealProductsBatch();
            List<CRM_ErrorLogger.ErrorLog> lstErrors = instance.logAnException(ex);
            Test.stopTest();
            System.assertEquals(1, lstErrors.size());
            System.assertEquals(1, instance.lstExceptions.size());
        }
    }

      //US#594 
    public static testmethod void testEstimatedProductionCost() {   
    	insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
    	   
        // Create Account records
        List<Account> lstAccounts2 = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts2[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts2[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts2[0].CurrencyIsoCode ='GBP';
        insert  lstAccounts2;
        System.assertEquals(1, [Select Count() From Account]);
        
        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'GBP'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;
        
        List<CRM_Production_Cost_Estimated__c> lstCustomSett = new List<CRM_Production_Cost_Estimated__c>();
     lstCustomSett.add(new CRM_Production_Cost_Estimated__c (Name='aa',Calculation_Order__c = 10,Case_Type__c='361',Country__c = '6000',Currency__c='GBP'
        ,Estimated_Production_Cost__c =100,Format__c='4',Pack_Type__c='6')); 
     lstCustomSett.add(new CRM_Production_Cost_Estimated__c (Name ='bb',Calculation_Order__c = 20 ,Case_Type__c='361',Country__c='6000',Currency__c='GBP'
        ,Estimated_Production_Cost__c=200,Format__c='93',Pack_Type__c='6'));
        insert lstCustomSett;
        System.assertEquals(2, [SELECT Id FROM CRM_Production_Cost_Estimated__c].size());
        // Create Products records
        List<Product_Group__c> lstProductGroups2 = CRM_TestDataFactory.createProductGroups(1, true);
         List<Product2> lstProducts2 = CRM_TestDataFactory.createProducts(lstProductGroups2, 1, false);
        lstProducts2[0].ProductCode = '1000230554';
        lstProducts2[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProducts2[0].Product_Format__c = '93';
        lstProducts2[0].Product_Rating__c = 'UK - Minimum 12 Ye';
        lstProducts2[0].Product_Genre__c = 'ACTION';
        lstProducts2[0].Release_Category__c = '23';
        lstProducts2[0].Case_Type__c = '361';
        lstProducts2[0].Pack_Type__c = '6'; 
        lstProducts2[0].Franchise_Type__c = 'X4';
        lstProducts2[0].Product_Language_Code__c = 'EN';
        lstProducts2[0].SAP_Dist_chain_product_Status__c = '11';
        lstProducts2[0].Type__c = CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE;
        lstProducts2[0].Recommended_Price__c = 150;
        lstProducts2[0].Local_Title__c = lstLocaTitle[0].Id;
        lstProducts2[0].CurrencyIsoCode = 'GBP';
        lstProducts2[0].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
        lstProducts2[0].Product_Label__c = 'SND';
        insert lstProducts2;
        lstProducts2 = [Select Recalculate_Production_Cost__c, Production_cost__C From Product2];
        System.assertEquals(1, lstProducts2.size());
        System.assertEquals(false, lstProducts2[0].Recalculate_Production_Cost__c);
        System.assertEquals(null, lstProducts2[0].Production_cost__C);
     
        // Get standard Pricebook and Create Pricebook entry.
        List<PricebookEntry> lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProducts2,1, false);
        for(PricebookEntry pbe:lstPriceBookEntry2){
            pbe.CurrencyIsoCode = 'GBP';
        }
         insert lstPriceBookEntry2;
        System.assertEquals(1, [Select Count() From PriceBookEntry]);
        
        List<Pricebook_Entry_Period__c> lstPBEP = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts2, 1, false);
        for (Pricebook_Entry_Period__c pbep : lstPBEP) {
                pbep.Start_Date__c = System.today() - 100;
                pbep.end_Date__c = System.today() + 100;
                pbep.CurrencyISOCode ='GBP';
            }
        insert lstPBEP;
        
        // Create Opportunity records
        List<Opportunity> lstOpportunity2 = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts2, 1,true);
        System.assertEquals(1, [Select Count() From Opportunity]);
        
        // Create Deal Product records
        List<OpportunityLineItem> lstDealProduct2 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry2, lstOpportunity2, 1, false);
        for(OpportunityLineItem a :lstDealProduct2 ){
        a.replen_quantity__c=3;
        a.initial_quantity__c=3;
        }
        insert lstDealProduct2;
        OpportunityLineItem dp = [Select Production_cost__c From OpportunityLineItem];
        System.assertEquals(200, dp.Production_cost__c);
        lstProducts2 = [Select Recalculate_Production_Cost__c, Production_cost__C From Product2];
        lstProducts2[0].Production_cost__C = 66;
        update lstProducts2;
        lstProducts2 = [Select Recalculate_Production_Cost__c, Production_cost__C From Product2];
        System.assertEquals(true, lstProducts2[0].Recalculate_Production_Cost__c);
        System.assertEquals(66, lstProducts2[0].Production_cost__C);
        Test.startTest();
            Database.executeBatch(new CRM_ProcessDealProductsBatch());
        Test.stopTest();
        OpportunityLineItem dp1 = [Select Product_Format__c,format__c,Production_cost__c From OpportunityLineItem];
        System.assertEquals(66, dp1.Production_cost__c);
        System.assertEquals('93', dp1.Format__c);
        System.assertEquals('93', dp1.Product_Format__c);
    }

	public static testmethod void testProcessDealBatch_process() {
		insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
    	
        //Method to create Dummy Data
        CRM_AutoEstablishSchedulesHelper_Test.TestDataWrapper tw = CRM_AutoEstablishSchedulesHelper_Test.createData();
        List<Product2> lstProduct = tw.lstProduct;

		Set<Id> setProductIds = new Set<Id>();
        // Update the Release Date to recalculate the schedules
        // For Physical Products update Product Street Date
        for (Product2 p : lstProduct){
        	setProductIds.add(p.Id);
            p.Street_Date__c = System.today() + 20;
        }
        update lstProduct;
        
        Test.startTest();
        CRM_ProcessDealsBatch batch = new CRM_ProcessDealsBatch(setProductIds);
        Database.executeBatch(batch, 50);
        Test.stopTest();
        
        for(Product2 p:[select Id, RecalculateSchedules__c from Product2 where Id IN:setProductIds]) {
        	System.assertEquals(p.RecalculateSchedules__c, false, 'RecalculateSchedules__c flag must be false after batch job run.');
        }
	}
	
	public static testmethod void testProcessDealBatch_errors() {
		insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));
    	
        //Method to create Dummy Data
        CRM_AutoEstablishSchedulesHelper_Test.TestDataWrapper tw = CRM_AutoEstablishSchedulesHelper_Test.createData();
        List<Product2> lstProduct = tw.lstProduct;

		Set<Id> setProductIds = new Set<Id>();
        // Update the Release Date to recalculate the schedules
        // For Physical Products update Product Street Date
        for (Product2 p : lstProduct){
        	setProductIds.add(p.Id);
            p.Street_Date__c = System.today() + 20;
        }
        update lstProduct;
        
        Test.startTest();
        CRM_ProcessDealsBatch.CRM_ProcessDealsBatchException ex1 = new CRM_ProcessDealsBatch.CRM_ProcessDealsBatchException(lstProduct[0].Id, new String[]{'Test Error Description 1'});
        CRM_ProcessDealsBatch.CRM_ProcessDealsBatchException ex2 = new CRM_ProcessDealsBatch.CRM_ProcessDealsBatchException(null, new String[]{'Test Error Description 2'});
        
        CRM_ProcessDealsBatch batch = new CRM_ProcessDealsBatch(setProductIds);
        batch.lstExceptions.add(ex1);
        batch.lstExceptions.add(ex2);
        batch.logAnException(new CRM_ProcessDealsBatch.CRM_ProcessDealsBatchException('Test Error Description 3'));
        Database.executeBatch(batch, 50);
        Test.stopTest();
        
        System.assert(batch.lstExceptions.size() > 0);
	}
	
    public class TestException extends Exception {
    }
}