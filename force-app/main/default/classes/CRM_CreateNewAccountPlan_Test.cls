/**
   @Author Cognizant Team
   @name CRM_CreateNewAccountPlan_Test 
   @CreateDate 
   @Description Test class for CRM_CreateNewAccountPlan_Test 
   @Version <1.0>
   @reference Requirement no 161
  */
@isTest
private class CRM_CreateNewAccountPlan_Test {

    public static void createData() {

        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(5);
        for (Account acc : lstAccounts) {
            if (acc.Games_Physical__c) {
                acc.Games_Physical__c = false;
            }
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            if (acc.Games_Physical__c || acc.Video_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (acc.Games_Digital__c || acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
            }
        }
        update lstAccounts;
        System.assertEquals(5, lstAccounts.size());

      /* List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(5);
        for(Account acc:lstAccounts){
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Status__c = CRM_AppConstants.ACCOUNT_STATUS_ACTIVE;
            acc.Price_Book__c = System.Test.getStandardPricebookId();
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE; 
            system.debug('Account values -->'+acc);   
        }
        update lstAccounts;*/

        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProGrp.size());

        List<Product2> lstProduct = CRM_AutoPhysicalNRDealCreateService_Test.createProductsForNRBatch(lstProGrp, lstAccounts);
        System.assertEquals(5, lstProduct.size());
        for (Product2 prod : lstProduct) {
            if (prod.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
                prod.Street_Date__c = System.today() + 32;
            }
            prod.NR_Product_Created__c = false;
        }
        update lstProduct;
        System.assertEquals(5, lstProduct.size());

        List<Country_Plan__c> lstCountryPlans = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, true);
        System.assertEquals(5, lstCountryPlans.size());

        for(Country_Plan__c cp:lstCountryPlans){
            cp.Target_Quantity__c =10.09;
        }
        update lstCountryPlans;
        System.assertEquals(5, lstCountryPlans.size());

        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlans, lstAccounts, true);
        System.assertEquals(25, lstAccountPlan.size());
        for(Account_Plan__c acc:lstAccountPlan){
            acc.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;
        System.assertEquals(25, lstAccountPlan.size());
    }

    /**
     *  Test Method to Create New Account Plan
     *  @name createAccountPlanTest
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    static testMethod void createAccountPlanTest(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        system.runAs(u){
            list<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1,true);
            system.assertNotEquals(null, lstProductGroup[0].id);    
       
            Account acc = New Account();
            acc.Name = 'WB Account';
            acc.Price_Book__c = System.Test.getStandardPricebookId();
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acc;
            system.assertNotEquals(null, acc.id);
            
            Decay_Curve_Template__c dcurve = new Decay_Curve_Template__c();
            dcurve.Name ='Dummu Decay Curve';
            dcurve.Template_Type__c ='Default Template';
            insert dcurve;
            system.assertNotEquals(null, dcurve.id);
            
            Account acc1 = New Account();
            acc1.Name = 'WB Account New';
            acc1.Price_Book__c = System.Test.getStandardPricebookId();
            acc1.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acc1;
            system.assertNotEquals(null, acc1.id);
        
            Target_Split_Template__c targetspiltTmp = new Target_Split_Template__c();
            targetspiltTmp.Name = 'Test Target Split template';
            insert targetspiltTmp;
            system.assertNotEquals(null, targetspiltTmp.id);
            
            Account_Split__c acctSplit = new Account_Split__c();
            acctSplit.Account__c = acc.Id;
            acctSplit.Share__c = 25;
            acctSplit.Handling_Fee__c = 25;
            acctSplit.Rental_Price__c = 25;
            acctSplit.Revenue_Share__c = 25;
            acctSplit.Number_of_Rentals_per_Unit__c = 25;
            acctSplit.Final_Purchase_Price__c = 25;
            acctSplit.Final_Purchase__c = 25;
            acctSplit.Rental_Price__c = 25;
            acctSplit.Decay_Curve__c = dcurve.Id;
            acctSplit.Target_Split_Template__c = targetspiltTmp.Id;
            insert acctSplit;
            system.assertNotEquals(null, acctSplit.id);
            
            Account_Split__c acctSplit1 = new Account_Split__c();
            acctSplit1.Account__c = acc1.Id;
            acctSplit1.Share__c = 35;
            acctSplit1.Handling_Fee__c = 35;
            acctSplit1.Rental_Price__c = 35;
            acctSplit1.Revenue_Share__c = 35;
            acctSplit1.Number_of_Rentals_per_Unit__c = 35;
            acctSplit1.Final_Purchase_Price__c = 35;
            acctSplit1.Final_Purchase__c = 35;
            acctSplit1.Rental_Price__c = 35;
            acctSplit1.Decay_Curve__c = dcurve.Id;
            acctSplit1.Target_Split_Template__c = targetspiltTmp.Id;
            insert acctSplit1;
            system.assertNotEquals(null, acctSplit1.id);
            
            Country_Plan__c countryPlan = new Country_Plan__c();
            countryPlan.Name = 'Test New Country plan';
            countryPlan.Product_Group1__c =lstProductGroup[0].Id;
            countryPlan.Target_Split_Template__c = targetspiltTmp.Id;
            countryPlan.Year__c = '2016';
            countryPlan.Country__c = 'United Kingdom';
            insert countryPlan;
            system.assertNotEquals(null, countryPlan.id);
            
            list<Account_Plan__c> lstAccountPlan = new list<Account_Plan__c>([Select id,Share__c from Account_Plan__c]);
            system.debug('======>>>>>>'+lstAccountPlan );
            system.assertEquals(2,lstAccountPlan.size());
        }
    }
    
    /**
     *  create Test Data to insert the Account plan where accounts are not matching and update existing where Account gets match
     *  @name upsertAccountPlanTest
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    static testMethod void upsertAccountPlanTest(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        system.runAs(u){
            list<Product_Group__c> productGrouplst = CRM_TestDataFactory.createProductGroups(1,True);
            system.assertNotEquals(null, productGrouplst[0].id);
            
            //Account Creation
            Account acct = New Account();
            acct.Name = 'WB Account test';
            acct.Price_Book__c = System.Test.getStandardPricebookId();
            acct.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct;
            system.assertNotEquals(null, acct.id);
            
            Decay_Curve_Template__c dcurve = new Decay_Curve_Template__c();
            dcurve.Name ='Dummu Decay Curve';
            dcurve.Template_Type__c ='Default Template';
            insert dcurve;
            system.assertNotEquals(null, dcurve.id);
        
            Account acct1 = New Account();
            acct1.Name = 'Amazone Account';
            acct1.Price_Book__c = System.Test.getStandardPricebookId();
            acct1.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct1;
            system.assertNotEquals(null, acct1.id);
            
            Account acct2 = New Account();
            acct2.Name = 'WB Bros Test Account';
            acct2.Price_Book__c = System.Test.getStandardPricebookId();
            acct2.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acct2;
            system.assertNotEquals(null, acct2.id);
        
            //Target Split template
            Target_Split_Template__c targetspiltTmp1 = new Target_Split_Template__c();
            targetspiltTmp1.Name = 'Test Target Split template';
            insert targetspiltTmp1;
            system.assertNotEquals(null, targetspiltTmp1.id);
            
            //Account Splits related to Target Split Templates 
            Account_Split__c acctSplit = new Account_Split__c();
            acctSplit.Account__c = acct1.Id;
            acctSplit.Share__c = 25;
            acctSplit.Handling_Fee__c = 25;
            acctSplit.Rental_Price__c = 25;
            acctSplit.Revenue_Share__c = 25;
            acctSplit.Number_of_Rentals_per_Unit__c = 25;
            acctSplit.Final_Purchase_Price__c = 25;
            acctSplit.Final_Purchase__c = 25;
            acctSplit.Rental_Price__c = 25;
            acctSplit.Decay_Curve__c = dcurve.Id;
            acctSplit.Target_Split_Template__c = targetspiltTmp1.Id;
            insert acctSplit;
            system.assertNotEquals(null, acctSplit.id);
        
            Account_Split__c acctSplit2 = new Account_Split__c();
            acctSplit2.Account__c = acct2.Id;
            acctSplit2.Share__c = 25;
            acctSplit.Handling_Fee__c = 35;
            acctSplit.Rental_Price__c = 35;
            acctSplit.Revenue_Share__c = 35;
            acctSplit.Number_of_Rentals_per_Unit__c = 35;
            acctSplit.Final_Purchase_Price__c = 35;
            acctSplit.Final_Purchase__c = 35;
            acctSplit.Rental_Price__c = 35;
            acctSplit.Decay_Curve__c = dcurve.Id;
            acctSplit2.Target_Split_Template__c = targetspiltTmp1.Id;
            insert acctSplit2;
            system.assertNotEquals(null, acctSplit2.id);
            
            //Country Plan
            Country_Plan__c countryPlan = new Country_Plan__c();
            countryPlan.Name = 'Test New Country plan';
            countryPlan.Product_Group1__c =productGrouplst[0].Id;
            countryPlan.Year__c = '2016';
            countryPlan.Country__c = 'United Kingdom';
            insert countryPlan;
            system.assertNotEquals(null, countryPlan.id);
        
            Account_Plan__c acctPlan = New Account_Plan__c();
            acctPlan.Country_Plan__c =countryPlan.Id;
            acctPlan.Share__c = 10;
            acctPlan.Customer__c = acct1.id;
            insert acctPlan;
            system.assertNotEquals(null, acctPlan.id);
            countryPlan.Target_Split_Template__c = targetspiltTmp1.Id;
            update countryPlan;
            list<Account_Plan__c> lstAccountPlan = new list<Account_Plan__c>([Select id,Share__c from Account_Plan__c]);
            system.debug('======>>>>>>'+lstAccountPlan );
            system.assertEquals(2,lstAccountPlan.size());
        }
    }

    static testMethod void testValidCountryPlanWithTargetQtyUpdate() {
        createData();

        Map<Id,Country_Plan__c> countryPlanMap =
            new Map<Id,Country_Plan__c>(
                [
                    SELECT
                        Id, Target_Quantity__c, Stretch_Target__c, NR_Product__r.RecordTypeId, Street_Date__c, 
                        NR_Product__r.Product_Type__c, NR_Product__r.Type__c, NR_Product__r.isActive,NR_Product__r.Exclusive_Customer__c,
                        NR_Product__r.NR_Product_Created__c,NR_Product__r.SAP_Sales_Org__c
                    FROM Country_Plan__c
                ]
            );

        System.assertEquals(
            0,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );

        Test.startTest();
        for (Country_Plan__c cp : countryPlanMap.values()) {
            cp.Target_Quantity__c = 35.5;
        }
        update countryPlanMap.values();
        Test.stopTest();

        // Verify Valid Records should be updated to Target_Revenue_Has_Changed__c = true
        System.assertEquals(
            6,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );

        Map<Id, List<Account_Plan__c>> mapProdIdToAccountPlan = new Map<Id, List<Account_Plan__c>>();
        for (Account_Plan__c accountPlan : [SELECT Id, Country_Plan__r.NR_Product__c FROM Account_Plan__c WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true]
        ) {
            if (!mapProdIdToAccountPlan.containsKey(accountPlan.Country_Plan__r.NR_Product__c)) {
                mapProdIdToAccountPlan.put(accountPlan.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlan});
            } else {
                mapProdIdToAccountPlan.get(accountPlan.Country_Plan__r.NR_Product__c).add(accountPlan);
            }
        }

        Integer countProducts = 0;
        for (Product2 prod : [SELECT Id, Type__c FROM Product2]) {
            // Account Plan with Target_Revenue_Has_Changed__c = true for Video Physical Product not present
            // because there is not account with Video Physical = true
            if (prod.Type__c == 'Games Physical') {
                System.assertEquals(false, mapProdIdToAccountPlan.containsKey(prod.Id));
                countProducts++;
            } else if (prod.Type__c == 'Games Digital') {
                System.assertEquals(1, mapProdIdToAccountPlan.get(prod.Id).size());
                countProducts++;
            } else if (prod.Type__c == 'Video Physical') {
                System.assertEquals(1, mapProdIdToAccountPlan.get(prod.Id).size());
                countProducts++;
            } else if (prod.Type__c == 'Video Digital') {
                System.assertEquals(2, mapProdIdToAccountPlan.get(prod.Id).size());
                countProducts++;
            } else if (prod.Type__c == 'Video Digital') {
                System.assertEquals(2, mapProdIdToAccountPlan.get(prod.Id).size());
                countProducts++;
            }
        }
        System.assertEquals(5, countProducts);
    }

   static testMethod void testValidCountryPlanWithStrechUpdate() {
        createData();

        Map<Id,Country_Plan__c> countryPlanMap =
            new Map<Id,Country_Plan__c>(
                [SELECT Id, Target_Quantity__c, Stretch_Target__c FROM Country_Plan__c]
            );

        System.assertEquals(
            0,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );

        Test.startTest();
        for (Country_Plan__c cp : countryPlanMap.values()) {
            cp.Stretch_Target__c = cp.Stretch_Target__c + 5;
        }

        update countryPlanMap.values();
        Test.stopTest();

        // Verify Valid Records should be updated to Target_Revenue_Has_Changed__c = true
        System.assertEquals(
            6,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );

        Map<Id, List<Account_Plan__c>> mapProdIdToAccountPlan = new Map<Id, List<Account_Plan__c>>();
        for (Account_Plan__c accountPlan : [SELECT Id, Country_Plan__r.NR_Product__c FROM Account_Plan__c WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true]
        ) {
            if (!mapProdIdToAccountPlan.containsKey(accountPlan.Country_Plan__r.NR_Product__c)) {
                mapProdIdToAccountPlan.put(accountPlan.Country_Plan__r.NR_Product__c, new List<Account_Plan__c>{accountPlan});
            } else {
                mapProdIdToAccountPlan.get(accountPlan.Country_Plan__r.NR_Product__c).add(accountPlan);
            }
        }

        Integer countProducts = 0;
        for (Product2 prod : [SELECT Id, Type__c FROM Product2]) {
            // Account Plan with Target_Revenue_Has_Changed__c = true for Video Physical Product not present
            // because there is not account with Video Physical = true
            if (prod.Type__c == 'Games Physical') {
                System.assertEquals(false, mapProdIdToAccountPlan.containsKey(prod.Id));
                countProducts++;
            } else if (prod.Type__c == 'Games Digital') {
                System.assertEquals(1, mapProdIdToAccountPlan.get(prod.Id).size());
                countProducts++;
            } else if (prod.Type__c == 'Video Physical') {
                System.assertEquals(1, mapProdIdToAccountPlan.get(prod.Id).size());
                countProducts++;
            } else if (prod.Type__c == 'Video Digital') {
                System.assertEquals(2, mapProdIdToAccountPlan.get(prod.Id).size());
                countProducts++;
            } else if (prod.Type__c == 'Video Digital') {
                System.assertEquals(2, mapProdIdToAccountPlan.get(prod.Id).size());
                countProducts++;
            }
        }
        System.assertEquals(5, countProducts);
    }

    static testMethod void testValidCountryPlanWithSomeOtherFieldUpdate() {
        createData();

        Map<Id,Country_Plan__c> countryPlanMap =
            new map<Id,Country_Plan__c>(
                [SELECT Id, Target_Quantity__c, Stretch_Target__c FROM Country_Plan__c]
            );

        System.assertEquals(
            0,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );

        Test.startTest();
        for (Country_Plan__c cp : countryPlanMap.values()) {
            cp.Year__c = '2016'; 
        }
        update countryPlanMap.values();
        Test.stopTest();

        // Verify Records not updated with Target_Revenue_Has_Changed__c = true as target Quantity
        // OR Stretch Target is not updated and some other field is updated
        System.assertEquals(
            0,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );
    }

    static testMethod void testInValidCountryPlanWithTargetQtyUpdate() {
        createData();

        List<Product2> updateProductList = [SELECT Id, NR_Product_Created__c FROM Product2];
        for (Product2 prod : updateProductList) {
            prod.NR_Product_Created__c = true;
        }
        update updateProductList;

        Map<Id,Country_Plan__c> countryPlanMap =
            new Map<Id,Country_Plan__c>(
                [SELECT Id, Target_Quantity__c, Stretch_Target__c FROM Country_Plan__c]
            );

        System.assertEquals(
            0,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );

        Test.startTest();
        for (Country_Plan__c cp : countryPlanMap.values()) {
            cp.Target_Quantity__c =35.5; 
        }
        update countryPlanMap.values();
        Test.stopTest();

        // Verify Records not updated with Target_Revenue_Has_Changed__c = true as Target Quantity is
        // Changed along with Condition which is not satisfied (Scenario 1 present)
        System.assertEquals(
            0,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );
    }

    static testMethod void testInValidCountryPlanWithStrechUpdate() {
        createData();

        List<Product2> updateProductList = [SELECT Id, NR_Product_Created__c FROM Product2];
        for (Product2 prod : updateProductList) {
            prod.NR_Product_Created__c = true;
        }
        update updateProductList;

        Map<Id,Country_Plan__c> countryPlanMap =
            new Map<Id,Country_Plan__c>(
                [SELECT Id, Target_Quantity__c, Stretch_Target__c FROM Country_Plan__c]
            );

        System.assertEquals(
            0,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );

        Test.startTest();
        for (Country_Plan__c cp : countryPlanMap.values()) {
            cp.Stretch_Target__c = cp.Stretch_Target__c + 5; 
        }
        update countryPlanMap.values();
        Test.stopTest();

        // Verify Records not updated with Target_Revenue_Has_Changed__c = true as Stretch Target is
        // Changed along with Condition which is not satisfied (Scenario 1 present)
        System.assertEquals(
            0,
            [
                SELECT count()
                FROM Account_Plan__c
                WHERE Country_Plan__c IN :countryPlanMap.keySet()
                AND Target_Revenue_Has_Changed__c = true
            ]
        );
    }
    /**
     *  Test Method to Update Linked NR Product (Requirment : 479)
     *  @name updateNRProductTest 
     *  @param none
     *  @return None
     *  @throws Exception None
     
    static testMethod void updateNRProductTest(){
        List<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, true);
        
        //create country
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'FR'}, 1, true);
        
        //Create Language
        List<Language__c> lList = new List<Language__c>();
      Language__c japanLang = TestUtil.createLanguage('France', 'USD',1);
      lList.add(japanLang);
      insert lList;  
        
        //Create Local Title    
        List<Local_Title__c> localdata =  CRM_TestDataFactory.createLocalTitles(countries,lList,1,true);
        
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProGrp.size());

        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp,5,false);
        for (Product2 prod : lstProduct) {
            prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            prod.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG;
            prod.Product_Price_Group__c  = CRM_AppConstants.PRODUCT_TYPE_CATALOG;
            prod.Street_Date__c = System.today() + 2;
            prod.NR_Product_Created__c = false;
            prod.Local_Title__c = localdata[0].Id;
        }
        insert lstProduct;
        System.assertEquals(5, lstProduct.size());
        for(Product2 prod : [Select Id,Release_Category__c,Product_Price_Group__c,Is_NR_Product__c From Product2]){
            system.assertEquals(CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG,prod.Release_Category__c,'Before linked to NR Country plane Products Release Category should be CATALOG');
            system.assertEquals(CRM_AppConstants.PRODUCT_TYPE_CATALOG,prod.Product_Price_Group__c,'Before linked to NR Country plane Product Price Group should be LB');
            //system.assertEquals(false,prod.Is_NR_Product__c,'Before linked to NR Country plane Products Is_NR_Product__c flag should be false');
        }
        
        Test.startTest();
        List<Country_Plan__c> lstCountryPlans = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, false);
        for (Country_Plan__c cp : lstCountryPlans) {
            cp.RecordTypeId = CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE;
            cp.Country__c = CRM_AppConstants.FRANCE_COUNTRY;
        }
        insert lstCountryPlans;
        System.assertEquals(5, lstCountryPlans.size());
        Test.stopTest();
        List<Product2> lstProdcuts = [Select Id,Release_Category__c,Product_Price_Group__c,Is_NR_Product__c From Product2];
        for(Product2 prod : lstProdcuts){
            system.assertEquals(CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG,prod.Release_Category__c,'After linked to NR Country plane Products Release Category should be still Catalog');
            system.assertEquals(CRM_AppConstants.PRODUCT_TYPE_CATALOG,prod.Product_Price_Group__c,'After linked to NR Country plane Product Price Group should be still Catalog');
            //system.assertEquals(true,prod.Is_NR_Product__c,'After linked to NR Country plane Products Is_NR_Product__c flag should be true');
          prod.Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG;
        }
        
        update lstProdcuts;
        for(Product2 prod : [Select Release_Category__c,Product_Price_Group__c From Product2]){
            system.assertEquals(CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG,prod.Release_Category__c,'Products Release Category should not be modified');
            system.assertEquals(CRM_AppConstants.PRODUCT_TYPE_CATALOG,prod.Product_Price_Group__c,'Product Price Group should not be modified');
      }
    }*/
    
    /**
     *  Test Method For Negative Case of Update NR Product (Requirment : 479)
     *  @name updateNRProductTest 
     *  @param none
     *  @return None
     *  @throws Exception None
     
    static testMethod void updateNRProductNegativeTest(){
        List<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, true);
        
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProGrp.size());

        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp,3,false);
        for (integer i=0;i<lstProduct.size();i++) {
            lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            lstProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG;
            lstProduct[i].Street_Date__c = System.today();
            lstProduct[i].Product_Price_Group__c = CRM_AppConstants.PRODUCT_TYPE_CATALOG;
            lstProduct[i].NR_Product_Created__c = false;
        }
        insert lstProduct;
        System.assertEquals(3, lstProduct.size());
        Test.startTest();
        
        List<Country_Plan__c> lstCountryPlans = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, false);
        for (integer i=0;i<lstCountryPlans.size();i++){
            lstCountryPlans[i].Country__c = CRM_AppConstants.FRANCE_COUNTRY;
        }
        insert lstCountryPlans;
        System.assertEquals(3, lstCountryPlans.size());
        Test.stopTest();
        
        for(Product2 prod : [Select Id,Release_Category__c,Product_Price_Group__c,Is_NR_Product__c From Product2]){
            system.assertEquals(CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG,prod.Release_Category__c,'Release Category should not be updated to NEW RELEASE');
            system.assertEquals(CRM_AppConstants.PRODUCT_TYPE_CATALOG,prod.Product_Price_Group__c,'Product Price Group should not be Updatde to NR');
            system.assertEquals(false,prod.Is_NR_Product__c,'Products Is_NR_Product__c flag should be false');
        }
    }*/
     static testMethod void updateNRProductAccountPlan(){
        List<Account> lstParentAccounts = CRM_TestDataFactory.createAccounts(1, true);
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstParentAccounts, 1, true);
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProGrp.size());

        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp,3,false);
        for (integer i=0;i<lstProduct.size();i++) {
            lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            lstProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG;
            lstProduct[i].Street_Date__c = System.today();
            lstProduct[i].Product_Price_Group__c = CRM_AppConstants.PRODUCT_TYPE_CATALOG;
            lstProduct[i].NR_Product_Created__c = false;
        }
        insert lstProduct;
        System.assertEquals(3, lstProduct.size());
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
        List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, true);
       
        Test.startTest();
        
        List<Country_Plan__c> lstCountryPlans = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, false);
        for (integer i=0;i<lstCountryPlans.size();i++){
            lstCountryPlans[i].Country__c = CRM_AppConstants.FRANCE_COUNTRY;
        }
        insert lstCountryPlans;
        System.assertEquals(3, lstCountryPlans.size());
        Test.stopTest();
        
        for(Product2 prod : [Select Id,Release_Category__c,Product_Price_Group__c,NR_Product_Created__c From Product2]){
            system.assertEquals(CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_CATALOG,prod.Release_Category__c,'Release Category should not be updated to NEW RELEASE');
            system.assertEquals(CRM_AppConstants.PRODUCT_TYPE_CATALOG,prod.Product_Price_Group__c,'Product Price Group should not be Updatde to NR');
            system.assertEquals(false,prod.NR_Product_Created__c,'NR Product Created flag should not be updated to true');
        }
    }
     /**
     *  Test Method to Create New Account Plan
     *  @name createAccountPlanTest
     *  @param none
     *  @return None
     *  @throws Exception None
     */
    static testMethod void createAccountPlanTestValidation(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        system.runAs(u){
            list<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1,true);
            system.assertNotEquals(null, lstProductGroup[0].id);    
       
            Account acc = New Account();
            acc.Name = 'WB Account';
            acc.Price_Book__c = System.Test.getStandardPricebookId();
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Planning_Customer__c = true;
            acc.CurrencyIsoCode = 'USD';
            insert acc;
            List<Account> lstAcc =new List<Account>();
            lstAcc.add(acc);
            system.assertNotEquals(null, acc.id);
            
            Decay_Curve_Template__c dcurve = new Decay_Curve_Template__c();
            dcurve.Name ='Dummu Decay Curve';
            dcurve.Template_Type__c ='Default Template';
            insert dcurve;
            system.assertNotEquals(null, dcurve.id);  
        
            Target_Split_Template__c targetspiltTmp = new Target_Split_Template__c();
            targetspiltTmp.Name = 'Test Target Split template';
            insert targetspiltTmp;
            system.assertNotEquals(null, targetspiltTmp.id);
            
            Account_Split__c acctSplit = new Account_Split__c();
            acctSplit.Account__c = acc.Id;
            acctSplit.Share__c = 25;
            acctSplit.Handling_Fee__c = 25;
            acctSplit.Rental_Price__c = 25;
            acctSplit.Revenue_Share__c = 25;
            acctSplit.Number_of_Rentals_per_Unit__c = 25;
            acctSplit.Final_Purchase_Price__c = 25;
            acctSplit.Final_Purchase__c = 25;
            acctSplit.Rental_Price__c = 25;
            acctSplit.Decay_Curve__c = dcurve.Id;
            acctSplit.Target_Split_Template__c = targetspiltTmp.Id;
            insert acctSplit;
            system.assertNotEquals(null, acctSplit.id);
            
            List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAcc, 1, true);
            List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false);
            for (Product2 prodInstance : lstProduct) {
                prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            }
            insert lstProduct; 
            List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
            List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
            List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, true);
            // Insert max Product limit per page
              
            Country_Plan__c countryPlan = new Country_Plan__c();
            countryPlan.Name = 'Test New Country plan';
            countryPlan.Product_Group1__c =lstProductGroup[0].Id;
            countryPlan.Target_Split_Template__c = targetspiltTmp.Id;
            countryPlan.Year__c = '2016';
            countryPlan.NR_Product__c= lstProduct[0].id;
            countryPlan.Country__c = 'United Kingdom';
            insert countryPlan;
            system.assertNotEquals(null, countryPlan.id);
            // Insert GL calendars
            List<GL_Calendar__c> lstGLCalendar = new List<GL_Calendar__c>();
            
            Date startDate = System.today().toStartOfMonth();
            Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
            GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
            );
            lstGLCalendar.add(glcalendar1);
            // Insert Country Plan Targets
            List<Country_Plan_Target__c> lstCountryPlanTargets = new List<Country_Plan_Target__c>();
            lstCountryPlanTargets.addAll(CRM_TestDataFactory.createCountryPlanTarget(countryPlan, [SELECT Id FROM GL_Calendar__c ORDER BY Start_Date__c]));
            //insert acc plan 
            list<Account_Plan__c> lstAccountPlan = new list<Account_Plan__c>([Select id,Country_Plan__r.Nr_Product__c,Customer__c from Account_Plan__c]);
            system.debug('======>>>>>>'+lstAccountPlan );
            system.assertEquals(1,lstAccountPlan.size()); 

             List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAcc ,lstProductGroup, lstAccountPlan, false);
            for(Integer i=0 ;i<lstTargets.size();i++){
                lstTargets[i].Target__c = 520;
                lstTargets[i].Account__c = lstAcc[i].Id;
                lstTargets[i].Product__c = lstProduct[i].id;
                lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            } 
            insert lstTargets;  
            system.debug('----->lstTargets'+lstTargets); 
            
            list<Target__c> lstAccountPlanTarget = new list<Target__c>([Select id,Account__c,Product__c,Account_Plan_Lookup__c 
                                                                                from Target__c]);
            system.debug('===lstAccountPlanTarget===>>>>>>'+lstAccountPlanTarget );
            system.assertEquals(1,lstAccountPlanTarget.size()); 
             
            Target_Split_Template__c targetspiltTmp1 = new Target_Split_Template__c();
            targetspiltTmp1.Name = 'Test Target Split2 template2';
            insert targetspiltTmp1;
            system.assertNotEquals(null, targetspiltTmp1.id);
            
            Account_Split__c acctSplit1 = new Account_Split__c();
            acctSplit1.Account__c = acc.Id;
            acctSplit1.Share__c = 2;
            acctSplit1.Handling_Fee__c = 2;
            acctSplit1.Rental_Price__c = 2;
            acctSplit1.Revenue_Share__c = 2;
            acctSplit1.Number_of_Rentals_per_Unit__c = 25;
            acctSplit1.Final_Purchase_Price__c = 25;
            acctSplit1.Final_Purchase__c = 25;
            acctSplit1.Rental_Price__c = 25;
            acctSplit1.Decay_Curve__c = dcurve.Id;
            acctSplit1.Target_Split_Template__c = targetspiltTmp1.Id;
            insert acctSplit1;
            system.assertNotEquals(null, acctSplit1.id);  
            
            list<Country_Plan__c> lstCountryPlan= new list<Country_Plan__c>([Select id,Target_Split_Template__c from Country_Plan__c where name='Test New Country plan']);
            lstCountryPlan[0].Target_Split_Template__c = targetspiltTmp1.Id;
            lstCountryPlan[0].Approve_Deletion_of_All_Account_Plan__c=true;
            
            try{
                update lstCountryPlan;
            }catch(System.DmlException ex){
                Boolean expectedExceptionThrown =  (ex.getDmlMessage(0).contains(System.Label.CRM_Cannot_Change_Target_Split_Template)) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
     static testMethod void createAccountPlanTestWithoutValidation(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        system.runAs(u){
            list<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1,true);
            system.assertNotEquals(null, lstProductGroup[0].id);    
       
            Account acc = New Account();
            acc.Name = 'WB Account';
            acc.Price_Book__c = System.Test.getStandardPricebookId();
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            insert acc;
            List<Account> lstAcc =new List<Account>();
            lstAcc.add(acc);
            system.assertNotEquals(null, acc.id);

            List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false);
            for (Product2 prodInstance : lstProduct) {
                prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            }
            insert lstProduct; 
            Decay_Curve_Template__c dcurve = new Decay_Curve_Template__c();
            dcurve.Name ='Dummu Decay Curve';
            dcurve.Template_Type__c ='Default Template';
            insert dcurve;
            system.assertNotEquals(null, dcurve.id);  
        
            Target_Split_Template__c targetspiltTmp = new Target_Split_Template__c();
            targetspiltTmp.Name = 'Test Target Split template';
            insert targetspiltTmp;
            system.assertNotEquals(null, targetspiltTmp.id);
            
            Account_Split__c acctSplit = new Account_Split__c();
            acctSplit.Account__c = acc.Id;
            acctSplit.Share__c = 25;
            acctSplit.Handling_Fee__c = 25;
            acctSplit.Rental_Price__c = 25;
            acctSplit.Revenue_Share__c = 25;
            acctSplit.Number_of_Rentals_per_Unit__c = 25;
            acctSplit.Final_Purchase_Price__c = 25;
            acctSplit.Final_Purchase__c = 25;
            acctSplit.Rental_Price__c = 25;
            acctSplit.Decay_Curve__c = dcurve.Id;
            acctSplit.Target_Split_Template__c = targetspiltTmp.Id;
            insert acctSplit;
            system.assertNotEquals(null, acctSplit.id); 
              
            Country_Plan__c countryPlan = new Country_Plan__c();
            countryPlan.Name = 'Test New Country plan';
            countryPlan.Product_Group1__c =lstProductGroup[0].Id;
            countryPlan.Target_Split_Template__c = targetspiltTmp.Id;
            countryPlan.Year__c = '2016';
            countryPlan.NR_Product__c= lstProduct[0].id;
            countryPlan.Country__c = 'United Kingdom';
            insert countryPlan;
            system.assertNotEquals(null, countryPlan.id);
            // Insert GL calendars
            List<GL_Calendar__c> lstGLCalendar = new List<GL_Calendar__c>();
            
            Date startDate = System.today().toStartOfMonth();
            Date endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month())-1);
            GL_Calendar__c glcalendar1 = new GL_Calendar__c(
            Start_Date__c = startDate,
            End_Date__c = endDate,
            Name = startDate.year() + '-' + startDate.month(),
            Month__c = String.valueOf(startDate.month()), 
            Year__c = String.valueOf(startDate.year())
            );
            lstGLCalendar.add(glcalendar1);
            // Insert Country Plan Targets
            List<Country_Plan_Target__c> lstCountryPlanTargets = new List<Country_Plan_Target__c>();
            lstCountryPlanTargets.addAll(CRM_TestDataFactory.createCountryPlanTarget(countryPlan, [SELECT Id FROM GL_Calendar__c ORDER BY Start_Date__c]));
            //insert acc plan 
            list<Account_Plan__c> lstAccountPlan = new list<Account_Plan__c>([Select id,Country_Plan__r.Nr_Product__c,Customer__c from Account_Plan__c]);
            system.debug('======>>>>>>'+lstAccountPlan );
            system.assertEquals(1,lstAccountPlan.size()); 

             List<Target__c> lstTargets = CRM_TestDataFactory.createTargets(lstAcc ,lstProductGroup, lstAccountPlan, false);
            for(Integer i=0 ;i<lstTargets.size();i++){
                lstTargets[i].Target__c = 520;
                lstTargets[i].Account__c = lstAcc[i].Id;
                lstTargets[i].Product__c = lstProduct[i].id;
                lstTargets[i].RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
            } 
            insert lstTargets;  
            system.debug('----->lstTargets'+lstTargets); 
            
            list<Target__c> lstAccountPlanTarget = new list<Target__c>([Select id,Account__c,Product__c,Account_Plan_Lookup__c 
                                                                                from Target__c]);
            system.debug('===lstAccountPlanTarget===>>>>>>'+lstAccountPlanTarget );
            system.assertEquals(1,lstAccountPlanTarget.size()); 
             
            Target_Split_Template__c targetspiltTmp1 = new Target_Split_Template__c();
            targetspiltTmp1.Name = 'Test Target Split2 template2';
            insert targetspiltTmp1;
            system.assertNotEquals(null, targetspiltTmp1.id);
            
            Account_Split__c acctSplit1 = new Account_Split__c();
            acctSplit1.Account__c = acc.Id;
            acctSplit1.Share__c = 2;
            acctSplit1.Handling_Fee__c = 2;
            acctSplit1.Rental_Price__c = 2;
            acctSplit1.Revenue_Share__c = 2;
            acctSplit1.Number_of_Rentals_per_Unit__c = 25;
            acctSplit1.Final_Purchase_Price__c = 25;
            acctSplit1.Final_Purchase__c = 25;
            acctSplit1.Rental_Price__c = 25;
            acctSplit1.Decay_Curve__c = dcurve.Id;
            acctSplit1.Target_Split_Template__c = targetspiltTmp1.Id;
            insert acctSplit1;
            system.assertNotEquals(null, acctSplit1.id);  
            
            list<Country_Plan__c> lstCountryPlan= new list<Country_Plan__c>([Select id,Target_Split_Template__c from Country_Plan__c where name='Test New Country plan']);
            lstCountryPlan[0].Target_Split_Template__c = targetspiltTmp1.Id;
            lstCountryPlan[0].Approve_Deletion_of_All_Account_Plan__c=true;
            
            Test.startTest(); 
                update lstCountryPlan;
            Test.stopTest();
              
        }
    }

    static testMethod void testTargetSplitTemplateChangeDefect() {
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

        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(5);
        for (Account acc : lstAccounts) {
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            if (acc.Games_Physical__c || acc.Video_Physical__c) {
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            } else if (acc.Games_Digital__c || acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_FR_DIGITAL_COUNTRY_CODE;
            }
        }
        update lstAccounts;
        System.assertEquals(5, lstAccounts.size());
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProGrp.size());
        List<Product2> lstProduct = CRM_AutoPhysicalNRDealCreateService_Test.createProductsForNRBatch(lstProGrp, lstAccounts);

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = [SELECT Id,Name FROM Country__c];
        lstCountry[0].Name = 'France';
        update lstCountry;
        List<Title__c> lstTitles = [Select Id FROM Title__c];
        System.assertEquals(1, lstTitles.size());
        List<Local_Title__c> lstDeleteLocalTitle = [SELECT Id FROM Local_Title__c];
        delete lstDeleteLocalTitle;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        
        System.assertEquals(5, lstProduct.size());
        for (Product2 prod : lstProduct) {  
            if (prod.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
                prod.Street_Date__c = System.today() + 32;
            }
            prod.Local_Title__c = lstLocaTitle[0].Id;
            prod.NR_Product_Created__c = false;
        }
        update lstProduct;
        System.assertEquals(5, lstProduct.size());

        List<Target_Split_Template__c> lstTargetSplitTemplate = CRM_TestDataFactory.createTargetSplitTemplate(lstProduct.size(), true);
        System.assertEquals(5, lstTargetSplitTemplate.size());

        List<Account_Split__c> lstAccountSplit = CRM_TestDataFactory.createAccountSplit(new List<Account>{lstAccounts[0],lstAccounts[1]} , lstTargetSplitTemplate, 2, true);
        System.assertEquals(10, lstAccountSplit.size());
        
        List<Country_Plan__c> lstCountryPlans = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, false);
        System.assertEquals(5, lstCountryPlans.size());

        for(Integer i=0; i < lstCountryPlans.size(); i++){
            lstCountryPlans[i].Target_Split_Template__c = lstTargetSplitTemplate[i].Id;
            lstCountryPlans[i].Target_Quantity__c =10.09;
        }
        insert lstCountryPlans;
        System.assertEquals(5, lstCountryPlans.size());

        // Verify Account Plans created with proper share% 
        Map<Id, Account_Plan__c> mapAccountPlan = new Map<Id, Account_Plan__c>([SELECT Id, Share__c FROM Account_Plan__c]);
        System.assertEquals(10, mapAccountPlan.size());
        for (Account_Plan__c accPlan : mapAccountPlan.values()) {
            System.assertEquals(10, accPlan.Share__c);
        }

        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR';
        defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
        defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;

        //Create GL Calender 
        List<GL_Calendar__c> glcListFRNR = new List<GL_Calendar__c>();
        GL_Calendar__c glcFRNR = new GL_Calendar__c();
        glcFRNR.Start_Date__c = System.today();
        glcFRNR.End_Date__c = System.today()+100;
        glcFRNR.Name = 'FR-NR';
        glcListFRNR.add(glcFRNR);
        insert glcListFRNR;
        Test.startTest();
        // Create Targets 
        List<String> countryPlanIds = new List<String>{lstCountryPlans[0].Id, lstCountryPlans[1].Id, lstCountryPlans[2].Id,lstCountryPlans[3].Id,lstCountryPlans[4].Id};
        system.debug('countryPlanIds --::'+countryPlanIds);
        List<Country_Plan__c> countryPlanList = new List<Country_Plan__c>();
    
        countryPlanList = [Select Id, Name, RecordType.DeveloperName,RecordTypeId,NR_Product__c,Product_Group1__c,NR_Product__r.Title_Country__c,Last_Auto_Allocated_Date__c,
        (Select Id,Name,End_Date__c,Start_Date__c,GL_Calendar__c,Stretch_Target__c,Target__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c From Country_Plan_Targets__r ORDER BY Start_Date__c),
        (Select Id,Name, RecordTypeId, CurrencyISOCode, Share__c,Total_Target__c,Target_Quantity__c,Product_Group__c,Customer__c,Returns_Share__c,Billing_Adjustment_Share__c From Account_Plans__r)// Where Country_Plan__c=:countryPlanId
        From Country_Plan__c Where Id IN : countryPlanIds ];
        
        List<Target__c> lstTargetsToUpsert = CRM_GenerateAccountPlanTargetsCtrl.generateAccountTargetList(countryPlanList);
        upsert lstTargetsToUpsert;
        
        //CRM_GenerateAccountPlanTargetsCtrl.createTarget(new List<String>{lstCountryPlans[0].Id, lstCountryPlans[1].Id, lstCountryPlans[2].Id,lstCountryPlans[3].Id,lstCountryPlans[4].Id});

        List<Target__c> lstTargets = [SELECT Id FROM Target__c];
        System.assertEquals(10, lstTargets.size());

        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(new List<Account> {lstAccounts[0], lstAccounts[1]}, 1, true);
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
        List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 5, true);
        lstDealProducts = [SELECT Id, Opportunity.AccountId, Product2Id FROM OpportunityLineItem];
        for (OpportunityLineItem oppLineItem : lstDealProducts) {
            oppLineItem.NR_Deal_Product_Unique_Key__c = oppLineItem.Opportunity.AccountId + '-' + oppLineItem.Product2Id;
        }
        update lstDealProducts;
        System.assertEquals(10, lstDealProducts.size());

        // Make the deal as Committed
        System.runas(testUser) {
            List<Opportunity> oppList = [SELECT Id,StageName FROM Opportunity];
            for (Opportunity opp: oppList) {
                opp.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update oppList;
        }
        Map<Id, OpportunityLineItem> mapExistingDealProducts = new Map<Id, OpportunityLineItem> (lstDealProducts);

        // Remove Template
        for(Integer i=0; i < lstCountryPlans.size(); i++){
            lstCountryPlans[i].Target_Split_Template__c = null;
            lstCountryPlans[i].Approve_Deletion_of_ALL_Account_Plan__c = true;
        }
        System.debug('-lstCountryPlans--->'+lstCountryPlans);
        update lstCountryPlans;
        
        // Update Account Splits
        List<Account_Split__c> splitToDelete = [SELECT Id FROM Account_Split__c WHERE Account__c =: lstAccounts[1].Id];
        delete splitToDelete;
        
        List<Account_Split__c> lstNewAccountSplit = CRM_TestDataFactory.createAccountSplit(new List<Account>{lstAccounts[2]} , lstTargetSplitTemplate, 1, true);
        System.assertEquals(5, lstNewAccountSplit.size());

        List<Account_Split__c> totalSplits = [SELECT Id, Account__c, Share__c FROM Account_Split__c];
        for (Account_Split__c accSplit : totalSplits) {
            if (accSplit.Account__c == lstAccounts[0].Id) {
                accSplit.Share__c = 20;
            }
        }
        update totalSplits;
        System.assertEquals(10, totalSplits.size());

        for(Integer i=0; i < lstCountryPlans.size(); i++){
            lstCountryPlans[i].Target_Split_Template__c = lstTargetSplitTemplate[i].Id;
        }
        update lstCountryPlans;
        
        // Verify Targets are deleted for one Account
        List<Target__c> lstTarget = [SELECT Id, Account__c FROM Target__c];
        Integer targetCountAcc0 = 0;
        Integer targetCountAcc1 = 0;
        for (Target__c target : lstTarget) {
            if (target.Account__c == lstAccounts[1].Id) {
                targetCountAcc1++;
            } else {
                targetCountAcc0++;
            }
        }
        System.assertEquals(5, targetCountAcc0);
        System.assertEquals(0, targetCountAcc1);

        // Verify Account Plans for lstAccounts[1] are deleted 
        List<Account_Plan__c> lstAccPlanDeleted = [Select Id FROM Account_Plan__c WHERE Customer__c =: lstAccounts[1].Id];
        System.assertEquals(0, lstAccPlanDeleted.size());
        
        // Verify Existing Account Plans lstAccounts[0] are not deleted and for lstAccounts[2] it is newly created 
        List<Account_Plan__c> lstNewAccPlans = [Select Id, Share__c, Customer__c FROM Account_Plan__c];
        Integer countAccountPlans = 0;
        for (Account_Plan__c accPlan : lstNewAccPlans) {
            if (accPlan.Customer__c == lstAccounts[0].Id) {
                countAccountPlans++;
                System.assert(mapAccountPlan.containsKey(accPlan.Id));
                // Verify Share% updated properly
                System.assertEquals(20, accPlan.Share__c);
            } else if (accPlan.Customer__c == lstAccounts[2].Id) {
                countAccountPlans++;
                System.assert(!mapAccountPlan.containsKey(accPlan.Id));
                System.assertEquals(10, accPlan.Share__c);
            }
        }
        System.assertEquals(10, countAccountPlans);

        // Verify deal products for lstAccounts[1] are deleted 
        List<OpportunityLineItem> lstDealProductsDeleted = [Select Id FROM OpportunityLineItem WHERE Opportunity.AccountId =: lstAccounts[1].Id];
        //System.assertEquals(0, lstDealProductsDeleted.size());
        
        // Verify Existing deal products for lstAccounts[0] are not deleted and for lstAccounts[2] it is not created 
        List<OpportunityLineItem> lstLineItems = [Select Id, Opportunity.AccountId FROM OpportunityLineItem];
        Integer countDealProducts = 0;
        for (OpportunityLineItem dealProduct : lstLineItems) {
            if (dealProduct.Opportunity.AccountId == lstAccounts[0].Id) {
                countDealProducts++;
                System.assert(mapExistingDealProducts.containsKey(dealProduct.Id));
            } else if (dealProduct.Opportunity.AccountId == lstAccounts[2].Id) {
                countDealProducts++;
                System.assert(!mapExistingDealProducts.containsKey(dealProduct.Id));
            }
        }
        System.assertEquals(5, countDealProducts);
        Test.stopTest();
    }
    
    //US : 801 : Account Split Change
    static void CreateDataForAutomaticallySplitToShipToTest() {
    	List<Account> lstSoldToAccounts = CRM_TestDataFactory.createAccounts(3,true);
        List<Account> lstAllAccounts = new List<Account>();
        for (Account soldToAcc : lstSoldToAccounts) {
            soldToAcc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            soldToAcc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            
            integer i = 0;
            List<Account> lstShipToAccounts = CRM_TestDataFactory.createAccounts(5,true);
	        for (Account shipToAcc : lstShipToAccounts) {
	            i++;
	            if (shipToAcc.Games_Physical__c) {
	                shipToAcc.Games_Physical__c = false;
	            }
	            shipToAcc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
	            shipToAcc.Sold_To_Customer__c = soldToAcc.Id;
	            if(i < 4){
	            	shipToAcc.Account_Split_Share__c = 20;
	            }
	            shipToAcc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
	        }
	        lstAllAccounts.addAll(lstShipToAccounts);
	    }
	    lstAllAccounts.addAll(lstSoldToAccounts);
        update lstAllAccounts;
        System.assertEquals(3, lstSoldToAccounts.size());
        System.assertEquals(18, lstAllAccounts.size());
        
        List<Target_Split_Template__c> lstTargetSplitTemplate = CRM_TestDataFactory.createTargetSplitTemplate(2,false);
        lstTargetSplitTemplate[0].Automatically_Split_to_Ship_To__c = true;
        insert lstTargetSplitTemplate;
        
        List<Account_Split__c> lstAccountSplits = CRM_TestDataFactory.createAccountSplit(lstSoldToAccounts,new List<Target_Split_Template__c>{lstTargetSplitTemplate[0]},lstSoldToAccounts.size(),true);
        lstAccountSplits = CRM_TestDataFactory.createAccountSplit(new List<Account>{lstSoldToAccounts[0]},new List<Target_Split_Template__c>{lstTargetSplitTemplate[1]},1,true);
        
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProGrp.size());

        List<Product2> lstProduct = CRM_AutoPhysicalNRDealCreateService_Test.createProductsForNRBatch(lstProGrp, lstSoldToAccounts);
        System.assertEquals(3, lstProduct.size());
        for (Product2 prod : lstProduct) {
            if (prod.RecordtypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL) {
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
                prod.Street_Date__c = System.today() + 32;
            }
            prod.NR_Product_Created__c = false;
        }
        update lstProduct;
        System.assertEquals(3, lstProduct.size());
	}
	
	//US : 801 : Account Split Change
	static testmethod void automaticallySplitToshipTo_Test(){
		CreateDataForAutomaticallySplitToShipToTest();
		List<Product2> lstProduct = [Select Id From Product2 Limit 1];
		List<Target_Split_Template__c> lstTSTs = [Select Id From Target_Split_Template__c Where Automatically_Split_to_Ship_To__c = true];
		
		Test.startTest();
		
		List<Country_Plan__c> lstCountryPlans = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, false);
        if(!lstTSTs.isEmpty())
        	lstCountryPlans[0].Target_Split_Template__c = lstTSTs[0].Id;
        	
        insert lstCountryPlans;
        System.assertEquals(1, lstCountryPlans.size());
        
        List<Account> lstShipToAccWithSharePerc = [Select Id From Account Where Account_Split_Share__c != null];
        System.assertEquals(9, lstShipToAccWithSharePerc.size(),'All ShipTos which have Account_Split_Share__c not equal to null');
        
        List<Account_Plan__c> latAPs = [Select Id,Share__c,Customer__r.RecordTypeId From Account_Plan__c Where Country_Plan__c = :lstCountryPlans[0].Id];
        System.assertEquals(12, latAPs.size(),'Total num of Account Plan created under the county plan (9 (For Ship To) + 3 (For Parent Sold To) = 12 )');
        for(Account_Plan__c ap : latAPs){
        	if(ap.Customer__r.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO){
        		System.assertEquals(2,ap.Share__c);
        	}else{
        		System.assertEquals(10,ap.Share__c);
        	}
        }
        
        lstTSTs = [Select Id,Automatically_Split_to_Ship_To__c From Target_Split_Template__c Where Automatically_Split_to_Ship_To__c = false];
        lstTSTs[0].Automatically_Split_to_Ship_To__c = true;
        update lstTSTs;
        
        lstCountryPlans[0].Target_Split_Template__c = lstTSTs[0].Id;
        lstCountryPlans[0].Approve_Deletion_of_All_Account_Plan__c = true;
        update lstCountryPlans;
        
        latAPs = [Select Id,Share__c,Customer__r.RecordTypeId From Account_Plan__c Where Country_Plan__c = :lstCountryPlans[0].Id];
        System.assertEquals(4, latAPs.size(),'Total num of Account Plan after updating TST on Country Plan (3 (For Ship To) + 1 (For Parent Sold To) = 12 )');
        for(Account_Plan__c ap : latAPs){
        	if(ap.Customer__r.RecordTypeId == CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO){
        		System.assertEquals(2,ap.Share__c);
        	}else{
        		System.assertEquals(10,ap.Share__c);
        	}
        }
        
        Test.stopTest();
	}
	
	//US : 801 : Account Split Change
	static testmethod void restrictToAddASOrUpdateTSTForAutoSplitToShipTo_Test(){
		List<Account> lstSoldToAccounts = CRM_TestDataFactory.createAccounts(3,true);
        List<Account> lstAllAccounts = new List<Account>();
        for (Account soldToAcc : lstSoldToAccounts) {
            soldToAcc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            soldToAcc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            
            integer i = 0;
            List<Account> lstShipToAccounts = CRM_TestDataFactory.createAccounts(5,true);
	        for (Account shipToAcc : lstShipToAccounts) {
	            i++;
	            if (shipToAcc.Games_Physical__c) {
	                shipToAcc.Games_Physical__c = false;
	            }
	            shipToAcc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
	            shipToAcc.Sold_To_Customer__c = soldToAcc.Id;
	            if(i < 4){
	            	shipToAcc.Account_Split_Share__c = 20;
	            }
	            shipToAcc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
	        }
	        lstAllAccounts.addAll(lstShipToAccounts);
	    }
	    lstAllAccounts.addAll(lstSoldToAccounts);
        update lstAllAccounts;
        System.assertEquals(3, lstSoldToAccounts.size());
        System.assertEquals(18, lstAllAccounts.size());
        
        List<Target_Split_Template__c> lstTargetSplitTemplate = CRM_TestDataFactory.createTargetSplitTemplate(2,false);
        lstTargetSplitTemplate[0].Automatically_Split_to_Ship_To__c = true;
        insert lstTargetSplitTemplate;
        
        List<Account> shiptToAccs = [Select Id From Account Where Account_Split_Share__c != null limit 1];
        List<Account_Split__c> lstAccountSplits = CRM_TestDataFactory.createAccountSplit(shiptToAccs,new List<Target_Split_Template__c>{lstTargetSplitTemplate[0]},shiptToAccs.size(),false);
        
        Test.startTest();
        try{
        	insert lstAccountSplits;
        }catch(System.DMLException de){}
        System.assertEquals(0,[Select Count() From Account_Split__c],'Account Splits are not created');
        
        lstTargetSplitTemplate[0].Automatically_Split_to_Ship_To__c = false;
        update lstTargetSplitTemplate;
        
        lstAccountSplits = CRM_TestDataFactory.createAccountSplit(shiptToAccs,new List<Target_Split_Template__c>{lstTargetSplitTemplate[0]},shiptToAccs.size(),true);
        System.assertEquals(1,[Select Count() From Account_Split__c]);
        
        try{
        	lstTargetSplitTemplate[0].Automatically_Split_to_Ship_To__c = true;
        	update lstTargetSplitTemplate;
        }catch(System.DMLException de){
        	System.assertEquals(System.Label.CRM_Account_Split_Template_Update_Error_Msg,de.getDmlMessage(0));
        }
        
        Test.stopTest();
    }
    
    static testMethod void testDeleteOldRecords_NegativeTest() {
    	List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
    	for (Account acc : lstAccounts) {  
            acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        }
        insert lstAccounts;
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
        }
        insert lstDeals;
        
        List<Product_Group__c> lstProductGroup2 = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup2, 10, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prodInstance.Product_Market__c = CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE;
        }
        insert lstProduct;
        
        List<Country_Plan__c> lstCountryPlan = new List<Country_Plan__c>();
        Country_Plan__c objCP = CRM_TestDataFactory.createCountryPlanNewReleaseInstance(lstProduct);
        objCP.Name = 'Test_Delete_Negative';
        objCP.NR_Product__c = lstProduct[1].Id;
        lstCountryPlan.add(objCP);
        insert lstCountryPlan;
        
        List<Account_Plan__c> lstAccPlan = CRM_TestDataFactory.createAccountPlan(1, lstCountryPlan[0], lstAccounts[0]);
        lstAccPlan[0].Country_Plan__c = lstCountryPlan[0].Id;
        update lstAccPlan;
        lstAccPlan = [SELECT Id, Customer__c, Country_Plan__r.NR_Product__c FROM Account_Plan__c WHERE Id IN : lstAccPlan LIMIT 1];
        
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);   
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);
        lstDealProduct[0].NR_Deal_Product_Unique_Key__c = lstAccounts[0].Id +'-'+ lstProduct[1].Id;
        insert lstDealProduct;
        
        lstDealProduct[0].Is_Canceled__c  = true;
        update lstDealProduct[0];
        CRM_CreateNewAccountPlan.newAccountPlanList = new List<Account_Plan__c>{
        	new Account_Plan__c(
        		Country_Plan__c = lstCountryPlan[0].Id,
	        	Returns_Share__c = 15
	        ) 
        };
        CRM_CreateNewAccountPlan.deleteOldRecords(lstCountryPlan, new Map<String, Account_Plan__c>(lstAccPlan));
    }
}