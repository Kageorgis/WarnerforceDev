/**
   @Author Cognizant Team
   @name CRM_AssortmentValidationHandler_Test  
   @CreateDate 
   @Description Test class for CRM_AssortmentValidationHandler 
   @Version <1.0>
   @reference Requirement no 277
  */
@isTest
private class CRM_AssortmentValidationHandler_Test {
    
    public static List<Bundle__c> insertBundle;
    
    public static void createBundle(){
        insertBundle = new List<Bundle__c>();
        Bundle__c currentBundle = new Bundle__c();
        currentBundle.Name = 'Dummy Assortment';
        currentBundle.Start_Date__c = Date.today();
        currentBundle.End_Date__c = System.today() + 30;
        currentBundle.Assortment_Status__c = 'Draft';
        currentBundle.RecordTypeId = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
        insertBundle.add(currentBundle);
    }
    
    public static void createCustomSetting(){
        List<CRM_Assortment_Transitions__c> customSettingList = new List<CRM_Assortment_Transitions__c>();
         CRM_Assortment_Transitions__c assrtTransition1 = new CRM_Assortment_Transitions__c();
         assrtTransition1.Name = 'Test 1';
         assrtTransition1.Profile__c = 'CRM - Marketing - FR';
         assrtTransition1.From_Status__c = 'Draft';
         assrtTransition1.To_status__c = 'Awaiting Approval';
         customSettingList.add(assrtTransition1);
         CRM_Assortment_Transitions__c assrtTransition2 = new CRM_Assortment_Transitions__c();
         assrtTransition2.Name = 'Test 2';
         assrtTransition2.Profile__c = 'System Administrator';
         assrtTransition2.From_Status__c = 'Draft';
         assrtTransition2.To_status__c = 'Awaiting Approval';
         customSettingList.add(assrtTransition2);
         CRM_Assortment_Transitions__c assrtTransition3 = new CRM_Assortment_Transitions__c();
         assrtTransition3.Name = 'Test 3';
         assrtTransition3.Profile__c = 'System Administrator';
         assrtTransition3.From_Status__c = 'Awaiting Approval';
         assrtTransition3.To_status__c = 'Approved';
         customSettingList.add(assrtTransition3);
         insert customSettingList;
    }
    /*
    static testMethod void testUpdateApproverNameAndDate() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'wassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
        system.runAs(testUser){
            createCustomSetting();
            createBundle();
            insert insertBundle;
            insertBundle = [SELECT Name,Start_Date__c,End_Date__c,Assortment_Status__c FROM Bundle__c WHERE Name='Dummy Assortment'];
            insertBundle[0].Assortment_Status__c = 'Awaiting Approval';
            update insertBundle;
            insertBundle[0].Assortment_Status__c = 'Approved';
            update insertBundle;
            insertBundle = null;
            insertBundle = [SELECT Name,Assortment_Status__c, Last_Approved_By__c FROM Bundle__c WHERE Name='Dummy Assortment'];
            system.debug('Last_Approved_By__c::::>>>>' + insertBundle[0]);
            system.assert(null != insertBundle[0]);
        }       
    }
    
    static testMethod void updateBundle() {
        Profile p = [SELECT Id FROM Profile WHERE Name='CRM - Marketing - FR'];
        User testUser = new User(Alias = 'wassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
        system.runAs(testUser){
            createCustomSetting();
            createBundle();
            insert insertBundle;
            insertBundle = [SELECT Name,Start_Date__c,End_Date__c,Assortment_Status__c FROM Bundle__c WHERE Name='Dummy Assortment'];
            insertBundle[0].Assortment_Status__c = 'Awaiting Approval';
            update insertBundle;
            insertBundle = null;
            insertBundle = [SELECT Name,Assortment_Status__c FROM Bundle__c WHERE Name='Dummy Assortment'];
            system.assertEquals('Awaiting Approval', insertBundle[0].Assortment_Status__c);
        }       
    }
    */
   
    static testMethod void testInvalidInsertState() {
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='CRM - Operations - FR'];
            User testUser = new User(Alias = 'wassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
            system.runAs(testUser){
                createCustomSetting();
                createBundle();
                insertBundle[0].Assortment_Status__c = 'Awaiting Approval';
                insert insertBundle;  
            }
        }catch(Exception e){
            System.assert(e != null);
        }
    }
    
    
    static testMethod void checkWrongTransition() {
        Profile p = [SELECT Id FROM Profile WHERE Name='CRM - Marketing - FR'];
        User testUser = new User(Alias = 'wassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
        system.runAs(testUser){
            try{
                createCustomSetting();
                createBundle();
                insert insertBundle;
                insertBundle = [SELECT Name,Start_Date__c,End_Date__c,Assortment_Status__c FROM Bundle__c WHERE Name='Dummy Assortment'];
                system.debug('Assortment status ::::'+insertBundle[0].Assortment_Status__c);
                insertBundle[0].Assortment_Status__c = 'Approved';
                update insertBundle;
                insertBundle = null;
                insertBundle = [SELECT Name,Assortment_Status__c FROM Bundle__c WHERE Name='Dummy Assortment'];
            }catch(Exception e){
                Boolean expectedExceptionThrown =  (e.getMessage().contains('Invalid status transition')) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }       
    }
    
    static testMethod void checkSameTransitionChange() {
        Profile p = [SELECT Id FROM Profile WHERE Name='CRM - Marketing - FR'];
        User testUser = new User(Alias = 'wassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
        system.runAs(testUser){
            try{
                createCustomSetting();
                createBundle();
                insertBundle = new List<Bundle__c>();
                Bundle__c currentBundle = new Bundle__c();
                currentBundle.Name = 'Dummy Assortment';
                currentBundle.Start_Date__c = Date.today();
                currentBundle.End_Date__c = System.today() + 30;
                currentBundle.Assortment_Status__c = 'Published';
                insertBundle.add(currentBundle);
                insert insertBundle;
                insertBundle = [SELECT Name,Start_Date__c,End_Date__c,Assortment_Status__c FROM Bundle__c WHERE Name='Dummy Assortment'];
                system.debug('Assortment status ::::'+insertBundle[0].Assortment_Status__c);
                insertBundle[0].Assortment_Status__c = 'Published';
                update insertBundle;
                insertBundle = null;
                insertBundle = [SELECT Name,Assortment_Status__c FROM Bundle__c WHERE Name='Dummy Assortment'];
            }catch(Exception e){
                Boolean expectedExceptionThrown =  (e.getMessage().contains('Invalid status transition')) ? true : false;
                //System.AssertEquals(expectedExceptionThrown, true);
            }
        }       
    }
    
    //Method to test deleteAssortmentError which Stop's user from Deleting Assortment.  
    static testMethod void testdeleteAssortmentError() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'wassort', Email='wbcrmassortmentuser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmassortmnetuser@testorg.com');
        system.runAs(testUser){
            createBundle();
            insertBundle[0].Last_Published_Date__c = System.today();
            insert insertBundle;
            try{
                delete insertBundle[0];    
            }Catch(Exception e){
                Boolean expectedExceptionThrown =  (e.getMessage().contains('You cannot delete this Assortment as the Last Published Date is not null.')) ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
    
    public static testmethod void test_batch() {
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = 'wbappr', Email='wbcrmstandarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmapprovass@testorg.com'+String.valueOf(Math.random()),ByPassValidationRule__c =true);
        System.runAs(testUser) {
            // Insert Account (10 for assortment account and 1 for pricing account)
            List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(11, false);
            for(Account acc : lstAccounts) {
                acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
                acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
            }
            insert lstAccounts;
            
            List<Pricebook2> lstPricebook = new List<Pricebook2>();
            Pricebook2 pricebook = new Pricebook2();
            pricebook.Name = 'testPB';
            pricebook.Business_Unit__c = '6014';
            pricebook.Product_Type__c = 'Digital';
            lstPricebook.add(pricebook);
            insert lstPricebook;
                        
            List<Bundle__c> lstBundles1 = CRM_TestDataFactory.createBundles(1, false);
            lstBundles1[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_Approved;
            lstBundles1[0].Name = 'Test National Campaign Bundle';
            lstBundles1[0].RecordTypeId = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
            lstBundles1[0].High_Level_Target__c = 20000;
            lstBundles1[0].Promo_Start_Date__c = Date.today().addDays(1);
            lstBundles1[0].Promo_End_Date__c = Date.today().addDays(30);
            lstBundles1[0].Account_Split_Template__c = null;
            lstBundles1[0].Campaign_Type__c = CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL;
            lstBundles1[0].Price_Book__c = lstPricebook[0].Id;
            insert lstBundles1;
            
            // Create a list of bundle products
            List<Assortment_Account__c> lstBundleAccounts = new List<Assortment_Account__c>();
            // Add products to bundle (100 Products)
            for (Integer i=1; i < lstAccounts.size(); i++) {
                Assortment_Account__c bAcc = new Assortment_Account__c();
                bAcc.Assortment__c = lstBundles1[0].Id;
                bAcc.Account__c = lstAccounts[i].Id;
                bAcc.Share__c = 10;
                lstBundleAccounts.add(bAcc);
            }
            // Insert Assortment Products
            insert lstBundleAccounts;
            
            List<Bundle__c> oldLst = new List<Bundle__c>();
            oldLst  = [Select Id,Assortment_Status__c  from bundle__c];
            oldLst[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL;
                                   
            CRM_AssortmentValidationHandler.publishAssortmentOnApproval(new Map<Id, Bundle__c>(oldLst), lstBundles1); 
        }             
        Test.stopTest();
        System.assertNotEquals(Null, [Select Id,Assortment_Status__c,Last_Published_Date__c from bundle__c Limit 1].Last_Published_Date__c);
    }
}