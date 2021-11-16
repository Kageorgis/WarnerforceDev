/**
 * @Author Cognizant
 * @name CRM_SyncConfigProductsHelperTest
 * @CreateDate 16th June 2016
 * @Description Test class for CRM_SyncConfigProductsHelper
 * @Version <1.0>
 **/
@isTest(SeeAllData=false)
private class CRM_SyncConfigProductsHelperTest {
    static List<Bundle__c> lstBundles;
    static List<Bundle_Product__c> lstBundleProducts;
    static Product2 parentBOMProd;

    private static void setupTestData() {
        // Insert Account
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert lstAccounts;

        // Create Products
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 100, false);
        
        // update all 100 product records
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
         
         //New Line of Code Product Assigned should be of type SBOM.
         lstProducts[0].SAP_Material_Type__c ='SBOM';
         insert lstProducts;

        CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);

        lstBundles = CRM_TestDataFactory.createBundles(1, true);

        // Create a list of bundle products
        lstBundleProducts = new List<Bundle_Product__c>();

        // Add products to bundle (95 Products)
        for (Integer i=0; i < lstProducts.size(); i++) {
            Bundle_Product__c bProd = new Bundle_Product__c();
            bProd.Bundle__c = lstBundles[0].Id;
            bProd.Product__c = lstProducts[i].Id;
            lstBundleProducts.add(bProd);
        }

        parentBOMProd = lstProducts[0];
        
        BOM__c[] listBOMs = new BOM__c[]{};
        for (Integer i=1; i < 5 ; i++) {
            BOM__c bomRec = new BOM__c();
            bomRec.Parent_Product__c = parentBOMProd.Id ;
            bomRec.Child_Product__c = lstProducts[i].Id;
            bomRec.Quantity__c = 5;
            listBOMs.add(bomRec);
        }
        
        insert listBOMs;
        insert lstBundleProducts;
    }

    static testmethod void test_NewVRACConfigInsert() {
        setupTestData();
        
        Test.startTest();
        Config__c vracConfig = new Config__c();
        vracConfig.Assortment__c = lstBundles[0].Id;
        vracConfig.RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_VRAC;
        insert vracConfig;
        
        System.assertEquals([Select count() FROM Config_Product__c where Config__c =:vracConfig.Id], 99,'All 95 products should be auto added to the VRAC-Config');
        
        // Now add an assortment product of VRAC type to the assortment.
        // expected result is system should auto add the VRAC product as config product as well

        Bundle_Product__c lastAssortmentProduct = lstBundleProducts[lstBundleProducts.size()-1];
        system.debug('lastAssortmentProduct--->'+lastAssortmentProduct);
        delete lastAssortmentProduct;
        System.assertEquals([Select count() FROM Config_Product__c where Config__c =:vracConfig.Id], 98 ,'Deleting an Assortment Product (FERT) should also delete the VRAC config Product.');
        
        lastAssortmentProduct.Id = null;
        insert lastAssortmentProduct;
        System.assertEquals([Select count() FROM Config_Product__c where Config__c =:vracConfig.Id], 99,'Adding an Assortment Product (FERT) should also add the VRAC config Product.');
        
        Test.stopTest();
    }
    
    static testmethod void test_NewSBOMConfigInsert() {
        setupTestData();
        
        Test.startTest();
        
        Config__c sbomConfig = new Config__c();
        sbomConfig.Assortment__c = lstBundles[0].Id;
        sbomConfig.RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_SBOM;
        sbomConfig.SBOM_Product__c = parentBOMProd.Id;
        insert sbomConfig;
        
        System.assertEquals([Select count() FROM Config_Product__c where Config__c =:sbomConfig.Id], 5 ,'5 products should be auto added to the SBOM-Config');
        
        Test.stopTest();
    }
    
    static testmethod void test_ConfigProductDelete(){
        setupTestData();
        
        Test.startTest();
        
        Config__c sbomConfig = new Config__c();
        sbomConfig.Assortment__c = lstBundles[0].Id;
        sbomConfig.RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_SBOM;
        sbomConfig.SBOM_Product__c = parentBOMProd.Id;
        insert sbomConfig;
        
        List<Config_Product__c> lstConfigProductOfTypeSBOM = [Select Id From Config_Product__c];
        try{
            Delete lstConfigProductOfTypeSBOM ;
        }catch(System.dmlexception de){
            String errorMessage = de.getDmlMessage(0);
            system.assert(errorMessage.contains('You can not delete Config Products of type SBOM or FERT'));
        }
        
        Test.stopTest();
    }
}