@isTest
private class CRM_AddConfigToOrderControllerTest{
    
    static List<Bundle_Product__c> lstBundlesProduct;
    static List<Product2> lstProduct;
    static List<Order> lstOrders;
    static List<Assortment_Account__c> lstBundleAccounts;
    static List<Config__c> lstConfig;
    static List<Bundle_Product__c> lstBundleProducts;
    static List<Bundle__c> lstBundles;
    
    static void createTestData() {
         
         List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
         lstAccounts[0].RecordTypeID = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
         //lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
         //lstAccounts[0].Status__c = 'N';
         lstAccounts[0].Planning_Customer__c = True;
         upsert lstAccounts;  
         
        system.assertEquals(1, lstAccounts.size());
            
         lstOrders = CRM_TestDataFactory.createOrders(lstAccounts, 2, true);
         
         lstBundles = CRM_TestDataFactory.createBundles(1, true);
         lstBundles[0].RecordTypeId = CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;         
         upsert lstBundles;
                 
         List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);         
         lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 100, false);         
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
             prod.Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
             prod.Recommended_Price__c = 150;
             prod.SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_UNBW;
         }
         
         insert lstProduct;         
         
         //lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstBundles, lstProduct, 1, true);
         
         List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
         CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
         
         lstBundleAccounts = new List<Assortment_Account__c>();           
              Assortment_Account__c bAcc = new Assortment_Account__c();
              bAcc.Assortment__c = lstBundles[0].Id;
              bAcc.Account__c = lstAccounts[0].Id;
              bAcc.Share__c = 10;
              lstBundleAccounts.add(bAcc);
            // Insert Assortment Products
            insert lstBundleAccounts;
        
            system.assertEquals(1, lstBundleAccounts.size());
            
            
            
        
            lstBundleProducts = new List<Bundle_Product__c>();
            // Add products to bundle (100 Products)
            for (Integer i=0; i < lstProduct.size(); i++) {
              Bundle_Product__c bProd = new Bundle_Product__c();
              bProd.Bundle__c = lstBundles[0].Id;
              bProd.Product__c = lstProduct[i].Id;
              bProd.List_Price__c = 20;
              bProd.Assortment_Price__c = 20;
              bProd.Share__c = 0;
              lstBundleProducts.add(bProd);
            }
            // Insert Assortment Products
            insert lstBundleProducts;
            
            
            lstConfig = new List<Config__c>();
            
            Config__c config = new Config__c();
            config.Assortment__c = lstBundles[0].Id;  
            config.RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_VRAC;   
                  
            lstConfig.add(config);
            
            if(!lstConfig.isEmpty()){
                insert lstConfig;
            }
        
            Config_Product__c confProd = new Config_Product__c();    
            confProd.Config__c = lstConfig[0].id;
            confProd.Product__c = lstProduct[0].id;
            confProd.Quantity__c = 2;           
            insert confProd; 
    }
    
    static testMethod void addConfig(){
        createTestData();
        User u = [Select Id from User 
            where Profile.Name = 'System Administrator' and isActive = true and ByPassValidationRule__c = false Limit 1];
        
        System.runAs(u){
            Test.startTest();
            
            Config__c currentConfig = lstConfig[0];
            List<Id> configIds = new List<Id>();
            configIds.add(currentConfig.id);
            
            Apexpages.StandardController stdCon = new Apexpages.StandardController(lstBundles[0]);
            CRM_AddConfigToOrderController ctrl=new CRM_AddConfigToOrderController(stdCon);             
            Config__c[] configLst = CRM_AddConfigToOrderController.getConfigs(lstOrders[0].id);
            
            system.debug('order list 3-->'+lstOrders[0].AccountId);
            system.debug([Select count() FROM Config__c where Id=:currentConfig.id] + 'query result');
            system.debug('actual result'+configLst.size());
            CRM_AddConfigToOrderController.addConfig(lstOrders[0].id,configIds);
            
            system.assertEquals([Select count() FROM Config__c where Id=:currentConfig.id],configLst.size());            
            
                        
            Test.stopTest();
            
        }    
    }

}