/**
@Author Cognizant
@name CRMJV_DecayCurveReforcastingBatch_Test
@CreateDate 11 Nov 2020
@Description: Vatch Test class to reforcast schedule using new replen quantity.
@Version <1.0>
@reference: W-017642 - Enable Decay Curves and Re-forecasting Schedules
*/
@IsTest
public class CRMJV_DecayCurveReforcastingBatch_Test {
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
            Country__c = 'USA'
        );
        insert JVPricebook;
        system.assertNotEquals(null, JVPricebook);
        
        date myDate = date.today();
        date weekStart = myDate.toStartofWeek();
        //Creating Decay Curve Template and Line Item
        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].Status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate; 
        
        // Inserting JV Account
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);        
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUTil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Class_of_Trade__c = 'Wholesale 5';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
        lstAccounts[0].Decay_Curve_Template__c = lstDecayCurveTemplate[0].ID;
        lstAccounts[0].Sales_Organization__c = '9500';
        lstAccounts[0].Price_Book__c =JVPricebook.id;
        
        lstAccounts[1].RecordTypeID = CRM_RecordTypeUTil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[1].Class_of_Trade__c = 'Wholesale 5';
        lstAccounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
        lstAccounts[1].Decay_Curve_Template__c = NULL;
        lstAccounts[1].Sales_Organization__c = '9500';
        lstAccounts[1].Price_Book__c =JVPricebook.id;
        insert lstAccounts;
        system.assertEquals(CRM_AppConstants.TERRITORY_SDS_US_CODE, lstAccounts[0].Sales_Organization__c);
        system.assertEquals(2,lstAccounts.size());
        
        //Creating Deal
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 2, false);
        
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
            deal.Promo_Start_Date__c = weekStart;
            deal.Promo_End_Date__c =  weekStart.addDays(3);
            deal.Start_Date__c = weekStart;
            deal.CloseDate = weekStart.addDays(3);
            deal.Price_Type__c = 'ZPRD';
            deal.Pricebook2Id = JVPricebook.id;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[0].RecordTypeId);
       
        //Creating Product Group and Products
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 10, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prodInstance.CurrencyIsoCode = 'USD';
            prodInstance.CanUseQuantitySchedule = true;
            prodInstance.CanUseRevenueSchedule = true;
        }
        insert lstProduct;
        
        // Creating PricebookEntry for JV
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        System.assertEquals(10,lstPriceBookEntries.size());
        
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries) {
            pbe.Pricebook2Id = JVPricebook.id;
        }
        insert customLstPriceBookEntries;
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : lstPriceBookEntryPeriod){
            pebp.Price_Type__c = 'Wholesale 5';
            pebp.Start_Date__c = weekStart;
            pebp.End_Date__c = weekStart.addDays(3);
            pebp.Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            pebp.Price_Book__c = JVPricebook.id;
        }
        insert lstPriceBookEntryPeriod;
        System.assertEquals(10,lstPriceBookEntryPeriod.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod1= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = weekStart;
            pebp.End_Date__c = weekStart.addDays(3);
            pebp.Price_Book__c = JVPricebook.id;
        }
        insert pricebookentryPeriod1;
        System.assertEquals(10,pricebookentryPeriod1.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c =weekStart;
            pebp.End_Date__c = weekStart.addDays(3);
            pebp.Price_Book__c = JVPricebook.id;
        }
        insert pricebookentryPeriod2;
        System.assertEquals(10,pricebookentryPeriod2.size());
        
        //Adding Products in Opportunity
        List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstDeals, 10, false);
        for(Integer nProductCount = 0; nProductCount < lstProduct.size(); nProductCount++){ 
            for(OpportunityLineItem oli : lstDealProducts) {
                oli.Start_Date__c = weekStart;
                oli.End_Date__c = weekStart.addDays(3);
                oli.Initial_Ship_Fcst__c = 100;
                oli.Replen_Ship_Fcst__c = 200;
                oli.Reason__c = 'DFI';
                oli.Account_Fund_Segment__c = 'NAT'; 
                oli.POS_Quantity__c=12;
                oli.ListPrice__c=100;
                
                
            }
           
        }
         lstDealProducts[0].Replen_Ship_Fcst__c = 0;
        insert lstDealProducts;
        System.assertEquals(40,lstDealProducts.size());        
             
        //Creating custom setting to send email notification to user 
        Batch_Notification_Recipients__c bnr=new  Batch_Notification_Recipients__c();
        bnr.Name='Rahul Kumar Chakalasiya';
        bnr.Entity__c='CRM';
        bnr.User_Email_Id__c='rahulkumar.chakalasiya@cognizant.com';
        insert bnr;    
        
        //creating custom setting to set batch size
        CRM_Batch_Size__c cbc = new CRM_Batch_Size__c();
        cbc.Name='Decay Curve Re-Forcasting Batch';
        cbc.Batch_Size__c=700;
        insert cbc;
 }
    
     //General Scenario to test schedule Creation Using Batch
    public static testMethod void testCreatingScheduleWithBatch(){
        
        Test.startTest();
        id batchId = Database.executeBatch( new CRMJV_DecayCurveReforcastingBatch(), 700 );
        Test.stopTest();
    }
    
    //when Deal product are upadted with new replane value
    public static testMethod void UpdateDealProductNewReplenValue(){
        List<OpportunityLineItem> lstDealProducts =[select id ,Start_Date__c,End_Date__c,Initial_Ship_Fcst__c,Replen_Ship_Fcst__c ,Reason__c,Account_Fund_Segment__c ,POS_Quantity__c , ListPrice__c from OpportunityLineItem];
        for(OpportunityLineItem oli : lstDealProducts){
            oli.New_Replen_Ship_Fcst__c=300;
        }
        update lstDealProducts;
        
        Test.startTest();
        id batchId=Database.executeBatch( new CRMJV_DecayCurveReforcastingBatch(), 700 );
        Test.stopTest();        
    }
    
    //Method to Update Deal Product Discount Value 
   public static testMethod void UpdateDealProductDiscountValue(){
        
        List<OpportunityLineItemSchedule> dealProductSchedules = [SELECT ID FROM OpportunityLineItemSchedule];
        delete dealProductSchedules;
        List<OpportunityLineItem> lstDealProducts =[select id ,Start_Date__c,End_Date__c,Initial_Ship_Fcst__c,Replen_Ship_Fcst__c ,Reason__c,Account_Fund_Segment__c ,POS_Quantity__c ,Quantity,TotalPrice, ListPrice__c from OpportunityLineItem];
        for(OpportunityLineItem oli : lstDealProducts){
           oli.Discount=100;
           // oli.Replen_Ship_Fcst__c=0;
            }
       lstDealProducts[0].Discount=90;
        update lstDealProducts;
        
        Test.startTest();       
        id batchId=Database.executeBatch( new CRMJV_DecayCurveReforcastingBatch(), 700);
        Test.stopTest();
        
        
    }
    
    //method to Test send mail Scenario
    public static testMethod void methodToTestSendEmail(){
        CRMJV_DecayCurveReforcastingService DecayCurveServiceInst = new  CRMJV_DecayCurveReforcastingService();
        CRMJV_DecayCurveReforcastingBatch batchobj= new CRMJV_DecayCurveReforcastingBatch();
        List<OpportunityLineItem> lstDealProducts =[select id from OpportunityLineItem limit 1];
        List<CRMJV_DecayCurveReforcastingService.CRMJV_DecayCurveReforcastingBatchException> lstExceptions = new List<CRMJV_DecayCurveReforcastingService.CRMJV_DecayCurveReforcastingBatchException>();
        List<String> lstErrors = new List<String>();
        lstErrors.add('Error occor');
        
        CRMJV_DecayCurveReforcastingService.CRMJV_DecayCurveReforcastingBatchException abc=new CRMJV_DecayCurveReforcastingService.CRMJV_DecayCurveReforcastingBatchException(lstDealProducts[0].id,lstErrors);
        //abc.recordId=lstDealProducts[0].id;
       // abc.lstErrors.addAll(lstErrors);
        
        lstExceptions.add(abc);
        
        CRMJV_DecayCurveReforcastingService.lstExceptions= lstExceptions;
        map<Id,OpportunityLineItem> mapProductError = new map<Id,OpportunityLineItem>([SELECT Id, Name FROM OpportunityLineItem]);
        batchobj.sendMail(mapProductError);
   }
    
    //Method to Test account record without decay curve Template
    public static testMethod void  accountWithoutDecayCurve(){
        list<account> lstacc=[select id, name from account];
        List<Account> lstnew=new List<Account>();
        for(account acc:lstacc){
            acc.Decay_Curve_Template__c=NULL;
            lstnew.add(acc);
        }
        update lstnew;
         
        Test.startTest();        
        id batchId=Database.executeBatch( new CRMJV_DecayCurveReforcastingBatch(), 700);
        Test.stopTest();
    }
    
     public static testMethod void negativeTestUpdateDeal(){
        List<OpportunityLineItem> lstDealProducts =[select id ,Promo_Start_Date__c,Start_Date__c,End_Date__c,Initial_Ship_Fcst__c,Replen_Ship_Fcst__c ,Reason__c,Account_Fund_Segment__c ,POS_Quantity__c , ListPrice__c from OpportunityLineItem];
        for(OpportunityLineItem oli : lstDealProducts){
            oli.New_Replen_Ship_Fcst__c=300;
            //oli.Promo_Start_Date__c='4000-12-31';
        }
        update lstDealProducts;
        
        Test.startTest();
        id batchId=Database.executeBatch( new CRMJV_DecayCurveReforcastingBatch(), 700 );
        Test.stopTest();        
    }
    
    // method to call executeBeforeInsert method of CRM_ProductSequenceController when triggerOnOffFlag is false
    @isTest
    public static void executeBeforeInsertProductSequenceController() {
        
        CRM_Trigger_Switches_For_ON_OFF__c setting = new CRM_Trigger_Switches_For_ON_OFF__c(Name = 'CRM_UpdateProductGroupOnProductBatch', IsActive__c = false);
        insert setting;
        
        List<Product_Group__c> lstProductGroup = [select Id from Product_Group__c limit 1];
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 5, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prodInstance.CurrencyIsoCode = 'USD';
            prodInstance.CanUseQuantitySchedule = true;
            prodInstance.CanUseRevenueSchedule = true;
        }
        insert lstProduct;
    }
    
    // method to call executeBeforeUpdate method of CRM_ProductSequenceController when triggerOnOffFlag is false
    @isTest
    public static void executeBeforeUpdateProductSequenceController() {
        
        Product2 productrecord = [select Id from product2 limit 1];
        productrecord.Process_Product_Group__c = false;
        Test.startTest();
            CRM_Trigger_Switches_For_ON_OFF__c setting = new CRM_Trigger_Switches_For_ON_OFF__c(Name = 'CRM_UpdateProductGroupOnProductBatch', IsActive__c = false);
            insert setting;
            update productrecord;
        Test.stopTest();
    }
    
    @isTest
    public static void testIsJVSalesOrg() {
        Test.startTest();
            CRM_UploadComponentController.isJVSalesOrg(CRM_AppConstants.TERRITORY_SDS_US_CODE);
        Test.stopTest();
    }
    
    
     public static testMethod void testRunBatchwithCommitedDeal(){
        insert new CRM_Default_Configuration__c(SetupOwnerId=UserInfo.getOrganizationId(), Batch_User_Id__c=Userinfo.getUserId().left(15));

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

       
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
         
          // Make the deal as Committed
        System.runas(testUser) {
        
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
                opp.Promo_Start_Date__c=  Date.newInstance(4000, 12, 9);
               opp.Promo_End_Date__c=Date.newInstance(4000, 12, 14);
            }
            update oppList;
            
        }


        Test.startTest();        
        id batchId=Database.executeBatch( new CRMJV_DecayCurveReforcastingBatch(), 700);
        Test.stopTest();
    }
    
    
    
     //method to update schedule type
  /* public static testMethod void UpdateScheduleType(){
        List<OpportunityLineItemSchedule> dealProductSchedules = [SELECT ID FROM OpportunityLineItemSchedule];
        delete dealProductSchedules;
        
      List<OpportunityLineItemSchedule> lstSchedule=[SELECT Id,Quantity, Revenue, ScheduleDate from OpportunityLineItemSchedule];
        for(OpportunityLineItemSchedule sc:lstSchedule){
            sc.Type='Quantity';
        }
        update lstSchedule;
        
         Test.startTest();       
        System.debug('Inside update schedule');
        id batchId=Database.executeBatch( new CRMJV_DecayCurveReforcastingBatch(), 700);
        Test.stopTest();
        
        
    }*/

    
}