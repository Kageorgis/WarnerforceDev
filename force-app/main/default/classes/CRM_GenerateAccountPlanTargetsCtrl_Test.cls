/**
   @Author Cognizant
   @name CRM_GenerateAccountPlanTargetsCtrl_Test
   @CreateDate 16 Feb 2016
   @Description Test class for CRM_GenerateAccountPlanTargetsCtrl
   @Version <1.0>
   @reference Requirement no 164/165
  */

@isTest(SeeAllData=false)
private class CRM_GenerateAccountPlanTargetsCtrl_Test{
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    */
    
    @testSetup static void createTestData() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(10, false);   
        Id tempRecordType = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        lstAccounts[0].RecordTypeID = tempRecordType;
        lstAccounts[1].RecordTypeID = tempRecordType;
        upsert lstAccounts;
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 2, true); 
        
        List<GL_Calendar__c> glcList = new List<GL_Calendar__c>();
        GL_Calendar__c glc = new GL_Calendar__c();
        glc.Start_Date__c = System.today();
        glc.End_Date__c = System.today()+1;
        glc.Name = '2016-01';
        glc.month__c = string.valueOf(System.today().month());
        glcList.add(glc);
        Insert glcList;
        List<Country_Plan__c> lstCountryPLan = new List<Country_Plan__c>();      
        /*Creating country plan */
        Country_Plan__c countryPlan = CRM_TestDataFactory.createCountryPlanCatalogInstance(lstProductGroup);
        countryPlan.Name = 'CountryPlanCatalog';
        lstCountryPLan.add(countryPlan);
        //update countryPlan;
        
        Country_Plan__c countryPlan1 = CRM_TestDataFactory.createCountryPlanNewReleaseInstance(lstProduct);
        countryPlan1.Name = 'CountryPlanNewRelease';
        lstCountryPLan.add(countryPlan1);
        //update countryPlan1;
        
        Country_Plan__c countryPlan2 = CRM_TestDataFactory.createCountryPlanCatalogInstance(lstProductGroup);
        countryPlan2.Name = 'CountryPlanCatalog1';
        lstCountryPLan.add(countryPlan2);
        //update countryPlan2;
        
        insert lstCountryPLan;
        
        System.assertNotEquals(null,countryPlan.id);
        System.assertNotEquals(null,countryPlan1.id);
        System.assertNotEquals(null,countryPlan2.id);

        list<Country_Plan_Target__c> countryPlanTargetList = CRM_TestDataFactory.createCountryPlanTarget(countryPlan,glcList);
        list<Country_Plan_Target__c> countryPlanTarget1List = CRM_TestDataFactory.createCountryPlanTarget(countryPlan1,glcList);

        
        CRM_TestDataFactory.createAccountPlan(1,countryPlan,lstAccounts[0]);
        list<Account_Plan__c> lstaccountPlan = CRM_TestDataFactory.createAccountPlan(1,countryPlan1,lstAccounts[1]);
        Account_Plan__c accountPlan = lstaccountPlan[0];
        accountPlan.Share__c = 20; 
        update accountPlan;
        
        System.assertNotEquals(null,accountPlan.id);
    }
    
     /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    */
    
   @testSetup static void createTestData1() {
        List<Account> lstAccounts = [select Id,RecordTypeID from Account];
        Id tempRecordType = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        for(Account acc : lstAccounts){
        acc.RecordTypeID = tempRecordType;
        }
        //lstAccounts[0].RecordTypeID = tempRecordType;
        //lstAccounts[1].RecordTypeID = tempRecordType;
        upsert lstAccounts;     
        List<Product_Group__c> lstProductGroup = [select Id from Product_Group__c];
        List<Product2> lstProduct = [select Id,External_id__c  from Product2];
        for(Product2 prod : lstProduct ){
            prod.External_id__c  = '123456'+ math.random();
        }
        update lstProduct;

        List<GL_Calendar__c> glcList = new List<GL_Calendar__c>();
        integer i;
        for(i = 0 ;i < 10; i++){
        GL_Calendar__c glc = new GL_Calendar__c();
        glc.Start_Date__c = System.today()+i;
        glc.End_Date__c = System.today()+i+1;
        glc.Name = '2016-01';
        glc.month__c = string.valueOf(System.today().month() + i);
        glcList.add(glc);
        }
        Insert glcList;
        
        List<Country_Plan__c> lstCountryPLan = new List<Country_Plan__c>(); 
    /*Creating country plan */
        Country_Plan__c countryPlan = CRM_TestDataFactory.createCountryPlanCatalogInstance(lstProductGroup);
        countryPlan.Name = 'CountryPlanCatalogBulk';
        lstCountryPLan.add(countryPlan);
        
        Country_Plan__c countryPlan1 = CRM_TestDataFactory.createCountryPlanNewReleaseInstance(lstProduct);
        countryPlan1.Name = 'CountryPlanNewReleaseBulk';
        lstCountryPLan.add(countryPlan1);        
        
        insert lstCountryPLan;
        
        CRM_TestDataFactory.createCountryPlanTarget(countryPlan,glcList);
        CRM_TestDataFactory.createCountryPlanTarget(countryPlan1,glcList);
        
        list<Country_Plan__c> testCountryPlan = new list<Country_Plan__c>();
        testCountryPlan.add(countryPlan);
        list<Country_Plan__c> testCountryPlan1 = new list<Country_Plan__c>();
        testCountryPlan1.add(countryPlan1);
        CRM_TestDataFactory.createAccountPlan(testCountryPlan,lstAccounts,true);
        CRM_TestDataFactory.createAccountPlan(testCountryPlan1,lstAccounts,true);

    }
    //Req: #456 - Create Targets for every Account Plan
    @testSetup static void createTestDataToTestTargetsWithAccountPlan() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(10, True);   
        Id tempRecordType = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        lstAccounts[0].RecordTypeID = tempRecordType;
        lstAccounts[1].RecordTypeID = tempRecordType;
        upsert lstAccounts;
        
        Title__c title = new Title__c();
        title.Name = 'Test Title';
        title.CurrencyIsoCode = 'USD';
        title.Digital_Planning__c = 'TBD';
        insert title;
        
        Country__c country = new Country__c();
        country.Name = 'France';
        country.Country_Code2__c = '1';
        country.Country_Code__c = '2';
        country.CurrencyIsoCode = 'USD';
        insert country;
        
        Language__c lang = new Language__c();
        lang.name = 'Test Lang';
        lang.Language_Order__c = 1;
        insert lang;
        
        Local_Title__c localTitle = new Local_Title__c();
        localTitle.Name = 'Test Local Data';
        localTitle.Title__c = title.Id;
        localTitle.Country__c = country.Id;
        localTitle.Language__c = lang.Id;
        localTitle.CurrencyIsoCode = 'USD';
        insert localTitle;
        
        List<Product2> lstProduct2 = [select Id,External_id__c  from Product2];
        lstProduct2[0].Local_Title__c = localTitle.Id;
        lstProduct2[1].Local_Title__c = localTitle.Id;
        lstProduct2[0].External_id__c  = '1234567'+ math.random();
        update lstProduct2;
        
        //Create GL Calender 
        List<GL_Calendar__c> glcListFRNR = new List<GL_Calendar__c>();
        GL_Calendar__c glcFRNR = new GL_Calendar__c();
        glcFRNR.Start_Date__c = System.today();
        glcFRNR.End_Date__c = System.today()+1;
        glcFRNR.Name = 'FR-NR';
        glcListFRNR.add(glcFRNR);
        insert glcListFRNR;
            
        list<Country_Plan__c> testCountryPlan = new list<Country_Plan__c>();
            
        Country_Plan__c countryPlan1 = CRM_TestDataFactory.createCountryPlanNewReleaseInstance(lstProduct2);
        countryPlan1.Name = 'NewReleaseCountryPlan1';
        testCountryPlan.add(countryPlan1);
        //update countryPlan1;
        //System.assertNotEquals(null,countryPlan1.id);
        
        List<Product2> lstProductNew = new List<Product2>();
        lstProductNew.add(lstProduct2[1]);
        /*lstProduct2 = [select Id,External_id__c  from Product2];
        lstProduct2[0].External_id__c  = '1234568'+ math.random();
        update lstProduct2;*/
        
        Country_Plan__c countryPlan2 = CRM_TestDataFactory.createCountryPlanNewReleaseInstance(lstProductNew);
        countryPlan2.Name = 'NewReleaseCountryPlan2';
        testCountryPlan.add(countryPlan2);
        insert testCountryPlan;
        
        List<Account_Plan__c> lstaccountPlan1 = CRM_TestDataFactory.createAccountPlan(1,countryPlan1,lstAccounts[0]);
        
        //update countryPlan2;
        //System.assertNotEquals(null,countryPlan2.id);
        
        List<Account_Plan__c> lstaccountPlan2 = CRM_TestDataFactory.createAccountPlan(1,countryPlan2,lstAccounts[0]);                
    }
    
   /**
    *  Test 1: Test to insert Target on catalog type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget0
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget0(){
        //Creating Custom Setting
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;
        System.debug('defaultConfiguration.GL_Calender_for_New_Release_FR__c' + defaultConfiguration.GL_Calender_for_New_Release_FR__c);
        //GL Calender
        GL_Calendar__c glCalender = [Select Id,Start_Date__c,End_Date__c From GL_Calendar__c where Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c Limit 1];
        
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Test.setCurrentPage(Page.CRM_GenerateAccountPlanTargets); 
        Country_Plan__c cp = [Select ID FROM Country_Plan__c where name=:'CountryPlanCatalog'][0];        
                
        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        CRM_GenerateAccountPlanTargetsCtrl ctrl1 = new CRM_GenerateAccountPlanTargetsCtrl();
        Country_Plan__c countryPlan1 = ctrl.countryPlan;
        Country_Plan__c[] countryPlan2 = ctrl.countryPlans;
        
        ApexPages.StandardSetController sc2 = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT id FROM Country_Plan__c]));
        system.currentPageReference().getParameters().put('id', cp.Id);
        CRM_GenerateAccountPlanTargetsCtrl ctrl2 = new CRM_GenerateAccountPlanTargetsCtrl(sc2);
        
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        //Target formula
        //accountPlanTarget.Target__c = (accountPlan.Share__c * countryPlanTarget.Stretch_Target__c) / 100;
        Target__c targt = [Select Target__c,ID,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c FROM Target__c]; 
        System.assertEquals(1.50,targt.Returns_Target__c);
        System.assertEquals(2.40,targt.Billing_Adjustment_Target__c);
        System.assertEquals(4.50,targt.Returns_Forecast__c);
        System.assertEquals(4.80,targt.Billing_Adjustment_Forecast__c);
        System.assertEquals(11,targt.Target__c);
        
    }
    
   /**
    *  Test 2: Test to insert Target on catalog type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget1
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget1(){
        //Creating Custom Setting
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;
        System.debug('defaultConfiguration.GL_Calender_for_New_Release_FR__c' + defaultConfiguration.GL_Calender_for_New_Release_FR__c);
        //GL Calender
        GL_Calendar__c glCalender = [Select Id,Start_Date__c,End_Date__c From GL_Calendar__c where Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c Limit 1];
        
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Country_Plan__c cp = [Select ID FROM Country_Plan__c where name=:'CountryPlanNewRelease'][0];        
                
        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        ApexPages.StandardSetController sc2 = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT id FROM Country_Plan__c]));
        CRM_GenerateAccountPlanTargetsCtrl ctrl2 = new CRM_GenerateAccountPlanTargetsCtrl(sc2);
        
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        Target__c  targt = [Select Target__c,ID FROM Target__c][0]; 
        System.assertEquals(null,targt.Target__c); //0 Target__c
    }
    
       /**
    *  Test 3: Test to insert Target on catalog type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget2
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget2(){
        //Creating Custom Setting
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;
        System.debug('defaultConfiguration.GL_Calender_for_New_Release_FR__c' + defaultConfiguration.GL_Calender_for_New_Release_FR__c);
        //GL Calender
        GL_Calendar__c glCalender = [Select Id,Start_Date__c,End_Date__c From GL_Calendar__c where Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c Limit 1];
        
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Country_Plan__c cp = [Select ID FROM Country_Plan__c where name=:'CountryPlanNewRelease'][0];  
        Account_Plan__c ap = [Select Share__c from Account_Plan__c where Country_Plan__c =:cp.id][0];
        ap.share__c =null;
        update ap;
                
        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        Target__c  targt = [Select Target__c,ID FROM Target__c]; 
        System.assertEquals(null,targt.Target__c);
    }
    
      /**
    *  Test 4: Test to insert Target on catalog type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget3
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget3(){
        //Creating Custom Setting
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;
        System.debug('defaultConfiguration.GL_Calender_for_New_Release_FR__c' + defaultConfiguration.GL_Calender_for_New_Release_FR__c);
        //GL Calender
        GL_Calendar__c glCalender = [Select Id,Start_Date__c,End_Date__c From GL_Calendar__c where Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c Limit 1];
        
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Country_Plan__c cp = [Select ID FROM Country_Plan__c where name=:'CountryPlanCatalog1'][0];  
                
        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        Integer counter = [Select count() FROM Target__c]; 
        System.assertEquals(0,counter);
    }
    /**
    *  Test 5: Test to insert Target on catalog type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget3
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget4(){
        //Creating Custom Setting
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;
        System.debug('defaultConfiguration.GL_Calender_for_New_Release_FR__c' + defaultConfiguration.GL_Calender_for_New_Release_FR__c);
        //GL Calender
        GL_Calendar__c glCalender = [Select Id,Start_Date__c,End_Date__c From GL_Calendar__c where Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c Limit 1];
        
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Country_Plan__c cp = [Select ID FROM Country_Plan__c where name=:'CountryPlanCatalogBulk'][0];  
        Integer ap = [Select count() from Account_Plan__c where Country_Plan__c =:cp.id];
        Integer ct = [Select count() from Country_Plan_Target__c where Country_Plan__c =:cp.id];
           
           system.debug('**ap**'+ap);
           system.debug('**ct**'+ct);
                
        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        Integer counter = [Select count() FROM Target__c]; 
        System.assertEquals(100,counter); 
        list<Target__c> targetList = [Select Target__c FROM Target__c]; 
        for(Target__c trgt: targetList )
        System.assertEquals(11,trgt.Target__c);
    }
    
      /**
    *  Test 6: Test to insert Target on catalog type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget2
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget5(){
        //Creating Custom Setting
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;
        System.debug('defaultConfiguration.GL_Calender_for_New_Release_FR__c' + defaultConfiguration.GL_Calender_for_New_Release_FR__c);
        //GL Calender
        GL_Calendar__c glCalender = [Select Id,Start_Date__c,End_Date__c From GL_Calendar__c where Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c Limit 1];
        
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Country_Plan__c cp = [Select ID FROM Country_Plan__c where name=:'CountryPlanNewReleaseBulk'][0];  
        Integer ap = [Select count() from Account_Plan__c where Country_Plan__c =:cp.id];
        Integer ct = [Select count() from Country_Plan_Target__c where Country_Plan__c =:cp.id];
                
        system.debug('**ap**'+ap);
        system.debug('**ct**'+ct);
        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        Integer counter = [Select count() FROM Target__c]; 
        System.assertEquals(10,counter); //10 Targets
        list<Target__c> targetList = [Select Target__c FROM Target__c]; 
        for(Target__c trgt: targetList )
        System.assertEquals(null,trgt.Target__c);  
    }
    
     /**
    *  Test 6: Negative Test to insert Target on new Release type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget6
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget6(){
        //Creating Custom Setting
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
         defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;
        System.debug('defaultConfiguration.GL_Calender_for_New_Release_FR__c' + defaultConfiguration.GL_Calender_for_New_Release_FR__c);
        //GL Calender
        GL_Calendar__c glCalender = [Select Id,Start_Date__c,End_Date__c From GL_Calendar__c where Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c Limit 1];
        
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Country_Plan__c cp = [Select ID,Stretch_Target__c FROM Country_Plan__c where name=:'CountryPlanNewRelease'][0];        
        List<Account_Plan__c> aplist = [Select id,Share__c from Account_Plan__c where Country_Plan__c =:cp.id];
        
        List<Country_Plan_Target__c> ctlist = [Select id,Target__c from Country_Plan_Target__c where Country_Plan__c =:cp.id];
        cp.Stretch_Target__c = 1000000000;
        update cp;
        
        for(Account_Plan__c ap: aplist){
            ap.Share__c = 1000000000;
        }
        update aplist;
         for(Country_Plan_Target__c ct: ctlist){
            ct.Target__c = 1000000000;
        }
        update ctlist;
                
        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
    }
    
    //Req: #456 - Create Targets for every Account Plan
    static testMethod void createTargetsWithAccountPlan_Test(){
        //Creating 'CRM_Default_Configuration__c' Custom Setting to get 'GL_Calender_for_New_Release_FR__c'
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
        defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
        defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;
        System.debug('defaultConfiguration.GL_Calender_for_New_Release_FR__c' + defaultConfiguration.GL_Calender_for_New_Release_FR__c);
        //getting GL Calender record
        GL_Calendar__c glCalender = [Select Id,Start_Date__c,End_Date__c From GL_Calendar__c where Name =: defaultConfiguration.GL_Calender_for_New_Release_FR__c Limit 1];
        
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        
        Country_Plan__c cp1 = [Select ID FROM Country_Plan__c where name =: 'NewReleaseCountryPlan1'][0];        
        Country_Plan__c cp2 = [Select ID FROM Country_Plan__c where name =: 'NewReleaseCountryPlan2'][0];  
        
        list<string> listCPId = new List<string>();
        listCPId.add(cp1.id);
        listCPId.add(cp2.id);
               
        ApexPages.StandardController sc = new ApexPages.StandardController(cp1);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        
        Integer counter = [Select count() FROM Target__c]; 
        System.assertEquals(2,counter);
    }    
    
    //Req: #818 - Create Targets for every Account Plan for Italy
    static testMethod void createTargetsWithAccountPlanForItaly_Test(){
        //Creating Custom Setting
        CRM_Default_Configuration__c defaultConfiguration = new CRM_Default_Configuration__c();
        defaultConfiguration.GL_Calender_for_New_Release_FR__c = 'FR-NR'; 
        defaultConfiguration.GL_Calender_for_New_Release_JP__c = 'JP-NR'; 
        defaultConfiguration.GL_Calender_for_New_Release_IT__c = 'IT-NR'; 
        insert defaultConfiguration;

        List<Account> lstAccounts = CRM_AutoPhysicalNRDealCreateService_Test.createAccountsForNRBatch(5);
        for (Account acc : lstAccounts) {
            acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
            if (acc.Games_Digital__c || acc.Video_Digital__c) {
                acc.Digital_Country_Code__c = CRM_AppConstants.ACCOUNT_ITALY_DIGITAL_COUNTRY_CODE;
            }
        }
        update lstAccounts;
        System.assertEquals(5, lstAccounts.size());

        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'Italy'}, 1, false);
        for (Country__c country : lstCountry) {
            country.Name = 'Italy';
        }
        insert lstCountry;

        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;

        //Create GL Calender 
        List<GL_Calendar__c> glcListITNR = new List<GL_Calendar__c>();
        GL_Calendar__c glcITNR = new GL_Calendar__c();
        glcITNR.Start_Date__c = System.today();
        glcITNR.End_Date__c = System.today()+20;
        glcITNR.Name = 'IT-NR';
        glcListITNR.add(glcITNR);
        insert glcListITNR;

        List<Product_Group__c> lstProductGroup = [SELECT Id FROM Product_Group__c];
        System.assertEquals(1, lstProductGroup.size());

        List<Product2> lstProduct = CRM_TestDataFactory.createProducts([SELECT Id FROM Product_Group__c], 5, false); 
        for(Integer i=0; i<lstProduct.size(); i++){
            lstProduct[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            lstProduct[i].Street_Date__c = system.today()+1;
            lstProduct[i].NR_Product_Created__c = true;
            lstProduct[i].Street_Date_Has_Changed__c = false;
            lstProduct[i].Release_Category__c = CRM_AppConstants.PRODUCT_RELEASE_CATEGORY_NEW_RELEASE;
            lstProduct[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_ITALY_CODE;
            lstProduct[i].CurrencyIsoCode = 'USD';
            lstProduct[i].Local_Title__c = lstLocaTitle[0].Id;
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
        System.debug('lstProduct::'+lstProduct.size());
        lstProduct = [SELECT Id,Release_Category__c, Street_Date__c, CurrencyIsoCode, RecordTypeId, SAP_Material_Type__c, Local_Title__c, Type__c, Product_Type__c, Street_Date_Has_Changed__c, NR_Product_Created__c FROM Product2 WHERE SAP_Sales_Org__c = : CRM_AppConstants.TERRITORY_ITALY_CODE ORDER BY CreatedDate];

        System.assertEquals(5, lstProduct.size());

        List<Country_Plan__c> lstCountryPlans = CRM_TestDataFactory.createCountryPlanNewRelease(1, lstProduct, true);
        System.assertEquals(5, lstCountryPlans.size());

        for(Country_Plan__c cp:lstCountryPlans){
            cp.Target_Quantity__c =10.09;
        }
        update lstCountryPlans;

        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlans, lstAccounts, true);
        System.assertEquals(25, lstAccountPlan.size());
        for(Account_Plan__c acc:lstAccountPlan){
            acc.Target_Revenue_Has_Changed__c = false;
        }
        update lstAccountPlan;
        
        lstCountryPlans = [Select Id, Name, RecordType.DeveloperName,RecordTypeId,NR_Product__c,Product_Group1__c,NR_Product__r.Title_Country__c,Last_Auto_Allocated_Date__c,
        (Select Id,Name,End_Date__c,Start_Date__c,GL_Calendar__c,Stretch_Target__c,Target__c,Returns_Target__c,Billing_Adjustment_Target__c,Returns_Forecast__c,Billing_Adjustment_Forecast__c From Country_Plan_Targets__r ORDER BY Start_Date__c),
        (Select Id,Name, RecordTypeId, CurrencyISOCode, Share__c,Total_Target__c,Target_Quantity__c,Product_Group__c,Customer__c,Returns_Share__c,Billing_Adjustment_Share__c,Country_Plan__r.Id,Country_Plan__r.Name From Account_Plans__r)// Where Country_Plan__c=:countryPlanId
        From Country_Plan__c Where Id IN : lstCountryPlans ];

        //ApexPages.StandardController sc = new ApexPages.StandardController(lstCountryPlans[0]);
        //CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        System.debug('-lstCountryPlans-before-->'+lstCountryPlans);
 
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(new List<String>{lstCountryPlans[0].Id, lstCountryPlans[1].Id, lstCountryPlans[2].Id, lstCountryPlans[3].Id, lstCountryPlans[4].Id});
        Test.stopTest();
        System.debug('-lstCountryPlans-after-->'+lstCountryPlans);
        
        List<Target__c> lstTargets = [Select Id, Target_Units__c, Account_Plan_Lookup__r.Target_Quantity__c, Account_Plan_Lookup__r.country_Plan__r.NR_Product__r.Title_Country__c FROM Target__c]; 
        System.assertEquals(25,lstTargets.size());
        for (Target__c target : lstTargets) {
            system.assertEquals('Italy', target.Account_Plan_Lookup__r.country_Plan__r.NR_Product__r.Title_Country__c);
            system.assertEquals(1, target.Account_Plan_Lookup__r.Target_Quantity__c);
            system.assertEquals(1, target.Target_Units__c);
        }
    }
}