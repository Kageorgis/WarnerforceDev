/*
   @Author: Cognizant Team   
   @name: CRM_AutoDigitalNRDealCreateService_Test
   @CreateDate: 12 Jan 2016
   @Description: Test/ Code Coverage for 'CRM_AutoDigitalNRDealCreationService' 
   @Version <1.0>
   @reference: classes: CRM_AutoDigitalNRDealCreationService
*/
/*======================================================================================*/

@isTest
public class CRM_AutoDigitalNRDealCreateService_Test{

    /*Create Dummy Data Using CRM_TestDataFactory Class*/
    static Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    static Id rtAccShipTo =  CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
    static Id rtTarget = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
    static Id digitalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
    static Id physicalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
    static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    static Id physicalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;

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

    public static testMethod void Street_Date_Changed_And_Target_Revenue_Changed_With_No_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        System.assertEquals(5, tw.lstProduct.size(), 'Updated Products');

        //Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++) {
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            //tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            //tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
            //tw.lstTargets[i].Target_Revenue_Has_Changed__c = true;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c);
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c,Material_Price_Group__c,
        Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
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
            if (p.RecordTypeId == digitalProductRecordTypeId) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            automaticNRDealCreationBatch.getNRProducts(),
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(7,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');
        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id, Target_Quantity__c, Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }
                digitalDealProducts++;
            }
        }
        System.assertEquals(5, digitalDealProducts);
    }

   public static testMethod void NR_Product_Creation_With_No_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        delete tw.lstOpportunity;
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for(Integer i = 0; i < tw.lstProduct.size() ; i++){
            System.assert(tw.lstProduct[i].NR_Product_Created__c);
            accountPlanUniqueKey.add(tw.lstProduct[i].Id + '-' + tw.lstAccounts[i].Id);
        }

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Previous_Start_Date__c, List_Price__c,Material_Price_Group__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Account_Price__c,Start_Date__c,Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            automaticNRDealCreationBatch.getNRProducts(),
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        System.assertEquals(3,[Select Id, Name from Opportunity].size(), 'New Deals');
        for (Opportunity deal : [Select Id,RecordTypeId, Name from Opportunity]) {
            System.assertEquals(digitalDealRecordTypeId, deal.RecordTypeId);
        }
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,OpportunityId,Target_Quantity__c,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(3, dealProduct.Target_Quantity__c);
            } else {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(0, dealProduct.Target_Quantity__c);
            }
            //System.assertEquals(3, dealProduct.Quantity);
        }
    }
    public static testMethod void NR_Product_Creation_With_Existing_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        for(Integer i = 0; i < tw.lstProduct.size() ; i++){
            System.assert(tw.lstProduct[i].NR_Product_Created__c);
            accountPlanUniqueKey.add(tw.lstProduct[i].Id + '-' + tw.lstAccounts[i].Id);
        }

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Previous_Start_Date__c, List_Price__c,Material_Price_Group__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Account_Price__c,Start_Date__c,Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        System.debug('--mapIdToPBEPInstance-in test->'+mapIdToPBEPInstance);
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Updated Deals');
        Set<Id> digitalDealIds = new Set<Id>();
        for (Opportunity deal : [Select Id,RecordTypeId, Name from Opportunity]) {
            if (deal.RecordTypeId == digitalDealRecordTypeId) {
                digitalDealIds.add(deal.Id);
            }
        }
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
             System.assert(digitalDealIds.contains(dealProduct.OpportunityId));
            if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(3, dealProduct.Target_Quantity__c);
            } else {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(0, dealProduct.Target_Quantity__c);
            }
        }
    }

    public static testMethod void Street_Date_Changed_With_Existing_Schedules_Test(){
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
            tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id,Previous_Start_Date__c, Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Account_Price__c, List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,Material_Price_Group__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
            lstPBEP[i].Previous_Start_Date__c = System.today() + 1;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
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
            if (p.RecordTypeId == digitalProductRecordTypeId) {
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
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed , mapIdToPBEPInstance, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        List<OpportunityLineItem> lineItems = [Select Id,OpportunityId from OpportunityLineItem];
        System.assertEquals(7,lineItems.size(), 'Initial Deal Products');
        Map<Id, OpportunityLineItem> mapIdToDealProductInsatnce = new Map<Id, OpportunityLineItem>(lineItems);
        Integer digitalDealProducts = 0;
        Date oldStreetDate = system.today()+1;
        Integer numberDaysDifference = oldStreetDate.daysBetween(system.today());
        System.debug('---numberDaysDifference-->'+numberDaysDifference);

        Date nweStreetDate = system.today()+140;
        Date newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        System.debug('--newScheduleDate-->'+newScheduleDate);
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(21, dealProduct.Quantity);
                    //System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(10, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                    System.assertEquals(21, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                    System.assertEquals(system.today()+140, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                }
                digitalDealProducts++;
            }
        }

        System.assertEquals(5, digitalDealProducts);
    }

    public static testMethod void Street_Date_Changed_With_No_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();

        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstPriceBookEntry[i].Product2Id;
        }
        insert lstDealProduct;

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c,
        Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,Material_Price_Group__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+140;
            lstPBEP[i].End_Date__c = System.today() +160;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);
         for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == digitalProductRecordTypeId) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed , mapIdToPBEPInstance, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'New Deals');
        //Total 7 Deal Products (2 extra deal products for repeated Video Digital Product)
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(7,dealProducts.size(), 'New Deal Products');
        Map<Id, OpportunityLineItem> mapIdToDealroductInstance =
            new Map<Id, OpportunityLineItem>(dealProducts);
        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(3, dealProduct.Target_Quantity__c);
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }
                digitalDealProducts++;
            }
        }
        System.assertEquals(5, digitalDealProducts);

        // Only two schedules created for 2 digital deal's deal products as those deal products are not created as part of test data
        // So as manually Schedule is false for those deal products, trigger created the schedules for default quantity 1
        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity from OpportunityLineItemSchedule];
        System.assertEquals(2, schedules.size(), 'New Deal Product Schedule');

        for (OpportunityLineItemSchedule scheduleInstance : schedules) {
            System.assertEquals(1, scheduleInstance.Quantity);
            OpportunityLineItem dealProduct =
                mapIdToDealroductInstance.get(scheduleInstance.OpportunityLineItemId);
            System.assert(dealProduct.Opportunity.Product_Type__c.contains('Digital'));
        }
    }

    public static testMethod void Target_Revenue_Has_Changed_With_No_Schedules(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
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
            tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
            //tw.lstTargets[i].Target_Revenue_Has_Changed__c = true;
            //System.debug('tw.lstTargets[i]::'+tw.lstTargets[i].Calc_Start_Date__c);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        List<Pricebook_Entry_Period__c> lstPBEP = 
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,Material_Price_Group__c,
                    CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == digitalProductRecordTypeId) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(1, dealProduct.Target_Quantity__c);
                }
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);
    }

    public static testMethod void Target_Revenue_Has_Changed_With_Auto_Generated_Schedules(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<String> accountPlanUniqueKey = new Set<String>();

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;
        
        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Account_Price__c = 20;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        // Verify 1 Schedule for each digital and physical deal product is created
        System.assertEquals(5, [Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'New Deal Product Schedule');

        //Setting up Product Data
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
            //tw.lstTargets[i].Target_Revenue_Has_Changed__c = true;
            System.debug('tw.lstTargets[i]::'+tw.lstTargets[i].Calc_Start_Date__c);
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');
        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }
        
        List<Pricebook_Entry_Period__c> lstPBEP =
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,Process_NR_Batch__c,Material_Price_Group__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == digitalProductRecordTypeId) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet, 
            mapIdToPBEPInstance, setProcessedProductIds
        );
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');
        
        // Verify target Revenue is changed for deal products with schedules
        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Replen_Quantity__c,Target_Quantity__c, Initial_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(1, dealProduct.Quantity, 'Should not be updated');
                    System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Updated Quantity');
                    System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                    System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Updated Quantity');
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(1, dealProduct.Target_Quantity__c);
                    System.assertEquals(1, dealProduct.Initial_Quantity__c, 'Updated Quantity');
                    System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity');
                }
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);
    }

    public static testMethod void Target_Revenue_Has_Changed_With_Manual_Schedules() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        // As we are considering Scenario 3, so Process NR Batch will always be false untill PBRP is updated.
        for (Pricebook_Entry_Period__c pbep : tw.lstPriceBookEntryPeriod) {
            pbep.Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        //Setting up Product Data
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
        //Setting up OpportunityLineItemSchedule Data
        for(Integer i=0 ; i< lstDealProductSchedule.size(); i++){
            lstDealProductSchedule[i].OpportunityLineItemId = lstDealProduct[i].id;
        }
        insert lstDealProductSchedule;

        // Verify 1 Schedule for each deal product is created
        System.assertEquals(lstDealProduct.size(), [Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'New Deal Product Schedule');

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
            //tw.lstTargets[i].Target_Revenue_Has_Changed__c = true;
            //System.debug('tw.lstTargets[i]::'+tw.lstTargets[i].Calc_Start_Date__c);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');
        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        List<Pricebook_Entry_Period__c> lstPBEP =
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,Process_NR_Batch__c,Material_Price_Group__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == digitalProductRecordTypeId) {
                System.assert(!p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed , mapIdToPBEPInstance, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        // Verify target Revenue is not changed for deal products with manual schedules
        Integer digitalDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select Id,Account_Price__c,Target_Quantity__c,Replen_Quantity__c, Initial_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(21.00, dealProduct.Quantity, 'Not updated');
                    //System.assertEquals(0, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(1, dealProduct.Target_Quantity__c);
                }
                digitalDealProducts++;
            }
        }
        System.assertEquals(3, digitalDealProducts);
    }

    public static testMethod void Street_Date_Changed_And_Target_Revenue_Changed_With_Existing_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
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
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;
        //Setting up OpportunityLineItemSchedule Data
        for(Integer i=0 ; i< lstDealProductSchedule.size(); i++){
            lstDealProductSchedule[i].OpportunityLineItemId = lstDealProduct[i].id;
        }
        insert lstDealProductSchedule;

        // Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Target__c = 200;
            accountPlanUniqueKey.add(tw.lstTargets[i].Product__c + '-' + tw.lstAccounts[i].Id);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;

        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c +'-'+ accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Previous_Start_Date__c, Start_Date__c,Account_Price__c, //Suggested_Price__c, - US#895 - removed ref. of suggested price
        List_Price__c, Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode,Material_Price_Group__c,
        Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+40;
            lstPBEP[i].End_Date__c = System.today() +60;
            lstPBEP[i].Previous_Start_Date__c = System.today() + 1;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        System.assertEquals(5, [SELECt Id FROM OpportunityLineItemSchedule].size());
 
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == digitalProductRecordTypeId) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed , mapIdToPBEPInstance, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(7,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');
        Integer digitalDealProducts = 0;
        Map<Id, OpportunityLineItem> mapDealProductIdToInstance = new Map<Id, OpportunityLineItem>();
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId  from OpportunityLineItem]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(21, dealProduct.Quantity, 'Quantity not updated as manually added schedules present');
                    //System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity not updated as manually added schedules present');
                    System.assertEquals(10, dealProduct.Target_Quantity__c, 'Quantity not updated as manually added schedules present');
                } else {
                    System.assertEquals(1, dealProduct.Quantity);
                    System.assertEquals(0, dealProduct.Target_Quantity__c);
                }
                digitalDealProducts++;
                mapDealProductIdToInstance.put(dealProduct.Id, dealProduct);
            }
        }
        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId,Quantity from OpportunityLineItemSchedule];
        System.assertEquals(7, schedules.size(), 'New Deal Product Schedule');
        for (OpportunityLineItemSchedule schedule : schedules) {
            if (mapDealProductIdToInstance.containskey(schedule.OpportunityLineItemId)) {
                OpportunityLineItem dealProduct = mapDealProductIdToInstance.get(schedule.OpportunityLineItemId);
                if (accountPlanUniqueKey.contains(dealProduct.Product2Id + '-' + dealProduct.Opportunity.AccountId)) {
                    System.assertEquals(21, schedule.Quantity, 'Quantity got cloned');
                } else {
                    System.assertEquals(1, schedule.Quantity);
                }
            }
        }
        System.assertEquals(5, digitalDealProducts);
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GD )
           2. Deals -> D0 -> For A0 -> (GD, Start Date = System.Today())
           3. Deal Product -> D0 (DP0 with P0 batch created having unique Key)
      2. Product ->
           1. P0 (GD, PBEP with Start Date = System.today()) -> Valid Target with Revenue Changed
      3. Result
           1. P0
                - Even if Street Date is changed, it will find the existing deal D0 and check for Deal Product in that.
                - As the Deal PRoduct is already present for the valid deal it will only process for Target Revenue change
                  and update the Quantity of the existing deal product
     */
    public static testMethod void Street_Date_Changed_And_Target_Revenue_Changed_With_Existing_Deal_Product() {
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        //Method to create Dummy Data
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(1);
        System.assertEquals(1, lstAccounts.size());

        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        // Setting Up the Account Data
        Account soldToAccount = lstAccounts[0];
        soldToAccount.Storefront__c = storefronts[0].Id;
        soldToAccount.Games_Physical__c = false;
        soldToAccount.Games_Digital__c = true;
        soldToAccount.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
        update soldToAccount; 

        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        System.assertEquals(1, lstProGrp.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'ABCD'}, 1, true);

        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        lstTitles[0].Name = 'Test4567';
        lstTitles[0].Video_Version__c = 'Test12345';
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(), false);
        System.assertEquals(1, lstProduct.size());
        for(Product2 p : lstProduct){
           p.Type__c = 'Games Digital';
           p.RecordTypeId = physicalProductRecordTypeId;
           p.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
           p.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
           p.Local_Title__c = lstLocaTitle[0].Id;
        }
        insert lstProduct;
        lstProduct = [SELECT Id, RecordTypeId,Type__c, Product_Type__c, STreet_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        //System.assertEquals(1, lstProduct.size());
        //System.debug('lstProduct::'+lstProduct.size());

        List<Target__c> lstTargets = CRM_AutoPhysicalNRDealCreateService_Test.createTargetsForNRBatch(lstAccounts, lstProduct, lstProGrp);
        System.assertEquals(1, lstTargets.size());
        for(Integer i=0 ; i < lstTargets.size() ; i++){
            lstTargets[i].Target__c = 200;
            //lstTargets[i].Target_Revenue_Has_Changed__c = true;
        }
        update lstTargets;

        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c +'-'+ accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry);

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        lstProduct[0].NR_Product_Created__c = false;
        update lstProduct;

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Start_Date__c,Account_Price__c, List_Price__c,Material_Price_Group__c,
        Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+40;
            lstPBEP[i].End_Date__c = System.today() +60;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);
        for(Integer i=0 ; i<lstPBEP.size() ; i++){
            lstPBEP[i].Start_Date__c = system.today()+1;
            lstPBEP[i].End_Date__c = System.today() +1;
        }
        update lstPBEP;

        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createDealsForNRBatch(
                CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct,lstPriceBookEntryPeriod);
        System.assertEquals(1, lstOpportunity.size());
        System.debug('lstOpportunity::'+lstOpportunity);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, false);

        //Setting up existing OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccounts[i].Id + '-' + lstPriceBookEntry[i].Product2Id;
        }
        insert lstDealProduct;
        System.assertEquals(1, lstDealProduct.size());
        System.assertEquals(1, lstDealProduct[0].Quantity);
        System.assertEquals(lstOpportunity[0].Id, lstDealProduct[0].OpportunityId);
        for(Product2 p : [SELECT Id, RecordTypeId, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2]){
            if (p.RecordTypeId == digitalProductRecordTypeId) {
                System.assert(p.Street_Date_Has_Changed__c);
                System.assert(!p.NR_Product_Created__c);
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            automaticNRDealCreationBatch.getNRProducts(),
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify even if street Date is changed no new Deal Product is created but the existing one Quantity is recalculated due to new Revenue change
        List<OpportunityLineItem> fetchedDealProducts = [SELECT Id, Quantity, Target_Quantity__c, OpportunityId FROM OpportunityLineItem];
        System.assertEquals(1, fetchedDealProducts.size());
        System.assertEquals(1, fetchedDealProducts[0].Quantity);
        System.assertEquals(10, fetchedDealProducts[0].Target_Quantity__c);
        System.assertEquals(lstOpportunity[0].Id, fetchedDealProducts[0].OpportunityId);
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GD )
           2. Deals -> For A0
                    1. D0 (GD, Start Date = System.Today() -> Manual Deal with Manual Deal Product (No Unique Key))
                    2. D1 (GD, Start Date = System.Today() -> NR Deal Changed To Planned)
                    3. D2 (GD, Start Date = System.today()+10 -> NR Deal Start Date Changed)
                    4. D3 (GD, Start Date = System.today() -> NR Deal with NR Deal Product Changed To Planned)
                    5. D4 (GD, Start Date = System.today() -> Valid NR Deal with no Deal Products)
           3. Deal Product ->
                    1. D0 (DP0 with P0 -> No NR Unique Key)
                    2. D3 (DP1 with P0 -> With NR Unique Key)
      2. Product -> P0 (GP, Street Date = system.today() + 1) -> valid Target present
      3. Result
           1. P0 -> No new Deal / Deal Product is created
    */
    public static testMethod void NR_Product_Creation_For_Multiple_Deals(){
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        
        //Method to create Dummy Data
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(1);
        System.assertEquals(1, lstAccounts.size());
        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Games_Digital__c = true;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
        //lstAccounts[0].Owner_Games__c = 
        update lstAccounts;
        
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

        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        lstProduct[0].Type__c = 'Games Digital';
        lstProduct[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProduct[0].Street_Date__c = system.today()+1;
        lstProduct[0].CurrencyIsoCode = 'USD';
        lstProduct[0].Local_Title__c = lstLocaTitle[0].Id;
        lstProduct[0].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstProduct[0].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        insert lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        System.debug('lstProduct::'+lstProduct.size());

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 200;
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = lstProduct[i].id;
            lstTargets[i].RecordTypeId = rtTarget;
        } 
        insert lstTargets;
        System.debug('lstTargets::'+lstTargets.size());
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry.size());

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Material_Price_Group__c,
        Start_Date__c,Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createMultipleDealsForSingleAccountAndProduct(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,5,false), lstAccounts, lstProduct, lstPBEP);
        System.debug('lstOpportunity::'+lstOpportunity);
        lstOpportunity[0].NR_Deal_Unique_Key__c = null;
        lstOpportunity[0].Name = 'Manual Deal with Manual Deal Product';
        lstOpportunity[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[1].Name = 'NR Deal Changed To Planned';
        lstOpportunity[2].Start_Date__c = system.today()+10;
        lstOpportunity[2].Promo_Start_Date__c = system.today()+10;
        lstOpportunity[2].Name = 'NR Deal Start Date Changed';
        lstOpportunity[3].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[3].Name = 'NR Deal with NR Deal Product Changed To Planned';
        lstOpportunity[4].Name = 'Valid NR Deal with no Deal Products';
        update lstOpportunity;
        System.debug('lstOpportunity::'+lstOpportunity.size());

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{lstOpportunity[0],lstOpportunity[3]}, 1, false);

        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            if(lstDealProduct[i].OpportunityId == lstOpportunity[3].Id)
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id;
        }
        insert lstDealProduct;

        // Verify existing deal and Deal products are created properly
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, Name, (SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(5, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsBeforeBatchRun.size());

        for (Opportunity opportunityInstance : dealsBeforeBatchRun) {
            if (opportunityInstance.Name == 'Manual Deal with Manual Deal Product') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c == null);
            } else if (opportunityInstance.Name == 'NR Deal Changed To Planned') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else if (opportunityInstance.Name == 'NR Deal Start Date Changed') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else if (opportunityInstance.Name == 'NR Deal with NR Deal Product Changed To Planned') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Valid NR Deal with no Deal Products') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            }
        }

        List<Product2> lstProducts = [SELECT Id, NR_Product_Created__c FROM Product2];
        for(Integer i = 0; i < lstProducts.size() ; i++){
            System.assert(lstProducts[i].NR_Product_Created__c);
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            automaticNRDealCreationBatch.getNRProducts(),
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no new Deal / Deal Products created as existing NR deal / Deal present with non NR Default Stage
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, Name, (SELECT Id, NR_Deal_Product_Unique_Key__c, Target_Quantity__c,Quantity FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(5, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItem];
        System.assertEquals(3, dealProductsAfterBatchRun.size());

        // Verify batch results
        for (Opportunity opportunityInstance : dealsAfterBatchRun) {
            if (opportunityInstance.Name == 'Manual Deal with Manual Deal Product') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c == null);
            } else if (opportunityInstance.Name == 'NR Deal Changed To Planned') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
                System.assertEquals(1, opportunityInstance.OpportunityLineItems[0].Quantity);
                System.assertEquals(10, opportunityInstance.OpportunityLineItems[0].Target_Quantity__c);
            } else if (opportunityInstance.Name == 'NR Deal Start Date Changed') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else if (opportunityInstance.Name == 'NR Deal with NR Deal Product Changed To Planned') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Valid NR Deal with no Deal Products') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else {
                System.assert(false, 'This should not be executed');
            }
        }
    }

        /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GD )
           2. Deals -> For A0
                    1. D0 (GD, Start Date = System.Today() -> Manual Deal with Manual Deal Product (No Unique Key))
                    2. D1 (GD, Start Date = System.Today() -> NR Deal Changed To Planned)
                    3. D2 (GD, Start Date = System.today()+10 -> NR Deal Start Date Changed)
                    4. D3 (GD, Start Date = System.today() -> NR Deal with NR Deal Product Changed To Planned)
                    5. D4 (GD, Start Date = System.today() -> Valid NR Deal with no Deal Products)
           3. Deal Product ->
                    1. D0 (DP0 with P0 -> No NR Unique Key)
                    2. D3 (DP1 with P0 -> With NR Unique Key)
      2. Product -> P0 (GP, Street Date changed = system.today() + 1) -> valid Target present
      3. Result
           1. P0 -> No new Deal / Deal Product is created and no existing deal Product gets deleted
    */
    public static testMethod void Street_Date_Changed_With_Planned_Deal_Stage_For_Multiple_Deals(){
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        
        //Method to create Dummy Data
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(1);
        System.assertEquals(1, lstAccounts.size());
        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Games_Digital__c = true;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
        //lstAccounts[0].Owner_Games__c = 
        update lstAccounts;
        
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

        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,1,false);
        lstProduct[0].Type__c = 'Games Digital';
        lstProduct[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProduct[0].Street_Date__c = system.today()+1;
        lstProduct[0].CurrencyIsoCode = 'USD';
        lstProduct[0].Local_Title__c = lstLocaTitle[0].Id;
        lstProduct[0].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstProduct[0].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        insert lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        //System.debug('lstProduct::'+lstProduct.size());

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 200;
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = lstProduct[i].id;
            lstTargets[i].RecordTypeId = rtTarget;
        } 
        insert lstTargets;
        System.debug('lstTargets::'+lstTargets.size());
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry.size());

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);
        lstProduct[0].NR_Product_Created__c = false;
        update lstProduct;

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Material_Price_Group__c,
        Start_Date__c,Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        
        List<Opportunity> lstOpportunity =
            CRM_AutoPhysicalNRDealCreateService_Test.createMultipleDealsForSingleAccountAndProduct(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,5,false), lstAccounts, lstProduct, lstPBEP);
        System.debug('lstOpportunity::'+lstOpportunity);
        lstOpportunity[0].NR_Deal_Unique_Key__c = null;
        lstOpportunity[0].Name = 'Manual Deal with Manual Deal Product';
        lstOpportunity[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[1].Name = 'NR Deal Changed To Planned';
        lstOpportunity[2].Start_Date__c = system.today()+10;
        lstOpportunity[2].Promo_Start_Date__c = system.today()+10;
        lstOpportunity[2].Name = 'NR Deal Start Date Changed';
        lstOpportunity[3].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[3].Name = 'NR Deal with NR Deal Product Changed To Planned';
        lstOpportunity[4].Start_Date__c = system.today()+40;
        lstOpportunity[4].Promo_Start_Date__c = system.today()+40;
        lstOpportunity[4].CloseDate = system.today()+60;
        lstOpportunity[4].Promo_End_Date__c = system.today()+60;
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today() + 40).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        lstOpportunity[4].NR_Deal_Unique_Key__c = lstOpportunity[4].AccountId + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(lstProduct[0].Type__c);
        lstOpportunity[4].Name = 'Valid NR Deal with no Deal Products';
        update lstOpportunity;
        System.debug('lstOpportunity::'+lstOpportunity.size());

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{lstOpportunity[0],lstOpportunity[3]}, 1, false);

        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            if(lstDealProduct[i].OpportunityId == lstOpportunity[3].Id)
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id;
        }
        insert lstDealProduct;

        // Verify existing deal and Deal products are created properly
        List<Opportunity> dealsBeforeBatchRun = [SELECT Id, Name, (SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(5, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsBeforeBatchRun.size());

        for (Opportunity opportunityInstance : dealsBeforeBatchRun) {
            if (opportunityInstance.Name == 'Manual Deal with Manual Deal Product') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c == null);
            } else if (opportunityInstance.Name == 'NR Deal Changed To Planned') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else if (opportunityInstance.Name == 'NR Deal Start Date Changed') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else if (opportunityInstance.Name == 'NR Deal with NR Deal Product Changed To Planned') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Valid NR Deal with no Deal Products') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            }
        }

        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            lstPBEP[i].Start_Date__c = System.today() + 40;
            lstPBEP[i].End_Date__c = System.today() + 60;
        }
        update lstPBEP;
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        List<Product2> lstProducts = [SELECT Id, NR_Product_Created__c, Street_Date_Has_Changed__c FROM Product2];
        for(Integer i = 0; i < lstProducts.size() ; i++){
            System.assert(!lstProducts[i].NR_Product_Created__c);
            System.assert(lstProducts[i].Street_Date_Has_Changed__c);
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            automaticNRDealCreationBatch.getNRProducts(),
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no new Deal / Deal Products created as existing NR deal / Deal present with non NR Default Stage
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, Name, (SELECT Id, NR_Deal_Product_Unique_Key__c, Quantity FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(5, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsAfterBatchRun.size());

        // Verify batch results
        for (Opportunity opportunityInstance : dealsAfterBatchRun) {
            if (opportunityInstance.Name == 'Manual Deal with Manual Deal Product') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c == null);
            } else if (opportunityInstance.Name == 'NR Deal Changed To Planned') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else if (opportunityInstance.Name == 'NR Deal Start Date Changed') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else if (opportunityInstance.Name == 'NR Deal with NR Deal Product Changed To Planned') {
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            } else if (opportunityInstance.Name == 'Valid NR Deal with no Deal Products') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else {
                System.assert(false, 'This should not be executed');
            }
        }
    }

    /**
      Scenario Details
      1. Existing data
           1. Account -> A0 (Sold To : GD , VD), A1 (Ship To), A2 (Ship To)
           2. Deals ->
                  A0
                    -> D0 (GD, Start Date = System.Today() - 30, Manual Created with Batch created DP0)
                    -> D1 (GD, Start Date = System.Today(), Batch Created Deal with Deal Product DP1)
                    -> D2 (VD, Start Date = System.Today(), Batch Created Deal with Deal Product DP2)
                  A1 -> D3;
                  A2 -> D4, D5
           3. Deal Product -> D0 (DP0 with P0), D1 (DP1 with P0), D2( DP2 with P1)
      2. Product ->
           1. P0 (GD, Street Date = system.today()) -> No Valid Target
           2. P1 (VD, Street Date Changed= system.today() + 60) -> No Valid Target
           3. P2 (VD, Street Date Changed = system.today() + 60) -> Valid Target present
      3. Result
           1. P0 -> Nothing happens to Deal Products related to P0 as those are already existing DP with Batch generated Unique Key
           2. P1 -> Create new Deal D6 and Clone DP2 for P1 from D1 and add in this new Deal D6 with Quantity 1
           3. P2 -> Take the newly created Deal D6 while processing P1 and insert new DP3 for P2 in the same deal D6 with Quantity calculated based on Target present
     */
    private static testMethod void Street_Date_Changed_For_Multiple_Deals(){
  
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
 
        // Set up Account Data
        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(3);
        List<Agreement__c> storefronts = [SELECT Id FROM Agreement__c];
        System.assertEquals(1, storefronts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        Account soldToAccountGD = lstAccounts[0];
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].recordTypeId = rtAcc;
        lstAccounts[0].Games_Digital__c = true;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].Video_Digital__c = true;
 
        // Next 2 Accounts are Ship To Accounts with Physical Type set
        lstAccounts[1].recordTypeId = rtAccShipTo;
        lstAccounts[1].Video_Physical__c = true;
        lstAccounts[2].recordTypeId = rtAccShipTo;
        lstAccounts[2].Video_Physical__c = true;
        for (Account acc : lstAccounts) {
            acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
        }
        update lstAccounts;
        soldToAccountGD = lstAccounts[0];
        System.debug('--lstAccounts-->'+lstAccounts);
        System.assertEquals(3, lstAccounts.size());
 
        // Setting Up the Product Group required for Product creation
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,false);
        System.assertEquals(1, lstProGrp.size());
 
        // Set Up 3 Products data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
        for(Integer i=0 ;i<lstProduct.size();i++){
            //lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        System.assertEquals(3, lstProduct.size());
        lstProduct[0].Type__c = 'Games Digital';
        lstProduct[0].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
        lstProduct[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        Product2 p0_GamesDigital = lstProduct[0];
        lstProduct[1].Type__c = 'Video Digital';
        Product2 p1_VideoDigital = lstProduct[1];
        lstProduct[2].Type__c = 'Video Digital';
        Product2 p2_VideoDigital = lstProduct[2];
        insert lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
 
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,new List<Product2>{p2_VideoDigital}, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, new List<Account> {soldToAccountGD}, true);
 
        // Create Multiple Targets for p2_GamesPhysical
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(new List<Account> {soldToAccountGD, soldToAccountGD, soldToAccountGD} , lstProGrp , lstAccountPlan, false);
        System.assertEquals(3, lstTargets.size());
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Product__c = p2_VideoDigital.id;
            lstTargets[i].RecordTypeId = rtTarget;
        }
        System.assertEquals(3, lstTargets.size());
        lstTargets[0].Target__c = 100;
        lstTargets[1].Target__c = 200;
        lstTargets[2].Target__c = 400;
        insert lstTargets;
 
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,2,false);
        System.assertEquals(6, lstOpportunity.size());
 
        // First Deal is Manual created along with Manual Deal Product and lies in previous month
        lstOpportunity[0].AccountId = soldToAccountGD.Id;
        lstOpportunity[0].Start_Date__c = system.today() - 130;
        lstOpportunity[0].Promo_Start_Date__c = system.today() - 130;
        lstOpportunity[0].CloseDate = system.today() - 125;
        lstOpportunity[0].Promo_End_Date__c = system.today() - 125;
        lstOpportunity[0].Name = 'Manual created Deal 1 with Unique Key with Deal Products for Product 1';
        lstOpportunity[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        lstOpportunity[0].CurrencyIsoCode = 'USD';
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today() - 130).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;

        lstOpportunity[0].NR_Deal_Unique_Key__c = soldToAccountGD.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesDigital.Type__c);
        lstOpportunity[0].Product_Type__c = 'Games Digital';
        lstOpportunity[0].RecordTypeId = digitalDealRecordTypeId;
 
        // Existing Deal with Deal Product for Games Digital Product (P0) to check nothing happens on Street Date change
        lstOpportunity[1].AccountId = soldToAccountGD.Id;
        lstOpportunity[1].Name = 'Batch created Deal 2 with Unique Key with Deal Products for Product 1';
        lstOpportunity[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        lstOpportunity[1].CurrencyIsoCode = 'USD';
        Integer currentQtr2 =
            Decimal.valueOf(
                (system.today() + 1).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod2 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr2;

        lstOpportunity[1].NR_Deal_Unique_Key__c = soldToAccountGD.Id + '-' + dealPeriod2+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesDigital.Type__c);
        lstOpportunity[1].Product_Type__c = 'Games Digital';
        lstOpportunity[1].RecordTypeId = digitalDealRecordTypeId;
 
        // Existing Deal for Video Physical Product (P1) to check Cloning of deal Product on Street Date change
        lstOpportunity[2].AccountId = soldToAccountGD.Id;
        lstOpportunity[2].Name = 'Batch created Deal 3 with Unique Key with Deal Products for Product 2';
        lstOpportunity[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        lstOpportunity[2].CurrencyIsoCode = 'USD';
        lstOpportunity[2].NR_Deal_Unique_Key__c = soldToAccountGD.Id + '-' + dealPeriod2+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesDigital.Type__c);
        lstOpportunity[2].Product_Type__c = 'Video Digital';
        lstOpportunity[2].RecordTypeId = digitalDealRecordTypeId;
        lstOpportunity[3].Product_Type__c = 'Video Physical';
        lstOpportunity[3].AccountId = lstAccounts[1].Id;
        lstOpportunity[4].Product_Type__c = 'Video Physical';
        lstOpportunity[4].AccountId = lstAccounts[2].Id;
        lstOpportunity[5].Product_Type__c = 'Video Physical';
        lstOpportunity[5].AccountId = lstAccounts[2].Id;
        System.debug('--lstOpportunity-->'+lstOpportunity);
        insert lstOpportunity;
 
        // Setting up 1 Price Book Entry record for each created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(3, lstPriceBookEntry.size());
 
        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.assertEquals(3, lstPriceBookEntryPeriod.size());
        for (Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++) {
            if (i == 0) {
                lstPriceBookEntryPeriod[i].Start_Date__c = System.Today() - 180;
            }
        }
        update lstPriceBookEntryPeriod;
        for (Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++) {
            if (i == 0) {
                lstPriceBookEntryPeriod[i].Process_NR_Batch__c = false;
            }
        }
        update lstPriceBookEntryPeriod;

        for(Integer i=0 ;i<lstProduct.size();i++){
            lstProduct[i].NR_Product_Created__c = false;
        }
        update lstProduct;

        // Setting up Deal Product data such that batch deal Product already present for the above Deals D0, D1 and D2
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{lstOpportunity[0],lstOpportunity[1], lstOpportunity[2]}, 1, false);
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            System.debug('---lstDealProduct[i].OpportunityId-->'+lstDealProduct[i].OpportunityId);
            System.debug('---lstOpportunity[2].Id-->'+lstOpportunity[2].Id);
            if (lstDealProduct[i].OpportunityId == lstOpportunity[2].Id) {
                System.assertEquals(lstPriceBookEntry[1].Product2Id, p1_VideoDigital.Id);
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = soldToAccountGD.Id + '-' + p1_VideoDigital.Id;
                lstDealProduct[i].PriceBookEntryId = lstPriceBookEntry[1].Id;
            }
            // Create 2 deal products with same Product
            else {
                System.assertEquals(lstPriceBookEntry[0].Product2Id, p0_GamesDigital.Id);
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = soldToAccountGD.Id + '-' + p0_GamesDigital.Id;
                lstDealProduct[i].PriceBookEntryId = lstPriceBookEntry[0].Id;
            }
        }
        insert lstDealProduct;
        System.assertEquals(3, lstDealProduct.size());

        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            lstPriceBookEntryPeriod[i].Previous_Start_Date__c = System.today()+1;
            if (i == 0) {
                // Keep the Street Date of P0 in same month as of deal created
                lstPriceBookEntryPeriod[i].Start_Date__c = System.today() + 1;
            } else {
                // P1 and P2 should lie in different month so that they will create a new deal and create 2 deal products in same deal
                lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+60;
            }
        }
        update lstPriceBookEntryPeriod;
        
        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Previous_Start_Date__c, Start_Date__c,Account_Price__c, List_Price__c,Material_Price_Group__c,
        Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c, CurrencyIsoCode,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

 
        // Verify the data before runnnig the batch
        for (Product2 product : [SELECT Id, Street_Date_Has_Changed__c FROM Product2]) {
           System.debug('----product-------'+product);
           System.debug('----lstProduct[0]-------'+lstProduct[0]);
           
           if (lstProduct[0].Id == product.Id) {
                System.assert(!product.Street_Date_Has_Changed__c, 'This should be false as the Start Date of PBEP is changed in current month only');
            } else {
                System.assert(product.Street_Date_Has_Changed__c, 'All Products should have Street Date changed as true');
            }
        }
 
        Map<Id,OpportunityLineItem> mapDealsProductsFetchedBeforeBatchRun = new Map<Id,OpportunityLineItem>([SELECT Id,Quantity,Product2Id, NR_Deal_Product_Unique_Key__c,(Select Id, Quantity,ScheduleDate from OpportunityLineItemSchedules) FROM OpportunityLineItem]);
        System.assertEquals(3, mapDealsProductsFetchedBeforeBatchRun.size());
        for (Opportunity opportunityInstance : [SELECT Id, Name,NR_Deal_Unique_Key__c, (SELECT Id,Target_Quantity__c,Quantity,Product2Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity]) {
            if (opportunityInstance.Name == 'Manual created Deal 1 with Unique Key with Deal Products for Product 1') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Batch created Deal 2 with Unique Key with Deal Products for Product 1') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Batch created Deal 3 with Unique Key with Deal Products for Product 2') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assertEquals(1, opportunityInstance.OpportunityLineItems[0].Quantity);
                System.assertEquals(0, opportunityInstance.OpportunityLineItems[0].Target_Quantity__c);
                OpportunityLineItem lineItems = mapDealsProductsFetchedBeforeBatchRun.get(opportunityInstance.OpportunityLineItems[0].Id);
                System.assertEquals(1, lineItems.OpportunityLineItemSchedules.size());
                System.assertEquals(1, lineItems.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(System.today() + 1, lineItems.OpportunityLineItemSchedules[0].ScheduleDate);
            } else {
                // No deal products created for Ship To Account deals
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            }
        }
 
        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            automaticNRDealCreationBatch.getNRProducts(),
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();
 
        // Verify batch results
        List<Opportunity> lstDealsFetched = [SELECT Id, Name,NR_Deal_Unique_Key__c, Product_Type__c, (SELECT Id,Quantity,Product2Id,Target_Quantity__c, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity];
        // Verify one additional Deal created through Batch for Product P1 and P2
        System.assertEquals(7, lstDealsFetched.size());
        // Verify batch results
        Map<Id,OpportunityLineItem> mapDealsProductsFetched = new Map<Id,OpportunityLineItem>([SELECT Id,Quantity,Product2Id,Target_Quantity__c, NR_Deal_Product_Unique_Key__c,(Select Id, Quantity,ScheduleDate from OpportunityLineItemSchedules) FROM OpportunityLineItem]);
        System.assertEquals(4, mapDealsProductsFetched.size());
        Integer currentQtr3 =
            Decimal.valueOf(
                (system.today() + 60).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod3 = CRM_AppConstants.NR_Deal_For_Quarter + ' ' + currentQtr3;

        for (Opportunity opportunityInstance : lstDealsFetched) {
            System.debug('--opportunityInstance-->'+opportunityInstance);
            if (opportunityInstance.Name == 'Manual created Deal 1 with Unique Key with Deal Products for Product 1') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Batch created Deal 2 with Unique Key with Deal Products for Product 1') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Batch created Deal 3 with Unique Key with Deal Products for Product 2') {
                System.debug('--in if-11->');
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            }
            // New Deal created for Video Physical Product (P1 & P2) same as scenario 1
            else if (opportunityInstance.Name == 'New Releases Video Digital '+dealPeriod3+' '+(system.today() + 60).year()+' ' + soldToAccountGD.Name) {
                System.debug('--in if-22->');
                // 2 Deal Products created.
                System.assertEquals(p1_VideoDigital.Type__c, opportunityInstance.Product_Type__c);
                System.assertEquals(2, opportunityInstance.OpportunityLineItems.size());
                for (OpportunityLineItem dealProduct : opportunityInstance.OpportunityLineItems) {
                    System.debug('-dealProduct-->'+dealProduct);
                    // 1. Verify if deal Product is created by cloning the deal Product for Product 1 from Deal 3 due to Street Date change
                    if (dealProduct.Product2Id == p1_VideoDigital.Id) {
                        System.debug('--1->');
                        System.assert(dealProduct.NR_Deal_Product_Unique_Key__c != null);
                        System.assertEquals(soldToAccountGD.Id + '-' + p1_VideoDigital.Id, dealProduct.NR_Deal_Product_Unique_Key__c );
                        // Quantity will be 1. It should not be modified by NR Batch
                        System.assertEquals(1, dealProduct.Quantity);
                        
                        // Quantity will be 0 as no Valid Target found for this Product
                        System.assertEquals(0, dealProduct.Target_Quantity__c);
                        if(mapDealsProductsFetched.containsKey(dealProduct.Id)){
                            //One Schedule created by Decay Curve as initial quantity on deal product is zero
                            System.assertEquals(1,mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules.size());
                            OpportunityLineItemSchedule schedule = mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0];
                            System.assertEquals(1, schedule.Quantity);
                            System.assertEquals(system.today() + 60, schedule.ScheduleDate);
                        }
                    }
                    // 2. Verify if deal Product is created as Scenario 1 for Street Date change as nothing to clone present for Product 2
                    else if (dealProduct.Product2Id == p2_VideoDigital.Id) {
                        System.debug('--2->');
                        System.assert(dealProduct.NR_Deal_Product_Unique_Key__c != null);
                        System.assertEquals(soldToAccountGD.Id + '-' + p2_VideoDigital.Id, dealProduct.NR_Deal_Product_Unique_Key__c );
                         // Quantity will be 1. It should not be modified by NR Batch
                        System.assertEquals(1, dealProduct.Quantity);
                        
                        // Target Quantity will be 35 based on sum of all the Targets found in Account Plan  / Account Price
                        System.assertEquals(35, dealProduct.Target_Quantity__c);
                        if(mapDealsProductsFetched.containsKey(dealProduct.Id)){
                            //One Schedule created by Decay Curve as initial quantity on deal product is zero
                            System.assertEquals(1,mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules.size());
                            OpportunityLineItemSchedule schedule = mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0];
                            System.assertEquals(1, schedule.Quantity, 'Shedule Quantity should not be re-calculated');
                            System.assertEquals(system.today() + 60, schedule.ScheduleDate);
                        }
                    } else {
                        System.assert(false, 'Deal Products not created properly');
                    }
                }
            } else {
                // No deal products created for Ship To Account deals
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            }
        }
  }

    private static testMethod void Target_Revenue_Changed_Without_Deal_And_Deal_Products() {
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdTOPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
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
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
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
        p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = rtTarget;
        t0_GamesDigital.Target__c = 200;
        //t0_GamesDigital.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c +'-'+ accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the code will try to search the PriceBookEntryPeriod Start lies between the  Deal Start Date and End Date
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriodCreated[0].Product__c = p0_GamesDigital.id;
        lstPriceBookEntryPeriodCreated[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriodCreated[0].End_Date__c = System.today() + 30;
        lstPriceBookEntryPeriodCreated[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriodCreated[0].List_Price__c = 20;
        insert lstPriceBookEntryPeriodCreated;

        List<Pricebook_Entry_Period__c> lstPBEP = 
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,Material_Price_Group__c,
                    CurrencyIsoCode, Product__r.RecordTypeId, Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);
        List<Product2> fetchedProducts = [SELECT Id,NR_Product_Created__c, Street_Date_Has_Changed__c FROM  Product2];
        System.assertEquals(1, fetchedProducts.size());
        
        fetchedProducts[0].NR_Product_Created__c = false;
        fetchedProducts[0].Street_Date_Has_Changed__c = false;
        update fetchedProducts;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no deal and deal products are created for Scenario 3
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsAfterBatchRun.size());
    }

    private static testMethod void Target_Revenue_Changed_With_Planned_Deal_And_Deal_Products(){
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
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
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
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
        p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = rtTarget;
        t0_GamesDigital.Target__c = 200;
        //t0_GamesDigital.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c +'-'+ accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriod[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriod[0].New_Release__c = true;
        insert lstPriceBookEntryPeriod;

        List<Pricebook_Entry_Period__c> lstPBEP = 
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,Material_Price_Group__c,
                    CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }

        System.debug('lstPBEP::'+lstPBEP);
        List<Product2> fetchedProducts = [SELECT Id,NR_Product_Created__c, Street_Date_Has_Changed__c FROM  Product2];
        System.assertEquals(1, fetchedProducts.size());
        
        fetchedProducts[0].NR_Product_Created__c = false;
        fetchedProducts[0].Street_Date_Has_Changed__c = false;
        update fetchedProducts;

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGD.Id;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0 With Stage Changed';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        d0_existingDeal.CurrencyIsoCode = 'USD';
        /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today()).year(),
                    (system.today()).month(),
                    (system.today()).day()
                );
        String currentMonth1 = sDate1.format('MMM');*/
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today() + 1).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;

        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGD.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesDigital.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Digital';
        d0_existingDeal.RecordTypeId = digitalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGD.Id + '-' + p0_GamesDigital.Id;
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        insert dp0_existingDealProduct;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Quantity,Target_Quantity__c FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        System.assertEquals(20, dealProductsBeforeBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeBatchRun[0].Target_Quantity__c);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no new deal and deal product is created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assertEquals(dealsBeforeBatchRun[0].Id, dealsAfterBatchRun[0].Id);

        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        System.assertEquals(dealProductsBeforeBatchRun[0].Id, dealProductsAfterBatchRun[0].Id);

        // Verify Quantity is recalculated even if Valid deal if of Stage Planned
        System.assertEquals(20, dealProductsAfterBatchRun[0].Quantity);
        System.assertEquals(10, dealProductsAfterBatchRun[0].Target_Quantity__c);
    }

    private static testMethod void Target_Revenue_Changed_With_Committed_Deal_And_Deal_Products(){

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

        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
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
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
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
        p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = rtTarget;
        t0_GamesDigital.Target__c = 200;
        //t0_GamesDigital.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c +'-'+ accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriod[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriod[0].New_Release__c = true;
        insert lstPriceBookEntryPeriod;

        List<Pricebook_Entry_Period__c> lstPBEP = 
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,Material_Price_Group__c,
                    CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }

        System.debug('lstPBEP::'+lstPBEP);
        List<Product2> fetchedProducts = [SELECT Id,NR_Product_Created__c, Street_Date_Has_Changed__c FROM  Product2];
        System.assertEquals(1, fetchedProducts.size());
        
        fetchedProducts[0].NR_Product_Created__c = false;
        fetchedProducts[0].Street_Date_Has_Changed__c = false;
        update fetchedProducts;

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGD.Id;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0 With Stage Changed';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        d0_existingDeal.CurrencyIsoCode = 'USD';
        /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today()).year(),
                    (system.today()).month(),
                    (system.today()).day()
                );
        String currentMonth1 = sDate1.format('MMM');*/
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today() + 1).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGD.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesDigital.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Digital';
        d0_existingDeal.RecordTypeId = digitalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGD.Id + '-' + p0_GamesDigital.Id;
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        insert dp0_existingDealProduct;

        // Make the deal as Committed
        System.runas(testUser) {
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update d0_existingDeal;
        }

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Quantity,Target_Quantity__c FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        System.assertEquals(20, dealProductsBeforeBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeBatchRun[0].Target_Quantity__c);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no new deal and deal product is created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assertEquals(dealsBeforeBatchRun[0].Id, dealsAfterBatchRun[0].Id);

        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        System.assertEquals(dealProductsBeforeBatchRun[0].Id, dealProductsAfterBatchRun[0].Id);

        // Verify Quantity is recalculated even if Valid deal if of Stage Committed
        System.assertEquals(20, dealProductsAfterBatchRun[0].Quantity);
        System.assertEquals(10, dealProductsAfterBatchRun[0].Target_Quantity__c);
    }

    private static testMethod void Target_Revenue_Changed_With_Approved_Deal_And_Deal_Products(){

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

        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
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
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
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
        p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = rtTarget;
        t0_GamesDigital.Target__c = 200;
        //t0_GamesDigital.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c +'-'+ accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriod[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriod[0].New_Release__c = true;
        insert lstPriceBookEntryPeriod;

        List<Pricebook_Entry_Period__c> lstPBEP = 
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,Material_Price_Group__c,
                    CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }

        System.debug('lstPBEP::'+lstPBEP);
        List<Product2> fetchedProducts = [SELECT Id,NR_Product_Created__c, Street_Date_Has_Changed__c FROM  Product2];
        System.assertEquals(1, fetchedProducts.size());
        
        fetchedProducts[0].NR_Product_Created__c = false;
        fetchedProducts[0].Street_Date_Has_Changed__c = false;
        update fetchedProducts;

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGD.Id;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0 With Stage Changed';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        d0_existingDeal.CurrencyIsoCode = 'USD';
        /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today()).year(),
                    (system.today()).month(),
                    (system.today()).day()
                );
        String currentMonth1 = sDate1.format('MMM');*/
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today() + 1).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGD.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesDigital.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Digital';
        d0_existingDeal.RecordTypeId = digitalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGD.Id + '-' + p0_GamesDigital.Id;
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        insert dp0_existingDealProduct;

        // Make the deal as Approved
        System.runas(testUser) {
            d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED;
            update d0_existingDeal;
        }

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Quantity,Target_Quantity__c FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        System.assertEquals(20, dealProductsBeforeBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeBatchRun[0].Target_Quantity__c);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no new deal and deal product is created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assertEquals(dealsBeforeBatchRun[0].Id, dealsAfterBatchRun[0].Id);

        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        System.assertEquals(dealProductsBeforeBatchRun[0].Id, dealProductsAfterBatchRun[0].Id);

        // Verify Quantity is recalculated even if Valid deal if of Stage Approved
        System.assertEquals(20, dealProductsAfterBatchRun[0].Quantity);
        System.assertEquals(10, dealProductsAfterBatchRun[0].Target_Quantity__c);
    }

    /*private static testMethod void Target_Revenue_Changed_With_Valid_Deal_And_Manual_Deal_Product(){
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Map<Id, List<Account_Plan__c>> mapProductIdToAccountPlanList = new Map<Id, List<Account_Plan__c>>();
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
        lstAccounts[0].Video_Physical__c = false;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].Storefront__c = storefronts[0].Id;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;

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
        p0_GamesDigital.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesDigital;
        p0_GamesDigital.NR_Product_Created__c = false;
        p0_GamesDigital.Street_Date_Has_Changed__c = false;
        update p0_GamesDigital;
        lstProduct = new List<Product2>{p0_GamesDigital};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_AutoPhysicalNRDealCreateService_Test.createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp ,lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesDigital = lstTargets[0];
        t0_GamesDigital.Account__c = soldToAccountGD.Id;
        t0_GamesDigital.Product__c = p0_GamesDigital.id;
        t0_GamesDigital.RecordTypeId = rtTarget;
        t0_GamesDigital.Target__c = 200;
        //t0_GamesDigital.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesDigital;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesDigital}, 1, false);
        lstPriceBookEntryPeriod[0].Start_Date__c = System.today() + 1;
        lstPriceBookEntryPeriod[0].New_Release__c = true;
        insert lstPriceBookEntryPeriod;

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }
           productAndAccountIdSet.add(accountPlanInstance.Country_Plan__r.NR_Product__c +'-'+ accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }
         
        List<Pricebook_Entry_Period__c> lstPBEP = 
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,Suggested_Price__c,
                    Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,
                    CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            lstPBEP[i].Process_NR_Batch__c = false;
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        update lstPBEP;

        System.debug('lstPBEP::'+lstPBEP);
        List<Product2> fetchedProducts = [SELECT Id,NR_Product_Created__c, Street_Date_Has_Changed__c FROM  Product2];
        System.assertEquals(1, fetchedProducts.size());
        
        fetchedProducts[0].NR_Product_Created__c = false;
        fetchedProducts[0].Street_Date_Has_Changed__c = false;
        update fetchedProducts;

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGD.Id;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0 With Stage Changed';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        d0_existingDeal.CurrencyIsoCode = 'USD';
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today()).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;

        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGD.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesDigital.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = digitalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up Deal Product data such manual deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        insert dp0_existingDealProduct;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        System.assertEquals(20, dealProductsBeforeBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeBatchRun[0].Target_Quantity__c);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no new deal and deal product is created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assertEquals(dealsBeforeBatchRun[0].Id, dealsAfterBatchRun[0].Id);

        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        System.assertEquals(dealProductsBeforeBatchRun[0].Id, dealProductsAfterBatchRun[0].Id);

        // Verify Quantity is not recalculated as no Valid deal found
        System.assertEquals(20, dealProductsAfterBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsAfterBatchRun[0].Target_Quantity__c);
        //System.assertEquals(10, dealProductsAfterBatchRun[0].Target_Quantity__c);
    }*/

    public static testMethod void NR_Product_Creation_With_Existing_Deal_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Change the Deal Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Opportunity deal : tw.lstOpportunity) {
            deal.CurrencyIsoCode = 'GBP';
        }
        update tw.lstOpportunity;

        System.assertEquals(5,[Select Id, Name from Opportunity WHERE CurrencyIsoCode = 'GBP'].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        // Create PricebookEntryPeriod which is not valid for the Account being processed
        List<Pricebook_Entry_Period__c> lstPBEP = 
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,Material_Price_Group__c,
                    CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify new deal is created for digital Products
        System.assertEquals(8,[Select Id, Name from Opportunity].size(), 'Updated Deals');

        // Verify  deal product is created as for newly created deals
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');
    }

    public static testMethod void Street_Date_Changed_With_No_Schedules_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
        }
        update tw.lstProduct;

        // Change the Deal Currency to make a scenario such that no valid PBEP found for the record being processed
        for (Account acc : tw.lstAccounts) {
            acc.CurrencyIsoCode = 'GBP';
        }
        system.runAs(createUser()) {
        	update tw.lstAccounts;
        }

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstPriceBookEntry[i].Product2Id;
        }
        insert lstDealProduct;

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+140;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+160;
        }
        update tw.lstPriceBookEntryPeriod;

        List<Pricebook_Entry_Period__c> lstPBEP = 
            [
                SELECT
                    Id, Previous_Start_Date__c, List_Price__c, Account_Price__c,Start_Date__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c, Price_Book__c,Material_Price_Group__c,
                    CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c
                FROM
                    Pricebook_Entry_Period__c
                //WHERE
                //    Product__c IN: mapProductIdToAccountPlanList.keySet()
            ];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }

        System.assert(mapIdToPBEPInstance.size() > 0);

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId,Product2.RecordTypeId  from OpportunityLineItem].size(), 'Initial Deal Products');

        for (OpportunityLineItem dealProductInstance : [Select Id,OpportunityId,Initial_Quantity__c,Target_Quantity__c,Replen_Quantity__c, Product2.RecordTypeId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assertEquals(1, dealProductInstance.Quantity);
            System.assertEquals(0, dealProductInstance.Target_Quantity__c);
            if (dealProductInstance.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProductInstance.Initial_Quantity__c);
                System.assertEquals(null, dealProductInstance.Replen_Quantity__c);
            } else {
                System.assertEquals(null, dealProductInstance.Initial_Quantity__c);
                System.assertEquals(1, dealProductInstance.Replen_Quantity__c);
            }
        }
        // Verify Schedules are created for Digital and Physical Deal Products
        System.assertEquals(5,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(),
            lstProductsToBeProcessed,
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no new Deals are created as no valid PBEP found
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');

        // Verify no new Deal Product is cloned and  modified
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Manually_Schedule__c, Product2.RecordTypeId,Product2.Type__c, Quantity,NR_Deal_Product_Unique_Key__c,Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        // Verify no digital deal products are cloned and created.
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(3, clonedDealProductsCount);

        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity from OpportunityLineItemSchedule];
        System.assertEquals(5, schedules.size(), 'No Change');
    }

    /*public static testMethod void NegativeTest_Schedules_Insert_Fail_Test(){
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
            tw.lstTargets[i].RecordTypeId = rtTarget;
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
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
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
            if (p.RecordTypeId == digitalProductRecordTypeId) {
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
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(CRM_AutoPhysicalNRDealCreateService_Test.fetchSoldToAccounts(), lstProductsToBeProcessed, productAndAccountIdSet , mapIdToPBEPInstance, setProcessedProductIds );
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
            if (dealProduct.Product2.RecordTypeId == digitalProductRecordTypeId) {
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
    }*/

   public static testMethod void NegativeTest_Deal_Insert_Fail_With_Scenario1_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Map<String, PriceBook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, PriceBook_Entry_Period__c>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        delete tw.lstOpportunity;
        Set<String> productAndAccountIdSet = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for(Integer i = 0; i < tw.lstProduct.size() ; i++){
            System.assert(tw.lstProduct[i].NR_Product_Created__c);
            accountPlanUniqueKey.add(tw.lstProduct[i].Id + '-' + tw.lstAccounts[i].Id);
        }

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Previous_Start_Date__c, List_Price__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
        Account_Price__c,Start_Date__c,Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,Material_Price_Group__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            tw.lstAccounts,
            automaticNRDealCreationBatch.getNRProducts(),
            //productAndAccountIdSet ,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        
        // Verify only one deal created for Games Digital as Games Owner present. Video Digital Deal not created as Account Owner not specified in Account Query
        //System.assertEquals(1,[Select Id, Name from Opportunity].size(), 'New Deals');
        //System.assert([Select Id, Name from Opportunity][0].Name.contains('Games'));
        //System.assertEquals(1,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products'); 
    }
    /*public static testMethod void NegativeTest_Deal_Product_Insert_Fail_With_Scenario1_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreateService_Test.CRM_AutoPhysicalNRDealCreationService_TestWrapper tw =
            CRM_AutoPhysicalNRDealCreateService_Test.createData();
        Set<String> productAndAccountIdSet = new Set<String>();
        Map<String, Pricebook_Entry_Period__c> mapIdToPBEPInstance = new Map<String, Pricebook_Entry_Period__c>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Set<String> accountPlanUniqueKey = new Set<String>();
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        for(Integer i = 0; i < tw.lstProduct.size() ; i++){
            System.assert(tw.lstProduct[i].NR_Product_Created__c);
            accountPlanUniqueKey.add(tw.lstProduct[i].Id + '-' + tw.lstAccounts[i].Id);
        }

        List<Pricebook_Entry_Period__c> lstPBEP = [SELECT Id, Previous_Start_Date__c, List_Price__c,Suggested_Price__c,
        Account_Price__c,Start_Date__c,Process_NR_Batch__c,New_Release__c, End_Date__c, Product__c,
        Price_Book__c, CurrencyIsoCode, Product__r.RecordTypeId,Minimum_Price__c, Retail_Price__c FROM Pricebook_Entry_Period__c];
        for (Integer i=0 ; i<lstPBEP.size() ; i++) {
            if (lstPBEP[i].Product__r.RecordTypeId == digitalProductRecordTypeId && lstPBEP[i].New_Release__c == true && lstPBEP[i].Process_NR_Batch__c == true) {
                String strKey = lstPBEP[i].Product__c + '-' + lstPBEP[i].Price_Book__c + '-' + lstPBEP[i].CurrencyIsoCode;
                if (!mapIdToPBEPInstance.containsKey(strKey)) {
                    mapIdToPBEPInstance.put(strKey, lstPBEP[i]);
                }
            }
        }
        System.debug('lstPBEP::'+lstPBEP);

        Test.startTest();
        CRM_AutoDigitalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoDigitalNRDealCreationBatch();
        List<Product2> lstProductsToBeProcessed = automaticNRDealCreationBatch.getNRProducts();
        System.debug('--mapIdToPBEPInstance-in test->'+mapIdToPBEPInstance);
        CRM_AutoDigitalNRDealCreationService.processNRProductRecords(
            tw.lstAccounts,
            lstProductsToBeProcessed,
            productAndAccountIdSet,
            mapIdToPBEPInstance,
            setProcessedProductIds
        );
        Test.stopTest();

        // Verify no Deal Products created as no proper query fetched for existing deals
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Updated Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');
    }*/

}//End of Class