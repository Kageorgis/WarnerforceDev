@isTest
private class CRM_BOMConfigProductHandler_Test {
    static BOM__c[] listBOMs;
    static Product2 parentBOMProd;
    static List<Product2> lstProducts;
    static List<Bundle__c> lstBundles;
    static List<Bundle_Product__c> lstBundleProducts;
    static Config__c sbomConfig;
        
    static void setupTestData() {
        // Insert Account
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert lstAccounts;
        
        // Create Products
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 50, false);
        
        // update all 50 product records
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
             lstProducts[i].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_UNBW; //PRODUCT_MATERIAL_TYPE_FERT;
             lstProducts[i].Pack_Type__c = CRM_AppConstants.PRODUCT_PACK_TYPE_MultiPack;
         }
         insert lstProducts;
         
        CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        lstBundles = CRM_TestDataFactory.createBundles(1, true);
        
        // Create a list of bundle products
        lstBundleProducts = new List<Bundle_Product__c>();

        // Add products to bundle (40 Products)
        for (Integer i=1; i < lstProducts.size(); i++) {
            Bundle_Product__c bProd = new Bundle_Product__c();
            bProd.Bundle__c = lstBundles[0].Id;
            bProd.Product__c = lstProducts[i].Id;
            lstBundleProducts.add(bProd);
        }
        
        // make first product as parent SBOM product
        insert lstBundleProducts;
        
        parentBOMProd = lstProducts[1];  
        system.assertEquals(lstProducts[1].Id, parentBOMProd.Id);
        
        listBOMs = new BOM__c[]{};
        
        // Add next 4 products as child BOM products for the parent SBOM product
        for (Integer i=1; i < 5 ; i++) {
            BOM__c bomRec = new BOM__c();
            bomRec.Parent_Product__c = parentBOMProd.Id ;
            bomRec.Child_Product__c = lstProducts[i].Id;
            bomRec.Quantity__c = 5;
            listBOMs.add(bomRec);
        }
        
        // insert the list of BOM and Bundle Product Records
        insert listBOMs;
        
        //Change the SAP MT to SBOM to insert Config.
        parentBOMProd.SAP_Material_Type__c = CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE;
        upsert parentBOMProd;
        
        //Create a new SBOM config record with the SBOM Product
        sbomConfig = new Config__c();
        sbomConfig.Assortment__c = lstBundles[0].Id;
        sbomConfig.RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_SBOM;
        sbomConfig.SBOM_Product__c = parentBOMProd.Id;        
        insert sbomConfig; 
    }
    
    // Test method for defect no : 3686
    static testmethod void test_NewBOMInsert() {
        setupTestData();
        
        Test.startTest();
        
        System.assertEquals(5, [Select count() FROM Config_Product__c where Config__c =:sbomConfig.Id],'All 4 child and 1 parent SBOM products must be added to the config.');
        
        //Update BOM Quantity
        BOM__c bomRec = listBOMs[0];
        bomRec.Quantity__c = 10;
        Update bomRec;
        
        List<Config_Product__c> configPro = [Select Quantity__c  FROM Config_Product__c where Related_BOM__c =: bomRec.Id Limit 1];
        //Assert SBOM Config Product Quantity Sync with related BOM Quantity
        System.assertEquals(configPro[0].Quantity__c,10);
        
        Test.stopTest();
    }
    
    /*static testmethod void test_ExstingBOMDelete() {
        setupTestData();
        
        Test.startTest();
        // Delete the last BOM record from List
        delete listBOMs[listBOMs.size() -1];
        
        System.assertEquals(4, [Select count() FROM Config_Product__c where Config__c =:sbomConfig.Id],'Config Product should be deleted on BOM deletion.');
        Test.stopTest();
    }*/
    
    //Req. #393 (FR): If BOM record is inserted with a Parent Product, update Parent Product Material Type to SBOM
    static testmethod void test_updateProductMaterialType() {
        setupTestData();
        
        Test.startTest();
        
        //If BOM record is inserted with a Parent Product, update Parent Product Material Type to SBOM
        List<Product2> product = [Select Id, SAP_Material_Type__c From Product2 where Id =: parentBOMProd.Id];
        System.assertEquals(CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE, product[0].SAP_Material_Type__c, 'Product SAP MT should be SBOM');
        
        Test.stopTest();
    }
    
    
    /**
    *  @name test_DeleteBOMMethod
    *  @param None
    *  @return None
    *  @throws None  
    */
    static testmethod void test_DeleteBOMMethod() {
        setupTestData();
        Integer bomCountFlag = 0;
        
        system.assertEquals(4,[select Count() from BOM__c]);
        
        Test.StartTest();
        for (BOM__c bomRec: listBOMs){
            bomRec.Delete_Record__c = true;
            bomCountFlag ++;
        }
        
        Update listBOMs;
        Test.StopTest();
        
        system.assertEquals(0,[select Count() from BOM__c]);
        
        
        try{
          integer i = 1/0;
        }        
        catch(Exception e){
            CRM_BOMConfigProductHandler.logAnException(e,lstProducts[0].id);
        }
        
    }
}