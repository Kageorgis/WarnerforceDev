/*
   @Author Aditi Satpute
   @name CRM_AutoDigitalGermanyNRBatch_Test
   @CreateDate 13 Jun 2017
   @Description Test class for CRM_AutoDigitalGermanyNRBatch
   @Version <1.0>
   @reference Requirement no 352
  */
  
@isTest
public with sharing class CRM_AutoDigitalGermanyNRBatch_Test {

    public static testMethod void Scenario1_With_Existing_Deal_And_Target_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalGermanyNRBatch_Test.createData();

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

        // Verify 2 deal product records for 2 physical products should be created through batch
        List<OpportunityLineItem> lstLineItem = [SELECT Id, Target_Quantity__c FROM OpportunityLineItem];
        System.assertEquals(3, lstLineItem.size());
        for (OpportunityLineItem dealProduct : lstLineItem) {
            System.assertEquals(3, dealProduct.Target_Quantity__c, 'Quantity = Publised Target / Account Price (50/20)');
        }

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
            } else {
                System.assert(productInstance.NR_Product_Created__c);
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Scenario2_With_Existing_Deal_And_Deal_Product_To_Be_Cloned_Present_Test(){

        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalGermanyNRBatch_Test.createData();

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
        Map<Id, Opportunity> mapIdToDealInstance = new Map<Id, Opportunity>(lstDealsForChangedStreetDate);

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
            if (p.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        // Verify Target flags are set
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target_Revenue_Has_Changed__c, Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(50, targetInstance.Target__c);
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should be false');
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

        // Verify no additional opportunity records created
        System.assertEquals(10, [SELECT Id FROM Opportunity].size());

        // Verify 5 deal product records from which 3 digital products should be Cloned and created through batch and 2 will be as it is as those are physical
        // 2 deal products not created even if they have same Type as for those Products and Account, no valid Account Plan is found so no deal Product is created
        System.assertEquals(5, [SELECT Id FROM OpportunityLineItem].size());
        for (OpportunityLineItem dealProduct : [SELECT Id, Initial_Quantity__c,Promoted_Price__c, SAP_Promoted_Price__c, Account_Plan__c, Opportunity.Account.Digital_Country_Code__c, Replen_Quantity__c, Account_Price__c, OpportunityId,Target_Quantity__c, Quantity, Product2.RecordTypeId, Opportunity.AccountId FROM OpportunityLineItem]) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(20, dealProduct.Account_Price__c);
                System.assertEquals(20, dealProduct.Promoted_Price__c);
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(dealProduct.Promoted_Price__c, dealProduct.SAP_Promoted_Price__c);
                System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
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

        // Verify Target flags are reset
        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c,Target_Revenue_Has_Changed__c, Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(50, targetInstance.Target__c);
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should be false');
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
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalGermanyNRBatch_Test.createData();
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
        for (Target__c targetInstance : [SELECT Id, Product__r.RecordType.DeveloperName, Account__r.Digital_Country_Code__c, Account__r.Status__c, Account__r.Video_Digital__c, Account__r.Games_Digital__c, Product__r.Type__c, Account__r.Video_Physical__c, Account__r.Games_Physical__c, Product__r.NR_Product_Created__c, Account__c, Target_Revenue_Has_Changed__c, Product__c, Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(200, targetInstance.Target__c);
                System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should be true');
            }
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
                System.assertEquals(1, dealProduct.Quantity, 'Should be 1');
                System.assertEquals(10, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Initial Quantity not populated');
                // System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity != Account Plan.Target Quantity as Manually Schedule true');
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);

        // Verify Schedules not created as Manually Schedule true
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(0, lineItemSchedules.size());

        // Verify Target flags are reset
        for (Target__c targetInstance : [SELECT Id, Account__c, Target_Revenue_Has_Changed__c, Product__c, Product__r.RecordTypeId, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(200, targetInstance.Target__c);
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should be false');
            }
        }

        // Verify Process NR Batch checkbox is unchecked as it is only checked when List Price / Account Price / Start End Date of PBEP is changed and there is Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }

    public static testMethod void Street_Date_Changed_To_Same_Month_With_Existing_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalGermanyNRBatch_Test.createData();
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

        for (Integer i=0; i < tw.lstOpportunity.size(); i++) {
            Opportunity deal = tw.lstOpportunity[i];
            deal.CloseDate = endDateOfCurrentDate;
            deal.Start_Date__c = startDateOfCurrentDate;
            deal.Promo_Start_Date__c = startDateOfCurrentDate;
            deal.Promo_End_Date__c = endDateOfCurrentDate;
            deal.NR_Deal_Unique_Key__c = tw.lstAccounts[i].Id + '-' + currentMonth+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(tw.lstProduct[i].Type__c);

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

        List<Pricebook_Entry_Period__c> lstPBEP2 = [SELECT Id,Previous_Start_Date__c, Start_Date__c,Suggested_Price__c,
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP2.size() ; i++){
            lstPBEP2[i].Start_Date__c = oldStreetDate + 15;
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

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2'); 
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        Database.executeBatch(automaticNRDealCreationBatch,10);
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lineItems = [Select Id,OpportunityId from OpportunityLineItem];
        System.assertEquals(5, lineItems.size(), 'Initial Deal Products');
        Map<Id, OpportunityLineItem> mapIdToDealProductInsatnce = new Map<Id, OpportunityLineItem>(lineItems);
        Integer digitalDealProducts = 0;

        Integer numberDaysDifference = oldStreetDate.daysBetween(oldStreetDate);
        System.debug('---numberDaysDifference-->'+numberDaysDifference);

        Date nweStreetDate = oldStreetDate + 15;
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
                    System.assertEquals(1, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                    System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, dealProduct.OpportunityLineItemSchedules[0].Description);
                }
                digitalDealProducts++;
            }
        }

        System.assertEquals(3, digitalDealProducts);

        // Verify Products processed properly and flag is reset
        for (Product2 productInstance : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]) {
            if (productInstance.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!productInstance.NR_Product_Created__c);
                System.assert(!productInstance.Street_Date_Has_Changed__c);
            }
        }

        for (Target__c targetInstance : [SELECT Id, Account__c, Product__c, Target__c, Target_Revenue_Has_Changed__c FROM Target__c]) {
            System.assertEquals(50, targetInstance.Target__c);
            System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false as Scenario 2'); 
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
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_GERMANY_DIGITAL_COUNTRY_CODE;
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
            new List<Pricebook_Entry_Period__c>{streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update lstPriceBookEntryPeriod;

        for(Product2 p : lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update lstProduct;

        List<Target__c> lstTargets = CRM_TestDataFactory.createProductTargets(lstAccounts, lstProduct, false);
        Date startDate = (System.today() + 1).toStartOfMonth();
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
        for (Target__c targetInstance : [SELECT Id, Product__r.RecordTypeId, Account__c, Target_Revenue_Has_Changed__c, Product__c, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(50, targetInstance.Target__c);
                System.assert(targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should be set as Scenario 3');
            }
        }

        // Verify Process NR Batch checkbox is un checked as Scenario 3
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, isDuplicate__c, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            System.debug('--pbep.isDuplicate__c-->'+pbep.isDuplicate__c);
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
            System.assertEquals(1, dealProduct.Quantity, 'Quantity should be same as Target Quantity');
            System.assertEquals(3, dealProduct.Target_Quantity__c, 'Target Quantity should be Account Plan. Published target / Deal Product.AccountPrice');
            System.assertEquals(0, dealProduct.Replen_Quantity__c, 'Default 0');
        }

        // Verify Schedules created with Quantity 1 as Replen Quantity is not entered and it is default 1
        List<OpportunityLineItemSchedule> lineItemSchedules = [SELECT Id, Quantity, Revenue FROM OpportunityLineItemSchedule];
        System.assertEquals(1, lineItemSchedules.size());
        for (OpportunityLineItemSchedule schedule : lineItemSchedules) {
            System.assertEquals(1, schedule.Quantity);
            System.assertEquals(0, schedule.Revenue);
        }

        // Verify Target flags are set
        for (Target__c targetInstance : [SELECT Id, Product__r.RecordTypeId, Account__c, Target_Revenue_Has_Changed__c, Product__c, Target__c FROM Target__c]) {
            if (targetInstance.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assertEquals(50, targetInstance.Target__c);
                System.assert(!targetInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed on Target should be reset as Scenario 3');
            }
        }

        // Verify Process NR Batch checkbox is unchecked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c, Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
    }
}