/*
   @Author: Cognizant Team   
   @name: CRM_AutoPhysicalNRDealCreateService_Test
   @CreateDate: 12 Jan 2016
   @Description: Test/ Code Coverage for 'CRM_AutoPhysicalNRDealCreationService' 
   @Version <1.0>
   @reference: classes: CRM_AutoPhysicalNRDealCreationService
*/
/*======================================================================================*/

@isTest
public class CRM_AutoPhysicalNRDealCreateService_Test{

    /*Create Dummy Data Using CRM_TestDataFactory Class*/
    static Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    static Id rtAccShipTo =  CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
    static Id rtTarget = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
    static Id digitalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
    static Id physicalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
    static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    static Id physicalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;

    public static CRM_AutoPhysicalNRDealCreationService_TestWrapper createData(){

        createBatchNotificationRecipientsCustomSettingRecord();

        List<Account> lstAccounts = createAccountsForNRBatch(5);
        System.debug('lstAccounts::'+lstAccounts.size());
        
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        
        List<Product2> lstProduct = createProductsForNRBatch(lstProGrp,lstAccounts);
        System.debug('lstProduct::'+lstProduct.size());
        for (Product2 prod : lstProduct) {
            prod.Release_Category__c = null;
        }
        update lstProduct;
        
        List<Target__c> lstTargets = createTargetsForNRBatch(lstAccounts, lstProduct, lstProGrp);
        System.debug('lstTargets::'+lstTargets.size());
        
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry);

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);

        List<Opportunity> lstOpportunity =
            createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);

        System.debug('lstOpportunity::'+lstOpportunity); 

        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = new CRM_AutoPhysicalNRDealCreationService_TestWrapper();
        tw.lstAccounts = lstAccounts;
        tw.lstOpportunity = lstOpportunity;
        tw.lstTargets = lstTargets;
        tw.lstProduct = lstProduct;
        tw.lstPriceBookEntry = lstPriceBookEntry;
        tw.lstPriceBookEntryPeriod = lstPriceBookEntryPeriod;
        
        return tw;
    }
    public static List<Account> fetchSoldToAccounts(){
    String queryString = 'SELECT ' + 
                'Id, ' +
                'Name, ' +
                'Sales_Organization__c, ' +
                'Price_Book__c, ' +
                'CurrencyIsoCode, ' +
                'Games_Digital__c, ' +
                'Video_Digital__c, ' +
                'Games_Physical__c, ' +
                'Video_Physical__c, ' +
                'OwnerId, '+
                'Status__c, ' +
                'Owner_Games__c, '+
                'Owner_Games__r.IsActive, '+
                ' Music_Physical__c, Music_Digital__c, Storefront__c, ' + // US JAPAN : 561
                'Digital_Country_Code__c,' +
                '(' +
                    'SELECT ' +
                        'Id, ' +
                        'Name, ' +
                        'RecordTypeId, '+
                        'Start_Date__c, ' +
                        'CloseDate, ' +
                        'AccountID, ' +
                        'Pricebook2ID, ' +
                        'StageName, ' +
                        'NR_Deal_Unique_Key__c, '+
                        'Product_Type__c, '+
                        'CurrencyIsoCode, ' +
                        'OwnerId, '+
                        'Account.OwnerId, '+
                        'Owner.IsActive, '+
                        'Account.Owner_Games__r.IsActive '+
                    'FROM ' +
                        'Opportunities' +
                '), ' + 
                '(' +
                        'SELECT' +
                            ' Id, Customer__c, Country_Plan__c, Country_Plan__r.NR_Product__c, Country_Plan__r.RecordTypeId,Country_Plan__r.NR_Product__r.SAP_Sales_Org__c,' +
                            // France Changes
                            // ' Country_Plan__r.Release_Type__c, 
                            ' Target_Quantity__c, ' +
                            ' PublishedTarget__c, Target_Revenue_Has_Changed__c, NR_Version__c, Customer__r.Video_Digital__c,Customer__r.Games_Digital__c, Customer__r.Music_Digital__c, ' +
                            ' Customer__r.Sales_Organization__c, Customer__r.Digital_Country_Code__c, Country_Plan__r.NR_Product__r.RecordTypeId' +
                        ' FROM Account_Plans__r' +
                        ' WHERE Country_Plan__c != null AND Country_Plan__r.NR_Product__c != null' +
                        //' AND Country_Plan__r.NR_Product__r.SAP_Sales_Org__c != null' +
                        ' AND Country_Plan__r.NR_Product__r.RecordTypeId != null' +
                        // Commented Germany Code Changes
                        //' AND Customer__r.Sales_Organization__c NOT IN: \'' + CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS + '\'' +
                        ' AND Customer__r.Sales_Organization__c NOT IN (\'' + String.join(new List<String>(CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS), '\',\'') + '\') ' +
                        //' AND Country_Plan__r.NR_Product__r.SAP_Sales_Org__c != \'' + CRM_AppConstants.TERRITORY_GERMANY_CODE + '\'' +
                        ' AND Country_Plan__r.RecordTypeId = \'' + CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE + '\'' +
                        ' ORDER BY CreatedDate ASC' +
                    ' )' +
                    //Commented Germany Code Changes
                    ' ,(' +
                        ' SELECT' +
                            ' Id, Account__c, Product__c, Target__c, Target_Units__c, Target_Revenue_Has_Changed__c, Product__r.RecordTypeId,' +
                            ' Account__r.Video_Digital__c, Account__r.Games_Digital__c, Account__r.Digital_Country_Code__c,' +
                            ' NR_Version__c, Account__r.Sales_Organization__c, Product__r.SAP_Sales_Org__c, Calc_End_Date__c,Calc_Start_Date__c,Account_Plan_Lookup__c ' +
                        ' FROM Targets__r WHERE Product__c != null AND Target__c != null' +
                        ' AND Account__r.Sales_Organization__c  IN (\'' + String.join(new List<String>(CRM_AppConstants.NR_WITH_GERMANY_LIKE_SALES_ORGS), '\',\'') + '\') ' +
                        ' ORDER BY LastModifiedDate DESC' +
                    ')' +
            'FROM ' +
                'Account '+
            'WHERE ' +
                ' (RecordTypeId = \'' + rtAcc + '\' ' +
                ' OR RecordTypeId = \'' + rtAccShipTo + '\') ' +
                ' AND Status__c = \'' + CRM_AppConstants.ACCOUNT_STATUS_ACTIVE + '\' ' +
                ' AND (' +
                    'Games_Digital__c = true ' +
                    'OR Video_Digital__c = true ' +
                    'OR Games_Physical__c = true ' +
                    'OR Video_Physical__c = true ' +
                    'OR Music_Physical__c = true ' +
                    'OR Music_Digital__c = true ' +
                ')'+
                ' AND (Sales_Organization__c != null OR Digital_Country_Code__c != null)';
        System.debug('---queryString----->'+queryString);
        return Database.query(queryString);
    }

    public static void createBatchNotificationRecipientsCustomSettingRecord() {
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
        insert userList;
        System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c].size());
    }

    public static testMethod void Street_Date_Changed_And_Target_Revenue_Changed_With_No_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+40;
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
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;
        
        //Setting up the target data
        for(Integer i=0 ; i<tw.lstTargets.size() ; i++){
            //tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            //tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
            //tw.lstTargets[i].Target_Revenue_Has_Changed__c = true;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = (System.today()-60).toStartOfMonth();
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today() +100;
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }
        update tw.lstPriceBookEntryPeriod;
        System.debug('tw.lstPriceBookEntryPeriod::'+tw.lstPriceBookEntryPeriod);
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProduct.Manually_Schedule__c);
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify 2 physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : [Select Id,OpportunityId,Target_Quantity__c, Product2.Type__c, Manually_Schedule__c, NR_Deal_Product_Unique_Key__c,Quantity  from OpportunityLineItem]) {
            System.assert(dealProduct.Manually_Schedule__c);
            if (dealProduct.Product2.Type__c.contains('Physical')) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);
    }

   public static testMethod void NR_Product_Creation_With_No_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        delete tw.lstOpportunity;
        Set<String> setProductAndAccountId = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(2,[Select Id, Name from Opportunity].size(), 'New Deals');
        System.assertEquals(2,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');
        List<OpportunityLineItem> dealProducts = [Select Id,Product2.RecordTypeId, P_L_Quantity__c, Target_Quantity__c, Quantity, OpportunityId  from OpportunityLineItem];
        System.assertEquals(2, dealProducts.size(), 'Updated Deal Products');
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(3, dealProduct.Target_Quantity__c);
                System.assertEquals(null, dealProduct.P_L_Quantity__c);
            }
        }
    }

    public static testMethod void NR_Product_Creation_With_Existing_Deal_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Updated Deals');
        System.assertEquals(2,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');
    }

     public static testMethod void Street_Date_Changed_With_Existing_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
           p.Previous_Street_Date__c = system.today()+1;
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
            tw.lstTargets[i].RecordTypeId = rtTarget;
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
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify 2 physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        Date oldStreetDate = system.today()+1;
        Integer numberDaysDifference = oldStreetDate.daysBetween(system.today());
        System.debug('---numberDaysDifference-->'+numberDaysDifference);

        Date nweStreetDate = system.today()+40;
        Date newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        System.debug('--newScheduleDate-->'+newScheduleDate);
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId) {
                System.assertEquals(21, dealProduct.Quantity);
                //System.assertEquals(0, dealProduct.Target_Quantity__c);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
                System.assertEquals(21, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);
    }

    public static testMethod void Street_Date_Changed_With_No_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = true;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstPriceBookEntry[i].Product2Id;
        }
        insert lstDealProduct;

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
        for (OpportunityLineItem dealProducts : [Select Id,Target_Quantity__c,OpportunityId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assert(dealProducts.Manually_Schedule__c);
            System.assertEquals(1, dealProducts.Quantity);
            System.assertEquals(0, dealProducts.Target_Quantity__c);
        }
        System.assertEquals(0,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,Target_Quantity__c, OpportunityId, Manually_Schedule__c,Product2.Type__c, Quantity,NR_Deal_Product_Unique_Key__c,Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(5,dealProducts.size(), 'New Deal Products');

        // Verify 2 physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : dealProducts) {
            System.assert(dealProduct.Manually_Schedule__c);
            if (dealProduct.Product2.Type__c.contains('Physical')) {
                System.assertEquals(3, dealProduct.Target_Quantity__c);
                System.assertEquals(1, dealProduct.Quantity);
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);

        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity from OpportunityLineItemSchedule];
        System.assertEquals(0, schedules.size(), 'New Deal Product Schedule');
    }

    public static testMethod void Target_Revenue_Has_Changed_With_No_Schedules(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
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
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
            //tw.lstTargets[i].Target_Revenue_Has_Changed__c = true;
            //System.debug('tw.lstTargets[i]::'+tw.lstTargets[i].Calc_Start_Date__c);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

         List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

        List<OpportunityLineItem> lstDealProducts = [Select Id, Target_Quantity__c, OpportunityId, Manually_Schedule__c, Quantity,Account_Price__c , NR_Deal_Product_Unique_Key__c from OpportunityLineItem];
        System.assertEquals(5, lstDealProducts.size());
        for(OpportunityLineItem dealProductBefore : lstDealProducts){
            System.assertEquals(1, dealProductBefore.Quantity);
            System.assertEquals(0, dealProductBefore.Target_Quantity__c);
            System.assert(dealProductBefore.Manually_Schedule__c);
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        List<OpportunityLineItem> lstUpdatedDealProducts = [Select Id,Target_Quantity__c, OpportunityId, Product2.Type__c, Manually_Schedule__c, Quantity,Account_Price__c,NR_Deal_Product_Unique_Key__c from OpportunityLineItem];
        System.assertEquals(5, lstUpdatedDealProducts.size());

        Integer physicalDealProductCount = 0;
        for(OpportunityLineItem dealProduct : lstUpdatedDealProducts){
            System.assert(dealProduct.Manually_Schedule__c);
            if (dealProduct.Product2.Type__c.contains('Physical')) {
                System.debug('dealProduct::::'+dealProduct);
                System.assertEquals(20.00, dealProduct.Account_Price__c, 'Updated Account Price');
                System.assertEquals(1, dealProduct.Quantity, 'Should not change');
                System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity = Target Revenue / Account Price');
                physicalDealProductCount++;
            } else {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(0, dealProduct.Target_Quantity__c);
            }
        }
        System.assertEquals(2, physicalDealProductCount);
    }

    public static testMethod void Target_Revenue_Has_Changed_With_Auto_Generated_Schedules(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
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
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Target_Quantity__c = 1;
            lstDealProduct[i].Replen_Quantity__c = lstDealProduct[i].Quantity;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,OpportunityId,Initial_Quantity__c,Replen_Quantity__c, Product2.RecordTypeId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(1, dealProduct.Target_Quantity__c);
            System.assertEquals(null, dealProduct.Initial_Quantity__c);
            System.assertEquals(1, dealProduct.Replen_Quantity__c);
            /*if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(null, dealProduct.Initial_Quantity__c);
                System.assertEquals(1, dealProduct.Replen_Quantity__c);
            } else {
                System.assertEquals(null, dealProduct.Initial_Quantity__c);
                System.assertEquals(1, dealProduct.Replen_Quantity__c);
            }*/
        }

        // Verify 1 Schedule for each digital deal product is created
        // No Schedule is created for Physical deal product as the value is added in Initial Quantity
        System.assertEquals(5, [Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'New Deal Product Schedule');

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
            //tw.lstTargets[i].Target_Revenue_Has_Changed__c = true;
            //System.debug('tw.lstTargets[i]::'+tw.lstTargets[i].Calc_Start_Date__c);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        Integer physicalDealProductCount = 0;
        Integer digitalDealProductCount = 0;
        // Verify target Revenue is  changed for physical deal products with automatic schedules
        for(OpportunityLineItem dealProduct : [Select Id, OpportunityId,Target_Quantity__c, Quantity, Product2.Type__c, Initial_Quantity__c, Replen_Quantity__c from OpportunityLineItem]){
            if (dealProduct.Product2.Type__c.contains('Physical')) {
                System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Quantity, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Updated Quantity');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Updated Quantity');
                physicalDealProductCount++;
            } else {
                digitalDealProductCount++;
                System.assertEquals(1, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Quantity, 'Quantity not Updated');
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Quantity not Updated');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity not Updated');
            }
        }
        System.assertEquals(2, physicalDealProductCount);
        System.assertEquals(3, digitalDealProductCount);
    }

    public static testMethod void Target_Revenue_Has_Changed_With_Manual_Schedules(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
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
            //tw.lstTargets[i].Target_Revenue_Has_Changed__c = true;
            //System.debug('tw.lstTargets[i]::'+tw.lstTargets[i].Calc_Start_Date__c);
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');
        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify target Revenue is not changed for deal products with schedules
        for(OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId, OpportunityId, Quantity,Initial_Quantity__c, Replen_Quantity__c from OpportunityLineItem]){
            if (dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId) {
                System.assertEquals(21.00, dealProduct.Quantity, 'Updated Quantity');
                //System.assertEquals(0, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(10, dealProduct.Target_Quantity__c, 'Updated Quantity');
            }
/*            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Initial_Quantity__c);
                System.assertEquals(null, dealProduct.Replen_Quantity__c);
            } else {
                System.assertEquals(null, dealProduct.Initial_Quantity__c);
                System.assertEquals(1, dealProduct.Replen_Quantity__c);
            }*/
        }
    }

     public static testMethod void Street_Date_Changed_And_Target_Revenue_Changed_With_Existing_Schedules_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
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
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

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

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify quantity is same after streetDate is changed as existing Schedules are also cloned
        for(OpportunityLineItem dealProduct : [Select Id,Product2.RecordTypeId, Manually_Schedule__c,Target_Quantity__c, Product2.Type__c, OpportunityId, Quantity from OpportunityLineItem]){
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(21.00, dealProduct.Quantity, 'Quantity based on manually added schedules');
                //System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity based on manually added schedules');
                System.assertEquals(10, dealProduct.Target_Quantity__c, 'Quantity based on manually added schedules');
            }
        }

        // Verify Schedules are cloned only for 2 physical deal products whose streetDate is changed
        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId,Quantity from OpportunityLineItemSchedule];
        System.assertEquals(5, schedules.size(), 'New Deal Product Schedule');
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP )
           2. Deals -> D0 -> For A0 -> (GP, Start Date = System.Today())
           3. Deal Product -> D0 (DP0 with P0 batch created having unique Key)
      2. Product ->
           1. P0 (GP, Street Date = System.today()) -> Valid Target with Revenue Changed
      3. Result
           1. P0
                - Even if Street Date is changed, it will find the existing deal D0 and check for Deal Product in that.
                - As the Deal PRoduct is already present for the valid deal it will only process for Target Revenue change
                  and update the Quantity of the existing deal product
     */
    public static testMethod void Street_Date_Changed_And_Target_Revenue_Changed_With_Existing_Deal_Product() {
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        //Method to create Dummy Data
        List<Account> lstAccounts = createAccountsForNRBatch(1);
        System.assertEquals(1, lstAccounts.size());

        // Setting Up the Account Data
        Account soldToAccount = lstAccounts[0];

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

        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(), false);
        System.assertEquals(1, lstProduct.size());
        for(Product2 p : lstProduct){
           p.Street_Date__c = system.today()+1;
           p.Street_Date_Has_Changed__c = true;
           p.CurrencyIsoCode = 'USD';
           p.NR_period_weeks__c = 1;
           p.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
           p.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
           p.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
           p.Type__c = 'Games Physical';
           p.Local_Title__c = lstLocaTitle[0].Id;
           p.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        insert lstProduct;
        lstProduct[0].NR_Product_Created__c = false;
        update lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        System.assertEquals(1, lstProduct.size());
        System.debug('lstProduct::'+lstProduct.size());

        List<Target__c> lstTargets = createTargetsForNRBatch(lstAccounts, lstProduct, lstProGrp);
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
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry);

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.assertEquals(1, lstPriceBookEntryPeriod.size());
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);

        List<Opportunity> lstOpportunity =
            createDealsForNRBatch(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
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
        System.assertEquals(null, lstDealProduct[0].Target_Quantity__c);
        System.assertEquals(lstOpportunity[0].Id, lstDealProduct[0].OpportunityId);

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify even if street Date is changed no new Deal Product is created but the existing one Quantity is recalculated due to Revenue change
        List<OpportunityLineItem> fetchedDealProducts = [SELECT Id, Quantity, Target_Quantity__c, OpportunityId FROM OpportunityLineItem];
        System.assertEquals(1, fetchedDealProducts.size());
        System.assertEquals(1, fetchedDealProducts[0].Quantity);
        System.assertEquals(10, fetchedDealProducts[0].Target_Quantity__c);
        System.assertEquals(lstOpportunity[0].Id, fetchedDealProducts[0].OpportunityId);
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP )
           2. Deals -> For A0
                    1. D0 (GP, Start Date = System.Today() -> Manual Deal with Manual Deal Product (No Unique Key))
                    2. D1 (GP, Start Date = System.Today() -> NR Deal Changed To Planned)
                    3. D2 (GP, Start Date = System.today()+10 -> NR Deal Start Date Changed)
                    4. D3 (GP, Start Date = System.today() -> NR Deal with NR Deal Product Changed To Planned)
                    5. D4 (GP, Start Date = System.today() -> Valid NR Deal with no Deal Products)
           3. Deal Product ->
                    1. D0 (DP0 with P0 -> No NR Unique Key)
                    2. D3 (DP1 with P0 -> With NR Unique Key)
      2. Product -> P0 (GP, Street Date = system.today() + 1) -> valid Target present
      3. Result
           1. P0 -> No new Deal / Deal Product is created
     */
    public static testMethod void NR_Product_Creation_For_Multiple_Deals(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        //Method to create Dummy Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        
        for(Account a: lstAccounts){
            a.recordTypeId = rtAcc;
            a.CurrencyIsoCode = 'USD';
        }
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        //lstAccounts[0].Owner_Games__c = 
        insert lstAccounts;
        System.debug('lstAccounts::'+lstAccounts.size());

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
        lstProduct[0].Type__c = 'Games Physical';
        lstProduct[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
        lstProduct[0].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        lstProduct[0].Street_Date__c = system.today()+1;
        lstProduct[0].NR_Product_Created__c = true;
        lstProduct[0].NR_period_weeks__c = 1;
        lstProduct[0].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        lstProduct[0].Street_Date_Has_Changed__c = false;
        lstProduct[0].CurrencyIsoCode = 'USD';
        lstProduct[0].Local_Title__c = lstLocaTitle[0].Id;
        lstProduct[0].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        System.debug('lstProduct::'+lstProduct.size());

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 200;
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = lstProduct[i].id;
            lstTargets[i].RecordTypeId = rtTarget;
        } 
        insert lstTargets;
        System.debug('lstTargets::'+lstTargets.size());

        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry.size());

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        List<Opportunity> lstOpportunity =
            createMultipleDealsForSingleAccountAndProduct(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,5,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
        System.debug('lstOpportunity::'+lstOpportunity);
        lstOpportunity[0].NR_Deal_Unique_Key__c = null;
        lstOpportunity[0].Name = 'Manual Deal with Manual Deal Product';
        lstOpportunity[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[1].Name = 'NR Deal Changed To Planned';
        lstOpportunity[2].Start_Date__c = system.today()+10;
        lstOpportunity[2].Promo_Start_Date__c = system.today()+10;
        lstOpportunity[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[2].Name = 'NR Deal Start Date Changed';
        lstOpportunity[3].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[3].Name = 'NR Deal with NR Deal Product Changed To Planned';
        lstOpportunity[4].Name = 'Valid NR Deal with no Deal Products';
        update lstOpportunity;
        lstOpportunity[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        update lstOpportunity;
        System.debug('lstOpportunity::'+lstOpportunity.size());

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{lstOpportunity[0],lstOpportunity[3]}, 1, false);

        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            if(lstDealProduct[i].OpportunityId == lstOpportunity[3].Id)
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id;
        }
        insert lstDealProduct;

        // Verify existing deal and Deal products are created properly
        for (Opportunity opportunityInstance : [SELECT Id, Name, (SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity]) {
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

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify batch results
        for (Opportunity opportunityInstance : [SELECT Id, Name, (SELECT Id,Quantity,Target_Quantity__c, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity]) {
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
            }
        }
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP )
           2. Deals -> For A0
                    1. D0 (GP, Start Date = System.Today() -> Manual Deal with Manual Deal Product (No Unique Key))
                    2. D1 (GP, Start Date = System.Today() -> NR Deal Changed To Planned)
                    3. D2 (GP, Start Date = System.today()+10 -> NR Deal Start Date Changed)
                    4. D3 (GP, Start Date = System.today() -> NR Deal with NR Deal Product Changed To Planned)
                    5. D4 (GP, Start Date = System.today() -> Valid NR Deal with no Deal Products)
           3. Deal Product ->
                    1. D0 (DP0 with P0 -> No NR Unique Key)
                    2. D3 (DP1 with P0 -> With NR Unique Key)
      2. Product -> P0 (GP, Street Date = system.today() + 1) -> valid Target present
      3. Result
           1. P0 -> No new Deal / Deal Product is created and no existing deal Product gets deleted
     */
    public static testMethod void Street_Date_Changed_With_Planned_Deal_Stage_For_Multiple_Deals(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        //Method to create Dummy Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        
        for(Account a: lstAccounts){
            a.recordTypeId = rtAcc;
            a.CurrencyIsoCode = 'USD';
        }
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        //lstAccounts[0].Owner_Games__c = 
        insert lstAccounts;
        System.debug('lstAccounts::'+lstAccounts.size());

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
        lstProduct[0].Type__c = 'Games Physical';
        lstProduct[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
        lstProduct[0].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        lstProduct[0].Street_Date__c = system.today()+1;
        lstProduct[0].NR_Product_Created__c = true;
        lstProduct[0].NR_period_weeks__c = 1;
        lstProduct[0].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        lstProduct[0].CurrencyIsoCode = 'USD';
        lstProduct[0].Local_Title__c = lstLocaTitle[0].Id;
        lstProduct[0].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert lstProduct;
        lstProduct[0].NR_Product_Created__c = false;
        lstProduct[0].Street_Date__c = system.today()+40;
        update lstProduct[0];
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        System.debug('lstProduct::'+lstProduct.size());

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 200;
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = lstProduct[i].id;
            lstTargets[i].RecordTypeId = rtTarget;
        } 
        insert lstTargets;
        System.debug('lstTargets::'+lstTargets.size());

        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry.size());

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        List<Opportunity> lstOpportunity =
            createMultipleDealsForSingleAccountAndProduct(CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,5,false), lstAccounts, lstProduct, lstPriceBookEntryPeriod);
        System.debug('lstOpportunity::'+lstOpportunity);
        lstOpportunity[0].NR_Deal_Unique_Key__c = null;
        lstOpportunity[0].Name = 'Manual Deal with Manual Deal Product';
        lstOpportunity[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[1].Name = 'NR Deal Changed To Planned';
        lstOpportunity[2].Start_Date__c = system.today()+10;
        lstOpportunity[2].Promo_Start_Date__c = system.today()+10;
        lstOpportunity[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[2].Name = 'NR Deal Start Date Changed';
        lstOpportunity[3].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        lstOpportunity[3].Name = 'NR Deal with NR Deal Product Changed To Planned';
        lstOpportunity[4].Start_Date__c = system.today()+40;
        lstOpportunity[4].Promo_Start_Date__c = system.today()+40;
        lstOpportunity[4].CloseDate = system.today()+60;
        lstOpportunity[4].Promo_End_Date__c = system.today()+60;
        lstOpportunity[4].Name = 'Valid NR Deal with no Deal Products';
        update lstOpportunity;
        lstOpportunity[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
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

        // Verify existing deal and Deal products are created properly
        for (Opportunity opportunityInstance : [SELECT Id, Name, (SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity]) {
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

        List<Product2> lstProducts = [SELECT Id, NR_Product_Created__c,RecordTypeId, Street_Date_Has_Changed__c FROM Product2];
        for(Integer i = 0; i < lstProducts.size() ; i++){
            if (lstProducts[i].RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(!lstProducts[i].NR_Product_Created__c);
                System.assert(lstProducts[i].Street_Date_Has_Changed__c);
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify no new Deal / Deal Products created as existing NR deal / Deal present with non NR Default Stage
        List<Opportunity> dealsAfterBatchRun = [SELECT Id, Name, (SELECT Id, NR_Deal_Product_Unique_Key__c, Quantity FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(5, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItem];
        System.assertEquals(2, dealProductsAfterBatchRun.size());

        for (Opportunity opportunityInstance : [SELECT Id, Name, (SELECT Id,Quantity, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity]) {
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
            }
        }
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP , VP), A1 (Ship To), A2 (Ship To)
           2. Deals ->
                  A0
                    -> D0 (GP, Start Date = System.Today() - 30, Maual Created with Batch DP0)
                    -> D1 (GP, Start Date = System.Today(), Batch Created with Batch DP1)
                    -> D2 (VP, Start Date = System.Today(), Batch Created with Batch DP2)
                  A1 -> D3;
                  A2 -> D4, D5
           3. Deal Product -> D0 (DP0 with P0), D1 (DP1 with P0), D2( DP2 with P1)
      2. Product ->
           1. P0 (GP, Street Date = system.today()) -> No Valid Target
           2. P1 (VP, Street Date = system.today() + 60) -> No Valid Target
           3. P2 (VP, Street Date = system.today() + 60) -> Valid Target present
      3. Result
           1. P0 -> Nothing happens to Deal Products related to P0 as those are already existing DP with Batch generated Unique Key
           2. P1 -> Create new Deal D6 and Clone DP2 for P1 from D1 and add in this new Deal D6
           3. P2 -> Take the newly created Deal D6 while processing P1 and insert new DP3 for P2 in the same deal D6
     */
    private static testMethod void Street_Date_Changed_For_Multiple_Deals(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(3,false);

        // First account is Sold To with Type Games Physical and Video Physical
        Account soldToAccountGP = lstAccounts[0];
        lstAccounts[0].recordTypeId = rtAcc;
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Video_Physical__c = true;
        lstAccounts[0].CurrencyIsoCode = 'USD';

        // Next 2 Accounts are Ship To Accounts with no Type set
        lstAccounts[1].recordTypeId = rtAccShipTo;
        lstAccounts[2].recordTypeId = rtAccShipTo;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert lstAccounts;
        System.assertEquals(3, lstAccounts.size());

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

        // Set Up 3 Products data
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
        for(Integer i=0 ;i<lstProduct.size();i++){
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            if (i == 0) {
                // Keep the Street Date of P0 in same month as of deal created
                lstProduct[i].Street_Date__c = System.today() + 1;
            } else {
                // P1 and P2 should lie in different month so that they will create a new deal and create 2 deal products in same deal
                lstProduct[i].Street_Date__c = System.today()+60;
            }
            lstProduct[i].NR_Product_Created__c = false;
            lstProduct[i].Street_Date_Has_Changed__c = true;
            lstProduct[i].CurrencyIsoCode = 'USD';
            lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        }
        System.assertEquals(3, lstProduct.size());
        lstProduct[0].Type__c = 'Games Physical';
        lstProduct[0].Local_Title__c = lstLocaTitle[0].Id;
        lstProduct[0].NR_period_weeks__c = 1;
        lstProduct[0].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        lstProduct[0].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        Product2 p0_GamesPhysical = lstProduct[0];

        lstProduct[1].Type__c = 'Video Physical';
        lstProduct[1].NR_period_weeks__c = 1;
        lstProduct[1].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        lstProduct[1].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        Product2 p1_VideoPhysical = lstProduct[1];

        lstProduct[2].Type__c = 'Video Physical';
        lstProduct[2].NR_period_weeks__c = 1;
        lstProduct[2].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        lstProduct[2].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        Product2 p2_VideoPhysical = lstProduct[2];
        insert lstProduct;
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        for(Integer i=0 ;i<lstProduct.size();i++){
            lstProduct[i].NR_Product_Created__c = false;
        }
        update lstProduct;

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,new List<Product2>{p2_VideoPhysical}, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, new List<Account> {soldToAccountGP}, true);

        // Create Multiple Targets for p2_GamesPhysical
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(new List<Account> {soldToAccountGP, soldToAccountGP, soldToAccountGP} , lstProGrp , lstAccountPlan, false);
        System.assertEquals(3, lstTargets.size());
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Product__c = p2_VideoPhysical.id;
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
        lstOpportunity[0].AccountId = soldToAccountGP.Id;
        lstOpportunity[0].Start_Date__c = system.today() - 130;
        lstOpportunity[0].Promo_Start_Date__c = system.today() - 130;
        lstOpportunity[0].CloseDate = system.today() - 125;
        lstOpportunity[0].Promo_End_Date__c = system.today() - 125;
        lstOpportunity[0].Name = 'Manual created Deal 1 with Unique Key with Deal Products for Product 1';
        lstOpportunity[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        lstOpportunity[0].CurrencyIsoCode = 'USD';
        /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() - 30).year(),
                    (system.today() - 30).month(),
                    (system.today() - 30).day()
                );
        String currentMonth1 = sDate1.format('MMM');*/
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today()-130).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        lstOpportunity[0].NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        lstOpportunity[0].Product_Type__c = 'Games Physical';
        lstOpportunity[0].RecordTypeId = physicalDealRecordTypeId;

        // Existing Deal with Deal Product for Games Physical Product (P0) to check nothing happens on Street Date change
        lstOpportunity[1].AccountId = soldToAccountGP.Id;
        lstOpportunity[1].Name = 'Batch created Deal 2 with Unique Key with Deal Products for Product 1';
        lstOpportunity[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        lstOpportunity[1].CurrencyIsoCode = 'USD';
        /*Datetime sDate2 =
                datetime.newInstance(
                    (system.today() + 1).year(),
                    (system.today() + 1).month(),
                    (system.today() + 1).day()
                );
        String currentMonth2 = sDate2.format('MMM');*/
        Integer currentQtr2 =
            Decimal.valueOf(
                (system.today()+1).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod2 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr2;
        lstOpportunity[1].NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod2+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        lstOpportunity[1].Product_Type__c = 'Games Physical';
        lstOpportunity[1].RecordTypeId = physicalDealRecordTypeId;

        // Existing Deal for Video Physical Product (P1) to check Cloning of deal Product on Street Date change
        lstOpportunity[2].AccountId = soldToAccountGP.Id;
        lstOpportunity[2].Name = 'Batch created Deal 3 with Unique Key with Deal Products for Product 2';
        lstOpportunity[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        lstOpportunity[2].CurrencyIsoCode = 'USD';
        lstOpportunity[2].NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod2+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        lstOpportunity[2].Product_Type__c = p1_VideoPhysical.Type__c;
        lstOpportunity[2].RecordTypeId = physicalDealRecordTypeId;
        insert lstOpportunity;

        // Setting up 1 Price Book Entry record for each created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(3, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = createPriceBookEntryPeriodForNRBatch(lstPriceBookEntry, lstProduct);
        System.assertEquals(3, lstPriceBookEntryPeriod.size());
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            lstPriceBookEntryPeriod[i].Start_date__c = System.Today() - 180;
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }
        update lstPriceBookEntryPeriod;

        System.debug('--lstProduct->'+ [SELECT Id, street_Date__c FROM Product2]);
        System.debug('--lstPBEP->'+ [SELECT Id, Start_Date__c, End_Date__c FROM Pricebook_Entry_Period__c]);


        // Setting up Deal Product data such that batch deal Product already present for the above Deals D0, D1 and D2
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{lstOpportunity[0],lstOpportunity[1], lstOpportunity[2]}, 1, false);
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            System.debug('---lstDealProduct[i].OpportunityId-->'+lstDealProduct[i].OpportunityId);
            System.debug('---lstOpportunity[2].Id-->'+lstOpportunity[2].Id);
            if (lstDealProduct[i].OpportunityId == lstOpportunity[2].Id) {
                System.assertEquals(lstPriceBookEntry[1].Product2Id, p1_VideoPhysical.Id);
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p1_VideoPhysical.Id;
                lstDealProduct[i].PriceBookEntryId = lstPriceBookEntry[1].Id;
                lstDealProduct[i].Replen_Quantity__c = lstDealProduct[1].Quantity;
            }
            // Create 2 deal products with same Product
            else {
                System.assertEquals(lstPriceBookEntry[0].Product2Id, p0_GamesPhysical.Id);
                lstDealProduct[i].NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p0_GamesPhysical.Id;
                lstDealProduct[i].PriceBookEntryId = lstPriceBookEntry[0].Id;
            }
        }
        insert lstDealProduct;
        System.assertEquals(3, lstDealProduct.size());

        // Verify the data before runnig the batch
        for (Product2 product : lstProduct) {
            System.assert(product.Street_Date_Has_Changed__c, 'All Products should have Street Date changed as true');
        }

        for (Opportunity opportunityInstance : [SELECT Id, Name,NR_Deal_Unique_Key__c, (SELECT Id,Quantity,Product2Id, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity]) {
            if (opportunityInstance.Name == 'Manual created Deal 1 with Unique Key with Deal Products for Product 1') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Batch created Deal 2 with Unique Key with Deal Products for Product 1') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
                System.assert(opportunityInstance.OpportunityLineItems[0].NR_Deal_Product_Unique_Key__c != null);
            } else if (opportunityInstance.Name == 'Batch created Deal 3 with Unique Key with Deal Products for Product 2') {
                System.assertEquals(1, opportunityInstance.OpportunityLineItems.size());
            } else {
                // No deal products created for Ship To Account deals
                System.assertEquals(0, opportunityInstance.OpportunityLineItems.size());
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify batch results
        List<Opportunity> lstDealsFetched = [SELECT Id, Name,NR_Deal_Unique_Key__c, Product_Type__c, (SELECT Id,Quantity,Initial_Quantity__c, Replen_Quantity__c,Target_Quantity__c, Product2Id,Product2.RecordTypeId, NR_Deal_Product_Unique_Key__c FROM OpportunityLineItems) FROM Opportunity];
        // Verify one additional Deal created through Batch for Product P1 and P2
        System.assertEquals(7, lstDealsFetched.size());
        // Verify batch results
        Map<Id,OpportunityLineItem> mapDealsProductsFetched = new Map<Id,OpportunityLineItem>([SELECT Id,Quantity,Product2Id, NR_Deal_Product_Unique_Key__c,(SELECT Id, Quantity, Revenue,OpportunityLineItem.NR_Revenue_Recognition_Date__c, OpportunityLineItem.Product2.Street_Date__c,ScheduleDate, Description FROM OpportunityLineItemSchedules ORDER BY OpportunityLineItem.Opportunity.Sales_Organisation__c, ScheduleDate) FROM OpportunityLineItem]);
        System.assertEquals(4, mapDealsProductsFetched.size());
        /*Datetime sDate3 =
                datetime.newInstance(
                    (system.today() + 60).year(),
                    (system.today() + 60).month(),
                    (system.today() + 60).day()
                );
        String currentMonth3 = sDate3.format('MMM');*/
        Integer currentQtr3 =
            Decimal.valueOf(
                (system.today()+60).toStartOfMonth().month()
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
            else if (opportunityInstance.Name == 'New Releases Video Physical '+dealPeriod3+' '+(system.today() + 60).year()+' ' + soldToAccountGP.Name) {
                System.debug('--in if-22->');
                // 2 Deal Products created.
                System.assertEquals(p1_VideoPhysical.Type__c, opportunityInstance.Product_Type__c);
                System.assertEquals(2, opportunityInstance.OpportunityLineItems.size());
                for (OpportunityLineItem dealProduct : opportunityInstance.OpportunityLineItems) {
                    System.debug('-dealProduct-->'+dealProduct);
                    // 1. Verify if deal Product is created by cloning the deal Product for Product 1 from Deal 3 due to Street Date change
                    if (dealProduct.Product2Id == p1_VideoPhysical.Id) {
                        System.debug('--1->');
                        System.assert(dealProduct.NR_Deal_Product_Unique_Key__c != null);
                        System.assertEquals(soldToAccountGP.Id + '-' + p1_VideoPhysical.Id, dealProduct.NR_Deal_Product_Unique_Key__c );

                        // Quantity will be 1. It should not be modified by NR Batch
                        System.assertEquals(1, dealProduct.Quantity);

                        // Target Quantity will be 0 as no Valid Target found for this Product
                        System.assertEquals(0, dealProduct.Target_Quantity__c);

                        // Initial Quantity null as Replen Quantity is added
                        System.assertEquals(null, dealProduct.Initial_Quantity__c);
                        System.assertEquals(1, dealProduct.Replen_Quantity__c);
                        if(mapDealsProductsFetched.containsKey(dealProduct.Id)){
                            // One Schedule created by Decay Curve as Replen Quantity present
                            System.assertEquals(1, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules.size());
                            System.assertEquals(CRM_AppConstants.SCHEDULE_REPLEN_DELAY, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].Description);
                            System.assertEquals(1, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].Quantity);
                            System.assertEquals(20, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].Revenue);
                            System.assertEquals((mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].OpportunityLineItem.Product2.Street_Date__c).addDays(7), mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].ScheduleDate);
                        }
                    }
                    // 2. Verify if deal Product is created as Scenario 1 for Street Date change as nothing to clone present for Product 2
                    else if (dealProduct.Product2Id == p2_VideoPhysical.Id) {
                        System.debug('--2->');
                        System.assert(dealProduct.NR_Deal_Product_Unique_Key__c != null);
                        System.assertEquals(soldToAccountGP.Id + '-' + p2_VideoPhysical.Id, dealProduct.NR_Deal_Product_Unique_Key__c );

                        // Quantity will be 1. It should not be modified by NR Batch
                        System.assertEquals(1, dealProduct.Quantity);
                        System.assertEquals(0, dealProduct.Initial_Quantity__c);

                        // Target Quantity will be 35 based on sum of all the Targets found in Account Plan  / Account Price
                        System.assertEquals(35, dealProduct.Target_Quantity__c);
                        System.assertEquals(null, dealProduct.Replen_Quantity__c);
                        if(mapDealsProductsFetched.containsKey(dealProduct.Id)){
                            System.assertEquals(dealProduct.Product2.RecordTypeId, CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL);

                            // One Schedule created by Decay Curve as initial quantity present. erify Schedules Quantity not recalculated based on new Target Quantity 
                            /*System.assertEquals(2, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules.size());
                            System.assertEquals(0, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].Quantity);
                            System.assertEquals(20, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].Revenue);
                            System.assertEquals(mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].OpportunityLineItem.NR_Revenue_Recognition_Date__c, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].ScheduleDate);
                            System.assertEquals(1, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[1].Quantity);
                            System.assertEquals(0, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[1].Revenue);
                            System.assertEquals(mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[1].OpportunityLineItem.NR_Revenue_Recognition_Date__c, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[1].ScheduleDate);*/
                            System.assertEquals(1, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules.size());
                            System.assertEquals(CRM_AppConstants.SCHEDULE_ZERO, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].Description);
                            System.assertEquals(1, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].Quantity);
                            System.assertEquals(0, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].Revenue);
                            System.assertEquals(mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].OpportunityLineItem.Product2.Street_Date__c, mapDealsProductsFetched.get(dealProduct.Id).OpportunityLineItemSchedules[0].ScheduleDate);
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

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP)
           2. Deals ->
                  A0
                    -> D0 (GP, Start Date = System.Today() - 40, Batch Created with Batch DP0)
           3. Deal Product -> D0 (DP0 with Quantity 1 for P0)
      2. Product ->
           1. P0 (GP, Street Date = system.today() + 1)
      3. Run the Batch -> This Clones the deal Product and calculates the Quantity based on Target available for that Period
    */
    private static testMethod void Street_Date_Changed_With_Quantity_Refresh_With_Auto_Generated_Schedules() {
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
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
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.NR_period_weeks__c = 1;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id; 
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date__c = System.today() + 35;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        insert t0_GamesPhysical;

        // Create Batch created deal along with Batch created Deal Product which lies in previous month
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGP.Id;
        d0_existingDeal.Start_Date__c = system.today();
        d0_existingDeal.Promo_Start_Date__c = system.today();
        d0_existingDeal.CloseDate = system.today()+40;
        d0_existingDeal.Promo_End_Date__c = system.today()+40;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
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
                (system.today()).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = physicalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodCreated
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c existingDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        existingDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        existingDealPriceBookPeriod.Start_Date__c = System.today();
        existingDealPriceBookPeriod.End_Date__c = System.today()+40;
        existingDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        existingDealPriceBookPeriod.List_Price__c = 10;

        lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c streetDateChangeCurrentMonthDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        streetDateChangeCurrentMonthDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        streetDateChangeCurrentMonthDealPriceBookPeriod.Start_Date__c = System.today()+150;
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+170;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
            if (lstPriceBookEntryPeriod[i].Start_Date__c == System.today()) {
                existingDealPriceBookPeriod = lstPriceBookEntryPeriod[i];
            } else if (lstPriceBookEntryPeriod[i].Start_Date__c == System.today()+150) {
                streetDateChangeCurrentMonthDealPriceBookPeriod = lstPriceBookEntryPeriod[i];
            }
        }

        List<Product2> productsBeforeStreetDateChange = [SELECT Id, Street_Date__c,Street_Date_Has_Changed__c FROM Product2];
        System.assertEquals(1, productsBeforeStreetDateChange.size());
        System.assertEquals(System.today()+35, productsBeforeStreetDateChange[0].Street_Date__c);
        System.assert(productsBeforeStreetDateChange[0].Street_Date_Has_Changed__c, 'All Products should have Street Date changed as true');

        // Setting up Deal Product data such that batch deal Product already present for the above Deals D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p0_GamesPhysical.Id;
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        dp0_existingDealProduct.Target_Quantity__c = 20;
        dp0_existingDealProduct.Replen_Quantity__c = 20;
        dp0_existingDealProduct.Comments__c = 'Test Coop Comment';
        dp0_existingDealProduct.Coop__c = 12;
        dp0_existingDealProduct.Reason__c = 'Advertizing';
       // dp0_existingDealProduct.Coop_Requested_Amount_NR__c = 14;
        dp0_existingDealProduct.Pricebook_Entry_Period__c = existingDealPriceBookPeriod.Id;
        dp0_existingDealProduct.Promoted_Price__c = 100;
        dp0_existingDealProduct.Account_Price__c = 10;
        insert dp0_existingDealProduct;

        List<Opportunity> dealsBeforeFirstBatchRun = [SELECT Id, Name, (SELECT ID FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(1, dealsBeforeFirstBatchRun.size());
        for (Opportunity deal : dealsBeforeFirstBatchRun) {
            System.assertEquals(d0_existingDeal.Id, deal.Id);
            System.assertEquals(1, deal.OpportunityLineItems.size());
        }


        List<OpportunityLineItem> dealProductsBeforeFirstBatchRun =
            [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c, /*Coop_Requested_Amount_NR__c,*/ Pricebook_Entry_Period__c,Target_Quantity__c,
                    Product2Id, Quantity, OpportunityId, Opportunity.Name,Replen_Quantity__c, Initial_Quantity__c,Promoted_Price__c,Account_Price__c,
                    (SELECT Id, ScheduleDate, Quantity FROM OpportunityLineItemSchedules)
                FROM
                    OpportunityLineItem
            ];
        System.assertEquals(1, dealProductsBeforeFirstBatchRun.size());

        // Verify Pricing details populated properly
        System.assertEquals(100, dealProductsBeforeFirstBatchRun[0].Promoted_Price__c);
        System.assertEquals(10, dealProductsBeforeFirstBatchRun[0].Account_Price__c);

        System.assertEquals(null, dealProductsBeforeFirstBatchRun[0].Initial_Quantity__c);
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].Replen_Quantity__c);
        System.assertEquals(existingDealPriceBookPeriod.Id, dealProductsBeforeFirstBatchRun[0].Pricebook_Entry_Period__c);
        System.assertEquals(1, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules.size());
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        System.assertEquals(productsBeforeStreetDateChange[0].Street_Date__c + 7, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate);
        System.assertEquals(dealsBeforeFirstBatchRun[0].Id, dealProductsBeforeFirstBatchRun[0].OpportunityId);
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].Quantity);
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].Target_Quantity__c);
        System.assertEquals(productsBeforeStreetDateChange[0].Id, dealProductsBeforeFirstBatchRun[0].Product2Id);

        // Verify Coop fields are populated before batch is run
        System.assertEquals('Test Coop Comment', dealProductsBeforeFirstBatchRun[0].Comments__c);
        System.assertEquals(12, dealProductsBeforeFirstBatchRun[0].Coop__c);
        System.assertEquals('Advertizing', dealProductsBeforeFirstBatchRun[0].Reason__c);
       // System.assertEquals(14, dealProductsBeforeFirstBatchRun[0].Coop_Requested_Amount_NR__c);

        for (Product2 productInstance : productsBeforeStreetDateChange) {
            productInstance.Street_Date__c = System.today() + 150;
        }
        update productsBeforeStreetDateChange;

        List<Product2> productsAfterStreetDateChange = [SELECT Id, Street_Date__c,Street_Date_Has_Changed__c FROM Product2];
        System.assertEquals(1, productsAfterStreetDateChange.size());
        System.assertEquals(System.today() + 150, productsAfterStreetDateChange[0].Street_Date__c);
        System.assert(productsAfterStreetDateChange[0].Street_Date_Has_Changed__c, 'All Products should have Street Date changed as true');

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify a new Deal is created due to Street Date change
        List<Opportunity> dealsAfterFirstBatchRun = [SELECT Id, Name, (SELECT Id FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(2, dealsAfterFirstBatchRun.size());
        Integer currentQtr =
            Decimal.valueOf(
                (productsAfterStreetDateChange[0].Street_Date__c).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod = CRM_AppConstants.NR_Deal_For_Quarter + ' ' + currentQtr;
        /*Datetime sDate2 =
                datetime.newInstance(
                    (productsAfterStreetDateChange[0].Street_Date__c).year(),
                    (productsAfterStreetDateChange[0].Street_Date__c).month(),
                    (productsAfterStreetDateChange[0].Street_Date__c).day()
                );
        String currentMonth2 = sDate2.format('MMM');*/
        Opportunity newlyCreatedOpportunity = new Opportunity();
        for (Opportunity deal : dealsAfterFirstBatchRun) {
            if (deal.Id == d0_existingDeal.Id) {
                System.assertEquals(0, deal.OpportunityLineItems.size());
            } else {
                newlyCreatedOpportunity = deal;
                System.assertEquals('New Releases Games Physical '+dealPeriod+' '+(productsAfterStreetDateChange[0].Street_Date__c).year()+' ' + soldToAccountGP.Name, deal.Name);
                System.assertEquals(1, deal.OpportunityLineItems.size());
            }
        }

        // Verify only one deal product is present as the deal product is cloned and created
        List<OpportunityLineItem> dealProductsAfterFirstBatchRun =
            [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c,/* Coop_Requested_Amount_NR__c,*/Pricebook_Entry_Period__c,
                    Quantity, OpportunityId, Opportunity.Name,Replen_Quantity__c,Target_Quantity__c,Promoted_Price__c,Account_Price__c,
                    (SELECT Id, ScheduleDate, Quantity FROM OpportunityLineItemSchedules)
                FROM OpportunityLineItem
            ];
        System.assertEquals(1, dealProductsAfterFirstBatchRun.size());

        // Verify Promoted Price copied properly
        System.assertEquals(100, dealProductsAfterFirstBatchRun[0].Promoted_Price__c);

        // Verify Account Price populated properly
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].Account_Price__c);

        System.assertEquals(1, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules.size());
        System.assertEquals(newlyCreatedOpportunity.Id, dealProductsAfterFirstBatchRun[0].OpportunityId);
        System.assertEquals(streetDateChangeCurrentMonthDealPriceBookPeriod.Id, dealProductsAfterFirstBatchRun[0].Pricebook_Entry_Period__c);

        // Verify Quantity is not changed and it is present as it is modified
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].Replen_Quantity__c);
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].Quantity);
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);

        // Verify Target Quantity Calculated based on list price of pricebook entry period whose date ranges satisfies for the new deals start date
        // Q = 200 / 20
        //  is recalculated and only Schedule date is changed
        System.assertEquals(10, dealProductsAfterFirstBatchRun[0].Target_Quantity__c);
        System.assertEquals(productsAfterStreetDateChange[0].Street_Date__c + 7, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate);

        
        // Verify Coop fields are reset for cloned deal prodduct after batch is run
        System.assertEquals(null, dealProductsAfterFirstBatchRun[0].Comments__c);
        System.assertEquals(null, dealProductsAfterFirstBatchRun[0].Coop__c);
        System.assertEquals(null, dealProductsAfterFirstBatchRun[0].Reason__c);
        //System.assertEquals(null, dealProductsAfterFirstBatchRun[0].Coop_Requested_Amount_NR__c);
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP)
           2. Deals ->
                  A0
                    -> D0 (GP, Start Date = System.Today() - 40, Batch Created with Batch DP0)
           3. Deal Product -> D0 (DP0 with Quantity 1 for P0)
      2. Product ->
           1. P0 (GP, Street Date = system.today() + 1)
      3. Run the Batch -> This Clones the deal Product and calculates the Quantity based on Target available for that Period
    */
    private static testMethod void Street_Date_Changed_With_Quantity_Refresh_With_Manual_Schedules(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
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
        p0_GamesPhysical.Street_Date__c = System.today() + 1;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date_Has_Changed__c = true;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.Previous_Street_Date__c = System.today() - 140;
        p0_GamesPhysical.NR_period_weeks__c = 1;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        insert t0_GamesPhysical;

        // Create Batch created deal along with Batch created Deal Product which lies in previous month
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGP.Id;
        d0_existingDeal.Start_Date__c = system.today() - 140;
        d0_existingDeal.Promo_Start_Date__c = system.today() - 140;
        d0_existingDeal.CloseDate = system.today() - 135;
        d0_existingDeal.Promo_End_Date__c = system.today() - 135;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        d0_existingDeal.CurrencyIsoCode = 'USD';
        /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() - 140).year(),
                    (system.today() - 140).month(),
                    (system.today() - 140).day()
                );
        String currentMonth1 = sDate1.format('MMM');*/
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today() - 140).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = physicalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodCreated
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c existingDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        existingDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        existingDealPriceBookPeriod.Start_Date__c = System.today()-140;
        existingDealPriceBookPeriod.End_Date__c = System.today()-140;
        existingDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        existingDealPriceBookPeriod.List_Price__c = 10;

        lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c streetDateChangeCurrentMonthDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        streetDateChangeCurrentMonthDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        streetDateChangeCurrentMonthDealPriceBookPeriod.Start_Date__c = System.today().toStartOfMonth();
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+30;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p0_GamesPhysical.Id;
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        dp0_existingDealProduct.Comments__c = 'Test Coop Comment';
        dp0_existingDealProduct.Coop__c = 12;
        dp0_existingDealProduct.Reason__c = 'Advertizing';
      //  dp0_existingDealProduct.Coop_Requested_Amount_NR__c = 14;
        dp0_existingDealProduct.Manually_Schedule__c = true;
        insert dp0_existingDealProduct;

        // Setting up Deal Product Schedules
        List<OpportunityLineItemSchedule> dealProductSchedulesBeforeBatchRun =
            CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        for(Integer i=0 ; i< dealProductSchedulesBeforeBatchRun.size(); i++){
            dealProductSchedulesBeforeBatchRun[i].OpportunityLineItemId = dp0_existingDealProduct.Id;
            dealProductSchedulesBeforeBatchRun[i].Quantity = 50;
        }
        insert dealProductSchedulesBeforeBatchRun;

        // Verify 1 Schedule created
        System.assertEquals(1, dealProductSchedulesBeforeBatchRun.size(), 'New Deal Product Schedule');

        // Verify the data before runnig the batch
        for (Product2 product : lstProduct) {
            System.assert(product.Street_Date_Has_Changed__c, 'All Products should have Street Date changed as true');
        }
        List<Opportunity> dealsBeforeFirstBatchRun = [SELECT Id, Name, (SELECT ID FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(1, dealsBeforeFirstBatchRun.size());
        for (Opportunity deal : dealsBeforeFirstBatchRun) {
            System.assertEquals(d0_existingDeal.Id, deal.Id);
            System.assertEquals(1, deal.OpportunityLineItems.size());
        }

        List<Product2> productsBeforeFirstBatchRun = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(1, productsBeforeFirstBatchRun.size());
        System.assertEquals(System.today() + 1, productsBeforeFirstBatchRun[0].Street_Date__c);

        List<OpportunityLineItem> dealProductsBeforeFirstBatchRun =
            [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c, /*Coop_Requested_Amount_NR__c,*/ Product2Id,
                    Quantity, OpportunityId, Opportunity.Name,Target_Quantity__c,
                    (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
                FROM OpportunityLineItem
            ];
        System.assertEquals(1, dealProductsBeforeFirstBatchRun.size());
        System.assertEquals(1, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules.size());
        System.assertEquals(50, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        System.assertEquals(System.today(), dealProductSchedulesBeforeBatchRun[0].ScheduleDate);
        System.assertEquals(dealsBeforeFirstBatchRun[0].Id, dealProductsBeforeFirstBatchRun[0].OpportunityId);
        // Verify even if Quantity is 20 but as Manually Added schedule Quantity is 50 it will get roll up to Qunatity
        System.assertEquals(50, dealProductsBeforeFirstBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeFirstBatchRun[0].Target_Quantity__c);
        System.assertEquals(productsBeforeFirstBatchRun[0].Id, dealProductsBeforeFirstBatchRun[0].Product2Id);

        // Verify Coop fields are populated before batch is run
        System.assertEquals('Test Coop Comment', dealProductsBeforeFirstBatchRun[0].Comments__c);
        System.assertEquals(12, dealProductsBeforeFirstBatchRun[0].Coop__c);
        System.assertEquals('Advertizing', dealProductsBeforeFirstBatchRun[0].Reason__c);
        //System.assertEquals(14, dealProductsBeforeFirstBatchRun[0].Coop_Requested_Amount_NR__c);

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify a new Deal is created due to Street Date change
        List<Opportunity> dealsAfterFirstBatchRun = [SELECT Id, Name, (SELECT Id FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(2, dealsAfterFirstBatchRun.size());
        /*Datetime sDate2 =
                datetime.newInstance(
                    (productsBeforeFirstBatchRun[0].Street_Date__c).year(),
                    (productsBeforeFirstBatchRun[0].Street_Date__c).month(),
                    (productsBeforeFirstBatchRun[0].Street_Date__c).day()
                );
        String currentMonth2 = sDate2.format('MMM');*/
        Integer currentQtr =
            Decimal.valueOf(
                (productsBeforeFirstBatchRun[0].Street_Date__c).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod = CRM_AppConstants.NR_Deal_For_Quarter + ' ' + currentQtr;
        for (Opportunity deal : dealsAfterFirstBatchRun) {
            if (deal.Id == d0_existingDeal.Id) {
                System.assertEquals(0, deal.OpportunityLineItems.size());
            } else {
                System.assertEquals('New Releases Games Physical '+dealPeriod+' '+(productsBeforeFirstBatchRun[0].Street_Date__c).year()+' ' + soldToAccountGP.Name, deal.Name);
                System.assertEquals(1, deal.OpportunityLineItems.size());
            }
        }

        // Verify only one deal product is present as the deal product is cloned and created
        List<OpportunityLineItem> dealProductsAfterFirstBatchRun =
            [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c, /*Coop_Requested_Amount_NR__c,*/
                    Quantity, OpportunityId, Opportunity.Name,Target_Quantity__c,
                    (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
                FROM OpportunityLineItem ORDER BY Opportunity.CreatedDate DESC
            ];
        System.assertEquals(1, dealProductsAfterFirstBatchRun.size());
        // Verify Schedules are cloned properly
        System.assertEquals(1, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules.size());
        System.assertEquals(50, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        Date oldStreetDate = System.today()-140;
        Date oldScheduleDate = dealProductSchedulesBeforeBatchRun[0].ScheduleDate;
        Integer numberDaysDifference = oldStreetDate.daysBetween(System.today());

        Date nweStreetDate = p0_GamesPhysical.Street_Date__c;
        Date  newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        System.assertEquals(newScheduleDate, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate);
        //System.assertEquals(dealsAfterFirstBatchRun[0].Id, dealProductsAfterFirstBatchRun[0].OpportunityId);
        // Verify the Quantity is not refreshed are the deal product has Manually added schedules
        System.assertEquals(50, dealProductsAfterFirstBatchRun[0].Quantity);
        //System.assertEquals(0, dealProductsAfterFirstBatchRun[0].Target_Quantity__c);
        System.assertEquals(10, dealProductsAfterFirstBatchRun[0].Target_Quantity__c);

        // Verify Coop fields are reset for cloned deal prodduct after batch is run
        System.assertEquals(null, dealProductsAfterFirstBatchRun[0].Comments__c);
        System.assertEquals(null, dealProductsAfterFirstBatchRun[0].Coop__c);
        System.assertEquals(null, dealProductsAfterFirstBatchRun[0].Reason__c);
        //System.assertEquals(null, dealProductsAfterFirstBatchRun[0].Coop_Requested_Amount_NR__c);
    }

    private static testMethod void Target_Revenue_Changed_Without_Deal_And_Deal_Products(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
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
        p0_GamesPhysical.Street_Date__c = System.today() + 1;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
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
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+30;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c, PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
           /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsBeforeBatchRun.size());

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(0, dealsAfterBatchRun.size());
        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, dealProductsAfterBatchRun.size());
    }

    private static testMethod void Target_Revenue_Changed_With_Planned_Deal_And_Deal_Products(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
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
        p0_GamesPhysical.Street_Date__c = System.today() + 1;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        insert lstPriceBookEntryPeriod;
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGP.Id;
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
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = physicalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p0_GamesPhysical.Id;
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        insert dp0_existingDealProduct;

        List<Opportunity> dealsBeforeBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsBeforeBatchRun.size());
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        System.assertEquals(20, dealProductsBeforeBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeBatchRun[0].Target_Quantity__c);

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify no new deal and deal product is created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assertEquals(dealsBeforeBatchRun[0].Id, dealsAfterBatchRun[0].Id);

        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        System.assertEquals(dealProductsBeforeBatchRun[0].Id, dealProductsAfterBatchRun[0].Id);

        // Verify Quantity is  recalculated even if Valid deal found is of type Planned
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

        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
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
        p0_GamesPhysical.Street_Date__c = System.today() + 1;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        insert lstPriceBookEntryPeriod;
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGP.Id;
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
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = physicalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p0_GamesPhysical.Id;
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
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        System.assertEquals(20, dealProductsBeforeBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeBatchRun[0].Target_Quantity__c);

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify no new deal and deal product is created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assertEquals(dealsBeforeBatchRun[0].Id, dealsAfterBatchRun[0].Id);

        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        System.assertEquals(dealProductsBeforeBatchRun[0].Id, dealProductsAfterBatchRun[0].Id);

        // Verify Quantity is  recalculated even if Valid deal found is of type Committed
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

        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
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
        p0_GamesPhysical.Street_Date__c = System.today() + 1;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        insert lstPriceBookEntryPeriod;
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
            /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
               mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
           } else {
                mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
           }*/
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGP.Id;
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
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = physicalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p0_GamesPhysical.Id;
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
        List<OpportunityLineItem> dealProductsBeforeBatchRun = [SELECT Id, Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsBeforeBatchRun.size());
        System.assertEquals(20, dealProductsBeforeBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeBatchRun[0].Target_Quantity__c);

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify no new deal and deal product is created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assertEquals(dealsBeforeBatchRun[0].Id, dealsAfterBatchRun[0].Id);

        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id,Target_Quantity__c, Quantity FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        System.assertEquals(dealProductsBeforeBatchRun[0].Id, dealProductsAfterBatchRun[0].Id);

        // Verify Quantity is  recalculated even if Valid deal found is of type Approved
        System.assertEquals(20, dealProductsAfterBatchRun[0].Quantity);
        System.assertEquals(10, dealProductsAfterBatchRun[0].Target_Quantity__c);
    }

/*    private static testMethod void Target_Revenue_Changed_With_Valid_Deal_And_Manual_Deal_Product(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
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
        p0_GamesPhysical.Street_Date__c = System.today() + 1;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date_Has_Changed__c = false;
        update p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp ,lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        //t0_GamesPhysical.Target_Revenue_Has_Changed__c = true;
        insert t0_GamesPhysical;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        insert lstPriceBookEntryPeriod;
        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        List<Account_Plan__c> lstAccountPlan1 = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan1){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }
         
        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGP.Id;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0 With Stage Changed';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        d0_existingDeal.CurrencyIsoCode = 'USD';
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today()).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = physicalDealRecordTypeId;
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
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts(), setProductAndAccountId , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify no new deal and deal product is created
        List<Opportunity> dealsAfterBatchRun = [SELECT Id FROM Opportunity];
        System.assertEquals(1, dealsAfterBatchRun.size());
        System.assertEquals(dealsBeforeBatchRun[0].Id, dealsAfterBatchRun[0].Id);

        List<OpportunityLineItem> dealProductsAfterBatchRun = [SELECT Id, Quantity,Target_Quantity__c FROM OpportunityLineItem];
        System.assertEquals(1, dealProductsAfterBatchRun.size());
        System.assertEquals(dealProductsBeforeBatchRun[0].Id, dealProductsAfterBatchRun[0].Id);

        // Verify Quantity is not recalculated as no Valid deal found
        System.assertEquals(20, dealProductsAfterBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsAfterBatchRun[0].Target_Quantity__c);
    }*/

    public static testMethod void NR_Product_Creation_With_Existing_Deal_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = System.today()+140;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today()+160;
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }
        update tw.lstPriceBookEntryPeriod;

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify no new deal is created
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'Updated Deals');

        // verify no deal product is created as no valid PBEP found
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');
    }

    public static testMethod void Street_Date_Changed_With_No_Schedules_And_No_Valid_PBEP_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        for(Product2 p : tw.lstProduct){
           p.Street_Date__c = system.today()+40;
           p.Street_Date_Has_Changed__c = true;
           p.NR_Product_Created__c = false;
           p.CurrencyIsoCode = 'USD';
        }
        update tw.lstProduct;

        // Setting up OpportunityLineItem Data
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstPriceBookEntry[i].Product2Id;
        }
        insert lstDealProduct;

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
        System.assertEquals(5,[Select Id,OpportunityId,Product2.RecordTypeId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProductInstance : [Select Id,Target_Quantity__c,OpportunityId,Initial_Quantity__c,Replen_Quantity__c, Product2.RecordTypeId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
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
        // Verify Schedules are only created for Digital and Physical
        System.assertEquals(5,[Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'Initial Deal Product Schedule');

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify no new Deals are created as no valid PBEP found
        System.assertEquals(5,[Select Id, Name from Opportunity].size(), 'New Deals');

        // Verify no new Deal Product is cloned and created but the existing deal product that was supposed to be cloned gets deleted
        List<OpportunityLineItem> dealProducts = [Select Id,OpportunityId, Manually_Schedule__c, Product2.RecordTypeId,Product2.Type__c, Quantity,NR_Deal_Product_Unique_Key__c,Opportunity.Product_Type__c from OpportunityLineItem];
        System.assertEquals(3,dealProducts.size(), 'New Deal Products');

        // Verify no physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(0, clonedDealProductsCount);

        // Verify no schedules are cloned as no valid PBEP Found and the existing Schedules are deleted
        List<OpportunityLineItemSchedule> schedules = [Select Id,OpportunityLineItemId, Quantity, ScheduleDate from OpportunityLineItemSchedule];
        System.assertEquals(3, schedules.size(), 'No Deal Product Schedule for Physical');
    }

    public static testMethod void NR_Existing_Deal_And_Deal_Product_Present_And_New_PBEP_Added() {
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);
        //Setting up Product Data
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = system.today()+20;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today() +30;
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
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
            //lstDealProduct[i].Replen_Quantity__c = lstDealProduct[i].Quantity;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;
        System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,OpportunityId,Initial_Quantity__c,Replen_Quantity__c, Product2.RecordTypeId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
            if (dealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assertEquals(1, dealProduct.Initial_Quantity__c);
                System.assertEquals(null, dealProduct.Replen_Quantity__c);
            } else {
                System.assertEquals(null, dealProduct.Initial_Quantity__c);
                System.assertEquals(1, dealProduct.Replen_Quantity__c);
            }
        }

        // Verify 1 Schedule for each digital deal product is created
        // No Schedule is created for Physical deal product as the value is added in Initial Quantity
        System.assertEquals(5, [Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'New Deal Product Schedule');

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
           setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
           System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        Test.startTest(); 
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
 
        Integer physicalDealProductCount = 0;
        Integer digitalDealProductCount = 0;

        // Verify target Revenue is  changed for physical deal products with automatic schedules
        for(OpportunityLineItem dealProduct : [Select Id, OpportunityId, Target_Quantity__c, Quantity, Product2.Type__c, Initial_Quantity__c, Replen_Quantity__c from OpportunityLineItem]){
            if (dealProduct.Product2.Type__c.contains('Physical')) {
                System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Quantity, 'Updated Quantity');
                System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Initial_Quantity__c, 'Updated Quantity');
                physicalDealProductCount++;
            } else {
                digitalDealProductCount++;
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Quantity, 'Quantity not Updated');
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Quantity not Updated');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity not Updated');
            }
        }
        System.assertEquals(2, physicalDealProductCount);
        System.assertEquals(3, digitalDealProductCount);

        List<Account_Plan__c> lstAccountPlanAfterFirstBatchRun = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlanAfterFirstBatchRun){
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlanAfterFirstBatchRun;

        // reset NR Batch and create New PBEPs
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Process_NR_Batch__c = false;
        }
        update tw.lstPriceBookEntryPeriod;

        // Add New Pricebook Entry Periods
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(tw.lstProduct, 1, false);
        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = tw.lstProduct[i].id;
            lstPriceBookEntryPeriod[i].Start_Date__c = System.today() + 10;
            lstPriceBookEntryPeriod[i].End_Date__c = System.today() + 20;
            lstPriceBookEntryPeriod[i].List_Price__c = 10;
            lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'USD';
            lstPriceBookEntryPeriod[i].New_Release__c = true;
        }
        insert lstPriceBookEntryPeriod;

        // Verify Process NR Batch checkbox is checked
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c,Start_Date__c,Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL && pbep.Start_Date__c == System.today() + 10) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        mapIdToPBEPList = new Map<String, List<Pricebook_Entry_Period__c>>();
        for (Pricebook_Entry_Period__c pbepInstance : [
                SELECT
                    Id, Product__c, Start_Date__c,Product__r.RecordTypeId, Price_Book__c, End_Date__c, List_Price__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    Account_Price__c,New_Release__c, CurrencyIsoCode,Minimum_Price__c, Retail_Price__c, Material_Price_Group__c, Process_NR_Batch__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Process_NR_Batch__c = true
                    AND Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT
                    ORDER BY Start_Date__c ASC
        ]) {
            String strKey = pbepInstance.Product__c + '-' + pbepInstance.Price_Book__c + '-' + pbepInstance.CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(pbepInstance);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{pbepInstance});
            }
        }

        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch1.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        physicalDealProductCount = 0;
        digitalDealProductCount = 0;
        setProductAndAccountId = new Set<String>();

        // Verify target Revenue is  changed for physical deal products with automatic schedules
        for(OpportunityLineItem dealProduct : [Select Id, OpportunityId,Target_Quantity__c, Quantity, Product2.Type__c, Initial_Quantity__c, Replen_Quantity__c from OpportunityLineItem]){
            if (dealProduct.Product2.Type__c.contains('Physical')) {
                System.assertEquals(20.00, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Quantity, 'Updated Quantity');
                System.assertEquals(null, dealProduct.Replen_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Initial_Quantity__c, 'Updated Quantity');
                physicalDealProductCount++;
            } else {
                digitalDealProductCount++;
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Quantity, 'Quantity not Updated');
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Quantity not Updated');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity not Updated');
            }
        }
        System.assertEquals(2, physicalDealProductCount);
        System.assertEquals(3, digitalDealProductCount);
    }

    public static testMethod void NR_Existing_Deal_And_Deal_Product_Present_And_New_PBEP_Start_Date_Changed(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(tw.lstPriceBookEntry, tw.lstOpportunity, 1, false);
        List<OpportunityLineItemSchedule> lstDealProductSchedule = CRM_TestDataFactory.createOpportunitySchedule(lstDealProduct, 1, false);

        //Setting up Product Data
        for(Product2 p : tw.lstProduct){
           p.NR_Product_Created__c = false;
           p.Street_Date_Has_Changed__c = false;
        }
        update tw.lstProduct;

        // Add New Pricebook Entry Periods
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(tw.lstProduct, 1, false);
        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = tw.lstProduct[i].id;
            lstPriceBookEntryPeriod[i].Start_Date__c = System.today() + 10;
            lstPriceBookEntryPeriod[i].End_Date__c = System.today() + 20;
            lstPriceBookEntryPeriod[i].List_Price__c = 10;
            lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'USD';
            lstPriceBookEntryPeriod[i].New_Release__c = true;
        }
        insert lstPriceBookEntryPeriod;

        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            tw.lstPriceBookEntryPeriod[i].Start_Date__c = system.today()+20;
            tw.lstPriceBookEntryPeriod[i].End_Date__c = System.today() +30;
        }
        update tw.lstPriceBookEntryPeriod;

        for (Pricebook_Entry_Period__c pbepInstance : [
                SELECT
                    Id, Product__c, Start_Date__c,Product__r.RecordTypeId, Price_Book__c,Material_Price_Group__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                     End_Date__c, List_Price__c, Account_Price__c,New_Release__c, CurrencyIsoCode, Minimum_Price__c, Retail_Price__c 
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Process_NR_Batch__c = true
                    AND Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT
                    ORDER BY Start_Date__c ASC
        ]) {
            String strKey = pbepInstance.Product__c + '-' + pbepInstance.Price_Book__c + '-' + pbepInstance.CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(pbepInstance);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{pbepInstance});
            }
        }

        //Setting up OpportunityLineItem Data
        System.debug('1::'+lstDealProduct.size());
        System.debug('2::'+tw.lstAccounts.size());
        System.debug('3::'+tw.lstProduct.size());
        for(Integer i=0 ; i< lstDealProduct.size(); i++){
            lstDealProduct[i].OpportunityId = tw.lstOpportunity[i].Id;
            lstDealProduct[i].PricebookEntryId = tw.lstPriceBookEntry[i].Id;
            lstDealProduct[i].Manually_Schedule__c = false;
            lstDealProduct[i].Replen_Quantity__c = lstDealProduct[i].Quantity;
            lstDealProduct[i].NR_Deal_Product_Unique_Key__c = tw.lstAccounts[i].Id + '-' + tw.lstProduct[i].Id;
            System.assertEquals(1, lstDealProduct[i].Quantity, 'Initial Quantity');
        }
        insert lstDealProduct;
        //System.assertEquals(5,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        Integer countDealProducts = 0;
        for (OpportunityLineItem dealProduct : [Select (Select Id,OpportunityLineItemId from OpportunityLineItemSchedules), Id,Target_Quantity__c,OpportunityId,Initial_Quantity__c,Replen_Quantity__c, Product2.RecordTypeId,Manually_Schedule__c, Quantity  from OpportunityLineItem]) {
            System.assertEquals(1, dealProduct.Quantity);
            System.assertEquals(0, dealProduct.Target_Quantity__c);
            System.assertEquals(null, dealProduct.Initial_Quantity__c);
            System.assertEquals(1, dealProduct.Replen_Quantity__c);
            System.assertEquals(1, dealProduct.OpportunityLineItemSchedules.size());
            countDealProducts++;
        }
        System.assertEquals(5,countDealProducts, 'Initial Deal Products');

        // Verify 1 Schedule for each digital deal product is created
        // No Schedule is created for Physical deal product as the value is added in Initial Quantity
        //System.assertEquals(5, [Select Id,OpportunityLineItemId from OpportunityLineItemSchedule].size(), 'New Deal Product Schedule');

        //Setting up the target data
        for(Integer i=0 ; i< tw.lstTargets.size() ; i++){
            tw.lstTargets[i].Product__c = tw.lstProduct[i].id;
            tw.lstTargets[i].RecordTypeId = rtTarget;
            tw.lstTargets[i].Target__c = 200;
        }
        System.debug('lstTargets::'+tw.lstTargets); 
        update tw.lstTargets;
        System.assertEquals(5, tw.lstTargets.size(), 'Updated Targets');

        List<Account_Plan__c> lstAccountPlan = [Select Id, Country_Plan__r.NR_Product__c, Country_Plan__r.NR_Product__r.RecordTypeId,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlan){
            if (accountPlanInstance.Country_Plan__r.NR_Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                System.assert(accountPlanInstance.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be true');
                /*if (mapProductIdToAccountPlanList.containsKey(accountPlanInstance.Country_Plan__r.NR_Product__c)) {
                    mapProductIdToAccountPlanList.get(accountPlanInstance.Country_Plan__r.NR_Product__c).add(accountPlanInstance);
                } else {
                    mapProductIdToAccountPlanList.put(accountPlanInstance.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlanInstance});
                }*/
                setProductAndAccountId.add(accountPlanInstance.Country_Plan__r.NR_Product__c + '-' + accountPlanInstance.Customer__c);
            }
                System.debug('accountPlanInstance in test::'+accountPlanInstance);
        }

        Test.startTest(); 
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
 
        Integer physicalDealProductCount = 0;
        Integer digitalDealProductCount = 0;

        // Verify target Revenue is  changed for physical deal products with automatic schedules
        for(OpportunityLineItem dealProduct : [Select Id, OpportunityId, Target_Quantity__c, Quantity, Product2.Type__c, Initial_Quantity__c, Replen_Quantity__c from OpportunityLineItem]){
            if (dealProduct.Product2.Type__c.contains('Physical')) {
                System.assertEquals(20.00, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Quantity, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Updated Quantity');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Updated Quantity');
                physicalDealProductCount++;
            } else {
                digitalDealProductCount++;
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Quantity, 'Quantity not Updated');
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Quantity not Updated');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity not Updated');
            }
        }
        System.assertEquals(2, physicalDealProductCount);
        System.assertEquals(3, digitalDealProductCount);

        List<Account_Plan__c> lstAccountPlanAfterFirstBatchRun = [Select Id, Country_Plan__r.NR_Product__c,  PublishedTarget__c, Target_Revenue_Has_Changed__c, Customer__c from Account_Plan__c ];
        for(Account_Plan__c accountPlanInstance : lstAccountPlanAfterFirstBatchRun){
            accountPlanInstance.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlanAfterFirstBatchRun;

        List<Pricebook_Entry_Period__c> pricebookEntryPeriodsToChangeDate =
            [SELECT Id, List_Price__c,Start_Date__c,Product__r.RecordTypeId, Process_NR_Batch__c
            FROM Pricebook_Entry_Period__c
            WHERE Start_Date__c =: System.today() + 10];
        for(Pricebook_Entry_Period__c pbep : pricebookEntryPeriodsToChangeDate) {
            pbep.Process_NR_Batch__c = false;
            pbep.Start_Date__c = system.today()+35;
            pbep.End_Date__c = system.today()+45;
        }
        update pricebookEntryPeriodsToChangeDate;

        // Verify Process NR Batch checkbox is checked as street Date is changed
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, List_Price__c,Start_Date__c,Product__r.RecordTypeId, Process_NR_Batch__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL && pbep.Start_Date__c == System.today() + 45) {
                System.assert(pbep.Process_NR_Batch__c, 'Process NR Batch should be true');
            }
        }

        mapIdToPBEPList = new Map<String, List<Pricebook_Entry_Period__c>>();
        for (Pricebook_Entry_Period__c pbepInstance : [
                SELECT
                    Id, Product__c, Start_Date__c,Product__r.RecordTypeId, Price_Book__c, End_Date__c,Material_Price_Group__c,//Suggested_Price__c, - US#895 - removed ref. of suggested price
                    List_Price__c, Account_Price__c,New_Release__c, CurrencyIsoCode,Minimum_Price__c, Retail_Price__c, Process_NR_Batch__c
                FROM
                    Pricebook_Entry_Period__c
                WHERE
                    Process_NR_Batch__c = true
                    AND Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT
                    ORDER BY Start_Date__c ASC
        ]) {
            String strKey = pbepInstance.Product__c + '-' + pbepInstance.Price_Book__c + '-' + pbepInstance.CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(pbepInstance);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{pbepInstance});
            }
        }

        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch1 = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch1.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        physicalDealProductCount = 0;
        digitalDealProductCount = 0;
        setProductAndAccountId = new Set<String>();

        // Verify target Revenue is  changed for physical deal products with automatic schedules
        for(OpportunityLineItem dealProduct : [Select Id, OpportunityId, Target_Quantity__c,Quantity, Product2.Type__c, Initial_Quantity__c, Replen_Quantity__c from OpportunityLineItem]){
            if (dealProduct.Product2.Type__c.contains('Physical')) {
                System.assertEquals(1, dealProduct.Quantity, 'Updated Quantity');
                System.assertEquals(10.00, dealProduct.Target_Quantity__c, 'Updated Quantity');
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Updated Quantity');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Updated Quantity');
                physicalDealProductCount++;
            } else {
                digitalDealProductCount++;
                System.assertEquals(0, dealProduct.Target_Quantity__c, 'Quantity not Updated');
                System.assertEquals(1, dealProduct.Quantity, 'Quantity not Updated');
                System.assertEquals(1, dealProduct.Replen_Quantity__c, 'Quantity not Updated');
                System.assertEquals(null, dealProduct.Initial_Quantity__c, 'Quantity not Updated');
            }
        }
        System.assertEquals(2, physicalDealProductCount);
        System.assertEquals(3, digitalDealProductCount);
    }

    public static testMethod void NegativeTest_Schedules_Insert_Fail_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Set<String> setProductAndAccountId = new Set<String>();
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
            tw.lstTargets[i].RecordTypeId = rtTarget;
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
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(7,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(5,[Select Id,OpportunityId from OpportunityLineItem].size(), 'Initial Deal Products');

        // Verify 2 physical deal products are cloned and created. Existing manually created digital deal products are still present
        Integer clonedDealProductsCount = 0;
        /*Date oldStreetDate = system.today()+1;
        Integer numberDaysDifference = oldStreetDate.daysBetween(system.today());
        System.debug('---numberDaysDifference-->'+numberDaysDifference);

        Date nweStreetDate = system.today()+40;
        Date newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        System.debug('--newScheduleDate-->'+newScheduleDate);*/
        for (OpportunityLineItem dealProduct : [Select Id,Target_Quantity__c,Product2.RecordTypeId,OpportunityId,Quantity,Product2Id, Opportunity.AccountId,
            (SELECT Id, Quantity, ScheduleDate FROM OpportunityLineItemSchedules)
            from OpportunityLineItem
        ]) {
            System.debug('--dealProduct-->'+dealProduct);
            System.debug('--dealProduct-->'+dealProduct);
            if (dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId) {
                System.assertEquals(1, dealProduct.Quantity);
                //System.assertEquals(0, dealProduct.Target_Quantity__c);
                System.assertEquals(10, dealProduct.Target_Quantity__c);
                System.assertEquals(0, dealProduct.OpportunityLineItemSchedules.size());
                // Verify Schedules are not created with changed Date as Previous Start Date is not present
                /*System.assertEquals(21, dealProduct.OpportunityLineItemSchedules[0].Quantity);
                System.assertEquals(newScheduleDate, dealProduct.OpportunityLineItemSchedules[0].ScheduleDate);*/
                clonedDealProductsCount++;
            }
        }
        System.assertEquals(2, clonedDealProductsCount);
    }

    public static testMethod void NegativeTest_Deal_Insert_Fail_With_Scenario1_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        delete tw.lstOpportunity;
        Set<String> setProductAndAccountId = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(tw.lstAccounts, automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify only one deal created for Games Physical as Games Owner present. Video Physical Deal not created as Account Owner not specified in Account Query
        //System.assertEquals(1,[Select Id, Name from Opportunity].size(), 'New Deals');
        //System.assert([Select Id, Name from Opportunity][0].Name.contains('Games'));
        //System.assertEquals(1,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Updated Deal Products');    
    }

    public static testMethod void NR_Product_Creation_With_No_Deal_For_Consignment_Customer_Test(){
        //Method to create Dummy Data
        CRM_AutoPhysicalNRDealCreationService_TestWrapper tw = createData();
        List<Account> lstAccounts = tw.lstAccounts;
        for (Account acc : lstAccounts) {
            acc.Consignment_Customer__c = true;
            if (acc.Games_Physical__c) {
                acc.Consignment_Multiplier_Games__c = 1.25;
            }
            if (acc.Video_Physical__c) {
                acc.Consignment_Multiplier_Video__c = 1.2;
            }
        }
        update lstAccounts;

        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        delete tw.lstOpportunity;
        Set<String> setProductAndAccountId = new Set<String>();
        Set<Id> setProcessedProductIds = new Set<Id>();
        System.assertEquals(0,[Select Id, Name from Opportunity].size(), 'Initial Deals');
        System.assertEquals(0,[Select Id,OpportunityId  from OpportunityLineItem].size(), 'Initial Deal Products');
        for(Integer i=0 ; i<tw.lstPriceBookEntryPeriod.size() ; i++){
            String strKey = tw.lstPriceBookEntryPeriod[i].Product__c + '-' + tw.lstPriceBookEntryPeriod[i].Price_Book__c + '-' + tw.lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(tw.lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{tw.lstPriceBookEntryPeriod[i]});
            }
        }

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        System.assertEquals(2,[Select Id, Name from Opportunity].size(), 'New Deals');
        List<OpportunityLineItem> dealProducts = [Select Id,Product2.RecordTypeId, P_L_Quantity__c, Target_Quantity__c, Quantity, OpportunityId  from OpportunityLineItem];
        System.assertEquals(2, dealProducts.size(), 'Updated Deal Products');
        for (OpportunityLineItem dealProduct : dealProducts) {
            if (dealProduct.Product2.RecordTypeId == physicalProductRecordTypeId) {
                System.assertEquals(1, dealProduct.Quantity);
                System.assertEquals(3, dealProduct.Target_Quantity__c);
                System.assertEquals(1, dealProduct.P_L_Quantity__c);
            }
        }
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP) with Consignmetn Customer true
           2. Deals ->
                  A0
                    -> D0 (GP, Start Date = System.Today() - 40, Batch Created with Batch DP0)
           3. Deal Product -> D0 (DP0 with Quantity 20 for P0)
      2. Product ->
           1. P0 (GP, Street Date = system.today() + 1)
      3. Run the Batch -> This Clones the deal Product and calculates the Quantity based on Target available for that Period and EPos Quantity persists as it is
    */
    private static testMethod void Street_Date_Changed_With_EPos_Quantity_For_Consignment_Customer(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Consignment_Customer__c = true;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        if (lstAccounts[0].Games_Physical__c) {
            lstAccounts[0].Consignment_Multiplier_Games__c = 1.25;
        }
        if (lstAccounts[0].Video_Physical__c) {
            lstAccounts[0].Consignment_Multiplier_Video__c = 1.2;
        }
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
        p0_GamesPhysical.Street_Date__c = System.today() - 140;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.NR_period_weeks__c = 1;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        insert t0_GamesPhysical;

        // Create Batch created deal along with Batch created Deal Product which lies in previous month
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGP.Id;
        d0_existingDeal.Start_Date__c = system.today() - 140;
        d0_existingDeal.Promo_Start_Date__c = system.today() - 140;
        d0_existingDeal.CloseDate = system.today() - 135;
        d0_existingDeal.Promo_End_Date__c = system.today() - 135;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        d0_existingDeal.CurrencyIsoCode = 'USD';
        /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() - 40).year(),
                    (system.today() - 40).month(),
                    (system.today() - 40).day()
                );
        String currentMonth1 = sDate1.format('MMM');*/
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today() - 40).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = physicalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodCreated
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c existingDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        existingDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        existingDealPriceBookPeriod.Start_Date__c = System.today()-140;
        existingDealPriceBookPeriod.End_Date__c = System.today()-140;
        existingDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        existingDealPriceBookPeriod.List_Price__c = 10;

        lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c streetDateChangeCurrentMonthDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        streetDateChangeCurrentMonthDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        streetDateChangeCurrentMonthDealPriceBookPeriod.Start_Date__c = System.today().toStartOfMonth();
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+30;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p0_GamesPhysical.Id;
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        dp0_existingDealProduct.Account_Price__c = 10;
        dp0_existingDealProduct.Promoted_Price__c = 10;
        dp0_existingDealProduct.P_L_Quantity__c = 20;
        dp0_existingDealProduct.Comments__c = 'Test Coop Comment';
        dp0_existingDealProduct.Coop__c = 12;
        dp0_existingDealProduct.Reason__c = 'Advertizing';
       // dp0_existingDealProduct.Coop_Requested_Amount_NR__c = 14;
        insert dp0_existingDealProduct;

        // change Product Street Date
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date__c = System.today() + 1;
        p0_GamesPhysical.Previous_Street_Date__c = System.today() - 140;
        update p0_GamesPhysical;

        // Verify the data before runnig the batch
        for (Product2 product : [SELECT Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(product.Street_Date_Has_Changed__c, 'All Products should have Street Date changed as true');
        }
        List<Opportunity> dealsBeforeFirstBatchRun = [SELECT Id, Name, (SELECT ID FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(1, dealsBeforeFirstBatchRun.size());
        for (Opportunity deal : dealsBeforeFirstBatchRun) {
            System.assertEquals(d0_existingDeal.Id, deal.Id);
            System.assertEquals(1, deal.OpportunityLineItems.size());
        }

        List<Product2> productsBeforeFirstBatchRun = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(1, productsBeforeFirstBatchRun.size());
        System.assertEquals(System.today() + 1, productsBeforeFirstBatchRun[0].Street_Date__c);

        List<OpportunityLineItem> dealProductsBeforeFirstBatchRun =
            [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c, /*Coop_Requested_Amount_NR__c,*/ Product2Id,P_L_Quantity__c,
                    Quantity, OpportunityId, Opportunity.Name,Target_Quantity__c,Account_Price__c, Promoted_Price__c,
                    (SELECT Id, Quantity, Revenue,Description, ScheduleDate FROM OpportunityLineItemSchedules Order By ScheduleDate, Description)
                FROM OpportunityLineItem
            ];
        System.assertEquals(1, dealProductsBeforeFirstBatchRun.size());
        // Verify Prices
        System.assertEquals(10, dealProductsBeforeFirstBatchRun[0].Account_Price__c);
        System.assertEquals(10, dealProductsBeforeFirstBatchRun[0].Promoted_Price__c);

        System.assertEquals(2, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules.size());
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        System.assertEquals(0, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].Revenue);
        System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].Description);
        System.assertEquals(0, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[1].Quantity);
        System.assertEquals(200, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[1].Revenue);
        System.assertEquals(CRM_AppConstants.SCHEDULE_PL, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[1].Description);
        System.assertEquals(System.today() - 140, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate);
        System.assertEquals(System.today() - 140, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[1].ScheduleDate);
        System.assertEquals(dealsBeforeFirstBatchRun[0].Id, dealProductsBeforeFirstBatchRun[0].OpportunityId);
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeFirstBatchRun[0].Target_Quantity__c);
        System.assertEquals(productsBeforeFirstBatchRun[0].Id, dealProductsBeforeFirstBatchRun[0].Product2Id);

        // Verify EPos fields are populated before batch is run
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].P_L_Quantity__c);

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify a new Deal is created due to Street Date change
        List<Opportunity> dealsAfterFirstBatchRun = [SELECT Id, Name, (SELECT Id FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(2, dealsAfterFirstBatchRun.size());
        /*Datetime sDate2 =
                datetime.newInstance(
                    (productsBeforeFirstBatchRun[0].Street_Date__c).year(),
                    (productsBeforeFirstBatchRun[0].Street_Date__c).month(),
                    (productsBeforeFirstBatchRun[0].Street_Date__c).day()
                );
        String currentMonth2 = sDate2.format('MMM');*/
        Integer currentQtr =
            Decimal.valueOf(
                (productsBeforeFirstBatchRun[0].Street_Date__c).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod = CRM_AppConstants.NR_Deal_For_Quarter + ' ' + currentQtr;
        for (Opportunity deal : dealsAfterFirstBatchRun) {
            if (deal.Id == d0_existingDeal.Id) {
                System.assertEquals(0, deal.OpportunityLineItems.size());
            } else {
                System.assertEquals('New Releases Games Physical '+dealPeriod+' '+(productsBeforeFirstBatchRun[0].Street_Date__c).year()+' ' + soldToAccountGP.Name, deal.Name);
                System.assertEquals(1, deal.OpportunityLineItems.size());
            }
        }

        // Verify only one deal product is present as the deal product is cloned and created
        List<OpportunityLineItem> dealProductsAfterFirstBatchRun =
            [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c,/* Coop_Requested_Amount_NR__c,*/ P_L_Quantity__c,
                    Quantity, OpportunityId, Opportunity.Name,Target_Quantity__c,Account_Price__c,Promoted_Price__c,
                    (SELECT Id, Quantity,Revenue, ScheduleDate,Description FROM OpportunityLineItemSchedules Order By ScheduleDate, Description)
                FROM OpportunityLineItem
            ];
        System.assertEquals(1, dealProductsAfterFirstBatchRun.size());

        // Verify Account Price calculated as per new PBEP
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].Account_Price__c);

        // Verify Promoted Price copied as it is from previous Deal Product
        System.assertEquals(10, dealProductsAfterFirstBatchRun[0].Promoted_Price__c);

        // Verify the EPos Quantity is not reset and it is cloned as it is
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].P_L_Quantity__c);

        // Verify Schedules are cloned properly
        System.assertEquals(2, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules.size());
        //System.assertEquals(20, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        Date oldStreetDate = System.today()-140;
        Date oldScheduleDate = dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate;
        Integer numberDaysDifference = oldStreetDate.daysBetween(System.today()-140);

        Date nweStreetDate = p0_GamesPhysical.Street_Date__c;
        Date  newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        System.assertEquals(0, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Revenue);
        System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Description);
        System.assertEquals(0, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[1].Quantity);
        System.assertEquals(200, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[1].Revenue);
        System.assertEquals(CRM_AppConstants.SCHEDULE_PL, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[1].Description);
        System.assertEquals(newScheduleDate, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate);
        System.assertEquals(newScheduleDate, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[1].ScheduleDate);

        //System.assertEquals(dealsAfterFirstBatchRun[0].Id, dealProductsAfterFirstBatchRun[0].OpportunityId);
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].Quantity);
        System.assertEquals(10, dealProductsAfterFirstBatchRun[0].Target_Quantity__c);
    }

    /**
      Scenario Details
      1. Existing data 
           1. Account -> A0 (Sold To : GP) with Consignmetn Customer true
           2. Deals ->
                  A0
                    -> D0 (GP, Start Date = System.Today() - 40, Batch Created with Batch DP0)
           3. Deal Product -> D0 (DP0 with Quantity 20 for P0)
      2. Product ->
           1. P0 (GP, Street Date = system.today() + 1)
      3. Run the Batch -> This Clones the deal Product and calculates the Quantity based on Target available for that Period and EPos Quantity is set to 1
    */
    private static testMethod void Street_Date_Changed_Without_EPos_Quantity_For_Consignment_Customer(){
        Set<String> setProductAndAccountId = new Set<String>();
        Map<String, List<PriceBook_Entry_Period__c>> mapIdToPBEPList = new Map<String, List<PriceBook_Entry_Period__c>>();
        Set<Id> setProcessedProductIds = new Set<Id>();

        // Set up Account Data
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        System.assertEquals(1, lstAccounts.size());

        // First account is Sold To with Type Games Physical and Video Physical
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].RecordTypeId = rtAcc;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Consignment_Customer__c = true;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        if (lstAccounts[0].Games_Physical__c) {
            lstAccounts[0].Consignment_Multiplier_Games__c = 1.25;
        }
        if (lstAccounts[0].Video_Physical__c) {
            lstAccounts[0].Consignment_Multiplier_Video__c = 1.2;
        }
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
        p0_GamesPhysical.Street_Date__c = System.today() - 140;
        p0_GamesPhysical.CurrencyIsoCode = 'USD';
        p0_GamesPhysical.Type__c = 'Games Physical';
        p0_GamesPhysical.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        p0_GamesPhysical.NR_period_weeks__c = 1;
        p0_GamesPhysical.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
        p0_GamesPhysical.Local_Title__c = lstLocaTitle[0].Id;
        p0_GamesPhysical.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert p0_GamesPhysical;
        lstProduct = new List<Product2>{p0_GamesPhysical};
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];

        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);

        // Create Targets data for Games Physical Product
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        System.assertEquals(1, lstTargets.size());
        Target__c t0_GamesPhysical = lstTargets[0];
        t0_GamesPhysical.Account__c = soldToAccountGP.Id;
        t0_GamesPhysical.Product__c = p0_GamesPhysical.id;
        t0_GamesPhysical.RecordTypeId = rtTarget;
        t0_GamesPhysical.Target__c = 200;
        insert t0_GamesPhysical;

        // Create Batch created deal along with Batch created Deal Product which lies in previous month
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
        System.assertEquals(1, lstOpportunity.size());
        Opportunity d0_existingDeal = lstOpportunity[0];
        d0_existingDeal.AccountId = soldToAccountGP.Id;
        d0_existingDeal.Start_Date__c = system.today() - 140;
        d0_existingDeal.Promo_Start_Date__c = system.today() - 140;
        d0_existingDeal.CloseDate = system.today() - 135;
        d0_existingDeal.Promo_End_Date__c = system.today() - 135;
        d0_existingDeal.Name = 'Batch created Deal 0 with Unique Key with Deal Products for Product 0';
        d0_existingDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
        d0_existingDeal.CurrencyIsoCode = 'USD';
        /*Datetime sDate1 =
                datetime.newInstance(
                    (system.today() - 40).year(),
                    (system.today() - 40).month(),
                    (system.today() - 40).day()
                );
        String currentMonth1 = sDate1.format('MMM');*/
        Integer currentQtr1 =
            Decimal.valueOf(
                (system.today()-140).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod1 = CRM_AppConstants.NR_Deal_For_Quarter + currentQtr1;
        d0_existingDeal.NR_Deal_Unique_Key__c = soldToAccountGP.Id + '-' + dealPeriod1+ '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(p0_GamesPhysical.Type__c);
        d0_existingDeal.Product_Type__c = 'Games Physical';
        d0_existingDeal.RecordTypeId = physicalDealRecordTypeId;
        insert d0_existingDeal;

        // Setting up 1 Price Book Entry record for one created Product
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForNRBatch(lstProduct);
        System.assertEquals(1, lstPriceBookEntry.size());

        // Setting up 1 Price Book Entry Period record for each created Product and PriceBookEntry
        // such that the Deal Start Date lies between the PriceBookEntryPeriod Start and End Date
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriodCreated
            = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c existingDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        existingDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        existingDealPriceBookPeriod.Start_Date__c = System.today()-140;
        existingDealPriceBookPeriod.End_Date__c = System.today()-140;
        existingDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        existingDealPriceBookPeriod.List_Price__c = 10;

        lstPriceBookEntryPeriodCreated =
            CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{p0_GamesPhysical}, 1, false);
        Pricebook_Entry_Period__c streetDateChangeCurrentMonthDealPriceBookPeriod = lstPriceBookEntryPeriodCreated[0];
        streetDateChangeCurrentMonthDealPriceBookPeriod.Product__c = p0_GamesPhysical.id;
        streetDateChangeCurrentMonthDealPriceBookPeriod.Start_Date__c = System.today().toStartOfMonth();
        streetDateChangeCurrentMonthDealPriceBookPeriod.End_Date__c = System.today()+30;
        streetDateChangeCurrentMonthDealPriceBookPeriod.CurrencyIsoCode = 'USD';
        streetDateChangeCurrentMonthDealPriceBookPeriod.List_Price__c = 20;

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod =
            new List<Pricebook_Entry_Period__c>{existingDealPriceBookPeriod, streetDateChangeCurrentMonthDealPriceBookPeriod};
        insert lstPriceBookEntryPeriod;

        for(Integer i=0 ; i<lstPriceBookEntryPeriod.size() ; i++){
            String strKey = lstPriceBookEntryPeriod[i].Product__c + '-' + lstPriceBookEntryPeriod[i].Price_Book__c + '-' + lstPriceBookEntryPeriod[i].CurrencyIsoCode;
            if (mapIdToPBEPList.containsKey(strKey)) {
                mapIdToPBEPList.get(strKey).add(lstPriceBookEntryPeriod[i]);
            } else {
                mapIdToPBEPList.put(strKey, new List<Pricebook_Entry_Period__c>{lstPriceBookEntryPeriod[i]});
            }
        }

        // Setting up Deal Product data such that batch deal Product already present for the above Deal D0
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, new List<Opportunity>{d0_existingDeal}, 1, false);
        System.assertEquals(1, lstDealProduct.size());
        OpportunityLineItem dp0_existingDealProduct = lstDealProduct[0];
        dp0_existingDealProduct.NR_Deal_Product_Unique_Key__c = soldToAccountGP.Id + '-' + p0_GamesPhysical.Id;
        dp0_existingDealProduct.PriceBookEntryId = lstPriceBookEntry[0].Id;
        dp0_existingDealProduct.Quantity = 20;
        dp0_existingDealProduct.Comments__c = 'Test Coop Comment';
        dp0_existingDealProduct.Coop__c = 12;
        dp0_existingDealProduct.Account_Price__c = 10;
        dp0_existingDealProduct.Promoted_Price__c = 10;
        dp0_existingDealProduct.Reason__c = 'Advertizing';
       // dp0_existingDealProduct.Coop_Requested_Amount_NR__c = 14;
        insert dp0_existingDealProduct;

        List<OpportunityLineItem> dealProductsBeforeFirstBatchRun =
            [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c, /*Coop_Requested_Amount_NR__c,*/ Product2Id,P_L_Quantity__c,
                    Quantity, OpportunityId, Opportunity.Name,Target_Quantity__c,
                    (SELECT Id, Quantity, Revenue,Description, ScheduleDate FROM OpportunityLineItemSchedules Order By ScheduleDate, Description)
                FROM OpportunityLineItem
            ];
        System.assertEquals(1, dealProductsBeforeFirstBatchRun.size());
        dealProductsBeforeFirstBatchRun[0].P_L_Quantity__c = null;
        update dealProductsBeforeFirstBatchRun;

        // change Product Street Date
        p0_GamesPhysical.NR_Product_Created__c = false;
        p0_GamesPhysical.Street_Date__c = System.today() + 1;
        p0_GamesPhysical.Previous_Street_Date__c = System.today() - 140;
        update p0_GamesPhysical;

        // Verify the data before runnig the batch
        for (Product2 product : [SELECT Street_Date_Has_Changed__c FROM Product2]) {
            System.assert(product.Street_Date_Has_Changed__c, 'All Products should have Street Date changed as true');
        }
        List<Opportunity> dealsBeforeFirstBatchRun = [SELECT Id, Name, (SELECT ID FROM OpportunityLineItems) FROM Opportunity];
        System.assertEquals(1, dealsBeforeFirstBatchRun.size());
        for (Opportunity deal : dealsBeforeFirstBatchRun) {
            System.assertEquals(d0_existingDeal.Id, deal.Id);
            System.assertEquals(1, deal.OpportunityLineItems.size());
        }

        List<Product2> productsBeforeFirstBatchRun = [SELECT Id, Street_Date__c FROM Product2];
        System.assertEquals(1, productsBeforeFirstBatchRun.size());
        System.assertEquals(System.today() + 1, productsBeforeFirstBatchRun[0].Street_Date__c);

        // Verify EPos field is not populated before batch is run
        System.assertEquals(null, dealProductsBeforeFirstBatchRun[0].P_L_Quantity__c);
        dealProductsBeforeFirstBatchRun = [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c, /*Coop_Requested_Amount_NR__c,*/ Product2Id,P_L_Quantity__c,
                    Quantity, OpportunityId, Opportunity.Name,Target_Quantity__c,
                    (SELECT Id, Quantity, Revenue,Description, ScheduleDate FROM OpportunityLineItemSchedules Order By ScheduleDate, Description)
                FROM OpportunityLineItem
        ];
        System.assertEquals(1, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules.size());
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        System.assertEquals(200, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].Revenue);
        System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].Description);
        System.assertEquals(System.today() - 140, dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate);
        System.assertEquals(dealsBeforeFirstBatchRun[0].Id, dealProductsBeforeFirstBatchRun[0].OpportunityId);
        System.assertEquals(20, dealProductsBeforeFirstBatchRun[0].Quantity);
        System.assertEquals(0, dealProductsBeforeFirstBatchRun[0].Target_Quantity__c);
        System.assertEquals(productsBeforeFirstBatchRun[0].Id, dealProductsBeforeFirstBatchRun[0].Product2Id);

        Test.startTest();
        CRM_AutoPhysicalNRDealCreationBatch automaticNRDealCreationBatch = new CRM_AutoPhysicalNRDealCreationBatch();
        CRM_AutoPhysicalNRDealCreationService.processNRProductRecords(fetchSoldToAccounts(), automaticNRDealCreationBatch.getNRProducts() , mapIdToPBEPList, setProcessedProductIds );
        Test.stopTest();

        // Verify a new Deal is created due to Street Date change
        List<Opportunity> dealsAfterFirstBatchRun = [SELECT Id, Name, (SELECT Id FROM OpportunityLineItems) FROM Opportunity ORDER BY CreatedDate DESC];
        System.assertEquals(2, dealsAfterFirstBatchRun.size());
        /*Datetime sDate2 =
                datetime.newInstance(
                    (productsBeforeFirstBatchRun[0].Street_Date__c).year(),
                    (productsBeforeFirstBatchRun[0].Street_Date__c).month(),
                    (productsBeforeFirstBatchRun[0].Street_Date__c).day()
                );
        String currentMonth2 = sDate2.format('MMM');*/
        Integer currentQtr =
            Decimal.valueOf(
                (productsBeforeFirstBatchRun[0].Street_Date__c).toStartOfMonth().month()
            ).divide(3.0, 0, System.RoundingMode.UP).intValue();
        String dealPeriod = CRM_AppConstants.NR_Deal_For_Quarter + ' ' + currentQtr;
        for (Opportunity deal : dealsAfterFirstBatchRun) {
            if (deal.Id == d0_existingDeal.Id) {
                System.assertEquals(0, deal.OpportunityLineItems.size());
            } else {
                System.assertEquals('New Releases Games Physical '+dealPeriod+' '+(productsBeforeFirstBatchRun[0].Street_Date__c).year()+' ' + soldToAccountGP.Name, deal.Name);
                System.assertEquals(1, deal.OpportunityLineItems.size());
            }
        }

        // Verify only one deal product is present as the deal product is cloned and created
        List<OpportunityLineItem> dealProductsAfterFirstBatchRun =
            [
                SELECT
                    Id, Comments__c, Coop__c, Reason__c, /*Coop_Requested_Amount_NR__c,*/ P_L_Quantity__c,
                    Quantity, OpportunityId, Opportunity.Name,Target_Quantity__c,
                    (SELECT Id, Quantity,Revenue, ScheduleDate,Description FROM OpportunityLineItemSchedules Order By ScheduleDate, Description)
                FROM OpportunityLineItem
            ];
        System.assertEquals(1, dealProductsAfterFirstBatchRun.size());

        // Verify the EPos Quantity is set 1 as it was null
        System.assertEquals(1, dealProductsAfterFirstBatchRun[0].P_L_Quantity__c);

        // Verify Schedules are cloned properly
        System.assertEquals(2, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules.size());
        //System.assertEquals(20, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        Date oldStreetDate = System.today()-140;
        Date oldScheduleDate = dealProductsBeforeFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate;
        Integer numberDaysDifference = oldStreetDate.daysBetween(System.today()-140);

        Date nweStreetDate = p0_GamesPhysical.Street_Date__c;
        Date  newScheduleDate = nweStreetDate.addDays(numberDaysDifference);
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Quantity);
        System.assertEquals(0, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Revenue);
        System.assertEquals(CRM_AppConstants.SCHEDULE_INITIAL, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].Description);
        System.assertEquals(0, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[1].Quantity);
        System.assertEquals(10, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[1].Revenue);
        System.assertEquals(CRM_AppConstants.SCHEDULE_PL, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[1].Description);
        System.assertEquals(newScheduleDate, dealProductsAfterFirstBatchRun[0].OpportunityLineItemSchedules[0].ScheduleDate);
        //System.assertEquals(dealsAfterFirstBatchRun[0].Id, dealProductsAfterFirstBatchRun[0].OpportunityId);
        System.assertEquals(20, dealProductsAfterFirstBatchRun[0].Quantity);
        System.assertEquals(10, dealProductsAfterFirstBatchRun[0].Target_Quantity__c);
    }

    @TestVisible
    private static List<Account> createAccountsForNRBatch(Integer numberOfAcounts){
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());

        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(numberOfAcounts,false);
        /*Setting Up the Account Data*/
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].recordTypeId = rtAcc;
            lstAccounts[i].CurrencyIsoCode = 'USD';
            if (i == 0) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Sales_Organization__c = '6000';
                lstAccounts[i].Owner_Games__c = UserInfo.getUserId();
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            } else if (i == 1) {
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Owner_Games__c = UserInfo.getUserId();
                lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
                lstAccounts[i].Storefront__c = storefronts[0].Id;
            } else if (i == 2) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Sales_Organization__c = '6000';
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            } else if (i == 3) {
                lstAccounts[i].Video_Digital__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
                lstAccounts[i].Storefront__c = storefronts[0].Id;
            } else if (i == 4) {
                lstAccounts[i].Video_Digital__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
                lstAccounts[i].Storefront__c = storefronts[0].Id;
            } else {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = false;
            }
        }
        insert lstAccounts;
        System.assertEquals(numberOfAcounts, lstAccounts.size());

        System.debug('lstAccounts.size()::'+lstAccounts.size());
        return lstAccounts;
    }

    @TestVisible
    private static List<Product2> createProductsForNRBatch(List<Product_Group__c> lstProGrp, List<Account> lstAccounts){
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
        /*Setting up the product data
        lstProduct[0].Type__c = 'Games Physical';
        lstProduct[1].Type__c = 'Games Digital';
        lstProduct[2].Type__c = 'Video Physical';
        lstProduct[3].Type__c = 'Video Digital EST';
        lstProduct[4].Type__c = 'Video Digital VODi';*/
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
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            lstProduct[i].Street_Date__c = system.today()+1;
            lstProduct[i].NR_Product_Created__c = true;
            lstProduct[i].Street_Date_Has_Changed__c = false;
            lstProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
            //lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstProduct[i].CurrencyIsoCode = 'USD';
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].RecordTypeId = physicalProductRecordTypeId;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            } else if (i == 1) {
                lstProduct[i].Type__c = 'Games Digital';
                lstProduct[i].RecordTypeId = physicalProductRecordTypeId;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            }else if (i == 2) {
                lstProduct[i].Type__c = 'Video Physical';
                lstProduct[i].RecordTypeId = physicalProductRecordTypeId;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Digital EST';
                lstProduct[i].RecordTypeId = digitalProductRecordTypeId;
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Video Digital VODi';
                lstProduct[i].RecordTypeId = digitalProductRecordTypeId;
            } else {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].RecordTypeId = physicalProductRecordTypeId;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            }
        }
        insert lstProduct;
        System.debug('lstProduct::'+lstProduct.size());
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        return lstProduct;
    }

    @TestVisible
    private static List<Target__c> createTargetsForNRBatch(List<Account> lstAccounts, List<Product2> lstProduct, List<Product_Group__c> lstProGrp){
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = createAccountPlan(1, lstCountryPlan, lstAccounts, true);
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts , lstProGrp , lstAccountPlan, false);
        for(Integer i=0 ;i<lstTargets.size();i++){
            lstTargets[i].Target__c = 50;
            lstTargets[i].Account__c = lstAccounts[i].Id;
            lstTargets[i].Product__c = lstProduct[i].id;
            lstTargets[i].RecordTypeId = rtTarget;
        } 
        insert lstTargets;
        System.debug('lstTargets::'+lstTargets);
        return lstTargets;
    }

    @TestVisible
    private static List<Opportunity> createMultipleDealsForSingleAccountAndProduct(
            List<Opportunity> lstOpportunity, List<Account> lstAccounts, List<Product2> lstProduct, List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod){
        Map<Id, Pricebook_Entry_Period__c> mapProdIdToPBEP = new Map<Id, Pricebook_Entry_Period__c>();
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            mapProdIdToPBEP.put(pbep.Product__c, pbep);
        }
        /*Setting up opportunity Data*/
        for(Integer i=0 ;i<lstOpportunity.size();i++){
            String dealUniqueKey = '';
            String dealPeriod = '';
            Date releaseDate;
            Map<String, Date> mapStartAndCloseDateForDeal = new Map<String, Date>();
            if (lstProduct[0].RecordTypeId == physicalProductRecordTypeId) {
                releaseDate = lstProduct[0].Street_Date__c;
            } else {
                releaseDate = mapProdIdToPBEP.get(lstProduct[0].Id).Start_Date__c;
            }
            if (
                    lstAccounts[0].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    lstAccounts[0].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    lstAccounts[0].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE
            ) {
                mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(releaseDate, 'Q');
                Integer currentQtr =
                    Decimal.valueOf(
                        releaseDate.toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = 'Q' + currentQtr;
            } else {
                mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(releaseDate, 'M');
                Datetime sDate =
                    datetime.newInstance(
                        releaseDate.year(),
                        releaseDate.month(),
                        releaseDate.day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
            }
            dealUniqueKey = lstAccounts[0].Id + '-' + dealPeriod + '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(lstProduct[0].Type__c);
            lstOpportunity[i].AccountId = lstAccounts[0].Id;
            lstOpportunity[i].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
            lstOpportunity[i].CurrencyIsoCode = 'USD';
            lstOpportunity[i].NR_Deal_Unique_Key__c = dealUniqueKey;
            String strdealProductType = '';
            String dealRecordTypeId = '';
            if (lstProduct[0].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = lstProduct[0].Type__c;
            }
            lstOpportunity[i].Product_Type__c = strdealProductType;
            if (digitalDealRecordTypeId != null && physicalDealRecordTypeId != null) {
                if(lstOpportunity[i].Product_Type__c!= null){
                    if(lstOpportunity[i].Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || lstOpportunity[i].Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                        lstOpportunity[i].RecordtypeId = digitalDealRecordTypeId;
                    }else{
                        lstOpportunity[i].RecordtypeId = physicalDealRecordTypeId;
                    }
                }
            }
        }
        System.debug('lstOpportunity::'+lstOpportunity);
        insert lstOpportunity;
        System.debug('lstOpportunity::'+lstOpportunity.size());
        return lstOpportunity;
    }

    @TestVisible
    private static List<Opportunity> createDealsForNRBatch(
            List<Opportunity> lstOpportunity, List<Account> lstAccounts,
            List<Product2> lstProduct, List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod
    ){
        Map<Id, Pricebook_Entry_Period__c> mapProdIdToPBEP = new Map<Id, Pricebook_Entry_Period__c>();
        for (Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod) {
            mapProdIdToPBEP.put(pbep.Product__c, pbep);
        }
        /*Setting up opportunity Data*/
        for(Integer i=0 ;i<lstOpportunity.size();i++){
            String dealUniqueKey = '';
            String dealPeriod = '';
            Date releaseDate;
            Map<String, Date> mapStartAndCloseDateForDeal = new Map<String, Date>();
            if (lstProduct[i].RecordTypeId == physicalProductRecordTypeId) {
                releaseDate = lstProduct[i].Street_Date__c;
            } else {
                releaseDate = mapProdIdToPBEP.get(lstProduct[i].Id).Start_Date__c;
            }
            if (
                    lstAccounts[i].Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE ||
                    lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE ||
                    lstAccounts[i].Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE
            ) {
                mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(releaseDate, 'Q');
                Integer currentQtr =
                    Decimal.valueOf(
                        releaseDate.toStartOfMonth().month()
                    ).divide(3.0, 0, System.RoundingMode.UP).intValue();
                dealPeriod = 'Q' + currentQtr;
            } else {
                mapStartAndCloseDateForDeal = CRM_AutoPhysicalNRDealCreationService.calculateDatesForDeal(releaseDate, 'M');
                Datetime sDate =
                    datetime.newInstance(
                        releaseDate.year(),
                        releaseDate.month(),
                        releaseDate.day()
                    );
                String currentMonth = sDate.format('MMM');
                dealPeriod = currentMonth;
            }

            dealUniqueKey = lstAccounts[i].Id + '-' + dealPeriod + '-' + CRM_AutoPhysicalNRDealCreationService.fetchProductTypeShortName(lstProduct[i].Type__c);
            lstOpportunity[i].AccountId = lstAccounts[i].Id;
            lstOpportunity[i].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
            lstOpportunity[i].CurrencyIsoCode = 'USD';
            lstOpportunity[i].NR_Deal_Unique_Key__c = dealUniqueKey;
            String strdealProductType = '';
            String dealRecordTypeId = '';
            if (lstProduct[i].Type__c.contains(CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE)) {
                strdealProductType = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            } else {
                strdealProductType = lstProduct[i].Type__c;
            }
            lstOpportunity[i].Product_Type__c = strdealProductType;
            if (digitalDealRecordTypeId != null && physicalDealRecordTypeId != null) {
                if(lstOpportunity[i].Product_Type__c!= null){
                    if(lstOpportunity[i].Product_Type__c == CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE || lstOpportunity[i].Product_Type__c == CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE){
                        lstOpportunity[i].RecordtypeId = digitalDealRecordTypeId;
                    }else{
                        lstOpportunity[i].RecordtypeId = physicalDealRecordTypeId;
                    }
                }
            }
        }
        System.debug('lstOpportunity::'+lstOpportunity);
        insert lstOpportunity;
        System.debug('lstOpportunity::'+lstOpportunity.size());
        return lstOpportunity;
    }

    @TestVisible
    private static List<PricebookEntry> createPriceBookEntryForNRBatch(List<Product2> lstProduct){
        /*Setting up PriceBookEntry Data*/
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        for(Integer i=0 ;i<lstPriceBookEntry.size();i++){
            lstPriceBookEntry[i].Product2Id = lstProduct[i].id;
        }
        insert lstPriceBookEntry;
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry.size());
        return lstPriceBookEntry;
    }

    @TestVisible
    private static List<Pricebook_Entry_Period__c> createPriceBookEntryPeriodForNRBatch(List<PricebookEntry> lstPriceBookEntry, List<Product2> lstProduct){
        /*Setting up PriceBookEntryPeriod Data*/
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        /*Setting up PriceBookEntryPeriod Data*/
        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = lstProduct[i].id;
            lstPriceBookEntryPeriod[i].Start_Date__c = System.today() + 1;
            lstPriceBookEntryPeriod[i].End_Date__c = System.today() + 140;
            lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'USD';
            System.debug('--lstProduct[i].RecordTypeId-->'+lstProduct[i].RecordTypeId);
            if (lstProduct[i].RecordTypeId == digitalProductRecordTypeId) {
                lstPriceBookEntryPeriod[i].New_Release__c = true;
            }
        }
        insert lstPriceBookEntryPeriod;
        return lstPriceBookEntryPeriod;
    }

    /**
     * createAccountPlan(Integer,List<Country_Plan__c>,List<Account>)
     * This method is called to create account plan for a test class.
    */      
    public static list<Account_Plan__c> createAccountPlan(Integer numAccountPlan,List<Country_Plan__c> lstCountryPlan,List<Account> lstAccount, Boolean shouldInsert) {
        if (lstCountryPlan.size() != lstAccount.size()) {
            return null;
        }
        List<Account_Plan__c> accountPlanList = new List<Account_Plan__c>();
        for (Integer i=0; i<lstCountryPlan.size(); i++) {
            for (Integer j=0; j < numAccountPlan; j++) {
                Account_Plan__c accountPlan = new Account_Plan__c();
                accountPlan.Country_Plan__c = lstCountryPlan[i].Id;
                accountPlan.Customer__c = lstAccount[i].Id;
                accountPlan.CurrencyIsoCode = 'USD';
                accountPlan.Share__c = 10 + i + j;
                accountPlanList.add(accountPlan);
            }
        }
        if(accountPlanList!= null && accountPlanList.size() > 0 && shouldInsert)
            insert accountPlanList;

        return accountPlanList;
    }

    public class CRM_AutoPhysicalNRDealCreationService_TestWrapper {
        public List<Account> lstAccounts;
        public List<Opportunity> lstOpportunity;
        public List<Target__c> lstTargets;
        public List<Product2> lstProduct;
        public List<PricebookEntry> lstPriceBookEntry;
        public List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod;
    }
}//End of Class