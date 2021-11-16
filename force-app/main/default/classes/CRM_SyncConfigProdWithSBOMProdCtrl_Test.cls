/**
   @Author Cognizant
   @name CRM_SyncConfigProdWithSBOMProd_Test
   @CreateDate 21 September 2016
   @Description - test class of CRM_SyncConfigProdWithSBOMProd  
   @Version <1.0>
*/
@isTest(SeeAllData=false)
public class CRM_SyncConfigProdWithSBOMProdCtrl_Test{
    
    static Product2 parentBOMProd;
    static List<Product2> lstProducts;
    static Config__c sbomConfig;
        
    static void setupTestData() {
        // Insert Account
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        insert lstAccounts;
        
        // Create Products
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 10, false);
        
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
        
        List<Bundle__c> lstBundles = CRM_TestDataFactory.createBundles(1, true);
        
        // Create a list of bundle products
        List<Bundle_Product__c> lstBundleProducts = new List<Bundle_Product__c>();

        // Add products to bundle (10 Products)
        for (Integer i=1; i < lstProducts.size() - 1 ; i++) {
            Bundle_Product__c bProd = new Bundle_Product__c();
            bProd.Bundle__c = lstBundles[0].Id;
            bProd.Product__c = lstProducts[i].Id;
            lstBundleProducts.add(bProd);
        }
        
        // make first product as parent SBOM product
        insert lstBundleProducts;
        
        parentBOMProd = lstProducts[0];  
        system.assertEquals(lstProducts[0].Id, parentBOMProd.Id);
        
        List<BOM__c> listBOMs = new List<BOM__c>();
        
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
    
     /**
    *  Test 1
    *  @name test_NewBOMInsert
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void test_NewBOMInsert() {
        setupTestData();
        
        Test.startTest();
        System.assertEquals(5, [Select count() FROM Config_Product__c where Config__c =:sbomConfig.Id],'All 4 child and 1 parent SBOM products must be added to the config.');
        
        // insert a new BOM record for the same parent SBOM product record
        BOM__c bomRec = new BOM__c();
        bomRec.Parent_Product__c = parentBOMProd.Id ;
        bomRec.Child_Product__c = lstProducts[5].Id;
        bomRec.Quantity__c = 15;
        insert bomRec;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(sbomConfig);
        CRM_SyncConfigProdWithSBOMProdCtrl ctrl = new CRM_SyncConfigProdWithSBOMProdCtrl(sc);
        CRM_SyncConfigProdWithSBOMProdCtrl.syncConfigProductsWithSBOMProducts(sbomConfig.Id,parentBOMProd.Id);
        
        System.assertEquals(6, [Select count() FROM Config_Product__c where Config__c =:sbomConfig.Id],'Config Product count should be increased by one.');
        
        // insert a new BOM record with Child Product which is not available in Assortment Product List  
        BOM__c bomRec1 = new BOM__c();
        bomRec1.Parent_Product__c = parentBOMProd.Id ;
        bomRec1.Child_Product__c = lstProducts[9].Id;
        bomRec1.Quantity__c = 15;
        insert bomRec1;
        
        CRM_SyncConfigProdWithSBOMProdCtrl.syncConfigProductsWithSBOMProducts(sbomConfig.Id,parentBOMProd.Id);
        
        System.assertEquals(6, [Select count() FROM Config_Product__c where Config__c =:sbomConfig.Id],'Config Product count should not be increased by one.');
        
        Test.stopTest();
    }
     /**
    *  Test 2
    *  @name test_ConfigProductDelete
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void test_ConfigProductDelete(){
        setupTestData();
        
        Test.startTest();
        
        System.assertEquals(5, [Select count() FROM Config_Product__c where Config__c =:sbomConfig.Id],'All 4 child and 1 parent SBOM products must be added to the config.');
        
        List<BOM__c> bomrec = [Select Id From Bom__c where Parent_Product__c =: parentBOMProd.Id limit 1];
        delete bomrec;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(sbomConfig);
        CRM_SyncConfigProdWithSBOMProdCtrl ctrl = new CRM_SyncConfigProdWithSBOMProdCtrl(sc);
        CRM_SyncConfigProdWithSBOMProdCtrl.syncConfigProductsWithSBOMProducts(sbomConfig.Id,parentBOMProd.Id);
        
        System.assertEquals(4, [Select count() FROM Config_Product__c where Config__c =:sbomConfig.Id],'Config Product count should be decreased by one.');
        
        Test.stopTest();
    }
}