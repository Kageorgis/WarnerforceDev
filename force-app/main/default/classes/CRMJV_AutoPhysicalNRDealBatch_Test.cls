/**
@Author Cognizant
@name CRMJV_AutoPhysicalNRDealBatch_Test
@CreateDate 13 Jan 2021
@Description: Batch Test class to JV NR Physical batch and service class.
@Version <1.0> 
@reference: W-017644, W-017678 - Automatic New Release Deals - Planning, DFI, POSADV deals
*/
@IsTest
public class CRMJV_AutoPhysicalNRDealBatch_Test{

    private static Map<Id,String> mapDealRecordTypeToShortName = new Map<Id,String>();
    static{
        mapDealRecordTypeToShortName.put(CRM_RecordTypeUtil.RT_Physical_POS_Deal, System.Label.CRM_ADVPOS_Deal_Type_Short_Name);
        mapDealRecordTypeToShortName.put(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, System.Label.CRM_DFI_Deal_Type_Short_Name);
        mapDealRecordTypeToShortName.put(CRM_RecordTypeUtil.RT_Physical_Planning_Deal, System.Label.CRM_Planning_Deal_Type_Short_Name);
    }

    // Testsetup method to Create data for JV
    @TestSetup    
    public static void createDataForJV(){
        // Creating Pricebook SDS - US
        Pricebook2 JVPricebook = new Pricebook2(
            Name='SDS - US',
            IsActive=true,
            Business_Unit__c = CRM_AppConstants.TERRITORY_SDS_US_CODE,
            External_Id__c = CRM_AppConstants.TERRITORY_SDS_US_CODE + '-10',
            Product_Type__c='Physical',
            Country__c = 'USA',
            Currency__c = 'USD',
            CurrencyIsoCode = 'USD'
        );
        insert JVPricebook;
        system.assertNotEquals(null, JVPricebook);

        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 7, true);
        lstDecayCurveTemplate[0].Status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate;
        
        // Inserting JV Account
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].AccountNumber = '1010101010';
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUTil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Planning_Customer__c = true;
        lstAccounts[0].Video_Physical__c = true;
        lstAccounts[0].Games_Physical__c = false;
        lstAccounts[0].Class_of_Trade__c = 'Wholesale 5';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
        lstAccounts[0].Price_Book__c = JVPricebook.id;
        lstAccounts[0].CurrencyIsoCode = 'USD';
        lstAccounts[0].Decay_Curve_Template__c = lstDecayCurveTemplate[0].Id;
        insert lstAccounts;
        system.assertEquals(CRM_AppConstants.TERRITORY_SDS_US_CODE, lstAccounts[0].Sales_Organization__c);
        system.assertEquals(1,lstAccounts.size());
        
       
        //Creating Product Group and Products
        Integer i = 1;
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 2, false);
        for(Product2 prodInstance : lstProduct){
            prodInstance.Type__c = 'Video Physical';
            prodInstance.ProductCode = '100123123'+String.valueOf(i);
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prodInstance.NR_Product_Created__c = true;
            prodInstance.Street_Date_Has_Changed__c = false;
            prodInstance.Exclusive_Customer__c = null;
            prodInstance.CurrencyIsoCode = 'USD';
            prodInstance.NR_period_weeks__c = 26;
            prodInstance.Street_Date__c = Date.newInstance(System.today().year(), System.today().addMonths(i).month(), System.today().day());
            i++;
        }
        insert lstProduct;
        List<Product2> lstProductUpd = new List<Product2>();
        for(Product2 p : [Select id,Type__c From Product2]){
            p.Type__c = 'Video Physical';
            lstProductUpd.add(p);
        }
        update lstProductUpd;

        for(Product2 p : [Select ProductCode,Type__c,NR_Product_Created__c,Street_Date_Has_Changed__c From Product2]){
            system.debug('@@Test P-->'+p);
            system.assertEquals(true,p.NR_Product_Created__c);
            system.assertEquals(false,p.Street_Date_Has_Changed__c);
            system.assertEquals('Video Physical',p.Type__c);
        }
        
        // Creating Product Traget for JV product
        List<Target__c> lstTargets = createTargetsForJVNRBatch(lstAccounts,lstProduct);
        for(Target__c t: lstTargets){
            System.assert(!t.Target_Revenue_Has_Changed__c, 'Target Revenue has changed should be false');
        }
        
        // Creating PricebookEntry for JV
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        System.assertEquals(2,lstPriceBookEntries.size());
        
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries){
            pbe.Pricebook2Id = JVPricebook.id;
        }
        insert customLstPriceBookEntries;
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : lstPriceBookEntryPeriod){
            pebp.Price_Type__c = 'WHOLESALE 5';
            pebp.Start_Date__c = Date.newInstance(2020, 01, 01);   //System.today().addMonths(-2);  //Date.newInstance(System.today().year(), System.today().addMonths(-2).month(), System.today().day());
            pebp.End_Date__c = Date.newInstance(4000, 12, 31);   //System.today().addMonths(7); //Date.newInstance(System.today().year(), System.today().addMonths(4).month(), System.today().day());
            pebp.Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            pebp.Price_Book__c = JVPricebook.id;
            pebp.Process_NR_Batch__c = true;
        }
        insert lstPriceBookEntryPeriod;
        System.assertEquals(2,lstPriceBookEntryPeriod.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod1= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = Date.newInstance(2020, 01, 01);   //System.today().addMonths(-2);  //Date.newInstance(System.today().year(), System.today().addMonths(-2).month(), System.today().day());
            pebp.End_Date__c = Date.newInstance(4000, 12, 31);   //System.today().addMonths(7); //Date.newInstance(System.today().year(), System.today().addMonths(4).month(), System.today().day());
            pebp.Price_Book__c = JVPricebook.id;
            pebp.Process_NR_Batch__c = true;
        }
        insert pricebookentryPeriod1;
        System.assertEquals(2,pricebookentryPeriod1.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c = Date.newInstance(2020, 01, 01);   //System.today().addMonths(-2);  //Date.newInstance(System.today().year(), System.today().addMonths(-2).month(), System.today().day());
            pebp.End_Date__c = Date.newInstance(4000, 12, 31);   //System.today().addMonths(7); //Date.newInstance(System.today().year(), System.today().addMonths(4).month(), System.today().day());
            pebp.Price_Book__c = JVPricebook.id;
            pebp.Process_NR_Batch__c = true;
        }
        insert pricebookentryPeriod2;
        System.assertEquals(2,pricebookentryPeriod2.size());

        for(Pricebook_Entry_Period__c p: [Select Process_NR_Batch__c,Product__r.ProductCode,Price_Book__c,CurrencyIsoCode,Price_Type__c,Start_Date__c,End_Date__c From Pricebook_Entry_Period__c]){
            System.assert(p.Process_NR_Batch__c);
        }

        //Creating custom setting to send email notification to user 
        Batch_Notification_Recipients__c bnr = new Batch_Notification_Recipients__c();
        bnr.Name='Rahul Kumar Chakalasiya';
        bnr.Entity__c='CRM';
        bnr.User_Email_Id__c='rahulkumar.chakalasiya@cognizant.com';
        insert bnr;  
    }

    public static testMethod void testCreatingNewNRDeal(){
        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        
        //System.assertEquals(6, [SELECT Id FROM Opportunity].size());
        //System.assertEquals(6, [SELECT Id FROM OpportunityLineItem].size());
        //System.assertEquals(2, [SELECT Id FROM Product2 Where NR_Product_Created__c = false and Street_Date_Has_Changed__c = false].size());
    }

    public static testMethod void testProductReleaseDateChangeNRDeal(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct1 = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate1 = lstProduct1[0].Street_Date__c;
        Map<String,Date> dealDate1 = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate1,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate1 = datetime.newInstance(prodReleaseDate1.year(),prodReleaseDate1.month(),prodReleaseDate1.day());
        String dealPeriod1 = sDate1.format('MMM')+String.valueOf(prodReleaseDate1.year());
        
        //Creating Deal
        integer numOfOpp = 3;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, numOfOpp, false);
        for(integer i = 0; i < numOfOpp; i++){
            Opportunity deal = lstDeals[i];
            deal.RecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;    //OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate1.get('Start Date');
            deal.Promo_End_Date__c =  dealDate1.get('End Date');
            deal.Start_Date__c = dealDate1.get('Start Date');
            deal.CloseDate = dealDate1.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod1 + '-VP-'+mapDealRecordTypeToShortName.get(deal.RecordTypeId);
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[1].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(integer i = 0; i < numOfOpp; i++){
            id dealRecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            OpportunityLineItem oli = lstDealProduct[i];
            oli.OpportunityId = lstDeals[i].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct1[0].Id + '-'+mapDealRecordTypeToShortName.get(dealRecordTypeId);
            oli.Start_Date__c = dealDate1.get('Start Date');
            oli.End_Date__c = dealDate1.get('End Date');
            if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
                oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
            }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
            }
        }
        insert lstDealProduct;
        system.assertEquals(3, [Select Product_Code__c,NR_Deal_Product_Unique_Key__c From OpportunityLineItem where Product_Code__c = '1001231231'].size());
        
        List<Product2> lstProducts = new List<Product2>();
        for(Product2 p : [Select Id,NR_Product_Created__c,Street_Date__c From Product2 where ProductCode = '1001231232' Limit 1]){
            p.Street_Date__c = p.Street_Date__c.addMonths(-1);
            p.NR_Product_Created__c = false;
            lstProducts.add(p);
        }
        update lstProducts;

        Date prodReleaseDate;
        for(Product2 p : [Select NR_Product_Created__c,Street_Date_Has_Changed__c,Street_Date__c From Product2 where ProductCode = '1001231232']){
            system.assertEquals(false,p.NR_Product_Created__c);
            system.assertEquals(true,p.Street_Date_Has_Changed__c);
            prodReleaseDate = p.Street_Date__c;
        }

        Test.startTest();
        Id batchId1 = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        //System.assertEquals(3, [SELECT Id FROM Opportunity Where Count_Opportunity_Products__c = 2].size());
        // for(Opportunity o: [Select NR_Deal_Unique_Key__c,Count_Opportunity_Products__c From Opportunity]){
        //     system.debug('@@@--->'+o.NR_Deal_Unique_Key__c+'--'+o.Count_Opportunity_Products__c);
        // }
    }

    public static testMethod void testProductReleaseDateChangeSameMonthNRDeal(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct1 = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate1 = lstProduct1[0].Street_Date__c;
        Map<String,Date> dealDate1 = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate1,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate1 = datetime.newInstance(prodReleaseDate1.year(),prodReleaseDate1.month(),prodReleaseDate1.day());
        String dealPeriod1 = sDate1.format('MMM')+String.valueOf(prodReleaseDate1.year());
        
        //Creating Deal
        integer numOfOpp = 3;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, numOfOpp, false);
        for(integer i = 0; i < numOfOpp; i++){
            Opportunity deal = lstDeals[i];
            deal.RecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;    //OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate1.get('Start Date');
            deal.Promo_End_Date__c =  dealDate1.get('End Date');
            deal.Start_Date__c = dealDate1.get('Start Date');
            deal.CloseDate = dealDate1.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod1 + '-VP-'+mapDealRecordTypeToShortName.get(deal.RecordTypeId);
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[1].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(integer i = 0; i < numOfOpp; i++){
            id dealRecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            OpportunityLineItem oli = lstDealProduct[i];
            oli.OpportunityId = lstDeals[i].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = false;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct1[0].Id + '-'+mapDealRecordTypeToShortName.get(dealRecordTypeId);
            oli.Start_Date__c = dealDate1.get('Start Date');
            oli.End_Date__c = dealDate1.get('End Date');
            if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
                oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
            }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
            }
        }
        insert lstDealProduct;
        system.assertEquals(3, [Select Product_Code__c,NR_Deal_Product_Unique_Key__c From OpportunityLineItem where Product_Code__c = '1001231231'].size());
        
        Integer dayNumber = System.today().day() == 10 ? 11 : 10;
        List<Product2> lstProducts = new List<Product2>();
        for(Product2 p : [Select Id,NR_Product_Created__c,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1]){
            //p.Street_Date__c = p.Street_Date__c.addDays(-1);
            p.Street_Date__c = Date.newInstance(p.Street_Date__c.year(), p.Street_Date__c.month(), dayNumber);
            p.NR_Product_Created__c = false;
            lstProducts.add(p);
        }
        update lstProducts;

        for(Product2 p : [Select NR_Product_Created__c,Street_Date_Has_Changed__c,Street_Date__c From Product2 where ProductCode = '1001231231']){
            system.assertEquals(false,p.NR_Product_Created__c);
            system.assertEquals(true,p.Street_Date_Has_Changed__c);
        }

        Test.startTest();
        Id batchId1 = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        //System.assertEquals(6, [SELECT Id FROM Opportunity Where Count_Opportunity_Products__c = 1].size());
    }

    public static testMethod void testProductReleaseDateChangeSameMonthWithSchedule(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct1 = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate1 = lstProduct1[0].Street_Date__c;
        Map<String,Date> dealDate1 = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate1,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate1 = datetime.newInstance(prodReleaseDate1.year(),prodReleaseDate1.month(),prodReleaseDate1.day());
        String dealPeriod1 = sDate1.format('MMM')+String.valueOf(prodReleaseDate1.year());
        
        //Creating Deal
        integer numOfOpp = 3;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, numOfOpp, false);
        for(integer i = 0; i < numOfOpp; i++){
            Opportunity deal = lstDeals[i];
            deal.RecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;    //OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate1.get('Start Date');
            deal.Promo_End_Date__c =  dealDate1.get('End Date');
            deal.Start_Date__c = dealDate1.get('Start Date');
            deal.CloseDate = dealDate1.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod1 + '-VP-'+mapDealRecordTypeToShortName.get(deal.RecordTypeId);
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[1].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(integer i = 0; i < numOfOpp; i++){
            id dealRecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            OpportunityLineItem oli = lstDealProduct[i];
            oli.OpportunityId = lstDeals[i].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct1[0].Id + '-'+mapDealRecordTypeToShortName.get(dealRecordTypeId);
            oli.Start_Date__c = dealDate1.get('Start Date');
            oli.End_Date__c = dealDate1.get('End Date');
            if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
                oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
            }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
            }
            oli.Initial_Ship_Fcst__c = 1000;
            oli.Replen_Ship_Fcst__c = 200;
            oli.Manually_Schedule__c = false;
        }
        insert lstDealProduct;
        system.assertEquals(3, [Select Product_Code__c,NR_Deal_Product_Unique_Key__c From OpportunityLineItem where Product_Code__c = '1001231231'].size());
        
        Integer dayNumber = System.today().day() == 10 ? 11 : 10;
        List<Product2> lstProducts = new List<Product2>();
        for(Product2 p : [Select Id,NR_Product_Created__c,Street_Date__c,CanUseQuantitySchedule,CanUseRevenueSchedule From Product2 where ProductCode = '1001231231' Limit 1]){
            //p.Street_Date__c = p.Street_Date__c.addDays(-1);
            p.Street_Date__c = Date.newInstance(p.Street_Date__c.year(), p.Street_Date__c.month(), dayNumber);
            p.NR_Product_Created__c = false;
            p.CanUseQuantitySchedule = true;
            p.CanUseRevenueSchedule = true;
            lstProducts.add(p);
        }
        update lstProducts;

        for(Product2 p : [Select NR_Product_Created__c,Street_Date_Has_Changed__c,Street_Date__c,CanUseQuantitySchedule,CanUseRevenueSchedule From Product2 where ProductCode = '1001231231']){
            system.assertEquals(false,p.NR_Product_Created__c);
            system.assertEquals(true,p.Street_Date_Has_Changed__c);
            system.assertEquals(true,p.CanUseQuantitySchedule);
            system.assertEquals(true,p.CanUseRevenueSchedule);
        }

        Test.startTest();
        Id batchId1 = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        //System.assertEquals(6, [SELECT Id FROM Opportunity Where Count_Opportunity_Products__c = 1].size());
    }

    public static testMethod void testCreatingNewNRDealNoTarget(){
        Delete [Select Id From Target__c];
        System.assertEquals(0, [SELECT Id FROM Target__c].size());

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Opportunity].size());
    }

    public static testMethod void testCreatingNewNRDealNoTargetWithExistingDeal(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct1 = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate1 = lstProduct1[0].Street_Date__c;
        Map<String,Date> dealDate1 = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate1,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate1 = datetime.newInstance(prodReleaseDate1.year(),prodReleaseDate1.month(),prodReleaseDate1.day());
        String dealPeriod1 = sDate1.format('MMM')+String.valueOf(prodReleaseDate1.year());
        
        //Creating Deal
        integer numOfOpp = 3;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, numOfOpp, false);
        for(integer i = 0; i < numOfOpp; i++){
            Opportunity deal = lstDeals[i];
            deal.RecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;    //OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate1.get('Start Date');
            deal.Promo_End_Date__c =  dealDate1.get('End Date');
            deal.Start_Date__c = dealDate1.get('Start Date');
            deal.CloseDate = dealDate1.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod1 + '-VP-'+mapDealRecordTypeToShortName.get(deal.RecordTypeId);
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[1].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(integer i = 0; i < numOfOpp; i++){
            id dealRecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            OpportunityLineItem oli = lstDealProduct[i];
            oli.OpportunityId = lstDeals[i].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct1[0].Id + '-'+mapDealRecordTypeToShortName.get(dealRecordTypeId);
            oli.Start_Date__c = dealDate1.get('Start Date');
            oli.End_Date__c = dealDate1.get('End Date');
            if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
                oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
            }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
            }
        }
        insert lstDealProduct;
        system.assertEquals(3, [Select Product_Code__c,NR_Deal_Product_Unique_Key__c From OpportunityLineItem where Product_Code__c = '1001231231'].size());
        
        List<Product2> lstProducts = new List<Product2>();
        for(Product2 p : [Select Id,NR_Product_Created__c,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1]){
            p.Street_Date__c = p.Street_Date__c.addMonths(1);
            p.NR_Product_Created__c = false;
            lstProducts.add(p);
        }
        update lstProducts;

        Date prodReleaseDate;
        for(Product2 p : [Select NR_Product_Created__c,Street_Date_Has_Changed__c,Street_Date__c From Product2 where ProductCode = '1001231231']){
            system.assertEquals(false,p.NR_Product_Created__c);
            system.assertEquals(true,p.Street_Date_Has_Changed__c);
            prodReleaseDate = p.Street_Date__c;
        }

        Delete [Select Id From Target__c];
        System.assertEquals(0, [SELECT Id FROM Target__c].size());

        Test.startTest();
        Id batchId1 = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
    }

    public static testMethod void testCreatingNewNRDealWithTargetUnitChange(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate = lstProduct[0].Street_Date__c;
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM')+String.valueOf(prodReleaseDate.year());
        
        //Creating Deal
        integer numOfOpp = 3;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, numOfOpp, false);
        for(integer i = 0; i < numOfOpp; i++){
            Opportunity deal = lstDeals[i];
            deal.RecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;    //OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-'+mapDealRecordTypeToShortName.get(deal.RecordTypeId);
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[1].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(integer i = 0; i < numOfOpp; i++){
            id dealRecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            OpportunityLineItem oli = lstDealProduct[i];
            oli.OpportunityId = lstDeals[i].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id + '-'+mapDealRecordTypeToShortName.get(dealRecordTypeId);
            oli.Start_Date__c = dealDate.get('Start Date');
            oli.End_Date__c = dealDate.get('End Date');
            if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
                oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
            }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
            }
        }
        insert lstDealProduct;
        system.assertEquals(3, [Select Product_Code__c,NR_Deal_Product_Unique_Key__c From OpportunityLineItem where Product_Code__c = '1001231231'].size());

        List<Target__c> lstTarget = new List<Target__c>();
        for(Target__c t: [Select Id,Product__c,Target__c From Target__c]){
            t.Target__c = 100;
            t.Target_Units__c = 200;
            t.Product__c = lstProduct[0].Id;
            t.Target_Revenue_Has_Changed__c = true;
            lstTarget.add(t);
        }
        update lstTarget;
        
        for(Target__c t: [Select Id,Target__c,Target_Revenue_Has_Changed__c From Target__c]){
            system.assert(t.Target_Revenue_Has_Changed__c);
        }

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        System.assertEquals(200, [SELECT Target_Quantity__c From OpportunityLineItem Limit 1].Target_Quantity__c);
    }

    public static testMethod void testCreatingNewNRDealWithTargetRevenueChange(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate = lstProduct[0].Street_Date__c;
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM')+String.valueOf(prodReleaseDate.year());
        
        //Creating Deal
        integer numOfOpp = 3;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, numOfOpp, false);
        for(integer i = 0; i < numOfOpp; i++){
            Opportunity deal = lstDeals[i];
            deal.RecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;    //OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-'+mapDealRecordTypeToShortName.get(deal.RecordTypeId);
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[1].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(integer i = 0; i < numOfOpp; i++){
            id dealRecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            OpportunityLineItem oli = lstDealProduct[i];
            oli.OpportunityId = lstDeals[i].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id + '-'+mapDealRecordTypeToShortName.get(dealRecordTypeId);
            oli.Start_Date__c = dealDate.get('Start Date');
            oli.End_Date__c = dealDate.get('End Date');
            if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
                oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
            }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
            }
        }
        insert lstDealProduct;
        system.assertEquals(3, [Select Product_Code__c,NR_Deal_Product_Unique_Key__c From OpportunityLineItem where Product_Code__c = '1001231231'].size());

        List<Target__c> lstTarget = new List<Target__c>();
        for(Target__c t: [Select Id,Product__c,Target__c From Target__c]){
            t.Target__c = 100;
            t.Target_Units__c = null;
            t.Product__c = lstProduct[0].Id;
            t.Target_Revenue_Has_Changed__c = true;
            t.Target_Maintained_As__c   = 'Revenue';
            lstTarget.add(t);
        }
        update lstTarget;
        
        for(Target__c t: [Select Id,Target__c,Target_Revenue_Has_Changed__c From Target__c]){
            system.assert(t.Target_Revenue_Has_Changed__c);
        }

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        System.assertEquals(5, [SELECT Target_Quantity__c From OpportunityLineItem Limit 1].Target_Quantity__c);
    }

    public static testMethod void testAddProductInExistingNRDeal(){
        Date prodReleaseDate = Date.newInstance(System.today().year(), System.today().addMonths(1).month(), System.today().day());
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM')+String.valueOf(prodReleaseDate.year());

        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];

        //Creating Deal
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);                
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-DFI';
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[0].RecordTypeId);
        System.assertEquals(0, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].size());

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        //System.assertEquals(1, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].size());
    }

    public static testMethod void testProductReleaseDateChangeOnExistingDealProductWithScheduleInNRDeal(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        Delete [Select id,Street_Date__c From Product2 where ProductCode = '1001231232' Limit 1];
        List<Product2> lstProduct = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate = lstProduct[0].Street_Date__c;
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM')+String.valueOf(prodReleaseDate.year());
        
        //Creating Deal
        integer numOfOpp = 3;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, numOfOpp, false);
        for(integer i = 0; i < numOfOpp; i++){
            Opportunity deal = lstDeals[i];
            deal.RecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;    //OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-'+mapDealRecordTypeToShortName.get(deal.RecordTypeId);
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[1].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(integer i = 0; i < numOfOpp; i++){
            id dealRecordTypeId = i == 0 ? CRM_RecordTypeUtil.RT_Physical_POS_Deal : i == 1 ? CRM_RecordTypeUtil.RT_Physical_DFI_Deal: CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            OpportunityLineItem oli = lstDealProduct[i];
            oli.OpportunityId = lstDeals[i].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id + '-'+mapDealRecordTypeToShortName.get(dealRecordTypeId);
            oli.Start_Date__c = dealDate.get('Start Date');
            oli.End_Date__c = dealDate.get('End Date');
            if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
                oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
            }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
            }
            oli.Initial_Ship_Fcst__c = 1000;
            oli.Replen_Ship_Fcst__c = 200;
            oli.Manually_Schedule__c = false;
        }
        insert lstDealProduct;
        system.assertEquals(3, [Select Product_Code__c,NR_Deal_Product_Unique_Key__c From OpportunityLineItem where Product_Code__c = '1001231231'].size());
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].size());
        System.assertEquals(8, [SELECT Id FROM OpportunityLineItemSchedule Where OpportunityLineItem.OpportunityId =: lstDeals[0].Id].size());
        // List<OpportunityLineItemSchedule> dealProdSchedules1 = [SELECT Id,ScheduleDate,Description,Quantity,OpportunityLineItem.Product_Code__c FROM OpportunityLineItemSchedule where OpportunityLineItem.OpportunityId =: lstDeals[0].Id order by ScheduleDate];
        // system.debug('@@dealProdSchedules1-->'+dealProdSchedules1);

        List<Product2> lstProducts = new List<Product2>();
        for(Product2 p : [Select Id,NR_Product_Created__c,Street_Date__c,CanUseQuantitySchedule,CanUseRevenueSchedule From Product2 where ProductCode = '1001231231']){
            p.Street_Date__c = p.Street_Date__c.addMonths(1);
            p.NR_Product_Created__c = false;
            p.CanUseQuantitySchedule = true;
            p.CanUseRevenueSchedule = true;
            lstProducts.add(p);
        }
        update lstProducts;
        for(Product2 p : [Select Street_Date__c,NR_Product_Created__c,Street_Date_Has_Changed__c,CanUseQuantitySchedule,CanUseRevenueSchedule From Product2 where ProductCode = '1001231231']){
            system.assertEquals(false,p.NR_Product_Created__c);
            system.assertEquals(true,p.Street_Date_Has_Changed__c);
            system.assertEquals(true,p.CanUseQuantitySchedule);
            system.assertEquals(true,p.CanUseRevenueSchedule);
            system.debug('@@newdate-->'+p.Street_Date__c);
        }

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();

        // List<OpportunityLineItemSchedule> dealProdSchedules2 = [SELECT Id,ScheduleDate,Description,Quantity,OpportunityLineItem.Product_Code__c FROM OpportunityLineItemSchedule where OpportunityLineItem.OpportunityId =: lstDeals[0].Id order by ScheduleDate];
        // system.debug('@@dealProdSchedules2-->'+dealProdSchedules2);

        //System.assertEquals(3, [SELECT Id FROM Opportunity Where Count_Opportunity_Products__c = 2].size());
        //System.assertEquals(8, [SELECT Id FROM OpportunityLineItemSchedule Where OpportunityLineItem.OpportunityId =: lstDeals[0].Id].size());
    }

    public static testMethod void testProductReleaseDateChangeOnExistingDealProductWithScheduleInNRDeal1(){
        Date prodReleaseDate = Date.newInstance(System.today().year(), System.today().addMonths(1).month(), System.today().day());
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM');

        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];

        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];

        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct = [Select id From Product2 where ProductCode = '1001231231' Limit 1];

        //Creating Deal
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);                
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;    //OPPORTUNITY_STAGE_NR_DEFAULT;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-POS';
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, lstDeals[0].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstDeals[0].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id + '-POS';
            oli.Start_Date__c = dealDate.get('Start Date');
            oli.End_Date__c = dealDate.get('End Date');
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
            oli.Initial_Ship_Fcst__c = 1000;
            oli.Replen_Ship_Fcst__c = 200;
            oli.Manually_Schedule__c = false;
        }
        insert lstDealProduct;
        system.assertEquals(lstDealProduct[0].OpportunityId, lstDeals[0].Id);
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].size());
        System.assertEquals(8, [SELECT Id FROM OpportunityLineItemSchedule].size());
        List<OpportunityLineItemSchedule> dealProdSchedules1 = [SELECT Id,ScheduleDate,Description,Quantity FROM OpportunityLineItemSchedule where Description like '%Test Item%' order by ScheduleDate];
        system.debug('@@dealProdSchedules1-->'+dealProdSchedules1);

        Integer dayNumber = System.today().day() == 10 ? 11 : 10;
        List<Product2> lstProducts = new List<Product2>();
        for(Product2 p : [Select Id,NR_Product_Created__c,Street_Date__c,CanUseQuantitySchedule,CanUseRevenueSchedule From Product2]){
            p.Street_Date__c = Date.newInstance(System.today().year(), System.today().addMonths(1).month(), dayNumber);
            p.NR_Product_Created__c = false;
            p.CanUseQuantitySchedule = true;
            p.CanUseRevenueSchedule = true;
            lstProducts.add(p);
        }
        update lstProducts;

        for(Product2 p : [Select NR_Product_Created__c,Street_Date_Has_Changed__c,CanUseQuantitySchedule,CanUseRevenueSchedule From Product2]){
            system.assertEquals(false,p.NR_Product_Created__c);
            system.assertEquals(true,p.Street_Date_Has_Changed__c);
            system.assertEquals(true,p.CanUseQuantitySchedule);
            system.assertEquals(true,p.CanUseRevenueSchedule);
        }

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();

        //System.assertEquals(3, [SELECT Id FROM Opportunity].size());
        //System.assertEquals(30, [SELECT Id FROM OpportunityLineItem].size());
        //List<OpportunityLineItemSchedule> dealProdSchedules = [SELECT Id,ScheduleDate,Description,Quantity FROM OpportunityLineItemSchedule where Description like '%Test Item%' order by ScheduleDate];
        //system.debug('@@dealProdSchedules-->'+dealProdSchedules);
    }

    public static testMethod void testAddProductInCommittedPOSDeal(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate = lstProduct[0].Street_Date__c;
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM')+String.valueOf(prodReleaseDate.year());

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(d).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
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

        //Creating Deal
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);                
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-POS';
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, lstDeals[0].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstDeals[0].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id + '-POS';
            oli.Start_Date__c = dealDate.get('Start Date');
            oli.End_Date__c = dealDate.get('End Date');
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;            
        }
        insert lstDealProduct;
        system.assertEquals(lstDealProduct[0].OpportunityId, lstDeals[0].Id);
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].size());

        System.runas(testUser){
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];            
            oppList[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update oppList;
        }

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, [SELECT StageName FROM Opportunity Where Id =: lstDeals[0].Id].StageName);
    }

    public static testMethod void testAddProductInCommittedPOSDealWithCreditNote(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        Delete [Select id,Street_Date__c From Product2 where ProductCode = '1001231232' Limit 1];
        List<Product2> lstProduct = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate = lstProduct[0].Street_Date__c;
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM')+String.valueOf(prodReleaseDate.year());

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        List<Profile> profileCP = [SELECT Id FROM Profile WHERE Name = 'CRM - Commercial Planning - SDS' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(d).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
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

        User testUserCP = new User(
            FirstName = 'Test2',
            LastName = 'User2',
            Username = String.valueOf(d).substring(0,8) + 'abc@test2.com',
            Email = 'abc@test2.com',
            Alias = String.valueOf(d).substring(0,6)+'2',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profileCP[0].Id,
            ByPassValidationRule__c = true
        );
        insert testUserCP;
        System.assert(testUser.Id != null, 'User should get created');

        //Creating Deal
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);                
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-POS';
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
            deal.OwnerId = testUserCP.Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, lstDeals[0].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstDeals[0].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id + '-POS';
            oli.Start_Date__c = dealDate.get('Start Date');
            oli.End_Date__c = dealDate.get('End Date');
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
        }
        insert lstDealProduct;
        system.assertEquals(lstDealProduct[0].OpportunityId, lstDeals[0].Id);
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].size());

        System.runas(testUser){
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];            
            oppList[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update oppList;
        }
    
        //Create Credit NOte and Item for POS Commited deal
        Credit_Note__c cn = new Credit_Note__c();
        cn.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_PHYSICAL;
        cn.Account__c = lstAccounts[0].Id;
        cn.Co_op_Reason__c = 'POS Rebate';
        cn.Status__c = 'Planned';
        cn.Credit_Note_Type__c = 'ZMC';
        cn.CurrencyIsoCode = 'USD';
        cn.OwnerId = testUserCP.Id;
        insert cn;

        Credit_Note_Item__c cni = new Credit_Note_Item__c();
        cni.Credit_Note__c = cn.Id;
        cni.Deal__c = lstDeals[0].Id;
        cni.Unique_Id__c = cn.Id+'-'+lstDeals[0].Id+'-'+lstDealProduct[0].Id;
        cni.CurrencyIsoCode = 'USD';
        cni.Amount__c = 100;
        cni.Requested_Co_op_Amount__c = 100;
        cni.Product__c = lstProduct[0].Id;
        insert cni;

        System.runas(testUser){
            //attach CN to deal product
            List<OpportunityLineItem> oppItemList = [SELECT Id,Credit_Note_Item__c FROM OpportunityLineItem Where Id =:lstDealProduct[0].Id];
            oppItemList[0].Credit_Note_Item__c = cni.Id;
            update oppItemList;
        }

        //Change product release date to next month
        List<Product2> lstProducts = new List<Product2>();
        for(Product2 p : [Select Id,NR_Product_Created__c,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1]){
            p.Street_Date__c = p.Street_Date__c.addMonths(1);
            p.NR_Product_Created__c = false;
            lstProducts.add(p);
        }
        update lstProducts;

        for(Product2 p : [Select NR_Product_Created__c,Street_Date_Has_Changed__c,Street_Date__c From Product2 where ProductCode = '1001231231']){
            system.assertEquals(false,p.NR_Product_Created__c);
            system.assertEquals(true,p.Street_Date_Has_Changed__c);
        }

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, [SELECT StageName FROM Opportunity Where Id =: lstDeals[0].Id].StageName);
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].Size());
    }

    public static testMethod void testAddProductInCommittedDFIDeal(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate = lstProduct[0].Street_Date__c;
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM')+String.valueOf(prodReleaseDate.year());

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(d).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
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

        //Creating Deal
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);                
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-DFI';
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[0].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstDeals[0].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id + '-DFI';
            oli.Start_Date__c = dealDate.get('Start Date');
            oli.End_Date__c = dealDate.get('End Date');
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
            oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
        }
        insert lstDealProduct;
        system.assertEquals(lstDealProduct[0].OpportunityId, lstDeals[0].Id);
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].size());

        System.runas(testUser){
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];            
            oppList[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update oppList;
        }

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        System.assertEquals('Cancelled', [SELECT Id,Deal_Product_Status__c FROM OpportunityLineItem Where Product_Code__c = '1001231231' and Deal_Record_Type__c =: CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL].Deal_Product_Status__c);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, [SELECT StageName FROM Opportunity Where Id =: lstDeals[0].Id].StageName);
    }

    public static testMethod void testRemoveProductInCommittedDFIDeal(){
        List<Account> lstAccounts = [Select Id,name,AccountNumber,Class_of_Trade__c,CurrencyIsoCode,Price_Book__c From Account Where AccountNumber = '1010101010'];
        List<Pricebook2> JVPricebooks = [Select Id,Name From Pricebook2 Where Name ='SDS - US' limit 1];
        List<PricebookEntry> lstPricBookEntry = [Select Id,Pricebook2Id From PricebookEntry Where Pricebook2Id =: JVPricebooks[0].Id];
        System.assert(JVPricebooks[0].Id==lstPricBookEntry[0].Pricebook2Id);

        List<Product2> lstProduct = [Select id,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1];
        Date prodReleaseDate = lstProduct[0].Street_Date__c;
        Map<String,Date> dealDate = CRMJV_AutoPhysicalNRDealBatchService.calculateDatesForDeal(prodReleaseDate,CRM_AppConstants.NR_Deal_For_Month);
        Datetime sDate = datetime.newInstance(prodReleaseDate.year(),prodReleaseDate.month(),prodReleaseDate.day());
        String dealPeriod = sDate.format('MMM')+String.valueOf(prodReleaseDate.year());

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(d).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
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

        //Creating Deal
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);                
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
            deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
            deal.Promo_Start_Date__c = dealDate.get('Start Date');
            deal.Promo_End_Date__c =  dealDate.get('End Date');
            deal.Start_Date__c = dealDate.get('Start Date');
            deal.CloseDate = dealDate.get('End Date');
            deal.Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            deal.Pricebook2Id = JVPricebooks[0].id;
            deal.NR_Deal_Unique_Key__c = lstAccounts[0].Id + '-' + dealPeriod + '-VP-DFI';
            deal.Product_Type__c = 'Video Physical';
            deal.AccountId = lstAccounts[0].Id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[0].RecordTypeId);

        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricBookEntry, lstDeals, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstDeals[0].Id;
            oli.PricebookEntryId = lstPricBookEntry[0].Id;
            oli.Manually_Schedule__c = true;
            oli.NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id + '-' + lstProduct[0].Id + '-DFI';
            oli.Start_Date__c = dealDate.get('Start Date');
            oli.End_Date__c = dealDate.get('End Date');
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
            oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
        }
        insert lstDealProduct;
        system.assertEquals(lstDealProduct[0].OpportunityId, lstDeals[0].Id);
        System.assertEquals(1, [SELECT Id FROM OpportunityLineItem Where OpportunityId =: lstDeals[0].Id].size());

        System.runas(testUser){
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];            
            oppList[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update oppList;
        
            List<Product2> lstProducts = new List<Product2>();
            for(Product2 p : [Select Id,NR_Product_Created__c,Street_Date__c From Product2 where ProductCode = '1001231231' Limit 1]){
                p.Street_Date__c = p.Street_Date__c.addMonths(1);
                p.NR_Product_Created__c = false;
                lstProducts.add(p);
            }
            update lstProducts;

            for(Product2 p : [Select NR_Product_Created__c,Street_Date_Has_Changed__c,Street_Date__c From Product2 where ProductCode = '1001231231']){
                system.assertEquals(false,p.NR_Product_Created__c);
                system.assertEquals(true,p.Street_Date_Has_Changed__c);
            }
        }

        Test.startTest();
        id batchId = Database.executeBatch(new CRMJV_AutoPhysicalNRDealBatch(),200);
        Test.stopTest();
        System.assertEquals('Cancelled', [SELECT Id,Deal_Product_Status__c FROM OpportunityLineItem Where Product_Code__c = '1001231231' and Deal_Record_Type__c =: CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL LIMIT 1].Deal_Product_Status__c);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, [SELECT StageName FROM Opportunity Where Id =: lstDeals[0].Id].StageName);
    }

    @TestVisible
    private static List<Target__c> createTargetsForJVNRBatch(List<Account> lstAccounts, List<Product2> lstProduct){
        List<Target__c> lstTargets = new List<Target__c>();
        for(Account account : lstAccounts){
            for(Product2 prd : lstProduct){
                Target__c targetInstance = new Target__c(
                    Account__c = account.Id,
                    Product__c = prd.Id,
                    RecordTypeId = CRM_RecordTypeUTil.RT_TARGET_PRODUCT,
                    Product_Group__c = null,
                    StartDate__c = Date.newInstance(2020, 01, 01),
                    End_Date__c = Date.newInstance(4000, 12, 31),
                    Approved__c = null,
                    Planned__c = null,
                    Confirmed__c = null,
                    Actual_Revenue__c = null,
                    High_Level__c = null,
                    CurrencyIsoCode = 'USD',
                    Target_Maintained_As__c = 'Quantity',
                    Target_Units__c = 100,
                    Target__c = 60
                );
                lstTargets.add(targetInstance);
            }
        }
        insert lstTargets;
        return lstTargets;
    }
}