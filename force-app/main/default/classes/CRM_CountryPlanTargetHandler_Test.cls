/**
   @Author Cognizant
   @name CRM_CountryPlanTargetHandler_Test
   @CreateDate 16 Feb 2016
   @Description Test class for CRM_CountryPlanTargetSequenceHandler
   @Version <1.0>
  */

@isTest(SeeAllData=false)
private class CRM_CountryPlanTargetHandler_Test{
 
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
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true); 
        
        for(Account acc : lstAccounts){
        acc.RecordTypeID = tempRecordType;
        }
        upsert lstAccounts;
        List<GL_Calendar__c> glcList = new List<GL_Calendar__c>();
        integer i;
        for(i = 0 ;i < 10; i++){
        GL_Calendar__c glc = new GL_Calendar__c();
        glc.Start_Date__c = System.today()+i;
        glc.End_Date__c = System.today()+i+1;
        glc.Name = '2016-01';
        glc.month__c = string.ValueOf(System.today().month()+i);
        glcList.add(glc);
        }
        Insert glcList;
        
    /*Creating country plan */
        Country_Plan__c countryPlan = CRM_TestDataFactory.createCountryPlanCatalog(lstProductGroup);
        System.assertNotEquals(null,countryPlan.id);
        countryPlan.Name = 'CountryPlanCatalogBulk';
        update countryPlan;
        
        Country_Plan__c countryPlan1 = CRM_TestDataFactory.createCountryPlanNewRelease(lstProduct);
        System.assertNotEquals(null,countryPlan1.id);
        countryPlan1.Name = 'CountryPlanNewReleaseBulk';
        update countryPlan1;
        
        CRM_TestDataFactory.createCountryPlanTarget(countryPlan,glcList);
        CRM_TestDataFactory.createCountryPlanTarget(countryPlan1,glcList);
        
        list<Country_Plan__c> testCountryPlan = new list<Country_Plan__c>();
        testCountryPlan.add(countryPlan);
        list<Country_Plan__c> testCountryPlan1 = new list<Country_Plan__c>();
        testCountryPlan1.add(countryPlan1);
        CRM_TestDataFactory.createAccountPlan(testCountryPlan,lstAccounts,true);
        CRM_TestDataFactory.createAccountPlan(testCountryPlan1,lstAccounts,true);

    }
    
    /**
    *  Test 1: Test to insert Target on catalog type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget1
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget1(){
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Country_Plan__c cp = [Select ID FROM Country_Plan__c where name=:'CountryPlanCatalogBulk'][0];  
        Integer ap = [Select count() from Account_Plan__c where Country_Plan__c =:cp.id];
        Integer ct = [Select count() from Country_Plan_Target__c where Country_Plan__c =:cp.id];
        List<Country_Plan_Target__c> listCt = [Select id from Country_Plan_Target__c where Country_Plan__c =:cp.id];
                
        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        delete listCt[0];
        Integer counter = [Select count() FROM Target__c]; 
        System.assertEquals(90,counter);
    }
    
      /**
    *  Test 2: Test to insert Target on catalog type counrty plan. 
    *  Expected: Targets should get created on cobination of country plan target and account plan if not exist. Otherwise updated.
    *  @name createTarget2
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testMethod void createTarget2(){
        Test.setCurrentPageReference(Page.CRM_GenerateAccountPlanTargets);
        Country_Plan__c cp = [Select ID FROM Country_Plan__c where name=:'CountryPlanNewReleaseBulk'][0];  
        Integer ap = [Select count() from Account_Plan__c where Country_Plan__c =:cp.id];
        Integer ct = [Select count() from Country_Plan_Target__c where Country_Plan__c =:cp.id];
        List<Country_Plan_Target__c> listCt = [Select id from Country_Plan_Target__c where Country_Plan__c =:cp.id];

        ApexPages.StandardController sc = new ApexPages.StandardController(cp);
        CRM_GenerateAccountPlanTargetsCtrl ctrl = new CRM_GenerateAccountPlanTargetsCtrl(sc);
        
        list<string> listCPId = new List<string>();
        listCPId.add(cp.id);
        Test.startTest();
        CRM_GenerateAccountPlanTargetsCtrl.createTarget(listCPId);
        Test.stopTest();
        delete listCt[0];
        Integer counter = [Select count() FROM Target__c]; 
        System.assertEquals(90,counter);
        CRM_CountryPlanTargetSequenceHandler testInstance = new CRM_CountryPlanTargetSequenceHandler();
        testInstance.logAnException(null,null);
    }
}