/**
 * @Author Cognizant
 * @name CRM_AssortmentApprovalCtrl_Test
 * @CreateDate 13 July 2016
 * @Description Test class for CRM_AssortmentApprovalCtrl
 * @Version <1.0>
 */
@isTest
private class CRM_AssortmentApprovalCtrl_Test {
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
    
    //Insert Configs 
    List<Config__c> lstConfig = new List<Config__c>();
    Config__c config = new Config__c();
    config.Assortment__c = lstBundles[0].Id;
    //config.SBOM_Product__c = lstProduct[0].Id;
    lstConfig.add(config);
    insert lstConfig;
    
    }
    
    static testmethod void test_validateAssortmentNoOverlapingNoRefresh() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_AssortmentApproval);
      Test.setCurrentPage(Page.CRM_AssortmentApproval); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_AssortmentApprovalCtrl controller = new CRM_AssortmentApprovalCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      //CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      lstBundles[0].Campaign_Type__c = 'New Release'; //CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL;
      update lstBundles;
      //CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);

      Id[] listAssortmentIds = new Id[]{lstBundles[0].Id};
      List<Bundle_Product__c> bundleProductList = [select Assortment_Price__c from Bundle_Product__c];
      for(Bundle_Product__c bp : bundleProductList) {
         bp.Assortment_Price__c = 12;
      }
      update bundleProductList;
      List<Assortment_Account__c> lstBundleAccounts1 = [select send_to_OTC__c from Assortment_Account__c];
      for(Assortment_Account__c bAcc : lstBundleAccounts1){
         bAcc.send_to_OTC__c = true;
      }
      update lstBundleAccounts1;
      try{
          CRM_AssortmentApprovalCtrl.refreshProductPrices(listAssortmentIds);
          //system.assertEquals(false,CRM_AssortmentApprovalCtrl.raisealert);
      }
      catch(Exception e){
        //system.assertEquals(Label.CRM_Validation_msg_prices_are_upto_date, e.getmessage());
      }
      delete [Select Id from Assortment_Account__c];
      try{
          CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      }
      catch(Exception e){
        //system.assertEquals(Label.CRM_No_Accounts_found_for_assortment, e.getmessage());
      }
      delete [Select Id from Bundle_Product__c];
      try{
          CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      }
      catch(Exception e){
        //system.assertEquals(Label.CRM_No_Products_found_for_assortment, e.getmessage());
      }
      try{
          CRM_AssortmentApprovalCtrl.refreshProductPrices(listAssortmentIds);
      }
      catch(Exception e){
        //system.assertEquals(Label.CRM_No_Products_found_for_assortment, e.getmessage());
      }
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      User testUser = new User(Alias = 'wbappr', Email='wbcrmstandarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmapprovass@testorg.com'+String.valueOf(Math.random()),ByPassValidationRule__c =true);
    
      System.runAs(testUser) {
         lstBundles[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_APPROVED;
         update lstBundles;
      }
      try{
          CRM_AssortmentApprovalCtrl.refreshProductPrices(listAssortmentIds);
      }
      catch(Exception e){
        //system.assertEquals(Label.CRM_Approved_assortment_cannot_be_edited_validated, e.getmessage());
      }
      try{
          CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      }
      catch(Exception e){
        //system.assertEquals(Label.CRM_Assortment_is_not_in_Draft_Stage, e.getmessage());
      }
      Test.stopTest();
    }
    
    static testmethod void test_validateAssortmentNoOverlapingWithRefresh() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_AssortmentApproval);
      Test.setCurrentPage(Page.CRM_AssortmentApproval); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_AssortmentApprovalCtrl controller = new CRM_AssortmentApprovalCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      
      Id[] listAssortmentIds = new Id[]{lstBundles[0].Id};
      
      List<Pricebook_Entry_Period__c> pbeplist = [select List_Price__c from Pricebook_Entry_Period__c];
      for(Pricebook_Entry_Period__c pbep : pbeplist) {
         pbep.List_Price__c = 10;
      }
      update pbeplist;
      
      CRM_AssortmentApprovalCtrl.refreshProductPrices(listAssortmentIds);
      List<Bundle_Product__c> bundleProductList = [select Assortment_Price__c,List_Price__c from Bundle_Product__c where Bundle__c = : lstBundles[0].Id ];
      for(Bundle_Product__c bp : bundleProductList) {
         //system.assertEquals(10,bp.Assortment_Price__c);
         //system.assertEquals(10,bp.List_Price__c);
      }
      CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      //system.assertEquals(false,CRM_AssortmentApprovalCtrl.raisealert);
      //system.assertEquals(CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL,[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
      Test.stopTest();
    }
    
    static testmethod void test_validateAssortmentNoOverlapingShareperError() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_AssortmentApproval);
      Test.setCurrentPage(Page.CRM_AssortmentApproval); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_AssortmentApprovalCtrl controller = new CRM_AssortmentApprovalCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      
      Id[] listAssortmentIds = new Id[]{lstBundles[0].Id};
      
      List<Bundle_Product__c> bundleProductList = [select Id,Share__c from Bundle_Product__c where Bundle__c = : lstBundles[0].Id ];
      for(Bundle_Product__c bp : bundleProductList) {
         bp.Share__c = 100;
         bp.Automatically_Add_Product__c = true;
      }
      update bundleProductList;
      try{
         CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
         //system.assertEquals(false,CRM_AssortmentApprovalCtrl.raisealert);
      }
      catch(Exception e){
        //system.assertEquals(Label.CRM_Assortment_Product_Share_Percent_should_be_100_or_0, e.getmessage());
      }
      Test.stopTest();
    }
    
     static testmethod void test_validateAssortmentOverlaping() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_AssortmentApproval);
      Test.setCurrentPage(Page.CRM_AssortmentApproval); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_AssortmentApprovalCtrl controller = new CRM_AssortmentApprovalCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      
      //lstBundles[0].Campaign_Type__c = CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL;
      //update lstBundles;
      CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      //system.assertEquals(CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL,[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
      
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
    
       //Insert Configs 
       List<Config__c> lstConfig1 = new List<Config__c>();
       Config__c config1 = new Config__c();
       config1.Assortment__c = lstBundles[0].Id;
       //config.SBOM_Product__c = lstProduct[0].Id;
       lstConfig1.add(config1);
       insert lstConfig1;
       
      CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      //system.assertEquals(true,CRM_AssortmentApprovalCtrl.raisealert);
      //system.assertEquals('Draft',[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
      
      Test.stopTest();
    }
    
    
    static testmethod void test_validateAssortmentOverlapingNotNational() {
      setupTestData();
      
      Test.setCurrentPageReference(Page.CRM_AssortmentApproval);
      Test.setCurrentPage(Page.CRM_AssortmentApproval); 
      Test.startTest();
      Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
      CRM_AssortmentApprovalCtrl controller = new CRM_AssortmentApprovalCtrl(stdCon);
      system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);
      
      lstBundles[0].Campaign_Type__c = 'New Release';
      update lstBundles;
      
      try{
         CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
     }
     catch(Exception e){
         //system.assertEquals(Label.CRM_Assort_Approval_Atleast_One_Account_Send_to_OTC, e.getmessage());
     }
      
      for(Assortment_Account__c bAcc : lstBundleAccounts){
         bAcc.send_to_OTC__c = true;
      }
      update lstBundleAccounts;
      
      CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      //system.assertEquals(CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL,[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
      
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
    
     try{
         CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
     }
     catch(Exception e){
         //system.assertEquals(Label.CRM_Submit_for_approval_error_for_no_config, e.getmessage());
     }
     
       //Insert Configs 
      List<Config__c> lstConfig2 = new List<Config__c>();
      Config__c config2 = new Config__c();
      config2.Assortment__c = lstBundles[0].Id;
      //config.SBOM_Product__c = lstProduct[0].Id;
      lstConfig2.add(config2);
      insert lstConfig2;
    
      CRM_AssortmentApprovalCtrl.getOverlappingAssProducts(lstBundles[0].Id);
      //system.assertEquals(true,CRM_AssortmentApprovalCtrl.raisealert);
      //system.assertEquals('Draft',[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
      
      Test.stopTest();
    }
    
    
    static testmethod void test_convertDateToString() {
        Test.StartTest();
        CRM_AssortmentApprovalCtrl.convertDateToString(System.Today());
        CRM_AssortmentApprovalCtrl.convertDateToString(Null);
        Test.StopTest();        
    }
    
    static testmethod void test_getLineItems(){
        Test.StartTest();
        setupTestData();
        CRM_AssortmentApprovalCtrl.getLineItems(lstBundles[0].id);        
        Test.StopTest();
    }
     static testmethod void test_SubmitForApprovalFunction(){
        setupTestData();
        
        Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
        CRM_AssortmentApprovalCtrl controller = new CRM_AssortmentApprovalCtrl(stdCon);
        system.currentPageReference().getParameters().put('Id', lstBundles[0].Id);  
        //system.assertEquals(false,controller.isAssortBexCampaignType);
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'Test BX';
        pb.Currency__c = 'USD';
        pb.External_Id__c = '6007-10';
        //pb.External_Id__c = '6004-10';
        pb.Business_Unit__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        //pb.Business_Unit__c = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
        insert pb;
        
        lstBundles[0].Campaign_Type__c = 'Trade Promotion';
        lstBundles[0].Price_Book__c = pb.id;
        update lstBundles;
        
        //system.assertEquals('Draft',[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
        Test.startTest();
            CRM_AssortmentApprovalCtrl.SubmitAssortmentForApproval(lstBundles[0].Id);
        Test.stopTest();
        
        //system.assertEquals('Awaiting Approval',[Select Assortment_Status__c from Bundle__c where id =:lstBundles[0].Id][0].Assortment_Status__c);
    }
    
}