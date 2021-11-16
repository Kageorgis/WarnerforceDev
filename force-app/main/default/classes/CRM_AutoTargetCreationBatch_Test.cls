@isTest
Public class CRM_AutoTargetCreationBatch_Test {
    
    
    static Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    static Id rtAccShipTo =  CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO;
    static Id rtTarget = CRM_RecordTypeUtil.RT_TARGET_PRODUCT;
    static Id digitalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
    static Id physicalDealRecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
    static Id digitalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
    static Id physicalProductRecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;

    private static testMethod void testUKTargets() {
        
        createData();
        
        Test.startTest();
        CRM_AutoTargetCreationProductInsertBatch automaticCPCreationBatch = new CRM_AutoTargetCreationProductInsertBatch();
        Database.executeBatch(automaticCPCreationBatch,10);
        Test.stopTest();
        
        Integer cpCounter = [Select count() FROM Country_Plan__c]; 
        System.assertEquals(5,cpCounter);
        Integer cptCounter = [Select count() FROM Country_Plan_Target__c]; 
        System.assertEquals(15,cptCounter);
        Integer apCounter = [Select count() FROM Account_Plan__c]; 
        System.assertEquals(10,apCounter);
        Integer targetCounter = [Select count() FROM Target__c]; 
        System.assertEquals(30,targetCounter);
        
    }
    
     private static testMethod void testUpdateUKTargets() {
        
        CRM_AutoTargetCreationHelper_TestWrapper tw = new CRM_AutoTargetCreationHelper_TestWrapper();
        tw = createData();
        List<Product2> lstProduct = tw.lstProduct;
        List<Account> lstAccounts = tw.lstAccounts;
        List<GL_Calendar__c> glcList = tw.glcList;
        Id CountryPlanId;
        List<Country_Plan_Target__c> countryPlanTargetList = new List<Country_Plan_Target__c>();
        List<Account_Plan__c> accountPlanList = new  List<Account_Plan__c>();
        
        
        for(Product2 prod : lstProduct){
            if(prod.Type__c == 'Video Physical'){
                Country_Plan__c countryPlan = new Country_Plan__c();
                countryPlan.Name = 'Test 1';
                countryPlan.Year__c = string.valueof(system.today().year());
                countryPlan.NR_Product__c = prod.Id;
                countryPlan.External_Id__c = 'USA_en_6000054423_EST_SD2';//prod.External_Id__c;//productInstance.Local_Title__r.Country__r.Country_Code2__c +'-' + productInstance.External_Id__c;
                countryPlan.RecordTypeId = CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE;
                countryPlan.CurrencyIsoCode = 'USD';
                countryPlan.Country__c = 'United Kingdom';
                insert countryPlan;
                CountryPlanId = countryPlan.Id;
                
                for(GL_Calendar__c glc : glcList){
                    if(glc.Name != 'FR-NR'){
                        Country_Plan_Target__c countryPlanTargetInstance = new Country_Plan_Target__c();
                        CountryPlanTargetInstance.Target__c = 10;
                        countryPlanTargetInstance.Country_Plan__c = countryPlan.Id;
                        countryPlanTargetInstance.CurrencyIsoCode = countryPlan.CurrencyIsoCode;
                        countryPlanTargetInstance.GL_Calendar__c = glc.Id;
                        //countryPlanTargetInstance.External_Id__c = countryPlan.External_Id__c +'-' + glc.month__c; 
                        countryPlanTargetList.add(countryPlanTargetInstance);                        
                    }
                }
                for(Account acc : lstAccounts){
                    if(acc.External_Id__c == 'Temp0' ||acc.External_Id__c == 'Temp2' ){
                        Account_Plan__c accountPlanInstance = new Account_Plan__c();
                        accountPlanInstance.Share__c = 10;
                        accountPlanInstance.Country_Plan__c = countryPlan.Id;
                        accountPlanInstance.CurrencyIsoCode = countryPlan.CurrencyIsoCode;
                        accountPlanInstance.Customer__c = acc.Id;
                        accountPlanInstance.External_Id__c = countryPlan.External_Id__c +'-' + acc.External_Id__c;
                        accountPlanList.add(accountPlanInstance);
                    }
                }
                
            }
            
        }
        
        Database.SaveResult[] result = Database.Insert(countryPlanTargetList, false);
        Database.SaveResult[] result1 = Database.Insert(accountPlanList, false);
        
        
        
        Test.startTest();
        CRM_AutoTargetCreationProductInsertBatch automaticCPCreationBatch = new CRM_AutoTargetCreationProductInsertBatch();
        Database.executeBatch(automaticCPCreationBatch,10);
        Test.stopTest();
        
        /*List<Country_Plan__c> lstCountryPlan = [Select Name ,Year__c,NR_Product__c ,External_Id__c ,RecordTypeId ,CurrencyIsoCode, Country__c FROM Country_Plan__c];
        List<Country_Plan_Target__c> lstCountryPlanTarget = [Select Id,Target__c,Country_Plan__c,CurrencyIsoCode ,GL_Calendar__c,External_Id__c FROM Country_Plan_Target__c];
        List<Account_Plan__c> lstAccountPlan = [Select Id,Share__c,Country_Plan__c ,CurrencyIsoCode,Customer__c,External_Id__c FROM Account_Plan__c];
        
        system.debug('lstCountryPlan' + lstCountryPlan);
        system.debug('lstCountryPlanTarget' + lstCountryPlanTarget);
        system.debug('lstAccountPlan' + lstAccountPlan);
        system.debug('lstProduct' + lstProduct);
        system.debug('lstAccounts' + lstAccounts);
        system.debug('glcList' + glcList);*/
        
        List<Country_Plan__c> lstCountryPlan = [Select Name ,Year__c,NR_Product__c ,External_Id__c ,RecordTypeId ,CurrencyIsoCode, Country__c FROM Country_Plan__c where Id =:CountryPlanId ];
        List<Country_Plan_Target__c> lstCountryPlanTarget = [Select Id,Target__c,Country_Plan__c,CurrencyIsoCode ,GL_Calendar__c,External_Id__c FROM Country_Plan_Target__c where Country_Plan__c =: CountryPlanId];
        List<Account_Plan__c> lstAccountPlan = [Select Id,Share__c,Country_Plan__c ,CurrencyIsoCode,Customer__c,External_Id__c FROM Account_Plan__c where Country_Plan__c =:  CountryPlanId];
        
        
         System.assertEquals(10,lstCountryPlanTarget[0].Target__c);
         System.assertEquals(10,lstCountryPlanTarget[1].Target__c);
         System.assertEquals(10,lstCountryPlanTarget[2].Target__c);
         System.assertEquals(10,lstAccountPlan[0].Share__c);
         System.assertEquals(10,lstAccountPlan[1].Share__c);

        
        Integer cpCounter = [Select count() FROM Country_Plan__c]; 
        System.assertEquals(5,cpCounter);
        Integer cptCounter = [Select count() FROM Country_Plan_Target__c]; 
        System.assertEquals(15,cptCounter);
        Integer apCounter = [Select count() FROM Account_Plan__c]; 
        System.assertEquals(10,apCounter);
        Integer targetCounter = [Select count() FROM Target__c]; 
        System.assertEquals(24,targetCounter); 
        
    }
    
     private static testMethod void testUKTargetsForBackDate() {
        
        createDataForBackDate();
        
        Test.startTest();
        CRM_AutoTargetCreationProductInsertBatch automaticCPCreationBatch = new CRM_AutoTargetCreationProductInsertBatch();
        Database.executeBatch(automaticCPCreationBatch,10);
        Test.stopTest();
        
        Integer cpCounter = [Select count() FROM Country_Plan__c]; 
        System.assertEquals(1,cpCounter);
        Integer cptCounter = [Select count() FROM Country_Plan_Target__c]; 
        System.assertEquals(1,cptCounter);
        Integer apCounter = [Select count() FROM Account_Plan__c]; 
        System.assertEquals(1,apCounter);
        List<Account_Plan__c> lstAccPlan =[Select Share__c FROM Account_Plan__c]; 
      //  System.assertEquals(null,lstAccPlan[0].Share__c); 
        Integer targetCounter = [Select count() FROM Target__c]; 
        System.assertEquals(1,targetCounter);
        
    }
    
    public static CRM_AutoTargetCreationHelper_TestWrapper createDataForBackDate()
    {   
        insertRegionCustomSetting();
        List<GL_Calendar__c> glcList = genarteGLCalanderBckDate();
        System.debug('glcList::'+glcList.size());
        
        List<Account> lstAccounts = createAccountBackDate(1);
        System.debug('lstAccounts::'+lstAccounts.size());
        
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        
        List<Product2> lstProduct = createProductsBackDate(lstProGrp,lstAccounts);
        System.debug('lstProduct::'+lstProduct.size());
        
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForCPBatch(lstProduct);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry);

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = createPriceBookEntryPeriodForCPBatch(lstPriceBookEntry, lstProduct);
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);

        CRM_AutoTargetCreationHelper_TestWrapper tw = new CRM_AutoTargetCreationHelper_TestWrapper();
        tw.lstAccounts = lstAccounts;
        tw.lstProduct = lstProduct;
        tw.lstPriceBookEntry = lstPriceBookEntry;
        tw.lstPriceBookEntryPeriod = lstPriceBookEntryPeriod;
        tw.glcList = glcList;
        
        return tw;
    }
    
     private static List<Product2> createProductsBackDate(List<Product_Group__c> lstProGrp, List<Account> lstAccounts){
        //5 accounts 1 product group
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'GB'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(2, false);
        System.assertEquals(2, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        lstTitles[1].Content_Type__c = 'Feature';
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstLocaTitle.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;
        
        List<Local_Title__c> lstLocaTitle1 = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstLocaTitle1.size());
        lstLocaTitle1[0].Title__c = lstTitles[1].Id;
        insert lstLocaTitle1;

        for(Integer i=0; i<lstProduct.size(); i++){
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            lstProduct[i].Street_Date__c = system.today()-5;
            lstProduct[i].NR_Product_Created__c = true;
            lstProduct[i].Street_Date_Has_Changed__c = false;
            lstProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
            lstProduct[i].CurrencyIsoCode = 'USD';
            lstProduct[i].External_Id__c = 'USA_en_6000054423_EST_SD'+string.valueOf(i);
            if (i == 0) {
                lstProduct[i].Type__c = 'Games Physical';
                lstProduct[i].RecordTypeId = physicalProductRecordTypeId;
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            }else if (i == 1) {
                lstProduct[i].Type__c = 'Video Digital EST';
                lstProduct[i].Local_Title__c = lstLocaTitle1[0].Id;
                lstProduct[i].RecordTypeId = digitalProductRecordTypeId;
                lstProduct[i].SAP_Material_Type__c = null;
            }   
        }
        insert lstProduct;
        System.debug('lstProduct::'+lstProduct);
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId,
         SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c,
         Pending_Country_Plan_Creation__c , NR_Product_Created__c FROM Product2 ORDER BY CreatedDate];
        System.assertEquals(false, lstProduct[0].Pending_Country_Plan_Creation__c); 
        System.assertEquals(true, lstProduct[1].Pending_Country_Plan_Creation__c); 
         System.debug('lstProduct[1].::'+lstProduct[1].Type__c);
        return lstProduct;
    }
   private static testMethod void testUKTargetsWithDiffPriceBook() {
        
        createData();
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
        List<Pricebook_Entry_Period__c> pbepList = [Select Id,Price_Book__c from Pricebook_Entry_Period__c WHERE Product__r.Type__c = 'Games Digital' or Product__r.Type__c = 'Video Digital'];
        for(Pricebook_Entry_Period__c pbep : pbepList){
            pbep.Price_Book__c = pb.Id;
        }
        update pbepList;
        
        List<Account> accList = [Select Id,Price_Book__c from Account WHERE Games_Digital__c = true or Video_Digital__c = true];
        for(Account acc : accList){
            acc.Price_Book__c = pb.Id;
        }
        update accList;
        
        Test.startTest();
        CRM_AutoTargetCreationProductInsertBatch automaticCPCreationBatch = new CRM_AutoTargetCreationProductInsertBatch();
        Database.executeBatch(automaticCPCreationBatch,10);
        Test.stopTest();
        
        Integer cpCounter = [Select count() FROM Country_Plan__c]; 
        System.assertEquals(5,cpCounter);
        Integer cptCounter = [Select count() FROM Country_Plan_Target__c]; 
        System.assertEquals(15,cptCounter);
        Integer apCounter = [Select count() FROM Account_Plan__c]; 
        System.assertEquals(10,apCounter);
        Integer targetCounter = [Select count() FROM Target__c]; 
        System.assertEquals(30,targetCounter);
        
    }
    
    
    private static testMethod void testFRTargets() {
        
        createData();
        List<Country__C> cntryList = [Select Id,Country_Code2__c,Name from Country__c WHERE Country_Code2__c = 'GB'];
        if(cntryList != null){
            cntryList[0].Country_Code2__c = 'FR';
            cntryList[0].Name = 'France';
            update cntryList;
        }
        
        Test.startTest();
        CRM_AutoTargetCreationProductInsertBatch automaticCPCreationBatch = new CRM_AutoTargetCreationProductInsertBatch();
        Database.executeBatch(automaticCPCreationBatch,10);
        Test.stopTest();
        
        Integer cpCounter = [Select count() FROM Country_Plan__c]; 
        System.assertEquals(5,cpCounter);
        Integer cptCounter = [Select count() FROM Country_Plan_Target__c]; 
        System.assertEquals(0,cptCounter);
        Integer apCounter = [Select count() FROM Account_Plan__c]; 
        System.assertEquals(10,apCounter);
        Integer targetCounter = [Select count() FROM Target__c]; 
        System.assertEquals(0,targetCounter);
        
    }
    
    public static void insertRegionCustomSetting(){
        
        // Setting custom setting Value
        Auto_Target_Creation__c settingAP = new Auto_Target_Creation__c();            
        settingAP.Name = 'Account Plan'; //Default instead of Default1234
        settingAP.Region__c = 'IE,GB,FR';
        insert settingAP;
        
        Auto_Target_Creation__c settingCP = new Auto_Target_Creation__c();            
        settingCP.Name = 'Country Plan'; //Default instead of Default1234
        settingCP.Region__c = 'IE,GB,FR';
        insert settingCP;
        
        Auto_Target_Creation__c settingAPT = new Auto_Target_Creation__c();            
        settingAPT.Name = 'Country Plan Target'; //Default instead of Default1234
        settingAPT.Region__c = 'IE,GB';
        insert settingAPT;
        
        
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
        insert defaultConfiguration;
    }
    public static CRM_AutoTargetCreationHelper_TestWrapper createData()
    {   
        insertRegionCustomSetting();
        List<GL_Calendar__c> glcList = genarteGLCalander();
        System.debug('glcList::'+glcList.size());
        
        List<Account> lstAccounts = createAccountsForCPBatch(5);
        System.debug('lstAccounts::'+lstAccounts.size());
        
        List<Product_Group__c> lstProGrp = CRM_TestDataFactory.createProductGroups(1,true);
        
        List<Product2> lstProduct = createProductsForCPBatch(lstProGrp,lstAccounts);
        System.debug('lstProduct::'+lstProduct.size());
        
        List<PricebookEntry> lstPriceBookEntry = createPriceBookEntryForCPBatch(lstProduct);
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry);

        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = createPriceBookEntryPeriodForCPBatch(lstPriceBookEntry, lstProduct);
        System.debug('lstPriceBookEntryPeriod::'+lstPriceBookEntryPeriod);

        CRM_AutoTargetCreationHelper_TestWrapper tw = new CRM_AutoTargetCreationHelper_TestWrapper();
        tw.lstAccounts = lstAccounts;
        tw.lstProduct = lstProduct;
        tw.lstPriceBookEntry = lstPriceBookEntry;
        tw.lstPriceBookEntryPeriod = lstPriceBookEntryPeriod;
        tw.glcList = glcList;
        
        return tw;
    }
     private static List<GL_Calendar__c> genarteGLCalanderBckDate(){
        
        List<GL_Calendar__c> glcList = new List<GL_Calendar__c>();
        
        GL_Calendar__c glcBackDate = new GL_Calendar__c();
        glcBackDate.Start_Date__c = System.today()-10;
        glcBackDate.End_Date__c = System.today().addDays(63);
        glcBackDate.Name = '2017-01';
        glcBackDate.Month__c = String.ValueOf(System.today().addmonths(1).month());
        glcBackDate.Year__c = String.ValueOf(System.today().addmonths(1).year());
        glcList.add(glcBackDate); 
         Insert glcList;
        return glcList;
     }
    
    private static List<GL_Calendar__c> genarteGLCalander(){
        
        List<GL_Calendar__c> glcList = new List<GL_Calendar__c>();
        GL_Calendar__c glc = new GL_Calendar__c();
        glc.Start_Date__c = System.today();
        glc.End_Date__c = System.today().addDays(31);
        glc.Name = '2016-01';
        glc.Month__c = String.ValueOf(System.today().month());
        glc.Year__c = String.ValueOf(System.today().year());
        glcList.add(glc);
        
        GL_Calendar__c glc1 = new GL_Calendar__c();
        glc1.Start_Date__c = System.today().addDays(32);
        glc1.End_Date__c = System.today().addDays(63);
        glc1.Name = '2016-01';
        glc1.Month__c = String.ValueOf(System.today().addmonths(1).month());
        glc1.Year__c = String.ValueOf(System.today().addmonths(1).year());
        glcList.add(glc1);
        
        GL_Calendar__c glc2 = new GL_Calendar__c();
        glc2.Start_Date__c = System.today().addDays(64);
        glc2.End_Date__c = System.today().addDays(95);
        glc2.Name = '2016-01';
        glc2.Month__c = String.ValueOf(System.today().addmonths(2).month());
        glc2.Year__c = String.ValueOf(System.today().addmonths(2).year());
        glcList.add(glc2);
        
        
        List<GL_Calendar__c> glcListFRNR = new List<GL_Calendar__c>();
        GL_Calendar__c glcFRNR = new GL_Calendar__c();
        glcFRNR.Start_Date__c = System.today();
        glcFRNR.End_Date__c = System.today()+1;
        glcFRNR.Name = 'FR-NR';
        glcList.add(glcFRNR);
        
        Insert glcList;
        
        return glcList;
        
    }
     private static List<Account> createAccountBackDate(Integer numberOfAcounts){ 
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'USA'}, 1, true);

        // Create storefronts
        List<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'USD', countries[0].id, true);
        System.assertEquals(1, storefronts.size());
        mainAccountForStoreFront[0].name='TestDigi';
        mainAccountForStoreFront[0].RecordTypeId = rtAcc;
        mainAccountForStoreFront[0].Video_Digital__c = true; 
        mainAccountForStoreFront[0].Storefront__c=storefronts[0].id;
        mainAccountForStoreFront[0].External_Id__c = 'TempTestDigital' ;
        mainAccountForStoreFront[0].Pending_Account_Plan_Creation__c=true;
        update mainAccountForStoreFront;
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(numberOfAcounts,false);
        /*Setting Up the Account Data*/
        for (Integer i=0; i<lstAccounts.size(); i++) {
            lstAccounts[i].recordTypeId = rtAcc;
            lstAccounts[i].CurrencyIsoCode = 'USD'; 
            //games physical
            lstAccounts[i].Games_Physical__c = true;
            lstAccounts[i].Sales_Organization__c = '6000';
            lstAccounts[i].Owner_Games__c = UserInfo.getUserId();
            lstAccounts[i].Video_Physical__c = true;
            lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstAccounts[i].External_Id__c = 'Temp' + String.valueOf(i); 
        }
        
        insert lstAccounts;
        //2 accounts
        //lstAccounts.add(mainAccountForStoreFront[0]);
        lstAccounts =[select id,recordTypeId,CurrencyIsoCode,Games_Physical__c,Sales_Organization__c,Video_Physical__c,Video_Digital__c from Account];
        System.assertEquals(2, lstAccounts.size()); 
        System.debug('lstAccounts:'+lstAccounts);
        return lstAccounts;
    }
    private static List<Account> createAccountsForCPBatch(Integer numberOfAcounts){
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
            lstAccounts[i].Storefront__c = storefronts[0].Id;
            if (i == 0) {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Sales_Organization__c = '6000';
                lstAccounts[i].Owner_Games__c = UserInfo.getUserId();
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
                lstAccounts[i].External_Id__c = 'Temp' + String.valueOf(i);
            } else if (i == 1) {
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Owner_Games__c = UserInfo.getUserId();
                lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
                lstAccounts[i].External_Id__c = 'Temp' + String.valueOf(i);
            } else if (i == 2) {
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].Sales_Organization__c = '6000';
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
                lstAccounts[i].External_Id__c = 'Temp' + String.valueOf(i);
            } else if (i == 3) {
                lstAccounts[i].Video_Digital__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Games_Digital__c= true;
                lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_US_DIGITAL_COUNTRY_CODE;
                lstAccounts[i].External_Id__c = 'Temp' + String.valueOf(i);
            } else if (i == 4) {
                lstAccounts[i].Video_Digital__c = true;
                lstAccounts[i].Video_Physical__c = false;
                lstAccounts[i].Games_Physical__c = false;
                lstAccounts[i].Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_IRE_DIGITAL_COUNTRY_CODE;
                lstAccounts[i].External_Id__c = 'Temp' + String.valueOf(i);
            } else {
                lstAccounts[i].Games_Physical__c = true;
                lstAccounts[i].Video_Physical__c = true;
                lstAccounts[i].External_Id__c = 'Temp' + String.valueOf(i);
            }
        }
        insert lstAccounts;
        System.assertEquals(numberOfAcounts, lstAccounts.size());

        System.debug('lstAccounts.size()::'+lstAccounts.size());
        System.debug('lstAccounts:'+lstAccounts);
        return lstAccounts;
    }

    private static List<Product2> createProductsForCPBatch(List<Product_Group__c> lstProGrp, List<Account> lstAccounts){
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProGrp ,lstAccounts.size(),false);
        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'GB'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(2, false);
        System.assertEquals(2, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        lstTitles[1].Content_Type__c = 'Feature';
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstLocaTitle.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;
        
        List<Local_Title__c> lstLocaTitle1 = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstLocaTitle1.size());
        lstLocaTitle1[0].Title__c = lstTitles[1].Id;
        insert lstLocaTitle1;

        for(Integer i=0; i<lstProduct.size(); i++){
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            lstProduct[i].Street_Date__c = system.today()+1;
            lstProduct[i].NR_Product_Created__c = true;
            lstProduct[i].Street_Date_Has_Changed__c = false;
            lstProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
            //lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
            lstProduct[i].CurrencyIsoCode = 'USD';
            lstProduct[i].Pending_Country_Plan_Creation__c = true;
            lstProduct[i].External_Id__c = 'USA_en_6000054423_EST_SD'+string.valueOf(i);
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
                lstProduct[i].Local_Title__c = lstLocaTitle1[0].Id;
                lstProduct[i].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            } else if (i == 3) {
                lstProduct[i].Type__c = 'Video Digital EST';
                lstProduct[i].Local_Title__c = lstLocaTitle1[0].Id;
                lstProduct[i].RecordTypeId = digitalProductRecordTypeId;
                lstProduct[i].SAP_Material_Type__c = null;
            } else if (i == 4) {
                lstProduct[i].Type__c = 'Video Digital VODi';
                lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
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
    
    private static List<PricebookEntry> createPriceBookEntryForCPBatch(List<Product2> lstProduct){
        /*Setting up PriceBookEntry Data*/
        List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
        for(Integer i=0 ;i<lstPriceBookEntry.size();i++){
            lstPriceBookEntry[i].Product2Id = lstProduct[i].id;
        }
        insert lstPriceBookEntry;
        System.debug('lstPriceBookEntry::'+lstPriceBookEntry.size());
        return lstPriceBookEntry;
    }

    private static List<Pricebook_Entry_Period__c> createPriceBookEntryPeriodForCPBatch(List<PricebookEntry> lstPriceBookEntry, List<Product2> lstProduct){
        /*Setting up PriceBookEntryPeriod Data*/
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        /*Setting up PriceBookEntryPeriod Data*/
        for(Integer i=0 ;i<lstPriceBookEntryPeriod.size();i++){
            lstPriceBookEntryPeriod[i].Product__c = lstProduct[i].id;
            lstPriceBookEntryPeriod[i].Start_Date__c = System.today() + 1;
            lstPriceBookEntryPeriod[i].End_Date__c = System.today() + 140;
            lstPriceBookEntryPeriod[i].CurrencyIsoCode = 'USD';
            System.debug('--lstPriceBookEntryPeriod[i].Product__r.RecordTypeId-->'+lstPriceBookEntryPeriod[i].Product__r.RecordTypeId);
            //if (lstPriceBookEntryPeriod[i].Product__r.RecordTypeId == digitalProductRecordTypeId) {
            lstPriceBookEntryPeriod[i].New_Release__c = true;
            //}
        }
        insert lstPriceBookEntryPeriod;
        return lstPriceBookEntryPeriod;
    }
    
    public class CRM_AutoTargetCreationHelper_TestWrapper {
        public List<Account> lstAccounts;
        public List<Product2> lstProduct;
        public List<PricebookEntry> lstPriceBookEntry;
        public List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod;
        public List<GL_Calendar__c> glcList;
    }
}