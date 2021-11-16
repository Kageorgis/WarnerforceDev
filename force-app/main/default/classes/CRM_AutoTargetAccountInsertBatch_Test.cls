/**
   @Author Cognizant
   @name CRM_CountryPlanTargetHandler_Test
   @CreateDate 20 Feb 2016
   @Description Test class for CRM_CountryPlanTargetSequenceHandler
   @Version <1.0>
  */

@isTest(SeeAllData=false)
private class CRM_AutoTargetAccountInsertBatch_Test{
 
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    */
    
    private static void createTestData() {
         
        List<Country_plan__c> lstCPlans = new list<Country_plan__c>();
        List<Country_plan_Target__c> lstCPlanTarget = new list<Country_plan_Target__c>();
        CRM_AutoTargetCreationBatch_Test.CRM_AutoTargetCreationHelper_TestWrapper tempWrapper = new CRM_AutoTargetCreationBatch_Test.CRM_AutoTargetCreationHelper_TestWrapper();
        tempWrapper = CRM_AutoTargetCreationBatch_Test.createData();
        
        for(Integer i=0;i<tempWrapper.lstProduct.size();i++)
        {
            tempWrapper.lstProduct[i].Pending_Country_Plan_Creation__c = false;
            tempWrapper.lstProduct[i].External_Id__c = 'USA_en_6000054423_EST_SD'+string.valueOf(i);
            
        }
        update tempWrapper.lstProduct;
        
        List<GL_Calendar__c> glcList = new List<GL_Calendar__c>();
        GL_Calendar__c glc = new GL_Calendar__c();
        glc.Start_Date__c = System.today();
        glc.End_Date__c = System.today()+3;
        glc.Name = '2016-01';
        glc.Month__c = String.ValueOf(System.today().month());
        glc.Year__c = String.ValueOf(System.today().year());
        glcList.add(glc);
        lstCPlans = createCountryPlans(tempWrapper.lstProduct);
        System.assertEquals(5, lstCPlans.size());
        lstCPlanTarget = createCountryPlanTarget(lstCPlans,glcList);
        System.assertEquals(5, lstCPlanTarget.size());  
    }
    private static void createTestData1() {
         
        List<Country_plan__c> lstCPlans = new list<Country_plan__c>();
        List<Country_plan_Target__c> lstCPlanTarget = new list<Country_plan_Target__c>();
        CRM_AutoTargetCreationBatch_Test.CRM_AutoTargetCreationHelper_TestWrapper tempWrapper = new CRM_AutoTargetCreationBatch_Test.CRM_AutoTargetCreationHelper_TestWrapper();
        tempWrapper = CRM_AutoTargetCreationBatch_Test.createData();
        
        for(Integer i=0;i<tempWrapper.lstProduct.size();i++)
        {
            tempWrapper.lstProduct[i].Pending_Country_Plan_Creation__c = false;
            tempWrapper.lstProduct[i].External_Id__c = 'USA_en_6000054423_EST_SD'+string.valueOf(i);
            
        }
        update tempWrapper.lstProduct;
        
        List<GL_Calendar__c> glcList = new List<GL_Calendar__c>();
        GL_Calendar__c glc = new GL_Calendar__c();
        glc.Start_Date__c = System.today();
        glc.End_Date__c = System.today()+3;
        glc.Name = '2016-01';
        glc.Month__c = String.ValueOf(System.today().month());
        glc.Year__c = String.ValueOf(System.today().year());
        glcList.add(glc);  
        System.assertEquals(1, glcList.size());
    }
    
    private static void createTestDataForBackDate() {
         
        List<Country_plan__c> lstCPlans = new list<Country_plan__c>();
        List<Country_plan_Target__c> lstCPlanTarget = new list<Country_plan_Target__c>();
        CRM_AutoTargetCreationBatch_Test.CRM_AutoTargetCreationHelper_TestWrapper tempWrapper = new CRM_AutoTargetCreationBatch_Test.CRM_AutoTargetCreationHelper_TestWrapper();
        tempWrapper = CRM_AutoTargetCreationBatch_Test.createDataForBackDate();
        
        for(Integer i=0;i<tempWrapper.lstProduct.size();i++)
        {
            tempWrapper.lstProduct[i].Pending_Country_Plan_Creation__c = false;
            tempWrapper.lstProduct[i].External_Id__c = 'USA_en_6000054423_EST_SD'+string.valueOf(i);
            
        }
        update tempWrapper.lstProduct; 
        
        lstCPlans = createCountryPlans(tempWrapper.lstProduct);
        System.assertEquals(2, lstCPlans.size());
        lstCPlanTarget = createCountryPlanTarget(lstCPlans,tempWrapper.glcList);
        System.assertEquals(2, lstCPlanTarget.size()); 
    }
    
    /**
     * createCountryPlans(list<Product2>)
     * This method is called to create country plan for a test class.
    */      
    public static list<Country_Plan__c> createCountryPlans(list<Product2> lstProduct) {
        list<Country_plan__c> lstplans = new list<Country_plan__c> ();
        if(lstProduct.size()>0)
        {
            for(Integer i=0;i<lstProduct.size();i++)
            {
                Country_Plan__c countryPlan = new Country_Plan__c();
                countryPlan.Name = 'CountryPlanNew_ReleaseTest'+String.valueOf(i);
                countryPlan.Year__c = '2016';
                countryPlan.Country__c = 'United Kingdom';
                countryPlan.NR_Product__c = lstProduct[i].Id;
                countryPlan.CurrencyIsoCode = 'USD';
                countryPlan.Stretch_Target__c = 10;
                countryPlan.External_Id__c = lstProduct[i].External_Id__c;
                countryPlan.RecordTypeID = CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE; 
                lstplans.add(countryPlan);
            }
            insert lstplans; 
        }
        return lstplans;
    }
    
     /**
     * createCountryPlanTarget(Country_Plan__c,List<GL_Calendar__c>)
     * This method is called to create country plan target for a test class.
    */      
    public static list<Country_Plan_Target__c> createCountryPlanTarget(list<Country_Plan__c> countryPlan,List<GL_Calendar__c> glclist) {
        
        list<Country_Plan_Target__c> countryPlanTargetList = new list<Country_Plan_Target__c>();
        if(countryPlan.size()>0 && glclist.size()>0)
        {
            for(Country_Plan__c cp : countryPlan){
                Country_Plan_Target__c countryPlanTarget  = new Country_Plan_Target__c();
                countryPlanTarget.Country_Plan__c = cp.Id;
                countryPlanTarget.GL_Calendar__c = glclist[0].Id;
                countryPlanTarget.Target__c = 10;
                countryPlanTarget.CurrencyIsoCode = 'USD';
                countryPlanTarget.Returns_Target__c = 10;
                countryPlanTarget.Billing_Adjustment_Target__c = 20;
                countryPlanTarget.Returns_Forecast__c = 30;
                countryPlanTarget.Billing_Adjustment_Forecast__c = 40;
                countryPlanTargetList.add(countryPlanTarget);
            }
        }
        insert countryPlanTargetList;
        System.assertNotEquals(null,countryPlanTargetList);    
        return countryPlanTargetList;
    } 
     
    
    /**
     * test_CRM_AutoTargetCreationAccountInsertBatch()
     * This method is called to test batch when CP and CPT exists then AP and APT should be created.
    */ 
    static testMethod void test_CRM_AutoTargetCreationAccountInsertBatch(){
    createTestData() ;
        Test.startTest();
            CRM_AutoTargetCreationAccountInsertBatch batchProcess = new CRM_AutoTargetCreationAccountInsertBatch();
            Database.executeBatch(batchProcess,10); 
        Test.stopTest();
    }
    /**
     * test_CRM_AutoTargetCreationAccountInsertBatch()
     * This method is called to test batch when CP and CPT does not exists then flag should be updated.
    */
    static testMethod void test_CRM_AutoTargetCreationAccountInsertBatch1(){
    createTestData1() ;
        Test.startTest();
            CRM_AutoTargetCreationAccountInsertBatch batchProcess = new CRM_AutoTargetCreationAccountInsertBatch();
            Database.executeBatch(batchProcess,10); 
        Test.stopTest();
    }
    
    /**
     * test_CRM_AutoTargetCreationAccountInsertBatch()
     * This method is called to test batch when CP and CPT exists then AP and APT should be created.
    */ 
    static testMethod void test_CRM_AutoTargetCreationAccountInsertBatch2(){
    createTestDataForBackDate() ;
        Test.startTest();
            CRM_AutoTargetCreationAccountInsertBatch batchProcess = new CRM_AutoTargetCreationAccountInsertBatch();
            Database.executeBatch(batchProcess,10); 
        Test.stopTest();
          Integer apCounter = [Select count() FROM Account_Plan__c]; 
        System.assertEquals(1,apCounter);
        List<Account_Plan__c> lstAccPlan =[Select Share__c FROM Account_Plan__c]; 
       // System.assertEquals(null,lstAccPlan[0].Share__c); 
        Integer targetCounter = [Select count() FROM Target__c]; 
        System.assertEquals(1,targetCounter);
    }
    
}