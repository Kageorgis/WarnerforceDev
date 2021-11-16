/**
   @Author Vaibhav Trivedi
   @name CRM_BatchTargetRollUp_V2_Test 
   @CreateDate 23 Feb 2016
   @Description Test class for CRM_BatchTargetRollUp_V2
   @Version <2.0>
   @reference Requirement no 38
  */
@isTest(SeeAllData=false) 
private class CRM_BatchTargetRollUp_Test {

    public static List<Account> lstSoldToAccount = null;
    public static List<File_Discount__c> lstFileDiscount = null;
    public static List<Product_Group__c> lstProductGroup = CRM_TestDataTemplate.createProductGroups(1,true);
    public static List<Product2> lstProducts = null;
    public static List<PricebookEntry> lstPriceBookEntries = null;
    public static List<Pricebook_Entry_Period__c> lstPriceBookPeriod = null;
    public static List<Opportunity> lstDeals = null;
    public static List<OpportunityLineItem> lstDealProducts = null;
    public static List<OpportunityLineItemSchedule> lstDealsSchedule = null;
    public static List<Bundle__c> lstBundle = null;
    public static List<Bundle_Product__c> lstBundleProduct = null;
    public static List<Target__c> lstTargets = new list<Target__c>();
    public static List<Target__c> lstProductTargets = null; 
    
    /**
    * check the scenarios to be executed 
    * @name checkScenariosToExecute
    * @param none  
    * @returning -  none
    */ 
    public static void checkScenariosToExecute(String Scenario){
        
        String localScenario = Scenario;
        
      /*  if(localScenario == 'dataSetUpCatalogForPlannedPhysicalDealNoSchedule')  {       
            dataSetUpCatalogForPlannedPhysicalDealNoSchedule(); 
            system.debug('I m here ... 1');
        }
        if(localScenario == 'dataSetUpCatalogForApprovedPhysicalDealNoSchedule')  {       
            dataSetUpCatalogForApprovedPhysicalDealNoSchedule();  
            system.debug('I m here ... 2');
        }     
        if(localScenario == 'dataSetUpCatalogForConfirmedPhysicalDealNoSchedule')  {       
            dataSetUpCatalogForConfirmedPhysicalDealNoSchedule();  
            system.debug('I m here ... 3');
        }   */  
        if(localScenario == 'dataSetUpCatalogForPlannedPhysicalDeal')  {       
            dataSetUpCatalogForPlannedPhysicalDeal();  
            system.debug('I m here ... 4');
        }
        
        //Req:#159 New Scenario For Midterm New Release type target for Planned Physical Deal.
        if(localScenario == 'dataSetUpCatalogForPlannedPhysicalDealMidTerm')  {       
            dataSetUpCatalogForPlannedPhysicalDealMidTerm();  
            system.debug('I m here ... 4.1');
        }
        //Req:#159 New Scenario For Midterm New Release type target.
        
        if(localScenario == 'dataSetUpCatalogForApprovedPhysicalDeal')  {       
            dataSetUpCatalogForApprovedPhysicalDeal();  
            system.debug('I m here ... 5');
        }     
        if(localScenario == 'dataSetUpCatalogForConfirmedPhysicalDeal')  {       
            dataSetUpCatalogForConfirmedPhysicalDeal();  
            system.debug('I m here ... 6');
        }     
        if(localScenario == 'dataSetUpCatalogForHighLevelDeal')  {      
            dataSetUpCatalogForHighLevelDeal();  
            system.debug('I m here ... 7');
        }
        if(localScenario == 'dataSetUpNRForPlannedPhysicalDeal')  {
            dataSetUpNRForPlannedPhysicalDeal();  
            system.debug('I m here ... 9');
        }
        if(localScenario == 'dataSetUpNRForPlannedDigitalDeal')  {
            dataSetUpNRForPlannedDigitalDeal();  
            system.debug('I m here ... 23');
        }
               
        if(localScenario == 'dataSetUpNRForConfirmedDigitalDeal')  {      
            dataSetUpNRForConfirmedDigitalDeal();  
            system.debug('I m here ... 24');
        }        
        if(localScenario == 'dataSetUpNRForApprovedDigitalDeal')  {      
            dataSetUpNRForApprovedDigitalDeal();  
            system.debug('I m here ... 25');
        }       
       /*
        if(localScenario == 'dataSetUpNRForPlannedDigitalDealNoSchedule')  {      
            dataSetUpNRForPlannedDigitalDealNoSchedule();  
            system.debug('I m here ... 27');
        }
        if(localScenario == 'dataSetUpNRForApprovedDigitalDealNoSchedule')  {
            dataSetUpNRForApprovedDigitalDealNoSchedule();  
            system.debug('I m here ... 28');
        }
        if(localScenario == 'dataSetUpNRForConfirmedDigitalDealNoSchedule')  {
            dataSetUpNRForConfirmedDigitalDealNoSchedule();  
            system.debug('I m here ... 29');
        }*/
        if(localScenario == 'dataSetUpNRForConfirmedPhysicalDeal')  {      
            dataSetUpNRForConfirmedPhysicalDeal();  
            system.debug('I m here ... 10');
        }
        if(localScenario == 'dataSetUpNRForApprovedPhysicalDeal')  {      
            dataSetUpNRForApprovedPhysicalDeal();  
            system.debug('I m here ... 11');
        }
        
        if(localScenario == 'dataSetUpBundleForPlannedPhysicalDeal')  {      
            dataSetUpBundleForPlannedPhysicalDeal();   
            system.debug('I m here ... 16');
        } 
        if(localScenario == 'dataSetUpBundleForApprovedPhysicalDeal')  {      
            dataSetUpBundleForApprovedPhysicalDeal(); 
            system.debug('I m here ... 17');
        }
        if(localScenario == 'dataSetUpBundleForConfirmedPhysicalDeal')  {      
            dataSetUpBundleForConfirmedPhysicalDeal();   
            system.debug('I m here ... 18');
        }
       /* if(localScenario == 'dataSetUpBundleForPlannedPhysicalDealNoSchedule')  {      
            dataSetUpBundleForPlannedPhysicalDealNoSchedule();   
            system.debug('I m here ... 19');
        } 
        if(localScenario == 'dataSetUpBundleForApprovedPhysicalDealNoSchedule')  {      
            dataSetUpBundleForApprovedPhysicalDealNoSchedule(); 
            system.debug('I m here ... 20');
        }
        if(localScenario == 'dataSetUpBundleForConfirmedPhysicalDealNoSchedule')  {      
            dataSetUpBundleForConfirmedPhysicalDealNoSchedule();   
            system.debug('I m here ... 21');
        }
*/
        if(localScenario == 'dataSetUpBundleForPlannedDigitalDeal')  {      
            dataSetUpBundleForPlannedDigitalDeal();
            system.debug('I m here ... 27');
        }
        if(localScenario == 'dataSetUpBundleForApprovedDigitalDeal')  {      
            dataSetUpBundleForApprovedDigitalDeal(); 
            system.debug('I m here ... 28');
        }
        if(localScenario == 'dataSetUpBundleForConfirmedDigitalDeal')  {      
            dataSetUpBundleForConfirmedDigitalDeal();   
            system.debug('I m here ... 29');
        }       
      /*  if(localScenario == 'dataSetUpBundleForPlannedDigitalDealNoSchedule')  {      
            dataSetUpBundleForPlannedDigitalDealNoSchedule();   
            system.debug('I m here ... 30');
        } 
        if(localScenario == 'dataSetUpBundleForApprovedDigitalDealNoSchedule')  {      
            dataSetUpBundleForApprovedDigitalDealNoSchedule(); 
            system.debug('I m here ... 31');
        }
        if(localScenario == 'dataSetUpBundleForConfirmedDigitalDealNoSchedule')  {      
            dataSetUpBundleForConfirmedDigitalDealNoSchedule();   
            system.debug('I m here ... 32');
        }*/
        if(localScenario == 'dataSetUpCatalogForPlannedDigitalDeal')  {       
            dataSetUpCatalogForPlannedDigitalDeal();  
            system.debug('I m here ... 33');
            system.debug('I m here ... 33');
        } 
        
        //Req:#159 New Scenario For Midterm New Release type target for Planned Digital Deal.
        if(localScenario == 'dataSetUpCatalogForPlannedDigitalDealMidTerm')  {       
            dataSetUpCatalogForPlannedDigitalDealMidTerm();  
            system.debug('I m here ... 33.1');
            system.debug('I m here ... 33.1');
        }     
        //Req:#159 New Scenario For Midterm New Release type target for Planned Digital Deal.
              
        if(localScenario == 'dataSetUpCatalogForApprovedDigitalDeal')  {       
            dataSetUpCatalogForApprovedDigitalDeal();  
            system.debug('I m here ... 34');
        }
        if(localScenario == 'dataSetUpCatalogForConfirmedDigitalDeal')  {       
            dataSetUpCatalogForConfirmedDigitalDeal();  
            system.debug('I m here ...  35');
        }       
    /*    if(localScenario == 'dataSetUpCatalogForPlannedDigitalDealNoSchedule')  {       
            dataSetUpCatalogForPlannedDigitalDealNoSchedule(); 
            system.debug('I m here ... 36');
        }       
        if(localScenario == 'dataSetUpCatalogForApprovedDigitalDealNoSchedule')  {       
            dataSetUpCatalogForApprovedDigitalDealNoSchedule();  
            system.debug('I m here ... 37');
        }
        if(localScenario == 'dataSetUpCatalogForConfirmedDigitalDealNoSchedule')  {       
            dataSetUpCatalogForConfirmedDigitalDealNoSchedule();  
            system.debug('I m here ... 38');
        }           */
        if(localScenario == 'dataSetUpCatalogForHighLevelDigitalDeal')  {      
            dataSetUpCatalogForHighLevelDigitalDeal();  
            system.debug('I m here ... 39');
        }
        
        if(localScenario == 'dataSetUpCatalogForJVPlannedPhysicalDeal')  {      
            dataSetUpCatalogForJVPlannedPhysicalDeal();  
            system.debug('I m here ... 40');
        }
        
       }
    
    /**
    * invoke custom Setting for target restriction by last 6 months
    * @name invokeCustomSetting
    * @param none  
    * @returning -  none
    */ 
    public static void invokeCustomSetting(){
        TargetLimitter__c setting1 = new TargetLimitter__c();
        setting1.Name = 'PeriodForEligibleTargets';
        setting1.PeriodForEligibleTargets__c = 8;
        insert setting1;
    }
    
    /**
    * 
    * @name dataSetUpNRForPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    */   
    public static void dataSetUpNRForPlannedPhysicalDeal(){
        invokeCustomSetting();
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today().addDays(700),System.Today()+5,1,false);
        for (Product2 objProd: lstProducts){
            objProd.NR_period_weeks__c = 99;
            objProd.Release_Category__c = '23';
        }
        insert lstProducts;
        
        
        
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today(),System.Today().addDays(365),'VOD TV Mobile','NR',34,1,true);
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today()+5,System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED,System.Today(),System.Today().addDays(365),dealRecordTypeId,1,true);
        for(Opportunity objOpp :lstDeals) {
            objOpp.Promo_Start_Date__c = System.Today() +4;
        }
        update lstDeals;
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,12,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,system.today()+30,1000,1,true);
        
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProducts, true);
        System.assertEquals(1, lstCountryPlan.size());

        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlan, lstSoldToAccount, true);
        System.assertEquals(1, lstAccountPlan.size());
         // Insert GL calendars
        List<GL_Calendar__c> lstGLCalendar = new List<GL_Calendar__c>();

        // For Target 1
        Date startDate = System.today() + 5;
        Date endDate = startDate.addDays(56);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar1);

        insert lstGLCalendar;
        System.assertEquals(1, lstGLCalendar.size());

        // Insert Country Plan Targets
        List<Country_Plan_Target__c> lstCountryPlanTargets = new List<Country_Plan_Target__c>();
        for (Country_Plan__c countryPlan : lstCountryPlan) {
            lstCountryPlanTargets.addAll(CRM_TestDataFactory.createCountryPlanTarget(countryPlan, [SELECT Id FROM GL_Calendar__c ORDER BY Start_Date__c]));
        }
         List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,Target_Quantity__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c 
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, RecordTypeId, Name, CurrencyISOCode, Share__c, Total_Target__c, Target_Quantity__c, Product_Group__c, Customer__c,Returns_Share__c,Billing_Adjustment_Share__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
            ];
        
        // Auto Allocate Account Plan Targets
        //CRM_GenerateAccountPlanTargetsCtrl controller = new CRM_GenerateAccountPlanTargetsCtrl();
        List<Target__c> accountPlanTargetList = CRM_GenerateAccountPlanTargetsCtrl.generateAccountTargetList(countryPlansWithInnerQuery);

        if (!accountPlanTargetList.isEmpty()) {
            upsert accountPlanTargetList Unique_Key__c;
        }
        
        List<Target__c> lstUpdatedTargets2 = [Select Id,Calc_Start_Date__c, Calc_End_Date__c, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.debug('Calc_Start_Date__c ===>' + lstUpdatedTargets2[0].Calc_Start_Date__c);
        System.debug('Calc_End_Date__c ===>' + lstUpdatedTargets2[0].Calc_End_Date__c);
    }
    
    
    /**
    * 
    * @name dataSetUpNRForConfirmedPhysicalDeal
    * @param none - 
    * @returning -  none
    */  
    public static void dataSetUpNRForConfirmedPhysicalDeal(){
        invokeCustomSetting();
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today().addDays(700),System.Today()+5,1,false);
        for (Product2 objProd: lstProducts){
            objProd.NR_period_weeks__c = 99;
            objProd.Release_Category__c = '23';
        }
        insert lstProducts;
        
        
        
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today(),System.Today().addDays(365),'VOD TV Mobile','NR',34,1,true);
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today()+5,System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,System.Today(),System.Today().addDays(365),dealRecordTypeId,1,true);
        for(Opportunity objOpp :lstDeals) {
            objOpp.Promo_Start_Date__c = System.Today() +4;
        }
        update lstDeals;
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,12,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,system.today()+30,1000,1,true);
        
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProducts, true);
        System.assertEquals(1, lstCountryPlan.size());

        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlan, lstSoldToAccount, true);
        System.assertEquals(1, lstAccountPlan.size());
         // Insert GL calendars
        List<GL_Calendar__c> lstGLCalendar = new List<GL_Calendar__c>();

        // For Target 1
        Date startDate = System.today() + 5;
        Date endDate = startDate.addDays(56);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar1);

        insert lstGLCalendar;
        System.assertEquals(1, lstGLCalendar.size());

        // Insert Country Plan Targets
        List<Country_Plan_Target__c> lstCountryPlanTargets = new List<Country_Plan_Target__c>();
        for (Country_Plan__c countryPlan : lstCountryPlan) {
            lstCountryPlanTargets.addAll(CRM_TestDataFactory.createCountryPlanTarget(countryPlan, [SELECT Id FROM GL_Calendar__c ORDER BY Start_Date__c]));
        }
         List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,Target_Quantity__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c 
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, RecordTypeId, Name, CurrencyISOCode, Share__c, Total_Target__c, Target_Quantity__c, Product_Group__c, Customer__c,Returns_Share__c,Billing_Adjustment_Share__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
            ];
        
        // Auto Allocate Account Plan Targets
        //CRM_GenerateAccountPlanTargetsCtrl controller = new CRM_GenerateAccountPlanTargetsCtrl();
        List<Target__c> accountPlanTargetList = CRM_GenerateAccountPlanTargetsCtrl.generateAccountTargetList(countryPlansWithInnerQuery);

        if (!accountPlanTargetList.isEmpty()) {
            upsert accountPlanTargetList Unique_Key__c;
        }
        
        List<Target__c> lstUpdatedTargets2 = [Select Id,Calc_Start_Date__c, Calc_End_Date__c, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.debug('Calc_Start_Date__c ===>' + lstUpdatedTargets2[0].Calc_Start_Date__c);
        System.debug('Calc_End_Date__c ===>' + lstUpdatedTargets2[0].Calc_End_Date__c);
    }
    
    /**
    * 
    * @name dataSetUpNRForApprovedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static void dataSetUpNRForApprovedPhysicalDeal(){
        invokeCustomSetting();
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today().addDays(700),System.Today()+5,1,false);
        for (Product2 objProd: lstProducts){
            objProd.NR_period_weeks__c = 99;
            objProd.Release_Category__c = '23';
        }
        insert lstProducts;
        
        
        
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today(),System.Today().addDays(365),'VOD TV Mobile','NR',34,1,true);
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today()+5,System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED,System.Today(),System.Today().addDays(365),dealRecordTypeId,1,true);
        for(Opportunity objOpp :lstDeals) {
            objOpp.Promo_Start_Date__c = System.Today() +4;
        }
        update lstDeals;
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,12,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,system.today()+30,1000,1,true);
        
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProducts, true);
        System.assertEquals(1, lstCountryPlan.size());

        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlan, lstSoldToAccount, true);
        System.assertEquals(1, lstAccountPlan.size());
         // Insert GL calendars
        List<GL_Calendar__c> lstGLCalendar = new List<GL_Calendar__c>();

        // For Target 1
        Date startDate = System.today() + 5;
        Date endDate = startDate.addDays(56);
        GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
        );
        lstGLCalendar.add(glcalendar1);

        insert lstGLCalendar;
        System.assertEquals(1, lstGLCalendar.size());

        // Insert Country Plan Targets
        List<Country_Plan_Target__c> lstCountryPlanTargets = new List<Country_Plan_Target__c>();
        for (Country_Plan__c countryPlan : lstCountryPlan) {
            lstCountryPlanTargets.addAll(CRM_TestDataFactory.createCountryPlanTarget(countryPlan, [SELECT Id FROM GL_Calendar__c ORDER BY Start_Date__c]));
        }
         List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, Product_Group1__c,Street_Date__c,NR_Product__r.Title_Country__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,Target_Quantity__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c 
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, RecordTypeId, Name, CurrencyISOCode, Share__c, Total_Target__c, Target_Quantity__c, Product_Group__c, Customer__c,Returns_Share__c,Billing_Adjustment_Share__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE NR_Product__c != null
                ORDER BY CreatedDate
            ];
        
        // Auto Allocate Account Plan Targets
        //CRM_GenerateAccountPlanTargetsCtrl controller = new CRM_GenerateAccountPlanTargetsCtrl();
        List<Target__c> accountPlanTargetList = CRM_GenerateAccountPlanTargetsCtrl.generateAccountTargetList(countryPlansWithInnerQuery);

        if (!accountPlanTargetList.isEmpty()) {
            upsert accountPlanTargetList Unique_Key__c;
        }
        
        List<Target__c> lstUpdatedTargets2 = [Select Id,Calc_Start_Date__c, Calc_End_Date__c, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.debug('Calc_Start_Date__c ===>' + lstUpdatedTargets2[0].Calc_Start_Date__c);
        System.debug('Calc_End_Date__c ===>' + lstUpdatedTargets2[0].Calc_End_Date__c);
    }

    
    
    /**
    * @name dataSetUpBundleForPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpBundleForPlannedPhysicalDeal(){
        //Deal Record Type is 'Deal' and Target is for Bundle and Deal Forecast Category is Planned
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_BUNDLE;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today()-400,date.today() -80, 1, true);
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today().addDays(2),System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED,System.Today().addDays(20),System.Today().addDays(365),dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,System.Today().addDays(3),1000,1,true);
        lstBundle = CRM_TestDataTemplate.createBundles(1,true);
        lstBundleProduct = CRM_TestDataTemplate.createBundleProducts(lstBundle,lstProducts,1,true);
        lstTargets = CRM_TestDataTemplate.createBundleTargets(lstSoldToAccount,lstBundle,targetRecordTypeId,true);
    }
    
    /**
    * @name dataSetUpBundleForApprovedPhysicalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpBundleForApprovedPhysicalDeal(){
        //Deal Record Type is 'Deal' and Target is for Bundle and Deal Forecast Category is APPROVED
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_BUNDLE;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today()-400,date.today() -80,1,true);
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today().addDays(2),System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED,System.Today().addDays(2),System.Today().addDays(365),dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,System.Today().addDays(3),1000,1,true);
        lstBundle = CRM_TestDataTemplate.createBundles(1,true);
        lstBundleProduct = CRM_TestDataTemplate.createBundleProducts(lstBundle,lstProducts,1,true);
        lstTargets = CRM_TestDataTemplate.createBundleTargets(lstSoldToAccount,lstBundle,targetRecordTypeId,true);        
    }
    
    /**
    * @name dataSetUpBundleForConfirmedPhysicalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpBundleForConfirmedPhysicalDeal(){
        //Deal Record Type is 'Deal' and Target is for Bundle and Deal Forecast Category is CONFIRMED
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_BUNDLE;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today()-400,date.today() -80,1,true);
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today().addDays(2),System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,System.Today().addDays(2),System.Today().addDays(365),dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,System.Today().addDays(3),1000,1,true);
        lstBundle = CRM_TestDataTemplate.createBundles(1,true);
        lstBundleProduct = CRM_TestDataTemplate.createBundleProducts(lstBundle,lstProducts,1,true);
        lstTargets = CRM_TestDataTemplate.createBundleTargets(lstSoldToAccount,lstBundle,targetRecordTypeId,true);
    } 
    
    /**
    * @name dataSetUpCatalogForPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForPlannedPhysicalDeal(){

       //Deal Record Type is 'Deal' and Target is for Product Group and Deal Forcecat Category is Planned
       invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,date.newInstance(2014, 02, 12), date.today() -80,1,true);
                
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,date.today(),date.today() +365,23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED,date.today() + 2,date.today() + 50,dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,date.today() + 10,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);        
    }
    
    
    /**
    * @name dataSetUpCatalogForPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    * #159: Requiremnt Function For Mid Term Target for Planned Deal
    */
    public static void dataSetUpCatalogForPlannedPhysicalDealMidTerm(){

       //Deal Record Type is 'Deal' and Target is for Product Group and Deal Forcecat Category is Planned
       invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,date.newInstance(2014, 02, 12), date.today() -450,1,true);
                
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,date.today(),date.today() +365,23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED,date.today() + 2,date.today() + 50,dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,date.today() + 10,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);        
    }
    
    /**
    * @name dataSetUpCatalogForApprovedPhysicalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForApprovedPhysicalDeal(){

       //Deal Record Type is 'Deal' and Target is for Product Group and Deal Forcecat Category is Planned
       invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,date.newInstance(2014, 02, 12), date.today() +5,1,true);
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,date.today(),date.today() +365,23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED,date.today() + 2,date.today() + 50,dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,date.today() + 30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);
        List<Target__c> lstUpdatedTargets2 = [Select Id,Calc_Start_Date__c, Calc_End_Date__c,RecordTypeId,Product_Group__c,Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
    }
    
    /**
    * @name dataSetUpCatalogForConfirmedPhysicalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForConfirmedPhysicalDeal(){

        //Deal Record Type is 'Deal' and Target is for Product Group and Deal Forcecat Category is Planned
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,date.newInstance(2014, 02, 12), date.today() -80,1,true);
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,date.today(),date.today() +365,23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,date.today() + 2,date.today() + 50,dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,date.today() + 30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);
        List<Target__c> lstUpdatedTargets2 = [Select Id,Calc_Start_Date__c, Calc_End_Date__c,RecordTypeId,Product_Group__c,Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
    }
   
    /**
    * @name dataSetUpCatalogForHighLevelDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForHighLevelDeal(){

       //Deal Record Type is 'High Level' and Target is for Product Group and Deal Forcecat Category is Planned
       invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,date.newInstance(2014, 02, 12), date.today(),1,true);
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,date.today(),date.today() +365,23,1, false,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,date.today() + 2,date.today() + 50,dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        List<Deal_product_group__c> lstDealProductGroup = CRM_TestDataTemplate.createDealProductGroups(lstDeals, lstProductGroup, true);
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH, date.today() + 30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);
    }
    
    /**
    * @name dataSetUpCatalogForActualDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForActualDeal(){

        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_ACTUALS;
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstSoldToAccount){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstSoldToAccount;
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,date.today() -400,date.today() -60,1,true);
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,date.today(),date.today() +365,23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,date.today() + 20,date.today() + 50,dealRecordTypeId,1,true);
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        update lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH, date.today() + 30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);
        System.AssertEquals(1, lstTargets.size()); 
    }
    
    /**
    * 
    * @name NRForPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void NRForPlannedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpNRForPlannedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Planned__c);
    }
    
    /**
    * 
    * @name NRForConfirmedPhysicalDeal
    * @param none - 
    * @returning -  none
    */
    public static testMethod void NRForConfirmedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpNRForConfirmedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Confirmed__c);
        
    }
    
    /**
    * @name NRForApprovedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void NRForApprovedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpNRForApprovedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Approved__c);
    }
    
    
    
    /**
    * @name BundleForPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void BundleForPlannedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpBundleForPlannedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Planned__c);
        
    }
  
    /**
    * @name BundleForApprovedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void BundleForApprovedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpBundleForApprovedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Approved__c);
        
    }
    
    /**
    * @name BundleForConfirmedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void BundleForConfirmedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpBundleForConfirmedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Confirmed__c);
        
    }   
    
    
    /**
    * @name CatalogForPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void CatalogForPlannedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForPlannedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Planned__c);
  
    }
    
    /**
    * @name CatalogForPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    * #159 Requirement Call to Function dataSetUpCatalogForPlannedPhysicalDealMidTerm
    */ 
    public static testMethod void CatalogForPlannedPhysicalDealMidTerm() {
        checkScenariosToExecute('dataSetUpCatalogForPlannedPhysicalDealMidTerm');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Planned__c);
  
    }
    
    
    
    /**
    * @name CatalogForApprovedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void CatalogForApprovedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForApprovedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
       // System.assertEquals(1000,lstUpdatedTargets[0].Approved__c);
  
    }
    
    /**
    * @name CatalogForConfirmedPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void CatalogForConfirmedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForConfirmedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Confirmed__c);
  
    }
    
    
    /**
    * @name CatalogHighLevelPhysicalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void CatalogHighLevelPhysicalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForHighLevelDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
            Database.executeBatch(batchTarget);
        Test.stopTest();
        
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.debug('lstUpdatedTargets[0].High_Level__c===> ' + lstUpdatedTargets[0].High_Level__c);
        System.assertEquals(547800,lstUpdatedTargets[0].High_Level__c);
  
    }
    
    
  
  
/*********************************** Test Cases for Digital Scenarios **************************************************************************/  
  
  
    /**
    * @name dataSetUpNRForPlannedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpNRForPlannedDigitalDeal(){
        
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;
        
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today().addDays(700),System.Today()+5,1,false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today()+5,System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED,System.Today(),System.Today().addDays(365),dealRecordTypeId,1,true);
        for(Opportunity objOpp :lstDeals) {
            objOpp.Promo_Start_Date__c = System.Today() +4;
        }
        update lstDeals;
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,12,1,false);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        insert lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,system.today()+30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductTargets(lstSoldToAccount,lstProducts,targetRecordTypeId,true);
    }
    
    /**
    * @name dataSetUpNRForConfirmedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpNRForConfirmedDigitalDeal(){
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;
        
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today().addDays(700),System.Today()+5,1,false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today()+5,System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,System.Today(),System.Today().addDays(365),dealRecordTypeId,1,true);
        for(Opportunity objOpp :lstDeals) {
            objOpp.Promo_Start_Date__c = System.Today() +4;
        }
        update lstDeals;
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,12,1,false);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        insert lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,system.today()+30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductTargets(lstSoldToAccount,lstProducts,targetRecordTypeId,true);
    }
    
    /**
    * @name dataSetUpNRForApprovedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpNRForApprovedDigitalDeal(){
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
                
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;
        
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today().addDays(700),System.Today()+5,1,false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL; 
        }
        insert lstProducts;
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today()+5,System.Today().addDays(365),23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED,System.Today(),System.Today().addDays(365),dealRecordTypeId,1,false);
        for(Opportunity objOpp :lstDeals) {
            objOpp.Promo_Start_Date__c = System.Today() +4;
        }
        insert lstDeals;
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,12,1,false);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        insert lstDealProducts;
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,system.today()+30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductTargets(lstSoldToAccount,lstProducts,targetRecordTypeId,true);
    }  
    
    /**
    * @name dataSetUpBundleForPlannedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpBundleForPlannedDigitalDeal(){
        
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_BUNDLE;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;

        /*List<Account> lstPhysicalAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstPhysicalAccount){
            acct.Video_Physical__c = true;
            acct.Games_Physical__c = true;
        }
        insert lstPhysicalAccount;*/
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;        
        
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,System.Today()-400,date.today() -60,1, false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        //lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,System.Today().addDays(2),System.Today(),23,1, true,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts,date.today() -60,System.Today()+400,23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED,System.Today().addDays(20),System.Today().addDays(365),dealRecordTypeId,1,true);
        
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        update lstDealProducts;
        
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,System.Today().addDays(3),1000,1,true);
        lstBundle = CRM_TestDataTemplate.createBundles(1,true);
        lstBundleProduct = CRM_TestDataTemplate.createBundleProducts(lstBundle,lstProducts,1,true);
        lstTargets = CRM_TestDataTemplate.createBundleTargets(lstSoldToAccount,lstBundle,targetRecordTypeId,true);
    }
    
    /**
    * @name dataSetUpBundleForApprovedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpBundleForApprovedDigitalDeal(){
        
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_BUNDLE;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;

        /*List<Account> lstPhysicalAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstPhysicalAccount){
            acct.Video_Physical__c = true;
            acct.Games_Physical__c = true;
        }
        insert lstPhysicalAccount;*/
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;        
        
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, System.Today()-400,date.today() -60,1, false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;

        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts, date.today() -60, System.Today()+400, 23, 1, true, true);        
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED,System.Today().addDays(2),System.Today().addDays(365),dealRecordTypeId,1,true);
        
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
       
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        update lstDealProducts;
        
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,System.Today().addDays(3),1000,1,true);
        lstBundle = CRM_TestDataTemplate.createBundles(1,true);
        lstBundleProduct = CRM_TestDataTemplate.createBundleProducts(lstBundle,lstProducts,1,true);
        lstTargets = CRM_TestDataTemplate.createBundleTargets(lstSoldToAccount,lstBundle,targetRecordTypeId,true);
    }
    
    /**
    * @name dataSetUpBundleForConfirmedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpBundleForConfirmedDigitalDeal(){
        
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_BUNDLE;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;

        /*List<Account> lstPhysicalAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstPhysicalAccount){
            acct.Video_Physical__c = true;
            acct.Games_Physical__c = true;
        }
        insert lstPhysicalAccount;*/
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;        
        
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, System.Today()-400, date.today() -60, 1, false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts, date.today() -60, System.Today()+400,23,1, true,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,System.Today().addDays(2),System.Today().addDays(365),dealRecordTypeId,1,true);
        
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        update lstDealProducts;
        
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,System.Today().addDays(3),1000,1,true);
        lstBundle = CRM_TestDataTemplate.createBundles(1,true);
        lstBundleProduct = CRM_TestDataTemplate.createBundleProducts(lstBundle,lstProducts,1,true);
        lstTargets = CRM_TestDataTemplate.createBundleTargets(lstSoldToAccount,lstBundle,targetRecordTypeId,true);
    } 
    
    /**
    * @name dataSetUpCatalogForPlannedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForPlannedDigitalDeal(){

        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;

        /*List<Account> lstPhysicalAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstPhysicalAccount){
            acct.Video_Physical__c = true;
            acct.Games_Physical__c = true;
        }
        insert lstPhysicalAccount;*/
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);

        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;        
        
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, date.today() -400, date.today() -60,1, false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts, date.today() -60, date.today() +400, 23, 1, false, true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED,System.Today().addDays(2),System.Today().addDays(365),dealRecordTypeId,1,true);
        
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        update lstDealProducts;
        
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,date.today() + 10,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);

    }
    
    
    /**
    * @name dataSetUpCatalogForPlannedDigitalDeal
    * @param none - 
    * @returning -  none
    * #159 dataSetUpCatalogForPlannedDigitalDealMidTerm Function
    */
    public static void dataSetUpCatalogForPlannedDigitalDealMidTerm(){

        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_MID_TERM_NR ;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;

        /*List<Account> lstPhysicalAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstPhysicalAccount){
            acct.Video_Physical__c = true;
            acct.Games_Physical__c = true;
        }
        insert lstPhysicalAccount;*/
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);

        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;        
        
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, date.today() -400, date.today() -60,1, false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            
        }
        insert lstProducts;
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts, date.today() -60, date.today() +400, 23, 1, false, true);
        lstPriceBookPeriod[0].New_Release__c  = true;
        update lstPriceBookPeriod;
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_PLANNED,System.Today().addDays(2),System.Today().addDays(365),dealRecordTypeId,1,true);
        
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        update lstDealProducts;
        
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,date.today() + 10,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);

    }
    
    /**
    * @name dataSetUpCatalogForApprovedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForApprovedDigitalDeal(){

        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;

        /*List<Account> lstPhysicalAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstPhysicalAccount){
            acct.Video_Physical__c = true;
            acct.Games_Physical__c = true;
        }
        insert lstPhysicalAccount;*/
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;        
        
        
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup,date.today() -400, date.today() -60,1, false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts, date.today() -60, date.today() +400,23,1, false,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_APPROVED,System.Today().addDays(2),System.Today().addDays(365),dealRecordTypeId,1,true);
        
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        update lstDealProducts;
        
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,date.today() + 30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);
        List<Target__c> lstUpdatedTargets2 = [Select Id,Calc_Start_Date__c, Calc_End_Date__c,RecordTypeId,Product_Group__c,Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
    }
    
    /**
    * @name dataSetUpCatalogForConfirmedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForConfirmedDigitalDeal(){

        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;

        /*List<Account> lstPhysicalAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstPhysicalAccount){
            acct.Video_Physical__c = true;
            acct.Games_Physical__c = true;
        }
        insert lstPhysicalAccount;*/
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;        
        
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, date.today() -400, date.today() -60,1, false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts, date.today() -60, date.today() +400, 23, 1, false, true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,System.Today().addDays(2),System.Today().addDays(365),dealRecordTypeId,1,true);
        
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        update lstDealProducts;
        
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH,date.today() + 30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);
    }
    
     
    
    /**
    * @name dataSetUpCatalogForHighLevelDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static void dataSetUpCatalogForHighLevelDigitalDeal(){

        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id dealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL;

        /*List<Account> lstPhysicalAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Account acct: lstPhysicalAccount){
            acct.Video_Physical__c = true;
            acct.Games_Physical__c = true;
        }
        insert lstPhysicalAccount;*/
        
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountries = CRM_TestDataTemplate.createCountries(new List<String>{'Africa'}, mainAccountForStoreFront.size(), true);
        List<Agreement__c> lstStoreFront = CRM_TestDataTemplate.createStoreFront(mainAccountForStoreFront, lstCountries, true);
        
        lstSoldToAccount = CRM_TestDataTemplate.createAccounts(1,false);
        for (Integer nAcct = 0; nAcct < lstSoldToAccount.size(); nAcct++){
            Account acct = lstSoldToAccount[nAcct];
            acct.Video_Digital__c = true;
            acct.Games_Digital__c = true;
            acct.Storefront__c = lstStoreFront[nAcct].Id;
        }
        insert lstSoldToAccount;        
        
        //lstFileDiscount = CRM_TestDataTemplate.createFileDiscounts(lstSoldToAccount,System.Today().addDays(2),System.Today().addDays(365),'DVD','NR',20,1,true);
        lstProducts = CRM_TestDataTemplate.createProducts(lstProductGroup, date.today() -400, date.today(),1, false);
        for (Product2 objProd: lstProducts){            
            objProd.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        }
        insert lstProducts;
        
        lstPriceBookEntries = CRM_TestDataTemplate.createPriceBookEntries(lstProducts,1,true);
        lstPriceBookPeriod = CRM_TestDataTemplate.createPriceBookEntryPeriods(lstProducts, date.today(), date.today() +400, 23, 1, false,true);
        lstDeals = CRM_TestDataTemplate.createDealsWithAccounts(lstSoldToAccount,CRM_AppConstants.DEAL_FORECASTCATEGORY_CONFIRMED,date.today() + 2,date.today() + 50,dealRecordTypeId,1,true);
        
        lstDealProducts = CRM_TestDataTemplate.createDealProductsWithOpportunities(lstPriceBookEntries,lstDeals,34,1,true);
        lstDealProducts[0].Account_Price__c=33;
        lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookPeriod[0].Id;
        update lstDealProducts;
        
        List<Deal_product_group__c> lstDealProductGroup = CRM_TestDataTemplate.createDealProductGroups(lstDeals, lstProductGroup, true);
        lstDealsSchedule = CRM_TestDataTemplate.createDealsSchedule(lstDealProducts,11,CRM_AppConstants.SCHEDULE_TYPE_BOTH, date.today() + 30,1000,1,true);
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount,lstProductGroup,targetRecordTypeId,true);
    } 
    
    /**
    * 
    * @name BundleForPlannedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static testMethod void BundleForPlannedDigitalDeal() {
        checkScenariosToExecute('dataSetUpBundleForPlannedDigitalDeal');        
        
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
            System.debug('============> Account size(): ' + [SELECT ID FROM ACCOUNT].size());
            Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Planned__c);
        
    }

    /**
    * 
    * @name BundleForApprovedDigitalDeal
    * @param none - 
    * @returning -  none
    */ 
    public static testMethod void BundleForApprovedDigitalDeal() {
        checkScenariosToExecute('dataSetUpBundleForApprovedDigitalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Approved__c);
        
    }

    /**
    * 
    * @name BundleForConfirmedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static testMethod void BundleForConfirmedDigitalDeal() {
        checkScenariosToExecute('dataSetUpBundleForConfirmedDigitalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Confirmed__c);
        
    }
 
    /**
    * 
    * @name CatalogForPlannedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static testMethod void CatalogForPlannedDigitalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForPlannedDigitalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Planned__c);
  
    }
    
    /**
    * 
    * @name CatalogForPlannedDigitalDealMidTerm
    * @param none - 
    * @returning -  none
    * #159 : Planned Digital Deal Midterm NR
    */
    public static testMethod void CatalogForPlannedDigitalDealMidTerm() {
        checkScenariosToExecute('dataSetUpCatalogForPlannedDigitalDealMidTerm');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Planned__c);
  
    }
    
    /**
    * 
    * @name CatalogForApprovedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static testMethod void CatalogForApprovedDigitalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForApprovedDigitalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Approved__c);
  
    }
    
    /**
    * 
    * @name CatalogForConfirmedDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static testMethod void CatalogForConfirmedDigitalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForConfirmedDigitalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(1000,lstUpdatedTargets[0].Confirmed__c);
  
    }
     

    /**
    * 
    * @name CatalogForHighLevelDigitalDeal
    * @param none - 
    * @returning -  none
    */
    public static testMethod void CatalogForHighLevelDigitalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForHighLevelDigitalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
            Database.executeBatch(batchTarget);
        Test.stopTest();
        
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.debug('lstUpdatedTargets[0].High_Level__c===> ' + lstUpdatedTargets[0].High_Level__c);
        System.assertEquals(547800,lstUpdatedTargets[0].High_Level__c);
  
    }
    
     /**
    *  Test 1
    *  @name CRM_ScheduleTargetRollUp
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void test_CRM_CRM_ScheduleTargetRollUpSchedule(){
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        Test.startTest();
            String jobId = System.schedule('Test CRM_ScheduleTargetRollUp', CRON_EXP, new CRM_ScheduleTargetRollUp() );
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        if(ct != null){
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }
    
    /**
    * @name dataSetUpCatalogForJVPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    * Added as a part of US#W-017615
    */
    public static void dataSetUpCatalogForJVPlannedPhysicalDeal(){

        //Deal Record Type is 'Physical DFI Deal' and Target is for Product Group and Deal Forcecat Category is Planned
        invokeCustomSetting();
        Id targetRecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP;
        Id priceBookJVId = CRM_AutoEstablishSchedulesHelper_Test.priceBookUSJVId;
        
        List<Decay_Curve_Template__c> lstDecayCurveTemplate = CRM_TestDataFactory.createDecayCurveTemplates(1, true);
        List<Decay_Curve_Item__c> lstDecayCurveItem = CRM_TestDataFactory.createItemsWithDecayCurveTemplates(lstDecayCurveTemplate, 3, true);
        
        //Changing Decay Curve Template "Status" to 'Active'.
        lstDecayCurveTemplate[0].Status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_ACTIVE;
        update lstDecayCurveTemplate; 
        
        lstSoldToAccount = CRM_TestDataFactory.createAccounts(1, false);        
        lstSoldToAccount[0].RecordTypeID = CRM_RecordTypeUTil.RT_ACCOUNT_SOLD_TO;
        lstSoldToAccount[0].Class_of_Trade__c = 'Wholesale 5';
        lstSoldToAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
        lstSoldToAccount[0].Decay_Curve_Template__c = lstDecayCurveTemplate[0].ID;
        lstSoldToAccount[0].Price_Book__c = priceBookJVId;
        insert lstSoldToAccount;
        system.assertEquals(CRM_AppConstants.TERRITORY_SDS_US_CODE, lstSoldToAccount[0].Sales_Organization__c);
        
        lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstSoldToAccount, 2, false);
        
        for(Opportunity deal : lstDeals) {
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
            deal.Promo_Start_Date__c = Date.today().addDays(-15);
            deal.Promo_End_Date__c = Date.today().addDays(15);
            deal.Start_Date__c = Date.today().addDays(-15);
            deal.CloseDate = Date.today().addDays(15);
            deal.Price_Type__c = 'ZPRD';
            deal.Pricebook2Id = priceBookJVId;
        }
        insert lstDeals;
        system.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstDeals[0].RecordTypeId);
        
        lstProducts = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false);
        for (Product2 prodInstance : lstProducts) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prodInstance.CurrencyIsoCode = 'USD';
            prodInstance.CanUseQuantitySchedule = true;
            prodInstance.CanUseRevenueSchedule = true;
        }
        insert lstProducts;
        
        lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        System.assertEquals(1,lstPriceBookEntries.size());
        
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries) {
            pbe.Pricebook2Id = priceBookJVId;
        }
        insert customLstPriceBookEntries;
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, false);
        for(Pricebook_Entry_Period__c pbep : lstPriceBookEntryPeriod){
            pbep.Price_Type__c = 'Wholesale 5';
            pbep.Start_Date__c = Date.today().addDays(-15);
            pbep.End_Date__c = Date.today().addDays(15);
            pbep.Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            pbep.Price_Book__c = priceBookJVId;
        }
        insert lstPriceBookEntryPeriod;
        System.assertEquals(1,lstPriceBookEntryPeriod.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod1= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, false);
        for(Pricebook_Entry_Period__c pbep : pricebookentryPeriod1){
            pbep.Price_Type__c = 'PROMOTION';
            pbep.Start_Date__c = Date.today().addDays(-15);
            pbep.End_Date__c = Date.today().addDays(15);
            pbep.Price_Book__c = priceBookJVId;
        }
        insert pricebookentryPeriod1;
        System.assertEquals(1,pricebookentryPeriod1.size());
        
        list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, false);
        for(Pricebook_Entry_Period__c pbep : pricebookentryPeriod2){
            pbep.Price_Type__c = 'DEALER';
            pbep.Start_Date__c = Date.today().addDays(-15);
            pbep.End_Date__c = Date.today().addDays(15);
            pbep.Price_Book__c = priceBookJVId;
        }
        insert pricebookentryPeriod2;
        System.assertEquals(1,pricebookentryPeriod2.size());
        
        List<Deal_product_group__c> lstDealProductGroup = CRM_TestDataTemplate.createDealProductGroups(lstDeals, lstProductGroup, true);
        
        lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstDeals, 2, false);
        for(Integer nProductCount = 0; nProductCount < lstProducts.size(); nProductCount++){ 
            for(OpportunityLineItem oli : lstDealProducts) {
                oli.Start_Date__c = Date.today().addDays(-15);
                oli.End_Date__c = Date.today().addDays(15);
                oli.Initial_Ship_Fcst__c = 100;
                oli.Replen_Ship_Fcst__c = 200;
                oli.Reason__c = 'DFI';
                oli.Account_Fund_Segment__c = 'NAT'; 
                oli.ListPrice__c = 30;
            }
        }
        insert lstDealProducts;
        system.debug('@@** lstDealProducts --> ' + lstDealProducts);
        System.assertEquals(4,lstDealProducts.size());   
        
        lstTargets = CRM_TestDataTemplate.createProductGroupTargets1(lstSoldToAccount, lstProductGroup,targetRecordTypeId,true);        
    }
    
    
    /**
    * @name CatalogForJVPlannedPhysicalDeal
    * @param none - 
    * @returning -  none
    * Added as a part of US#W-017615
    */ 
    public static testMethod void CatalogForJVPlannedPhysicalDeal() {
        checkScenariosToExecute('dataSetUpCatalogForJVPlannedPhysicalDeal');
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        Test.startTest();
        Database.executeBatch(batchTarget);
        Test.stopTest();
        List<Target__c> lstUpdatedTargets = [Select Id, Approved__c, Planned__c, Confirmed__c, Account__c, Actual_Revenue__c, High_Level__c From Target__c];
        System.assertEquals(24000,lstUpdatedTargets[0].Planned__c);
    }

  
}