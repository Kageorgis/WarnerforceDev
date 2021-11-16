/**
   @Author Cognizant
   @name CRM_AddConfigProductsControllerTest
   @CreateDate 6th June 2016
   @Description Test class for CRM_AddConfigProductsController
   @Version <1.0>
  */
@isTest
private class CRM_AddConfigProductsControllerTest{
    static List<Product2> lstProduct;
    static List<Config__c> lstConfig;
    static List<Bundle_Product__c> lstBundlesProduct;
    /**
    *  Create Test Data.
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    */

    static void createTestData() {
         List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
         lstAccounts[0].RecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
         upsert lstAccounts;

         List<Bundle__c> lstBundles = CRM_TestDataFactory.createBundles(1, true);

         List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
         //System.assertNotEquals(null,lstProductGroup[0].id);
         lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 200, false);
         
         //System.assertEquals(200, lstProduct.size());
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
         //lstProduct[0].Exclusive_Customer__c = lstAccounts[0].Id;
         insert lstProduct;
         //System.assertNotEquals(null,lstProduct[0].id);

         CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
         CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
         
         lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstBundles, lstProduct, 1, true);

         lstConfig = new List<Config__c>();
         Config__c config = new Config__c();
         config.Assortment__c = lstBundles[0].Id;
         //config.SBOM_Product__c = lstProduct[0].Id;
         lstConfig.add(config);
         insert lstConfig;
         //System.assertNotEquals(null,lstConfig[0].id);
    }

    /**     *  Test 2: Test to add new Config product.
    *  Expected: New Config products should be added
    *  @name addConfigProduct
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get     */

    static testMethod void addConfigProduct(){

        createTestData();
        User u = [Select Id from User 
            where Profile.Name = 'System Administrator' and isActive = true and ByPassValidationRule__c = false Limit 1];
        
        System.runAs(u){
            Test.startTest();
            
            Config__c currentConfig = lstConfig[0];
            
            Bundle_Product__c assortmentProduct = lstBundlesProduct[0];   
            
            ApexPages.StandardController sc = new ApexPages.StandardController(currentConfig);
            Test.setCurrentPageReference(Page.CRM_AddConfigProducts);
            CRM_AddConfigProductsController ctrl = new CRM_AddConfigProductsController(sc);
            
            CRM_AddConfigProductsController.ConfigProduct[] configProduct = CRM_AddConfigProductsController.getConfigProducts(currentConfig.Id);
            
            System.assertEquals(configProduct.size(), lstProduct.size(),'All the UNBW products should be returned from get method');
            
            // select all the products
            for(CRM_AddConfigProductsController.ConfigProduct cp : configProduct) {
                cp.isSelected = true;
            }
                            
            CRM_AddConfigProductsController.setConfigProducts(currentConfig.Id, configProduct);
            
            System.assertEquals([Select count() FROM Config_Product__c where Config__c =:currentConfig.Id], configProduct.size(),'Config Product Inserted');
            
            configProduct[0].isSelected = false;
            CRM_AddConfigProductsController.setConfigProducts(currentConfig.Id, configProduct);
            System.assertEquals([Select count() FROM Config_Product__c where Config__c =:currentConfig.Id ], configProduct.size()-1,'1 Config Product should be removed');
            
            Test.stopTest();
         }
    }

}