/**
 * @Author Cognizant
 * @name CRM_ValidateAssortmentCtrl_Test
 * @CreateDate 11 July 2016
 * @Description Test class for CRM_ValidateAssortmentCtrl
 * @Version <1.0>
 */
@isTest
private class CRM_ValidateAssortmentCtrl_Test {
  static List<Bundle__c> lstBundles;
  static List<Bundle_Product__c> lstBundleProducts;
  static List<Assortment_Account__c> lstBundleAccounts;
  static List<Account> lstAccounts;
  static List<Product_Group__c> lstProductGroups;
  static List<Product2> lstProducts;

    private static void setupTestData() {
      // Insert Account (10 for assortment account and 1 for pricing account)
      lstAccounts = CRM_TestDataFactory.createAccounts(11, false);
      for(Account acc : lstAccounts) {
        acc.RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        acc.Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
      }
      insert lstAccounts;

      // Create 10 Products
      lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
      lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 10, false);

    // update all 10 product records
     for (Integer i=0; i < lstProducts.size(); i++) {
         lstProducts[i].ProductCode = '1000230554';
         lstProducts[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
         lstProducts[i].Product_Format__c = '4';
         lstProducts[i].Product_Rating__c = 'UK - Minimum 12 Ye';
         lstProducts[i].Product_Genre__c = 'ACTION';
         lstProducts[i].Release_Category__c = '23';
         lstProducts[i].Franchise_Type__c = 'X4';
         lstProducts[i].Product_Language_Code__c = 'EN';
         lstProducts[i].SAP_Dist_chain_product_Status__c = '11';
         lstProducts[i].Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
         lstProducts[i].Recommended_Price__c = 150;
         lstProducts[i].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
     }
     insert lstProducts;

    CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
    CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);

    lstBundles = CRM_TestDataFactory.createBundles(1, false);
    lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;
    lstBundles[0].Name = 'Test National Campaign Bundle';
    lstBundles[0].RecordTypeId = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
    lstBundles[0].High_Level_Target__c = 20000;
    lstBundles[0].Promo_Start_Date__c = Date.today().addDays(1);
    lstBundles[0].Promo_End_Date__c = Date.today().addDays(30);
    lstBundles[0].Account_Split_Template__c = null;
    lstBundles[0].Campaign_Type__c = CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL;
    lstBundles[0].Pricing_Account__c = lstAccounts[0].Id;
    
    insert lstBundles;

    //lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
    // lstBundles;

    // Create a list of bundle products
    lstBundleProducts = new List<Bundle_Product__c>();
    // Add products to bundle (100 Products)
    for (Integer i=0; i < lstProducts.size(); i++) {
      Bundle_Product__c bProd = new Bundle_Product__c();
      bProd.Bundle__c = lstBundles[0].Id;
      bProd.Product__c = lstProducts[i].Id;
      bProd.List_Price__c = 20;
      bProd.Assortment_Price__c = 20;
      bProd.Share__c = 10;
      lstBundleProducts.add(bProd);
    }
    // Insert Assortment Products
    insert lstBundleProducts;

    // Create a list of bundle products
    lstBundleAccounts = new List<Assortment_Account__c>();
    // Add products to bundle (100 Products)
    for (Integer i=1; i < lstAccounts.size(); i++) {
      Assortment_Account__c bAcc = new Assortment_Account__c();
      bAcc.Assortment__c = lstBundles[0].Id;
      bAcc.Account__c = lstAccounts[i].Id;
      bAcc.Share__c = 10;
      lstBundleAccounts.add(bAcc);
    }
    // Insert Assortment Products
    insert lstBundleAccounts;
    }

    static testmethod void test_validateAssortmentNoOverlapingNoRefresh() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_ValidateAssortment);
      Test.setCurrentPage(Page.CRM_ValidateAssortment); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_ValidateAssortmentCtrl controller = new CRM_ValidateAssortmentCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      // ASSORTMENT_TYPE_
      lstBundles[0].Campaign_Type__c = 'New Release'; //CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL;
      update lstBundles;
      CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);

      Id[] listAssortmentIds = new Id[]{lstBundles[0].Id};
      List<Bundle_Product__c> bundleProductList = [select Assortment_Price__c from Bundle_Product__c];
      for(Bundle_Product__c bp : bundleProductList) {
         bp.Assortment_Price__c = 12;
      }
      update bundleProductList;
      try{
          CRM_ValidateAssortmentCtrl.refreshProductPrices(listAssortmentIds);
          system.assertEquals(false,CRM_ValidateAssortmentCtrl.raisealert);
      }
      catch(Exception e){
        system.assertEquals(Label.CRM_Validation_msg_prices_are_upto_date, e.getmessage());
      }
      delete [Select Id from Assortment_Account__c];
      try{
          CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      }
      catch(Exception e){
        system.assertEquals(Label.CRM_No_Accounts_found_for_assortment, e.getmessage());
      }
      delete [Select Id from Bundle_Product__c];
      try{
          CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      }
      catch(Exception e){
        system.assertEquals(Label.CRM_No_Products_found_for_assortment, e.getmessage());
      }
       try{
          CRM_ValidateAssortmentCtrl.refreshProductPrices(listAssortmentIds);
      }
      catch(Exception e){
        system.assertEquals(Label.CRM_No_Products_found_for_assortment, e.getmessage());
      }
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User testUser = new User(Alias = 'wbappra', Email='wbcrmstandarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmapprovassa@testorg.com',ByPassValidationRule__c =true);
    
      System.runAs(testUser) {
         lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
         update lstBundles;
      }
      try{
          CRM_ValidateAssortmentCtrl.refreshProductPrices(listAssortmentIds);
      }
      catch(Exception e){
        system.assertEquals(Label.CRM_Approved_assortment_cannot_be_edited_validated, e.getmessage());
      }
       try{
          CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      }
      catch(Exception e){
        system.assertEquals(Label.CRM_Assortment_is_not_in_Draft_Stage, e.getmessage());
      }
      Test.stopTest();
    }
    
    static testmethod void test_validateAssortmentNoOverlapingWithRefresh() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_ValidateAssortment);
      Test.setCurrentPage(Page.CRM_ValidateAssortment); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_ValidateAssortmentCtrl controller = new CRM_ValidateAssortmentCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);

      Id[] listAssortmentIds = new Id[]{lstBundles[0].Id};
      
      List<Pricebook_Entry_Period__c> pbeplist = [select List_Price__c from Pricebook_Entry_Period__c];
      for(Pricebook_Entry_Period__c pbep : pbeplist) {
         pbep.List_Price__c = 10;
      }
      update pbeplist;

      CRM_ValidateAssortmentCtrl.refreshProductPrices(listAssortmentIds);
      system.assertEquals(false,CRM_ValidateAssortmentCtrl.raisealert);
      List<Bundle_Product__c> bundleProductList = [select Assortment_Price__c,List_Price__c from Bundle_Product__c where Bundle__c = : lstBundles[0].Id ];
      for(Bundle_Product__c bp : bundleProductList) {
         system.assertEquals(10,bp.Assortment_Price__c);
         system.assertEquals(10,bp.List_Price__c);
      }
      
      Test.stopTest();
    }
    
    static testmethod void test_validateAssortmentOverlaping() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_AssortmentApproval);
      Test.setCurrentPage(Page.CRM_AssortmentApproval); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_ValidateAssortmentCtrl controller = new CRM_ValidateAssortmentCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      
      //lstBundles[0].Campaign_Type__c = CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL;
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User testUser = new User(Alias = 'wbapprb', Email='wbcrmstandarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmapprovassb@testorg.com',ByPassValidationRule__c =true);
    
      System.runAs(testUser) {
         lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
         update lstBundles;
      }
      //CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      system.assertEquals(CRM_AppConstants.ASSORTMENT_STATUS_APPROVED,[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
      
      lstBundles = CRM_TestDataFactory.createBundles(1, false);
      lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;
      lstBundles[0].Name = 'Test National Campaign Bundle';
      lstBundles[0].RecordTypeId = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
      lstBundles[0].High_Level_Target__c = 20000;
      lstBundles[0].Promo_Start_Date__c = Date.today().addDays(1);
      lstBundles[0].Promo_End_Date__c = Date.today().addDays(30);
      lstBundles[0].Account_Split_Template__c = null;
      lstBundles[0].Campaign_Type__c = CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL;
      lstBundles[0].Pricing_Account__c = lstAccounts[1].Id;
    
      insert lstBundles;

    //lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
    // lstBundles;

    // Create a list of bundle products
    lstBundleProducts = new List<Bundle_Product__c>();
    // Add products to bundle (100 Products)
    for (Integer i=0; i < lstProducts.size(); i++) {
      Bundle_Product__c bProd = new Bundle_Product__c();
      bProd.Bundle__c = lstBundles[0].Id;
      bProd.Product__c = lstProducts[i].Id;
      bProd.List_Price__c = 20;
      bProd.Assortment_Price__c = 15;
      bProd.Share__c = 10;
      lstBundleProducts.add(bProd);
    }
    // Insert Assortment Products
    insert lstBundleProducts;

    // Create a list of bundle products
    lstBundleAccounts = new List<Assortment_Account__c>();
    // Add products to bundle (100 Products)
    for (Integer i=1; i < lstAccounts.size(); i++) {
      Assortment_Account__c bAcc = new Assortment_Account__c();
      bAcc.Assortment__c = lstBundles[0].Id;
      bAcc.Account__c = lstAccounts[i].Id;
      bAcc.Share__c = 10;
      lstBundleAccounts.add(bAcc);
    }
    // Insert Assortment Products
    insert lstBundleAccounts;
    
      CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      system.assertEquals(true,CRM_ValidateAssortmentCtrl.raisealert);
      
      Test.stopTest();
    }
    
    
    static testmethod void test_validateAssortmentOverlapingNotNational() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_AssortmentApproval);
      Test.setCurrentPage(Page.CRM_AssortmentApproval); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_ValidateAssortmentCtrl controller = new CRM_ValidateAssortmentCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      
      lstBundles[0].Campaign_Type__c = 'New Release';
      update lstBundles;
      
      for(Assortment_Account__c bAcc : lstBundleAccounts){
         bAcc.send_to_OTC__c = true;
      }
      update lstBundleAccounts;
      
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User testUser = new User(Alias = 'wbapprc', Email='wbcrmstandarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmapprovassc@testorg.com',ByPassValidationRule__c =true);
    
      System.runAs(testUser) {
         lstBundles[0].Campaign_Type__c = 'New Release';
         lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
         update lstBundles;
      }
      //CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      system.assertEquals(CRM_AppConstants.ASSORTMENT_STATUS_APPROVED,[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
      
      lstBundles = CRM_TestDataFactory.createBundles(1, false);
      lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_DRAFT;
      lstBundles[0].Name = 'Test National Campaign Bundle';
      lstBundles[0].RecordTypeId = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
      lstBundles[0].High_Level_Target__c = 20000;
      lstBundles[0].Promo_Start_Date__c = Date.today().addDays(1);
      lstBundles[0].Promo_End_Date__c = Date.today().addDays(30);
      lstBundles[0].Account_Split_Template__c = null;
      lstBundles[0].Campaign_Type__c = 'New Release';
      lstBundles[0].Pricing_Account__c = lstAccounts[1].Id;
    
      insert lstBundles;

    //lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
    // lstBundles;

    // Create a list of bundle products
    lstBundleProducts = new List<Bundle_Product__c>();
    // Add products to bundle (100 Products)
    for (Integer i=0; i < lstProducts.size(); i++) {
      Bundle_Product__c bProd = new Bundle_Product__c();
      bProd.Bundle__c = lstBundles[0].Id;
      bProd.Product__c = lstProducts[i].Id;
      bProd.List_Price__c = 20;
      bProd.Assortment_Price__c = 15;
      bProd.Share__c = 10;
      lstBundleProducts.add(bProd);
    }
    // Insert Assortment Products
    insert lstBundleProducts;

    // Create a list of bundle products
    lstBundleAccounts = new List<Assortment_Account__c>();
    // Add products to bundle (100 Products)
    for (Integer i=1; i < lstAccounts.size(); i++) {
      Assortment_Account__c bAcc = new Assortment_Account__c();
      bAcc.Assortment__c = lstBundles[0].Id;
      bAcc.Account__c = lstAccounts[i].Id;
      bAcc.Share__c = 10;
      bAcc.send_to_OTC__c = true;
      lstBundleAccounts.add(bAcc);
    }
    // Insert Assortment Products
      insert lstBundleAccounts;
    
      CRM_ValidateAssortmentCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      system.assertEquals(true,CRM_ValidateAssortmentCtrl.raisealert);
      
      Test.stopTest();
    }
    
   static testmethod void test_convertDateToString() {
        Test.StartTest();
        CRM_ValidateAssortmentCtrl.convertDateToString(System.Today());
        CRM_ValidateAssortmentCtrl.convertDateToString(Null);
        Test.StopTest();        
    }
    
    static testmethod void test_getLineItems(){
        Test.StartTest();
        setupTestData();
        CRM_ValidateAssortmentCtrl.getLineItems(lstBundles[0].id);        
        Test.StopTest();
    }
    
}