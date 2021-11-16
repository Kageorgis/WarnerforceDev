@isTest(SeeAllData=false) 
private class CRM_TargetHandler_Test {

    // This method creates the data for Insert and Delete Scenarios
    public static void dataSetUpTargetAccountPlanForInsertAndDelete(){
        List<Account> lstAccounts = CRM_TestDataTemplate.createAccounts(2, false);
        for (Account acct: lstAccounts){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstAccounts;
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(2, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 2, false);
        for (Product2 objProduct: lstProduct){
            objProduct.NR_Product_Created__c = false;
        }
        insert lstProduct;
        
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, false);
        
        for (Country_Plan__c objCountryPlan: lstCountryPlan){
            objCountryPlan.RecordTypeId = CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE;
        }
        insert lstCountryPlan;
        
        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(1, lstCountryPlan[0], lstAccounts[0]);
        lstAccountPlan.addAll(CRM_TestDataFactory.createAccountPlan(1, lstCountryPlan[1], lstAccounts[1]));
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts, lstProductGroup, lstAccountPlan, false);

        
        for (Integer nTarget = 0; nTarget < lstTargets.size(); nTarget++){
            Target__c objTarget = lstTargets[nTarget];
            if (lstAccountPlan != null && lstAccountPlan.size() > 0){                                
                objTarget.Account_Plan_Lookup__c = (nTarget > 0)? lstAccountPlan[math.mod((nTarget + 1), 2)].Id:  lstAccountPlan[(math.mod((nTarget + 1), 2))].Id;
                objTarget.Account__c = (nTarget > 0)? lstAccountPlan[math.mod((nTarget + 1), 2)].Customer__c:  lstAccountPlan[(math.mod((nTarget + 1), 2))].Customer__c;
            }
            objTarget.Target__c = 100;            
            //objTarget.RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            //objTarget.Product__c = lstProduct[0].Id;
        }
        insert lstTargets;       
        
    }

    // This method creates the data for update scenario
    public static void dataSetUpTargetAccountPlanForUpdateAndChangeOfAccountPlan(){
        List<Account> lstAccounts = CRM_TestDataTemplate.createAccounts(1, false);
        for (Account acct: lstAccounts){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstAccounts;
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(2, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true);
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = new List<Account_Plan__c>(); //CRM_TestDataFactory.createAccountPlan(1, lstCountryPlan[0], lstAccounts[0]);
        
        Account_Plan__c accountPlan = new Account_Plan__c();
        accountPlan.Country_Plan__c = lstCountryPlan[0].Id;
        accountPlan.Customer__c = lstAccounts[0].Id;
        accountPlan.Share__c = 645;
        accountPlan.External_Id__c = 'dfg3445f';
        accountPlan.Share__c = 54;
        accountPlan.CurrencyIsoCode = 'USD';        
        lstAccountPlan.add(accountPlan);
        
        Account_Plan__c accountPlan1 = new Account_Plan__c();
        accountPlan1.Country_Plan__c = lstCountryPlan[1].Id;
        accountPlan1.Customer__c = lstAccounts[0].Id;
        accountPlan1.Share__c = 590;
        accountPlan1.External_Id__c = 'sdfhsjkf';
        accountPlan1.Share__c = 16;
        accountPlan1.CurrencyIsoCode = 'USD';
        lstAccountPlan.add(accountPlan1);
        insert lstAccountPlan;
        
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts, lstProductGroup, lstAccountPlan, false);
        for (Integer nTarget = 0; nTarget < lstTargets.size(); nTarget++){
            Target__c objTarget = lstTargets[nTarget];
            if (lstAccountPlan != null && lstAccountPlan.size() > 0){                                
                objTarget.Account_Plan_Lookup__c = ((math.mod((nTarget + 1), 2)) > 0)? lstAccountPlan[math.mod(((nTarget + 1) - 1), 2)].Id:  lstAccountPlan[(math.mod((nTarget + 1), 2))].Id;
                objTarget.Account__c = ((math.mod((nTarget + 1), 2)) > 0)? lstAccountPlan[math.mod(((nTarget + 1) - 1), 2)].Customer__c:  lstAccountPlan[(math.mod((nTarget + 1), 2))].Customer__c;
            }
            objTarget.Target__c = 100;
        }
        insert lstTargets;
    }
    
      // This method creates the data for update scenario
    public static void dataSetUpTargetAccountPlanForUpdateAndChangeOfAccountPlan_1034(){
        List<Account> lstAccounts = CRM_TestDataTemplate.createAccounts(1, false);
        for (Account acct: lstAccounts){
            acct.Games_Physical__c = true;
            acct.Video_Physical__c = true;
        }
        insert lstAccounts;
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(2, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true);
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = new List<Account_Plan__c>(); //CRM_TestDataFactory.createAccountPlan(1, lstCountryPlan[0], lstAccounts[0]);
        
        Account_Plan__c accountPlan = new Account_Plan__c();
        accountPlan.Country_Plan__c = lstCountryPlan[0].Id;
        accountPlan.Customer__c = lstAccounts[0].Id;
        accountPlan.Share__c = 645;
        accountPlan.External_Id__c = 'dfg3445f';
        accountPlan.Share__c = 54;
        accountPlan.CurrencyIsoCode = 'USD';        
        lstAccountPlan.add(accountPlan);
        
        Account_Plan__c accountPlan1 = new Account_Plan__c();
        accountPlan1.Country_Plan__c = lstCountryPlan[1].Id;
        accountPlan1.Customer__c = lstAccounts[0].Id;
        accountPlan1.Share__c = 590;
        accountPlan1.External_Id__c = 'sdfhsjkf';
        accountPlan1.Share__c = 16;
        accountPlan1.CurrencyIsoCode = 'USD';
        lstAccountPlan.add(accountPlan1);
        insert lstAccountPlan;
        
        List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAccounts, lstProductGroup, lstAccountPlan, false);
        for (Integer nTarget = 0; nTarget < lstTargets.size(); nTarget++){
            Target__c objTarget = lstTargets[nTarget];
            if (lstAccountPlan != null && lstAccountPlan.size() > 0){                                
                objTarget.Account_Plan_Lookup__c = ((math.mod((nTarget + 1), 2)) > 0)? lstAccountPlan[math.mod(((nTarget + 1) - 1), 2)].Id:  lstAccountPlan[(math.mod((nTarget + 1), 2))].Id;
                objTarget.Account__c = ((math.mod((nTarget + 1), 2)) > 0)? lstAccountPlan[math.mod(((nTarget + 1) - 1), 2)].Customer__c:  lstAccountPlan[(math.mod((nTarget + 1), 2))].Customer__c;
            }
            objTarget.Target__c = 100;
        }
        insert lstTargets;
    }
    
    //This method will create data for Product Targets //ER-003346 
    public static void dataSetupForProductTarget() {
        List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, true);
        
        List<String> regionLst = new List<String>();
        regionLst.add('US');
        
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(regionLst, 1, true);	
        
        List<Language__c> lstLanguage = CRM_TestDataFactory.createLanguages(1, true);
        
        List<Title__c> lstTitle = CRM_TestDataFactory.createTitles(1, false);
        for(Title__c title :lstTitle) {
            title.Video_Version__c = '6000001234';
        }
        insert lstTitle;
        
        List<Local_Title__c> lstLocalTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstLanguage, 1, false);    
        for(Local_Title__c lt :lstLocalTitle) {
        	lt.Title__c = lstTitle[0].Id;
        }
        insert lstLocalTitle;
            
        System.debug([SELECT Id, Title_VV_F__c FROM Local_Title__c]);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(2, false);
        
        for(Product2 product :lstProduct) {
            product.Local_Title__c = lstLocalTitle[0].Id;
            product.ProductCode = '6000001234';
        }
        lstProduct[0].Product_Format__c = 'SD';
        lstProduct[1].Product_Format__c = 'HD';
        
        insert lstProduct;
        
        system.debug(lstProduct);
    }
    
    
    /*
        Method: CheckPublishedTarget_After_TargetInsert
        Description: This method would check if the 'Target__c' on 'Target' has been rolled up to the associated Account Plan.
        Inputs: 
            Product_Group__c: 2
            Product2: 2
            Country_Plan__c: 2
            Account_Plan__c: 1
            Target__c: 
        Output:
            Targets would be inserted and value of PublishedTarget__c on Account Plan will be updated.
    */
    public static testMethod void CheckPublishedTarget_After_TargetInsert() {
        Test.startTest();
            dataSetUpTargetAccountPlanForInsertAndDelete();
            List<Target__c> lstTargetsInserted = [SELECT Account_Plan_Lookup__c, Account_Plan_Lookup__r.Country_Plan__c, Account_Plan_Lookup__r.Country_Plan__r.RecordType.DeveloperName, RecordType.DeveloperName, Product__c, Target__c, Product__r.NR_Product_Created__c, Rollup_Revenue_Change__c FROM Target__c];
            List<Account_Plan__c> lstAcctPlan = [SELECT PublishedTarget__c FROM Account_Plan__c];
                    
            System.assertEquals(200, lstAcctPlan[0].PublishedTarget__c);
            System.assertEquals(200, lstAcctPlan[1].PublishedTarget__c);            
        Test.stopTest();                
                

        
    }
    
    
    /*
        Method: CheckPublishedTarget_After_TargetDelete
        Description: This method would check if the 'Target__c' on 'Target' has been recalculated and rolled up to the associated Account Plan after deleting the existing Target__c object.
        Inputs: 
            Product_Group__c: 2
            Product2: 2
            Country_Plan__c: 2
            Account_Plan__c: 1
            Target__c: 
        Output:
            Target would be deleted and value of PublishedTarget__c on Account Plan will be updated.
    */  
    public static testMethod void CheckPublishedTarget_After_TargetDelete() {
        dataSetUpTargetAccountPlanForInsertAndDelete();
        List<Account_Plan__c> lstAccountPlanToBeModified = new List<Account_Plan__c>();
        
        Test.startTest();
            List<Target__c> lstTargetToDelete = [SELECT Id, Account_Plan_Lookup__c, Target__c FROM Target__c];          
            lstAccountPlanToBeModified = [SELECT Id, PublishedTarget__c FROM Account_Plan__c WHERE Id =: lstTargetToDelete[0].Account_Plan_Lookup__c];
            delete lstTargetToDelete[0];
            List<Target__c> lstTargetsInserted = [SELECT Account_Plan_Lookup__c, Account_Plan_Lookup__r.Country_Plan__c, Account_Plan_Lookup__r.Country_Plan__r.RecordType.DeveloperName, RecordType.DeveloperName, Product__c, Target__c, Product__r.NR_Product_Created__c, Rollup_Revenue_Change__c FROM Target__c];
            List<Account_Plan__c> lstAcctPlan = [SELECT PublishedTarget__c FROM Account_Plan__c WHERE Id =: lstAccountPlanToBeModified[0].Id];        
        
            System.assertEquals((lstAccountPlanToBeModified[0].PublishedTarget__c - lstTargetToDelete[0].Target__c), lstAcctPlan[0].PublishedTarget__c);            
        Test.stopTest();        
    }
    
    
    /*
        Method: CheckPublishedTarget_AfterUpdate_With_AccountPlanLookup_Changed
        Description: This method would check:
            1. Insert Targets to Account Plans
            2. Change the value of Target Revenue and Account Plan associated with it.
            3. Check if the PublishedTarget__c value for both the Account Plan objects has been changed.
        Inputs: 
            Product_Group__c: 2
            Product2: 2
            Country_Plan__c: 2
            Account_Plan__c: 1
            Target__c: 
        Output:
            Targets would be inserted and value of PublishedTarget__c on Account Plan will be updated.
    */  
    public static testMethod void CheckPublishedTarget_AfterUpdate_With_AccountPlanLookup_Changed() {
        dataSetUpTargetAccountPlanForUpdateAndChangeOfAccountPlan();
        Test.startTest();
            List<Account_Plan__c> lstAcctPlan = [SELECT Id, Customer__c, PublishedTarget__c from Account_Plan__c];
            List<Target__c> lstTargetToDelete = [SELECT Id, Account__c, Account_Plan_Lookup__c FROM Target__c];

            Id IdAcctPlanWithNewTarget;
            
            for (Account_Plan__c acctplan: lstAcctPlan){
                for (Target__c objTarget: lstTargetToDelete){
                    if (objTarget.Account_Plan_Lookup__c != acctplan.Id){
                        objTarget.Account_Plan_Lookup__c = acctplan.Id;
                        IdAcctPlanWithNewTarget = objTarget.Account_Plan_Lookup__c;
                        objTarget.Target__c = 250;
                        break;
                    }
                }
            }
            
            List<Target__c> lstTargetsUpdatedBEFOREUPDATE = [SELECT Id FROM Target__c WHERE Account_Plan_Lookup__c =: IdAcctPlanWithNewTarget];
            List<Account_Plan__c> lstActPlnBEFOREUPDATE = [SELECT Id, PublishedTarget__c FROM Account_Plan__c WHERE Id =: IdAcctPlanWithNewTarget];
            System.assertEquals(lstActPlnBEFOREUPDATE[0].PublishedTarget__c, null);
        
            update lstTargetToDelete;
            List<Account_Plan__c> lstAcctPlanUpdated = [SELECT Id, PublishedTarget__c FROM Account_Plan__c WHERE Id =: IdAcctPlanWithNewTarget];
            List<Target__c> lstTargetsUpdated = [SELECT Id FROM Target__c WHERE Account_Plan_Lookup__c =: IdAcctPlanWithNewTarget];

            System.assertEquals(lstAcctPlanUpdated[0].PublishedTarget__c, 250 );        
        Test.stopTest();        
    }
    
    //US#1034 start
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
        for(Pricebook_Entry_Period__c pbep : [SELECT Id, Product__c, Product__r.RecordTypeId, Process_NR_Batch__c, New_Release__c,
        Start_Date__c, List_price__c FROM Pricebook_Entry_Period__c]) {
            if (pbep.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL) {
                System.assert(!pbep.Process_NR_Batch__c, 'Process NR Batch should be false');
            }
        }
        list<Account_Plan__c> lstAccPlans= [select id from Account_Plan__c];
        delete lstAccPlans;
        List<OpportunityLineItem> dealProductBefore = [SELECT Id, Account_Price__c,Promoted_Price__c, SAP_Promoted_Price__c, Account_Plan__c, Opportunity.AccountId, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem];
        System.assertEquals(3, dealProductBefore.size());    
        List<Target__c> targetInstance = [SELECT Id, Account__c, Product__c, Target__c FROM Target__c];
        delete targetInstance;
        List<OpportunityLineItem> dealProductafter = new List<OpportunityLineItem>();
        dealProductafter = [SELECT Id, Account_Price__c,Promoted_Price__c, SAP_Promoted_Price__c, Account_Plan__c, Opportunity.AccountId, Opportunity.Account.Digital_Country_Code__c, Initial_Quantity__c, Replen_Quantity__c, Target_Quantity__c,Quantity FROM OpportunityLineItem];
        System.assertEquals(0, dealProductafter.size());    
     } 

    //US#1034 end
    
    //ER-003346 Starts Here ------->
    public static testMethod void createTempEADExistingEADTest() {
        
        dataSetupForProductTarget();
        
        List<Account> lstAccount = [SELECT Id FROM Account];
        List<Product2> lstProduct = [SELECT Id, Product_Market__c, Product_Format__c, CurrencyIsoCode, Local_Title__r.Title__c, Local_Title__r.Country__c FROM Product2];
        
        Earliest_Avail_Date__c ead = new Earliest_Avail_Date__c();
        ead.Channel__c = lstProduct[0].Product_Market__c;
        ead.Format__c = lstProduct[0].Product_Format__c;
        ead.Status__c = CRM_AppConstants.EARLIEST_AVAIL_DATE_STATUS_UNLOCKED; 
        ead.Source__c = CRM_AppConstants.EARLIEST_AVAIL_DATE_SOURCE_TARGET;
        ead.CurrencyIsoCode = lstProduct[0].CurrencyIsoCode;
        ead.Title__c = lstProduct[0].Local_Title__r.Title__c;
        ead.Country__c = lstProduct[0].Local_Title__r.Country__c;
        insert ead;
        
        system.debug('EAD Key --> '+[SELECT Key__c FROM Earliest_Avail_Date__c limit 1].Key__c);
        system.debug('EAD ID --> '+ead.Id);
        
        List<Target__c> lstTarget = CRM_TestDataFactory.createProductTargets(lstAccount, lstProduct, false);
        lstTarget.addAll(CRM_TestDataFactory.createProductTargets(lstAccount, lstProduct, false));
        insert lstTarget;
        
        system.assertEquals(2, [SELECT COUNT() FROM Earliest_Avail_Date__c]);
    }
    
    public static testMethod void createTempEADNoExistingEADTest() {
        
        dataSetupForProductTarget();
        
        List<Account> lstAccount = [SELECT Id FROM Account];
        List<Product2> lstProduct = [SELECT Id FROM Product2];
        
        List<Target__c> lstTarget = CRM_TestDataFactory.createProductTargets(lstAccount, lstProduct, false);
        lstTarget.addAll(CRM_TestDataFactory.createProductTargets(lstAccount, lstProduct, false));
        
        insert lstTarget;
                
        system.assertEquals(2, [SELECT COUNT() FROM Earliest_Avail_Date__c]);
    }
    //ER-003346 Ends Here ------->
}