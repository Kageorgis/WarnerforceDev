@isTest
public class CRM_UpdateProductGroupOnProductBatchTest {
    
    public static List<Product2> lstProduct = new List<Product2>();
    
    static void createTestData(){  
        Product_Group__c pg1 = new Product_Group__c();
        pg1.name = 'FR Product Group 1';
        pg1.External_Id__c = 'FR Product Group 1';
        insert pg1; 
        
        CRM_Product_Group_Update__c cs1 = new CRM_Product_Group_Update__c();
        cs1.Name = 'step1';
        cs1.Country__c = 'FR';
        cs1.Franchise__c = 'TV';
        cs1.Group__c = pg1.External_Id__c;
        cs1.ID__c = pg1.Id;
        cs1.Order__c = 10;
        cs1.Type__c = 'Video Digital';
        cs1.Product_Market__c = 'EST';
        insert cs1;
        
        Product_Group__c pg2 = new Product_Group__c();
        pg2.name = 'FR Product Group 2';
        pg2.External_Id__c = 'FR Product Group 2';
        insert pg2; 
        
        CRM_Product_Group_Update__c cs2 = new CRM_Product_Group_Update__c();
        cs2.Name = 'step2';
        cs2.Country__c = 'FR';        
        cs2.Group__c = pg1.External_Id__c;
        cs2.ID__c = pg1.Id;
        cs2.Order__c = 10;
        cs2.Type__c = 'Games Physical';
        cs2.Special_Version__c = '69';
        insert cs2;
        
        Product_Group__c pg3 = new Product_Group__c();
        pg3.name = 'Digital HBO';
        pg3.External_Id__c = 'UK Digital HBO';
        pg3.Country__c = 'UK';
        pg3.Type__c = 'Video Digital';
        insert pg3;
        
        CRM_Product_Group_Update__c cs3 = new CRM_Product_Group_Update__c();
        cs3.Name = 'Set IE|GB 8';
        cs3.Content_Type__c = '';
        cs3.Country__c = '(IE|GB)';
        cs3.Franchise__c = '';
        cs3.Group__c = pg2.External_Id__c;
        cs3.ID__c = pg2.Id;
        cs3.Order__c = 1;
        cs3.Type__c = 'Video Digital';
        cs3.Product_Genre__c = '';
        cs3.Product_Label__c = '';
        cs3.Product_Market__c = '';
        cs3.Display_Label__c = 'HBO';
        insert cs3;
        
        //--//
        List<String> strRegion = new List<String>();    
        strRegion.add('FR');
        strRegion.add('GB');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1,false);
        lstCountries[0].Country_Code2__c = 'FR';
        lstCountries[1].Country_Code2__c = 'GB';
        insert lstCountries;
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Season';
        insert tittle;
        
        Title__c tittle1 = new title__c();
        tittle1.name = 'Tittle1';
        insert tittle1;        
        system.assertEquals(2,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(new List<Country__c>{lstCountries[0]}, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        
        List<Local_Title__c> lstLocalData1 = CRM_TestDataFactory.createLocalTitles(new List<Country__c>{lstCountries[1]}, lstLang, 1, false);
        lstLocalData1[0].Name = 'Test HBO Title';
        lstLocalData1[0].Title__c = tittle1.Id;
        lstLocalData1[0].LT_DisplayStudio_Value__c = 'HBO';
        lstLocalData1[0].DisplayStudioOverride__c = 'HBO';
        insert lstLocalData1;        
        system.assertEquals(2,[select count() from Local_Title__c]);
        
        //Create Products
        lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.Product_Market__c = 'EST';
            objProduct.Product_Format__c = null;
            prodCountflag ++;
        }
        
        //Create Products for HBO
        List<Product2> lstProduct1 = CRM_TestDataFactory.createProducts(1,false);
        for (Product2 objProduct1 : lstProduct1){
            objProduct1.Name = 'Product '+ prodCountflag ;
            objProduct1.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct1.Local_Title__c = lstLocalData1[0].Id;
            objProduct1.Product_Group__c = null;
            objProduct1.Type__c = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            prodCountflag ++;
            lstProduct.add(objProduct1);
        }

        
        if(!lstProduct.isEmpty()) {
            insert lstProduct;
        }
        
        system.assertEquals(2,[select Count() from Product2]);
    }
    
    static testmethod void test1() {
        createTestData();
        List<Product2> lstProduct1 = [Select Id,Process_Product_Group__c From Product2];
        for (Product2 objProduct : lstProduct1){
            objProduct.Process_Product_Group__c = true;
        }
        update lstProduct1;
        
        CRM_UpdateProductGroupOnProductBatch batch = new CRM_UpdateProductGroupOnProductBatch();
        Test.startTest();        
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Product2> lstProduct2 = [Select Product_Group__c From Product2];
        System.assertNotEquals(null, lstProduct2[0].Product_Group__c);
    }
}