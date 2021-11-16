/**
   @Author Cognizant
   @name CRM_AddOrderProductsFromConfigCtrl_Test
   @CreateDate 21 June 2016
   @Description Test class for CRM_AddOrderProductsFromConfigController
   @Version <1.0>
   @reference Requirement no 85 France
  */

@isTest 
private class CRM_AddOrderProductsFromConfigCtrl_Test{


 /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    */
    
     static void createTestData() {
     /*Creating Account Record*/
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        lstAccounts[0].RecordTypeID = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        lstAccounts[0].Planning_Customer__c = True;
        lstAccounts[0].Status__c = 'N';
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE ;
        upsert lstAccounts;
        
    /* Creating Assortment(Bundles) of two types one of type campaign and other new release*/
        List<Bundle__c> lstAssort = CRM_TestDataFactory.createBundles(2,false);
        lstAssort[0].RecordTypeID = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
        lstAssort[1].RecordTypeID = CRM_RecordTypeUtil.RT_Promotional_Assortment; //[select id,Name from RecordType where SobjectType='Bundle__c' and Name='New Release Assortment' Limit 1].ID;
        upsert lstAssort;
    
    /*Creating Product Group and Product*/
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        system.assertNotEquals(null, lstProductGroup[0].id);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false); 
        System.assertEquals(1, lstProduct.size());
        for (Product2 prod : lstProduct) {
            prod.ProductCode = '1000230554';
            prod.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prod.Product_Format__c = '4';
            prod.Product_Rating__c = 'UK - Minimum 12 Ye';
            prod.Product_Genre__c = 'ACTION';
            prod.Release_Category__c = '23';
            prod.Franchise_Type__c = 'X4';
            prod.Product_Language_Code__c = 'SR';
            prod.SAP_Dist_chain_product_Status__c = '11';
            prod.Type__c = 'Video Physical';
            prod.Recommended_Price__c = 150;
         }
         upsert lstProduct;
         
    /*Creating Bundle Products*/
    List<Bundle_Product__c> bundleProdList = new List<Bundle_Product__c>();
    bundleProdList = CRM_TestDataFactory.createBundleProducts(lstAssort,lstProduct,1, true);
       
                    
    /*Creating Pricebook and Pricebook Entry Period*/
          List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
          system.assertNotEquals(null, lstPriceBookEntries[0].id);
          List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true); 
          system.assertNotEquals(null, lstPriceBookEntryPeriod[0].id);
        
        
    /*Create Config Associated with Assortment*/    
        Config__c conf =  CRM_TestDataFactory.createConfig(lstAssort[0]);
        List<Config__c> lstConf = new List<Config__c>();
        lstConf.add(conf);
        insert lstConf;
        system.assertNotEquals(null, lstConf[0].id);
         
    /*Creating Config Products*/ 
        Config_Product__c confProd = new Config_Product__c();    
        confProd.Config__c = lstConf[0].id;
        confProd.Product__c = lstProduct[0].id;
        confProd.Quantity__c = 2;
        insert confProd; 
        system.assertNotEquals(null, confProd.id);  
     /*Creating Deal - 3 type : One without assortment, one with assortment but of not campaign type and last 
       with assortment of type campaign */         
        List<Opportunity> lstOpp = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,3,false);
        lstOpp[1].Bundle__c= lstAssort[0].id; // assortment with campaign type
        lstOpp[2].Bundle__c = lstAssort[1].id;//assortment without campaign type
        insert lstOpp;
        for(Opportunity opp: lstOpp){
        Opp.Last_Published_Date__c = System.today();
        Opp.Sales_Org__c = '6007';
        Opp.StageName = 'Committed';
        }
        update lstOpp;
        system.assertNotEquals(null, lstOpp[0].id);
         
     }
     
     
    /**Scenario 1
    *  Generate Order for Deal without any assortment. 
    *  @name generateOrder
    *  @param None
    *  @return None
    *  @throws None
    * 
    */
     static testMethod void generateOrder(){
        createTestData();         
         Opportunity Opp = [SELECT Id,name,Bundle__c FROM Opportunity WHERE Bundle__c =: null LIMIT 1];
         system.assertNotEquals(null, Opp.id);
         Test.setCurrentPageReference(new PageReference('Page.CRM_AddOrderProductsFromConfig'));
         ApexPages.StandardController sc = new ApexPages.StandardController(Opp);
         //CRM_AddOrderProductsFromConfigController ctrl = new CRM_AddOrderProductsFromConfigController(sc); 
         CRM_AddOrderProductsFromConfigController.initCheck(Opp.Id);
         system.assertNotEquals(null,[SELECT Id FROM Order WHERE OpportunityId =: Opp.id]);
         
     }
     
   /** Scenario 2
    *  Generate Order for Deal with assortment but not of type campaign. 
    *  @name generateOrderWithAssortNotCamp
    *  @param None
    *  @return None
    *  @throws None
    * 
    */
     static testMethod void generateOrderWithAssortNotCamp(){
          createTestData();
          Opportunity Opp = [SELECT Id,Name,Bundle__c FROM Opportunity WHERE Bundle__c !=:null AND
                             Bundle__r.RecordType.DeveloperName !=: 'Campaign_Assortment' LIMIT 1];
          system.assertNotEquals(null,Opp.id);
          Test.setCurrentPageReference(new PageReference('Page.CRM_AddOrderProductsFromConfig'));
          ApexPages.StandardController sc = new ApexPages.StandardController(Opp);
          //CRM_AddOrderProductsFromConfigController ctrl = new CRM_AddOrderProductsFromConfigController(sc); 
          CRM_AddOrderProductsFromConfigController.initCheck(Opp.Id);
          system.assertNotEquals(null,[SELECT Id FROM Order WHERE OpportunityId =: Opp.id]);
                              
      }
      
   /** Scenario 3
    * Generate Order for Deal with assortment of type campaign. 
    *  @name generateOrderWithAssortCamp
    *  @param None
    *  @return None
    *  @throws None
    * 
    */ 
    
    static testMethod void generateOrderWithAssortCamp(){
          createTestData();
          Opportunity Opp = [SELECT Id,Name,Bundle__c FROM Opportunity WHERE Bundle__c !=:null AND
                             Bundle__r.RecordType.DeveloperName =: 'Campaign_Assortment' LIMIT 1];
          system.assertNotEquals(null,Opp.id);
          Test.setCurrentPageReference(new PageReference('Page.CRM_AddOrderProductsFromConfig'));
          ApexPages.StandardController sc = new ApexPages.StandardController(Opp);
          //CRM_AddOrderProductsFromConfigController ctrl = new CRM_AddOrderProductsFromConfigController(sc); 
          CRM_AddOrderProductsFromConfigController.initCheck(Opp.Id);
          List<Order> lstOdr = [SELECT Id FROM Order WHERE OpportunityId =: Opp.Id];
          system.assertEquals(0,lstOdr.size());//No Order Should Get Created
          List<CRM_AddOrderProductsFromConfigController.Config>  lstconfigs = new List<CRM_AddOrderProductsFromConfigController.Config>();
          lstconfigs = CRM_AddOrderProductsFromConfigController.getConfig(Opp.Bundle__c);//Calling Remote Method                    
          system.assertNotEquals(null,lstconfigs);//It should return only 1 config refer create data.
          system.assertEquals(1,lstconfigs.size());
          
          Config__c conf = [SELECT Id FROM Config__c WHERE Assortment__c =: Opp.Bundle__c LIMIT 1];
          
          /*Calling generate Order Function*/
           PageReference orderPage;
           orderPage = CRM_AddOrderProductsFromConfigController.generateOrder(conf.id,Opp.id);
           system.assertNotEquals(null,orderPage);
           lstOdr = [SELECT Id FROM Order WHERE OpportunityId =: Opp.Id];
           system.assertNotEquals(0,lstOdr.size());//Now Order Should Get Created
           system.assertNotEquals(null,lstOdr[0].id);
           List<Config_Product__c> lstConfProd = [SELECT Id FROM Config_Product__c WHERE Config__c =: conf.Id];
           system.assertNotEquals(0,lstConfProd.size());
           system.assertNotEquals(null,lstConfProd[0].id);
    } 
    
     /** Scenario 4
    * Generate Config Product for Config with product not added to assortment. 
    *  @name validateConfigProduct
    *  @param None
    *  @return None
    *  @throws None
    * 
    */ 
    static testMethod void validateConfigProduct(){
    createTestData();
    List<Product_Group__c> lstProductGroup = [SELECT ID,Name FROM Product_Group__c];
    List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false);
    for (Product2 prod : lstProduct) {
            prod.ProductCode = '1000230990';
            prod.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prod.Product_Format__c = '4';
            prod.Product_Rating__c = 'UK - Minimum 12 Ye';
            prod.Product_Genre__c = 'ACTION';
            prod.Release_Category__c = '23';
            prod.Franchise_Type__c = 'X4';
            prod.Product_Language_Code__c = 'SR';
            prod.SAP_Dist_chain_product_Status__c = '11';
            prod.Type__c = 'Video Physical';
            prod.Recommended_Price__c = 150;
         }
      upsert lstProduct;
      List<Config__c> lstConfig = [SELECT id,Name FROM Config__c LIMIT 1];
      
      try{
      
        Config_Product__c confProd = new Config_Product__c();    
        confProd.Config__c = lstConfig[0].id;
        confProd.Product__c = lstProduct[0].id;
        confProd.Quantity__c = 2;
        insert confProd;
        //throw new MyException('An exception should have been thrown by the trigger but was not.');  
      }
      
      catch(Exception e)
        {
        Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.CRM_Config_Product_not_available_in_assortment) ? true : false;
        System.AssertEquals(expectedExceptionThrown, true);
        } 
     
    }     

}